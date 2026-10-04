import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets('drag emits each step once with haptics, then the end value', (
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
    expect(haptics, changes.length);
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
}
