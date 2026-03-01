import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveGrid.columnCount', () {
    test('returns 3 for phone width (~390dp)', () {
      expect(ResponsiveGrid.columnCount(availableWidth: 390), 3);
    });
    test('returns 5 for tablet portrait (~744dp)', () {
      expect(ResponsiveGrid.columnCount(availableWidth: 744), 5);
    });
    test('returns at least 2 for very narrow width', () {
      expect(ResponsiveGrid.columnCount(availableWidth: 100), 2);
    });
    test('respects custom itemWidth', () {
      expect(
        ResponsiveGrid.columnCount(availableWidth: 600, itemWidth: 200),
        3,
      );
    });
  });
}
