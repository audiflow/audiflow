import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackSpeedScale', () {
    test('has 21 ascending steps from 0.5 to 3.0', () {
      const steps = PlaybackSpeedScale.steps;
      expect(steps.length, 21);
      expect(steps.first, 0.5);
      expect(steps.last, 3.0);
      for (var i = 1; i < steps.length; i++) {
        expect(steps[i - 1] < steps[i], isTrue);
      }
      expect(steps.sublist(15), [2.0, 2.2, 2.4, 2.6, 2.8, 3.0]);
    });

    test('speedForIndex and indexForSpeed round-trip every step', () {
      for (var i = 0; i < PlaybackSpeedScale.steps.length; i++) {
        final speed = PlaybackSpeedScale.speedForIndex(i);
        expect(PlaybackSpeedScale.indexForSpeed(speed), i);
      }
    });

    test('speedForIndex clamps out-of-range indices', () {
      expect(PlaybackSpeedScale.speedForIndex(-3), 0.5);
      expect(PlaybackSpeedScale.speedForIndex(99), 3.0);
    });

    test('snap rounds legacy off-grid speeds to the nearest step', () {
      expect(PlaybackSpeedScale.snap(0.75), 0.8);
      expect(PlaybackSpeedScale.snap(1.25), 1.3);
      expect(PlaybackSpeedScale.snap(1.75), 1.8);
      expect(PlaybackSpeedScale.snap(1.22), 1.2);
      expect(PlaybackSpeedScale.snap(2.05), 2.0);
      expect(PlaybackSpeedScale.snap(2.1), 2.2);
    });

    test('snap clamps values outside the grid', () {
      expect(PlaybackSpeedScale.snap(0.1), 0.5);
      expect(PlaybackSpeedScale.snap(4.0), 3.0);
    });

    test('snap absorbs floating-point drift', () {
      expect(PlaybackSpeedScale.snap(0.1 + 0.2 + 1.0), 1.3);
    });

    test('label formats with one decimal', () {
      expect(PlaybackSpeedScale.label(1.0), '1.0x');
      expect(PlaybackSpeedScale.label(2.4), '2.4x');
    });
  });

  group('RecentPlaybackSpeeds', () {
    test('record puts the newest speed first', () {
      expect(RecentPlaybackSpeeds.record([1.5], 2.0), [2.0, 1.5]);
    });

    test('record evicts the oldest beyond capacity', () {
      expect(RecentPlaybackSpeeds.record([2.0, 1.5], 1.3), [1.3, 2.0]);
    });

    test('record moves an existing entry to the front', () {
      expect(RecentPlaybackSpeeds.record([2.0, 1.5], 1.5), [1.5, 2.0]);
    });

    test('record ignores normal speed', () {
      expect(RecentPlaybackSpeeds.record([2.0, 1.5], 1.0), [2.0, 1.5]);
    });

    test('record snaps the speed to the grid', () {
      expect(RecentPlaybackSpeeds.record([], 1.25), [1.3]);
    });

    test('normalize sanitizes stored data', () {
      expect(RecentPlaybackSpeeds.normalize([1.0, 1.25, 1.3, 0.75, 3.0]), [
        1.3,
        0.8,
      ]);
    });

    test('chipSpeeds returns normal plus recents in ascending order', () {
      expect(RecentPlaybackSpeeds.chipSpeeds([2.0, 0.8]), [0.8, 1.0, 2.0]);
      expect(RecentPlaybackSpeeds.chipSpeeds([1.5, 1.2]), [1.0, 1.2, 1.5]);
      expect(RecentPlaybackSpeeds.chipSpeeds([]), [1.0]);
    });
  });
}
