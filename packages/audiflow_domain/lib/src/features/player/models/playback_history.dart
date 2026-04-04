import 'package:isar_community/isar.dart';

part 'playback_history.g.dart';

@collection
class PlaybackHistory {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int episodeId;

  int positionMs = 0;
  int? durationMs;
  DateTime? completedAt;
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
