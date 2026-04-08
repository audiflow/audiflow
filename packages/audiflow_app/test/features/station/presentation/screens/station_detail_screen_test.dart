// Station detail screen widget tests.
//
// Why limited scope: The popup menu lives inside _StationDetailContent, which
// is only built when stationByIdProvider emits a non-null Station. That widget
// also calls stationReconcilerServiceProvider (requires live Isar) and
// feedSyncServiceProvider (requires Ref + Logger) in initState as
// fire-and-forget futures. Without a real Isar instance the service
// providers cannot be constructed, so those tests would need full
// integration-test infrastructure. The tests below cover the two paths that
// do NOT require the heavy providers.
import 'package:audiflow_app/features/station/presentation/controllers/station_detail_controller.dart';
import 'package:audiflow_app/features/station/presentation/screens/station_detail_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testStationId = 1;

  Widget buildWidget({
    Stream<Station?> stationStream = const Stream.empty(),
    Stream<List<StationEpisode>> episodesStream = const Stream.empty(),
  }) {
    return ProviderScope(
      overrides: [
        stationByIdProvider.overrideWith((ref, id) => stationStream),
        stationEpisodesProvider.overrideWith((ref, id) => episodesStream),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StationDetailScreen(stationId: testStationId),
      ),
    );
  }

  group('StationDetailScreen', () {
    group('not found state', () {
      testWidgets('renders not-found scaffold when station is null', (
        tester,
      ) async {
        await tester.pumpWidget(buildWidget(stationStream: Stream.value(null)));
        await tester.pump();

        check(find.byType(Scaffold).evaluate()).isNotEmpty();
      });

      testWidgets('shows go back button when station is null', (tester) async {
        await tester.pumpWidget(buildWidget(stationStream: Stream.value(null)));
        await tester.pump();

        // Locate localizations via a Scaffold descendant inside the widget tree.
        final l10n = AppLocalizations.of(
          tester.element(find.byType(Scaffold).last),
        );
        check(find.text(l10n.commonGoBack).evaluate()).isNotEmpty();
      });
    });

    group('loading state', () {
      testWidgets('renders loading indicator while station stream is pending', (
        tester,
      ) async {
        // A stream that never emits keeps the provider in AsyncLoading state.
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        check(find.byType(CircularProgressIndicator).evaluate()).isNotEmpty();
      });
    });
  });
}
