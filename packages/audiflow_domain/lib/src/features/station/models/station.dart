import 'package:isar_community/isar.dart';

import 'station_duration_filter.dart';
import 'station_episode_sort.dart';

part 'station.g.dart';

@collection
class Station {
  Id id = Isar.autoIncrement;

  late String name;
  int sortOrder = 0;

  /// Stored as string, use [episodeSort] getter.
  String episodeSortType = 'newest';

  // -- Filter fields (flat for simple types) --

  bool hideCompleted = false;
  bool filterDownloaded = false;
  bool filterFavorited = false;

  StationDurationFilter? durationFilter;

  /// Null means no publishedWithin filter.
  int? publishedWithinDays;

  late DateTime createdAt;
  late DateTime updatedAt;

  // -- Convenience getters (not persisted) --

  @ignore
  StationEpisodeSort get episodeSort =>
      StationEpisodeSort.fromString(episodeSortType);

  set episodeSort(StationEpisodeSort value) => episodeSortType = value.name;
}
