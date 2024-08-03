import 'package:audiflow/features/browser/common/data/page_models_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/common/model/season_filter_mode.dart';
import 'package:audiflow/features/browser/podcast/model/podcast_details_page_model.dart';
import 'package:isar/isar.dart';

class IsarPageModelsRepository implements PageModelsRepository {
  IsarPageModelsRepository(this.isar);

  final Isar isar;

  // -- PodcastDetailsPageModel

  @override
  Future<PodcastDetailsPageModel?> findPodcastDetailsPageModel(int pid) async {
    return isar.podcastDetailsPageModels.get(pid);
  }

  @override
  Future<PodcastDetailsPageModel> updatePodcastDetailsPageModel(
    PodcastDetailsPageModelUpdateParam param,
  ) async {
    final stats = await isar.podcastDetailsPageModels.get(param.id);
    final newStats = stats != null
        ? stats.copyWith(
            viewMode: param.viewMode ?? stats.viewMode,
            episodeFilterMode:
                param.episodeFilterMode ?? stats.episodeFilterMode,
            episodesAscending:
                param.episodesAscending ?? stats.episodesAscending,
            seasonFilterMode: param.seasonFilterMode ?? stats.seasonFilterMode,
            seasonsAscending: param.seasonsAscending ?? stats.seasonsAscending,
            seasonEpisodesAscending:
                param.seasonEpisodesAscending ?? stats.seasonEpisodesAscending,
          )
        : PodcastDetailsPageModel(
            pid: param.id,
            viewMode: param.viewMode ?? PodcastDetailsPageViewMode.episodes,
            episodeFilterMode: param.episodeFilterMode ?? EpisodeFilterMode.all,
            episodesAscending: param.episodesAscending ?? false,
            seasonFilterMode: param.seasonFilterMode ?? SeasonFilterMode.all,
            seasonsAscending: param.seasonsAscending ?? false,
            seasonEpisodesAscending: param.seasonEpisodesAscending ?? true,
          );
    await isar.writeTxn(() => isar.podcastDetailsPageModels.put(newStats));
    return newStats;
  }
}
