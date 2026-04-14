import '../../../../common/datasources/shared_preferences_datasource.dart';

/// Persists the user's most recent numeric sleep-timer selections.
///
/// Two int keys:
///  - `sleep_timer.last_minutes` — clamped to 0..999 (0 = never set)
///  - `sleep_timer.last_episodes` — clamped to 0..99 (0 = never set)
class SleepTimerPreferencesDatasource {
  const SleepTimerPreferencesDatasource(this._prefs);

  final SharedPreferencesDataSource _prefs;

  static const String _kMinutes = 'sleep_timer.last_minutes';
  static const String _kEpisodes = 'sleep_timer.last_episodes';

  static const int _maxMinutes = 999;
  static const int _maxEpisodes = 99;

  int getLastMinutes() {
    final raw = _prefs.getInt(_kMinutes) ?? 0;
    return raw.clamp(0, _maxMinutes);
  }

  int getLastEpisodes() {
    final raw = _prefs.getInt(_kEpisodes) ?? 0;
    return raw.clamp(0, _maxEpisodes);
  }

  Future<void> setLastMinutes(int minutes) {
    return _prefs.setInt(_kMinutes, minutes.clamp(0, _maxMinutes));
  }

  Future<void> setLastEpisodes(int episodes) {
    return _prefs.setInt(_kEpisodes, episodes.clamp(0, _maxEpisodes));
  }
}
