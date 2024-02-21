import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/podcast_event.dart';
import 'package:seasoning/repository/repository_provider.dart';

part 'podcast_subscriptions_provider.g.dart';

@Riverpod(keepAlive: true)
class PodcastSubscriptions extends _$PodcastSubscriptions {
  @override
  Future<List<(PodcastStats, PodcastSummary)>> build() async {
    final subscriptions = await ref.read(repositoryProvider).subscriptions();
    _listen();
    return subscriptions;
  }

  List<(PodcastStats, PodcastSummary)> _sorted(
    List<(PodcastStats, PodcastSummary)> subscriptions,
  ) {
    return subscriptions
        .sorted((a, b) =>
            b.$2.releaseDate.millisecondsSinceEpoch -
            a.$2.releaseDate.millisecondsSinceEpoch)
        .toList();
  }

  void _listen() {
    final repository = ref.read(repositoryProvider);

    final sub = repository.podcastStream.listen((event) {
      switch (event) {
        case PodcastSubscribedEvent(podcast: final podcast, stats: final stats):
          final list = [...state.value!, (stats, podcast)];
          state = AsyncData(_sorted(list));
        case PodcastUnsubscribedEvent(stats: final stats):
          final list = state.value!.where((e) => e.$1.id != stats.id).toList();
          state = AsyncData(list);
        case PodcastUpdatedEvent(podcast: final podcast):
          // final list = state.value!
          //     .map((e) => e.$2.guid == podcast.guid ? (e.$1, podcast) : e)
          //     .toList();
          // state = AsyncData(list);
        case PodcastStatsUpdatedEvent(stats: final stats):
          // final list = state.value!
          //     .map((e) => e.$1.id == stats.id ? (stats, e.$2) : e)
          //     .toList();
          // state = AsyncData(_sorted(list));
      }
    });
    ref.onDispose(sub.cancel);
  }
}
