import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_stats_provider.g.dart';

@riverpod
Future<PodcastStats?> podcastStats(PodcastStatsRef ref, int pid) {
  ref.listen(podcastEventStreamProvider, (_, next) {
    next.whenData((event) {
      switch (event) {
        case PodcastSubscribedEvent(stats: final stats) ||
              PodcastUnsubscribedEvent(stats: final stats) ||
              PodcastStatsUpdatedEvent(stats: final stats):
          if (stats.id == pid) {
            ref.state = AsyncData(stats);
          }
        case PodcastUpdatedEvent(stats: final stats):
          if (stats?.id == pid) {
            ref.state = AsyncData(stats);
          }
      }
    });
  });

  return ref.read(statsRepositoryProvider).findPodcastStats(pid);
}
