import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Column(children: [child])),
  );

  group('LargeTitle', () {
    testWidgets('left-aligned displayTitle in ink, marked as header', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const LargeTitle('Library')));
      final text = tester.widget<Text>(find.text('Library'));
      check(text.style!.fontSize).equals(AppTextStyles.displayTitle.fontSize);
      check(text.style!.color).equals(AppColors.light.ink);
      check(
        tester.getTopLeft(find.text('Library')).dx,
      ).equals(Spacing.screenHorizontal);
      check(
        tester.getSemantics(find.text('Library')).flagsCollection.isHeader,
      ).isTrue();
      handle.dispose();
    });
  });

  group('SectionHeader', () {
    testWidgets('sectionTitle on the left, trailing on the right', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SectionHeader(
            title: 'Stations',
            trailing: Icon(Icons.add, key: ValueKey('trailing')),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text('Stations'));
      check(text.style!.fontSize).equals(AppTextStyles.sectionTitle.fontSize);
      check(
        tester.getTopLeft(find.text('Stations')).dx,
      ).equals(Spacing.screenHorizontal);
      final screenWidth = tester.getSize(find.byType(Scaffold)).width;
      check(
        tester.getTopRight(find.byKey(const ValueKey('trailing'))).dx,
      ).isLessOrEqual(screenWidth - Spacing.screenHorizontal + 1e-6);
    });
  });
}
