import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_filter_chips.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_list_section.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/podcast_detail_sticky_bar.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SmartPlaylist _playlist(String id, String name) =>
    SmartPlaylist(id: id, displayName: name, sortKey: 0, episodeIds: const []);

void main() {
  final regular = _playlist('regular', 'Regular series');
  final shorts = _playlist('short', 'Short series');

  Future<_Log> pump(
    WidgetTester tester, {
    bool showModeSwitch = true,
    PodcastViewMode mode = PodcastViewMode.episodes,
    List<SmartPlaylist>? playlists,
    int? seriesCount,
  }) async {
    final log = _Log();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PodcastDetailStickyBar(
            showModeSwitch: showModeSwitch,
            mode: mode,
            onModeChanged: log.modes.add,
            playlists: playlists ?? [regular, shorts],
            selectedPlaylist: regular,
            onPlaylistSelected: log.playlists.add,
            filter: EpisodeFilter.all,
            onFilterSelected: log.filters.add,
            sortOrder: SortOrder.descending,
            onToggleSortOrder: () => log.sortToggles++,
            seriesCount: seriesCount,
          ),
        ),
      ),
    );
    return log;
  }

  group('PodcastDetailStickyBar', () {
    testWidgets('switches between episodes and series', (tester) async {
      final log = await pump(tester);
      check(
        find.byType(AppSegmentedControl<PodcastViewMode>).evaluate(),
      ).length.equals(1);
      await tester.tap(find.text('Series'));
      check(log.modes).deepEquals([PodcastViewMode.smartPlaylists]);
    });

    testWidgets('omits the switch for podcasts without series', (tester) async {
      await pump(tester, showModeSwitch: false);
      check(
        find.byType(AppSegmentedControl<PodcastViewMode>).evaluate(),
      ).isEmpty();
      check(find.byType(EpisodeFilterChips).evaluate()).length.equals(1);
    });

    testWidgets('episodes row has filter chips and the sort toggle', (
      tester,
    ) async {
      final log = await pump(tester);
      check(find.byType(EpisodeFilterChips).evaluate()).length.equals(1);
      check(find.text('Regular series').evaluate()).isEmpty();
      await tester.tap(find.byType(SortOrderButton));
      check(log.sortToggles).equals(1);
    });

    testWidgets('series row has the series-type dropdown, no chips', (
      tester,
    ) async {
      final log = await pump(tester, mode: PodcastViewMode.smartPlaylists);
      check(find.byType(EpisodeFilterChips).evaluate()).isEmpty();
      check(find.byType(SortOrderButton).evaluate()).length.equals(1);
      await tester.tap(find.text('Regular series'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Short series').last);
      await tester.pumpAndSettle();
      check(log.playlists.map((p) => p.id)).deepEquals(['short']);
    });

    testWidgets('series row shows the count before the sort toggle', (
      tester,
    ) async {
      await pump(tester, mode: PodcastViewMode.smartPlaylists, seriesCount: 50);
      final count = tester.getCenter(find.text('50 series ·'));
      final sort = tester.getCenter(find.byType(SortOrderButton));
      check(count.dx).isLessThan(sort.dx);
    });

    testWidgets('a single series type shows as a plain label', (tester) async {
      await pump(
        tester,
        mode: PodcastViewMode.smartPlaylists,
        playlists: [regular],
      );
      check(find.text('Regular series').evaluate()).length.equals(1);
      check(find.byIcon(Icons.expand_more_rounded).evaluate()).isEmpty();
    });
  });
}

class _Log {
  final modes = <PodcastViewMode>[];
  final playlists = <SmartPlaylist>[];
  final filters = <EpisodeFilter>[];
  var sortToggles = 0;
}
