import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_countdown_format.dart';
import 'package:audiflow_app/l10n/app_localizations_en.dart';
import 'package:audiflow_app/l10n/app_localizations_ja.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final deadline = DateTime(2026, 10, 5, 23);

  group('formatSleepTimerCountdown', () {
    test('uses the player clock format', () {
      check(
        formatSleepTimerCountdown(
          const SleepTimerTimeLeft(Duration(minutes: 12, seconds: 5)),
        ),
      ).equals('12:05');
      check(
        formatSleepTimerCountdown(
          const SleepTimerTimeLeft(Duration(hours: 1, minutes: 2, seconds: 3)),
        ),
      ).equals('1:02:03');
    });

    test('appends the further episodes of unknown length', () {
      check(
        formatSleepTimerCountdown(
          const SleepTimerTimeLeft(Duration(minutes: 30), extraEpisodes: 2),
        ),
      ).equals('30:00 +2');
    });
  });

  group('sleepTimerSemanticsLabel', () {
    const twelveMinutes = SleepTimerTimeLeft(Duration(minutes: 12));

    test('is null while off', () {
      check(
        sleepTimerSemanticsLabel(
          const SleepTimerConfig.off(),
          twelveMinutes,
          l10n,
          includeMode: true,
        ),
      ).isNull();
    });

    test('names the stop condition and the time left', () {
      check(
        sleepTimerSemanticsLabel(
          const SleepTimerConfig.endOfEpisode(),
          twelveMinutes,
          l10n,
          includeMode: true,
        ),
      ).equals('Sleep timer, stops at end of episode, 12 minutes left');
      check(
        sleepTimerSemanticsLabel(
          const SleepTimerConfig.endOfChapter(),
          twelveMinutes,
          l10n,
          includeMode: true,
        ),
      ).equals('Sleep timer, stops at end of chapter, 12 minutes left');
      check(
        sleepTimerSemanticsLabel(
          const SleepTimerConfig.episodes(total: 3, remaining: 3),
          const SleepTimerTimeLeft(Duration(minutes: 30), extraEpisodes: 2),
          l10n,
          includeMode: true,
        ),
      ).equals(
        'Sleep timer, stops after 3 episodes, '
        '30 minutes left, plus 2 more episodes',
      );
    });

    test('a duration timer needs only its time left', () {
      check(
        sleepTimerSemanticsLabel(
          SleepTimerConfig.duration(
            total: const Duration(minutes: 30),
            deadline: deadline,
          ),
          const SleepTimerTimeLeft(Duration(hours: 1, minutes: 5)),
          l10n,
          includeMode: true,
        ),
      ).equals('Sleep timer, 1 hour 5 minutes left');
    });

    test('without the mode, reads only the time left', () {
      check(
        sleepTimerSemanticsLabel(
          const SleepTimerConfig.endOfEpisode(),
          twelveMinutes,
          l10n,
          includeMode: false,
        ),
      ).equals('Sleep timer, 12 minutes left');
    });

    test('falls back to the condition while the time is unknown', () {
      check(
        sleepTimerSemanticsLabel(
          const SleepTimerConfig.endOfEpisode(),
          null,
          l10n,
          includeMode: true,
        ),
      ).equals('Sleep timer, stops at end of episode');
    });

    test('reads seconds under a minute and rounds minutes up', () {
      String spoken(Duration time) =>
          spokenSleepTimerTimeLeft(SleepTimerTimeLeft(time), l10n);
      check(spoken(const Duration(seconds: 45))).equals('45 seconds left');
      check(
        spoken(const Duration(minutes: 11, seconds: 1)),
      ).equals('12 minutes left');
      check(spoken(const Duration(hours: 2))).equals('2 hours left');
    });

    test('joins Japanese parts without spaces', () {
      check(
        spokenSleepTimerTimeLeft(
          const SleepTimerTimeLeft(Duration(hours: 1, minutes: 5)),
          AppLocalizationsJa(),
        ),
      ).equals('残り1時間5分');
    });
  });

  group('isNewSleepTimerArm', () {
    test('arming from off or switching mode is new', () {
      check(
        isNewSleepTimerArm(
          const SleepTimerConfig.off(),
          const SleepTimerConfig.endOfEpisode(),
        ),
      ).isTrue();
      check(
        isNewSleepTimerArm(
          const SleepTimerConfig.endOfEpisode(),
          const SleepTimerConfig.endOfChapter(),
        ),
      ).isTrue();
    });

    test('a new deadline is new', () {
      check(
        isNewSleepTimerArm(
          SleepTimerConfig.duration(
            total: const Duration(minutes: 5),
            deadline: deadline,
          ),
          SleepTimerConfig.duration(
            total: const Duration(minutes: 5),
            deadline: deadline.add(const Duration(minutes: 1)),
          ),
        ),
      ).isTrue();
    });

    test('an episode count counting down is not new', () {
      check(
        isNewSleepTimerArm(
          const SleepTimerConfig.episodes(total: 3, remaining: 3),
          const SleepTimerConfig.episodes(total: 3, remaining: 2),
        ),
      ).isFalse();
    });

    test('re-arming an episode count is new', () {
      check(
        isNewSleepTimerArm(
          const SleepTimerConfig.episodes(total: 3, remaining: 2),
          const SleepTimerConfig.episodes(total: 3, remaining: 3),
        ),
      ).isTrue();
    });

    test('turning the timer off is not an arm', () {
      check(
        isNewSleepTimerArm(
          const SleepTimerConfig.endOfEpisode(),
          const SleepTimerConfig.off(),
        ),
      ).isFalse();
    });
  });
}
