import 'package:audiflow_app/features/station/presentation/widgets/episode_limit_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> events;

  setUp(() => events = []);

  Future<void> pumpSheet(
    WidgetTester tester, {
    EpisodeLimitMode mode = EpisodeLimitMode.latest,
    int count = 3,
    bool withDefault = false,
    Size size = const Size(400, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EpisodeLimitSheet(
            subtitle: 'Daily Show',
            initialMode: mode,
            initialCount: count,
            defaultLabel: withDefault ? 'Default (3)' : null,
            onDefault: withDefault ? () => events.add('default') : null,
            onAll: () => events.add('all'),
            onLatest: (n) => events.add('latest $n'),
          ),
        ),
      ),
    );
  }

  Finder setButton() => find.widgetWithText(FilledButton, 'Set');
  bool setEnabled(WidgetTester tester) =>
      tester.widget<FilledButton>(setButton()).onPressed != null;

  testWidgets('the station-wide sheet has no Default segment', (tester) async {
    await pumpSheet(tester);

    check(find.text('All').evaluate()).length.equals(1);
    check(find.text('Latest N').evaluate()).length.equals(1);
    check(find.text('Default (3)').evaluate()).isEmpty();
  });

  testWidgets('tapping All saves at once', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('All'));

    check(events).deepEquals(['all']);
  });

  testWidgets('tapping Default saves at once', (tester) async {
    await pumpSheet(tester, withDefault: true);

    await tester.tap(find.text('Default (3)'));

    check(events).deepEquals(['default']);
  });

  testWidgets('a short window scrolls to reach Set', (tester) async {
    await pumpSheet(tester, size: const Size(400, 320));

    await tester.ensureVisible(setButton());
    await tester.pump();
    await tester.tap(setButton());

    check(tester.takeException()).isNull();
    check(events).deepEquals(['latest 3']);
  });

  testWidgets('a typed count saves with Set', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(setButton());

    check(events).deepEquals(['latest 7']);
  });

  testWidgets('typing while All is selected switches to Latest N', (
    tester,
  ) async {
    await pumpSheet(tester, mode: EpisodeLimitMode.all);
    check(setEnabled(tester)).isFalse();

    await tester.tap(find.text('1'));
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(setButton());

    check(events).deepEquals(['latest 15']);
  });

  testWidgets('Set is disabled while the count is empty', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pump();

    check(setEnabled(tester)).isFalse();
  });

  testWidgets('counts stop at two digits', (tester) async {
    await pumpSheet(tester);

    for (final digit in ['9', '9', '9']) {
      await tester.tap(find.text(digit).last);
    }
    await tester.pump();
    await tester.tap(setButton());

    check(events).deepEquals(['latest 99']);
  });

  testWidgets('re-tapping Latest N only selects it', (tester) async {
    await pumpSheet(tester, mode: EpisodeLimitMode.all);

    await tester.tap(find.text('Latest N'));
    await tester.pump();

    check(events).isEmpty();
    check(setEnabled(tester)).isTrue();
    check(
      tester
          .widget<AppSegmentedControl<EpisodeLimitMode>>(
            find.byType(AppSegmentedControl<EpisodeLimitMode>),
          )
          .selected,
    ).equals(EpisodeLimitMode.latest);
  });

  testWidgets('the number box stays centered as digits are added', (
    tester,
  ) async {
    await pumpSheet(tester);
    final box = find.byKey(EpisodeLimitSheet.numberBoxKey);
    final sheetCenter = tester.getCenter(find.byType(EpisodeLimitSheet)).dx;
    check(tester.getCenter(box).dx).equals(sheetCenter);

    await tester.tap(find.text('1'));
    await tester.tap(find.text('5'));
    await tester.pump();

    check(tester.getCenter(box).dx).equals(sheetCenter);
  });

  testWidgets('the unit sits on the digits baseline', (tester) async {
    await pumpSheet(tester);

    final row = tester.widget<Row>(
      find
          .ancestor(
            of: find.byKey(EpisodeLimitSheet.numberBoxKey),
            matching: find.byType(Row),
          )
          .first,
    );
    check(row.crossAxisAlignment).equals(CrossAxisAlignment.baseline);
    check(row.textBaseline).equals(TextBaseline.alphabetic);
  });
}
