import 'package:audiflow_app/app/background/localized_notification_text_formatter.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalizedNotificationTextFormatter', () {
    final date = DateTime(2026, 9, 1, 12);
    const duration = Duration(hours: 1, minutes: 5);

    test('uses the stored language over the platform one', () async {
      final formatter = await LocalizedNotificationTextFormatter.create(
        storedLocale: 'ja',
        platformLocale: 'en_US',
      );

      check(formatter.formatDate(date)).equals('2026年9月1日');
      check(formatter.formatDuration(duration)).equals('1時間5分');
    });

    test('follows the platform language when none is stored', () async {
      final formatter = await LocalizedNotificationTextFormatter.create(
        storedLocale: null,
        platformLocale: 'ja_JP',
      );

      check(formatter.formatDuration(duration)).equals('1時間5分');
    });

    test('falls back to English for unsupported languages', () async {
      final formatter = await LocalizedNotificationTextFormatter.create(
        storedLocale: null,
        platformLocale: 'fr_FR',
      );

      check(formatter.formatDate(date)).equals('Sep 1, 2026');
      check(formatter.formatDuration(duration)).equals('1h5m');
    });

    test('shows minutes only under an hour', () async {
      final formatter = await LocalizedNotificationTextFormatter.create(
        storedLocale: 'en',
        platformLocale: 'en_US',
      );

      check(
        formatter.formatDuration(const Duration(minutes: 42)),
      ).equals('42m');
    });
  });
}
