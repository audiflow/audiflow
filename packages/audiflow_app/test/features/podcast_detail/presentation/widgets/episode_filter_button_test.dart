import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_filter_button.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart' show EpisodeFilter;
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const labels = ['All', 'Unplayed', 'In Progress', 'Played', 'Downloaded'];

  Future<List<EpisodeFilter>> pump(
    WidgetTester tester, {
    EpisodeFilter selected = EpisodeFilter.all,
    Locale locale = const Locale('en'),
  }) async {
    final chosen = <EpisodeFilter>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: EpisodeFilterButton(
              selected: selected,
              onSelected: chosen.add,
            ),
          ),
        ),
      ),
    );
    return chosen;
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byType(EpisodeFilterButton));
    await tester.pumpAndSettle();
  }

  group('EpisodeFilterButton', () {
    testWidgets('shows the current filter', (tester) async {
      await pump(tester, selected: EpisodeFilter.played);
      check(find.text('Played').evaluate()).length.equals(1);
      check(find.text('All').evaluate()).isEmpty();
      check(find.byIcon(Icons.expand_more_rounded).evaluate()).length.equals(1);
    });

    testWidgets('menu lists all five filters in order', (tester) async {
      await pump(tester);
      await openMenu(tester);
      final items = tester
          .widgetList<PopupMenuItem<int>>(find.byType(PopupMenuItem<int>))
          .map((item) => ((item.child! as Text).data))
          .toList();
      check(items).deepEquals(labels);
    });

    testWidgets('marks the current filter in the accent color', (tester) async {
      await pump(tester, selected: EpisodeFilter.downloaded);
      await openMenu(tester);
      final context = tester.element(find.byType(EpisodeFilterButton));
      final accent = AppColors.of(context).accent;
      Color? colorOf(String label) => tester
          .widget<Text>(
            find.descendant(
              of: find.byType(PopupMenuItem<int>),
              matching: find.text(label),
            ),
          )
          .style
          ?.color;
      check(colorOf('Downloaded')).equals(accent);
      check(colorOf('Unplayed')).not((it) => it.equals(accent));
    });

    testWidgets('reports the chosen filter', (tester) async {
      final chosen = await pump(tester);
      await openMenu(tester);
      await tester.tap(find.text('Played').last);
      await tester.pumpAndSettle();
      check(chosen).deepEquals([EpisodeFilter.played]);
    });

    testWidgets('dismissing the menu reports nothing', (tester) async {
      final chosen = await pump(tester);
      await openMenu(tester);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      check(chosen).isEmpty();
    });

    testWidgets('uses Japanese labels', (tester) async {
      await pump(tester, locale: const Locale('ja'));
      await openMenu(tester);
      check(find.text('再生済み').evaluate()).isNotEmpty();
      check(find.text('ダウンロード済み').evaluate()).isNotEmpty();
    });
  });
}
