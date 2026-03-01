import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LayoutConstants', () {
    test('tabletBreakpoint is 600', () {
      expect(LayoutConstants.tabletBreakpoint, 600.0);
    });
    test('contentMaxWidth is 560', () {
      expect(LayoutConstants.contentMaxWidth, 560.0);
    });
    test('podcastGridItemWidth is 130', () {
      expect(LayoutConstants.podcastGridItemWidth, 130.0);
    });
    test('sidebarWidth is 280', () {
      expect(LayoutConstants.sidebarWidth, 280.0);
    });
  });
}
