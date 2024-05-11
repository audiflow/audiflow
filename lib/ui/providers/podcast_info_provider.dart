import 'package:audiflow/core/exception/app_exception.dart';
import 'package:audiflow/core/logger.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/podcast_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_info_provider.freezed.dart';
part 'podcast_info_provider.g.dart';

@riverpod
class PodcastInfo extends _$PodcastInfo {

  Repository get _repository => ref.read(repositoryProvider);

  PodcastService get _podcastService => ref.read(podcastServiceProvider);

  @override
  Future<PodcastInfoState> build({
    String? feedUrl,
    int? collectionId,
  }) async {
    if (feedUrl != null) {
      logger.d('build: feedUrl="$feedUrl"');
    } else if (collectionId != null) {
      logger.d('build: collectionId=$collectionId');
    } else {
      throw ArgumentError('feedUrl or collectionId is required');
    }

    feedUrl ??= await _podcastService.findOrFetchFeedUrlBy(
      collectionId: collectionId!,
    );
    if (feedUrl == null) {
      throw NotFoundException();
    }

    final (podcast, episodes) =
        await _podcastService.findOrFetchPodcastBy(feedUrl: feedUrl);
    if (podcast == null) {
      throw NotFoundException();
    }

    final podcastStats = await _repository.findPodcastStats(podcast.id);

    _listen();
    return PodcastInfoState(
      podcast: podcast,
      stats: podcastStats,
      episodes: episodes,
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
            if (podcast.id == state.valueOrNull?.podcast.id) {
              state = AsyncData(
                PodcastInfoState(
                  podcast: podcast,
                  stats: stats,
                  episodes: state.requireValue.episodes,
                ),
              );
            }
          case PodcastUpdatedEvent(podcast: final podcast):
            if (podcast.guid == state.valueOrNull?.podcast.guid) {
              state = AsyncData(state.requireValue.copyWith(podcast: podcast));
            }
          case PodcastStatsUpdatedEvent(stats: final stats):
            if (stats.id == state.valueOrNull?.podcast.id) {
              state = AsyncData(state.requireValue.copyWith(stats: stats));
            }
          case PodcastViewStatsUpdatedEvent():
        }
      });
    });
  }
}

@freezed
class PodcastInfoState with _$PodcastInfoState {
  const factory PodcastInfoState({
    required Podcast podcast,
    PodcastStats? stats,
    required List<Episode> episodes,
  }) = _PodcastInfoState;
}
