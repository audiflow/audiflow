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
import 'package:audiflow/features/browser/season/service/podcast_season_extractor_factory.dart';
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
part 'podcast_feed_loader_commands.dart';
part 'podcast_feed_loader_worker.dart';

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
        _workerPort?.send(_ContinueEpisodeLoadingCommand());
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

