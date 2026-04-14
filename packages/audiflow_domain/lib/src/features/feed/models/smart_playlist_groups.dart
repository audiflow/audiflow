import 'package:isar_community/isar.dart';

part 'smart_playlist_groups.g.dart';

@collection
@Name('SmartPlaylistGroup')
class SmartPlaylistGroupEntity {
  Id id = Isar.autoIncrement;

  @Index(
    composite: [CompositeIndex('playlistId'), CompositeIndex('groupId')],
    unique: true,
  )
  late int podcastId;

  late String playlistId;
  late String groupId;
  late String displayName;
  late int sortKey;
  String? thumbnailUrl;
  late String episodeIds;
  String? yearOverride;
  DateTime? earliestDate;
  DateTime? latestDate;
  int? totalDurationMs;

  /// Whether this group shows date range metadata.
  bool showDateRange = false;

  /// Per-group override for showing year separator headers.
  bool? showYearHeaders;

  /// Per-group override for prepending season number to title.
  bool? prependSeasonNumber;

  /// Per-group episode sort field (e.g. 'publishedAt').
  String? episodeSortField;

  /// Per-group episode sort direction (e.g. 'ascending').
  String? episodeSortOrder;
}
