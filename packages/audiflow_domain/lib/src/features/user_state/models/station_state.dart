import 'package:isar_community/isar.dart';

part 'station_state.g.dart';

/// A station's settings, named so every device refers to it the same way
/// (docs/architecture/user-data-sync.md, "Local storage").
///
/// `Station` stays as the local copy the app reads; this row is what
/// syncs. Each value carries the [Hlc] of its last change (`*Hlc`, packed).
/// A deleted station stays as a row with [deleted] set, so the removal can
/// win a merge.
@collection
class StationState {
  Id id = Isar.autoIncrement;

  /// A UUIDv7, also stored on `Station.stationId`.
  @Index(unique: true)
  late String stationId;

  String name = '';
  int nameHlc = 0;

  int sortOrder = 0;
  int sortOrderHlc = 0;

  String episodeSortType = 'newest';
  int episodeSortTypeHlc = 0;

  bool hideCompleted = false;
  int hideCompletedHlc = 0;

  bool filterDownloaded = false;
  int filterDownloadedHlc = 0;

  bool filterFavorited = false;
  int filterFavoritedHlc = 0;

  /// The duration filter, flattened: [durationOperator] is null when off.
  String? durationOperator;
  int durationMinutes = 0;
  int durationFilterHlc = 0;

  int? publishedWithinDays;
  int publishedWithinDaysHlc = 0;

  int? defaultEpisodeLimit;
  int defaultEpisodeLimitHlc = 0;

  bool groupByPodcast = false;
  int groupByPodcastHlc = 0;

  String podcastSortType = 'manual';
  int podcastSortTypeHlc = 0;

  DateTime? lastPlayedAt;
  int lastPlayedAtHlc = 0;

  /// When the station was created; never changes.
  DateTime? createdAt;

  bool deleted = false;
  int deletedHlc = 0;
}

/// One podcast of a station, by the podcast's stable key.
@collection
class StationMember {
  Id id = Isar.autoIncrement;

  @Index(unique: true, composite: [CompositeIndex('podcastKey')])
  late String stationId;

  late String podcastKey;

  int? episodeLimit;
  int episodeLimitHlc = 0;

  int sortOrder = 0;
  int sortOrderHlc = 0;

  /// When the podcast joined the station; never changes.
  DateTime? addedAt;

  bool deleted = false;
  int deletedHlc = 0;
}
