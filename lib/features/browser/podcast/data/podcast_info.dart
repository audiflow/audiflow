import 'package:audiflow/core/exception/app_exception.dart';
import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/feed/data/podcast_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/feed/service/podcast_feed_loader_igniter.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_info.freezed.dart';
part 'podcast_info.g.dart';

@riverpod
class PodcastInfo extends _$PodcastInfo {
  PodcastRepository get _podcastRepository =>
      ref.read(podcastRepositoryProvider);

  StatsRepository get _statsRepository => ref.read(statsRepositoryProvider);

  @override
  Future<PodcastInfoState> build({
    String? feedUrl,
    int? collectionId,
  }) async {
    logger.d('build: feedUrl="$feedUrl", collectionId=$collectionId');
    assert(feedUrl != null || collectionId != null);

    _listenRepository();
    _listenFeedLoader();
    if (feedUrl != null) {
      return _setupWithFeedUrl(feedUrl, collectionId);
    } else if (collectionId != null) {
      return _setupWithCollectionId(collectionId);
    }
    return PodcastInfoState(error: NotFoundException());
  }

  void _listenFeedLoader() {
    ref.listen(
      podcastFeedLoaderIgniterProvider(
        feedUrl: feedUrl,
        collectionId: collectionId,
      ),
      (_, next) {},
    );
  }

  void _listenRepository() {
    bool isTargetPodcast(Podcast podcast) {
      if (collectionId != null) {
        return podcast.collectionId == collectionId;
      } else if (feedUrl != null) {
        return podcast.feedUrl == feedUrl;
      }
      return false;
    }

    AsyncValue<PodcastInfoState> copyStateWith(
      Podcast? podcast,
      PodcastStats? stats,
    ) {
      return AsyncData(
        state.hasValue
            ? state.requireValue.copyWith(
                podcast: podcast ?? state.requireValue.podcast,
                stats: stats ?? state.requireValue.stats,
              )
            : PodcastInfoState(
                podcast: podcast,
                stats: stats,
              ),
      );
    }

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
            if (isTargetPodcast(podcast)) {
              state = copyStateWith(null, stats);
            }
          case PodcastUpdatedEvent(podcast: final podcast, stats: final stats):
            if (isTargetPodcast(podcast)) {
              if (stats == null && state.valueOrNull?.stats == null) {
                _statsRepository.findPodcastStats(podcast.id).then((stats) {
                  state = copyStateWith(podcast, stats);
                });
              } else {
                state = copyStateWith(podcast, stats);
              }
            }
          case PodcastStatsUpdatedEvent(stats: final stats):
            final podcast = state.valueOrNull?.podcast;
            if (podcast?.id == stats.id) {
              state = copyStateWith(null, stats);
            }
          case PodcastViewStatsUpdatedEvent():
        }
      });
    });
  }

  Future<PodcastInfoState> _setupWithFeedUrl(
    String feedUrl,
    int? collectionId,
  ) async {
    final [podcast, stats] = await Future.wait([
      _podcastRepository.findPodcastBy(feedUrl: feedUrl),
      _statsRepository.findPodcastStatsBy(feedUrl: feedUrl),
    ]);
    if (podcast != null) {
      return PodcastInfoState(
        podcast: podcast as Podcast,
        stats: stats as PodcastStats?,
      );
    } else if (stats != null) {
      return PodcastInfoState(stats: stats as PodcastStats);
    }

    return const PodcastInfoState();
  }

  Future<PodcastInfoState> _setupWithCollectionId(int collectionId) async {
    final podcast =
        await _podcastRepository.findPodcastBy(collectionId: collectionId);
    if (podcast != null) {
      final stats =
          await _statsRepository.findPodcastStatsBy(feedUrl: podcast.feedUrl);
      return PodcastInfoState(
        podcast: podcast,
        stats: stats,
      );
    }

    final feedUrl =
        await _podcastRepository.findPodcastBy(collectionId: collectionId);
    if (feedUrl == null) {
      return PodcastInfoState(error: NotFoundException());
    }

    return const PodcastInfoState();
  }
}

@freezed
class PodcastInfoState with _$PodcastInfoState {
  const factory PodcastInfoState({
    Podcast? podcast,
    PodcastStats? stats,
    AppException? error,
  }) = _PodcastInfoState;
}
