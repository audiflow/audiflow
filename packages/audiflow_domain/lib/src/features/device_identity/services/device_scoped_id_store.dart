import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import 'device_only_store.dart';

/// Identifiers that belong to one install on one device and must never
/// move to another device through a backup or migration.
///
/// The value lives in [DeviceOnlyStore]. A per-key marker in
/// SharedPreferences tells whether that value was written by this install:
/// preferences are deleted with the app and cleared by "Reset All Data",
/// while iOS Keychain items survive both. A stored value without its marker
/// is a leftover and is replaced. A restored copy of preferences on a new
/// device brings the marker but not the value, so a new id is generated
/// there too.
class DeviceScopedIdStore {
  DeviceScopedIdStore(this._store, this._prefs, {Uuid? uuid, this._logger})
    : _uuid = uuid ?? const Uuid();

  /// Anonymous id shared by crash reporting and analytics (FR 16).
  static const installIdKey = 'install_id';

  /// Identity of this device for sync and restore detection.
  static const deviceIdKey = 'device_id';

  /// Where the install id lived before it moved to device-only storage.
  /// SharedPreferences is backed up, so it moved to new devices.
  static const legacyInstallIdPrefsKey = 'analytics.install_id';

  static const _markerPrefix = 'device_identity.written.';

  final DeviceOnlyStore _store;
  final SharedPreferencesDataSource _prefs;
  final Uuid _uuid;
  final Logger? _logger;
  final _pending = <String, Future<String>>{};

  /// Returns the id stored under [key], generating and storing one when
  /// this install has none.
  ///
  /// Never throws: when device-only storage fails, falls back to an id that
  /// lasts for this session (or the legacy install id), so analytics and
  /// crash reporting keep working.
  Future<String> getOrCreate(String key) => _pending[key] ??= _resolve(key);

  Future<String> _resolve(String key) async {
    try {
      return await _readOrCreate(key);
    } on Exception catch (error) {
      _logger?.w('Device-only storage unavailable for $key: $error');
      final legacy = key == installIdKey
          ? _prefs.getString(legacyInstallIdPrefsKey)
          : null;
      if (legacy != null && legacy.isNotEmpty) return legacy;
      return _uuid.v4();
    }
  }

  Future<String> _readOrCreate(String key) async {
    final marker = '$_markerPrefix$key';
    final stored = await _store.read(key);
    final ownedByThisInstall = _prefs.getBool(marker) ?? false;
    if (stored != null && stored.isNotEmpty && ownedByThisInstall) {
      return stored;
    }

    final id = _adoptLegacy(key) ?? _uuid.v4();
    // Value before marker: a crash in between leaves an unmarked value,
    // which the next launch replaces, rather than a marker without one.
    await _store.write(key, id);
    await _prefs.setBool(marker, true);
    if (key == installIdKey) await _prefs.remove(legacyInstallIdPrefsKey);
    return id;
  }

  /// Keeps the existing install id across the upgrade that moved it, so
  /// this device's analytics and crash history stay linked.
  String? _adoptLegacy(String key) {
    if (key != installIdKey) return null;
    final legacy = _prefs.getString(legacyInstallIdPrefsKey);
    if (legacy == null || legacy.isEmpty) return null;
    return legacy;
  }
}
