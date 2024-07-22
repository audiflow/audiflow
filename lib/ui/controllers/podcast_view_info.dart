import 'dart:async';

import 'package:audiflow/core/logger.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/audio/audio_player_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_view_info.g.dart';

@riverpod
class PodcastViewInfo extends _$PodcastViewInfo {
  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<PodcastViewStats> build(int pid) async {
    logger.d(() => 'build pid=$pid');
    final viewStats = await _repository.findPodcastViewStats(pid);
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

    _repository.updatePodcastViewStats(
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

    _repository.updatePodcastViewStats(
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

    _repository.updatePodcastViewStats(
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
