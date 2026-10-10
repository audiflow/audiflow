import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberEntry', () {
    test('starts with the initial value, or empty for 0', () {
      expect(NumberEntry.initial(12).text, '12');
      expect(NumberEntry.initial(0).text, '');
      expect(NumberEntry.initial(0).value, 0);
    });

    test('the first digit replaces a pre-filled value', () {
      final entry = NumberEntry.initial(12).appendDigit('7', maxValue: 99);
      expect(entry.value, 7);
    });

    test('later digits append', () {
      final entry = NumberEntry.initial(
        0,
      ).appendDigit('1', maxValue: 99).appendDigit('5', maxValue: 99);
      expect(entry.value, 15);
    });

    test('a leading zero is ignored', () {
      final entry = NumberEntry.initial(0).appendDigit('0', maxValue: 99);
      expect(entry.text, '');
    });

    test('digits past maxValue are rejected', () {
      final entry = NumberEntry.initial(
        0,
      ).appendDigit('9', maxValue: 99).appendDigit('9', maxValue: 99);
      expect(entry.appendDigit('1', maxValue: 99).value, 99);
    });

    test('backspace on a pre-filled value clears it', () {
      expect(NumberEntry.initial(12).backspace().text, '');
    });

    test('backspace removes the last typed digit', () {
      final entry = NumberEntry.initial(
        0,
      ).appendDigit('4', maxValue: 99).appendDigit('2', maxValue: 99);
      expect(entry.backspace().value, 4);
    });
  });

  group('NumberKeypad', () {
    testWidgets('reports digits and backspace', (tester) async {
      final digits = <String>[];
      var backspaces = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberKeypad(
              onDigit: digits.add,
              onBackspace: () => backspaces++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('3'));
      await tester.tap(find.text('0'));
      await tester.tap(find.byTooltip('Delete'));

      expect(digits, ['3', '0']);
      expect(backspaces, 1);
    });
  });
}
