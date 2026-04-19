import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Handles notification tap responses by navigating to the
/// appropriate screen via GoRouter.
class NotificationTapHandler {
  const NotificationTapHandler({required this.router});

  final GoRouter router;

  /// Called when user taps a notification while the app is running.
  void onDidReceiveNotificationResponse(NotificationResponse response) {
    final route = parseNotificationRoute(response.payload);
    if (route == null) {
      unawaited(
        Sentry.captureMessage(
          'notif-tap: route parse returned null — no navigation',
          level: SentryLevel.warning,
          withScope: (scope) {
            scope.setContexts('notification_tap', {
              'payloadPresent': response.payload != null,
              'payloadLength': response.payload?.length ?? 0,
              'actionId': response.actionId,
              'notificationResponseType': response.notificationResponseType
                  .toString(),
            });
          },
        ),
      );
      return;
    }

    try {
      router.push(route);
    } on Object catch (e, stack) {
      unawaited(
        Sentry.captureException(
          e,
          stackTrace: stack,
          withScope: (scope) {
            scope.setContexts('notification_tap', {
              'route': route,
              'currentLocation': _currentLocation(),
            });
          },
        ),
      );
    }
  }

  String _currentLocation() {
    try {
      return router.routerDelegate.currentConfiguration.uri.toString();
    } on Object catch (_) {
      return '<unavailable>';
    }
  }

  /// Parses a notification payload and returns the route to navigate to,
  /// or null if the payload is invalid or unrecognized.
  static String? parseNotificationRoute(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['type'] != 'new_episode') return null;

      final episodeId = decoded['episodeId'];
      final podcastId = decoded['podcastId'];
      if (episodeId is! int || podcastId is! int) return null;

      return '/notification/episode/$podcastId/$episodeId';
    } on Exception {
      return null;
    }
  }
}
