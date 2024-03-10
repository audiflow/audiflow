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
  Future<List<(PodcastMetadata, PodcastStats)>> build() async {
    final subscriptions = await ref.read(repositoryProvider).subscriptions();
    _listen();
    _log.info('${subscriptions.length} subscriptions');
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
      next.whenData((event) {
        switch (event) {
          case PodcastSubscribedEvent(
              podcast: final podcast,
              stats: final stats
            ):
            final list = [...state.value!, (podcast.metadata, stats)];
            state = AsyncData(_sorted(list));
          case PodcastUnsubscribedEvent(stats: final stats):
            final list =
                state.value!.where((e) => e.$2.guid != stats.guid).toList();
            state = AsyncData(list);
          case PodcastUpdatedEvent(podcast: final podcast, stats: final stats):
            final list = state.value!
                .map(
                  (e) => e.$1.guid == podcast.guid
                      ? (podcast.metadata, stats ?? e.$2)
                      : e,
                )
                .toList();
            state = AsyncData(list);
          case PodcastStatsUpdatedEvent(stats: final stats):
            final list = state.value!
                .map((e) => e.$2.guid == stats.guid ? (e.$1, stats) : e)
                .toList();
            state = AsyncData(list);
        }
      });
    });
  }
}
