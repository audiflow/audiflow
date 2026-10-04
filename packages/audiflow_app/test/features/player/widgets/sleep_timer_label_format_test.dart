import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_label_format.dart';
import 'package:audiflow_app/l10n/app_localizations_en.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();
  String clock(DateTime _) => '23:45';

  group('formatSleepTimerSheetStatus', () {
    test('returns null when off', () {
      final label = formatSleepTimerSheetStatus(
        const SleepTimerConfig.off(),
        l10n,
        formatClock: clock,
      );
      check(label).isNull();
    });

    test('describes end of episode and end of chapter', () {
      check(
        formatSleepTimerSheetStatus(
          const SleepTimerConfig.endOfEpisode(),
          l10n,
          formatClock: clock,
        ),
      ).equals('Stops at end of episode');
      check(
        formatSleepTimerSheetStatus(
          const SleepTimerConfig.endOfChapter(),
          l10n,
          formatClock: clock,
        ),
      ).equals('Stops at end of chapter');
    });

    test('pluralizes episodes left', () {
      String? format(int remaining) => formatSleepTimerSheetStatus(
        SleepTimerConfig.episodes(total: 3, remaining: remaining),
        l10n,
        formatClock: clock,
      );
      check(format(1)).equals('1 episode left');
      check(format(3)).equals('3 episodes left');
    });

    test('combines countdown with wall-clock deadline', () {
      // The formatter reads the wall clock, so leave slack below the
      // half-minute mark instead of asserting an exact second.
      final deadline = DateTime.now().add(
        const Duration(minutes: 10, seconds: 30, milliseconds: 500),
      );
      final label = formatSleepTimerSheetStatus(
        SleepTimerConfig.duration(
          total: const Duration(minutes: 10),
          deadline: deadline,
        ),
        l10n,
        formatClock: clock,
      );
      check(label).isNotNull().matchesPattern(
        RegExp(r'^Stopping in 10:(30|2\d) \(at 23:45\)$'),
      );
    });
  });
}
