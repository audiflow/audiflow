import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_label_format.dart';
import 'package:audiflow_app/l10n/app_localizations_en.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
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
      expect(label, isNull);
    });

    test('describes end of episode and end of chapter', () {
      expect(
        formatSleepTimerSheetStatus(
          const SleepTimerConfig.endOfEpisode(),
          l10n,
          formatClock: clock,
        ),
        'Stops at end of episode',
      );
      expect(
        formatSleepTimerSheetStatus(
          const SleepTimerConfig.endOfChapter(),
          l10n,
          formatClock: clock,
        ),
        'Stops at end of chapter',
      );
    });

    test('pluralizes episodes left', () {
      String? format(int remaining) => formatSleepTimerSheetStatus(
        SleepTimerConfig.episodes(total: 3, remaining: remaining),
        l10n,
        formatClock: clock,
      );
      expect(format(1), '1 episode left');
      expect(format(3), '3 episodes left');
    });

    test('combines countdown with wall-clock deadline', () {
      final deadline = DateTime.now().add(
        const Duration(minutes: 10, milliseconds: 500),
      );
      final label = formatSleepTimerSheetStatus(
        SleepTimerConfig.duration(
          total: const Duration(minutes: 10),
          deadline: deadline,
        ),
        l10n,
        formatClock: clock,
      );
      expect(label, 'Stopping in 10:00 (at 23:45)');
    });
  });
}
