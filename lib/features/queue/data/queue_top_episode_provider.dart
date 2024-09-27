import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/model/episode.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:audiflow/features/queue/service/queue_controller.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_top_episode_provider.g.dart';

@riverpod
class QueueTopEpisode extends _$QueueTopEpisode {
  @override
  Episode? build() {
    _listen();
    return null;
  }

  void _listen() {
    ref
      ..listen(
        queueControllerProvider.select((data) => data.queue.firstOrNull),
        (_, item) => _onQueueChange(item),
        fireImmediately: true,
      )
      ..listen(episodeEventStreamProvider, (_, next) {
        switch (next.requireValue) {
          case EpisodeUpdatedEvent(episode: final episode):
            if (state?.id == episode.id) {
              state = episode;
            }
          case EpisodesUpdatedEvent(episodes: final episodes):
            final episode = episodes.firstWhereOrNull((e) => e.id == state?.id);
            if (episode != null) {
              state = episode;
            }
          case EpisodesAddedEvent() ||
                EpisodeDeletedEvent() ||
                EpisodesDeletedEvent() ||
                EpisodeStatsUpdatedEvent() ||
                EpisodeStatsListUpdatedEvent():
            break;
        }
      });
  }

  Future<void> _onQueueChange(QueueItem? item) async {
    state = item == null
        ? await Future<Episode?>.delayed(Duration.zero, () => null)
        : await ref.read(episodeRepositoryProvider).findEpisode(item.eid);
  }
}
