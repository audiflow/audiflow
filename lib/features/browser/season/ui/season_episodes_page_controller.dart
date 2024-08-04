import 'package:audiflow/features/browser/common/data/page_models_repository.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'season_episodes_page_controller.freezed.dart';
part 'season_episodes_page_controller.g.dart';

@riverpod
class SeasonEpisodesPageController extends _$SeasonEpisodesPageController {
  List<Episode> _episodes = [];
  List<Episode> _filteredEpisodes = [];

  @override
  Future<SeasonEpisodesState> build(Season season) async {
    final model = await ref
        .read(pageModelsRepositoryProvider)
        .findPodcastDetailsPageModel(season.pid);
    _episodes = await ref
        .read(episodeRepositoryProvider)
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
    return SeasonEpisodesState(
      episodes: sortedEpisodes,
      filterMode: model.seasonEpisodeFilterMode,
      ascending: model.seasonEpisodesAscending,
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
        final episodeStatsList = await ref
            .read(statsRepositoryProvider)
            .findEpisodeStatsList(episodes.map((e) => e.id));
        return episodes.whereIndexed((i, e) {
          return (episodeStatsList[i]?.completeCount ?? 0) < 0;
        }).toList();
      case EpisodeFilterMode.completed:
        final episodeStatsList = await ref
            .read(statsRepositoryProvider)
            .findEpisodeStatsList(episodes.map((e) => e.id));
        return episodes.whereIndexed((i, e) {
          return 0 < (episodeStatsList[i]?.completeCount ?? 0);
        }).toList();
      case EpisodeFilterMode.downloaded:
        final episodeStatsList = await ref
            .read(downloadRepositoryProvider)
            .findDownloads(episodes.map((e) => e.id));
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
}

@freezed
class SeasonEpisodesState with _$SeasonEpisodesState {
  const factory SeasonEpisodesState({
    required List<Episode> episodes,
    required EpisodeFilterMode filterMode,
    required bool ascending,
  }) = _SeasonEpisodesState;
}
