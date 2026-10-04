import 'package:audiflow_ui/src/widgets/player/player_seek_bar.dart';
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

Widget _host({
  required double value,
  required _SeekRecorder recorder,
  List<SeekBarSegment> segments = SeekBarSegment.single,
  Widget Function(BuildContext context, double value)? tooltipBuilder,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: _barWidth,
          child: PlayerSeekBar(
            value: value,
            segments: segments,
            tooltipBuilder: tooltipBuilder,
            leadingLabel: '01:00',
            trailingLabel: '-09:00',
            semanticValueFormatter: (value) => 'at ${(value * 100).round()}%',
            onChangeStart: recorder.starts.add,
            onChanged: recorder.changes.add,
            onChangeEnd: recorder.ends.add,
            onTrailingLabelTap: () => recorder.trailingTaps++,
          ),
        ),
      ),
    ),
  );
}

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
      final haptics = <Object?>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
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

      final gesture = await tester.startGesture(tester.getCenter(_track));
      await gesture.moveBy(const Offset(40, 0));
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

    test('leaves a gap only where segments meet', () {
      const painter = PlayerSeekBarPainter(
        value: 0,
        trackHeight: 6,
        segments: [
          SeekBarSegment(start: 0, end: 0.5),
          SeekBarSegment(start: 0.5, end: 1),
        ],
        segmentGap: 2,
        activeColor: Colors.blue,
        inactiveColor: Colors.grey,
      );
      const radius = Radius.circular(3);
      expect(
        (Canvas canvas) => painter.paint(canvas, const Size(400, 10)),
        paints
          ..rrect(rrect: RRect.fromLTRBR(0, 2, 199, 8, radius))
          ..rrect(rrect: RRect.fromLTRBR(201, 2, 400, 8, radius)),
      );
    });

    test('skips a segment narrower than the gap', () {
      const painter = PlayerSeekBarPainter(
        value: 0,
        trackHeight: 6,
        segments: [
          SeekBarSegment(start: 0, end: 0.5),
          SeekBarSegment(start: 0.5, end: 0.502),
          SeekBarSegment(start: 0.502, end: 1),
        ],
        segmentGap: 2,
        activeColor: Colors.blue,
        inactiveColor: Colors.grey,
      );
      expect(
        (Canvas canvas) => painter.paint(canvas, const Size(400, 10)),
        paints
          ..rrect()
          ..rrect(),
      );
      expect(
        (Canvas canvas) => painter.paint(canvas, const Size(400, 10)),
        isNot(
          paints
            ..rrect()
            ..rrect()
            ..rrect(),
        ),
      );
    });
  });

  group('PlayerSeekBar tooltip', () {
    Widget tooltipHost(double value) => _host(
      value: value,
      recorder: _SeekRecorder(),
      tooltipBuilder: (context, value) => Text('at ${(value * 100).round()}%'),
    );

    Future<TestGesture> startDrag(WidgetTester tester, double dx) async {
      final gesture = await tester.startGesture(tester.getCenter(_track));
      await gesture.moveBy(Offset(dx, 0));
      await tester.pump();
      return gesture;
    }

    testWidgets('is hidden until a drag starts', (tester) async {
      await tester.pumpWidget(tooltipHost(0.5));

      check(find.byKey(PlayerSeekBar.tooltipKey).evaluate()).isEmpty();
    });

    testWidgets('follows the scrub value and hides on release', (tester) async {
      await tester.pumpWidget(tooltipHost(0.5));

      final gesture = await startDrag(tester, _barWidth * 0.1);
      check(find.text('at 60%').evaluate()).isNotEmpty();
      final tooltip = tester.getRect(find.byKey(PlayerSeekBar.tooltipKey));
      final track = tester.getRect(_track);
      check(tooltip.bottom).isLessOrEqual(track.top);
      check(
        (tooltip.center.dx - (track.left + _barWidth * 0.6)).abs(),
      ).isLessThan(1);

      await gesture.up();
      await tester.pump();
      check(find.byKey(PlayerSeekBar.tooltipKey).evaluate()).isEmpty();
    });

    testWidgets('stays inside the bar at both edges', (tester) async {
      await tester.pumpWidget(tooltipHost(0.0));
      final track = tester.getRect(_track);

      var gesture = await startDrag(tester, -10);
      var tooltip = tester.getRect(find.byKey(PlayerSeekBar.tooltipKey));
      check(tooltip.left).equals(track.left);
      await gesture.up();
      await tester.pump();

      await tester.pumpWidget(tooltipHost(1.0));
      gesture = await startDrag(tester, 10);
      tooltip = tester.getRect(find.byKey(PlayerSeekBar.tooltipKey));
      check(tooltip.right).equals(track.right);
      await gesture.up();
    });

    testWidgets('drag continues across the first update', (tester) async {
      final recorder = _SeekRecorder();
      await tester.pumpWidget(
        _host(
          value: 0.5,
          recorder: recorder,
          tooltipBuilder: (context, value) => const Text('tip'),
        ),
      );

      final gesture = await startDrag(tester, 10);
      await gesture.moveBy(const Offset(_barWidth * 0.1, 0));
      await gesture.up();
      await tester.pump();

      check(recorder.ends).length.equals(1);
      check(recorder.ends.single).isGreaterThan(0.6);
    });
  });
}
