import 'package:audiflow_app/features/carplay/services/carplay_playback.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextCarPlaySpeed', () {
    test('steps through every CarPlay speed and wraps', () {
      final visited = <double>[];
      var speed = carPlaySpeeds.first;
      for (var i = 0; i < carPlaySpeeds.length; i++) {
        speed = nextCarPlaySpeed(speed);
        visited.add(speed);
      }
      check(
        visited,
      ).deepEquals([...carPlaySpeeds.skip(1), carPlaySpeeds.first]);
    });

    test('moves a speed between steps up to the next step', () {
      check(nextCarPlaySpeed(1.3)).equals(1.5);
    });

    test('wraps a speed above the last step to the first', () {
      check(
        nextCarPlaySpeed(PlaybackSpeedScale.max),
      ).equals(carPlaySpeeds.first);
    });

    test('moves a speed below the first step up to it', () {
      check(
        nextCarPlaySpeed(PlaybackSpeedScale.min),
      ).equals(carPlaySpeeds.first);
    });

    test('only offers speeds on the shared grid', () {
      for (final speed in carPlaySpeeds) {
        check(PlaybackSpeedScale.steps).contains(speed);
      }
    });
  });
}
