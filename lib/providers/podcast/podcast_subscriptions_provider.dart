import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/podcast_event.dart';
import 'package:seasoning/repository/repository_provider.dart';

part 'podcast_subscriptions_provider.g.dart';

@Riverpod(keepAlive: true)
class PodcastSubscriptions extends _$PodcastSubscriptions {
  @override
  Future<List<(PodcastMetadata, PodcastStats)>> build() async {
    final subscriptions = await ref.read(repositoryProvider).subscriptions();
    _listen();
    return subscriptions;
  }

  List<(PodcastMetadata, PodcastStats)> _sorted(
    List<(PodcastMetadata, PodcastStats)> subscriptions,
  ) {
    return subscriptions
        .sorted(
          (a, b) =>
              b.$1.releaseDate.millisecondsSinceEpoch -
              a.$1.releaseDate.millisecondsSinceEpoch,
        )
        .toList();
  }

  void _listen() {
    ref.listen(podcastEventStreamProvider, (_, next) {
      final event = next.valueOrNull;
      switch (event) {
        case PodcastSubscribedEvent(podcast: final podcast, stats: final stats):
          final list = [...state.value!, (podcast, stats)];
          state = AsyncData(_sorted(list));
        case PodcastUnsubscribedEvent(stats: final stats):
          final list =
              state.value!.where((e) => e.$2.guid != stats.guid).toList();
          state = AsyncData(list);
        case PodcastUpdatedEvent():
        // final list = state.value!
        //     .map((e) => e.$2.guid == podcast.guid ? (e.$1, podcast) : e)
        //     .toList();
        // state = AsyncData(list);
        case PodcastStatsUpdatedEvent():
        case null:
      }
    });
  }
}
