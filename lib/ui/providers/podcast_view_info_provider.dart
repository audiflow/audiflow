import 'dart:async';

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/podcast_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/audio/audio_player_event.dart';
import 'package:audiflow/ui/providers/podcast_info_provider.dart';
import 'package:audiflow/ui/providers/podcast_seasons_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_view_info_provider.freezed.dart';
part 'podcast_view_info_provider.g.dart';

@riverpod
class PodcastViewInfo extends _$PodcastViewInfo {
  final _log = Logger('PodcastViewInfo');

  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<PodcastViewStats> build(int id) async {
    _log.fine('build $id');

    final viewStats = await _repository.findPodcastViewStats(id);

    _listen();
    if (viewStats != null) {
      return viewStats;
    }

    // If the viewStats is not found, determine the default viewMode by the
    // existence of seasons.
    return _determineDefaultViewMode(id);
  }

  Future<PodcastViewStats> _determineDefaultViewMode(int id) async {
    final podcastState = ref.watch(podcastInfoProvider(guid));
    final podcast = podcastState.valueOrNull?.podcast;

    final completer = Completer<PodcastViewStats>();
    if (podcast == null) {
      ref.onDispose(() {
        completer.complete(PodcastViewStats(id: id));
      });
      return completer.future;
    }

    final seasonState = ref.watch(podcastSeasonsProvider(podcast));
    if (seasonState.valueOrNull == null) {
      ref.onDispose(() {
        completer.complete(PodcastViewStats(id: id));
      });
      return completer.future;
    }

    final viewMode = seasonState.valueOrNull!.isNotEmpty
        ? PodcastDetailViewMode.seasons
        : PodcastDetailViewMode.episodes;
    await _repository.updatePodcastViewStats(
      PodcastViewStatsUpdateParam(id: id, viewMode: viewMode),
    );
    return PodcastViewStats(id: id, viewMode: viewMode);
  }

  void _listen() {
    ref
      ..listen(podcastEventStreamProvider, (_, next) {
        final event = next.valueOrNull;
        if (event
            case PodcastViewStatsUpdatedEvent(viewStats: final viewStats)) {
          state = AsyncData(viewStats);
        }
      })
      ..listen(audioPlayerEventStreamProvider, (_, next) async {
        next.whenData((event) {
          if (event
              case AudioPlayerActionEvent(
                episode: final episode,
                action: final action,
              )) {
            if (action == AudioPlayerAction.play &&
                episode.id == state.requireValue.id) {
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
    final listenedEpisodes =
        Map<String, DateTime>.from(state.requireValue.listenedEpisodes);
    listenedEpisodes[episode.guid] = DateTime.now();

    _repository.updatePodcastViewStats(
      PodcastViewStatsUpdateParam(
        id: state.requireValue.id,
        listenedEpisodes: listenedEpisodes,
      ),
    );
  }
}

@freezed
class PodcastViewInfoState with _$PodcastViewInfoState {
  const factory PodcastViewInfoState({
    required PodcastViewStats viewStats,
  }) = _PodcastViewInfoState;
}
