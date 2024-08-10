import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

class EpisodeStatsRepositoryChangeHandler implements EpisodeStatsRepository {
  EpisodeStatsRepositoryChangeHandler(this._ref, this._inner);

  final Ref _ref;
  final EpisodeStatsRepository _inner;

  // --- EpisodeStats

  @override
  Future<List<EpisodeStats>> queryCompletedEpisodeStatsList({
    required int pid,
    int? lastOrdinal,
    bool ascending = false,
    int? limit,
  }) =>
      _inner.queryCompletedEpisodeStatsList(
        pid: pid,
        lastOrdinal: lastOrdinal,
        ascending: ascending,
        limit: limit,
      );

  @override
  Future<List<EpisodeStats?>> findEpisodeStatsListBy({
    required int pid,
    EpisodeStatsFilterBy? filterBy,
    required EpisodeStatsSortBy sortBy,
    DateTime? lastPlayedDate,
    bool ascending = false,
    int? offset,
    int? limit,
  }) =>
      _inner.findEpisodeStatsListBy(
        pid: pid,
        filterBy: filterBy,
        sortBy: sortBy,
        lastPlayedDate: lastPlayedDate,
        ascending: ascending,
        offset: offset,
        limit: limit,
      );

  @override
  Future<int> countEpisodeStatsBy({
    required int pid,
    EpisodeStatsFilterBy? filterBy,
  }) =>
      _inner.countEpisodeStatsBy(
        pid: pid,
        filterBy: filterBy,
      );

  @override
  Future<EpisodeStats?> findEpisodeStats(Id id) => _inner.findEpisodeStats(id);

  @override
  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<Id> ids) =>
      _inner.findEpisodeStatsList(ids);

  @override
  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param) async {
    final stats = await _inner.updateEpisodeStats(param);
    _ref
        .read(episodeEventStreamProvider.notifier)
        .add(EpisodeStatsUpdatedEvent(stats));
    return stats;
  }

  @override
  Future<List<EpisodeStats>> updateEpisodeStatsList(
    Iterable<EpisodeStatsUpdateParam> params,
  ) async {
    final statsList = await _inner.updateEpisodeStatsList(params);
    _ref
        .read(episodeEventStreamProvider.notifier)
        .add(EpisodeStatsListUpdatedEvent(statsList));
    return statsList;
  }

  @override
  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(Id pid) =>
      _inner.findPlayedEpisodeStatsList(pid);

  @override
  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(Id pid) =>
      _inner.findUnplayedEpisodeStatsList(pid);

  // --- Recently played episodes

  @override
  Future<(List<Episode>, int?)> findRecentlyPlayedEpisodeList({
    int? cursor,
    int limit = 100,
  }) =>
      _inner.findRecentlyPlayedEpisodeList(cursor: cursor, limit: limit);

  @override
  Future<void> saveRecentlyPlayedEpisode(
    Episode episode, {
    DateTime? playedAt,
  }) =>
      _inner.saveRecentlyPlayedEpisode(episode, playedAt: playedAt);
}
