import 'package:audiflow_ui/src/widgets/player/seek_release_tracker.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

Duration ms(int value) => Duration(milliseconds: value);

const _trackWidth = 400.0;

/// Track fraction for [points] along a [_trackWidth] track.
double pt(double points) => points / _trackWidth;

SeekReleaseTracker _tracker({double start = 0.0}) => SeekReleaseTracker(
  startValue: start,
  startTime: ms(0),
  trackWidth: _trackWidth,
);

/// Feeds a drag moving [speed] points per 10 ms from [from] for [frames]
/// samples starting at [startMs]. Returns the last position.
double _drag(
  SeekReleaseTracker tracker, {
  required double from,
  required double speed,
  required int frames,
  required int startMs,
}) {
  var position = from;
  for (var i = 1; i <= frames; i++) {
    position = from + speed * i;
    tracker.update(pt(position), ms(startMs + 10 * i));
  }
  return position;
}

void main() {
  group('settled then jitter', () {
    test('a roll after holding still commits the settled position', () {
      final tracker = _tracker();
      _drag(tracker, from: 0, speed: 5, frames: 20, startMs: 0); // to 100 pt
      // Holds at 100 pt from 200 ms to 400 ms with sub-point tremor.
      tracker.update(pt(100.5), ms(300));
      tracker.update(pt(100), ms(380));
      // The finger rolls as it lifts.
      tracker.update(pt(104), ms(410));
      tracker.update(pt(107), ms(425));

      check(tracker.resolveRelease(ms(440))).equals(pt(100));
    });

    test('a roll backwards is undone as well', () {
      final tracker = _tracker(start: pt(200));
      tracker.update(pt(180), ms(50));
      tracker.update(pt(174), ms(330));

      check(tracker.resolveRelease(ms(350))).equals(pt(180));
    });

    test('the dwell may be the time since the drag began', () {
      final tracker = _tracker(start: pt(100));
      tracker.update(pt(103), ms(200));

      check(tracker.resolveRelease(ms(220))).equals(pt(100));
    });
  });

  group('fine scrubbing', () {
    test('a small finger roll is undone', () {
      // At one-eighth speed a 6 pt finger roll moves the bar 0.75 pt.
      final tracker = _tracker();
      _drag(tracker, from: 0, speed: 0.5, frames: 20, startMs: 0);
      tracker.update(pt(10.75), ms(400), finger: 10 + 6);

      check(tracker.resolveRelease(ms(420))).equals(pt(10));
    });

    test('a final push measured under the finger is kept', () {
      // At one-eighth speed a 64 pt push moves the bar only 8 pt, inside
      // the roll limit on the bar but far beyond it under the finger.
      final tracker = _tracker();
      _drag(tracker, from: 0, speed: 0.5, frames: 20, startMs: 0);
      tracker.update(pt(18), ms(400), finger: 10 + 64);

      check(tracker.resolveRelease(ms(420))).equals(pt(18));
    });
  });

  group('kept as is', () {
    test('a drag still moving at lift-off commits the final position', () {
      final tracker = _tracker();
      final last = _drag(tracker, from: 0, speed: 1, frames: 40, startMs: 0);

      check(tracker.resolveRelease(ms(405))).equals(pt(last));
    });

    test('a slow drag of under a point per frame is not mistaken for '
        'resting', () {
      final tracker = _tracker();
      final last = _drag(tracker, from: 0, speed: 0.4, frames: 40, startMs: 0);

      check(tracker.resolveRelease(ms(405))).equals(pt(last));
    });

    test('a flick from rest commits the final position', () {
      final tracker = _tracker(start: pt(100));
      tracker.update(pt(130), ms(300));
      tracker.update(pt(170), ms(310));

      check(tracker.resolveRelease(ms(320))).equals(pt(170));
    });

    test('a flick at the end of a drag commits the final position', () {
      final tracker = _tracker();
      _drag(tracker, from: 0, speed: 8, frames: 10, startMs: 0);
      tracker.update(pt(110), ms(110));
      tracker.update(pt(140), ms(120));

      check(tracker.resolveRelease(ms(125))).equals(pt(140));
    });

    test('a move the finger rested on before lifting is kept', () {
      final tracker = _tracker(start: pt(100));
      tracker.update(pt(105), ms(300));

      check(tracker.resolveRelease(ms(500))).equals(pt(105));
    });

    test('a pause shorter than the dwell does not count', () {
      final tracker = _tracker();
      _drag(tracker, from: 0, speed: 5, frames: 20, startMs: 0);
      tracker.update(pt(105), ms(300));

      check(tracker.resolveRelease(ms(320))).equals(pt(105));
    });

    test('a drag that began inside the late window is kept', () {
      final tracker = _tracker(start: pt(100));
      tracker.update(pt(103), ms(20));

      check(tracker.resolveRelease(ms(40))).equals(pt(103));
    });

    test('no movement keeps the start position', () {
      final tracker = _tracker(start: pt(50));

      check(tracker.resolveRelease(ms(500))).equals(pt(50));
    });
  });

  test('thresholds are configurable', () {
    final tracker = SeekReleaseTracker(
      startValue: pt(100),
      startTime: ms(0),
      trackWidth: _trackWidth,
      lateMoveWindow: ms(20),
    );
    tracker.update(pt(103), ms(300));

    check(tracker.resolveRelease(ms(340))).equals(pt(103));
  });
}
