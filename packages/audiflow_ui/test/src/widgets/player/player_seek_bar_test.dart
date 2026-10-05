import 'package:audiflow_ui/src/widgets/player/player_seek_bar.dart';
import 'package:audiflow_ui/src/widgets/player/scrub_speed.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  Widget Function(BuildContext context, double value)? tooltipBuilder,
  bool adjustable = true,
  GestureDragUpdateCallback? onParentVerticalDrag,
  bool withSheetArena = true,
  double width = _barWidth,
  Map<ScrubSpeed, String> scrubSpeedLabels = _scrubLabels,
}) {
  return MaterialApp(
    home: Scaffold(
      // Stands in for the player sheet's swipe-to-dismiss.
      body: GestureDetector(
        onVerticalDragUpdate: withSheetArena
            ? onParentVerticalDrag ?? (_) {}
            : null,
        child: Center(
          child: SizedBox(
            width: width,
            child: PlayerSeekBar(
              value: value,
              segments: segments,
              tooltipBuilder: tooltipBuilder,
              leadingLabel: '01:00',
              trailingLabel: '-09:00',
              scrubSpeedLabels: scrubSpeedLabels,
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
    testWidgets(
      'labels sit close under the bar yet the full touch area drags',
      (tester) async {
        final recorder = _SeekRecorder();
        await tester.pumpWidget(
          _host(value: 0.5, recorder: recorder, withSheetArena: false),
        );
        final track = tester.getRect(_track);
        final label = tester.getRect(find.text('01:00'));
        // The bar is drawn mid-touch-area; the labels start below the bar
        // but inside the bottom of its touch area.
        check(track.center.dy).isLessThan(label.top);
        check(label.top).isLessThan(track.bottom);

        // A drag starting at the very bottom of the touch area, over the
        // labels row, still seeks forward.
        final gesture = await tester.startGesture(
          Offset(track.center.dx, track.bottom - 2),
        );
        await gesture.moveBy(const Offset(40, 0));
        await gesture.moveBy(const Offset(40, 0));
        await gesture.up();
        await tester.pump();
        check(recorder.ends).length.equals(1);
        check(0.5).isLessThan(recorder.ends.single);
      },
    );

    testWidgets(
      'tapping the part of the trailing label under the touch area toggles',
      (tester) async {
        final recorder = _SeekRecorder();
        await tester.pumpWidget(_host(value: 0.5, recorder: recorder));
        final track = tester.getRect(_track);
        final label = tester.getRect(find.text('-09:00'));
        // Above the label's vertical middle, still inside the track's area.
        final point = Offset(label.center.dx, track.bottom - 2);
        check(point.dy).isLessThan(label.center.dy);

        await tester.tapAt(point);
        await tester.pump();

        check(recorder.trailingTaps).equals(1);
        check(recorder.ends).isEmpty();
      },
    );

    testWidgets('a second touch does not cancel the covered label tap', (
      tester,
    ) async {
      final recorder = _SeekRecorder();
      await tester.pumpWidget(_host(value: 0.5, recorder: recorder));
      final track = tester.getRect(_track);
      final label = tester.getRect(find.text('-09:00'));

      final labelTap = await tester.startGesture(
        Offset(label.center.dx, track.bottom - 2),
      );
      final other = await tester.startGesture(track.center, pointer: 2);
      await labelTap.up();
      await other.up();
      await tester.pump();

      check(recorder.trailingTaps).equals(1);
    });

    testWidgets(
      'a touch that starts off the label and lifts on it is ignored',
      (tester) async {
        final recorder = _SeekRecorder();
        await tester.pumpWidget(_host(value: 0.5, recorder: recorder));
        final track = tester.getRect(_track);
        final label = tester.getRect(find.text('-09:00'));
        // The label's tap box includes 16 pt of left padding.
        final onLabel = Offset(label.left - 14, track.bottom - 2);

        final gesture = await tester.startGesture(onLabel - const Offset(8, 0));
        await gesture.moveTo(onLabel);
        await gesture.up();
        await tester.pump();

        check(recorder.trailingTaps).equals(0);
      },
    );

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

    testWidgets('scales a long label down instead of cutting it', (
      tester,
    ) async {
      const long = 'Scrubbing at half speed for a fine adjustment';
      await tester.pumpWidget(
        _host(
          value: 0.5,
          recorder: _SeekRecorder(),
          width: 200,
          scrubSpeedLabels: const {ScrubSpeed.half: long},
        ),
      );
      final gesture = await _startScrub(tester);
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();

      final paragraph = tester.renderObject<RenderParagraph>(find.text(long));
      check(paragraph.didExceedMaxLines).isFalse();
      check(tester.takeException()).isNull();
      await gesture.up();
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

  group('PlayerSeekBar lift-off', () {
    Duration ms(int value) => Duration(milliseconds: value);

    // Drags right to about 0.6 over 200 ms, without the sheet arena so every move
    // after the first is applied in full.
    Future<TestGesture> dragToSixtyPercent(
      WidgetTester tester,
      _SeekRecorder recorder,
    ) async {
      await tester.pumpWidget(
        _host(value: 0.5, recorder: recorder, withSheetArena: false),
      );
      final gesture = await tester.startGesture(tester.getCenter(_track));
      await gesture.moveBy(const Offset(1, 0), timeStamp: ms(10));
      for (var t = 1; t <= 10; t++) {
        await gesture.moveBy(
          const Offset(_barWidth * 0.01, 0),
          timeStamp: ms(10 + 20 * t),
        );
      }
      await tester.pump();
      return gesture;
    }

    testWidgets('a roll after holding still commits the settled position', (
      tester,
    ) async {
      final recorder = _SeekRecorder();
      final gesture = await dragToSixtyPercent(tester, recorder);
      final settled = recorder.changes.last;

      // Rests until 500 ms, then rolls 6 pt as it lifts.
      await gesture.moveBy(const Offset(6, 0), timeStamp: ms(520));
      check(recorder.changes.last).equals(settled + 6 / _barWidth);
      await gesture.up(timeStamp: ms(540));
      await tester.pump();

      check(recorder.ends.single).equals(settled);
      // The parent's displayed value ends on the committed position too.
      check(recorder.changes.last).equals(settled);
    });

    testWidgets('a drag still moving at lift-off commits the final position', (
      tester,
    ) async {
      final recorder = _SeekRecorder();
      final gesture = await dragToSixtyPercent(tester, recorder);

      await gesture.moveBy(const Offset(6, 0), timeStamp: ms(220));
      await gesture.up(timeStamp: ms(230));
      await tester.pump();

      check(recorder.ends.single).equals(recorder.changes.last);
      check(recorder.ends.single).isGreaterThan(0.6 + 5 / _barWidth);
    });

    testWidgets('respects the fine-scrub speed', (tester) async {
      final recorder = _SeekRecorder();
      final gesture = await dragToSixtyPercent(tester, recorder);
      // Into the one-eighth band, then hold still.
      await gesture.moveBy(const Offset(0, 160), timeStamp: ms(220));
      final settled = recorder.changes.last;
      await gesture.moveBy(const Offset(16, 0), timeStamp: ms(520));
      check(recorder.changes.last).equals(settled + 2 / _barWidth);
      await gesture.up(timeStamp: ms(540));
      await tester.pump();

      check(recorder.ends.single).equals(settled);
    });

    testWidgets('a cancelled drag commits its current position', (
      tester,
    ) async {
      final recorder = _SeekRecorder();
      final gesture = await dragToSixtyPercent(tester, recorder);
      await gesture.moveBy(const Offset(6, 0), timeStamp: ms(520));
      await gesture.cancel();
      await tester.pump();

      check(recorder.ends.single).equals(recorder.changes.last);
    });
  });

  group('PlayerSeekBar tooltip', () {
    // These tests assert drag-to-value math. Competing with the sheet's
    // vertical recognizer costs a drag its first touch slop (18pt), so they
    // run without that arena.
    Widget tooltipHost(double value) => _host(
      value: value,
      recorder: _SeekRecorder(),
      withSheetArena: false,
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
          withSheetArena: false,
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
