import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:collection/collection.dart';
import 'package:isar/isar.dart';

class IsarEpisodeStatsRepository implements EpisodeStatsRepository {
  IsarEpisodeStatsRepository(this.isar);

  final Isar isar;

  // --- EpisodeStats

  @override
  Future<List<EpisodeStats>> queryCompletedEpisodeStatsList({
    required int pid,
    int? lastOrdinal,
    bool ascending = false,
    int? limit,
  }) async {
    return isar.episodeStats
        .where()
        .optional(
          true,
          (q) => lastOrdinal == null
              ? q.pidEqualToAnyOrdinal(pid)
              : ascending
                  ? q.pidEqualToOrdinalGreaterThan(pid, lastOrdinal)
                  : q.pidEqualToOrdinalLessThan(pid, lastOrdinal),
        )
        .filter()
        .completeCountGreaterThan(0)
        .optional(
          true,
          (q) => ascending ? q.sortByOrdinal() : q.sortByOrdinalDesc(),
        )
        .optional(limit != null, (q) => q.limit(limit!))
        .findAll();
  }

  @override
  Future<List<EpisodeStats?>> findEpisodeStatsListBy({
    required int pid,
    EpisodeStatsFilterBy? filterBy,
    required EpisodeStatsSortBy sortBy,
    DateTime? lastPlayedDate,
    bool ascending = false,
    int? offset,
    int? limit,
  }) async {
    return isar.episodeStats
        .where()
        .filter()
        .pidEqualTo(pid)
        .optional(
          lastPlayedDate != null,
          (q) => ascending
              ? q.lastPlayedAtGreaterThan(lastPlayedDate)
              : q.lastPlayedAtLessThan(lastPlayedDate),
        )
        .optional(filterBy != null, (q) {
          switch (filterBy!) {
            case EpisodeStatsFilterBy.played:
              return q.playedEqualTo(true);
            case EpisodeStatsFilterBy.completed:
              return q.completeCountGreaterThan(0);
            case EpisodeStatsFilterBy.incomplete:
              return q.completeCountEqualTo(0);
          }
        })
        .optional(true, (q) {
          switch (sortBy) {
            case EpisodeStatsSortBy.playedDate:
              return ascending
                  ? q.sortByLastPlayedAt()
                  : q.sortByLastPlayedAtDesc();
          }
        })
        .optional(offset != null, (q) => q.offset(offset!))
        .optional(limit != null, (q) => q.limit(limit!))
        .findAll();
  }

  @override
  Future<int> countEpisodeStatsBy({
    required int pid,
    EpisodeStatsFilterBy? filterBy,
  }) async {
    return isar.episodeStats
        .where()
        .filter()
        .pidEqualTo(pid)
        .optional(filterBy != null, (q) {
      switch (filterBy!) {
        case EpisodeStatsFilterBy.played:
          return q.playedEqualTo(true);
        case EpisodeStatsFilterBy.completed:
          return q.completeCountGreaterThan(0);
        case EpisodeStatsFilterBy.incomplete:
          return q.completeCountEqualTo(0);
      }
    }).count();
  }

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
    final stats = await isar.episodeStats.get(param.eid);
    final newStats = EpisodeStats(
      eid: param.eid,
      pid: param.pid,
      ordinal: param.ordinal,
      positionMS: param.position?.inMilliseconds ?? stats?.positionMS ?? 0,
      playCount: (stats?.playCount ?? 0) + (param.played == true ? 1 : 0),
      playTotalMS: (stats?.playTotalMS ?? 0) +
          (param.playTotalDelta?.inMilliseconds ?? 0),
      played: param.played ?? stats?.played ?? false,
      completeCount:
          (stats?.completeCount ?? 0) + (param.completed == true ? 1 : 0),
      lastPlayedAt: param.lastPlayedAt ?? stats?.lastPlayedAt,
      downloaded: param.downloaded ?? stats?.downloaded ?? false,
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
  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(Id pid) async {
    return isar.episodeStats.where().filter().playedEqualTo(true).findAll();
  }

  @override
  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(Id pid) async {
    return isar.episodeStats.where().filter().playedEqualTo(false).findAll();
  }

  // --- Recently played episodes

  @override
  Future<(List<Episode>, int?)> findRecentlyPlayedEpisodeList({
    int? cursor,
    int limit = 100,
  }) async {
    final ids = await isar.episodeStats
        .where(sort: Sort.desc)
        .sortByLastPlayedAtDesc()
        .offset(cursor ?? 0)
        .limit(limit)
        .idProperty()
        .findAll();
    final nextCursor = ids.length < limit ? null : (cursor ?? 0) + limit;
    final episodes = await isar.episodes
        .getAll(ids)
        .then((value) => value.whereNotNull().toList());
    return (episodes, nextCursor);
  }

  @override
  Future<void> saveRecentlyPlayedEpisode(
    Episode episode, {
    DateTime? playedAt,
  }) async {
    await updateEpisodeStats(
      EpisodeStatsUpdateParam(
        eid: episode.id,
        pid: episode.pid,
        ordinal: episode.ordinal,
        lastPlayedAt: playedAt ?? DateTime.now(),
      ),
    );
  }
}
