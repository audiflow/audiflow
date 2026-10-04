import 'package:audiflow_ui/src/widgets/player/skip_duration_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checks/checks.dart';
import 'package:material_symbols_icons/symbols.dart';

const _durations = [5, 10, 15, 30, 45, 60];

Future<void> _pumpIcon(
  WidgetTester tester, {
  required int seconds,
  required bool isForward,
  double size = 36,
  Color? color,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SkipDurationIcon(
          seconds: seconds,
          isForward: isForward,
          size: size,
          color: color,
        ),
      ),
    ),
  );
}

Text _digitText(WidgetTester tester, int seconds) =>
    tester.widget<Text>(find.text('$seconds'));

Padding _digitPadding(WidgetTester tester, int seconds) =>
    tester.widget<Padding>(
      find
          .ancestor(of: find.text('$seconds'), matching: find.byType(Padding))
          .first,
    );

void main() {
  group('SkipDurationIcon', () {
    for (final seconds in _durations) {
      for (final isForward in [false, true]) {
        final direction = isForward ? 'forward' : 'backward';

        testWidgets(
          'renders replay glyph with text for ${seconds}s $direction',
          (tester) async {
            await _pumpIcon(tester, seconds: seconds, isForward: isForward);

            check(find.text('$seconds').evaluate()).isNotEmpty();
            check(find.byIcon(Symbols.replay).evaluate()).isNotEmpty();
            // Dedicated glyphs embed their own digits in a different style.
            check(find.byIcon(Symbols.replay_5).evaluate()).isEmpty();
            check(find.byIcon(Symbols.replay_10).evaluate()).isEmpty();
            check(find.byIcon(Symbols.replay_30).evaluate()).isEmpty();
          },
        );
      }

      testWidgets('backward and forward digits match for ${seconds}s', (
        tester,
      ) async {
        await _pumpIcon(tester, seconds: seconds, isForward: false);
        final backwardStyle = _digitText(tester, seconds).style;
        final backwardPadding = _digitPadding(tester, seconds).padding;

        await _pumpIcon(tester, seconds: seconds, isForward: true);
        final forwardStyle = _digitText(tester, seconds).style;
        final forwardPadding = _digitPadding(tester, seconds).padding;

        check(backwardStyle).equals(forwardStyle);
        check(backwardPadding).equals(forwardPadding);
      });
    }

    testWidgets('sizes digits at 28% of icon size and bold', (tester) async {
      await _pumpIcon(tester, seconds: 10, isForward: false, size: 50);

      final style = _digitText(tester, 10).style!;
      check(style.fontSize).isNotNull().isCloseTo(14, 1e-9);
      check(style.fontWeight).equals(FontWeight.w700);
    });

    testWidgets('flips the glyph only for forward', (tester) async {
      await _pumpIcon(tester, seconds: 10, isForward: false);
      check(find.byType(Transform).evaluate().where(_isFlip)).isEmpty();

      await _pumpIcon(tester, seconds: 10, isForward: true);
      check(find.byType(Transform).evaluate().where(_isFlip)).isNotEmpty();
    });

    testWidgets('applies provided size to replay icon', (tester) async {
      await _pumpIcon(tester, seconds: 30, isForward: true, size: 48);

      final icon = tester.widget<Icon>(find.byIcon(Symbols.replay));
      check(icon.size).equals(48);
    });

    testWidgets('applies provided color to icon and digits', (tester) async {
      await _pumpIcon(tester, seconds: 10, isForward: false, color: Colors.red);

      final icon = tester.widget<Icon>(find.byIcon(Symbols.replay));
      check(icon.color).equals(Colors.red);
      check(_digitText(tester, 10).style?.color).equals(Colors.red);
    });
  });
}

bool _isFlip(Element element) {
  final transform = (element.widget as Transform).transform;
  return transform.entry(0, 0) == -1;
}
