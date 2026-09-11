import 'dart:async';

import 'package:audiflow_app/features/onboarding/presentation/screens/migration_guide_screen.dart';
import 'package:audiflow_app/features/settings/presentation/controllers/opml_import_controller.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// Records import launches without touching the gate or the file picker.
///
/// [pending] stands in for the gate, the picker, and the parse, so a test can
/// hold the flow open and tap again while it is still running.
class _FakeOpmlImportController extends OpmlImportController {
  _FakeOpmlImportController({this.pending});

  final Future<void>? pending;
  int startCount = 0;

  @override
  OpmlPickResult build() => OpmlPickIdle();

  @override
  Future<bool> pickAndParse(BuildContext context) async {
    startCount++;
    final inFlight = pending;
    if (inFlight != null) await inFlight;
    return true;
  }
}

void main() {
  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(MigrationGuideScreen)));

  group('MigrationGuideScreen', () {
    testWidgets('offers an import action without scrolling', (tester) async {
      await tester.pumpApp(const MigrationGuideScreen());
      await tester.pumpAndSettle();

      final l10n = l10nOf(tester);
      check(find.text(l10n.migrationImportCtaTitle).evaluate()).isNotEmpty();
      check(find.text(l10n.migrationImportCtaButton).evaluate()).isNotEmpty();
    });

    testWidgets('repeats the action and names where import lives at the end', (
      tester,
    ) async {
      await tester.pumpApp(const MigrationGuideScreen());
      await tester.pumpAndSettle();

      final l10n = l10nOf(tester);
      await tester.scrollUntilVisible(
        find.text(l10n.migrationImportLocationHint),
        400,
      );
      await tester.pumpAndSettle();

      check(
        find.text(l10n.migrationImportLocationHint).evaluate(),
      ).isNotEmpty();
      check(find.text(l10n.migrationImportCtaButton).evaluate()).isNotEmpty();
    });

    testWidgets('tapping the action starts the import', (tester) async {
      final fake = _FakeOpmlImportController();

      await tester.pumpApp(
        const MigrationGuideScreen(),
        overrides: [opmlImportControllerProvider.overrideWith(() => fake)],
      );
      await tester.pumpAndSettle();

      final l10n = l10nOf(tester);
      await tester.tap(find.text(l10n.migrationImportCtaButton).first);
      await tester.pumpAndSettle();

      check(fake.startCount).equals(1);
    });

    testWidgets('ignores a second tap while an import is in flight', (
      tester,
    ) async {
      final inFlight = Completer<void>();
      final fake = _FakeOpmlImportController(pending: inFlight.future);

      await tester.pumpApp(
        const MigrationGuideScreen(),
        overrides: [opmlImportControllerProvider.overrideWith(() => fake)],
      );
      await tester.pumpAndSettle();

      final l10n = l10nOf(tester);
      final button = find.text(l10n.migrationImportCtaButton).first;

      await tester.tap(button);
      await tester.pump();
      await tester.tap(button);
      await tester.pump();

      check(fake.startCount).equals(1);

      inFlight.complete();
      await tester.pumpAndSettle();
    });
  });
}
