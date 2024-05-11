import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/podcast_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_subscriptions_provider.g.dart';

@Riverpod(keepAlive: true)
class PodcastSubscriptions extends _$PodcastSubscriptions {
  final _log = Logger('PodcastSubscriptions');

  @override
  Future<List<Podcast>> build() async {
    final subscriptions = await ref.read(repositoryProvider).subscriptions();
    _listen();
    _log.info('${subscriptions.length} subscriptions');
    return subscriptions;
  }

  List<Podcast> _sorted(
    List<Podcast> subscriptions,
  ) {
    return subscriptions.sorted((a, b) => b.id.compareTo(b.id)).toList();
  }

  void _listen() {
    ref.listen(podcastEventStreamProvider, (_, next) {
      final event = next.requireValue;
      switch (event) {
        case PodcastSubscribedEvent(podcast: final podcast):
          final list = [...state.value!, podcast];
          state = AsyncData(_sorted(list));
        case PodcastUnsubscribedEvent(stats: final stats):
          final list = state.value!.where((e) => e.id != stats.id).toList();
          state = AsyncData(list);
        case PodcastUpdatedEvent(podcast: final podcast, stats: final stats):
          final list = state.value!
              .map(
                (e) => e.id == podcast.id ? podcast : e,
              )
              .toList();
          state = AsyncData(list);
        case PodcastStatsUpdatedEvent():
        case PodcastViewStatsUpdatedEvent():
      }
    });
  }
}
