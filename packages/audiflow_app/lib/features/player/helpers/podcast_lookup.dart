import 'package:audiflow_domain/audiflow_domain.dart';

/// Finds the subscription/podcast for a given episode.
///
/// Tries direct ID lookup first. Falls back to title match
/// when episode.podcastId references a stale Isar ID (e.g.
/// after a schema migration that reassigned subscription IDs).
Future<Podcast?> lookupPodcastForEpisode({
  required SubscriptionRepository subscriptionRepo,
  required int podcastId,
  required String podcastTitle,
}) async {
  var subscription = await subscriptionRepo.getById(podcastId);
  final trimmedTitle = podcastTitle.trim();
  if (subscription == null && trimmedTitle.isNotEmpty) {
    final all = await subscriptionRepo.getSubscriptions();
    subscription = _findUniqueTitleMatch(all, trimmedTitle);
  }
  if (subscription == null) return null;
  return subscription.toPodcast();
}

/// Returns the subscription only if exactly one matches [title].
/// Single-pass: exits early once a second match is found.
Subscription? _findUniqueTitleMatch(
  List<Subscription> subscriptions,
  String title,
) {
  Subscription? match;
  for (final s in subscriptions) {
    if (s.title == title) {
      if (match != null) return null;
      match = s;
    }
  }
  return match;
}
