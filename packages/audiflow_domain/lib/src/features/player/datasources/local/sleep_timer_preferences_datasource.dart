import 'package:isar_community/isar.dart';

import '../../../../common/datasources/shared_preferences_datasource.dart';
import '../../../user_state/services/synced_settings_store.dart';

/// Persists the user's most recent numeric sleep-timer selections.
///
/// Two int keys:
///  - `sleep_timer.last_minutes` — clamped to 0..999 (0 = never set)
///  - `sleep_timer.last_episodes` — clamped to 0..99 (0 = never set)
///
/// Both follow the listener to other devices (see [SyncedSettingsStore]).
class SleepTimerPreferencesDatasource {
  /// Without [isar] the values stay in SharedPreferences only.
  SleepTimerPreferencesDatasource(
    SharedPreferencesDataSource prefs, {
    Isar? isar,
  }) : _prefs = SyncedSettingsStore(prefs, isar: isar);

  final SyncedSettingsStore _prefs;

  static const String _kMinutes = lastMinutesKey;
  static const String _kEpisodes = lastEpisodesKey;

  /// Storage keys, also listed in [SyncedSettingsStore.syncedKeys].
  static const String lastMinutesKey = 'sleep_timer.last_minutes';
  static const String lastEpisodesKey = 'sleep_timer.last_episodes';

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
