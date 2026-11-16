import 'dart:convert';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:isar_community/isar.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../player/datasources/local/sleep_timer_preferences_datasource.dart';
import '../models/synced_setting.dart';
import '../sync/user_state_fields.dart';
import 'user_state_store.dart';

/// The settings storage the settings repository reads and writes.
///
/// Keys in [syncedKeys] live in [SyncedSetting] (Isar) and are also written
/// to SharedPreferences for one release, so a rollback finds them. A synced
/// key with no row yet, or a store without Isar, reads SharedPreferences.
/// Every other key is device-scoped and stays in SharedPreferences only.
class SyncedSettingsStore {
  SyncedSettingsStore(this._prefs, {this._isar});

  final SharedPreferencesDataSource _prefs;
  final Isar? _isar;

  late final _store = _isar == null ? null : UserStateStore(_isar);

  /// The settings that follow the listener to other devices: the
  /// listening-related ones (backup-restore plan, decision D3). The rest
  /// (appearance, haptics, network and download limits, feed sync
  /// schedule, last tab, privacy consent) depend on the device.
  static const Set<String> syncedKeys = {
    SettingsKeys.playbackSpeed,
    SettingsKeys.recentPlaybackSpeeds,
    SettingsKeys.skipForwardSeconds,
    SettingsKeys.skipBackwardSeconds,
    SettingsKeys.autoCompleteThreshold,
    SettingsKeys.continuousPlayback,
    SettingsKeys.autoPlayOrder,
    SettingsKeys.duckInterruptionBehavior,
    SettingsKeys.showRemainingTime,
    SettingsKeys.skipSilence,
    SettingsKeys.voiceBoost,
    SettingsKeys.autoDeletePlayed,
    SettingsKeys.autoDownloadKeepCount,
    SettingsKeys.notifyNewEpisodes,
    SettingsKeys.searchCountry,
    SleepTimerPreferencesDatasource.lastMinutesKey,
    SleepTimerPreferencesDatasource.lastEpisodesKey,
  };

  String? getString(String key) => _read(key, _prefs.getString, _asString);

  int? getInt(String key) => _read(key, _prefs.getInt, _asInt);

  double? getDouble(String key) => _read(key, _prefs.getDouble, _asDouble);

  bool? getBool(String key) => _read(key, _prefs.getBool, _asBool);

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
    await _write(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
    await _write(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
    await _write(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
    await _write(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
    await _write(key, null, present: false);
  }

  /// Copies the synced keys SharedPreferences holds into Isar, skipping
  /// keys that already have a row. Idempotent; the foreground launch runs
  /// it, since migration steps cannot reach SharedPreferences.
  Future<void> copyFromPreferences(Set<String> storedKeys) async {
    final store = _store;
    final isar = _isar;
    if (store == null || isar == null) return;
    await store.write((txn) async {
      for (final key in syncedKeys) {
        if (!storedKeys.contains(key)) continue;
        if (await isar.syncedSettings.getByKey(key) != null) continue;
        // The typed getters throw on another type, so read it untyped.
        final value = _prefs.get(key);
        if (value == null) continue;
        await isar.syncedSettings.put(
          SyncedSetting()
            ..key = key
            ..value = jsonEncode(value)
            ..hlc = txn.stamp.packed,
        );
      }
      // Existing values travel with the first sync's snapshot instead.
    }, recordOps: false);
  }

  T? _read<T>(String key, T? Function(String) legacy, T? Function(Object?) as) {
    final isar = _isar;
    if (isar == null || !syncedKeys.contains(key)) return legacy(key);
    final row = isar.syncedSettings.getByKeySync(key);
    if (row == null) return legacy(key);
    if (!row.present) return null;
    return as(_decode(row.value));
  }

  Future<void> _write(String key, Object? value, {bool present = true}) async {
    final store = _store;
    final isar = _isar;
    if (store == null || isar == null || !syncedKeys.contains(key)) return;
    final encoded = jsonEncode(value);
    await store.write((txn) async {
      final row =
          await isar.syncedSettings.getByKey(key) ??
          (SyncedSetting()..key = key);
      if (row.hlc != 0 && row.present == present && row.value == encoded) {
        return;
      }
      await isar.syncedSettings.put(
        row
          ..value = encoded
          ..present = present
          ..hlc = txn.stamp.packed,
      );
      txn.touch(UserStateEntities.setting, row);
    });
  }

  static Object? _decode(String value) {
    try {
      return jsonDecode(value);
    } on FormatException {
      return null;
    }
  }

  static String? _asString(Object? v) => v is String ? v : null;

  // A double that is a whole number came from an int setting.
  static int? _asInt(Object? v) => switch (v) {
    final int i => i,
    final double d when d == d.roundToDouble() => d.toInt(),
    _ => null,
  };

  static double? _asDouble(Object? v) => v is num ? v.toDouble() : null;

  static bool? _asBool(Object? v) => v is bool ? v : null;
}
