import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? AppTheme.light(),
    home: Scaffold(body: ListView(children: [child])),
  );

  BoxDecoration surfaceDecoration(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find.byKey(GroupedSection.surfaceKey),
    );
    return box.decoration as BoxDecoration;
  }

  group('GroupedSection', () {
    testWidgets('draws rows on a rounded surface with the grouped shadow', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const GroupedSection(children: [Text('a'), Text('b')])),
      );
      final decoration = surfaceDecoration(tester);
      check(decoration.color).equals(AppColors.light.surface);
      check(decoration.borderRadius).equals(AppBorders.groupedSurface);
      check(
        decoration.boxShadow,
      ).isNotNull().deepEquals(AppShadows.groupedSurface);
    });

    testWidgets('separates rows with hairlines, none after the last', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const GroupedSection(children: [Text('a'), Text('b'), Text('c')])),
      );
      final dividers = tester.widgetList<Divider>(find.byType(Divider));
      check(dividers.length).equals(2);
      for (final divider in dividers) {
        check(divider.color).equals(AppColors.light.hairline);
        check(divider.height).equals(1);
      }
    });

    testWidgets('insets separators by separatorIndent', (tester) async {
      await tester.pumpWidget(
        host(
          const GroupedSection(
            separatorIndent: 60,
            children: [Text('a'), Text('b')],
          ),
        ),
      );
      check(tester.widget<Divider>(find.byType(Divider)).indent).equals(60);
    });

    testWidgets('single row has no separator', (tester) async {
      await tester.pumpWidget(
        host(const GroupedSection(children: [Text('only')])),
      );
      check(find.byType(Divider).evaluate().length).equals(0);
    });

    testWidgets('header renders in overline style, tertiary ink', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const GroupedSection(header: '再生', children: [Text('a')])),
      );
      final header = tester.widget<Text>(find.text('再生'));
      check(header.style!.fontWeight).equals(FontWeight.w600);
      check(
        header.style!.letterSpacing,
      ).equals(AppTextStyles.overline.letterSpacing);
      check(header.style!.color).equals(AppColors.light.inkTertiary);
      check(tester.getRect(find.text('再生')).bottom).isLessOrEqual(
        tester.getRect(find.byKey(GroupedSection.surfaceKey)).top,
      );
    });

    testWidgets('header is a semantics header', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const GroupedSection(header: 'Audio', children: [Text('a')])),
      );
      check(
        tester.getSemantics(find.text('Audio')).flagsCollection.isHeader,
      ).isTrue();
      handle.dispose();
    });

    testWidgets('footer renders below the surface', (tester) async {
      await tester.pumpWidget(
        host(
          const GroupedSection(
            footer: 'Explains the group',
            children: [Text('a')],
          ),
        ),
      );
      check(
        tester.getRect(find.text('Explains the group')).top,
      ).isGreaterOrEqual(
        tester.getRect(find.byKey(GroupedSection.surfaceKey)).bottom,
      );
    });

    testWidgets('uses the 20px screen gutter by default', (tester) async {
      await tester.pumpWidget(
        host(const GroupedSection(children: [Text('a')])),
      );
      final surface = tester.getRect(find.byKey(GroupedSection.surfaceKey));
      check(surface.left).equals(Spacing.screenHorizontal);
    });

    testWidgets('dark theme uses dark surface', (tester) async {
      await tester.pumpWidget(
        host(
          const GroupedSection(children: [Text('a')]),
          theme: AppTheme.dark(),
        ),
      );
      check(surfaceDecoration(tester).color).equals(AppColors.dark.surface);
    });
  });
}
