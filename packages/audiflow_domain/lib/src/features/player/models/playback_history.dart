import 'package:isar_community/isar.dart';

part 'playback_history.g.dart';

@collection
class PlaybackHistory {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int episodeId;

  int positionMs = 0;
  int? durationMs;

  /// When the episode was last played to the end (or marked played).
  ///
  /// Non-null means the episode is played. It stays set while the episode
  /// is replayed and is cleared only by marking the episode unplayed.
  DateTime? completedAt;

  /// True while a played episode is being listened to again.
  ///
  /// Set when playback of a played episode starts and cleared when that
  /// listen completes or the episode is marked played or unplayed. Keeps
  /// the replay position resumable without dropping [completedAt].
  bool isReplaying = false;

  DateTime? firstPlayedAt;
  DateTime? lastPlayedAt;
  int playCount = 0;

  /// Number of times this episode's playback was completed.
  int completedCount = 0;

  /// Accumulated content duration listened in milliseconds.
  ///
  /// Tracks how much of the episode content was consumed regardless of
  /// playback speed. E.g. a 1-hour episode played at 1.5x records 3600000.
  int totalListenedMs = 0;

  /// Accumulated real-time (wall-clock) duration spent listening in milliseconds.
  ///
  /// Tracks actual elapsed time. E.g. a 1-hour episode played at 1.5x
  /// records ~2400000 (40 minutes).
  int totalRealtimeMs = 0;
}

/// Played and in-progress semantics shared by every reader (FR 04).
extension PlaybackHistoryStatus on PlaybackHistory {
  /// Played to the end at least once, or marked played, and not since
  /// marked unplayed. A replay does not change it.
  bool get isPlayed => completedAt != null;

  /// The current listen reached the end: played and not being replayed.
  bool get isListenFinished => isPlayed && !isReplaying;

  /// The current listen has a resumable position: started and not
  /// finished. A replay of a played episode counts.
  bool get isInProgress => 0 < positionMs && !isListenFinished;
}
