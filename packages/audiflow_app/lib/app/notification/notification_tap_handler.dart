import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

/// Handles notification tap responses by navigating to the
/// appropriate screen via GoRouter.
class NotificationTapHandler {
  const NotificationTapHandler({required this.router});

  final GoRouter router;

  /// Called when user taps a notification while the app is running.
  void onDidReceiveNotificationResponse(NotificationResponse response) {
    final route = parseNotificationRoute(response.payload);
    if (route != null) {
      router.push(route);
    }
  }

  /// Parses a notification payload and returns the route to navigate to,
  /// or null if the payload is invalid or unrecognized.
  static String? parseNotificationRoute(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['type'] != 'new_episode') return null;

      final episodeId = data['episodeId'] as int;
      final podcastId = data['podcastId'] as int;

      return '/notification/episode/$podcastId/$episodeId';
    } on Exception {
      return null;
    }
  }
}
