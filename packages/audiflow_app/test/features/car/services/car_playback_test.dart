import 'package:audiflow_app/features/car/services/car_playback.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextCarSpeed', () {
    test('steps through every car speed and wraps', () {
      final visited = <double>[];
      var speed = carSpeeds.first;
      for (var i = 0; i < carSpeeds.length; i++) {
        speed = nextCarSpeed(speed);
        visited.add(speed);
      }
      check(visited).deepEquals([...carSpeeds.skip(1), carSpeeds.first]);
    });

    test('moves a speed between steps up to the next step', () {
      check(nextCarSpeed(1.3)).equals(1.5);
    });

    test('wraps a speed above the last step to the first', () {
      check(nextCarSpeed(PlaybackSpeedScale.max)).equals(carSpeeds.first);
    });

    test('moves a speed below the first step up to it', () {
      check(nextCarSpeed(PlaybackSpeedScale.min)).equals(carSpeeds.first);
    });

    test('only offers speeds on the shared grid', () {
      for (final speed in carSpeeds) {
        check(PlaybackSpeedScale.steps).contains(speed);
      }
    });
  });
}
