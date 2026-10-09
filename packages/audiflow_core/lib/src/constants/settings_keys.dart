import '../models/auto_play_order.dart';
import '../models/duck_interruption_behavior.dart';
import '../models/haptic_feedback_level.dart';

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

  /// Haptic feedback level (on, reduced, off).
  static const String hapticFeedbackLevel = 'settings_haptic_feedback_level';

  // -- Playback --

  /// Audio playback speed multiplier.
  static const String playbackSpeed = 'settings_playback_speed';

  /// Recently used non-normal playback speeds, newest first (JSON list).
  static const String recentPlaybackSpeeds = 'settings_recent_playback_speeds';

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

  /// How the player reacts to duckable audio focus loss (duck vs pause).
  static const String duckInterruptionBehavior =
      'settings_duck_interruption_behavior';

  /// Whether the player's right-hand time label shows remaining time
  /// (`-mm:ss`) instead of the total duration.
  static const String showRemainingTime = 'settings_show_remaining_time';

  /// Whether silent passages are skipped during playback (Android only).
  static const String skipSilence = 'settings_skip_silence';

  /// Whether the voice boost loudness effect is on (Android only).
  static const String voiceBoost = 'settings_voice_boost';

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

  /// Unstarted auto-downloads to keep per podcast.
  static const String autoDownloadKeepCount =
      'settings_auto_download_keep_count';

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

  // -- Privacy --

  /// Whether the user has accepted the privacy policy. Gates first-launch
  /// navigation; until true the consent screen is shown.
  static const String privacyConsentAccepted =
      'settings_privacy_consent_accepted';
}

/// Default values for app settings when no preference has been saved.
class SettingsDefaults {
  SettingsDefaults._();

  /// Default UI text scale factor.
  static const double textScale = 1.0;

  /// Default haptic feedback level.
  static const HapticFeedbackLevel hapticFeedbackLevel =
      HapticFeedbackLevel.reduced;

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

  /// Default behavior on duckable interruption (platform-idiomatic duck).
  static const DuckInterruptionBehavior duckInterruptionBehavior =
      DuckInterruptionBehavior.duck;

  /// Seconds to rewind before an interruption-driven pause so the listener
  /// does not miss content when playback resumes.
  static const int interruptionRewindSeconds = 2;

  /// Default player time label mode (remaining time).
  static const bool showRemainingTime = true;

  /// Default silence skipping setting.
  static const bool skipSilence = false;

  /// Default voice boost setting.
  static const bool voiceBoost = false;

  /// Default Wi-Fi only download setting.
  static const bool wifiOnlyDownload = true;

  /// Default auto-delete after playback setting. Safe to enable by default
  /// because it only ever removes auto-downloaded episodes.
  static const bool autoDeletePlayed = true;

  /// Default maximum concurrent downloads.
  static const int maxConcurrentDownloads = 1;

  /// Default batch download limit.
  static const int batchDownloadLimit = 25;

  /// Minimum allowed batch download limit.
  static const int batchDownloadLimitMin = 1;

  /// Maximum allowed batch download limit.
  static const int batchDownloadLimitMax = 500;

  /// Default number of unstarted auto-downloads kept per podcast.
  static const int autoDownloadKeepCount = 3;

  /// Choices offered for the auto-download keep count.
  static const List<int> autoDownloadKeepCountOptions = [1, 2, 3, 5, 10];

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
}
