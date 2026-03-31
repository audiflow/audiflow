import 'package:audiflow_ui/src/widgets/player/skip_duration_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checks/checks.dart';

void main() {
  group('SkipDurationIcon', () {
    // -- Backward: dedicated icons for 5/10/30 --------------------------

    testWidgets('renders dedicated icon for 10s backward', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 10, isForward: false, size: 36),
          ),
        ),
      );

      check(find.byIcon(Icons.replay_10).evaluate()).isNotEmpty();
    });

    testWidgets('renders dedicated icon for 30s backward', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 30, isForward: false, size: 36),
          ),
        ),
      );

      check(find.byIcon(Icons.replay_30).evaluate()).isNotEmpty();
    });

    // -- Backward: text overlay for non-dedicated -----------------------

    testWidgets('renders text overlay for 15s backward', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 15, isForward: false, size: 36),
          ),
        ),
      );

      check(find.text('15').evaluate()).isNotEmpty();
      check(find.byIcon(Icons.replay).evaluate()).isNotEmpty();
    });

    // -- Forward: always text overlay (flipped replay) ------------------

    testWidgets('renders flipped replay with text for 30s forward', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 30, isForward: true, size: 36),
          ),
        ),
      );

      check(find.text('30').evaluate()).isNotEmpty();
      check(find.byIcon(Icons.replay).evaluate()).isNotEmpty();
    });

    testWidgets('renders flipped replay with text for 15s forward', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 15, isForward: true, size: 36),
          ),
        ),
      );

      check(find.text('15').evaluate()).isNotEmpty();
      check(find.byIcon(Icons.replay).evaluate()).isNotEmpty();
    });

    testWidgets('renders flipped replay with text for 45s forward', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 45, isForward: true, size: 36),
          ),
        ),
      );

      check(find.text('45').evaluate()).isNotEmpty();
      check(find.byIcon(Icons.replay).evaluate()).isNotEmpty();
    });

    // -- Size and color -------------------------------------------------

    testWidgets('applies provided size to overlay icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 30, isForward: true, size: 48),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.replay));
      check(icon.size).equals(48);
    });

    testWidgets('applies provided color to dedicated icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(
              seconds: 10,
              isForward: false,
              size: 36,
              color: Colors.red,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.replay_10));
      check(icon.color).equals(Colors.red);
    });
  });
}
