import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _sheet({
  required SleepTimerConfig config,
  int lastMinutes = 0,
  int lastEpisodes = 0,
  VoidCallback? onOff,
  ValueChanged<Duration>? onDurationStart,
}) => wrap(
  SleepTimerSheet(
    state: SleepTimerState(
      config: config,
      lastMinutes: lastMinutes,
      lastEpisodes: lastEpisodes,
    ),
    hasChapters: false,
    onOff: onOff ?? () {},
    onEndOfEpisode: () {},
    onEndOfChapter: () {},
    onDurationStart: onDurationStart ?? (_) {},
    onEpisodesStart: (_) {},
    onCloseSheet: () {},
  ),
);

Widget wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('shows End of episode, Set minutes/episodes by default', (
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

    // Off is replaced by a Cancel button that only appears while active.
    check(find.text('Off').evaluate()).isEmpty();
    check(find.text('Cancel').evaluate()).isEmpty();
    check(find.text('Stop on').evaluate()).length.equals(1);
    check(find.text('Stop after').evaluate()).length.equals(1);
    check(find.text('End of episode').evaluate()).length.equals(1);
    check(find.text('End of chapter').evaluate()).isEmpty();
    check(find.text('Set minutes').evaluate()).length.equals(1);
    check(find.text('Set episodes').evaluate()).length.equals(1);
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
    check(find.text('End of chapter').evaluate()).length.equals(1);
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
    check(started).equals(const Duration(minutes: 30));
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
    check(find.text('Minutes').evaluate()).length.equals(1);
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
    check(row.evaluate()).length.equals(1);
    check(
      find.descendant(of: row, matching: find.byIcon(Icons.check)).evaluate(),
    ).length.equals(1);
  });

  group('active timer', () {
    testWidgets('shows status line and Cancel calls onOff', (tester) async {
      var offCalls = 0;
      await tester.pumpWidget(
        _sheet(
          config: const SleepTimerConfig.endOfEpisode(),
          onOff: () => offCalls++,
        ),
      );
      await tester.pumpAndSettle();

      check(find.text('Stops at end of episode').evaluate()).length.equals(1);
      await tester.tap(find.text('Cancel'));
      check(offCalls).equals(1);
    });

    testWidgets('shows episodes left for an episode-count timer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _sheet(
          config: const SleepTimerConfig.episodes(total: 3, remaining: 2),
          lastEpisodes: 3,
        ),
      );
      await tester.pumpAndSettle();

      check(find.text('2 episodes left').evaluate()).length.equals(1);
    });

    testWidgets('shows countdown for a duration timer', (tester) async {
      final deadline = DateTime.now().add(const Duration(minutes: 5));
      await tester.pumpWidget(
        _sheet(
          config: SleepTimerConfig.duration(
            total: const Duration(minutes: 5),
            deadline: deadline,
          ),
          lastMinutes: 5,
        ),
      );
      await tester.pump();

      check(find.textContaining('Stopping in ').evaluate()).length.equals(1);
      // Unmount so the 1Hz refresh timer is cancelled before teardown.
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('Edit control on remembered minutes opens numeric panel', (
    tester,
  ) async {
    var started = false;
    await tester.pumpWidget(
      _sheet(
        config: const SleepTimerConfig.off(),
        lastMinutes: 30,
        onDurationStart: (_) => started = true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    check(find.text('Minutes').evaluate()).length.equals(1);
    check(started).isFalse();
  });

  testWidgets('long-press on Set minutes opens numeric panel', (tester) async {
    await tester.pumpWidget(_sheet(config: const SleepTimerConfig.off()));
    await tester.pumpAndSettle();

    check(find.text('Edit').evaluate()).isEmpty();
    await tester.longPress(find.text('Set minutes'));
    await tester.pumpAndSettle();
    check(find.text('Minutes').evaluate()).length.equals(1);
  });
}
