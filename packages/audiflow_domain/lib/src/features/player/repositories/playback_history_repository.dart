import '../../../common/database/app_database.dart';

/// Repository interface for playback history operations.
///
/// Abstracts the data layer for tracking episode playback progress,
/// completion status, and play counts.
abstract class PlaybackHistoryRepository {
  /// Returns playback history for an episode, or null if not found.
  Future<PlaybackHistory?> getByEpisodeId(int episodeId);

  /// Saves playback progress for an episode.
  ///
  /// Updates position and optionally duration. Creates a new record
  /// if this is the first time playing the episode.
  Future<void> saveProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
  });

  /// Marks an episode as completed.
  ///
  /// Sets the completedAt timestamp to the current time.
  Future<void> markCompleted(int episodeId);

  /// Marks an episode as incomplete.
  ///
  /// Clears the completedAt timestamp, allowing the episode
  /// to appear in "Continue Listening" again.
  Future<void> markIncomplete(int episodeId);

  /// Increments play count when starting from the beginning.
  ///
  /// Called when playback starts from position 0 or near the beginning.
  Future<void> incrementPlayCount(int episodeId);

  /// Returns true if the episode is completed.
  Future<bool> isCompleted(int episodeId);

  /// Returns the progress percentage (0.0 to 1.0) for an episode.
  ///
  /// Returns null if no playback history exists or duration is unknown.
  Future<double?> getProgressPercent(int episodeId);

  /// Watches episodes that are in progress (for "Continue Listening").
  ///
  /// Returns episodes that have been started but not completed,
  /// ordered by most recently played.
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10});
}
