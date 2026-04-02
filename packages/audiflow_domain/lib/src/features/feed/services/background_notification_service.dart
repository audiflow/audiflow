import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

import '../models/new_episode_notification.dart';

/// Detail record for a single notification to display.
class NotificationDetail {
  const NotificationDetail({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

class BackgroundNotificationService {
  BackgroundNotificationService({Logger? logger}) : _logger = logger;

  final Logger? _logger;

  static const _channelId = 'audiflow_new_episodes';
  static const _channelName = 'New Episodes';
  static const _channelDescription = 'Notifications for new podcast episodes';

  Future<FlutterLocalNotificationsPlugin> initialize() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(settings: initSettings);
    return plugin;
  }

  /// Shows one notification per [NewEpisodeNotification].
  Future<void> showPerEpisodeNotifications(
    FlutterLocalNotificationsPlugin plugin,
    List<NewEpisodeNotification> notifications,
  ) async {
    final details = buildNotificationDetails(notifications);

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    for (final detail in details) {
      try {
        await plugin.show(
          id: detail.id,
          title: detail.title,
          body: detail.body,
          payload: detail.payload,
          notificationDetails: notificationDetails,
        );
        _logger?.i('Showed notification: ${detail.title} — ${detail.body}');
      } catch (e, stack) {
        _logger?.e('Failed to show notification', error: e, stackTrace: stack);
      }
    }
  }

  /// Builds notification detail records from episode notifications.
  ///
  /// Uses [NewEpisodeNotification.episodeId] as the notification ID
  /// so re-notifying the same episode replaces the previous one.
  static List<NotificationDetail> buildNotificationDetails(
    List<NewEpisodeNotification> notifications,
  ) {
    return notifications
        .map(
          (n) => NotificationDetail(
            id: n.episodeId,
            title: n.podcastTitle,
            body: n.episodeTitle,
            payload: n.toPayload(),
          ),
        )
        .toList();
  }
}
