import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/errors/errors.dart';
import 'package:seasoning/events/podcast_event.dart';
import 'package:seasoning/providers/podcast_service_provider.dart';
import 'package:seasoning/providers/repository_provider.dart';

part 'podcast_details_provider.freezed.dart';
part 'podcast_details_provider.g.dart';

@riverpod
class PodcastDetail extends _$PodcastDetail {
  @override
  Future<PodcastDetailsState> build(PodcastBaseInfo baseInfo) async {
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
      print('!!! no podcast');
      throw NotFoundError();
    }

    print('!!! podcast found');
    return PodcastDetailsState(
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
            PodcastDetailsState(
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
class PodcastDetailsState with _$PodcastDetailsState {
  const factory PodcastDetailsState({
    required Podcast podcast,
    PodcastStats? stats,
  }) = _PodcastDetailsState;
}
