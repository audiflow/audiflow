import '../models/playback_history.dart';

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
  ///
  /// [listenedDeltaMs] and [realtimeDeltaMs] are incremental durations
  /// to accumulate into the episode's total statistics.
  Future<void> saveProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
    int listenedDeltaMs = 0,
    int realtimeDeltaMs = 0,
  });

  /// Marks an episode as played on the listener's request.
  ///
  /// Sets the completedAt timestamp to the current time and ends any
  /// replay in progress. Counts a completion only for an episode that was
  /// not played.
  Future<void> markCompleted(int episodeId);

  /// [markCompleted] for bulk marking: leaves an episode that is already
  /// played, also one being replayed, unchanged. Returns whether the
  /// episode changed.
  Future<bool> markCompletedUnlessPlayed(int episodeId);

  /// Finishes the current listen when playback reaches the completion
  /// threshold. Returns false, changing nothing, when it already finished.
  ///
  /// Counts a completion for a first listen and for a replay started from
  /// the beginning, not for a replay reopened by a rewind.
  Future<bool> finishListen(int episodeId);

  /// Marks an episode as incomplete (unplayed).
  ///
  /// Clears the completedAt timestamp and ends any replay, so a saved
  /// position appears in "Continue Listening" again.
  Future<void> markIncomplete(int episodeId);

  /// Starts a replay of a played episode at [positionMs]; [fromStart]
  /// marks a replay from the beginning, the only kind that counts a
  /// completion when it finishes.
  ///
  /// The episode stays played while the replay's position is saved and
  /// resumable. Taking an open replay back to the beginning makes it
  /// count; otherwise does nothing unless the episode's last listen
  /// finished.
  Future<void> startReplay(
    int episodeId, {
    required int positionMs,
    required bool fromStart,
  });

  /// Increments play count when starting from the beginning.
  ///
  /// Called when playback starts from position 0 or near the beginning.
  Future<void> incrementPlayCount(int episodeId);

  /// Returns true if the episode is played, including while it is
  /// being replayed.
  Future<bool> isCompleted(int episodeId);

  /// Returns the progress percentage (0.0 to 1.0) for an episode.
  ///
  /// Returns null if no playback history exists or duration is unknown.
  Future<double?> getProgressPercent(int episodeId);

  /// Returns the most recently played in-progress episode, or null.
  ///
  /// Used to restore the mini player on app restart.
  Future<PlaybackHistory?> getLastPlayed();

  /// Watches episodes that are in progress (for "Continue Listening").
  ///
  /// Returns episodes that have been started and whose current listen is
  /// not finished (replays of played episodes included), ordered by most
  /// recently played.
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10});

  /// Returns all playback histories for episodes in a podcast.
  ///
  /// Performs a single batch query instead of N individual queries.
  /// Map key is episodeId.
  Future<Map<int, PlaybackHistory>> getByPodcastId(int podcastId);
}
