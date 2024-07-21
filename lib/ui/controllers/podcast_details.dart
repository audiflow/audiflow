import 'package:audiflow/core/exception/app_exception.dart';
import 'package:audiflow/core/logger.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/podcast_event.dart';
import 'package:audiflow/services/podcast/api/podcast_feed_loader.dart';
import 'package:audiflow/services/podcast/podcast_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_details.freezed.dart';
part 'podcast_details.g.dart';

@riverpod
class PodcastDetails extends _$PodcastDetails {
  PodcastService get _podcastService => ref.read(podcastServiceProvider);

  @override
  PodcastDetailsState build({
    String? feedUrl,
    int? collectionId,
  }) {
    _listen();
    if (feedUrl != null) {
      logger.d('build: feedUrl=$feedUrl');
      _setupWithFeedUrl(feedUrl, collectionId);
    } else if (collectionId != null) {
      logger.d('build: collectionId=$collectionId');
      _setupWithCollectionId(collectionId);
    } else {
      throw ArgumentError('feedUrl or collectionId is required');
    }

    return PodcastDetailsState(
      collectionId: collectionId,
      feedUrl: feedUrl,
    );
  }

  void _listen() {
    ref.listen(podcastEventStreamProvider, (_, next) {
      next.whenData((event) {
        switch (event) {
          case PodcastSubscribedEvent(
                  podcast: final podcast,
                  stats: final stats
                ) ||
                PodcastUnsubscribedEvent(
                  podcast: final podcast,
                  stats: final stats
                ):
            if (podcast.id == state.podcast?.id) {
              state = state.copyWith(stats: stats);
            }
          case PodcastUpdatedEvent(podcast: final podcast):
            if (podcast.guid == state.podcast?.guid) {
              state = state.copyWith(podcast: podcast);
            }
          case PodcastStatsUpdatedEvent(stats: final stats):
            if (stats.id == state.podcast?.id) {
              state = state.copyWith(stats: stats);
            }
          case PodcastViewStatsUpdatedEvent():
        }
      });
    });
  }

  void _listenFeed(String feedUrl) {
    ref.listen(
      podcastFeedLoaderProvider(feedUrl: feedUrl, collectionId: collectionId),
      (_, next) {
        if (next.podcast != null && next.podcast != state.podcast) {
          logger.d(
            state.podcast == null
                ? 'loaded podcast from feed'
                : 'updated podcast from feed',
          );
          final podcast = next.podcast!;
          state = state.copyWith(
            podcast: podcast,
            feedUrl: podcast.feedUrl,
            collectionId: podcast.collectionId,
          );
        }
      },
      fireImmediately: true,
    );
  }

  Future<void> _setupWithFeedUrl(String feedUrl, int? collectionId) async {
    final [podcast, stats] = await Future.wait([
      _podcastService.findPodcastBy(feedUrl: feedUrl),
      _podcastService.findPodcastStatsBy(feedUrl: feedUrl),
    ]);
    if (podcast != null) {
      state = state.copyWith(
        podcast: podcast as Podcast,
        stats: stats as PodcastStats?,
        collectionId: podcast.collectionId,
      );
    } else if (stats != null) {
      state = state.copyWith(
        stats: stats as PodcastStats,
      );
    }

    _listenFeed(feedUrl);
  }

  Future<void> _setupWithCollectionId(int collectionId) async {
    final podcast =
        await _podcastService.findPodcastBy(collectionId: collectionId);
    if (podcast != null) {
      final stats =
          await _podcastService.findPodcastStatsBy(feedUrl: podcast.feedUrl);
      state = state.copyWith(
        podcast: podcast,
        stats: stats,
        feedUrl: podcast.feedUrl,
      );
      _listenFeed(podcast.feedUrl);
      return;
    }

    final feedUrl =
        await _podcastService.findOrFetchFeedUrlBy(collectionId: collectionId);
    if (feedUrl == null) {
      state = state.copyWith(error: NotFoundException());
      return;
    }
    _listenFeed(feedUrl);
  }
}

@freezed
class PodcastDetailsState with _$PodcastDetailsState {
  const factory PodcastDetailsState({
    String? feedUrl,
    int? collectionId,
    Podcast? podcast,
    PodcastStats? stats,
    @Default([]) List<Episode> episodes,
    AppException? error,
  }) = _PodcastDetailsState;
}
