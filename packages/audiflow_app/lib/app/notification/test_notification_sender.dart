import 'package:audiflow_domain/audiflow_domain.dart';

/// Posts [notifications] through the new-episode notification service.
typedef NewEpisodeNotificationPoster =
    Future<void> Function(List<NewEpisodeNotification> notifications);

/// Posts sample new-episode notifications on demand from the developer
/// settings.
///
/// Uses the newest stored episode of each subscribed podcast, so a change to
/// notifications can be checked on a device without waiting for a background
/// refresh to find new episodes.
class TestNotificationSender {
  TestNotificationSender({
    required this._subscriptionRepo,
    required this._episodeRepo,
    required this._post,
  });

  /// One per podcast, capped so a large library does not flood the device.
  static const maxNotifications = 3;

  final SubscriptionRepository _subscriptionRepo;
  final EpisodeRepository _episodeRepo;
  final NewEpisodeNotificationPoster _post;

  /// Posts the notifications and returns how many were posted.
  Future<int> send() async {
    final notifications = await _collect();
    if (notifications.isEmpty) return 0;
    await _post(notifications);
    return notifications.length;
  }

  Future<List<NewEpisodeNotification>> _collect() async {
    final notifications = <NewEpisodeNotification>[];
    for (final subscription in await _subscriptionRepo.getSubscriptions()) {
      if (maxNotifications <= notifications.length) break;
      final episode = await _episodeRepo.getNewestByPodcastId(subscription.id);
      if (episode == null) continue;
      notifications.add(
        NewEpisodeNotification.fromEpisode(
          subscription: subscription,
          episode: episode,
          artworkUrl: subscription.artworkUrl,
        ),
      );
    }
    return notifications;
  }
}
