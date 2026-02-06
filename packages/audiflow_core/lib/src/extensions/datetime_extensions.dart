import 'package:intl/intl.dart';

/// Extensions for DateTime class
extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Format as ISO 8601 string
  String toIso8601StringWithMillis() {
    return toIso8601String();
  }

  /// Format for episode list display (Apple Podcasts style).
  ///
  /// - Today → [todayLabel] (e.g. "Today" / "今日")
  /// - Yesterday → [yesterdayLabel] (e.g. "Yesterday" / "昨日")
  /// - 2-6 days ago → abbreviated weekday (e.g. "Mon" / "月")
  /// - Same year → month + day (e.g. "Jan 6" / "1月6日")
  /// - Previous years → full date (e.g. "Jan 6, 2024" / "2024/01/06")
  String formatEpisodeDate({String? todayLabel, String? yesterdayLabel}) {
    if (isToday && todayLabel != null) return todayLabel;
    if (isYesterday && yesterdayLabel != null) return yesterdayLabel;

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    if (sevenDaysAgo.isBefore(this)) {
      return DateFormat.E().format(this);
    }
    if (year == now.year) {
      return DateFormat.MMMd().format(this);
    }
    return DateFormat.yMMMd().format(this);
  }
}
