import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import '../models/new_episode_notification.dart';

/// Android drawable name of the monochrome notification small icon.
///
/// Android draws small icons from the alpha channel only, so the full-colour
/// launcher icon would render as a blank circle.
const androidNotificationSmallIcon = 'ic_stat_notification';

/// Tint for the notification small icon: the app icon's background colour,
/// so the notification matches the launcher icon rather than the system's
/// default accent.
const androidNotificationColor = Color(0xFFDB8648);

/// iOS category of new-episode notifications.
///
/// Kept stable so a future Notification Content Extension can claim these
/// notifications by category.
const newEpisodeNotificationCategory = 'new_episode';

/// Joins the parts of one notification line.
const _separator = ' \u00B7 ';

/// Locale-aware text for notification fields.
///
/// The background isolate has no `BuildContext`, so the app layer, which
/// owns localization, supplies an implementation for the stored locale.
abstract interface class NotificationTextFormatter {
  String formatDate(DateTime date);
  String formatDuration(Duration duration);
}

/// Detail record for a single notification to display.
///
/// Exposed only for testing; not part of the public API contract.
@visibleForTesting
class NotificationDetail {
  const NotificationDetail({
    required this.id,
    required this.title,
    required this.podcastTitle,
    required this.meta,
    required this.body,
    required this.payload,
    this.artworkUrl,
  });

  final int id;

  /// Episode title.
  final String title;

  final String podcastTitle;

  /// Publish date and duration; null when the episode has neither.
  final String? meta;

  /// Plain-text description; null when the episode has none.
  final String? body;
  final String payload;
  final String? artworkUrl;

  /// iOS subtitle: the podcast, with [meta] on its own line so the date and
  /// duration stay together rather than wrapping mid-way.
  String get subtitle => meta == null ? podcastTitle : '$podcastTitle\n$meta';
}

/// Resolves [artworkUrl] to a local image file for notification
/// [notificationId], or null when unavailable.
///
/// Must return a distinct file per notification: iOS moves attachment files
/// into its own store, so a shared file would be gone for the next one.
typedef ArtworkFileProvider =
    Future<String?> Function(String artworkUrl, int notificationId);

/// Told when artwork for [artworkUrl] could not be attached, including a
/// timeout, so the app layer can surface it to telemetry.
typedef ArtworkFailureSink = void Function(String artworkUrl, Object error);

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
  BackgroundNotificationService({
    required this._textFormatter,
    this._logger,
    this._artworkFileProvider,
    this._onArtworkFailure,
  });

  final NotificationTextFormatter _textFormatter;
  final Logger? _logger;
  final ArtworkFileProvider? _artworkFileProvider;
  final ArtworkFailureSink? _onArtworkFailure;

  static const _channelId = 'audiflow_new_episodes';
  static const _channelName = 'New Episodes';
  static const _channelDescription = 'Notifications for new podcast episodes';
  static const _artworkTimeout = Duration(seconds: 5);

  Future<FlutterLocalNotificationsPlugin> initialize() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@drawable/$androidNotificationSmallIcon',
      ),
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
    final details = buildNotificationDetails(notifications, _textFormatter);
    // Fetch concurrently: the OS grants background refresh only ~30s, and
    // notifications must not wait on artwork one podcast at a time.
    final artworkPaths = await Future.wait(details.map(_artworkPath));

    final errors = <(Object, StackTrace)>[];

    for (final (index, detail) in details.indexed) {
      try {
        await _showWithFallback(delegate, detail, artworkPaths[index]);
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

  /// iOS rejects a notification whose attachment it cannot read, so a
  /// failure with artwork is retried text-only rather than losing the
  /// notification.
  Future<void> _showWithFallback(
    NotificationsShowDelegate delegate,
    NotificationDetail detail,
    String? artworkPath,
  ) async {
    try {
      await _show(delegate, detail, artworkPath);
    } catch (e, stack) {
      if (artworkPath == null) rethrow;
      _logger?.w(
        'Retrying notification without artwork',
        error: e,
        stackTrace: stack,
      );
      await _show(delegate, detail, null);
    }
  }

  Future<void> _show(
    NotificationsShowDelegate delegate,
    NotificationDetail detail,
    String? artworkPath,
  ) => delegate.show(
    id: detail.id,
    title: detail.title,
    body: detail.body,
    payload: detail.payload,
    notificationDetails: _buildDetails(detail, artworkPath),
  );

  Future<String?> _artworkPath(NotificationDetail detail) async {
    final url = detail.artworkUrl;
    final provider = _artworkFileProvider;
    if (url == null || provider == null) return null;
    try {
      return await provider(url, detail.id).timeout(_artworkTimeout);
    } catch (e, stack) {
      // Artwork is decorative; the notification must still be shown.
      _logger?.w('Notification artwork failed', error: e, stackTrace: stack);
      _reportArtworkFailure(url, e);
      return null;
    }
  }

  void _reportArtworkFailure(String url, Object error) {
    try {
      _onArtworkFailure?.call(url, error);
    } catch (e, stack) {
      // Telemetry must never cost the notification.
      _logger?.w('Artwork failure sink threw', error: e, stackTrace: stack);
    }
  }

  /// Expanded Android text: the notes with date and duration as summary, or
  /// date and duration alone when the episode has no notes.
  static StyleInformation? _androidStyle(NotificationDetail detail) {
    final body = detail.body;
    final meta = detail.meta;
    if (body != null) return BigTextStyleInformation(body, summaryText: meta);
    if (meta != null) return BigTextStyleInformation(meta);
    return null;
  }

  static NotificationDetails _buildDetails(
    NotificationDetail detail,
    String? artworkPath,
  ) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        color: androidNotificationColor,
        largeIcon: artworkPath == null
            ? null
            : FilePathAndroidBitmap(artworkPath),
        // Android has no subtitle: the header line carries the podcast, and
        // the expanded view's summary carries date and duration.
        subText: detail.podcastTitle,
        styleInformation: _androidStyle(detail),
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
        subtitle: detail.subtitle,
        categoryIdentifier: newEpisodeNotificationCategory,
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
    NotificationTextFormatter formatter,
  ) {
    return notifications.map((n) => _detailFor(n, formatter)).toList();
  }

  static NotificationDetail _detailFor(
    NewEpisodeNotification n,
    NotificationTextFormatter formatter,
  ) {
    final publishedAt = n.publishedAt;
    final duration = n.duration;
    final metaParts = [
      if (publishedAt != null) formatter.formatDate(publishedAt),
      if (duration != null && Duration.zero < duration)
        formatter.formatDuration(duration),
    ];
    return NotificationDetail(
      id: n.episodeId,
      title: n.episodeTitle,
      podcastTitle: n.podcastTitle,
      meta: metaParts.isEmpty ? null : metaParts.join(_separator),
      body: n.description,
      payload: n.toPayload(),
      artworkUrl: n.artworkUrl,
    );
  }
}
