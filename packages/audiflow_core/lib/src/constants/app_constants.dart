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

  /// Upper limit of the streamed-audio cache, about four hours of a typical
  /// 128 kbps episode.
  static const int streamCacheMaxBytes = 250 * 1024 * 1024;

  /// How far ahead of the playback position the player keeps downloading.
  /// Covers most seeks a listener makes, and bounds what an episode left after
  /// a minute costs, while an episode shorter than this downloads in full.
  static const Duration readAheadDuration = Duration(minutes: 10);

  /// Audio the Android player may hold in memory ahead of the playback
  /// position. The player buffers in RAM, so a high-bitrate episode stops at
  /// this limit instead of at [readAheadDuration].
  static const int readAheadMaxBytes = 16 * 1024 * 1024;

  /// Auto-downloads a podcast may receive without being played before its
  /// auto-download pauses. Counting downloads rather than days adapts to
  /// each feed's release cadence.
  static const int autoDownloadPauseThreshold = 5;
}
