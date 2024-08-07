import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_stats_repository.g.dart';

abstract class PodcastStatsRepository {
  // -- Subscriptions

  Future<List<Podcast>> subscriptions();

  Future<void> subscribePodcast(Podcast podcast);

  Future<void> unsubscribePodcast(Podcast podcast);

  // -- PodcastStats

  Future<PodcastStats?> findPodcastStats(int pid);

  Future<PodcastStats?> findPodcastStatsBy({required String feedUrl});

  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param);
}

@Riverpod(keepAlive: true)
PodcastStatsRepository podcastStatsRepository(PodcastStatsRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
