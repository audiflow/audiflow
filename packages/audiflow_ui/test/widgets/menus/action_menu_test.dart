import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    required List<String> log,
    double top = 100,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showActionMenu(
                  context: context,
                  top: top,
                  tiles: [
                    ActionMenuEntry(
                      icon: Icons.remove_circle_outline,
                      label: 'Unsubscribe',
                      onSelected: () => log.add('unsubscribe'),
                    ),
                    ActionMenuEntry(
                      icon: Icons.ios_share,
                      label: 'Share',
                      onSelected: () => log.add('share'),
                    ),
                  ],
                  sections: [
                    [
                      ActionMenuEntry(
                        icon: Icons.sort,
                        label: 'Play order',
                        onSelected: () => log.add('order'),
                      ),
                    ],
                    [
                      ActionMenuEntry(
                        icon: Icons.link,
                        label: 'Website',
                        onSelected: () => log.add('web'),
                      ),
                    ],
                  ],
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('showActionMenu', () {
    testWidgets('shows tiles side by side above the item rows', (tester) async {
      await open(tester, log: []);
      final unsubscribe = tester.getCenter(find.text('Unsubscribe'));
      final share = tester.getCenter(find.text('Share'));
      final order = tester.getCenter(find.text('Play order'));
      check(share.dy).equals(unsubscribe.dy);
      check(unsubscribe.dx).isLessThan(share.dx);
      check(unsubscribe.dy).isLessThan(order.dy);
      check(
        find.byType(Divider).evaluate(),
      ).length.equals(2); // after the tiles, and between the sections
    });

    testWidgets('sits under the given top edge on a floating surface', (
      tester,
    ) async {
      await open(tester, log: [], top: 120);
      final surface = find.byKey(ActionMenu.surfaceKey);
      check(tester.getTopRight(surface).dy).isGreaterOrEqual(120);
      final decoration =
          tester.widget<DecoratedBox>(surface).decoration as BoxDecoration;
      check(decoration.color).equals(AppColors.light.surface);
      check(decoration.boxShadow).isNotNull().deepEquals(AppShadows.floating);
    });

    testWidgets('selecting an entry closes the menu, then runs it', (
      tester,
    ) async {
      final log = <String>[];
      await open(tester, log: log);
      await tester.tap(find.text('Play order'));
      await tester.pumpAndSettle();
      check(log).deepEquals(['order']);
      check(find.text('Play order').evaluate()).isEmpty();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();
      check(log).deepEquals(['order', 'share']);
    });

    testWidgets('tapping outside dismisses without running anything', (
      tester,
    ) async {
      final log = <String>[];
      await open(tester, log: log);
      await tester.tapAt(const Offset(10, 580));
      await tester.pumpAndSettle();
      check(find.text('Play order').evaluate()).isEmpty();
      check(log).isEmpty();
    });
  });
}
