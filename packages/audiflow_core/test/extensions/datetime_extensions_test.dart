import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('DateTimeExtensions', () {
    group('isToday', () {
      test('returns true for current date and time', () {
        final now = DateTime.now();
        expect(now.isToday, isTrue);
      });

      test('returns true for start of today', () {
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);
        expect(startOfToday.isToday, isTrue);
      });

      test('returns true for end of today', () {
        final now = DateTime.now();
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
        expect(endOfToday.isToday, isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isToday, isFalse);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.isToday, isFalse);
      });

      test('returns false for same day different year', () {
        final now = DateTime.now();
        final lastYear = DateTime(now.year - 1, now.month, now.day);
        expect(lastYear.isToday, isFalse);
      });
    });

    group('isYesterday', () {
      test('returns true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isYesterday, isTrue);
      });

      test('returns true for start of yesterday', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final startOfYesterday = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
        );
        expect(startOfYesterday.isYesterday, isTrue);
      });

      test('returns true for end of yesterday', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final endOfYesterday = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          23,
          59,
          59,
        );
        expect(endOfYesterday.isYesterday, isTrue);
      });

      test('returns false for today', () {
        expect(DateTime.now().isYesterday, isFalse);
      });

      test('returns false for two days ago', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        expect(twoDaysAgo.isYesterday, isFalse);
      });
    });

    group('toIso8601StringWithMillis', () {
      test('returns ISO 8601 formatted string', () {
        final date = DateTime(2024, 3, 15, 10, 30, 45);
        final result = date.toIso8601StringWithMillis();
        expect(result, date.toIso8601String());
      });
    });

    group('formatEpisodeDate', () {
      test('returns todayLabel for today when provided', () {
        final now = DateTime.now();
        final result = now.formatEpisodeDate(
          todayLabel: 'Today',
          yesterdayLabel: 'Yesterday',
        );
        expect(result, 'Today');
      });

      test('does not return todayLabel when null', () {
        final now = DateTime.now();
        final result = now.formatEpisodeDate();
        // Should fall through to other formatting
        expect(result, isNotEmpty);
        expect(result, isNot('Today'));
      });

      test('returns yesterdayLabel for yesterday when provided', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = yesterday.formatEpisodeDate(
          todayLabel: 'Today',
          yesterdayLabel: 'Yesterday',
        );
        expect(result, 'Yesterday');
      });

      test('does not return yesterdayLabel when null', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = yesterday.formatEpisodeDate();
        expect(result, isNotEmpty);
        expect(result, isNot('Yesterday'));
      });

      test('returns abbreviated weekday for 2-6 days ago', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        final result = threeDaysAgo.formatEpisodeDate(
          todayLabel: 'Today',
          yesterdayLabel: 'Yesterday',
        );
        final expected = DateFormat.E().format(threeDaysAgo);
        expect(result, expected);
      });

      test('returns abbreviated weekday for 6 days ago', () {
        final sixDaysAgo = DateTime.now().subtract(const Duration(days: 6));
        final result = sixDaysAgo.formatEpisodeDate(
          todayLabel: 'Today',
          yesterdayLabel: 'Yesterday',
        );
        final expected = DateFormat.E().format(sixDaysAgo);
        expect(result, expected);
      });

      test('returns month and day for same year older than 7 days', () {
        final now = DateTime.now();
        // Use a date 30 days ago to be sure it is within the same year
        // but outside the 7-day window. If that crosses a year boundary,
        // adjust to Jan 15 of this year.
        final sameYearDate = now.month == 1 && 15 < now.day
            ? DateTime(now.year, 1, 1)
            : DateTime(
                now.year,
                now.month,
                now.day,
              ).subtract(const Duration(days: 30));
        // Only test if still same year
        if (sameYearDate.year == now.year) {
          final result = sameYearDate.formatEpisodeDate(
            todayLabel: 'Today',
            yesterdayLabel: 'Yesterday',
          );
          final expected = DateFormat.MMMd().format(sameYearDate);
          expect(result, expected);
        }
      });

      test('returns full date for previous years', () {
        final lastYear = DateTime(DateTime.now().year - 1, 6, 15);
        final result = lastYear.formatEpisodeDate(
          todayLabel: 'Today',
          yesterdayLabel: 'Yesterday',
        );
        final expected = DateFormat.yMMMd().format(lastYear);
        expect(result, expected);
      });

      test('returns full date for dates from two years ago', () {
        final twoYearsAgo = DateTime(DateTime.now().year - 2, 12, 25);
        final result = twoYearsAgo.formatEpisodeDate(
          todayLabel: 'Today',
          yesterdayLabel: 'Yesterday',
        );
        final expected = DateFormat.yMMMd().format(twoYearsAgo);
        expect(result, expected);
      });

      test('works without labels for today', () {
        final now = DateTime.now();
        final result = now.formatEpisodeDate();
        // Without todayLabel, today falls through to weekday
        expect(result, isNotEmpty);
      });
    });
  });
}
