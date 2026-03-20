import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class BackgroundNotificationService {
  BackgroundNotificationService({Logger? logger}) : _logger = logger;

  final Logger? _logger;

  static const _channelId = 'audiflow_new_episodes';
  static const _channelName = 'New Episodes';
  static const _channelDescription = 'Notifications for new podcast episodes';
  static const _notificationId = 1001;

  Future<FlutterLocalNotificationsPlugin> initialize() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(settings: initSettings);
    return plugin;
  }

  Future<void> showNewEpisodesNotification(
    FlutterLocalNotificationsPlugin plugin,
    Map<String, int> newEpisodesPerPodcast,
  ) async {
    if (newEpisodesPerPodcast.isEmpty) return;

    final body = formatNotificationBody(newEpisodesPerPodcast);
    if (body.isEmpty) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await plugin.show(
        id: _notificationId,
        title: 'New episodes available',
        body: body,
        notificationDetails: details,
      );
      _logger?.i('Showed notification: $body');
    } catch (e, stack) {
      _logger?.e('Failed to show notification', error: e, stackTrace: stack);
    }
  }

  static String formatNotificationBody(Map<String, int> episodesPerPodcast) {
    if (episodesPerPodcast.isEmpty) return '';

    final totalEpisodes = episodesPerPodcast.values.fold(0, (a, b) => a + b);
    final names = episodesPerPodcast.keys.toList();
    final episodeLabel = totalEpisodes == 1 ? 'episode' : 'episodes';

    return switch (names.length) {
      1 => '$totalEpisodes new $episodeLabel from ${names[0]}',
      2 => '$totalEpisodes new $episodeLabel from ${names[0]} and ${names[1]}',
      _ => () {
        final otherCount = names.length - 2;
        final otherLabel = otherCount == 1 ? '1 other' : '$otherCount others';
        return '$totalEpisodes new $episodeLabel from ${names[0]}, ${names[1]}, and $otherLabel';
      }(),
    };
  }
}
