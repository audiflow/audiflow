part of 'podcast_feed_loader.dart';

class _Worker {
  _Worker(
    this._uiPort,
    this._isCancelled,
  );

  final SendPort _uiPort;
  final ReceivePort _workerPort = ReceivePort();
  final bool Function() _isCancelled;
  late final Isar _isar;
  late final PodcastRepository _podcastRepository;
  late final EpisodeRepository _episodeRepository;
  late final PodcastStatsRepository _podcastStatsRepository;
  late final SeasonRepository _seasonRepository;
  late final String _cacheDir;
  final _commandStreamController = StreamController<_Command>();
  final _completer = Completer<void>();
  late PodcastFeedParser<Uint8List, Podcast, Episode>? _feedParser;
  Podcast? _podcast;
  final _newEpisodes = <Episode>[];
  final _ackCompleter = Completer<void>();

  void dispose() {
    _commandStreamController.close();
    _isar.close();
  }

  Future<void> listen() async {
    _listenCommandStream();
    _workerPort
        .listen((event) => _commandStreamController.add(event as _Command));
    _uiPort.send(_SendPortMessage(_workerPort.sendPort));
    return _completer.future.whenComplete(() {
      logger.d('ending worker');
    });
  }

  void _listenCommandStream() {
    _commandStreamController.stream.flatMap(
      (command) async* {
        logger.d(() => 'received command $command');
        try {
          switch (command) {
            case _SetupCommand(
                storageDir: final storageDir,
                cacheDir: final cacheDir
              ):
              await _setupRepository(storageDir);
              _cacheDir = cacheDir;
            case _LoadFeedCommand(
                feedUrl: final feedUrl,
                collectionId: final collectionId,
              ):
              unawaited(
                _handleLoadFeedEvent(
                  feedUrl: feedUrl,
                  collectionId: collectionId,
                ).then((_) => _complete()),
              );
            case _ContinueEpisodeLoadingCommand():
              if (!_ackCompleter.isCompleted) {
                _ackCompleter.complete(null);
              }
            case _CancelledCommand():
              _complete();
          }
          // ignore: avoid_catches_without_on_clauses
        } catch (err) {
          logger.e(err);
          _uiPort.send(_GotErrorMessage(message: err.toString()));
        }
      },
      maxConcurrent: 1,
    ).drain<void>();
  }

  void _complete() {
    if (!_completer.isCompleted) {
      _completer.complete(null);
    }
  }

  Future<void> _setupRepository(String storageDir) async {
    _isar = await IsarFactory.create(storageDir);
    _podcastRepository = IsarPodcastRepository(_isar);
    _podcastStatsRepository = IsarPodcastStatsRepository(_isar);
    _episodeRepository = IsarEpisodeRepository(_isar);
    _seasonRepository = IsarSeasonRepository(_isar);
  }

  Future<void> _handleLoadFeedEvent({
    required String feedUrl,
    required int? collectionId,
  }) async {
    final loaded = await _loadFeed(
      feedUrl: feedUrl,
      collectionId: collectionId ??
          (await _podcastRepository.findPodcastBy(feedUrl: feedUrl))
              ?.collectionId,
      cacheDir: _cacheDir,
    );
    if (!loaded || _isCancelled()) {
      return;
    }

    final sent = await _readPodcast();
    if (!sent || _isCancelled()) {
      return;
    }

    await _readEpisodes();
  }

  Future<bool> _loadFeed({
    required String feedUrl,
    required int? collectionId,
    required String cacheDir,
  }) async {
    var ordinal = DateTime.now().microsecondsSinceEpoch;
    for (final url in [
      feedUrl.replaceFirst(RegExp('^http:'), 'https:'),
      feedUrl.replaceFirst(RegExp('^https:'), 'http:'),
    ]) {
      logger.d(() => 'loadFeed $url, collectionId=$collectionId');
      try {
        final http = CachedHttp(cacheDir);
        final rs = await http
            .fetch<ResponseBody>(url, responseType: ResponseType.stream)
            .timeout(const Duration(seconds: 30));
        if (rs == null) {
          logger.w(() => 'rss is null, url=$feedUrl');
          return false;
        }

        _feedParser = PodcastFeedParser(
          rs.stream,
          channelBuilder: (channelValues) => Podcast.fromFeed(
            channelValues,
            feedUrl: feedUrl,
            newFeedUrl: feedUrl,
            collectionId: collectionId,
          ),
          channelItemBuilder: (channelItemValues) {
            if (_podcast == null) {
              throw StateError('cannot build Episode due to podcast is null');
            }
            return Episode.fromChannelItem(
              pid: _podcast!.id,
              ordinal: ordinal--,
              item: channelItemValues,
            );
          },
        );
        return true;
      } on DioException catch (err) {
        if (err.type == DioExceptionType.connectionError) {
          if (url.startsWith('https:')) {
            logger.e('connectionError; retry');
            continue;
          }
        }
        logger.e(() => 'loadFeed failed: $err');
        return false;
        // ignore: avoid_catches_without_on_clauses
      } catch (err) {
        logger.e(err);
        return false;
      }
    }
    return false;
  }

  Future<bool> _readPodcast() async {
    try {
      final podcast = _podcast = await _feedParser!.readChannel();
      await _podcastRepository.savePodcast(podcast);
      _uiPort.send(_LoadedPodcastMessage());
      return true;
      // ignore: avoid_catches_without_on_clauses
    } catch (err) {
      logger.e(err);
      return false;
    }
  }

  Future<void> _readEpisodes() async {
    logger.d(() => 'read episodes for ${_podcast!.feedUrl}');
    // Get the latest episode to determine the last publication date.
    // If the podcast has loaded all episodes, we don't need to read the entire
    // feed.
    final podcastStats =
        await _podcastStatsRepository.findPodcastStats(_podcast!.id);
    final latest = podcastStats?.hasLoadedAll == true
        ? await _episodeRepository.findLatestEpisode(_podcast!.id)
        : null;
    final lastPubDate = latest?.publicationDate;

    final episodes = <Episode>[];
    var batchLength = 20;
    var loadingState = LoadingState.loadingEpisodes;
    while (true) {
      final episode = await _feedParser!.readChannelItem();
      if (_isCancelled()) {
        await _updateSeasons(loadingState);
        return;
      }

      if (episode == null) {
        loadingState = LoadingState.loadedAllEpisodes;
        break;
      }

      if (lastPubDate != null && episode.publicationDate != null) {
        if (!lastPubDate.isBefore(episode.publicationDate!)) {
          loadingState = LoadingState.reachedLastPubDate;
          break;
        }
      }
      episodes.add(episode);
      _newEpisodes.add(episode);
      if (batchLength <= episodes.length) {
        await _episodeRepository.saveEpisodes(episodes);
        await _podcastStatsRepository.updatePodcastStats(
          PodcastStatsUpdateParam(
            id: _podcast!.id,
            deltaTotalEpisodes: episodes.length,
            latestPubDate: _newEpisodes.firstOrNull?.publicationDate,
          ),
        );
        _uiPort.send(
          _LoadedEpisodesMessage(
            episodes: episodes.map(PartialEpisode.fromEpisode).toList(),
            loadingState: loadingState,
          ),
        );
        episodes.clear();
        await _ackCompleter.future;
        batchLength = 200;
      }
    }

    await _episodeRepository.saveEpisodes(episodes);
    await _podcastStatsRepository.updatePodcastStats(
      PodcastStatsUpdateParam(
        id: _podcast!.id,
        deltaTotalEpisodes: episodes.length,
        lastCheckedAt: DateTime.now(),
        latestPubDate: _newEpisodes.firstOrNull?.publicationDate,
        hasLoadedAll: true,
      ),
    );

    await _updateSeasons(loadingState);
    _uiPort.send(
      _LoadedEpisodesMessage(
        episodes: episodes.map(PartialEpisode.fromEpisode).toList(),
        loadingState: loadingState,
      ),
    );
    logger.d(() => 'read ${_newEpisodes.length} episodes, $loadingState');
  }

  Future<void> _updateSeasons(LoadingState loadingState) async {
    if (_podcast == null || _newEpisodes.isEmpty) {
      return;
    }

    final seasons = await _seasonRepository.findPodcastSeasons(_podcast!.id);
    final seasonExtractor = PodcastSeasonExtractorFactor.create(
      _podcast!,
      knownSeasons: seasons,
    )..process(_newEpisodes);

    if (seasons.isEmpty &&
        seasonExtractor.updatedSeasons.isNotEmpty &&
        loadingState == LoadingState.reachedLastPubDate) {
      logger.d('the podcast turned supporting "season"');
      final allEpisodes = await _episodeRepository.queryEpisodes(
        pid: _podcast!.id,
      );
      seasonExtractor.process(allEpisodes);
    }

    final updatedSeasons = seasonExtractor.updatedSeasons.toList();
    if (updatedSeasons.isNotEmpty) {
      await _seasonRepository.saveSeasons(updatedSeasons);
      _uiPort.send(_LoadedSeasonMessage(seasons: updatedSeasons.toList()));
    }
  }
}
