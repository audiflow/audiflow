import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
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

  PodcastInfo() {
    _log.fine('PodcastInfo created');
  }

  final _log = Logger('PodcastInfo');

  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<PodcastDetailsState> build(PodcastMetadata metadata) async {
    final podcastService = ref.read(podcastServiceProvider);

    final list = await Future.wait([
      podcastService.loadPodcast(metadata),
      _repository.findPodcastStats(metadata.guid),
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

    _repository.updatePodcastStats(
      PodcastStatsUpdateParam(
        guid: state.value!.podcast.guid,
        viewMode: viewMode,
      ),
    );
  }
}

@freezed
class PodcastDetailsState with _$PodcastDetailsState {
  const factory PodcastDetailsState({
    required Podcast podcast,
    PodcastStats? stats,
  }) = _PodcastDetailsState;
}
