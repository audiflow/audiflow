import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/page_models_event.dart';
import 'package:audiflow/features/browser/common/data/page_models_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/podcast/model/podcast_details_page_model.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/download/service/download_service.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/queue/service/audio_queue_service.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'season_episodes_page_controller.freezed.dart';
part 'season_episodes_page_controller.g.dart';

@riverpod
class SeasonEpisodesPageController extends _$SeasonEpisodesPageController {
  List<Episode> _episodes = [];
  List<Episode> _filteredEpisodes = [];

  PageModelsRepository get _pageModelsRepository =>
      ref.read(pageModelsRepositoryProvider);

  EpisodeRepository get _episodeRepository =>
      ref.read(episodeRepositoryProvider);

  EpisodeStatsRepository get _episodeStatsRepository =>
      ref.read(episodeStatsRepositoryProvider);

  DownloadRepository get _downloadRepository =>
      ref.read(downloadRepositoryProvider);

  DownloadService get _downloadService => ref.read(downloadServiceProvider);

  AudioPlayerState? get _audioPlayerState =>
      ref.read(audioPlayerServiceProvider);

  AudioPlayerService get _audioPlayerService =>
      ref.read(audioPlayerServiceProvider.notifier);

  AudioQueueService get _audioQueueService =>
      ref.read(audioQueueServiceProvider);

  @override
  Future<SeasonEpisodesState> build(Season season) async {
    final model =
        await _pageModelsRepository.findPodcastDetailsPageModel(season.pid);
    _episodes = await _episodeRepository
        .findEpisodes(season.episodeIds)
        .then((episodes) => episodes.whereNotNull().toList());
    _filteredEpisodes = await _filterEpisodes(
      _episodes,
      filterMode: model!.seasonEpisodeFilterMode,
    );
    final sortedEpisodes = _sortEpisodes(
      _filteredEpisodes,
      ascending: model.seasonEpisodesAscending,
    );

    _listen();
    return SeasonEpisodesState(
      episodes: sortedEpisodes,
      filterMode: model.seasonEpisodeFilterMode,
      ascending: model.seasonEpisodesAscending,
    );
  }

  void _listen() {
    ref.listen(pageModelsEventStreamProvider, (_, next) {
      if (!state.hasValue) {
        return;
      }

      next.whenData((event) {
        if (event
            case PodcastDetailsPageModelUpdatedEvent(model: final model)) {
          if (model.pid == season.pid) {
            _onPodcastDetailsPageModelChanged(model);
          }
        }
      });
    });
  }

  Future<void> _onPodcastDetailsPageModelChanged(
    PodcastDetailsPageModel model,
  ) async {
    final current = state.requireValue;
    if (model.seasonEpisodeFilterMode == current.filterMode &&
        model.seasonEpisodesAscending == current.ascending) {
      return;
    }

    if (model.seasonEpisodeFilterMode != current.filterMode) {
      _filteredEpisodes = await _filterEpisodes(
        _episodes,
        filterMode: model.seasonEpisodeFilterMode,
      );
    }

    final episodes = _sortEpisodes(
      _filteredEpisodes,
      ascending: model.seasonEpisodesAscending,
    );
    state = AsyncData(
      SeasonEpisodesState(
        episodes: episodes,
        filterMode: model.seasonEpisodeFilterMode,
        ascending: model.seasonEpisodesAscending,
      ),
    );
  }

  Future<List<Episode>> _filterEpisodes(
    List<Episode> episodes, {
    required EpisodeFilterMode filterMode,
  }) async {
    switch (filterMode) {
      case EpisodeFilterMode.all:
        return episodes;
      case EpisodeFilterMode.unplayed:
        final episodeStatsList = await _episodeStatsRepository
            .findEpisodeStatsList(episodes.map((e) => e.id));
        return episodes.whereIndexed((i, e) {
          return (episodeStatsList[i]?.completeCount ?? 0) < 1;
        }).toList();
      case EpisodeFilterMode.completed:
        final episodeStatsList = await _episodeStatsRepository
            .findEpisodeStatsList(episodes.map((e) => e.id));
        return episodes.whereIndexed((i, e) {
          return 0 < (episodeStatsList[i]?.completeCount ?? 0);
        }).toList();
      case EpisodeFilterMode.downloaded:
        final episodeStatsList =
            await _downloadRepository.findDownloads(episodes.map((e) => e.id));
        return episodes.whereIndexed((i, e) {
          return episodeStatsList[i]?.downloaded ?? false;
        }).toList();
    }
  }

  List<Episode> _sortEpisodes(
    List<Episode> episodes, {
    required bool ascending,
  }) {
    return ascending
        ? episodes.sorted((a, b) => a.compareTo(b))
        : episodes.sorted((a, b) => b.compareTo(a));
  }

  Future<void> setFilterMode(EpisodeFilterMode mode) async {
    if (!state.hasValue) {
      return;
    }

    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: season.pid,
        seasonEpisodeFilterMode: mode,
      ),
    );
  }

  Future<void> toggleAscending() async {
    if (!state.hasValue) {
      return;
    }

    await _pageModelsRepository.updatePodcastDetailsPageModel(
      PodcastDetailsPageModelUpdateParam(
        pid: season.pid,
        seasonEpisodesAscending: !state.requireValue.ascending,
      ),
    );
  }

  Future<void> togglePlayState(Episode episode) async {
    if (_audioPlayerState?.episode.id == episode.id) {
      return _audioPlayerService.togglePlayPause();
    } else {
      final episodes =
          _sortEpisodes(state.requireValue.episodes, ascending: true);
      final i = episodes.indexOf(episode);
      if (i < 0) {
        return;
      }
      await _audioQueueService.buildAndPlay(
        pid: episode.pid,
        eid: episode.id,
        queueingEpisodeIds: episodes.slice(i + 1).map((e) => e.id),
      );
    }
  }

  Future<void> downloadAllEpisodes() async {
    final episodes = state.requireValue.episodes;
    await _downloadService.downloadEpisodes(episodes);
  }

  Future<void> downloadUnplayedEpisodes() async {
    final episodes = state.requireValue.episodes;
    await _downloadService.downloadEpisodes(episodes, unplayedOnly: true);
  }
}

@freezed
class SeasonEpisodesState with _$SeasonEpisodesState {
  const factory SeasonEpisodesState({
    required List<Episode> episodes,
    required EpisodeFilterMode filterMode,
    required bool ascending,
  }) = _SeasonEpisodesState;
}
