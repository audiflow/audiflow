import 'package:isar/isar.dart';

part 'playing_episode.g.dart';

@collection
class PlayingEpisode {
  PlayingEpisode({
    required this.eid,
  });

  final Id id = 1;
  final int? eid;
}
