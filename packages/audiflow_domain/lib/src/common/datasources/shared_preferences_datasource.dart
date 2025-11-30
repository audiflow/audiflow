import 'package:shared_preferences/shared_preferences.dart';

/// Data source for SharedPreferences operations
class SharedPreferencesDataSource {
  const SharedPreferencesDataSource(this._prefs);

  final SharedPreferences _prefs;

  /// Keys
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';

  /// Get string value
  String? getString(String key) => _prefs.getString(key);

  /// Set string value
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  /// Get int value
  int? getInt(String key) => _prefs.getInt(key);

  /// Set int value
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  /// Get bool value
  bool? getBool(String key) => _prefs.getBool(key);

  /// Set bool value
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  /// Remove value
  Future<bool> remove(String key) => _prefs.remove(key);

  /// Clear all values
  Future<bool> clear() => _prefs.clear();
}
