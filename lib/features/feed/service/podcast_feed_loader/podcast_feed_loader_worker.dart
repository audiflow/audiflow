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
  late final PodcastStatsRepository _podcastStatsRepository;
  late final String _cacheDir;
  final _commandStreamController = StreamController<_Command>();
  final _completer = Completer<void>();
  late PodcastFeedParser<Uint8List, Podcast, Episode>? _feedParser;
  Podcast? _podcast;
  final _ackCompleter = Completer<void>();

  void dispose() {
    _commandStreamController.close();
    _isar.close();
  }

  Future<void> listen() async {
    _listenCommandStream();
    _workerPort
        .listen((event) => _commandStreamController.add(event as _Command));
    _sendMessage(_SendPortMessage(_workerPort.sendPort));
    return _completer.future.whenComplete(() {
      logger.d('ending worker');
    });
  }

  void _sendMessage(_Message message) {
    if (!_isCancelled()) {
      _uiPort.send(message);
    }
  }

  void _listenCommandStream() {
    _commandStreamController.stream.listen((command) async {
      logger.d(() => 'received command $command');
      try {
        switch (command) {
          case _LoadFeedCommand(
              storageDir: final storageDir,
              cacheDir: final cacheDir,
              feedUrl: final feedUrl,
              collectionId: final collectionId,
            ):
            _isar = await IsarFactory.create(storageDir);
            _podcastRepository = IsarPodcastRepository(_isar);
            _podcastStatsRepository = IsarPodcastStatsRepository(_isar);
            _cacheDir = cacheDir;
            await _handleLoadFeedEvent(
              feedUrl: feedUrl,
              collectionId: collectionId,
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
        _sendMessage(_GotErrorMessage(message: err.toString()));
      }
    });
  }

  void _complete() {
    if (!_completer.isCompleted) {
      _completer.complete(null);
    }
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
      _sendMessage(_LoadedPodcastMessage(podcast.id));
      return true;
      // ignore: avoid_catches_without_on_clauses
    } catch (err) {
      logger.e(err);
      return false;
    }
  }

  Future<void> _readEpisodes() async {
    logger.d(() => 'read episodes for ${_podcast!.feedUrl}');

    final episodesUpdater = _EpisodesUpdater(
      pid: _podcast!.id,
      episodeRepository: IsarEpisodeRepository(_isar),
      episodeStatsRepository: IsarEpisodeStatsRepository(_isar),
    );
    final seasonUpdater = _SeasonUpdater(
      podcast: _podcast!,
      seasonRepository: IsarSeasonRepository(_isar),
    );

    var isFirst = true;
    while (!_isCancelled()) {
      final batchLength = isFirst ? 20 : 200;
      final episodes = await _feedParser!.readChannelItems(limit: batchLength);
      final isLast = episodes.length < batchLength;
      final state =
          await episodesUpdater.processParsedEpisodes(episodes, isLast: isLast);

      if (state.inserts.isNotEmpty || state.deletes.isNotEmpty) {
        await _podcastStatsRepository.updatePodcastStats(
          PodcastStatsUpdateParam(
            id: _podcast!.id,
            deltaTotalEpisodes: state.inserts.length - state.deletes.length,
            latestPubDate:
                isFirst ? episodes.firstOrNull?.publicationDate : null,
            lastCheckedAt: isLast ? DateTime.now() : null,
            hasLoadedAll: isLast ? true : null,
          ),
        );
      }

      _sendMessage(
        _LoadedEpisodesMessage(
          inserts: state.inserts.map(PartialEpisode.fromEpisode).toList(),
          updates: state.updates.map(PartialEpisode.fromEpisode).toList(),
          deletes: state.deletes.map(PartialEpisode.fromEpisode).toList(),
          loadingState: isLast
              ? LoadingState.loadedAllEpisodes
              : LoadingState.loadingEpisodes,
        ),
      );

      final seasonsState =
          await seasonUpdater.processParsedEpisodes(state, isLast: isLast);
      if (seasonsState.updates.isNotEmpty || seasonsState.deletes.isNotEmpty) {
        _sendMessage(
          _LoadedSeasonMessage(
            updates: seasonsState.updates,
            deletes: seasonsState.deletes,
          ),
        );
      }

      if (episodes.length < batchLength) {
        break;
      }
      await _ackCompleter.future;
      isFirst = false;
    }
  }

// Future<void> _updateSeasons(LoadingState loadingState) async {
//   final seasons = await _seasonRepository.findPodcastSeasons(_podcast!.id);
//   final seasonExtractor = PodcastSeasonExtractorFactor.create(
//     _podcast!,
//     knownSeasons: seasons,
//   )..process(_newEpisodes);
//
//   if (seasons.isEmpty &&
//       seasonExtractor.updatedSeasons.isNotEmpty &&
//       loadingState == LoadingState.reachedLastPubDate) {
//     logger.d('the podcast turned supporting "season"');
//     final allEpisodes = await _episodeRepository.queryEpisodes(
//       pid: _podcast!.id,
//     );
//     seasonExtractor.process(allEpisodes);
//   }
//
//   final updatedSeasons = seasonExtractor.updatedSeasons.toList();
//   if (updatedSeasons.isNotEmpty) {
//     await _seasonRepository.saveSeasons(updatedSeasons);
//     _sendMessage(_LoadedSeasonMessage(seasons: updatedSeasons.toList()));
//   }
// }
}

class _EpisodesState {
  const _EpisodesState({
    this.inserts = const [],
    this.updates = const [],
    this.deletes = const [],
    this.unchanged = const [],
  });

  final List<Episode> inserts;
  final List<Episode> updates;
  final List<Episode> deletes;
  final List<Episode> unchanged;
}

class _EpisodesUpdater {
  _EpisodesUpdater({
    required this.pid,
    required this.episodeRepository,
    required this.episodeStatsRepository,
  });

  final int pid;
  final EpisodeRepository episodeRepository;
  final EpisodeStatsRepository episodeStatsRepository;

  final List<Episode> unchanged = [];

  bool _readsAll = false;
  int? _lastOrdinalForQuery;
  int? _nextOrdinalForStore;
  final List<Episode> _episodes = [];

  Future<_EpisodesState> processParsedEpisodes(
    List<Episode> episodes, {
    required bool isLast,
  }) async {
    final inserts = <Episode>[];
    final updates = <Episode>[];
    final deletes = <Episode>[];
    final unchanged = <Episode>[];

    await _prepareEpisodes(count: episodes.length - _episodes.length + 30);
    if (_episodes.isEmpty) {
      if (episodes.isNotEmpty) {
        if (_nextOrdinalForStore == null) {
          inserts.addAll(episodes);
        } else {
          var ordinal = _nextOrdinalForStore!;
          for (final parsed in episodes) {
            inserts.add(parsed.copyWith(ordinal: ordinal--));
          }
          _nextOrdinalForStore = ordinal;
        }
        await episodeRepository.saveEpisodes(episodes);
      }
      return _EpisodesState(inserts: inserts);
    }

    var ordinal = _nextOrdinalForStore ?? episodes.first.ordinal;
    for (final parsed in episodes) {
      final i = _episodes.indexWhere((e) => e.guid == parsed.guid);
      if (i < 0) {
        inserts.add(parsed.copyWith(ordinal: ordinal--));
      } else {
        if (_episodes[i].contentEquals(parsed)) {
          unchanged.add(_episodes[i]);
        } else {
          updates.add(parsed.copyWith(ordinal: _episodes[i].ordinal));
        }
        ordinal = _episodes[i].ordinal - 1;
        _episodes.removeAt(i);
        if (0 < i) {
          deletes.addAll(_episodes.sublist(0, i));
          _episodes.removeRange(0, i);
        }
      }
    }
    _nextOrdinalForStore = ordinal;

    if (isLast) {
      deletes.addAll(_episodes);
    }

    final tasks = <Future<dynamic>>[
      if (inserts.isNotEmpty || updates.isNotEmpty)
        episodeRepository.saveEpisodes([...inserts, ...updates]),
      if (deletes.isNotEmpty)
        episodeRepository.deleteEpisodes(deletes.map((e) => e.id).toList()),
    ];
    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }
    return _EpisodesState(
      inserts: inserts,
      updates: updates,
      deletes: deletes,
      unchanged: unchanged,
    );
  }

  Future<void> _prepareEpisodes({required int count}) async {
    if (_readsAll || count <= 0) {
      return;
    }

    final episodes = await episodeRepository.queryEpisodes(
      pid: pid,
      lastOrdinal: _lastOrdinalForQuery,
      limit: count,
    );
    _readsAll = episodes.length < count;
    if (episodes.isNotEmpty) {
      _lastOrdinalForQuery = episodes.last.ordinal;
      _episodes.addAll(episodes);
    }
  }
}

class _SeasonsState {
  const _SeasonsState({
    this.updates = const [],
    this.deletes = const [],
  });

  final List<Season> updates;
  final List<Season> deletes;
}

class _SeasonUpdater {
  _SeasonUpdater({
    required this.podcast,
    required this.seasonRepository,
  });

  final Podcast podcast;
  final SeasonRepository seasonRepository;

  bool? _supportsSeasons;
  PodcastSeasonExtractor? _seasonExtractor;
  final List<Episode> _episodes = [];
  final List<Episode> _deletedEpisodes = [];

  Future<_SeasonsState> processParsedEpisodes(
    _EpisodesState state, {
    required bool isLast,
  }) async {
    _supportsSeasons ??= _determineSeasonSupportiveState(state);
    if (_supportsSeasons == false) {
      return const _SeasonsState();
    }
    _seasonExtractor ??= PodcastSeasonExtractorFactor.create(
      podcast,
      knownSeasons: await seasonRepository.findPodcastSeasons(podcast.id),
    );

    switch (_seasonExtractor!.titleExtractor.distinction) {
      case SeasonDistinction.seasonNum:
        final episodes = [
          ...state.inserts,
          ...state.updates,
        ].sorted((a, b) => a.ordinal - b.ordinal);
        _seasonExtractor!
          ..process(episodes)
          ..remove(state.deletes);
      case SeasonDistinction.title:
        _episodes
            .addAll([...state.inserts, ...state.updates, ...state.unchanged]);
        _deletedEpisodes.addAll(state.deletes);
        if (isLast) {
          _seasonExtractor!
            ..process(_episodes.sorted((a, b) => a.ordinal - b.ordinal))
            ..remove(_deletedEpisodes);
        }
    }

    if (_seasonExtractor!.updatedSeasons.isEmpty) {
      return const _SeasonsState();
    }

    final updatedSeasons = _seasonExtractor!.updatedSeasons
        .where((season) => season.episodeIds.isNotEmpty)
        .toList();
    final deletedSeasons = _seasonExtractor!.updatedSeasons
        .where((season) => season.episodeIds.isEmpty)
        .toList();
    if (updatedSeasons.isNotEmpty) {
      await seasonRepository.saveSeasons(updatedSeasons);
    }
    if (deletedSeasons.isNotEmpty) {
      await seasonRepository.deleteAll(deletedSeasons.map((s) => s.id));
    }
    _seasonExtractor!.flush();

    return _SeasonsState(
      updates: updatedSeasons,
      deletes: deletedSeasons,
    );
  }

  bool _determineSeasonSupportiveState(_EpisodesState state) {
    if (PodcastSeasonExtractorFactor.supports(podcast.feedUrl)) {
      return true;
    }
    final episodes = [...state.inserts, ...state.updates, ...state.unchanged];
    final count = episodes.where((e) => 0 < (e.season ?? 0)).length;
    return 0.5 <= (count.toDouble() / episodes.length.toDouble());
  }
}

extension _EpisodeCompare on Episode {
  bool contentEquals(Episode other) {
    return contentUrl == other.contentUrl &&
        title == other.title &&
        author == other.author &&
        link == other.link &&
        description == other.description &&
        durationMS == other.durationMS &&
        imageUrl == other.imageUrl &&
        explicit == other.explicit &&
        episode == other.episode &&
        season == other.season &&
        type == other.type;
  }
}
