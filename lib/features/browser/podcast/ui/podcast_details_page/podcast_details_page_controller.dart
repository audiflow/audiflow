import 'package:audiflow/features/browser/common/data/page_models_event.dart';
import 'package:audiflow/features/browser/common/data/page_models_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/common/model/season_filter_mode.dart';
import 'package:audiflow/features/browser/podcast/model/podcast_details_page_model.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/queue/service/audio_queue_service.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_details_page_controller.freezed.dart';
part 'podcast_details_page_controller.g.dart';

@riverpod
class PodcastDetailsPageController extends _$PodcastDetailsPageController {
  PageModelsRepository get _pageModelsRepository =>
      ref.read(pageModelsRepositoryProvider);

  AudioPlayerState? get _audioPlayerState =>
      ref.read(audioPlayerServiceProvider);

  AudioPlayerService get _audioPlayerService =>
      ref.read(audioPlayerServiceProvider.notifier);

  AudioQueueService get _audioQueueService =>
      ref.read(audioQueueServiceProvider);

  @override
  Future<PodcastDetailsPageState> build(int pid) async {
    logger.d(() => 'build pid=$pid');
    _listen();
    final model =
        await _pageModelsRepository.findPodcastDetailsPageModel(pid) ??
            PodcastDetailsPageModel(pid: pid);
    return PodcastDetailsPageState.fromModel(model);
  }

  void _listen() {
    ref.listen(pageModelsEventStreamProvider, (_, next) {
      if (!state.hasValue) {
        return;
      }

      next.whenData((event) {
        if (event
            case PodcastDetailsPageModelUpdatedEvent(model: final model)) {
          if (model.pid == pid) {
            state = AsyncData(state.requireValue.copyWithModel(model));
          }
        }
      });
    });
  }

  Future<void> setViewMode(PodcastDetailsPageViewMode viewMode) async {
    if (!state.hasValue) {
      return;
    }

    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: pid,
        viewMode: viewMode,
      ),
    );
  }

  Future<void> setEpisodeFilter(EpisodeFilterMode mode) async {
    if (!state.hasValue) {
      return;
    }

    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: pid,
        episodeFilterMode: mode,
      ),
    );
  }

  Future<void> toggleEpisodesAscending() async {
    if (!state.hasValue) {
      return;
    }

    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: pid,
        episodesAscending: !state.requireValue.episodesAscending,
      ),
    );
  }

  Future<void> setSeasonFilter(SeasonFilterMode mode) async {
    if (!state.hasValue) {
      return;
    }

    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: pid,
        seasonFilterMode: mode,
      ),
    );
  }

  Future<void> toggleSeasonsAscending() async {
    if (!state.hasValue) {
      return;
    }

    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: pid,
        seasonsAscending: !state.requireValue.seasonsAscending,
      ),
    );
  }

  Future<void> togglePlayState(Episode episode) async {
    if (_audioPlayerState?.episode.id == episode.id) {
      await _audioPlayerService.togglePlayPause();
    } else {
      await _audioQueueService.playFromPodcastDetailsPage(
        start: episode,
        filterMode: state.requireValue.episodeFilterMode,
      );
    }
  }
}

@freezed
class PodcastDetailsPageState with _$PodcastDetailsPageState {
  const factory PodcastDetailsPageState({
    required PodcastDetailsPageViewMode viewMode,
    required EpisodeFilterMode episodeFilterMode,
    required bool episodesAscending,
    required SeasonFilterMode seasonFilterMode,
    required bool seasonsAscending,
  }) = _PodcastDetailsPageState;

  factory PodcastDetailsPageState.fromModel(PodcastDetailsPageModel model) {
    return PodcastDetailsPageState(
      viewMode: model.viewMode,
      episodeFilterMode: model.episodeFilterMode,
      episodesAscending: model.episodesAscending,
      seasonFilterMode: model.seasonFilterMode,
      seasonsAscending: model.seasonsAscending,
    );
  }
}

extension PodcastDetailsPageStateExt on PodcastDetailsPageState {
  PodcastDetailsPageState copyWithModel(PodcastDetailsPageModel model) {
    return copyWith(
      viewMode: model.viewMode,
      episodeFilterMode: model.episodeFilterMode,
      episodesAscending: model.episodesAscending,
      seasonFilterMode: model.seasonFilterMode,
      seasonsAscending: model.seasonsAscending,
    );
  }
}
