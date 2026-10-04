import 'package:audiflow_ui/src/widgets/player/step_drag_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

Duration ms(int value) => Duration(milliseconds: value);

void main() {
  group('hysteresis', () {
    test('stays on the step until the finger passes 30% past the boundary', () {
      final tracker = StepDragTracker(startIndex: 5, startTime: ms(0));

      expect(tracker.update(5.6, ms(10)), isFalse);
      expect(tracker.update(5.79, ms(20)), isFalse);
      expect(tracker.index, 5);

      expect(tracker.update(5.81, ms(30)), isTrue);
      expect(tracker.index, 6);
    });

    test('wobbling around a boundary does not flip back and forth', () {
      final tracker = StepDragTracker(startIndex: 5, startTime: ms(0));
      tracker.update(5.9, ms(10));

      for (final position in [5.45, 5.55, 5.4, 5.6, 5.3]) {
        tracker.update(position, ms(20));
        expect(tracker.index, 6, reason: 'at $position');
      }
    });

    test('a fast move jumps straight to the step under the finger', () {
      final tracker = StepDragTracker(startIndex: 2, startTime: ms(0));

      expect(tracker.update(9.2, ms(16)), isTrue);
      expect(tracker.index, 9);
    });

    test('the end steps are reachable', () {
      final tracker = StepDragTracker(startIndex: 1, startTime: ms(0));

      tracker.update(0, ms(10));
      expect(tracker.index, 0);
    });
  });

  group('release', () {
    test('rolls back a one-step change made just before lift-off', () {
      final tracker = StepDragTracker(startIndex: 5, startTime: ms(0));
      tracker.update(8.0, ms(100)); // settles on 8
      tracker.update(8.8, ms(400)); // finger rolls on lift-off

      expect(tracker.resolveRelease(ms(440)), 8);
    });

    test('keeps a change the finger rested on before lifting', () {
      final tracker = StepDragTracker(startIndex: 5, startTime: ms(0));
      tracker.update(8.0, ms(100));
      tracker.update(9.0, ms(400));

      expect(tracker.resolveRelease(ms(600)), 9);
    });

    test('keeps the last step while the finger is still sweeping', () {
      final tracker = StepDragTracker(startIndex: 5, startTime: ms(0));
      tracker.update(6.0, ms(20));
      tracker.update(7.0, ms(40));
      tracker.update(8.0, ms(60));

      // The previous step was held only 20ms: this is motion, not jitter.
      expect(tracker.resolveRelease(ms(70)), 8);
    });

    test('keeps a multi-step jump made just before lift-off', () {
      final tracker = StepDragTracker(startIndex: 5, startTime: ms(0));
      tracker.update(8.0, ms(100));
      tracker.update(11.0, ms(400));

      expect(tracker.resolveRelease(ms(420)), 11);
    });

    test('without any change the start step is committed', () {
      final tracker = StepDragTracker(startIndex: 5, startTime: ms(0));
      tracker.update(5.5, ms(100));

      expect(tracker.resolveRelease(ms(120)), 5);
    });
  });
}
