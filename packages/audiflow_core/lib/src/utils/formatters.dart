import 'package:intl/intl.dart';

/// Formatting utilities
class Formatters {
  Formatters._();

  /// Format number with thousand separators
  static String formatNumber(num value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }

  /// Format bytes to human-readable size
  static String formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var unitIndex = 0;

    while (1024.0 <= size && unitIndex < units.length - 1) {
      size /= 1024.0;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  /// Format date in a localized manner
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_Hm().format(dateTime);
  }
}
