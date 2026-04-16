import 'package:audiflow_app/features/podcast_detail/presentation/widgets/play_order_bottom_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('PlayOrderBottomSheet', () {
    testWidgets('shows three radio options', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showPlayOrderBottomSheet(
                context: context,
                currentOrder: AutoPlayOrder.defaultOrder,
                resolvedParentOrder: AutoPlayOrder.oldestFirst,
                onOrderSelected: (_) {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      check(
        find.text('Play order'),
      ).has((f) => f.evaluate().length, 'widget count').equals(1);
      check(
        find.text('Default (Oldest first)'),
      ).has((f) => f.evaluate().length, 'widget count').equals(1);
      check(
        find.text('Oldest first'),
      ).has((f) => f.evaluate().length, 'widget count').equals(1);
      check(
        find.text('As displayed'),
      ).has((f) => f.evaluate().length, 'widget count').equals(1);
      check(
        find.byType(RadioListTile<AutoPlayOrder>),
      ).has((f) => f.evaluate().length, 'radio count').equals(3);
    });

    testWidgets('pre-selects current order', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showPlayOrderBottomSheet(
                context: context,
                currentOrder: AutoPlayOrder.asDisplayed,
                resolvedParentOrder: AutoPlayOrder.oldestFirst,
                onOrderSelected: (_) {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final radioGroup = tester.widget<RadioGroup<AutoPlayOrder>>(
        find.byType(RadioGroup<AutoPlayOrder>),
      );
      check(radioGroup.groupValue).equals(AutoPlayOrder.asDisplayed);
    });

    testWidgets('calls onOrderSelected on tap and closes sheet', (
      tester,
    ) async {
      AutoPlayOrder? selected;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showPlayOrderBottomSheet(
                context: context,
                currentOrder: AutoPlayOrder.defaultOrder,
                resolvedParentOrder: AutoPlayOrder.oldestFirst,
                onOrderSelected: (order) => selected = order,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Oldest first'));
      await tester.pumpAndSettle();

      check(selected).equals(AutoPlayOrder.oldestFirst);
      // Sheet should be closed
      check(find.text('Play order').evaluate().length).equals(0);
    });
  });
}
