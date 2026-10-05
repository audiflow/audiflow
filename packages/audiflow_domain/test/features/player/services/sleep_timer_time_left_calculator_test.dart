import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 10, 5, 23);

EpisodeChapter _chapter(int index, int startMinutes) => EpisodeChapter()
  ..id = index
  ..episodeId = 1
  ..sortOrder = index
  ..title = 'Chapter $index'
  ..startMs = startMinutes * 60 * 1000;

/// Chapters starting at 0, 10 and 25 minutes.
final _chapters = [_chapter(0, 0), _chapter(1, 10), _chapter(2, 25)];

/// 10 minutes into a 40-minute episode.
SleepTimerPlayback _playback({
  double speed = 1.0,
  Duration? position = const Duration(minutes: 10),
  Duration? duration = const Duration(minutes: 40),
  List<EpisodeChapter> chapters = const [],
  List<Duration?>? upNext,
}) => (
  position: position,
  duration: duration,
  speed: speed,
  chapters: chapters,
  upNextDurations: upNext,
);

SleepTimerTimeLeft? _compute(
  SleepTimerConfig config,
  SleepTimerPlayback playback,
) => computeSleepTimerTimeLeft(config: config, now: _now, playback: playback);

void main() {
  group('computeSleepTimerTimeLeft', () {
    test('returns null while the timer is off', () {
      check(_compute(const SleepTimerConfig.off(), _playback())).isNull();
    });

    group('duration timer', () {
      SleepTimerConfig config(Duration left) => SleepTimerConfig.duration(
        total: const Duration(minutes: 30),
        deadline: _now.add(left),
      );

      test('counts wall-clock time, unaffected by speed', () {
        final left = const Duration(minutes: 12, seconds: 5);
        check(
          _compute(config(left), _playback()),
        ).equals(SleepTimerTimeLeft(left));
        check(
          _compute(config(left), _playback(speed: 1.5)),
        ).equals(SleepTimerTimeLeft(left));
      });

      test('clamps a passed deadline to zero', () {
        check(
          _compute(config(const Duration(seconds: -3)), _playback()),
        ).equals(const SleepTimerTimeLeft(Duration.zero));
      });
    });

    group('end of episode', () {
      const config = SleepTimerConfig.endOfEpisode();

      test('is the remaining episode time at speed 1.0', () {
        check(
          _compute(config, _playback()),
        ).equals(const SleepTimerTimeLeft(Duration(minutes: 30)));
      });

      test('divides the remaining time by the speed', () {
        check(
          _compute(config, _playback(speed: 1.5)),
        ).equals(const SleepTimerTimeLeft(Duration(minutes: 20)));
      });

      test('is null while the episode length is unknown', () {
        check(_compute(config, _playback(duration: null))).isNull();
        check(_compute(config, _playback(duration: Duration.zero))).isNull();
      });
    });

    group('end of chapter', () {
      const config = SleepTimerConfig.endOfChapter();

      test('runs to the next chapter start, scaled by speed', () {
        final playback = _playback(
          position: const Duration(minutes: 13),
          chapters: _chapters,
        );
        check(
          _compute(config, playback),
        ).equals(const SleepTimerTimeLeft(Duration(minutes: 12)));
        check(
          _compute(config, (
            position: playback.position,
            duration: playback.duration,
            speed: 1.5,
            chapters: playback.chapters,
            upNextDurations: null,
          )),
        ).equals(const SleepTimerTimeLeft(Duration(minutes: 8)));
      });

      test('runs to the episode end in the last chapter', () {
        final playback = _playback(
          position: const Duration(minutes: 30),
          chapters: _chapters,
        );
        check(
          _compute(config, playback),
        ).equals(const SleepTimerTimeLeft(Duration(minutes: 10)));
      });

      test('ends with the first chapter during a lead-in', () {
        final chapters = [_chapter(0, 5), _chapter(1, 20)];
        final playback = _playback(
          position: const Duration(minutes: 2),
          chapters: chapters,
        );
        check(
          _compute(config, playback),
        ).equals(const SleepTimerTimeLeft(Duration(minutes: 18)));
      });

      test('is null without chapters', () {
        check(_compute(config, _playback())).isNull();
      });
    });

    group('after N episodes', () {
      const config = SleepTimerConfig.episodes(total: 3, remaining: 3);

      test('adds the next N-1 queued durations to the current remainder', () {
        final playback = _playback(
          upNext: const [
            Duration(minutes: 20),
            Duration(minutes: 15),
            Duration(minutes: 50),
          ],
        );
        check(
          _compute(config, playback),
        ).equals(const SleepTimerTimeLeft(Duration(minutes: 65)));
      });

      test('divides the total by the speed', () {
        final playback = _playback(
          speed: 1.5,
          upNext: const [Duration(minutes: 20), Duration(minutes: 10)],
        );
        check(
          _compute(config, playback),
        ).equals(const SleepTimerTimeLeft(Duration(minutes: 40)));
      });

      test('falls back to +N when a queued duration is unknown', () {
        final playback = _playback(
          speed: 1.5,
          upNext: const [Duration(minutes: 20), null],
        );
        check(_compute(config, playback)).equals(
          const SleepTimerTimeLeft(Duration(minutes: 20), extraEpisodes: 2),
        );
      });

      test('treats a zero queued duration as unknown', () {
        final playback = _playback(
          upNext: const [Duration(minutes: 20), Duration.zero],
        );
        check(_compute(config, playback)).equals(
          const SleepTimerTimeLeft(Duration(minutes: 30), extraEpisodes: 2),
        );
      });

      test('stops counting where the queue runs out', () {
        final playback = _playback(upNext: const [Duration(minutes: 20)]);
        check(
          _compute(config, playback),
        ).equals(const SleepTimerTimeLeft(Duration(minutes: 50)));
      });

      test('falls back to +N while the queue has not loaded', () {
        check(_compute(config, _playback())).equals(
          const SleepTimerTimeLeft(Duration(minutes: 30), extraEpisodes: 2),
        );
      });

      test('is the current remainder alone for the last episode', () {
        const last = SleepTimerConfig.episodes(total: 3, remaining: 1);
        final playback = _playback(upNext: const [Duration(minutes: 20)]);
        check(
          _compute(last, playback),
        ).equals(const SleepTimerTimeLeft(Duration(minutes: 30)));
      });

      test('is null while the current episode length is unknown', () {
        check(
          _compute(config, _playback(duration: null, upNext: const [])),
        ).isNull();
      });
    });
  });
}
