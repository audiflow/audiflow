import 'package:meta/meta.dart';

import '../models/review_prompt_stats.dart';

/// Persists the state used by the review-prompt auto-trigger.
///
/// Reads return a cached in-memory snapshot loaded once at construction;
/// external SharedPreferences writes are not observed. Writes are async
/// because they hit disk and may fail (errors are logged, never thrown).
abstract class ReviewPromptRepository {
  ReviewPromptStats getStats();

  /// Adds [delta] to the cumulative listened total. Non-positive deltas
  /// are ignored.
  Future<void> addListened(Duration delta);

  /// Advances `nextPromptThreshold` by [reviewPromptInterval] and records
  /// the current time as `lastPromptedAt`. No-op when the status is
  /// terminal (`optedOut` / `rated`).
  Future<void> recordPromptShown();

  /// Transitions the state to [ReviewPromptStatus.optedOut].
  Future<void> markOptedOut();

  /// Transitions the state to [ReviewPromptStatus.rated].
  Future<void> markRated();

  /// Clears all persisted prompt state. Test-only.
  @visibleForTesting
  Future<void> reset();
}
