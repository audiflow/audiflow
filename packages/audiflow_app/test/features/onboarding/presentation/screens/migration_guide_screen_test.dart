import 'package:audiflow_app/features/onboarding/presentation/screens/migration_guide_screen.dart';
import 'package:audiflow_app/features/settings/presentation/controllers/opml_import_controller.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// Records import launches without touching the gate or the file picker.
class _FakeOpmlImportController extends OpmlImportController {
  int startCount = 0;

  @override
  OpmlPickResult build() => OpmlPickIdle();

  @override
  Future<bool> pickAndParse(BuildContext context) async {
    startCount++;
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
  });
}
