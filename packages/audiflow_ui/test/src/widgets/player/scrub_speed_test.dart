import 'package:audiflow_ui/src/widgets/player/scrub_speed.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('scrubFactorForDistance', () {
    test('is full speed within 50 pt of the bar', () {
      check(scrubFactorForDistance(0)).equals(1.0);
      check(scrubFactorForDistance(49.9)).equals(1.0);
    });

    test('halves between 50 and 100 pt', () {
      check(scrubFactorForDistance(50)).equals(0.5);
      check(scrubFactorForDistance(99.9)).equals(0.5);
    });

    test('quarters between 100 and 150 pt', () {
      check(scrubFactorForDistance(100)).equals(0.25);
      check(scrubFactorForDistance(149.9)).equals(0.25);
    });

    test('is one eighth from 150 pt on', () {
      check(scrubFactorForDistance(150)).equals(0.125);
      check(scrubFactorForDistance(1000)).equals(0.125);
    });

    test('treats above and below the bar the same', () {
      for (final dy in [10.0, 60.0, 120.0, 200.0]) {
        check(scrubFactorForDistance(-dy)).equals(scrubFactorForDistance(dy));
      }
    });
  });

  group('scrubSpeedForDistance', () {
    test('maps each band to its speed', () {
      check(scrubSpeedForDistance(25)).equals(ScrubSpeed.full);
      check(scrubSpeedForDistance(75)).equals(ScrubSpeed.half);
      check(scrubSpeedForDistance(-125)).equals(ScrubSpeed.quarter);
      check(scrubSpeedForDistance(175)).equals(ScrubSpeed.fine);
    });
  });
}
