import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';

/// Repository interface for reading and writing app settings.
///
/// Each setting has a synchronous getter (returns current or default
/// value) and an async setter that persists the value.
abstract class AppSettingsRepository {
  // -- Appearance --

  /// Current theme mode preference.
  ThemeMode getThemeMode();

  /// Persists the theme mode preference.
  Future<void> setThemeMode(ThemeMode mode);

  /// Current locale override, or null for system default.
  String? getLocale();

  /// Persists the locale override. Pass null to reset to system
  /// default.
  Future<void> setLocale(String? locale);

  /// Current UI text scale factor.
  double getTextScale();

  /// Persists the UI text scale factor.
  Future<void> setTextScale(double scale);

  // -- Playback --

  /// Current audio playback speed multiplier.
  double getPlaybackSpeed();

  /// Persists the audio playback speed multiplier.
  Future<void> setPlaybackSpeed(double speed);

  /// Seconds to skip forward on tap.
  int getSkipForwardSeconds();

  /// Persists seconds to skip forward on tap.
  Future<void> setSkipForwardSeconds(int seconds);

  /// Seconds to skip backward on tap.
  int getSkipBackwardSeconds();

  /// Persists seconds to skip backward on tap.
  Future<void> setSkipBackwardSeconds(int seconds);

  /// Fraction of episode at which it is marked complete.
  double getAutoCompleteThreshold();

  /// Persists the auto-complete threshold.
  Future<void> setAutoCompleteThreshold(double threshold);

  /// Whether to auto-play the next episode in the queue.
  bool getContinuousPlayback();

  /// Persists the continuous playback setting.
  Future<void> setContinuousPlayback(bool enabled);

  /// Auto-play order when queuing from a podcast's episode list.
  AutoPlayOrder getAutoPlayOrder();

  /// Persists the auto-play order preference.
  Future<void> setAutoPlayOrder(AutoPlayOrder order);

  /// How the player reacts to a duckable audio focus loss (e.g. a short
  /// notification chime): lower volume ("duck") or pause.
  DuckInterruptionBehavior getDuckInterruptionBehavior();

  /// Persists the duck interruption behavior preference.
  Future<void> setDuckInterruptionBehavior(DuckInterruptionBehavior behavior);

  // -- Downloads --

  /// Whether downloads are restricted to Wi-Fi.
  bool getWifiOnlyDownload();

  /// Persists the Wi-Fi only download setting.
  Future<void> setWifiOnlyDownload(bool enabled);

  /// Whether played episodes are auto-deleted.
  bool getAutoDeletePlayed();

  /// Persists the auto-delete after playback setting.
  Future<void> setAutoDeletePlayed(bool enabled);

  /// Maximum number of simultaneous download tasks.
  int getMaxConcurrentDownloads();

  /// Persists the max concurrent downloads setting.
  Future<void> setMaxConcurrentDownloads(int count);

  /// Maximum number of episodes to batch-download at once.
  int getBatchDownloadLimit();

  /// Persists the batch download limit.
  Future<void> setBatchDownloadLimit(int limit);

  // -- Feed Sync --

  /// Whether automatic background sync is enabled.
  bool getAutoSync();

  /// Persists the auto-sync setting.
  Future<void> setAutoSync(bool enabled);

  /// Minutes between automatic feed syncs.
  int getSyncIntervalMinutes();

  /// Persists the sync interval in minutes.
  Future<void> setSyncIntervalMinutes(int minutes);

  /// Whether feed sync is restricted to Wi-Fi.
  bool getWifiOnlySync();

  /// Persists the Wi-Fi only sync setting.
  Future<void> setWifiOnlySync(bool enabled);

  // -- Notifications --

  /// Whether to show local notifications for new episodes.
  bool getNotifyNewEpisodes();

  /// Persists the new episode notification setting.
  Future<void> setNotifyNewEpisodes(bool enabled);

  // -- Search --

  /// Current search country code, or null for device locale default.
  String? getSearchCountry();

  /// Persists the search country code. Pass null to reset to device default.
  Future<void> setSearchCountry(String? country);

  // -- Navigation --

  /// Last selected tab index (0=search, 1=library, 2=queue).
  int getLastTabIndex();

  /// Persists the last selected tab index.
  /// Only indices 0-2 are accepted; others are ignored.
  Future<void> setLastTabIndex(int index);

  // -- Voice --

  /// Whether voice commands are enabled.
  bool getVoiceEnabled();

  /// Persists the voice commands enabled setting.
  Future<void> setVoiceEnabled(bool enabled);

  // -- Data management --

  /// Removes all persisted settings, restoring defaults.
  Future<void> clearAll();
}
