import 'package:audiflow_app/features/player/presentation/widgets/chapter_list_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

String _title(int index) => 'Chapter title ${index + 1}';

EpisodeChapter _chapter(int index) => EpisodeChapter()
  ..id = index + 1
  ..episodeId = 1
  ..sortOrder = index
  ..title = _title(index)
  ..startMs = Duration(minutes: index).inMilliseconds;

final _chapters = List.generate(40, _chapter);

/// Far enough down that the sheet must scroll to show it.
const _current = 30;

class _CurrentIndex extends Notifier<int?> {
  _CurrentIndex(this._initial);

  final int? _initial;

  @override
  int? build() => _initial;

  void set(int? value) => state = value;
}

final _currentIndexProvider = NotifierProvider<_CurrentIndex, int?>(
  () => _CurrentIndex(_current),
);

Widget _buildSheet({ThemeData? theme, int? initialIndex = _current}) {
  return ProviderScope(
    overrides: [
      _currentIndexProvider.overrideWith(() => _CurrentIndex(initialIndex)),
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
  of: find.text(_title(index)),
  matching: find.byType(ListTile),
);

ListTile _tile(WidgetTester tester, int index) =>
    tester.widget<ListTile>(_tileOf(index));

void _setCurrent(WidgetTester tester, int? index) {
  ProviderScope.containerOf(
    tester.element(find.byType(ChapterListSheet)),
  ).read(_currentIndexProvider.notifier).set(index);
}

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

      check(find.text(_title(_current)).hitTestable().evaluate()).isNotEmpty();
      check(find.text(_title(0)).hitTestable().evaluate()).isEmpty();
    });

    testWidgets('stays at the top when no chapter is current', (tester) async {
      await tester.pumpWidget(_buildSheet(initialIndex: null));
      await tester.pumpAndSettle();

      check(find.text(_title(0)).hitTestable().evaluate()).isNotEmpty();
      check(find.byIcon(Symbols.graphic_eq).evaluate()).isEmpty();
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

        final current = _tile(tester, _current);
        check(current.selected).isTrue();
        check(current.selectedTileColor).equals(colors.accentTint);
        check(current.selectedColor).equals(colors.accent);
        check(_playingIconIn(_current).evaluate()).isNotEmpty();

        final title = tester.widget<Text>(find.text(_title(_current)));
        check(title.style?.fontWeight).equals(FontWeight.w600);
      });
    }

    testWidgets('marks other chapters plainly', (tester) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      const previous = _current - 1;
      check(_tile(tester, previous).selected).isFalse();
      check(_playingIconIn(previous).evaluate()).isEmpty();
      final number = find.descendant(
        of: _tileOf(previous),
        matching: find.text('${previous + 1}'),
      );
      check(number.evaluate()).isNotEmpty();
    });

    testWidgets('highlight follows playback while open', (tester) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      const next = _current + 1;
      _setCurrent(tester, next);
      await tester.pumpAndSettle();

      check(_tile(tester, next).selected).isTrue();
      check(_tile(tester, _current).selected).isFalse();
      check(_playingIconIn(next).evaluate()).isNotEmpty();
      check(_playingIconIn(_current).evaluate()).isEmpty();
    });

    testWidgets('exposes the current chapter as selected to screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(_tileOf(_current)),
        matchesSemantics(
          label: 'Chapter 31: ${_title(_current)}, starts at 30:00',
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
