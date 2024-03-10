import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/errors/errors.dart';
import 'package:audiflow/repository/podcast_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_info_provider.freezed.dart';
part 'podcast_info_provider.g.dart';

@riverpod
class PodcastInfo extends _$PodcastInfo {
  final _log = Logger('PodcastInfo');

  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<PodcastDetailsState> build(PodcastMetadata metadata) async {
    _log.fine('build ${metadata.guid} ${metadata.title}');
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
          if (podcast.guid == state.valueOrNull?.podcast.guid) {
            state = AsyncData(
              PodcastDetailsState(
                podcast: podcast,
                stats: stats,
              ),
            );
          }
        case PodcastUpdatedEvent(podcast: final podcast):
          if (podcast.guid == state.valueOrNull?.podcast.guid) {
            state = AsyncData(state.requireValue.copyWith(podcast: podcast));
          }
        case PodcastStatsUpdatedEvent(stats: final stats):
          if (stats.guid == state.valueOrNull?.podcast.guid) {
            state = AsyncData(state.requireValue.copyWith(stats: stats));
          }
        case null:
      }
    });
  }

  void setViewMode(PodcastDetailViewMode viewMode) {
    if (state.valueOrNull == null) {
      return;
    }

    _repository.updatePodcastStats(
      PodcastStatsUpdateParam(
        guid: state.requireValue.podcast.guid,
        viewMode: viewMode,
      ),
    );
  }

  void toggleAscend() {
    if (state.valueOrNull == null) {
      return;
    }

    _repository.updatePodcastStats(
      PodcastStatsUpdateParam(
        guid: state.requireValue.podcast.guid,
        ascend: !(state.requireValue.stats?.ascend ?? false),
      ),
    );
  }

  void toggleAscendSeasonEpisode() {
    if (state.valueOrNull == null) {
      return;
    }

    _repository.updatePodcastStats(
      PodcastStatsUpdateParam(
        guid: state.requireValue.podcast.guid,
        ascendSeasonEpisodes:
            !(state.requireValue.stats?.ascendSeasonEpisodes ?? true),
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
