import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:audiflow/common/data/app_path_repository.dart';
import 'package:audiflow/common/data/isar_factory.dart';
import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/events/season_event.dart';
import 'package:audiflow/features/browser/common/data/podcast_stats_repository/isar_podcast_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/podcast_stats_repository/podcast_stats_repository.dart';
import 'package:audiflow/features/browser/season/data/isar_season_repository.dart';
import 'package:audiflow/features/browser/season/data/season_repository.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_service.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/data/isar_episode_repository.dart';
import 'package:audiflow/features/feed/data/isar_podcast_repository.dart';
import 'package:audiflow/features/feed/data/podcast_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/cached_http.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:podcast_feed/parsers/podcast_feed_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:worker_manager/worker_manager.dart';

part 'podcast_feed_loader.freezed.dart';
part 'podcast_feed_loader.g.dart';

@riverpod
class PodcastFeedLoader extends _$PodcastFeedLoader {
  SendPort? _workerPort;

  String get _cacheDir => ref.read(apiCacheDirProvider);

  String get _appDocDir => ref.read(appDocDirProvider);

  PodcastRepository get _podcastRepository =>
      ref.read(podcastRepositoryProvider);

  bool _initialized = false;

  @override
  PodcastFeedLoaderState build({required String feedUrl}) {
    logger.d(() => 'build($feedUrl)');
    return PodcastFeedLoaderState(feedUrl: feedUrl);
  }

  void setup({int? collectionId}) {
    if (!_initialized) {
      _initialized = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (collectionId != null) {
          state = state.copyWith(collectionId: collectionId);
        }
        _setupWorker();
      });
    }
  }

  Future<void> _setupWorker() async {
    final cancellable = workerManager.executeGentleWithPort<void, _Message>(
      (sendPort, isCancelled) async {
        logger.d('start worker');
        final worker = _Worker(sendPort, isCancelled);
        try {
          await worker.listen();
        } finally {
          worker.dispose();
        }
        logger.d('worker done');
      },
      onMessage: _onWorkerMessage,
    );
    unawaited(cancellable.whenComplete(() => _workerPort = null));

    ref.onDispose(() {
      logger.d('dispose');
      _workerPort?.send(_CancelledCommand());
      _workerPort = null;
    });
  }

  Future<void> _onWorkerMessage(_Message message) async {
    logger.d(() => 'received $message');
    switch (message) {
      case _SendPortMessage(sendPort: final sendPort):
        _workerPort = sendPort;
        _workerPort
          ?..send(
            _SetupCommand(
              cacheDir: _cacheDir,
              storageDir: _appDocDir,
            ),
          )
          ..send(
            _LoadFeedCommand(
              feedUrl: state.feedUrl,
              collectionId: state.collectionId,
            ),
          );
      case _LoadedPodcastMessage():
        final podcast =
            await _podcastRepository.findPodcastBy(feedUrl: state.feedUrl);
        if (podcast == null) {
          logger.w(() => 'podcast is null');
          return;
        }
        logger.d(() => 'loaded new podcast $podcast');
        ref
            .read(podcastEventStreamProvider.notifier)
            .add(PodcastUpdatedEvent(podcast));
        state = state.copyWith(loadingState: LoadingState.loadingEpisodes);
      case _LoadedEpisodesMessage(
          episodes: final episodes,
          loadingState: final loadingState
        ):
        if (episodes.isNotEmpty) {
          ref
              .read(episodeEventStreamProvider.notifier)
              .add(EpisodesAddedEvent(episodes));
          unawaited(
            ref
                .read(podcastStatsRepositoryProvider)
                .findPodcastStats(episodes.first.pid)
                .then((stats) {
              if (stats != null) {
                ref
                    .read(podcastEventStreamProvider.notifier)
                    .add(PodcastStatsUpdatedEvent(stats));
              }
            }),
          );
        }
        state = state.copyWith(loadingState: loadingState);
      case _LoadedSeasonMessage(seasons: final seasons):
        if (seasons.isNotEmpty) {
          ref
              .read(seasonEventStreamProvider.notifier)
              .add(SeasonsUpdatedEvent(seasons));
        }
      case _GotErrorMessage(message: final message):
        logger.w(message);
        state = state.copyWith(loadingState: LoadingState.error);
    }
  }
}

enum LoadingState {
  /// The loader is loading podcast.
  loadingPodcast,

  /// The loader is loading episodes.
  loadingEpisodes,

  /// The loader has all of newer episodes.
  reachedLastPubDate,

  /// The loader has loaded all episodes.
  loadedAllEpisodes,

  /// The loader has encountered an error.
  error,
}

@freezed
class PodcastFeedLoaderState with _$PodcastFeedLoaderState {
  const factory PodcastFeedLoaderState({
    required String feedUrl,
    int? collectionId,
    @Default(LoadingState.loadingPodcast) LoadingState loadingState,
  }) = _PodcastFeedLoaderState;
}

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
              await _handleLoadFeedEvent(
                feedUrl: feedUrl,
                collectionId: collectionId,
              );
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
      _complete();
      return;
    }

    final sent = await _readPodcast();
    if (!sent || _isCancelled()) {
      _complete();
      return;
    }

    await _readEpisodes();
    _complete();
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
    final seasonService = PodcastSeasonService();
    var updatedSeasons = seasonService.extractSeasons(
      _podcast!,
      _newEpisodes,
      seasons,
    );

    if (seasons.isEmpty &&
        updatedSeasons.isNotEmpty &&
        loadingState == LoadingState.reachedLastPubDate) {
      logger.d('the podcast turned supporting "season"');
      final allEpisodes = await _episodeRepository.queryEpisodes(
        pid: _podcast!.id,
      );
      updatedSeasons = seasonService.extractSeasons(
        _podcast!,
        allEpisodes,
        seasons,
      );
    }

    if (updatedSeasons.isNotEmpty) {
      await _seasonRepository.saveSeasons(updatedSeasons);
      _uiPort.send(_LoadedSeasonMessage(seasons: updatedSeasons.toList()));
    }
  }
}

sealed class _Command {}

sealed class _Message {}

class _SendPortMessage extends _Message {
  _SendPortMessage(this.sendPort);

  final SendPort sendPort;

  @override
  String toString() {
    return '_SendPortEvent{sendPort}';
  }
}

class _SetupCommand extends _Command {
  _SetupCommand({
    required this.cacheDir,
    required this.storageDir,
  });

  final String cacheDir;
  final String storageDir;

  @override
  String toString() {
    return '_SetupCommand(cacheDir: $cacheDir, storageDir: $storageDir)';
  }
}

class _LoadFeedCommand extends _Command {
  _LoadFeedCommand({
    required this.feedUrl,
    required this.collectionId,
  });

  final String feedUrl;
  final int? collectionId;

  @override
  String toString() {
    return '_LoadFeedCommand('
        'feedUrl: $feedUrl, '
        'collectionId: $collectionId)';
  }
}

class _LoadedPodcastMessage extends _Message {
  _LoadedPodcastMessage();

  @override
  String toString() {
    return '_LoadedPodcastMessage()';
  }
}

class _LoadedEpisodesMessage extends _Message {
  _LoadedEpisodesMessage({
    required this.episodes,
    required this.loadingState,
  });

  final List<PartialEpisode> episodes;
  final LoadingState loadingState;

  @override
  String toString() {
    return '_LoadedEpisodesMessage('
        'episodes: ${episodes.length} episodes, '
        'loadingState: $loadingState)';
  }
}

class _LoadedSeasonMessage extends _Message {
  _LoadedSeasonMessage({
    required this.seasons,
  });

  final List<Season> seasons;

  @override
  String toString() {
    return '_LoadedSeasonMessage(seasons: ${seasons.length} seasons)';
  }
}

class _CancelledCommand extends _Command {
  _CancelledCommand();

  @override
  String toString() {
    return '_CancelledCommand()';
  }
}

class _GotErrorMessage extends _Message {
  _GotErrorMessage({required this.message});

  final String message;

  @override
  String toString() {
    return '_ErrorResult(message: $message)';
  }
}
