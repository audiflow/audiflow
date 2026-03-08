import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackProgress', () {
    group('construction', () {
      test('holds all fields', () {
        final progress = PlaybackProgress(
          position: const Duration(seconds: 30),
          duration: const Duration(minutes: 5),
          bufferedPosition: const Duration(minutes: 1),
        );

        expect(progress.position, const Duration(seconds: 30));
        expect(progress.duration, const Duration(minutes: 5));
        expect(progress.bufferedPosition, const Duration(minutes: 1));
      });

      test('accepts zero durations', () {
        final progress = PlaybackProgress(
          position: Duration.zero,
          duration: Duration.zero,
          bufferedPosition: Duration.zero,
        );

        expect(progress.position, Duration.zero);
        expect(progress.duration, Duration.zero);
        expect(progress.bufferedPosition, Duration.zero);
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final a = PlaybackProgress(
          position: const Duration(seconds: 10),
          duration: const Duration(seconds: 100),
          bufferedPosition: const Duration(seconds: 50),
        );
        final b = PlaybackProgress(
          position: const Duration(seconds: 10),
          duration: const Duration(seconds: 100),
          bufferedPosition: const Duration(seconds: 50),
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when position differs', () {
        final a = PlaybackProgress(
          position: const Duration(seconds: 10),
          duration: const Duration(seconds: 100),
          bufferedPosition: const Duration(seconds: 50),
        );
        final b = PlaybackProgress(
          position: const Duration(seconds: 20),
          duration: const Duration(seconds: 100),
          bufferedPosition: const Duration(seconds: 50),
        );

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copies with new position', () {
        final original = PlaybackProgress(
          position: const Duration(seconds: 10),
          duration: const Duration(seconds: 100),
          bufferedPosition: const Duration(seconds: 50),
        );
        final copied = original.copyWith(position: const Duration(seconds: 20));

        expect(copied.position, const Duration(seconds: 20));
        expect(copied.duration, const Duration(seconds: 100));
        expect(copied.bufferedPosition, const Duration(seconds: 50));
      });

      test('copies with new duration', () {
        final original = PlaybackProgress(
          position: const Duration(seconds: 10),
          duration: const Duration(seconds: 100),
          bufferedPosition: const Duration(seconds: 50),
        );
        final copied = original.copyWith(
          duration: const Duration(seconds: 200),
        );

        expect(copied.duration, const Duration(seconds: 200));
        expect(copied.position, const Duration(seconds: 10));
      });

      test('returns equal instance when no changes', () {
        final original = PlaybackProgress(
          position: const Duration(seconds: 10),
          duration: const Duration(seconds: 100),
          bufferedPosition: const Duration(seconds: 50),
        );
        final copied = original.copyWith();

        expect(copied, equals(original));
      });
    });

    group('progress', () {
      test('returns 0.0 when duration is zero', () {
        final progress = PlaybackProgress(
          position: const Duration(seconds: 30),
          duration: Duration.zero,
          bufferedPosition: Duration.zero,
        );

        expect(progress.progress, 0.0);
      });

      test('returns correct progress ratio', () {
        final progress = PlaybackProgress(
          position: const Duration(seconds: 50),
          duration: const Duration(seconds: 100),
          bufferedPosition: Duration.zero,
        );

        expect(progress.progress, 0.5);
      });

      test('returns 0.0 when position is zero', () {
        final progress = PlaybackProgress(
          position: Duration.zero,
          duration: const Duration(seconds: 100),
          bufferedPosition: Duration.zero,
        );

        expect(progress.progress, 0.0);
      });

      test('returns 1.0 when at end', () {
        final progress = PlaybackProgress(
          position: const Duration(seconds: 100),
          duration: const Duration(seconds: 100),
          bufferedPosition: const Duration(seconds: 100),
        );

        expect(progress.progress, 1.0);
      });

      test('clamps to 1.0 when position exceeds duration', () {
        final progress = PlaybackProgress(
          position: const Duration(seconds: 120),
          duration: const Duration(seconds: 100),
          bufferedPosition: Duration.zero,
        );

        expect(progress.progress, 1.0);
      });

      test('returns precise value for partial progress', () {
        final progress = PlaybackProgress(
          position: const Duration(seconds: 25),
          duration: const Duration(seconds: 100),
          bufferedPosition: Duration.zero,
        );

        expect(progress.progress, 0.25);
      });

      test('handles millisecond precision', () {
        final progress = PlaybackProgress(
          position: const Duration(milliseconds: 1500),
          duration: const Duration(milliseconds: 3000),
          bufferedPosition: Duration.zero,
        );

        expect(progress.progress, 0.5);
      });
    });

    group('bufferedProgress', () {
      test('returns 0.0 when duration is zero', () {
        final progress = PlaybackProgress(
          position: Duration.zero,
          duration: Duration.zero,
          bufferedPosition: const Duration(seconds: 30),
        );

        expect(progress.bufferedProgress, 0.0);
      });

      test('returns correct buffered ratio', () {
        final progress = PlaybackProgress(
          position: Duration.zero,
          duration: const Duration(seconds: 100),
          bufferedPosition: const Duration(seconds: 75),
        );

        expect(progress.bufferedProgress, 0.75);
      });

      test('returns 1.0 when fully buffered', () {
        final progress = PlaybackProgress(
          position: Duration.zero,
          duration: const Duration(seconds: 100),
          bufferedPosition: const Duration(seconds: 100),
        );

        expect(progress.bufferedProgress, 1.0);
      });

      test('clamps to 1.0 when buffered exceeds duration', () {
        final progress = PlaybackProgress(
          position: Duration.zero,
          duration: const Duration(seconds: 100),
          bufferedPosition: const Duration(seconds: 150),
        );

        expect(progress.bufferedProgress, 1.0);
      });

      test('returns 0.0 when nothing is buffered', () {
        final progress = PlaybackProgress(
          position: Duration.zero,
          duration: const Duration(seconds: 100),
          bufferedPosition: Duration.zero,
        );

        expect(progress.bufferedProgress, 0.0);
      });
    });
  });
}
