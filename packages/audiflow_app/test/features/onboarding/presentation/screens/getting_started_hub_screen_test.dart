import 'package:audiflow_app/features/onboarding/presentation/screens/getting_started_hub_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(GettingStartedHubScreen)));

  group('GettingStartedHubScreen', () {
    testWidgets('lists the tiles that have a real destination', (tester) async {
      await tester.pumpApp(const GettingStartedHubScreen());
      await tester.pumpAndSettle();

      final l10n = l10nOf(tester);
      check(find.text(l10n.gettingStartedMigrateTitle).evaluate()).isNotEmpty();
      check(find.text(l10n.gettingStartedSearchTitle).evaluate()).isNotEmpty();
      check(
        find.text(l10n.gettingStartedStationsTitle).evaluate(),
      ).isNotEmpty();
      check(
        find.text(l10n.gettingStartedReplayCarousel).evaluate(),
      ).isNotEmpty();
    });

    testWidgets('hides the smart playlists tile while it has no destination', (
      tester,
    ) async {
      await tester.pumpApp(const GettingStartedHubScreen());
      await tester.pumpAndSettle();

      final l10n = l10nOf(tester);
      check(
        find.text(l10n.gettingStartedSmartPlaylistsTitle).evaluate(),
      ).isEmpty();
    });
  });
}
