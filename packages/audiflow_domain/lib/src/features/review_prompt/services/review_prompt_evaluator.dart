import '../models/review_prompt_stats.dart';

/// Pure: should the prompt fire right now?
bool shouldShowReviewPrompt(ReviewPromptStats stats) {
  if (stats.status != ReviewPromptStatus.accumulating) return false;
  return stats.nextPromptThreshold <= stats.totalListened;
}
