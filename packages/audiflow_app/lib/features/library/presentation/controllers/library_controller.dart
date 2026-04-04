import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_controller.g.dart';

/// SharedPreferences key for persisted podcast sort order.
const _podcastSortOrderKey = 'podcast_sort_order';

/// Provides a reactive stream of user's podcast subscriptions.
///
/// Updates automatically when subscriptions change in the database.
@riverpod
Stream<List<Subscription>> librarySubscriptions(Ref ref) {
  return ref.watch(subscriptionRepositoryProvider).watchSubscriptions();
}

/// Manages the persisted podcast sort order preference.
@riverpod
class PodcastSortOrderController extends _$PodcastSortOrderController {
  @override
  Future<PodcastSortOrder> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_podcastSortOrderKey);
    if (stored == null) return PodcastSortOrder.latestEpisode;
    return PodcastSortOrder.fromName(stored);
  }

  /// Persists [order] and updates state.
  Future<void> setSortOrder(PodcastSortOrder order) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_podcastSortOrderKey, order.name);
    state = AsyncData(order);
  }
}

/// Watches the newest episode for a given podcast, emitting its
/// [Episode.publishedAt] whenever the episode list changes.
///
/// Used by [sortedSubscriptionsProvider] to keep the latest-episode
/// sort order reactive to background feed refreshes.
@riverpod
Stream<DateTime?> newestEpisodeDate(Ref ref, int podcastId) {
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  return episodeRepo.watchByPodcastId(podcastId).map((episodes) {
    if (episodes.isEmpty) return null;
    // Compute max publishedAt explicitly -- the interface does not
    // guarantee any ordering for watchByPodcastId.
    return episodes.fold<DateTime?>(null, (latest, e) {
      final pub = e.publishedAt;
      if (pub == null) return latest;
      if (latest == null || latest.isBefore(pub)) return pub;
      return latest;
    });
  });
}

/// Provides subscriptions sorted by the user's selected sort order.
///
/// Combines [librarySubscriptionsProvider] with
/// [podcastSortOrderControllerProvider] and episode data
/// (for latestEpisode sort).
///
/// When [PodcastSortOrder.latestEpisode] is active, watches
/// per-podcast episode streams so the sort order updates reactively
/// when new episodes arrive (e.g. after a background feed refresh).
@riverpod
Future<List<Subscription>> sortedSubscriptions(Ref ref) async {
  final subscriptions = await ref.watch(librarySubscriptionsProvider.future);
  final sortOrder = await ref.watch(podcastSortOrderControllerProvider.future);

  switch (sortOrder) {
    case PodcastSortOrder.subscribedAt:
      return _sortBySubscribedAt(subscriptions);
    case PodcastSortOrder.alphabetical:
      return _sortAlphabetically(subscriptions);
    case PodcastSortOrder.latestEpisode:
      return _sortByLatestEpisode(subscriptions, ref);
  }
}

List<Subscription> _sortBySubscribedAt(List<Subscription> subscriptions) {
  final sorted = List.of(subscriptions);
  sorted.sort((a, b) {
    final cmp = b.subscribedAt.compareTo(a.subscribedAt);
    if (cmp != 0) return cmp;
    return _tiebreaker(a, b);
  });
  return sorted;
}

List<Subscription> _sortAlphabetically(List<Subscription> subscriptions) {
  final sorted = List.of(subscriptions);
  sorted.sort((a, b) {
    final cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
    if (cmp != 0) return cmp;
    return a.id.compareTo(b.id);
  });
  return sorted;
}

/// Sorts subscriptions by their newest episode date, watching each
/// podcast's episode stream so the order updates reactively.
Future<List<Subscription>> _sortByLatestEpisode(
  List<Subscription> subscriptions,
  Ref ref,
) async {
  // Watch newest episode date per podcast -- establishes reactive
  // dependencies so this provider recomputes when episodes change.
  final futures = subscriptions.map((s) async {
    final date = await ref.watch(newestEpisodeDateProvider(s.id).future);
    return (subscription: s, latestPubDate: date);
  });
  final entries = await Future.wait(futures);

  // Sort: podcasts with episodes first (newest episode descending),
  // then podcasts with no episodes (sorted by subscribedAt descending).
  final sorted = List.of(entries);
  sorted.sort((a, b) {
    final aDate = a.latestPubDate;
    final bDate = b.latestPubDate;
    if (aDate != null && bDate != null) {
      final cmp = bDate.compareTo(aDate);
      if (cmp != 0) return cmp;
      return _tiebreaker(a.subscription, b.subscription);
    }
    if (aDate != null) return -1;
    if (bDate != null) return 1;
    final cmp = b.subscription.subscribedAt.compareTo(
      a.subscription.subscribedAt,
    );
    if (cmp != 0) return cmp;
    return _tiebreaker(a.subscription, b.subscription);
  });

  return sorted.map((e) => e.subscription).toList();
}

/// Deterministic secondary sort: title (case-insensitive), then id.
///
/// Dart's [List.sort] is not stable, so ties in the primary key can
/// reorder unpredictably between rebuilds.  This ensures a consistent
/// order for any two subscriptions that compare equal on the primary
/// sort dimension.
int _tiebreaker(Subscription a, Subscription b) {
  final titleCmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
  if (titleCmp != 0) return titleCmp;
  return a.id.compareTo(b.id);
}
