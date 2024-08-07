import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_stats_provider.g.dart';

@riverpod
Future<EpisodeStats?> episodeStats(
  EpisodeStatsRef ref, {
  required int eid,
}) async {
  ref.listen(episodeEventStreamProvider, (_, next) {
    final event = next.valueOrNull;
    switch (event) {
      case EpisodeStatsUpdatedEvent(stats: final stats):
        if (stats.eid == eid) {
          ref.state = AsyncData(stats);
        }
      case EpisodeUpdatedEvent() ||
            EpisodesAddedEvent() ||
            EpisodeDeletedEvent() ||
            null:
        break;
    }
  });
  return ref.read(statsRepositoryProvider).findEpisodeStats(eid);
}
