import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/errors/errors.dart';
import 'package:seasoning/repository/podcast_event.dart';
import 'package:seasoning/repository/repository_provider.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';

part 'podcast_info_provider.freezed.dart';
part 'podcast_info_provider.g.dart';

@riverpod
class PodcastInfo extends _$PodcastInfo {
  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<PodcastDetailsState> build(PodcastMetadata baseInfo) async {
    final podcastService = ref.read(podcastServiceProvider);

    final list = await Future.wait([
      podcastService.loadPodcast(baseInfo),
      _repository.findPodcastStats(baseInfo.guid),
    ]);
    final podcast = list[0] as Podcast?;
    final podcastStats = list[1] as PodcastStats?;
    if (podcast == null) {
      throw NotFoundError();
    }

    _listen();
    return PodcastDetailsState(
      podcast: podcast,
      stats: podcastStats,
    );
  }

  void _listen() {
    ref.listen(podcastEventStreamProvider, (_, next) {
      final event = next.valueOrNull;
      switch (event) {
        case PodcastSubscribedEvent(
                podcast: final podcast,
                stats: final stats
              ) ||
              PodcastUnsubscribedEvent(
                podcast: final podcast,
                stats: final stats
              ):
          if (podcast.guid == state.value?.podcast.guid) {
            state = AsyncData(
              PodcastDetailsState(
                podcast: podcast,
                stats: stats,
              ),
            );
          }
        case PodcastUpdatedEvent(podcast: final podcast):
          if (podcast.guid == state.value?.podcast.guid) {
            state = AsyncData(state.requireValue.copyWith(podcast: podcast));
          }
        case PodcastStatsUpdatedEvent(stats: final stats):
          if (stats.guid == state.value?.podcast.guid) {
            state = AsyncData(state.requireValue.copyWith(stats: stats));
          }
        case null:
      }
    });
  }

  void setViewMode(PodcastDetailViewMode viewMode) {
    if (state.value == null) {
      return;
    }

    final newStats =
        (state.value!.stats ?? PodcastStats(guid: state.value!.podcast.guid))
            .copyWith(viewMode: viewMode);
    _repository.savePodcastStats(newStats);
  }
}

@freezed
class PodcastDetailsState with _$PodcastDetailsState {
  const factory PodcastDetailsState({
    required Podcast podcast,
    PodcastStats? stats,
  }) = _PodcastDetailsState;
}
