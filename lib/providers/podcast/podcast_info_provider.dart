import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/errors/errors.dart';
import 'package:seasoning/events/podcast_event.dart';
import 'package:seasoning/providers/podcast_service_provider.dart';
import 'package:seasoning/providers/repository_provider.dart';

part 'podcast_info_provider.freezed.dart';
part 'podcast_info_provider.g.dart';

@riverpod
class PodcastInfo extends _$PodcastInfo {
  @override
  Future<PodcastInfoState> build(PodcastSummary baseInfo) async {
    _listen();

    final podcastService = ref.read(podcastServiceProvider);
    final repository = ref.read(repositoryProvider);

    final list = await Future.wait([
      podcastService.loadPodcast(baseInfo),
      repository.findPodcastStatsByGuid(baseInfo.guid),
    ]);
    final podcast = list[0] as Podcast?;
    final podcastStats = list[1] as PodcastStats?;
    if (podcast == null) {
      throw NotFoundError();
    }

    return PodcastInfoState(
      podcast: podcast,
      stats: podcastStats,
    );
  }

  void _listen() {
    final repository = ref.read(repositoryProvider);

    final sub =
        repository.podcastListener.where((event) => false).listen((event) {
      switch (event) {
        case PodcastSubscribedEvent(
                podcast: final podcast,
                stats: final stats
              ) ||
              PodcastUnsubscribedEvent(
                podcast: final podcast,
                stats: final stats
              ):
          state = AsyncData(
            PodcastInfoState(
              podcast: podcast,
              stats: stats,
            ),
          );
        case PodcastUpdatedEvent(podcast: final podcast):
          state = AsyncData(state.requireValue.copyWith(podcast: podcast));
        case PodcastStatsUpdatedEvent(stats: final stats):
          state = AsyncData(state.requireValue.copyWith(stats: stats));
      }
    });
    ref.onDispose(sub.cancel);
  }
}

@freezed
class PodcastInfoState with _$PodcastInfoState {
  const factory PodcastInfoState({
    required Podcast podcast,
    PodcastStats? stats,
  }) = _PodcastInfoState;
}
