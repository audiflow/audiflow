import 'package:audiflow/features/feed/model/model.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_stats_repository.g.dart';

enum EpisodeStatsFilterBy {
  played,
  completed,
  incomplete,
  downloaded,
}

enum EpisodeStatsSortBy {
  playedDate,
}

abstract class EpisodeStatsRepository {
  Future<EpisodeStats?> findEpisodeStats(Id id);

  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<Id> ids);

  Future<List<EpisodeStats>> queryEpisodeStatsList({
    required int pid,
    EpisodeStatsFilterBy? filterBy,
    int? lastOrdinal,
    bool ascending = false,
    int? limit,
  });

  Future<List<EpisodeStats>> findEpisodeStatsListBy({
    required int pid,
    EpisodeStatsFilterBy? filterBy,
    required EpisodeStatsSortBy sortBy,
    DateTime? lastPlayedDate,
    bool ascending = false,
    int? offset,
    int? limit,
  });

  Future<int> count({
    required int pid,
    EpisodeStatsFilterBy? filterBy,
  });

  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param);

  Future<List<EpisodeStats>> updateEpisodeStatsList(
    Iterable<EpisodeStatsUpdateParam> params,
  );

  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(Id pid);

  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(Id pid);

  // --- Recently played episodes

  Future<(List<Episode>, int?)> findRecentlyPlayedEpisodeList({
    int? cursor,
    int limit = 100,
  });

  Future<void> saveRecentlyPlayedEpisode(
    Episode episode, {
    DateTime? playedAt,
  });
}

@Riverpod(keepAlive: true)
EpisodeStatsRepository episodeStatsRepository(EpisodeStatsRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
