import 'package:audiflow_app/features/station/presentation/controllers/station_list_controller.dart';
import 'package:audiflow_app/features/station/presentation/screens/station_list_screen.dart';
import 'package:audiflow_app/features/station/presentation/widgets/station_grid_tile.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    Stream<List<Station>> Function() stations,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        // No automatic retry, so a failed load surfaces right away.
        retry: (_, _) => null,
        overrides: [stationListProvider.overrideWith((ref) => stations())],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StationListScreen(),
        ),
      ),
    );
  }

  testWidgets('shows progress while the stations load', (tester) async {
    await pump(tester, () => const Stream.empty());
    check(find.byType(CircularProgressIndicator).evaluate()).length.equals(1);
    check(find.byType(StationGridTile).evaluate()).isEmpty();
  });

  testWidgets('a failed load offers a retry that reloads', (tester) async {
    var attempts = 0;
    await pump(tester, () {
      attempts++;
      return attempts == 1
          ? Stream.error(Exception('db'))
          : Stream.value(<Station>[]);
    });
    await tester.pumpAndSettle();
    check(
      find.text("Couldn't load your stations.").evaluate(),
    ).length.equals(1);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    check(attempts).equals(2);
    check(find.text("Couldn't load your stations.").evaluate()).isEmpty();
  });
}
