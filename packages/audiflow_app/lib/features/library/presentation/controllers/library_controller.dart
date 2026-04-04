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

/// Provides subscriptions sorted by the user's selected sort order.
///
/// Combines [librarySubscriptionsProvider] with
/// [podcastSortOrderControllerProvider] and episode data
/// (for latestEpisode sort).
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
      final episodeRepo = ref.watch(episodeRepositoryProvider);
      return _sortByLatestEpisode(subscriptions, episodeRepo);
  }
}

List<Subscription> _sortBySubscribedAt(List<Subscription> subscriptions) {
  final sorted = List.of(subscriptions);
  sorted.sort((a, b) => b.subscribedAt.compareTo(a.subscribedAt));
  return sorted;
}

List<Subscription> _sortAlphabetically(List<Subscription> subscriptions) {
  final sorted = List.of(subscriptions);
  sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  return sorted;
}

Future<List<Subscription>> _sortByLatestEpisode(
  List<Subscription> subscriptions,
  EpisodeRepository episodeRepo,
) async {
  // Fetch newest episode date per podcast in parallel.
  final futures = subscriptions.map((s) async {
    final episode = await episodeRepo.getNewestByPodcastId(s.id);
    return (subscription: s, latestPubDate: episode?.publishedAt);
  });
  final entries = await Future.wait(futures);

  // Sort: podcasts with episodes first (newest episode descending),
  // then podcasts with no episodes (sorted by subscribedAt descending).
  final sorted = List.of(entries);
  sorted.sort((a, b) {
    final aDate = a.latestPubDate;
    final bDate = b.latestPubDate;
    if (aDate != null && bDate != null) return bDate.compareTo(aDate);
    if (aDate != null) return -1;
    if (bDate != null) return 1;
    return b.subscription.subscribedAt.compareTo(a.subscription.subscribedAt);
  });

  return sorted.map((e) => e.subscription).toList();
}
