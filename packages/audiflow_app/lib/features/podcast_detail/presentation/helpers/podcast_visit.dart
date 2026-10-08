import 'package:audiflow_domain/audiflow_domain.dart';

/// Records that the listener opened the podcast at [feedUrl], which clears
/// its new-episode dot in the Library.
///
/// Called whenever the screen opens: the feed fetch also records a visit,
/// but its provider is reused while another copy of the screen stays
/// mounted (e.g. in another tab), so it cannot be relied on.
Future<void> recordPodcastVisit(
  SubscriptionRepository repository,
  String feedUrl,
) async {
  final subscription = await repository.getByFeedUrl(feedUrl);
  if (subscription == null) return;
  await repository.updateLastAccessed(subscription.id);
}
