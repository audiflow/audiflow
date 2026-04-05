import 'package:isar_community/isar.dart';

part 'station_episode.g.dart';

@collection
class StationEpisode {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('episodeId')], unique: true)
  late int stationId;

  late int episodeId;

  /// Copy of Episode.publishedAt for Isar-native sort + pagination.
  DateTime? sortKey;

  /// Sort key for grouped-by-podcast ordering.
  int podcastSortKey = 0;
}
