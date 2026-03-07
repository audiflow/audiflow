import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutoPlayOrder', () {
    test('has exactly two values', () {
      expect(AutoPlayOrder.values.length, equals(2));
    });

    test('oldestFirst is the first value', () {
      expect(AutoPlayOrder.values.first, AutoPlayOrder.oldestFirst);
    });

    test('asDisplayed is the second value', () {
      expect(AutoPlayOrder.values.last, AutoPlayOrder.asDisplayed);
    });
  });
}
