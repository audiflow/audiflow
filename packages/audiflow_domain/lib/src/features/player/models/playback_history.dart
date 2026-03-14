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
}
