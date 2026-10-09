import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingHapticPlayer implements HapticPlayer {
  final played = <HapticToken>[];

  @override
  void play(HapticToken token) => played.add(token);

  @override
  void prepare(HapticToken token) {}
}

void main() {
  Widget host({
    required double speed,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 420,
          child: PlaybackSpeedSlider(
            speed: speed,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ),
    );
  }

  testWidgets('has 21 positions and shows the snapped speed', (tester) async {
    await tester.pumpWidget(host(speed: 1.25, onChanged: (_) {}));

    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.divisions, 20);
    expect(slider.min, 0);
    expect(slider.max, 20);
    expect(slider.value, PlaybackSpeedScale.indexForSpeed(1.3).toDouble());
  });

  testWidgets('drag emits each step once without haptics, then the end value', (
    tester,
  ) async {
    final changes = <double>[];
    final ends = <double>[];
    var haptics = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') haptics++;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      host(speed: 1.0, onChanged: changes.add, onChangeEnd: ends.add),
    );
    // Drag from the start of the track to its end: every step is crossed.
    // The slider has a 24 pt horizontal padding outside its track.
    final rect = tester.getRect(find.byType(Slider)).deflate(24);
    final gesture = await tester.startGesture(rect.centerLeft);
    for (var dx = 0.0; dx <= rect.width + 24; dx += 4) {
      await gesture.moveTo(rect.centerLeft + Offset(dx, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump();

    expect(changes.toSet().length, changes.length);
    expect(changes.last, 3.0);
    expect(changes, contains(2.2));
    expect(haptics, 0);
    expect(ends, [3.0]);
  });

  testWidgets('tapping the current step does not fire onChangeEnd', (
    tester,
  ) async {
    final ends = <double>[];
    await tester.pumpWidget(
      host(speed: 0.5, onChanged: (_) {}, onChangeEnd: ends.add),
    );
    // The first step sits at the start of the track (after the padding).
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, 0);
    final rect = tester.getRect(find.byType(Slider)).deflate(24);
    final gesture = await tester.startGesture(
      rect.centerLeft + const Offset(1, 0),
    );
    await gesture.up();
    await tester.pump();

    expect(ends, isEmpty);

    // A tap on another step is a real choice.
    await tester.tapAt(rect.centerRight - const Offset(1, 0));
    await tester.pump();
    expect(ends, [3.0]);
  });

  testWidgets('tapping a landmark label selects that speed', (tester) async {
    // A tap on the track picks the nearest tick, so landing on the
    // labelled speed proves the label sits over its own tick.
    for (final speed in PlaybackSpeedSlider.landmarkSpeeds) {
      final start = speed == 1.0 ? 2.0 : 1.0;
      final changes = <double>[];
      await tester.pumpWidget(host(speed: start, onChanged: changes.add));
      final label = find.text(PlaybackSpeedScale.label(speed));
      final sliderCenterY = tester.getCenter(find.byType(Slider)).dy;
      await tester.tapAt(Offset(tester.getCenter(label).dx, sliderCenterY));
      await tester.pumpAndSettle();
      expect(changes.last, speed, reason: 'label for $speed');
    }
  });

  group('jitter handling', () {
    // Center of the tick at [index] for the 420 pt wide host.
    Offset tickCenter(WidgetTester tester, int index) {
      final rect = tester.getRect(find.byType(Slider));
      const inset = 24.0 + 2.0; // padding + half the rounded track
      final span = rect.width - 2 * inset;
      final x = rect.left + inset + span * index / PlaybackSpeedScale.maxIndex;
      return Offset(x, rect.center.dy);
    }

    double stepWidth(WidgetTester tester) =>
        tickCenter(tester, 1).dx - tickCenter(tester, 0).dx;

    testWidgets('a roll onto the next step at lift-off is undone', (
      tester,
    ) async {
      final changes = <double>[];
      final ends = <double>[];
      await tester.pumpWidget(
        host(speed: 1.0, onChanged: changes.add, onChangeEnd: ends.add),
      );
      final target = PlaybackSpeedScale.indexForSpeed(1.5);
      final gesture = await tester.startGesture(
        tickCenter(tester, PlaybackSpeedScale.indexForSpeed(1.0)),
      );
      // Slide to 1.5x and rest there.
      for (var t = 1; t <= 10; t++) {
        await gesture.moveTo(
          tickCenter(tester, target) - Offset(stepWidth(tester) * (10 - t), 0),
          timeStamp: Duration(milliseconds: 20 * t),
        );
        await tester.pump();
      }
      // The finger rolls one step right as it lifts.
      await gesture.moveTo(
        tickCenter(tester, target + 1),
        timeStamp: const Duration(milliseconds: 500),
      );
      await tester.pump();
      expect(changes.last, 1.6);
      await gesture.up(timeStamp: const Duration(milliseconds: 530));
      await tester.pump();

      expect(changes.last, 1.5);
      expect(ends, [1.5]);
    });

    testWidgets('resting on a boundary does not toggle steps', (tester) async {
      final changes = <double>[];
      await tester.pumpWidget(host(speed: 0.8, onChanged: changes.add));
      final gesture = await tester.startGesture(
        tickCenter(tester, PlaybackSpeedScale.indexForSpeed(0.8)),
      );
      // Drag up to the 1.0/1.1 boundary, then wobble a few points on it.
      final one = tickCenter(tester, PlaybackSpeedScale.indexForSpeed(1.0));
      final boundary = one.dx + stepWidth(tester) / 2;
      for (final dx in [-3.0, 3.0, -2.0, 4.0, -4.0, 2.0]) {
        await gesture.moveTo(Offset(boundary + dx, one.dy));
        await tester.pump();
      }
      await gesture.up();
      await tester.pump();

      expect(changes.last, 1.0);
      expect(changes, isNot(contains(1.1)));
    });

    testWidgets('a tap commits where the finger went down', (tester) async {
      final ends = <double>[];
      await tester.pumpWidget(
        host(speed: 1.0, onChanged: (_) {}, onChangeEnd: ends.add),
      );
      final down = tickCenter(tester, PlaybackSpeedScale.indexForSpeed(1.5));
      final gesture = await tester.startGesture(down);
      // Lift-off roll smaller than the drag slop.
      await gesture.moveTo(down + Offset(stepWidth(tester) * 0.7, 0));
      await gesture.up();
      await tester.pump();

      expect(ends, [1.5]);
    });

    testWidgets('shows the speed above the thumb while dragging', (
      tester,
    ) async {
      await tester.pumpWidget(host(speed: 1.0, onChanged: (_) {}));
      final start = tickCenter(tester, PlaybackSpeedScale.indexForSpeed(1.0));
      final gesture = await tester.startGesture(start);
      await gesture.moveTo(start + Offset(stepWidth(tester) * 2, 0));
      await tester.pump();

      expect(find.text('1.2x'), findsOneWidget);

      await gesture.up();
      await tester.pump();
      expect(find.text('1.2x'), findsNothing);
    });

    testWidgets('screen reader increase moves exactly one step', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final changes = <double>[];
      await tester.pumpWidget(host(speed: 1.0, onChanged: changes.add));

      tester.semantics.performAction(
        find.semantics.byValue('1.0x'),
        SemanticsAction.increase,
      );
      await tester.pump();

      expect(changes, [1.1]);
      semantics.dispose();
    });
  });

  group('1.0x mark', () {
    Future<List<HapticToken>> dragAcross(
      WidgetTester tester, {
      required double fromFraction,
      required double toFraction,
    }) async {
      final player = _RecordingHapticPlayer();
      await tester.pumpWidget(
        HapticsScope(
          player: player,
          child: host(speed: 2.0, onChanged: (_) {}),
        ),
      );
      final rect = tester.getRect(find.byType(Slider)).deflate(24);
      Offset at(double fraction) =>
          rect.centerLeft + Offset(rect.width * fraction, 0);
      final gesture = await tester.startGesture(at(fromFraction));
      final steps = 40;
      for (var i = 1; i <= steps; i++) {
        final t = fromFraction + (toFraction - fromFraction) * i / steps;
        await gesture.moveTo(at(t));
        await tester.pump();
      }
      await gesture.up();
      await tester.pump();
      return player.played;
    }

    testWidgets('a drag across 1.0x plays steps and one edge', (tester) async {
      // The track starts at 0.5x, so 1.0x sits a quarter of the way along.
      final played = await dragAcross(tester, fromFraction: 0, toFraction: 0.6);
      check(
        played.where((t) => t == HapticToken.edge).toList(),
      ).length.equals(1);
      check(
        played.where((t) => t != HapticToken.edge).toSet(),
      ).deepEquals({HapticToken.step});
    });

    testWidgets('a drag that stays above 1.0x plays only steps', (
      tester,
    ) async {
      final played = await dragAcross(tester, fromFraction: 0.6, toFraction: 1);
      check(played).isNotEmpty();
      check(played.toSet()).deepEquals({HapticToken.step});
    });
  });
}
