import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberEntry', () {
    test('starts with the initial value, or empty for 0', () {
      check(NumberEntry.initial(12).text).equals('12');
      check(NumberEntry.initial(0).text).equals('');
      check(NumberEntry.initial(0).value).equals(0);
    });

    test('the first digit replaces a pre-filled value', () {
      final entry = NumberEntry.initial(12).appendDigit('7', maxValue: 99);
      check(entry.value).equals(7);
    });

    test('later digits append', () {
      final entry = NumberEntry.initial(
        0,
      ).appendDigit('1', maxValue: 99).appendDigit('5', maxValue: 99);
      check(entry.value).equals(15);
    });

    test('a leading zero is ignored', () {
      final entry = NumberEntry.initial(0).appendDigit('0', maxValue: 99);
      check(entry.text).equals('');
    });

    test('digits past maxValue are rejected', () {
      final entry = NumberEntry.initial(
        0,
      ).appendDigit('9', maxValue: 99).appendDigit('9', maxValue: 99);
      check(entry.appendDigit('1', maxValue: 99).value).equals(99);
    });

    test('backspace on a pre-filled value clears it', () {
      check(NumberEntry.initial(12).backspace().text).equals('');
    });

    test('backspace removes the last typed digit', () {
      final entry = NumberEntry.initial(
        0,
      ).appendDigit('4', maxValue: 99).appendDigit('2', maxValue: 99);
      check(entry.backspace().value).equals(4);
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

      check(digits).deepEquals(['3', '0']);
      check(backspaces).equals(1);
    });
  });
}
