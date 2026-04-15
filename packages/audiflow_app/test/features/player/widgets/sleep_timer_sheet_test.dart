import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('shows Off, End of episode, Set minutes/episodes by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        SleepTimerSheet(
          state: const SleepTimerState(
            config: SleepTimerConfig.off(),
            lastMinutes: 0,
            lastEpisodes: 0,
          ),
          hasChapters: false,
          onOff: () {},
          onEndOfEpisode: () {},
          onEndOfChapter: () {},
          onDurationStart: (_) {},
          onEpisodesStart: (_) {},
          onCloseSheet: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Off'), findsOneWidget);
    expect(find.text('End of episode'), findsOneWidget);
    expect(find.text('End of chapter'), findsNothing);
    expect(find.text('Set minutes'), findsOneWidget);
    expect(find.text('Set episodes'), findsOneWidget);
  });

  testWidgets('shows End of chapter when hasChapters true', (tester) async {
    await tester.pumpWidget(
      wrap(
        SleepTimerSheet(
          state: const SleepTimerState(
            config: SleepTimerConfig.off(),
            lastMinutes: 0,
            lastEpisodes: 0,
          ),
          hasChapters: true,
          onOff: () {},
          onEndOfEpisode: () {},
          onEndOfChapter: () {},
          onDurationStart: (_) {},
          onEpisodesStart: (_) {},
          onCloseSheet: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('End of chapter'), findsOneWidget);
  });

  testWidgets('short-tap on remembered minutes starts timer immediately', (
    tester,
  ) async {
    var started = Duration.zero;
    await tester.pumpWidget(
      wrap(
        SleepTimerSheet(
          state: const SleepTimerState(
            config: SleepTimerConfig.off(),
            lastMinutes: 30,
            lastEpisodes: 0,
          ),
          hasChapters: false,
          onOff: () {},
          onEndOfEpisode: () {},
          onEndOfChapter: () {},
          onDurationStart: (d) => started = d,
          onEpisodesStart: (_) {},
          onCloseSheet: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('30 minutes'));
    await tester.pumpAndSettle();
    expect(started, const Duration(minutes: 30));
  });

  testWidgets('long-press on remembered minutes opens numeric panel', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        SleepTimerSheet(
          state: const SleepTimerState(
            config: SleepTimerConfig.off(),
            lastMinutes: 30,
            lastEpisodes: 0,
          ),
          hasChapters: false,
          onOff: () {},
          onEndOfEpisode: () {},
          onEndOfChapter: () {},
          onDurationStart: (_) {},
          onEpisodesStart: (_) {},
          onCloseSheet: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('30 minutes'));
    await tester.pumpAndSettle();
    expect(find.text('Minutes'), findsOneWidget);
  });

  testWidgets('checkmark shown on active entry', (tester) async {
    await tester.pumpWidget(
      wrap(
        SleepTimerSheet(
          state: const SleepTimerState(
            config: SleepTimerConfig.endOfEpisode(),
            lastMinutes: 0,
            lastEpisodes: 0,
          ),
          hasChapters: false,
          onOff: () {},
          onEndOfEpisode: () {},
          onEndOfChapter: () {},
          onDurationStart: (_) {},
          onEpisodesStart: (_) {},
          onCloseSheet: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final row = find.ancestor(
      of: find.text('End of episode'),
      matching: find.byType(ListTile),
    );
    expect(row, findsOneWidget);
    expect(
      find.descendant(of: row, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });
}
