import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/features/browser/common/data/podcast_stats_repository/podcast_stats_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastStatsRepositoryChangeHandler implements PodcastStatsRepository {
  PodcastStatsRepositoryChangeHandler(this._ref, this._inner);

  final Ref _ref;
  final PodcastStatsRepository _inner;

  // -- Subscriptions

  @override
  Future<List<Podcast>> subscriptions() => _inner.subscriptions();

  @override
  Future<void> subscribePodcast(Podcast podcast) async {
    await _inner.subscribePodcast(podcast);
    final stats = await _inner.findPodcastStats(podcast.id);
    _ref
        .read(podcastEventStreamProvider.notifier)
        .add(PodcastSubscribedEvent(podcast, stats!));
  }

  @override
  Future<void> unsubscribePodcast(Podcast podcast) async {
    await _inner.unsubscribePodcast(podcast);
    final stats = await _inner.findPodcastStats(podcast.id);
    _ref
        .read(podcastEventStreamProvider.notifier)
        .add(PodcastUnsubscribedEvent(podcast, stats!));
  }

  // -- PodcastStats

  @override
  Future<PodcastStats?> findPodcastStats(int pid) =>
      _inner.findPodcastStats(pid);

  @override
  Future<PodcastStats?> findPodcastStatsBy({required String feedUrl}) =>
      _inner.findPodcastStatsBy(feedUrl: feedUrl);

  @override
  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param) async {
    final stats = await _inner.updatePodcastStats(param);
    _ref
        .read(podcastEventStreamProvider.notifier)
        .add(PodcastStatsUpdatedEvent(stats));
    return stats;
  }
}
