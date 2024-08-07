import 'package:audiflow/features/browser/common/data/podcast_stats_repository/podcast_stats_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:collection/collection.dart';
import 'package:isar/isar.dart';

class IsarPodcastStatsRepository implements PodcastStatsRepository {
  IsarPodcastStatsRepository(this.isar);

  final Isar isar;

  // -- Subscriptions

  @override
  Future<List<Podcast>> subscriptions() async {
    final statsList = await isar.podcastStats
        .where()
        .filter()
        .subscribedDateIsNotNull()
        .findAll();
    return isar.podcasts
        .getAll(statsList.map((e) => e.id).toList())
        .then((value) => value.whereNotNull().toList());
  }

  @override
  Future<void> subscribePodcast(Podcast podcast) async {
    await updatePodcastStats(
      PodcastStatsUpdateParam(
        id: podcast.id,
        subscribed: true,
      ),
    );
  }

  @override
  Future<void> unsubscribePodcast(Podcast podcast) async {
    await updatePodcastStats(
      PodcastStatsUpdateParam(
        id: podcast.id,
        subscribed: false,
      ),
    );
  }

  // -- PodcastStats

  @override
  Future<PodcastStats?> findPodcastStats(int pid) async {
    return isar.podcastStats.get(pid);
  }

  @override
  Future<PodcastStats?> findPodcastStatsBy({required String feedUrl}) async {
    return isar.podcastStats.get(Podcast.pidFrom(feedUrl));
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
      lastCheckedAt:
          param.lastCheckedAt ?? stats?.lastCheckedAt ?? DateTime.now(),
      latestPubDate: param.latestPubDate ?? stats?.latestPubDate,
      hasLoadedAll: param.hasLoadedAll ?? stats?.hasLoadedAll ?? false,
      totalEpisodes:
          (param.deltaTotalEpisodes ?? 0) + (stats?.totalEpisodes ?? 0),
      totalPlayed: (param.deltaTotalPlayed ?? 0) + (stats?.totalPlayed ?? 0),
    );
    await isar.podcastStats.put(newStats);
    return newStats;
  }
}
