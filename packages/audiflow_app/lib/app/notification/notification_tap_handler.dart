import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

/// Handles notification tap responses by navigating to the
/// appropriate screen via GoRouter.
class NotificationTapHandler {
  const NotificationTapHandler({required this.router, required this.logger});

  final GoRouter router;
  final Logger logger;

  /// Called when user taps a notification while the app is running.
  void onDidReceiveNotificationResponse(NotificationResponse response) {
    logger.i(
      '[NotifTap] onDidReceiveNotificationResponse fired. '
      'actionId=${response.actionId}, '
      'payload=${response.payload}, '
      'notificationResponseType=${response.notificationResponseType}',
    );
    final route = parseNotificationRoute(response.payload);
    logger.i('[NotifTap] parsed route=$route');
    if (route != null) {
      logger.i('[NotifTap] calling router.push($route)');
      router.push(route);
    } else {
      logger.w('[NotifTap] route is null, no navigation');
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
