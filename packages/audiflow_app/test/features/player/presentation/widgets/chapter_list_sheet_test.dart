import 'package:audiflow_app/features/player/presentation/widgets/chapter_list_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

EpisodeChapter _chapter(int index) => EpisodeChapter()
  ..id = index + 1
  ..episodeId = 1
  ..sortOrder = index
  ..title = 'Chapter title ${index + 1}'
  ..startMs = Duration(minutes: index).inMilliseconds;

final _chapters = List.generate(40, _chapter);

class _CurrentIndex extends Notifier<int?> {
  @override
  int? build() => 30;

  void set(int? value) => state = value;
}

final _currentIndexProvider = NotifierProvider<_CurrentIndex, int?>(
  _CurrentIndex.new,
);

Widget _buildSheet({ThemeData? theme}) {
  return ProviderScope(
    overrides: [
      currentEpisodeChaptersProvider.overrideWith(
        (ref) => Stream.value(_chapters),
      ),
      currentChapterProvider.overrideWith((ref) {
        final index = ref.watch(_currentIndexProvider);
        if (index == null) return null;
        return CurrentChapter(index: index, chapter: _chapters[index]);
      }),
    ],
    child: MaterialApp(
      theme: theme ?? AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        // Short enough that most of the 40 chapters are off screen.
        body: SizedBox(
          height: 400,
          child: ChapterListSheet(onChapterSelected: (_) {}),
        ),
      ),
    ),
  );
}

Finder _tileOf(int index) => find.ancestor(
  of: find.text('Chapter title ${index + 1}'),
  matching: find.byType(ListTile),
);

ListTile _tile(WidgetTester tester, int index) =>
    tester.widget<ListTile>(_tileOf(index));

Finder _playingIconIn(int index) => find.descendant(
  of: _tileOf(index),
  matching: find.byIcon(Symbols.graphic_eq),
);

void main() {
  group('ChapterListSheet', () {
    testWidgets('opens scrolled so the current chapter is visible', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      check(
        find.text('Chapter title 31').hitTestable().evaluate(),
      ).isNotEmpty();
      check(find.text('Chapter title 1').hitTestable().evaluate()).isEmpty();
    });

    testWidgets('stays at the top when no chapter is current', (tester) async {
      await tester.pumpWidget(_buildSheet());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ChapterListSheet)),
      );
      container.read(_currentIndexProvider.notifier).set(null);
      await tester.pumpAndSettle();

      check(find.text('Chapter title 1').hitTestable().evaluate()).isNotEmpty();
    });

    for (final (name, theme, colors) in [
      ('light', AppTheme.light(), AppColors.light),
      ('dark', AppTheme.dark(), AppColors.dark),
    ]) {
      testWidgets('tints the current chapter with the accent ($name)', (
        tester,
      ) async {
        await tester.pumpWidget(_buildSheet(theme: theme));
        await tester.pumpAndSettle();

        final current = _tile(tester, 30);
        check(current.selected).isTrue();
        check(current.selectedTileColor).equals(colors.accentTint);
        check(current.selectedColor).equals(colors.accent);
        check(_playingIconIn(30).evaluate()).isNotEmpty();

        final title = tester.widget<Text>(find.text('Chapter title 31'));
        check(title.style?.fontWeight).equals(FontWeight.w600);
      });
    }

    testWidgets('marks other chapters plainly', (tester) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      check(_tile(tester, 29).selected).isFalse();
      check(_playingIconIn(29).evaluate()).isEmpty();
      final number = find.descendant(
        of: _tileOf(29),
        matching: find.text('30'),
      );
      check(number.evaluate()).isNotEmpty();
    });

    testWidgets('highlight follows playback while open', (tester) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ChapterListSheet)),
      );

      container.read(_currentIndexProvider.notifier).set(31);
      await tester.pumpAndSettle();

      check(_tile(tester, 31).selected).isTrue();
      check(_tile(tester, 30).selected).isFalse();
      check(_playingIconIn(31).evaluate()).isNotEmpty();
      check(_playingIconIn(30).evaluate()).isEmpty();
    });

    testWidgets('exposes the current chapter as selected to screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(_tileOf(30)),
        matchesSemantics(
          label: 'Chapter 31: Chapter title 31, starts at 30:00',
          isSelected: true,
          hasSelectedState: true,
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });
}
