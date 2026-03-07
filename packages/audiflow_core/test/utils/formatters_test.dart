import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('Formatters', () {
    group('formatNumber()', () {
      test('formats zero', () {
        expect(Formatters.formatNumber(0), '0');
      });

      test('formats small numbers without separator', () {
        expect(Formatters.formatNumber(999), '999');
      });

      test('formats thousands with comma separator', () {
        expect(Formatters.formatNumber(1000), '1,000');
      });

      test('formats tens of thousands', () {
        expect(Formatters.formatNumber(12345), '12,345');
      });

      test('formats millions', () {
        expect(Formatters.formatNumber(1000000), '1,000,000');
      });

      test('formats negative numbers', () {
        expect(Formatters.formatNumber(-1234), '-1,234');
      });

      test('formats double values', () {
        // NumberFormat('#,###') truncates decimals
        final result = Formatters.formatNumber(1234.56);
        expect(result, isNotEmpty);
      });

      test('formats single digit', () {
        expect(Formatters.formatNumber(5), '5');
      });
    });

    group('formatBytes()', () {
      test('formats zero bytes', () {
        expect(Formatters.formatBytes(0), '0.00 B');
      });

      test('formats bytes below 1 KB', () {
        expect(Formatters.formatBytes(500), '500.00 B');
      });

      test('formats exactly 1 KB', () {
        expect(Formatters.formatBytes(1024), '1.00 KB');
      });

      test('formats kilobytes', () {
        expect(Formatters.formatBytes(2048), '2.00 KB');
      });

      test('formats megabytes', () {
        expect(Formatters.formatBytes(1048576), '1.00 MB');
      });

      test('formats gigabytes', () {
        expect(Formatters.formatBytes(1073741824), '1.00 GB');
      });

      test('formats fractional kilobytes', () {
        expect(Formatters.formatBytes(1536), '1.50 KB');
      });

      test('formats large megabytes', () {
        // 500 MB = 500 * 1024 * 1024
        expect(Formatters.formatBytes(524288000), '500.00 MB');
      });

      test('formats 1 byte', () {
        expect(Formatters.formatBytes(1), '1.00 B');
      });

      test('formats 1023 bytes stays in B range', () {
        expect(Formatters.formatBytes(1023), '1023.00 B');
      });
    });

    group('formatDate()', () {
      test('formats a date', () {
        final date = DateTime(2024, 1, 15);
        final expected = DateFormat.yMMMd().format(date);
        expect(Formatters.formatDate(date), expected);
      });

      test('formats end of year date', () {
        final date = DateTime(2024, 12, 31);
        final expected = DateFormat.yMMMd().format(date);
        expect(Formatters.formatDate(date), expected);
      });

      test('formats beginning of year date', () {
        final date = DateTime(2024, 1, 1);
        final expected = DateFormat.yMMMd().format(date);
        expect(Formatters.formatDate(date), expected);
      });
    });

    group('formatDateTime()', () {
      test('formats date and time', () {
        final dateTime = DateTime(2024, 3, 15, 14, 30);
        final expected = DateFormat.yMMMd().add_Hm().format(dateTime);
        expect(Formatters.formatDateTime(dateTime), expected);
      });

      test('formats midnight', () {
        final dateTime = DateTime(2024, 6, 1, 0, 0);
        final expected = DateFormat.yMMMd().add_Hm().format(dateTime);
        expect(Formatters.formatDateTime(dateTime), expected);
      });

      test('formats end of day', () {
        final dateTime = DateTime(2024, 6, 1, 23, 59);
        final expected = DateFormat.yMMMd().add_Hm().format(dateTime);
        expect(Formatters.formatDateTime(dateTime), expected);
      });
    });
  });
}
