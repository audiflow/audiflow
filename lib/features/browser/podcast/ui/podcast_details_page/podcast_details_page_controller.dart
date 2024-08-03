import 'package:audiflow/features/browser/common/data/page_models_event.dart';
import 'package:audiflow/features/browser/common/data/page_models_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/common/model/season_filter_mode.dart';
import 'package:audiflow/features/browser/podcast/model/podcast_details_page_model.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_details_page_controller.freezed.dart';
part 'podcast_details_page_controller.g.dart';

@riverpod
class PodcastDetailsPageController extends _$PodcastDetailsPageController {
  PageModelsRepository get _pageModelsRepository =>
      ref.read(pageModelsRepositoryProvider);

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
    state = AsyncData(state.requireValue.copyWith(viewMode: viewMode));
  }

  Future<void> setEpisodeFilter(EpisodeFilterMode model) async {
    if (!state.hasValue) {
      return;
    }

    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: pid,
        episodeFilterMode: model,
      ),
    );
    state = AsyncData(state.requireValue.copyWith(episodeFilterMode: model));
  }

  Future<void> toggleEpisodesAscending() async {
    if (!state.hasValue) {
      return;
    }

    final newValue = !state.requireValue.episodesAscending;
    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: pid,
        episodesAscending: newValue,
      ),
    );
    state = AsyncData(state.requireValue.copyWith(episodesAscending: newValue));
  }

  Future<void> setSeasonFilter(SeasonFilterMode model) async {
    if (!state.hasValue) {
      return;
    }

    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: pid,
        seasonFilterMode: model,
      ),
    );
    state = AsyncData(state.requireValue.copyWith(seasonFilterMode: model));
  }

  Future<void> toggleSeasonsAscending() async {
    if (!state.hasValue) {
      return;
    }

    final newValue = !state.requireValue.seasonsAscending;
    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: pid,
        seasonsAscending: newValue,
      ),
    );
    state = AsyncData(state.requireValue.copyWith(seasonsAscending: newValue));
  }

  Future<void> toggleSeasonEpisodesAscending() async {
    if (!state.hasValue) {
      return;
    }

    final newValue = !state.requireValue.seasonEpisodesAscending;
    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: pid,
        seasonEpisodesAscending: newValue,
      ),
    );
    state = AsyncData(
      state.requireValue.copyWith(seasonEpisodesAscending: newValue),
    );
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
    required bool seasonEpisodesAscending,
  }) = _PodcastDetailsPageState;

  factory PodcastDetailsPageState.fromModel(PodcastDetailsPageModel model) {
    return PodcastDetailsPageState(
      viewMode: model.viewMode,
      episodeFilterMode: model.episodeFilterMode,
      episodesAscending: model.episodesAscending,
      seasonFilterMode: model.seasonFilterMode,
      seasonsAscending: model.seasonsAscending,
      seasonEpisodesAscending: model.seasonEpisodesAscending,
    );
  }
}

extension PodcastDetailsPageStateExt on PodcastDetailsPageState {
  PodcastDetailsPageState copyWithModel(PodcastDetailsPageModel model) {
    return copyWith(
      viewMode: model.viewMode,
      episodeFilterMode: model.episodeFilterMode,
      episodesAscending: model.episodesAscending,
      seasonsAscending: model.seasonsAscending,
      seasonEpisodesAscending: model.seasonEpisodesAscending,
    );
  }
}
