import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_app/features/station/presentation/controllers/station_detail_controller.dart';
import 'package:audiflow_app/features/station/presentation/widgets/station_grid_sliver.dart';
import 'package:audiflow_app/features/station/presentation/widgets/station_grid_tile.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Station _station(int id) => Station()
  ..id = id
  ..name = 'Station $id'
  ..createdAt = DateTime(2026)
  ..updatedAt = DateTime(2026);

void main() {
  Future<void> pump(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          librarySubscriptionsProvider.overrideWith(
            (ref) => Stream.value(const []),
          ),
          stationPodcastsProvider.overrideWith(
            (ref, id) => Stream.value(const []),
          ),
          stationEpisodesProvider.overrideWith(
            (ref, id) => Stream.value(const []),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                StationGridSliver(
                  stations: [for (var id = 1; id <= 4; id++) _station(id)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  // Tiles sharing the first tile's top edge form the first row.
  int firstRowTiles(WidgetTester tester) {
    final tops = find
        .byType(StationGridTile)
        .evaluate()
        .map((e) => tester.getTopLeft(find.byWidget(e.widget)).dy)
        .toList();
    return tops.where((top) => top == tops.first).length;
  }

  group('StationGridSliver', () {
    testWidgets('lays out two columns on a phone', (tester) async {
      await pump(tester, 390);
      check(firstRowTiles(tester)).equals(2);
    });

    testWidgets('fits as many tiles as keep the minimum width on a tablet', (
      tester,
    ) async {
      await pump(tester, 820);
      check(firstRowTiles(tester)).equals(4);
      check(
        tester.getSize(find.byType(StationGridTile).first).width,
      ).isGreaterOrEqual(LayoutConstants.stationGridItemWidth);
    });
  });
}
