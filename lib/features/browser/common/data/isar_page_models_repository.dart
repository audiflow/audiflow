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
    final newStats = PodcastDetailsPageModel(
      pid: param.id,
      viewMode: param.viewMode ??
          stats?.viewMode ??
          PodcastDetailsPageViewMode.episodes,
      episodeFilterMode: param.episodeFilterMode ??
          stats?.episodeFilterMode ??
          EpisodeFilterMode.all,
      episodesAscending:
          param.episodesAscending ?? stats?.episodesAscending ?? false,
      seasonFilterMode: param.seasonFilterMode ??
          stats?.seasonFilterMode ??
          SeasonFilterMode.all,
      seasonsAscending:
          param.seasonsAscending ?? stats?.seasonsAscending ?? false,
      seasonEpisodeFilterMode: param.seasonEpisodeFilterMode ??
          stats?.seasonEpisodeFilterMode ??
          EpisodeFilterMode.all,
      seasonEpisodesAscending: param.seasonEpisodesAscending ??
          stats?.seasonEpisodesAscending ??
          true,
    );
    await isar.writeTxn(() => isar.podcastDetailsPageModels.put(newStats));
    return newStats;
  }
}
