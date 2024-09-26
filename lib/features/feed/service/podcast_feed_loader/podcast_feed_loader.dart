import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:audiflow/common/data/app_path_repository.dart';
import 'package:audiflow/common/data/isar_factory.dart';
import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/events/season_event.dart';
import 'package:audiflow/features/browser/common/data/default_podcast_api_repository.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/isar_episode_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/podcast_stats_repository/isar_podcast_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/podcast_stats_repository/podcast_stats_repository.dart';
import 'package:audiflow/features/browser/season/data/isar_season_repository.dart';
import 'package:audiflow/features/browser/season/data/season_repository.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_extractor.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_extractor_factory.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/data/isar_episode_repository.dart';
import 'package:audiflow/features/feed/data/isar_podcast_repository.dart';
import 'package:audiflow/features/feed/data/podcast_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/cached_http.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:podcast_feed/parsers/podcast_feed_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
        sendPort.send(
          _LoadFeedCommand(
            cacheDir: _cacheDir,
            storageDir: _appDocDir,
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
        _notifyPodcastUpdated(podcast);
        state = state.copyWith(loadingState: LoadingState.loadingEpisodes);
      case _LoadedEpisodesMessage(
          inserts: final inserts,
          updates: final updates,
          deletes: final deletes,
          loadingState: final loadingState
        ):
        if (inserts.isNotEmpty) {
          _notifyEpisodesAdded(inserts);
          _notifyPodcastStatsUpdated(inserts.first.pid);
        }
        state = state.copyWith(loadingState: loadingState);
        if (loadingState == LoadingState.loadingEpisodes) {
          _workerPort?.send(_ContinueEpisodeLoadingCommand());
        } else if ([
          LoadingState.reachedLastPubDate,
          LoadingState.loadedAllEpisodes,
        ].contains(loadingState)) {
          _workerPort?.send(_CancelledCommand());
        }
      case _LoadedSeasonMessage(updates: final seasons):
        _notifySeasonsUpdated(seasons);
      case _GotErrorMessage(message: final message):
        logger.w(message);
        state = state.copyWith(loadingState: LoadingState.error);
    }
  }

  void _notifyPodcastUpdated(Podcast podcast) {
    logger.d(() => 'loaded new podcast $podcast');
    ref
        .read(podcastEventStreamProvider.notifier)
        .add(PodcastUpdatedEvent(podcast));
  }

  void _notifyEpisodesAdded(List<PartialEpisode> episodes) {
    ref
        .read(episodeEventStreamProvider.notifier)
        .add(EpisodesAddedEvent(episodes));
  }

  void _notifyEpisodesUpdated(List<Episode> episodes) {
    ref
        .read(episodeEventStreamProvider.notifier)
        .add(EpisodesUpdatedEvent(episodes));
  }

  void _notifyEpisodesDeleted(List<PartialEpisode> episodes) {
    ref
        .read(episodeEventStreamProvider.notifier)
        .add(EpisodesDeletedEvent(episodes.map((e) => e.id).toList()));
  }

  void _notifyPodcastStatsUpdated(int pid) {
    ref
        .read(podcastStatsRepositoryProvider)
        .findPodcastStats(pid)
        .then((stats) {
      if (stats != null) {
        ref
            .read(podcastEventStreamProvider.notifier)
            .add(PodcastStatsUpdatedEvent(stats));
      }
    });
  }

  void _notifySeasonsUpdated(List<Season> seasons) {
    if (seasons.isNotEmpty) {
      ref
          .read(seasonEventStreamProvider.notifier)
          .add(SeasonsUpdatedEvent(seasons));
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
