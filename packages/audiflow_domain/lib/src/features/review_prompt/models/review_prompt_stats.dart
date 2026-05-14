import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_prompt_stats.freezed.dart';

/// 10 hours in milliseconds (first prompt milestone).
const int reviewPromptInitialThresholdMs = 10 * 60 * 60 * 1000;

/// 100 hours in milliseconds (interval between subsequent prompts).
const int reviewPromptIntervalMs = 100 * 60 * 60 * 1000;

/// Persisted state for the "Rate the App" auto-prompt feature.
///
/// All durations are tracked in **content** listened milliseconds (not
/// wall-clock real-time), so playback speed does not influence the
/// threshold.
@freezed
sealed class ReviewPromptStats with _$ReviewPromptStats {
  const factory ReviewPromptStats({
    /// Cumulative content listened since the feature was installed.
    @Default(0) int totalListenedMs,

    /// Next milestone at which the prompt should fire.
    ///
    /// First prompt fires when [totalListenedMs] reaches this value
    /// (default 10 hours). Each shown prompt advances it by 100 hours.
    @Default(reviewPromptInitialThresholdMs) int nextPromptThresholdMs,

    /// User selected "Don't ask again" — never auto-prompt again.
    @Default(false) bool userOptedOut,

    /// User tapped "Rate now" or the manual "Rate the App" tile — assume
    /// they rated; never auto-prompt again.
    @Default(false) bool userTappedRateNow,

    /// Timestamp of the last shown prompt (debugging / future throttling).
    DateTime? lastPromptedAt,
  }) = _ReviewPromptStats;

  /// 10 hours in milliseconds (first prompt milestone).
  static const int initialThresholdMs = reviewPromptInitialThresholdMs;

  /// 100 hours in milliseconds (interval between subsequent prompts).
  static const int promptIntervalMs = reviewPromptIntervalMs;
}
