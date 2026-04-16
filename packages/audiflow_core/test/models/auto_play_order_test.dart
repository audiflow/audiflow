import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutoPlayOrder', () {
    test('has exactly three values', () {
      expect(AutoPlayOrder.values.length, equals(3));
    });

    test('defaultOrder is the first value', () {
      expect(AutoPlayOrder.values[0], AutoPlayOrder.defaultOrder);
    });

    test('oldestFirst is the second value', () {
      expect(AutoPlayOrder.values[1], AutoPlayOrder.oldestFirst);
    });

    test('asDisplayed is the third value', () {
      expect(AutoPlayOrder.values[2], AutoPlayOrder.asDisplayed);
    });
  });
}
