import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_provider.g.dart';

@riverpod
Future<Episode?> episode(
  EpisodeRef ref, {
  required int eid,
}) async {
  ref.listen(episodeEventStreamProvider, (_, next) {
    switch (next.valueOrNull) {
      case EpisodeUpdatedEvent(episode: final episode):
        if (episode.id == eid) {
          ref.state = AsyncData(episode);
        }
      case EpisodesUpdatedEvent(episodes: final episodes):
        final episode = episodes.firstWhereOrNull((e) => e.id == eid);
        if (episode != null) {
          ref.state = AsyncData(episode);
        }
      case EpisodesAddedEvent(episodes: final episodes):
        if (episodes.any((e) => e.id == eid)) {
          ref.read(episodeRepositoryProvider).findEpisode(eid).then((episode) {
            if (episode != null) {
              ref.state = AsyncData(episode);
            }
          });
        }
      case EpisodeDeletedEvent() ||
            EpisodeStatsUpdatedEvent() ||
            EpisodeStatsListUpdatedEvent() ||
            null:
        break;
    }
  });

  return ref.read(episodeRepositoryProvider).findEpisode(eid);
}
