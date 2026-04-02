import 'dart:convert';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_app/app/notification/notification_tap_handler.dart';

void main() {
  group('NotificationTapHandler', () {
    group('parseNotificationRoute', () {
      test('returns route for valid new_episode payload', () {
        final payload = jsonEncode({
          'type': 'new_episode',
          'episodeId': 42,
          'podcastId': 7,
        });

        final route = NotificationTapHandler.parseNotificationRoute(payload);
        check(route).equals('/notification/episode/7/42');
      });

      test('returns null for null payload', () {
        final route = NotificationTapHandler.parseNotificationRoute(null);
        check(route).isNull();
      });

      test('returns null for empty payload', () {
        final route = NotificationTapHandler.parseNotificationRoute('');
        check(route).isNull();
      });

      test('returns null for unknown type', () {
        final payload = jsonEncode({'type': 'unknown'});
        final route = NotificationTapHandler.parseNotificationRoute(payload);
        check(route).isNull();
      });

      test('returns null for malformed JSON', () {
        final route = NotificationTapHandler.parseNotificationRoute('not json');
        check(route).isNull();
      });
    });
  });
}
