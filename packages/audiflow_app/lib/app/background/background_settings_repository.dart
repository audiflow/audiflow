import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';

import 'background_task_registrar.dart';

/// Read-only [AppSettingsRepository] backed by Workmanager's inputData map.
///
/// Used in the background isolate where SharedPreferences platform channels
/// are not available. Setter methods throw [UnsupportedError] — background
/// tasks must not mutate settings.
class BackgroundSettingsRepository implements AppSettingsRepository {
  BackgroundSettingsRepository(Map<String, dynamic>? data)
    : _data = data ?? const {};

  final Map<String, dynamic> _data;

  // -- Feed Sync (used by BackgroundRefreshService / FeedSyncExecutor) --

  @override
  bool getAutoSync() =>
      _data[BackgroundInputKeys.autoSync] as bool? ?? SettingsDefaults.autoSync;

  @override
  bool getWifiOnlySync() =>
      _data[BackgroundInputKeys.wifiOnlySync] as bool? ??
      SettingsDefaults.wifiOnlySync;

  @override
  int getSyncIntervalMinutes() =>
      _data[BackgroundInputKeys.syncIntervalMinutes] as int? ??
      SettingsDefaults.syncIntervalMinutes;

  @override
  bool getNotifyNewEpisodes() =>
      _data[BackgroundInputKeys.notifyNewEpisodes] as bool? ??
      SettingsDefaults.notifyNewEpisodes;

  @override
  bool getWifiOnlyDownload() =>
      _data[BackgroundInputKeys.wifiOnlyDownload] as bool? ??
      SettingsDefaults.wifiOnlyDownload;

  // -- Unused in background — delegate to defaults or throw on write --

  @override
  ThemeMode getThemeMode() => ThemeMode.system;

  @override
  String? getLocale() => null;

  @override
  double getTextScale() => SettingsDefaults.textScale;

  @override
  double getPlaybackSpeed() => SettingsDefaults.playbackSpeed;

  @override
  int getSkipForwardSeconds() => SettingsDefaults.skipForwardSeconds;

  @override
  int getSkipBackwardSeconds() => SettingsDefaults.skipBackwardSeconds;

  @override
  double getAutoCompleteThreshold() => SettingsDefaults.autoCompleteThreshold;

  @override
  bool getContinuousPlayback() => SettingsDefaults.continuousPlayback;

  @override
  AutoPlayOrder getAutoPlayOrder() => SettingsDefaults.autoPlayOrder;

  @override
  bool getAutoDeletePlayed() => SettingsDefaults.autoDeletePlayed;

  @override
  int getMaxConcurrentDownloads() => SettingsDefaults.maxConcurrentDownloads;

  @override
  String? getSearchCountry() => null;

  @override
  int getLastTabIndex() => SettingsDefaults.lastTabIndex;

  @override
  bool getVoiceEnabled() => SettingsDefaults.voiceEnabled;

  // -- All setters are unsupported in background --

  Never _unsupported() =>
      throw UnsupportedError('Settings are read-only in background isolate');

  @override
  Future<void> setThemeMode(ThemeMode mode) => _unsupported();

  @override
  Future<void> setLocale(String? locale) => _unsupported();

  @override
  Future<void> setTextScale(double scale) => _unsupported();

  @override
  Future<void> setPlaybackSpeed(double speed) => _unsupported();

  @override
  Future<void> setSkipForwardSeconds(int seconds) => _unsupported();

  @override
  Future<void> setSkipBackwardSeconds(int seconds) => _unsupported();

  @override
  Future<void> setAutoCompleteThreshold(double threshold) => _unsupported();

  @override
  Future<void> setContinuousPlayback(bool enabled) => _unsupported();

  @override
  Future<void> setAutoPlayOrder(AutoPlayOrder order) => _unsupported();

  @override
  Future<void> setWifiOnlyDownload(bool enabled) => _unsupported();

  @override
  Future<void> setAutoDeletePlayed(bool enabled) => _unsupported();

  @override
  Future<void> setMaxConcurrentDownloads(int count) => _unsupported();

  @override
  Future<void> setAutoSync(bool enabled) => _unsupported();

  @override
  Future<void> setSyncIntervalMinutes(int minutes) => _unsupported();

  @override
  Future<void> setWifiOnlySync(bool enabled) => _unsupported();

  @override
  Future<void> setNotifyNewEpisodes(bool enabled) => _unsupported();

  @override
  Future<void> setSearchCountry(String? country) => _unsupported();

  @override
  Future<void> setLastTabIndex(int index) => _unsupported();

  @override
  Future<void> setVoiceEnabled(bool enabled) => _unsupported();

  @override
  Future<void> clearAll() => _unsupported();
}
