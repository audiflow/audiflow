import 'package:audiflow_app/features/player/helpers/playback_time_format.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatPlaybackTime', () {
    test('is a placeholder when unknown', () {
      check(formatPlaybackTime(null)).equals('--:--');
    });

    test('uses mm:ss under an hour', () {
      check(
        formatPlaybackTime(const Duration(minutes: 5, seconds: 7)),
      ).equals('05:07');
    });

    test('adds hours from one hour up', () {
      check(
        formatPlaybackTime(const Duration(hours: 1, minutes: 2, seconds: 3)),
      ).equals('1:02:03');
    });
  });
}
