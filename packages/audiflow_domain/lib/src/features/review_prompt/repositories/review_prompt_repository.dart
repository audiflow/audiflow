import '../models/review_prompt_stats.dart';

/// Persists the state used by the review-prompt auto-trigger.
///
/// Reads are synchronous (kept hot in SharedPreferences); writes are
/// async because the underlying storage is async.
abstract class ReviewPromptRepository {
  /// Returns the current snapshot. Never throws — returns defaults if
  /// the underlying store is empty.
  ReviewPromptStats getStats();

  /// Adds a delta to the cumulative listened total and persists.
  Future<void> addListenedMs(int deltaMs);

  /// Marks a prompt as shown: advances the threshold by
  /// [ReviewPromptStats.promptIntervalMs] and records [shownAt].
  ///
  /// Idempotent if called twice at the same instant.
  Future<void> recordPromptShown(DateTime shownAt);

  /// Records that the user picked "Don't ask again" — never prompt again.
  Future<void> markOptedOut();

  /// Records that the user tapped "Rate now" (auto-prompt) or the manual
  /// "Rate the App" tile in Settings — assume they rated, never prompt
  /// again.
  Future<void> markUserRated();

  /// Test/debug helper.
  Future<void> reset();
}
