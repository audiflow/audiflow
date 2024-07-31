import 'package:audiflow/features/feed/model/model.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_repository.g.dart';

enum EpisodeStatsFilterBy {
  played,
  completed,
  incomplete,
}

enum EpisodeStatsSortBy {
  playedDate,
}

abstract class StatsRepository {
  // -- Subscriptions

  Future<List<Podcast>> subscriptions();

  Future<void> subscribePodcast(Podcast podcast);

  Future<void> unsubscribePodcast(Podcast podcast);

  // -- PodcastStats

  Future<PodcastStats?> findPodcastStats(int pid);

  Future<PodcastStats?> findPodcastStatsBy({required String feedUrl});

  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param);

  // --- EpisodeStats

  Future<EpisodeStats?> findEpisodeStats(Id id);

  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<Id> ids);

  Future<List<EpisodeStats?>> findEpisodeStatsListBy({
    required int pid,
    EpisodeStatsFilterBy? filterBy,
    required EpisodeStatsSortBy sortBy,
    DateTime? lastPlayedDate,
    bool ascending = false,
    int? offset,
    int? limit,
  });

  Future<int> countEpisodeStatsBy({
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
StatsRepository statsRepository(StatsRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
