/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// Application name
  static const String appName = 'audiflow';

  /// API timeout duration
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Minimum splash screen display time
  static const Duration minSplashDuration = Duration(seconds: 1);

  /// Minimum total episode count required to expose the auto-detect
  /// year-grouping smart-playlist tab. Below this threshold the year
  /// fallback is suppressed so the smart-playlist toggle stays hidden
  /// for small feeds.
  ///
  /// Only applies to the auto-detect path (no curated config). Explicit
  /// `year` definitions in pattern configs bypass this threshold.
  static const int autoYearGroupingMinEpisodes = 30;

  /// How long a finished auto-downloaded episode keeps its file before the
  /// played-download cleanup removes it. Leaves room to replay or to undo
  /// an accidental "mark as played".
  static const Duration playedDownloadGracePeriod = Duration(hours: 24);

  /// Auto-downloads a podcast may receive without being played before its
  /// auto-download pauses. Counting downloads rather than days adapts to
  /// each feed's release cadence.
  static const int autoDownloadPauseThreshold = 5;
}
