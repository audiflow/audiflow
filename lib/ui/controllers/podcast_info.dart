import 'package:audiflow/core/exception/app_exception.dart';
import 'package:audiflow/core/logger.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/podcast/api/podcast_feed_loader_igniter.dart';
import 'package:audiflow/services/podcast/podcast_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_info.freezed.dart';
part 'podcast_info.g.dart';

@riverpod
class PodcastInfo extends _$PodcastInfo {
  Repository get _repository => ref.read(repositoryProvider);

  PodcastService get _podcastService => ref.read(podcastServiceProvider);

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
                _repository.findPodcastStats(podcast.id).then((stats) {
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
      _podcastService.findPodcastBy(feedUrl: feedUrl),
      _podcastService.findPodcastStatsBy(feedUrl: feedUrl),
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
        await _podcastService.findPodcastBy(collectionId: collectionId);
    if (podcast != null) {
      final stats =
          await _podcastService.findPodcastStatsBy(feedUrl: podcast.feedUrl);
      return PodcastInfoState(
        podcast: podcast,
        stats: stats,
      );
    }

    final feedUrl =
        await _podcastService.findOrFetchFeedUrlBy(collectionId: collectionId);
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
