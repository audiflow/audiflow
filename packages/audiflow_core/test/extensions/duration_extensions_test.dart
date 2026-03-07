import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DurationExtensions', () {
    group('formatMinutesSeconds()', () {
      test('formats zero duration', () {
        expect(Duration.zero.formatMinutesSeconds(), '00:00');
      });

      test('formats seconds only', () {
        expect(const Duration(seconds: 5).formatMinutesSeconds(), '00:05');
      });

      test('formats single digit seconds with padding', () {
        expect(const Duration(seconds: 9).formatMinutesSeconds(), '00:09');
      });

      test('formats double digit seconds', () {
        expect(const Duration(seconds: 45).formatMinutesSeconds(), '00:45');
      });

      test('formats minutes and seconds', () {
        expect(
          const Duration(minutes: 3, seconds: 15).formatMinutesSeconds(),
          '03:15',
        );
      });

      test('formats single digit minutes with padding', () {
        expect(
          const Duration(minutes: 1, seconds: 0).formatMinutesSeconds(),
          '01:00',
        );
      });

      test('formats exactly one minute', () {
        expect(const Duration(minutes: 1).formatMinutesSeconds(), '01:00');
      });

      test('wraps minutes at 60 for durations with hours', () {
        // remainder(60) means hours are stripped
        expect(
          const Duration(
            hours: 1,
            minutes: 5,
            seconds: 30,
          ).formatMinutesSeconds(),
          '05:30',
        );
      });

      test('formats 59 minutes 59 seconds', () {
        expect(
          const Duration(minutes: 59, seconds: 59).formatMinutesSeconds(),
          '59:59',
        );
      });
    });

    group('formatHoursMinutesSeconds()', () {
      test('formats zero duration', () {
        expect(Duration.zero.formatHoursMinutesSeconds(), '00:00:00');
      });

      test('formats seconds only', () {
        expect(
          const Duration(seconds: 30).formatHoursMinutesSeconds(),
          '00:00:30',
        );
      });

      test('formats minutes and seconds', () {
        expect(
          const Duration(minutes: 5, seconds: 10).formatHoursMinutesSeconds(),
          '00:05:10',
        );
      });

      test('formats hours minutes and seconds', () {
        expect(
          const Duration(
            hours: 2,
            minutes: 30,
            seconds: 45,
          ).formatHoursMinutesSeconds(),
          '02:30:45',
        );
      });

      test('formats single digit hours with padding', () {
        expect(
          const Duration(hours: 1).formatHoursMinutesSeconds(),
          '01:00:00',
        );
      });

      test('formats large hour values', () {
        expect(
          const Duration(
            hours: 100,
            minutes: 0,
            seconds: 0,
          ).formatHoursMinutesSeconds(),
          '100:00:00',
        );
      });

      test('formats 23:59:59', () {
        expect(
          const Duration(
            hours: 23,
            minutes: 59,
            seconds: 59,
          ).formatHoursMinutesSeconds(),
          '23:59:59',
        );
      });

      test('handles milliseconds by truncating', () {
        expect(
          const Duration(
            hours: 1,
            minutes: 2,
            seconds: 3,
            milliseconds: 999,
          ).formatHoursMinutesSeconds(),
          '01:02:03',
        );
      });
    });
  });
}
