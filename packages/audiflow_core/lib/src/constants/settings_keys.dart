import '../models/auto_play_order.dart';

/// Keys for SharedPreferences storage of user settings.
class SettingsKeys {
  SettingsKeys._();

  // -- Appearance --

  /// Theme mode preference (system, light, dark).
  static const String themeMode = 'settings_theme_mode';

  /// Locale/language preference.
  static const String locale = 'settings_locale';

  /// UI text scale factor.
  static const String textScale = 'settings_text_scale';

  // -- Playback --

  /// Audio playback speed multiplier.
  static const String playbackSpeed = 'settings_playback_speed';

  /// Seconds to skip forward on tap.
  static const String skipForwardSeconds = 'settings_skip_forward_seconds';

  /// Seconds to skip backward on tap.
  static const String skipBackwardSeconds = 'settings_skip_backward_seconds';

  /// Fraction of episode duration at which it is marked complete.
  static const String autoCompleteThreshold =
      'settings_auto_complete_threshold';

  /// Whether to auto-play the next episode in the queue.
  static const String continuousPlayback = 'settings_continuous_playback';

  /// Auto-play order when queuing from a podcast's episode list.
  static const String autoPlayOrder = 'settings_auto_play_order';

  // -- Downloads --

  /// Restrict downloads to Wi-Fi connections.
  static const String wifiOnlyDownload = 'settings_wifi_only_download';

  /// Automatically delete episodes after playback completes.
  static const String autoDeletePlayed = 'settings_auto_delete_played';

  /// Maximum number of simultaneous download tasks.
  static const String maxConcurrentDownloads =
      'settings_max_concurrent_downloads';

  /// Maximum number of episodes to batch-download at once.
  static const String batchDownloadLimit = 'settings_batch_download_limit';

  // -- Feed Sync --

  /// Enable automatic background feed sync.
  static const String autoSync = 'settings_auto_sync';

  /// Minutes between automatic feed syncs.
  static const String syncIntervalMinutes = 'settings_sync_interval_minutes';

  /// Restrict feed sync to Wi-Fi connections.
  static const String wifiOnlySync = 'settings_wifi_only_sync';

  // -- Notifications --

  /// Whether to show local notifications for new episodes found
  /// during background refresh.
  static const String notifyNewEpisodes = 'settings_notify_new_episodes';

  // -- Search --

  /// iTunes storefront country code for podcast search (ISO 3166-1 alpha-2).
  static const String searchCountry = 'settings_search_country';

  // -- Navigation --

  /// Last selected tab index (0=search, 1=library, 2=queue).
  static const String lastTabIndex = 'settings_last_tab_index';

  // -- Voice --

  /// Whether voice commands are enabled.
  static const String voiceEnabled = 'settings_voice_enabled';
}

/// Default values for app settings when no preference has been saved.
class SettingsDefaults {
  SettingsDefaults._();

  /// Default UI text scale factor.
  static const double textScale = 1.0;

  /// Default audio playback speed.
  static const double playbackSpeed = 1.0;

  /// Default seconds to skip forward.
  static const int skipForwardSeconds = 30;

  /// Default seconds to skip backward.
  static const int skipBackwardSeconds = 10;

  /// Default auto-complete threshold (95% of episode).
  static const double autoCompleteThreshold = 0.95;

  /// Default continuous playback setting.
  static const bool continuousPlayback = true;

  /// Default auto-play order (chronological, oldest first).
  static const AutoPlayOrder autoPlayOrder = AutoPlayOrder.oldestFirst;

  /// Default Wi-Fi only download setting.
  static const bool wifiOnlyDownload = true;

  /// Default auto-delete after playback setting.
  static const bool autoDeletePlayed = false;

  /// Default maximum concurrent downloads.
  static const int maxConcurrentDownloads = 1;

  /// Default batch download limit.
  static const int batchDownloadLimit = 25;

  /// Minimum allowed batch download limit.
  static const int batchDownloadLimitMin = 1;

  /// Maximum allowed batch download limit.
  static const int batchDownloadLimitMax = 500;

  /// Default auto-sync setting.
  static const bool autoSync = true;

  /// Default minutes between syncs.
  static const int syncIntervalMinutes = 60;

  /// Default Wi-Fi only sync setting.
  static const bool wifiOnlySync = false;

  /// Default new episode notification setting.
  static const bool notifyNewEpisodes = true;

  /// Default last tab index (search tab).
  static const int lastTabIndex = 0;

  /// Maximum persistable tab index (queue = 2).
  static const int maxPersistableTabIndex = 2;

  /// Default voice commands enabled setting.
  static const bool voiceEnabled = false;
}
