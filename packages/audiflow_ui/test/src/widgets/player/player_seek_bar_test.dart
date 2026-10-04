import 'package:audiflow_ui/src/widgets/player/player_seek_bar.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
  bool adjustable = true,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: _barWidth,
          child: PlayerSeekBar(
            value: value,
            segments: segments,
            leadingLabel: '01:00',
            trailingLabel: '-09:00',
            semanticValueFormatter: (value) => 'at ${(value * 100).round()}%',
            adjustable: adjustable,
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

    testWidgets('offers no adjust actions when not adjustable', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(value: 0.5, recorder: _SeekRecorder(), adjustable: false),
      );

      final node = tester.getSemantics(find.byType(PlayerSeekBar));
      check(node.flagsCollection.isSlider).isTrue();
      check(node.value).equals('at 50%');
      check(
        node.getSemanticsData().hasAction(SemanticsAction.increase),
      ).isFalse();
      check(
        node.getSemanticsData().hasAction(SemanticsAction.decrease),
      ).isFalse();
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
