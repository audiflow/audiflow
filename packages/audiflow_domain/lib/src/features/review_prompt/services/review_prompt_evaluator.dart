import '../models/review_prompt_stats.dart';

/// Pure function: should we show the review prompt right now?
///
/// Returns `true` only when:
/// - the user has neither opted out nor already rated
/// - cumulative listened content has reached the next threshold
bool shouldShowReviewPrompt(ReviewPromptStats stats) {
  if (stats.userOptedOut) return false;
  if (stats.userTappedRateNow) return false;
  return stats.nextPromptThresholdMs <= stats.totalListenedMs;
}
