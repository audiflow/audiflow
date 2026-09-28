import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import '../models/new_episode_notification.dart';

/// Detail record for a single notification to display.
///
/// Exposed only for testing; not part of the public API contract.
@visibleForTesting
class NotificationDetail {
  const NotificationDetail({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
    this.artworkUrl,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
  final String? artworkUrl;
}

/// Resolves [artworkUrl] to a local image file for notification
/// [notificationId], or null when unavailable.
///
/// Must return a distinct file per notification: iOS moves attachment files
/// into its own store, so a shared file would be gone for the next one.
typedef ArtworkFileProvider =
    Future<String?> Function(String artworkUrl, int notificationId);

/// Abstracts the `show` call on [FlutterLocalNotificationsPlugin] so tests can
/// inject a fake without subclassing the plugin (which has a private
/// constructor in v21+).
@visibleForTesting
abstract interface class NotificationsShowDelegate {
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  });
}

/// Thin adapter wrapping [FlutterLocalNotificationsPlugin].
class _PluginShowDelegate implements NotificationsShowDelegate {
  const _PluginShowDelegate(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) => _plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: notificationDetails,
    payload: payload,
  );
}

class BackgroundNotificationService {
  BackgroundNotificationService({this._logger, this._artworkFileProvider});

  final Logger? _logger;
  final ArtworkFileProvider? _artworkFileProvider;

  static const _channelId = 'audiflow_new_episodes';
  static const _channelName = 'New Episodes';
  static const _channelDescription = 'Notifications for new podcast episodes';
  static const _artworkTimeout = Duration(seconds: 5);

  Future<FlutterLocalNotificationsPlugin> initialize() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // Background isolate must NOT request permissions — they must already
      // be granted via the foreground initialization in main.dart.
      // Requesting in background silently fails on iOS, preventing all
      // subsequent notifications from being shown.
      //
      // defaultPresent* mirror the foreground init so notifications posted
      // from the background isolate are presented (banner/list/sound) even
      // when the app happens to be in the foreground at delivery time.
      // Without these, iOS silently discards the notification in foreground.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentBanner: true,
        defaultPresentList: true,
        defaultPresentSound: true,
      ),
    );
    await plugin.initialize(settings: initSettings);
    return plugin;
  }

  /// Shows one notification per [NewEpisodeNotification].
  Future<void> showPerEpisodeNotifications(
    FlutterLocalNotificationsPlugin plugin,
    List<NewEpisodeNotification> notifications,
  ) => _showWithDelegate(_PluginShowDelegate(plugin), notifications);

  /// Shows notifications via an injectable [NotificationsShowDelegate].
  ///
  /// Exposed for testing only.
  @visibleForTesting
  Future<void> showPerEpisodeNotificationsViaDelegate(
    NotificationsShowDelegate delegate,
    List<NewEpisodeNotification> notifications,
  ) => _showWithDelegate(delegate, notifications);

  Future<void> _showWithDelegate(
    NotificationsShowDelegate delegate,
    List<NewEpisodeNotification> notifications,
  ) async {
    final details = buildNotificationDetails(notifications);
    // Fetch concurrently: the OS grants background refresh only ~30s, and
    // notifications must not wait on artwork one podcast at a time.
    final artworkPaths = await Future.wait(details.map(_artworkPath));

    final errors = <(Object, StackTrace)>[];

    for (final (index, detail) in details.indexed) {
      try {
        await delegate.show(
          id: detail.id,
          title: detail.title,
          body: detail.body,
          payload: detail.payload,
          notificationDetails: _buildDetails(artworkPaths[index]),
        );
        _logger?.i('Showed notification: ${detail.title} — ${detail.body}');
      } catch (e, stack) {
        _logger?.e('Failed to show notification', error: e, stackTrace: stack);
        errors.add((e, stack));
      }
    }

    if (errors.isNotEmpty) {
      final (firstError, firstStack) = errors.first;
      Error.throwWithStackTrace(
        Exception(
          'Failed to show ${errors.length}/${details.length} notification(s): '
          '$firstError',
        ),
        firstStack,
      );
    }
  }

  Future<String?> _artworkPath(NotificationDetail detail) async {
    final url = detail.artworkUrl;
    final provider = _artworkFileProvider;
    if (url == null || provider == null) return null;
    try {
      return await provider(url, detail.id).timeout(_artworkTimeout);
    } catch (e, stack) {
      // Artwork is decorative; the notification must still be shown.
      _logger?.w('Notification artwork failed', error: e, stackTrace: stack);
      return null;
    }
  }

  static NotificationDetails _buildDetails(String? artworkPath) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        largeIcon: artworkPath == null
            ? null
            : FilePathAndroidBitmap(artworkPath),
      ),
      // presentBanner/presentList/presentSound ensure the notification is
      // visible when the app is in the foreground. Without these flags iOS
      // silently drops foreground banners, which hides both the debug-menu
      // posted notification and any background-refresh result that arrives
      // while the user has the app open.
      iOS: DarwinNotificationDetails(
        presentBanner: true,
        presentList: true,
        presentSound: true,
        attachments: artworkPath == null
            ? null
            : [DarwinNotificationAttachment(artworkPath)],
      ),
    );
  }

  /// Builds notification detail records from episode notifications.
  ///
  /// Uses [NewEpisodeNotification.episodeId] as the notification ID
  /// so re-notifying the same episode replaces the previous one.
  @visibleForTesting
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
            artworkUrl: n.artworkUrl,
          ),
        )
        .toList();
  }
}
