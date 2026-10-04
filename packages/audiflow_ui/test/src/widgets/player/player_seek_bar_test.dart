import 'package:audiflow_ui/src/widgets/player/player_seek_bar.dart';
import 'package:audiflow_ui/src/widgets/player/scrub_speed.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _barWidth = 400.0;

/// Records every callback the seek bar fires.
class _SeekRecorder {
  final List<double> starts = [];
  final List<double> changes = [];
  final List<double> ends = [];
  int trailingTaps = 0;
}

const _scrubLabels = {
  ScrubSpeed.full: 'full',
  ScrubSpeed.half: 'half',
  ScrubSpeed.quarter: 'quarter',
  ScrubSpeed.fine: 'fine',
};

Widget _host({
  required double value,
  required _SeekRecorder recorder,
  List<SeekBarSegment> segments = SeekBarSegment.single,
  GestureDragUpdateCallback? onParentVerticalDrag,
}) {
  return MaterialApp(
    home: Scaffold(
      // Stands in for the player sheet's swipe-to-dismiss.
      body: GestureDetector(
        onVerticalDragUpdate: onParentVerticalDrag ?? (_) {},
        child: Center(
          child: SizedBox(
            width: _barWidth,
            child: PlayerSeekBar(
              value: value,
              segments: segments,
              leadingLabel: '01:00',
              trailingLabel: '-09:00',
              scrubSpeedLabels: _scrubLabels,
              semanticValueFormatter: (value) => 'at ${(value * 100).round()}%',
              onChangeStart: recorder.starts.add,
              onChanged: recorder.changes.add,
              onChangeEnd: recorder.ends.add,
              onTrailingLabelTap: () => recorder.trailingTaps++,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Captures haptic feedback requests sent to the platform.
List<Object?> _recordHaptics(WidgetTester tester) {
  final haptics = <Object?>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return haptics;
}

/// Starts a drag on the track center and moves past the drag slop, so later
/// moves are applied in full.
///
/// With the sheet's vertical recognizer competing, winning the arena sends
/// no update; the second move is what actually begins the scrub.
Future<TestGesture> _startScrub(WidgetTester tester) async {
  final gesture = await tester.startGesture(tester.getCenter(_track));
  await gesture.moveBy(const Offset(40, 0));
  await gesture.moveBy(const Offset(10, 0));
  await tester.pump();
  return gesture;
}

/// Value change caused by a 100 pt horizontal move made [dy] pt below the
/// track.
Future<double> _travelAt(WidgetTester tester, double dy) async {
  final recorder = _SeekRecorder();
  await tester.pumpWidget(_host(value: 0.5, recorder: recorder));
  final gesture = await _startScrub(tester);
  await gesture.moveBy(Offset(0, dy));
  final before = recorder.changes.last;
  await gesture.moveBy(const Offset(100, 0));
  await gesture.up();
  await tester.pump();
  return recorder.ends.single - before;
}

const _labelTexts = ['full', 'half', 'quarter', 'fine'];

List<String> _visibleScrubLabels() => [
  for (final text in _labelTexts)
    if (find.text(text).evaluate().isNotEmpty) text,
];

Finder get _track => find.byKey(PlayerSeekBar.trackKey);

void main() {
  group('PlayerSeekBar', () {
    testWidgets('shows leading and trailing labels', (tester) async {
      await tester.pumpWidget(_host(value: 0.1, recorder: _SeekRecorder()));

      check(find.text('01:00').evaluate()).isNotEmpty();
      check(find.text('-09:00').evaluate()).isNotEmpty();
    });

    testWidgets('tapping the track does not seek', (tester) async {
      final recorder = _SeekRecorder();
      await tester.pumpWidget(_host(value: 0.5, recorder: recorder));

      await tester.tapAt(tester.getTopLeft(_track) + const Offset(20, 8));
      await tester.pump();

      check(recorder.starts).isEmpty();
      check(recorder.changes).isEmpty();
      check(recorder.ends).isEmpty();
    });

    testWidgets('drag moves by finger delta, not to the touch point', (
      tester,
    ) async {
      final recorder = _SeekRecorder();
      await tester.pumpWidget(_host(value: 0.5, recorder: recorder));

      // Start near the left edge: a jump-to-touch slider would report ~0.
      final start = tester.getTopLeft(_track) + const Offset(10, 8);
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(20, 0));
      await gesture.moveBy(const Offset(_barWidth * 0.1, 0));
      await gesture.up();
      await tester.pump();

      check(recorder.starts.single).equals(0.5);
      // The first 20 px are consumed by the drag slop; only the second move
      // is guaranteed to be applied in full.
      check(recorder.ends.single).isGreaterOrEqual(0.6 - 1e-9);
      check(recorder.ends.single).isLessOrEqual(0.65 + 1e-9);
      check(recorder.changes.last).equals(recorder.ends.single);
    });

    testWidgets('clamps the value to the track bounds', (tester) async {
      final recorder = _SeekRecorder();
      await tester.pumpWidget(_host(value: 0.9, recorder: recorder));

      await tester.drag(_track, const Offset(_barWidth, 0));
      await tester.pump();

      check(recorder.ends.single).equals(1.0);
    });

    testWidgets('fires a light haptic on drag start', (tester) async {
      final haptics = _recordHaptics(tester);
      await tester.pumpWidget(_host(value: 0.5, recorder: _SeekRecorder()));

      await tester.drag(_track, const Offset(40, 0));
      await tester.pump();

      check(haptics).deepEquals(['HapticFeedbackType.lightImpact']);
    });

    testWidgets('thickens the track while dragging', (tester) async {
      await tester.pumpWidget(_host(value: 0.5, recorder: _SeekRecorder()));
      double trackHeight() =>
          (tester
                      .widget<CustomPaint>(
                        find.descendant(
                          of: _track,
                          matching: find.byType(CustomPaint),
                        ),
                      )
                      .painter!
                  as PlayerSeekBarPainter)
              .trackHeight;

      check(trackHeight()).equals(PlayerSeekBar.idleTrackHeight);

      final gesture = await _startScrub(tester);
      await tester.pumpAndSettle();
      check(trackHeight()).equals(PlayerSeekBar.draggingTrackHeight);

      await gesture.up();
      await tester.pumpAndSettle();
      check(trackHeight()).equals(PlayerSeekBar.idleTrackHeight);
    });

    testWidgets('tapping the trailing label calls onTrailingLabelTap', (
      tester,
    ) async {
      final recorder = _SeekRecorder();
      await tester.pumpWidget(_host(value: 0.1, recorder: recorder));

      await tester.tap(find.text('-09:00'));
      await tester.pump();

      check(recorder.trailingTaps).equals(1);
      check(recorder.starts).isEmpty();
    });

    testWidgets('exposes slider semantics with the given value', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(value: 0.1, recorder: _SeekRecorder()));

      final node = tester.getSemantics(find.byType(PlayerSeekBar));
      check(node.flagsCollection.isSlider).isTrue();
      check(node.value).equals('at 10%');
      handle.dispose();
    });
  });

  group('PlayerSeekBar fine scrubbing', () {
    testWidgets('150 pt away, travel is one eighth of full speed', (
      tester,
    ) async {
      final full = await _travelAt(tester, 0);
      final fine = await _travelAt(tester, 150);

      check(full).isCloseTo(100 / _barWidth, 1e-9);
      check(fine).isCloseTo(full / 8, 1e-9);
    });

    testWidgets('slows down by band above the track too', (tester) async {
      check(await _travelAt(tester, -60)).isCloseTo(50 / _barWidth, 1e-9);
      check(await _travelAt(tester, -110)).isCloseTo(25 / _barWidth, 1e-9);
    });

    testWidgets('shows the band label only below full speed', (tester) async {
      await tester.pumpWidget(_host(value: 0.5, recorder: _SeekRecorder()));
      final gesture = await _startScrub(tester);
      check(_visibleScrubLabels()).isEmpty();

      final seen = <List<String>>[];
      for (final step in [60.0, 50.0, 50.0, -120.0]) {
        await gesture.moveBy(Offset(0, step));
        await tester.pump();
        seen.add(_visibleScrubLabels());
      }
      check(seen).deepEquals([
        ['half'],
        ['quarter'],
        ['fine'],
        <String>[],
      ]);

      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      check(_visibleScrubLabels()).isEmpty();
    });

    testWidgets('fires a light haptic on each band change only', (
      tester,
    ) async {
      final haptics = _recordHaptics(tester);
      await tester.pumpWidget(_host(value: 0.5, recorder: _SeekRecorder()));
      final gesture = await _startScrub(tester);
      // Moves within full, into half, within half, into quarter, back to full.
      for (final step in [20.0, 40.0, 20.0, 50.0, -120.0]) {
        await gesture.moveBy(Offset(0, step));
      }
      await gesture.up();
      await tester.pump();

      check(haptics).length.equals(4);
      check(haptics.toSet()).deepEquals({'HapticFeedbackType.lightImpact'});
    });

    testWidgets('next drag starts at full speed again', (tester) async {
      final haptics = _recordHaptics(tester);
      await tester.pumpWidget(_host(value: 0.5, recorder: _SeekRecorder()));
      final first = await _startScrub(tester);
      await first.moveBy(const Offset(0, 200));
      await first.up();
      await tester.pump();

      haptics.clear();
      final second = await _startScrub(tester);
      await tester.pump();
      // Only the drag-start haptic: no band change back from fine.
      check(haptics).length.equals(1);
      check(_visibleScrubLabels()).isEmpty();
      await second.up();
    });

    testWidgets('a vertical drag on the track goes to the enclosing sheet', (
      tester,
    ) async {
      final recorder = _SeekRecorder();
      var parentDrags = 0;
      await tester.pumpWidget(
        _host(
          value: 0.5,
          recorder: recorder,
          onParentVerticalDrag: (_) => parentDrags++,
        ),
      );

      await tester.drag(_track, const Offset(5, 120));
      await tester.pump();

      check(parentDrags).isGreaterThan(0);
      check(recorder.starts).isEmpty();
    });

    testWidgets('a started scrub keeps the finger when it moves vertically', (
      tester,
    ) async {
      final recorder = _SeekRecorder();
      var parentDrags = 0;
      await tester.pumpWidget(
        _host(
          value: 0.5,
          recorder: recorder,
          onParentVerticalDrag: (_) => parentDrags++,
        ),
      );

      final gesture = await _startScrub(tester);
      await gesture.moveBy(const Offset(0, 200));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.up();
      await tester.pump();

      check(parentDrags).equals(0);
      check(recorder.ends).length.equals(1);
    });
  });

  group('PlayerSeekBar accessibility', () {
    testWidgets('increase action seeks forward by one semantic step', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final recorder = _SeekRecorder();
      await tester.pumpWidget(_host(value: 0.5, recorder: recorder));

      final slider = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.slider == true,
        ),
      );
      check(slider.properties.increasedValue).equals('at 55%');
      slider.properties.onIncrease!();
      await tester.pump();

      check(recorder.starts.single).equals(0.5);
      check(
        recorder.ends.single,
      ).isCloseTo(0.5 + PlayerSeekBar.semanticStep, 1e-9);
      handle.dispose();
    });

    testWidgets('trailing label is reachable as a button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(value: 0.1, recorder: _SeekRecorder()));

      final node = tester.getSemantics(find.text('-09:00'));
      check(node.flagsCollection.isButton).isTrue();
      handle.dispose();
    });
  });

  group('PlayerSeekBarPainter', () {
    test('painter repaints when segments change', () {
      const base = PlayerSeekBarPainter(
        value: 0.5,
        trackHeight: 6,
        segments: SeekBarSegment.single,
        activeColor: Colors.blue,
        inactiveColor: Colors.grey,
      );
      const split = PlayerSeekBarPainter(
        value: 0.5,
        trackHeight: 6,
        segments: [
          SeekBarSegment(start: 0, end: 0.5),
          SeekBarSegment(start: 0.5, end: 1),
        ],
        activeColor: Colors.blue,
        inactiveColor: Colors.grey,
      );
      check(split.shouldRepaint(base)).isTrue();
      check(base.shouldRepaint(base)).isFalse();
    });
  });
}
