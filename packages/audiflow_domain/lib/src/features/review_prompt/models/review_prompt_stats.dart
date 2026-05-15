import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_prompt_stats.freezed.dart';

/// First-prompt milestone: total content listened before the prompt is
/// shown for the first time.
const Duration reviewPromptInitialThreshold = Duration(hours: 10);

/// Interval between subsequent prompts (after the first).
const Duration reviewPromptInterval = Duration(hours: 100);

/// Terminal state of the auto-prompt flow. Once not [accumulating] the
/// prompt is never shown again, regardless of listening time.
enum ReviewPromptStatus {
  /// Still tracking listening time toward the next milestone.
  accumulating,

  /// User picked "Don't ask again".
  optedOut,

  /// User picked "Rate now" or tapped the manual rate tile.
  rated,
}

/// Persisted state for the "Rate the App" auto-prompt feature.
///
/// `totalListened` accumulates **content** time (not wall-clock), so
/// playback speed does not move the prompt closer.
@freezed
sealed class ReviewPromptStats with _$ReviewPromptStats {
  const factory ReviewPromptStats({
    @Default(Duration.zero) Duration totalListened,
    @Default(reviewPromptInitialThreshold) Duration nextPromptThreshold,
    @Default(ReviewPromptStatus.accumulating) ReviewPromptStatus status,
    DateTime? lastPromptedAt,
  }) = _ReviewPromptStats;
}
