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
  if (subscription == null && podcastTitle.isNotEmpty) {
    final all = await subscriptionRepo.getSubscriptions();
    subscription = all.where((s) => s.title == podcastTitle).firstOrNull;
  }
  if (subscription == null) return null;
  return subscription.toPodcast();
}
