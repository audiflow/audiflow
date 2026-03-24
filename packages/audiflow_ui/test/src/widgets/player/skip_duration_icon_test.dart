import 'package:audiflow_ui/src/widgets/player/skip_duration_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checks/checks.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  group('skipForwardIconData', () {
    test('returns forward_5 for 5 seconds', () {
      check(skipForwardIconData(5)).equals(Symbols.forward_5);
    });

    test('returns forward_10 for 10 seconds', () {
      check(skipForwardIconData(10)).equals(Symbols.forward_10);
    });

    test('returns forward_30 for 30 seconds', () {
      check(skipForwardIconData(30)).equals(Symbols.forward_30);
    });

    test('returns null for 15 seconds (no dedicated icon)', () {
      check(skipForwardIconData(15)).isNull();
    });

    test('returns null for 45 seconds (no dedicated icon)', () {
      check(skipForwardIconData(45)).isNull();
    });

    test('returns null for 60 seconds (no dedicated icon)', () {
      check(skipForwardIconData(60)).isNull();
    });
  });

  group('skipBackwardIconData', () {
    test('returns replay_5 for 5 seconds', () {
      check(skipBackwardIconData(5)).equals(Symbols.replay_5);
    });

    test('returns replay_10 for 10 seconds', () {
      check(skipBackwardIconData(10)).equals(Symbols.replay_10);
    });

    test('returns replay_30 for 30 seconds', () {
      check(skipBackwardIconData(30)).equals(Symbols.replay_30);
    });

    test('returns null for 15 seconds (no dedicated icon)', () {
      check(skipBackwardIconData(15)).isNull();
    });
  });

  group('SkipDurationIcon', () {
    testWidgets('renders dedicated icon for 30s forward', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 30, isForward: true, size: 36),
          ),
        ),
      );

      final iconFinder = find.byIcon(Symbols.forward_30);
      check(iconFinder.evaluate()).isNotEmpty();
    });

    testWidgets('renders dedicated icon for 10s backward', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 10, isForward: false, size: 36),
          ),
        ),
      );

      final iconFinder = find.byIcon(Symbols.replay_10);
      check(iconFinder.evaluate()).isNotEmpty();
    });

    testWidgets('renders text label for 15s forward (no dedicated icon)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 15, isForward: true, size: 36),
          ),
        ),
      );

      // Should show the number as text
      check(find.text('15').evaluate()).isNotEmpty();
      // Should show the base forward icon
      check(find.byIcon(Symbols.forward).evaluate()).isNotEmpty();
    });

    testWidgets('renders text label for 45s forward (no dedicated icon)', (
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
      check(find.byIcon(Symbols.forward).evaluate()).isNotEmpty();
    });

    testWidgets('renders text label for 60s forward (no dedicated icon)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 60, isForward: true, size: 36),
          ),
        ),
      );

      check(find.text('60').evaluate()).isNotEmpty();
      check(find.byIcon(Symbols.forward).evaluate()).isNotEmpty();
    });

    testWidgets('renders text label for 15s backward (no dedicated icon)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 15, isForward: false, size: 36),
          ),
        ),
      );

      check(find.text('15').evaluate()).isNotEmpty();
      check(find.byIcon(Symbols.replay).evaluate()).isNotEmpty();
    });

    testWidgets('applies provided size to icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkipDurationIcon(seconds: 30, isForward: true, size: 48),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Symbols.forward_30));
      check(icon.size).equals(48);
    });

    testWidgets('applies provided color to icon', (tester) async {
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

      final icon = tester.widget<Icon>(find.byIcon(Symbols.replay_10));
      check(icon.color).equals(Colors.red);
    });
  });
}
