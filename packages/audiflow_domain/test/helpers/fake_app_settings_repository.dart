import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';

/// Fake implementation of [AppSettingsRepository] for use in tests.
///
/// All fields are mutable so tests can set up specific states without
/// relying on real persistence or mock generation.
class FakeAppSettingsRepository implements AppSettingsRepository {
  ThemeMode themeMode = ThemeMode.system;
  String? locale;
  double textScale = 1.0;
  double playbackSpeed = 1.0;
  int skipForwardSeconds = 30;
  int skipBackwardSeconds = 10;
  double autoCompleteThreshold = 0.95;
  bool continuousPlayback = true;
  AutoPlayOrder autoPlayOrder = AutoPlayOrder.oldestFirst;
  bool wifiOnlyDownload = true;
  bool autoDeletePlayed = false;
  int maxConcurrentDownloads = 1;
  bool autoSync = true;
  int syncIntervalMinutes = 60;
  bool wifiOnlySync = false;
  bool notifyNewEpisodes = true;
  String? searchCountry;
  int lastTabIndex = 0;
  bool voiceEnabled = SettingsDefaults.voiceEnabled;

  @override
  ThemeMode getThemeMode() => themeMode;

  @override
  Future<void> setThemeMode(ThemeMode mode) async => themeMode = mode;

  @override
  String? getLocale() => locale;

  @override
  Future<void> setLocale(String? value) async => locale = value;

  @override
  double getTextScale() => textScale;

  @override
  Future<void> setTextScale(double scale) async => textScale = scale;

  @override
  double getPlaybackSpeed() => playbackSpeed;

  @override
  Future<void> setPlaybackSpeed(double speed) async => playbackSpeed = speed;

  @override
  int getSkipForwardSeconds() => skipForwardSeconds;

  @override
  Future<void> setSkipForwardSeconds(int seconds) async =>
      skipForwardSeconds = seconds;

  @override
  int getSkipBackwardSeconds() => skipBackwardSeconds;

  @override
  Future<void> setSkipBackwardSeconds(int seconds) async =>
      skipBackwardSeconds = seconds;

  @override
  double getAutoCompleteThreshold() => autoCompleteThreshold;

  @override
  Future<void> setAutoCompleteThreshold(double threshold) async =>
      autoCompleteThreshold = threshold;

  @override
  bool getContinuousPlayback() => continuousPlayback;

  @override
  Future<void> setContinuousPlayback(bool enabled) async =>
      continuousPlayback = enabled;

  @override
  AutoPlayOrder getAutoPlayOrder() => autoPlayOrder;

  @override
  Future<void> setAutoPlayOrder(AutoPlayOrder order) async =>
      autoPlayOrder = order;

  @override
  bool getWifiOnlyDownload() => wifiOnlyDownload;

  @override
  Future<void> setWifiOnlyDownload(bool enabled) async =>
      wifiOnlyDownload = enabled;

  @override
  bool getAutoDeletePlayed() => autoDeletePlayed;

  @override
  Future<void> setAutoDeletePlayed(bool enabled) async =>
      autoDeletePlayed = enabled;

  @override
  int getMaxConcurrentDownloads() => maxConcurrentDownloads;

  @override
  Future<void> setMaxConcurrentDownloads(int count) async =>
      maxConcurrentDownloads = count;

  @override
  bool getAutoSync() => autoSync;

  @override
  Future<void> setAutoSync(bool enabled) async => autoSync = enabled;

  @override
  int getSyncIntervalMinutes() => syncIntervalMinutes;

  @override
  Future<void> setSyncIntervalMinutes(int minutes) async =>
      syncIntervalMinutes = minutes;

  @override
  bool getWifiOnlySync() => wifiOnlySync;

  @override
  Future<void> setWifiOnlySync(bool enabled) async => wifiOnlySync = enabled;

  @override
  bool getNotifyNewEpisodes() => notifyNewEpisodes;

  @override
  Future<void> setNotifyNewEpisodes(bool enabled) async =>
      notifyNewEpisodes = enabled;

  @override
  String? getSearchCountry() => searchCountry;

  @override
  Future<void> setSearchCountry(String? country) async =>
      searchCountry = country;

  @override
  int getLastTabIndex() => lastTabIndex;

  @override
  Future<void> setLastTabIndex(int index) async => lastTabIndex = index;

  // -- Voice --

  @override
  bool getVoiceEnabled() => voiceEnabled;

  @override
  Future<void> setVoiceEnabled({required bool enabled}) async =>
      voiceEnabled = enabled;

  @override
  Future<void> clearAll() async {
    themeMode = ThemeMode.system;
    locale = null;
    textScale = 1.0;
    playbackSpeed = 1.0;
    skipForwardSeconds = 30;
    skipBackwardSeconds = 10;
    autoCompleteThreshold = 0.95;
    continuousPlayback = true;
    autoPlayOrder = AutoPlayOrder.oldestFirst;
    wifiOnlyDownload = true;
    autoDeletePlayed = false;
    maxConcurrentDownloads = 1;
    autoSync = true;
    syncIntervalMinutes = 60;
    wifiOnlySync = false;
    notifyNewEpisodes = true;
    searchCountry = null;
    lastTabIndex = 0;
    voiceEnabled = SettingsDefaults.voiceEnabled;
  }
}
