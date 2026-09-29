import 'app_localizations.dart';

extension DurationLabel on AppLocalizations {
  /// Localized hours-and-minutes label, truncated to whole minutes
  /// (e.g. `1h5m`, `42m`).
  String durationLabel(Duration duration) {
    final minutes = duration.inMinutes;
    final hours = minutes ~/ 60;
    if (0 < hours) return groupDurationHoursMinutes(hours, minutes % 60);
    return groupDurationMinutes(minutes);
  }
}
