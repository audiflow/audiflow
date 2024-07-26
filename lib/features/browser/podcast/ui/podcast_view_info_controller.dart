import 'dart:async';

import 'package:audiflow/events/audio_player_event.dart';
import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_view_info_controller.g.dart';

@riverpod
class PodcastViewInfoController extends _$PodcastViewInfoController {
  StatsRepository get _statsRepository => ref.read(statsRepositoryProvider);

  @override
  Future<PodcastViewStats> build(int pid) async {
    logger.d(() => 'build pid=$pid');
    final viewStats = await _statsRepository.findPodcastViewStats(pid);
    _listen();
    return viewStats ?? PodcastViewStats(id: pid);
  }

  void _listen() {
    ref
      ..listen(podcastEventStreamProvider, (_, next) {
        next.whenData((event) {
          if (event
              case PodcastViewStatsUpdatedEvent(viewStats: final viewStats)) {
            if (viewStats.id == pid) {
              state = AsyncData(viewStats);
            }
          }
        });
      })
      ..listen(audioPlayerEventStreamProvider, (_, next) async {
        next.whenData((event) {
          if (event
              case AudioPlayerActionEvent(
                episode: final episode,
                action: final action,
              )) {
            if (action == AudioPlayerAction.play && episode.pid == pid) {
              _onEpisodeStartsPlaying(episode);
            }
          }
        });
      });
  }

  void setViewMode(PodcastDetailViewMode viewMode) {
    if (state.valueOrNull == null) {
      return;
    }

    _statsRepository.updatePodcastViewStats(
      PodcastViewStatsUpdateParam(
        id: state.requireValue.id,
        viewMode: viewMode,
      ),
    );
  }

  void toggleAscend() {
    if (state.valueOrNull == null) {
      return;
    }

    _statsRepository.updatePodcastViewStats(
      PodcastViewStatsUpdateParam(
        id: state.requireValue.id,
        ascend: !state.requireValue.ascend,
      ),
    );
  }

  void toggleAscendSeasonEpisode() {
    if (state.valueOrNull == null) {
      return;
    }

    _statsRepository.updatePodcastViewStats(
      PodcastViewStatsUpdateParam(
        id: state.requireValue.id,
        ascendSeasonEpisodes: !state.requireValue.ascendSeasonEpisodes,
      ),
    );
  }

  void _onEpisodeStartsPlaying(Episode episode) {
    // final listenedEpisodes =
    //     Map<String, DateTime>.from(state.requireValue.listenedEpisodes);
    // listenedEpisodes[episode.guid] = DateTime.now();
    //
    // _repository.updatePodcastViewStats(
    //   PodcastViewStatsUpdateParam(
    //     id: state.requireValue.id,
    //     listenedEpisodes: listenedEpisodes,
    //   ),
    // );
  }
}
