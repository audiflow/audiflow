import 'dart:ui' as ui;

import 'package:audiflow_app/features/voice/presentation/widgets/waveform_painter.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WaveformAnimationMode', () {
    test('listening mode has correct parameters', () {
      const mode = WaveformAnimationMode.listening;
      check(mode.durationMs).equals(800);
      check(mode.minHeight).equals(4.0);
      check(mode.maxHeight).equals(40.0);
      check(mode.bottomColor).equals(const Color(0xFF0D47A1));
      check(mode.topColor).equals(const Color(0xFFFFC107));
    });

    test('processing mode has correct parameters', () {
      const mode = WaveformAnimationMode.processing;
      check(mode.durationMs).equals(2000);
      check(mode.minHeight).equals(4.0);
      check(mode.maxHeight).equals(16.0);
      check(mode.bottomColor).equals(const Color(0xFF0D47A1));
      check(mode.topColor).equals(const Color(0xFF1976D2));
    });

    test('idle mode has correct parameters', () {
      const mode = WaveformAnimationMode.idle;
      check(mode.minHeight).equals(4.0);
      check(mode.maxHeight).equals(4.0);
    });

    test('covers all three modes without default branch', () {
      // Exhaustive switch — compile error if a case is missing.
      for (final mode in WaveformAnimationMode.values) {
        final label = switch (mode) {
          WaveformAnimationMode.listening => 'listening',
          WaveformAnimationMode.processing => 'processing',
          WaveformAnimationMode.idle => 'idle',
        };
        check(label.isNotEmpty).isTrue();
      }
    });
  });

  group('WaveformPainter', () {
    test('shouldRepaint returns true for different animation values', () {
      final animation = _ConstantAnimation(0.0);
      final painter = WaveformPainter(
        animation: animation,
        mode: WaveformAnimationMode.listening,
      );

      final animationChanged = _ConstantAnimation(0.5);
      final painterChanged = WaveformPainter(
        animation: animationChanged,
        mode: WaveformAnimationMode.listening,
      );

      check(painter.shouldRepaint(painterChanged)).isTrue();
    });

    test('shouldRepaint returns true when mode changes', () {
      final animation = _ConstantAnimation(0.0);
      final painter = WaveformPainter(
        animation: animation,
        mode: WaveformAnimationMode.listening,
      );
      final painterProcessing = WaveformPainter(
        animation: animation,
        mode: WaveformAnimationMode.processing,
      );

      check(painter.shouldRepaint(painterProcessing)).isTrue();
    });

    test('shouldRepaint returns false for identical state', () {
      final animation = _ConstantAnimation(0.3);
      final painter = WaveformPainter(
        animation: animation,
        mode: WaveformAnimationMode.listening,
      );
      final painterSame = WaveformPainter(
        animation: animation,
        mode: WaveformAnimationMode.listening,
      );

      check(painter.shouldRepaint(painterSame)).isFalse();
    });

    test('paint does not throw for any mode', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      for (final mode in WaveformAnimationMode.values) {
        final animation = _ConstantAnimation(0.5);
        final painter = WaveformPainter(animation: animation, mode: mode);

        check(
          () => painter.paint(canvas, const Size(200, 60)),
        ).returnsNormally();
      }
    });

    test('paint does not throw at animation boundary values', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      for (final value in [0.0, 0.5, 1.0]) {
        final animation = _ConstantAnimation(value);
        final painter = WaveformPainter(
          animation: animation,
          mode: WaveformAnimationMode.listening,
        );
        check(
          () => painter.paint(canvas, const Size(200, 60)),
        ).returnsNormally();
      }
    });
  });

  group('WaveformWidget', () {
    testWidgets('renders CustomPaint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 60,
                child: WaveformWidget(mode: WaveformAnimationMode.listening),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Find the specific CustomPaint that uses WaveformPainter.
      final waveformPaint = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is WaveformPainter,
      );
      check(waveformPaint).has((f) => f.evaluate().length, 'count').equals(1);
    });

    testWidgets('renders without errors for all modes', (tester) async {
      for (final mode in WaveformAnimationMode.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  height: 60,
                  child: WaveformWidget(mode: mode),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        check(
          find.byType(WaveformWidget),
        ).has((f) => f.evaluate().length, 'count').equals(1);
      }
    });

    testWidgets('animates when mode is listening', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 60,
                child: WaveformWidget(mode: WaveformAnimationMode.listening),
              ),
            ),
          ),
        ),
      );

      // Pump to let animation tick.
      await tester.pump(const Duration(milliseconds: 400));

      check(
        find.byType(WaveformWidget),
      ).has((f) => f.evaluate().length, 'count').equals(1);
    });

    testWidgets('disposes AnimationController without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 60,
                child: WaveformWidget(mode: WaveformAnimationMode.listening),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Replace widget tree — triggers dispose.
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump();

      // No exceptions means dispose completed cleanly.
    });

    testWidgets('updates animation when mode changes', (tester) async {
      var mode = WaveformAnimationMode.listening;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 60,
                      child: WaveformWidget(mode: mode),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          mode = WaveformAnimationMode.processing;
                        });
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Change'));
      await tester.pump();

      check(
        find.byType(WaveformWidget),
      ).has((f) => f.evaluate().length, 'count').equals(1);
    });
  });

  group('WaveformPainter bar height computation', () {
    test('idle mode produces collapsed bars equal to minHeight', () {
      // In idle mode, amplitude is 0 (minHeight == maxHeight == 4),
      // so all bars must render at exactly minHeight regardless of phase.
      final animation = _ConstantAnimation(0.0);
      final painter = WaveformPainter(
        animation: animation,
        mode: WaveformAnimationMode.idle,
      );

      // Verify via the exposed helper (tested indirectly through paint
      // correctness, but expose barHeight for unit testing).
      for (var i = 0; 12 > i; i++) {
        final height = painter.barHeightForIndex(i);
        check(height).equals(4.0);
      }
    });

    test('listening mode bar heights are within [minHeight, maxHeight]', () {
      for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final animation = _ConstantAnimation(t);
        final painter = WaveformPainter(
          animation: animation,
          mode: WaveformAnimationMode.listening,
        );

        for (var i = 0; 12 > i; i++) {
          final height = painter.barHeightForIndex(i);
          check(4.0 <= height).isTrue();
          check(height <= 40.0).isTrue();
        }
      }
    });

    test('processing mode bar heights are within [minHeight, maxHeight]', () {
      for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final animation = _ConstantAnimation(t);
        final painter = WaveformPainter(
          animation: animation,
          mode: WaveformAnimationMode.processing,
        );

        for (var i = 0; 12 > i; i++) {
          final height = painter.barHeightForIndex(i);
          check(4.0 <= height).isTrue();
          check(height <= 16.0).isTrue();
        }
      }
    });
  });
}

/// Stub [Animation<double>] that always returns [value].
class _ConstantAnimation extends Animation<double> {
  _ConstantAnimation(this._value);

  final double _value;

  @override
  double get value => _value;

  @override
  AnimationStatus get status => AnimationStatus.forward;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void addStatusListener(AnimationStatusListener listener) {}

  @override
  void removeStatusListener(AnimationStatusListener listener) {}
}
