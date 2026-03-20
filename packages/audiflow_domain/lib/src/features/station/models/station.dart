import 'package:isar_community/isar.dart';

import 'station_duration_filter.dart';
import 'station_episode_sort.dart';
import 'station_playback_state.dart';

part 'station.g.dart';

@collection
class Station {
  Id id = Isar.autoIncrement;

  late String name;
  int sortOrder = 0;

  /// Stored as string, use [episodeSort] getter.
  String episodeSortType = 'newest';

  // -- Filter fields (flat for simple types) --

  /// Stored as string, use [playbackStateFilter] getter.
  String playbackState = 'all';

  bool filterDownloaded = false;
  bool filterFavorited = false;

  StationDurationFilter? durationFilter;

  /// Null means no publishedWithin filter.
  int? publishedWithinDays;

  late DateTime createdAt;
  late DateTime updatedAt;

  // -- Convenience getters (not persisted) --

  @ignore
  StationPlaybackState get playbackStateFilter =>
      StationPlaybackState.fromString(playbackState);

  set playbackStateFilter(StationPlaybackState value) =>
      playbackState = value.name;

  @ignore
  StationEpisodeSort get episodeSort =>
      StationEpisodeSort.fromString(episodeSortType);

  set episodeSort(StationEpisodeSort value) => episodeSortType = value.name;
}
