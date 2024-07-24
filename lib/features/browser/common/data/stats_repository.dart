import 'package:audiflow/features/feed/model/model.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_repository.g.dart';

abstract class StatsRepository {
  // -- Subscriptions

  Future<List<Podcast>> subscriptions();

  Future<void> subscribePodcast(Podcast podcast);

  Future<void> unsubscribePodcast(Podcast podcast);

  // -- PodcastStats

  Future<PodcastStats?> findPodcastStats(int pid);

  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param);

  // -- PodcastViewStats

  Future<PodcastViewStats?> findPodcastViewStats(int pid);

  Future<PodcastViewStats> updatePodcastViewStats(
    PodcastViewStatsUpdateParam param,
  );

  // --- EpisodeStats

  Future<EpisodeStats?> findEpisodeStats(Id id);

  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<Id> ids);

  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param);

  Future<List<EpisodeStats>> updateEpisodeStatsList(
    Iterable<EpisodeStatsUpdateParam> params,
  );

  Future<List<EpisodeStats>> findDownloadedEpisodeStatsList(Id pid);

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
