import 'package:isar_community/isar.dart';

part 'station_podcast.g.dart';

@collection
class StationPodcast {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('podcastId')], unique: true)
  late int stationId;

  late int podcastId;
  late DateTime addedAt;
  int? episodeLimit;
  int sortOrder = 0;
}
