import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeTestEpisode() {
  return Episode()
    ..id = 1
    ..podcastId = 10
    ..guid = 'guid-001'
    ..title = 'Test Episode'
    ..audioUrl = 'https://example.com/ep.mp3'
    ..durationMs = 3600000;
}

PlaybackHistory _history({
  int episodeId = 1,
  int positionMs = 0,
  int? durationMs,
  int playCount = 0,
  DateTime? completedAt,
}) {
  return PlaybackHistory()
    ..episodeId = episodeId
    ..positionMs = positionMs
    ..durationMs = durationMs
    ..playCount = playCount
    ..completedAt = completedAt;
}

void main() {
  late Episode episode;

  setUp(() {
    episode = _makeTestEpisode();
  });

  group('EpisodeWithProgress', () {
    group('isCompleted', () {
      test('returns false when history is null', () {
        final ewp = EpisodeWithProgress(episode: episode);
        expect(ewp.isCompleted, isFalse);
      });

      test('returns false when completedAt is null', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(positionMs: 500000, playCount: 1),
        );
        expect(ewp.isCompleted, isFalse);
      });

      test('returns true when completedAt is set', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(
            positionMs: 3600000,
            playCount: 1,
            completedAt: DateTime(2024, 6, 1),
          ),
        );
        expect(ewp.isCompleted, isTrue);
      });
    });

    group('isInProgress', () {
      test('returns false when history is null', () {
        final ewp = EpisodeWithProgress(episode: episode);
        expect(ewp.isInProgress, isFalse);
      });

      test('returns false when position is zero', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(positionMs: 0, playCount: 0),
        );
        expect(ewp.isInProgress, isFalse);
      });

      test('returns true when position is positive and not completed', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(positionMs: 120000, playCount: 1),
        );
        expect(ewp.isInProgress, isTrue);
      });

      test('returns false when completed', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(
            positionMs: 3600000,
            playCount: 1,
            completedAt: DateTime(2024, 6, 1),
          ),
        );
        expect(ewp.isInProgress, isFalse);
      });
    });

    group('progressPercent', () {
      test('returns null when history is null', () {
        final ewp = EpisodeWithProgress(episode: episode);
        expect(ewp.progressPercent, isNull);
      });

      test('returns null when durationMs is null', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(positionMs: 500, playCount: 1),
        );
        expect(ewp.progressPercent, isNull);
      });

      test('returns null when durationMs is zero', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(positionMs: 500, durationMs: 0, playCount: 1),
        );
        expect(ewp.progressPercent, isNull);
      });

      test('calculates correct percentage', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(
            positionMs: 1800000,
            durationMs: 3600000,
            playCount: 1,
          ),
        );
        expect(ewp.progressPercent, 0.5);
      });

      test('returns 0.0 when position is zero', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(positionMs: 0, durationMs: 3600000, playCount: 0),
        );
        expect(ewp.progressPercent, 0.0);
      });

      test('returns 1.0 at full duration', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(
            positionMs: 3600000,
            durationMs: 3600000,
            playCount: 1,
          ),
        );
        expect(ewp.progressPercent, 1.0);
      });
    });

    group('remainingMs', () {
      test('returns null when history is null', () {
        final ewp = EpisodeWithProgress(episode: episode);
        expect(ewp.remainingMs, isNull);
      });

      test('returns null when durationMs is null', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(positionMs: 500, playCount: 1),
        );
        expect(ewp.remainingMs, isNull);
      });

      test('calculates remaining correctly', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(
            positionMs: 1000000,
            durationMs: 3600000,
            playCount: 1,
          ),
        );
        expect(ewp.remainingMs, 2600000);
      });

      test('returns zero when at end', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(
            positionMs: 3600000,
            durationMs: 3600000,
            playCount: 1,
          ),
        );
        expect(ewp.remainingMs, 0);
      });
    });

    group('remainingTimeFormatted', () {
      test('returns null when history is null', () {
        final ewp = EpisodeWithProgress(episode: episode);
        expect(ewp.remainingTimeFormatted, isNull);
      });

      test('returns null when durationMs is null', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(positionMs: 500, playCount: 1),
        );
        expect(ewp.remainingTimeFormatted, isNull);
      });

      test('formats minutes for short remaining time', () {
        // 18 minutes remaining = 1080000ms
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(
            positionMs: 2520000,
            durationMs: 3600000,
            playCount: 1,
          ),
        );
        expect(ewp.remainingTimeFormatted, '18 min left');
      });

      test('formats hours and minutes for long remaining time', () {
        // 90 minutes remaining = 5400000ms
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(positionMs: 0, durationMs: 5400000, playCount: 0),
        );
        expect(ewp.remainingTimeFormatted, '1 hr 30 min left');
      });

      test('formats exact hours without minutes', () {
        // 120 minutes remaining = 7200000ms
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(positionMs: 0, durationMs: 7200000, playCount: 0),
        );
        expect(ewp.remainingTimeFormatted, '2 hr left');
      });

      test('formats zero remaining', () {
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(
            positionMs: 3600000,
            durationMs: 3600000,
            playCount: 1,
          ),
        );
        expect(ewp.remainingTimeFormatted, '0 min left');
      });

      test('formats exactly 60 minutes as 1 hr', () {
        // 60 minutes remaining = 3600000ms
        final ewp = EpisodeWithProgress(
          episode: episode,
          history: _history(positionMs: 0, durationMs: 3600000, playCount: 0),
        );
        expect(ewp.remainingTimeFormatted, '1 hr left');
      });
    });
  });
}
