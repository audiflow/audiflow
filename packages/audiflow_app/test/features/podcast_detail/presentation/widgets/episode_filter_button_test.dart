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
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(ActionMenu.surfaceKey),
              matching: find.byType(Text),
            ),
          )
          .map((text) => text.data)
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
              of: find.byKey(ActionMenu.surfaceKey),
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

    testWidgets('press, slide to a filter, and release chooses it', (
      tester,
    ) async {
      final chosen = await pump(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(EpisodeFilterButton)),
      );
      await tester.pump(
        ActionMenuTrigger.holdDuration + const Duration(milliseconds: 10),
      );
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(find.text('Downloaded')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(chosen).deepEquals([EpisodeFilter.downloaded]);
      check(find.byKey(ActionMenu.surfaceKey).evaluate()).isEmpty();
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
