import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../models/force_update_config.dart';

/// SharedPreferences-backed cache for the force-update config.
///
/// Stores the most recently fetched config along with the timestamp of
/// the fetch so callers can decide whether to refresh.
class ForceUpdateLocalDataSource {
  const ForceUpdateLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  /// Returns the cached config, or null when no usable cache exists.
  ///
  /// Discards (and clears) the cache when it cannot be decoded so a
  /// corrupted entry never poisons future reads.
  Future<ForceUpdateConfig?> read() async {
    final raw = _prefs.getString(forceUpdateCacheKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ForceUpdateConfig.fromJson(json);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> write(
    ForceUpdateConfig config, {
    required DateTime fetchedAt,
  }) async {
    await _prefs.setString(forceUpdateCacheKey, jsonEncode(config.toJson()));
    await _prefs.setString(
      forceUpdateLastFetchKey,
      fetchedAt.toUtc().toIso8601String(),
    );
  }

  DateTime? lastFetchAt() {
    final raw = _prefs.getString(forceUpdateLastFetchKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> clear() async {
    await _prefs.remove(forceUpdateCacheKey);
    await _prefs.remove(forceUpdateLastFetchKey);
  }
}
