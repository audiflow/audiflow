import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import 'app_settings_repository.dart';

/// SharedPreferences-backed implementation of [AppSettingsRepository].
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  /// Creates a repository backed by [dataSource].
  const AppSettingsRepositoryImpl(this._ds);

  final SharedPreferencesDataSource _ds;

  // -- Appearance --

  @override
  ThemeMode getThemeMode() {
    final name = _ds.getString(SettingsKeys.themeMode);
    return _parseThemeMode(name);
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    await _ds.setString(SettingsKeys.themeMode, mode.name);
  }

  @override
  String? getLocale() => _ds.getString(SettingsKeys.locale);

  @override
  Future<void> setLocale(String? locale) async {
    if (locale == null) {
      await _ds.remove(SettingsKeys.locale);
    } else {
      await _ds.setString(SettingsKeys.locale, locale);
    }
  }

  @override
  double getTextScale() =>
      _ds.getDouble(SettingsKeys.textScale) ?? SettingsDefaults.textScale;

  @override
  Future<void> setTextScale(double scale) async {
    await _ds.setDouble(SettingsKeys.textScale, scale);
  }

  // -- Playback --

  @override
  double getPlaybackSpeed() =>
      _ds.getDouble(SettingsKeys.playbackSpeed) ??
      SettingsDefaults.playbackSpeed;

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    await _ds.setDouble(SettingsKeys.playbackSpeed, speed);
  }

  @override
  int getSkipForwardSeconds() =>
      _ds.getInt(SettingsKeys.skipForwardSeconds) ??
      SettingsDefaults.skipForwardSeconds;

  @override
  Future<void> setSkipForwardSeconds(int seconds) async {
    await _ds.setInt(SettingsKeys.skipForwardSeconds, seconds);
  }

  @override
  int getSkipBackwardSeconds() =>
      _ds.getInt(SettingsKeys.skipBackwardSeconds) ??
      SettingsDefaults.skipBackwardSeconds;

  @override
  Future<void> setSkipBackwardSeconds(int seconds) async {
    await _ds.setInt(SettingsKeys.skipBackwardSeconds, seconds);
  }

  @override
  double getAutoCompleteThreshold() =>
      _ds.getDouble(SettingsKeys.autoCompleteThreshold) ??
      SettingsDefaults.autoCompleteThreshold;

  @override
  Future<void> setAutoCompleteThreshold(double threshold) async {
    await _ds.setDouble(SettingsKeys.autoCompleteThreshold, threshold);
  }

  @override
  bool getContinuousPlayback() =>
      _ds.getBool(SettingsKeys.continuousPlayback) ??
      SettingsDefaults.continuousPlayback;

  @override
  Future<void> setContinuousPlayback(bool enabled) async {
    await _ds.setBool(SettingsKeys.continuousPlayback, enabled);
  }

  // -- Downloads --

  @override
  bool getWifiOnlyDownload() =>
      _ds.getBool(SettingsKeys.wifiOnlyDownload) ??
      SettingsDefaults.wifiOnlyDownload;

  @override
  Future<void> setWifiOnlyDownload(bool enabled) async {
    await _ds.setBool(SettingsKeys.wifiOnlyDownload, enabled);
  }

  @override
  bool getAutoDeletePlayed() =>
      _ds.getBool(SettingsKeys.autoDeletePlayed) ??
      SettingsDefaults.autoDeletePlayed;

  @override
  Future<void> setAutoDeletePlayed(bool enabled) async {
    await _ds.setBool(SettingsKeys.autoDeletePlayed, enabled);
  }

  @override
  int getMaxConcurrentDownloads() =>
      _ds.getInt(SettingsKeys.maxConcurrentDownloads) ??
      SettingsDefaults.maxConcurrentDownloads;

  @override
  Future<void> setMaxConcurrentDownloads(int count) async {
    await _ds.setInt(SettingsKeys.maxConcurrentDownloads, count);
  }

  // -- Feed Sync --

  @override
  bool getAutoSync() =>
      _ds.getBool(SettingsKeys.autoSync) ?? SettingsDefaults.autoSync;

  @override
  Future<void> setAutoSync(bool enabled) async {
    await _ds.setBool(SettingsKeys.autoSync, enabled);
  }

  @override
  int getSyncIntervalMinutes() =>
      _ds.getInt(SettingsKeys.syncIntervalMinutes) ??
      SettingsDefaults.syncIntervalMinutes;

  @override
  Future<void> setSyncIntervalMinutes(int minutes) async {
    await _ds.setInt(SettingsKeys.syncIntervalMinutes, minutes);
  }

  @override
  bool getWifiOnlySync() =>
      _ds.getBool(SettingsKeys.wifiOnlySync) ?? SettingsDefaults.wifiOnlySync;

  @override
  Future<void> setWifiOnlySync(bool enabled) async {
    await _ds.setBool(SettingsKeys.wifiOnlySync, enabled);
  }

  // -- Data management --

  @override
  Future<void> clearAll() async {
    await Future.wait([
      _ds.remove(SettingsKeys.themeMode),
      _ds.remove(SettingsKeys.locale),
      _ds.remove(SettingsKeys.textScale),
      _ds.remove(SettingsKeys.playbackSpeed),
      _ds.remove(SettingsKeys.skipForwardSeconds),
      _ds.remove(SettingsKeys.skipBackwardSeconds),
      _ds.remove(SettingsKeys.autoCompleteThreshold),
      _ds.remove(SettingsKeys.continuousPlayback),
      _ds.remove(SettingsKeys.wifiOnlyDownload),
      _ds.remove(SettingsKeys.autoDeletePlayed),
      _ds.remove(SettingsKeys.maxConcurrentDownloads),
      _ds.remove(SettingsKeys.autoSync),
      _ds.remove(SettingsKeys.syncIntervalMinutes),
      _ds.remove(SettingsKeys.wifiOnlySync),
    ]);
  }

  // -- Helpers --

  ThemeMode _parseThemeMode(String? name) {
    return switch (name) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
