import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:isar/isar.dart';

class IsarStatsRepository implements StatsRepository {
  IsarStatsRepository(this.isar);

  final Isar isar;

  // -- PodcastStats

  @override
  Future<PodcastStats?> findPodcastStats(int pid) async {
    return isar.podcastStats.get(pid);
  }

  @override
  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param) async {
    return isar.writeTxn(() => _updatePodcastStats(param));
  }

  Future<PodcastStats> _updatePodcastStats(
    PodcastStatsUpdateParam param,
  ) async {
    final stats = await isar.podcastStats.get(param.id);
    final newStats = PodcastStats(
      id: param.id,
      subscribedDate: param.subscribed == null
          ? stats?.subscribedDate
          : param.subscribed!
              ? DateTime.now()
              : null,
      lastCheckedAt: param.lastCheckedAt ?? stats?.lastCheckedAt,
    );
    await isar.podcastStats.put(newStats);
    return newStats;
  }

  // -- PodcastViewStats

  @override
  Future<PodcastViewStats?> findPodcastViewStats(int pid) async {
    return isar.podcastViewStats.get(pid);
  }

  @override
  Future<PodcastViewStats> updatePodcastViewStats(
    PodcastViewStatsUpdateParam param,
  ) async {
    final stats = await isar.podcastViewStats.get(param.id);
    final newStats = stats != null
        ? stats.copyWith(
            viewMode: param.viewMode ?? stats.viewMode,
            ascend: param.ascend ?? stats.ascend,
            ascendSeasonEpisodes:
                param.ascendSeasonEpisodes ?? stats.ascendSeasonEpisodes,
          )
        : PodcastViewStats(
            id: param.id,
            viewMode: param.viewMode ?? PodcastDetailViewMode.seasons,
            ascend: param.ascend ?? false,
            ascendSeasonEpisodes: param.ascendSeasonEpisodes ?? true,
          );
    await isar.writeTxn(() => isar.podcastViewStats.put(newStats));
    return newStats;
  }

  // --- EpisodeStats

  @override
  Future<EpisodeStats?> findEpisodeStats(Id id) async {
    return isar.episodeStats.get(id);
  }

  @override
  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<Id> ids) async {
    return isar.episodeStats.getAll(ids.toList());
  }

  @override
  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param) async {
    return isar.writeTxn(() => _updateEpisodeStats(param));
  }

  Future<EpisodeStats> _updateEpisodeStats(
    EpisodeStatsUpdateParam param,
  ) async {
    final stats = await isar.episodeStats.get(param.id);
    final newStats = EpisodeStats(
      id: param.id,
      pid: param.pid,
      positionMS: param.position?.inMilliseconds ?? stats?.positionMS ?? 0,
      playCount: (stats?.playCount ?? 0) + (param.played == true ? 1 : 0),
      playTotalMS: (stats?.playTotalMS ?? 0) +
          (param.playTotalDelta?.inMilliseconds ?? 0),
      played: (stats?.played ?? false) || (param.played ?? false),
      completeCount:
          (stats?.completeCount ?? 0) + (param.completed == true ? 1 : 0),
      inQueue: (stats?.inQueue ?? false) || (param.inQueue ?? false),
      downloadedTime: param.downloaded == null
          ? stats?.downloadedTime
          : param.downloaded!
              ? DateTime.now()
              : null,
      lastPlayedAt: param.lastPlayedAt ?? stats?.lastPlayedAt,
    );
    await isar.episodeStats.put(newStats);
    return newStats;
  }

  @override
  Future<List<EpisodeStats>> updateEpisodeStatsList(
    Iterable<EpisodeStatsUpdateParam> params,
  ) async {
    return isar.writeTxn(() => Future.wait(params.map(_updateEpisodeStats)));
  }

  @override
  Future<List<EpisodeStats>> findDownloadedEpisodeStatsList(Id pid) async {
    return isar.episodeStats
        .where()
        .filter()
        .pidEqualTo(pid)
        .downloadedTimeIsNotNull()
        .findAll();
  }

  @override
  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(Id pid) async {
    return isar.episodeStats
        .where()
        .filter()
        .playedEqualTo(true)
        .downloadedTimeIsNotNull()
        .findAll();
  }

  @override
  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(Id pid) async {
    return isar.episodeStats
        .where()
        .filter()
        .playedEqualTo(false)
        .downloadedTimeIsNotNull()
        .findAll();
  }
}
