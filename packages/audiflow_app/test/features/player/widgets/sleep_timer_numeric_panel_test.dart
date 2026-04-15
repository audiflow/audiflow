import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_numeric_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpPanel(
    WidgetTester tester, {
    int initial = 0,
    required int maxValue,
    required void Function(int) onStart,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SleepTimerNumericPanel(
            title: 'Minutes',
            initialValue: initial,
            maxValue: maxValue,
            startLabel: 'Start',
            onBack: () {},
            onClose: () {},
            onStart: onStart,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Start disabled when value is 0', (tester) async {
    var started = 0;
    await pumpPanel(tester, maxValue: 999, onStart: (v) => started = v);

    final startButton = find.widgetWithText(FilledButton, 'Start');
    expect(tester.widget<FilledButton>(startButton).onPressed, isNull);
    expect(started, 0);
  });

  testWidgets('digit buttons append and Start emits value', (tester) async {
    var started = 0;
    await pumpPanel(tester, maxValue: 999, onStart: (v) => started = v);

    await tester.tap(find.widgetWithText(TextButton, '3'));
    await tester.tap(find.widgetWithText(TextButton, '0'));
    await tester.pumpAndSettle();

    expect(find.text('30'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    expect(started, 30);
  });

  testWidgets('clamps typing beyond maxValue', (tester) async {
    await pumpPanel(tester, maxValue: 99, onStart: (_) {});

    await tester.tap(find.widgetWithText(TextButton, '9'));
    await tester.tap(find.widgetWithText(TextButton, '9'));
    await tester.tap(find.widgetWithText(TextButton, '9'));
    await tester.pumpAndSettle();

    expect(find.text('99'), findsOneWidget);
  });

  testWidgets('backspace removes last digit after typing', (tester) async {
    await pumpPanel(tester, initial: 0, maxValue: 999, onStart: (_) {});

    await tester.tap(find.widgetWithText(TextButton, '3'));
    await tester.tap(find.widgetWithText(TextButton, '0'));
    await tester.pumpAndSettle();
    expect(find.text('30'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();
    // Readout shows '3'; keypad also contains a '3' button, so expect 2.
    expect(find.text('30'), findsNothing);
    expect(find.text('3'), findsNWidgets(2));
  });

  testWidgets('first digit press replaces remembered value (pristine state)', (
    tester,
  ) async {
    var started = 0;
    await pumpPanel(
      tester,
      initial: 999,
      maxValue: 999,
      onStart: (v) => started = v,
    );
    expect(find.text('999'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '3'));
    await tester.pumpAndSettle();

    // Display is now just "3", not "9993" or "999" with a digit appended.
    expect(find.text('999'), findsNothing);
    // Readout '3' + keypad button '3'.
    expect(find.text('3'), findsNWidgets(2));

    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    expect(started, 3);
  });

  testWidgets('first backspace clears remembered value (pristine state)', (
    tester,
  ) async {
    await pumpPanel(tester, initial: 30, maxValue: 999, onStart: (_) {});
    expect(find.text('30'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();
    // After pristine backspace, display is empty -> rendered as '0'.
    expect(find.text('30'), findsNothing);
  });
}
