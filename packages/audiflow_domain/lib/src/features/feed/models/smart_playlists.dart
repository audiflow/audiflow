import 'package:isar_community/isar.dart';

part 'smart_playlists.g.dart';

@collection
@Name('SmartPlaylist')
class SmartPlaylistEntity {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('playlistNumber')], unique: true)
  late int podcastId;

  late int playlistNumber;

  /// Original playlist ID from the resolver (e.g., "playlist_regular",
  /// "season_3"). Used to look up persisted groups.
  String playlistId = '';

  late String displayName;
  late int sortKey;
  late String resolverType;
  String? thumbnailUrl;
  bool yearGrouped = false;
  String playlistStructure = 'separate';
  String yearHeaderMode = 'none';

  /// Whether group cards should display a date range.
  bool showDateRange = false;

  /// Whether episode lists show year separator headers.
  bool showYearHeaders = false;

  /// Whether the user can toggle the sort order.
  bool userSortable = true;

  /// Whether to prepend season number to group titles.
  bool prependSeasonNumber = false;

  /// Persisted group sort field (e.g. 'playlistNumber').
  String? groupSortField;

  /// Persisted group sort direction (e.g. 'ascending').
  String? groupSortOrder;

  /// Persisted episode sort field (e.g. 'publishedAt').
  String? episodeSortField;

  /// Persisted episode sort direction (e.g. 'ascending').
  String? episodeSortOrder;

  /// Config version for cache invalidation.
  ///
  /// Matches [PatternSummary.dataVersion] when resolved from a
  /// config pattern. Null for generic season-based resolution.
  /// When the upstream config version changes, the cache is
  /// invalidated and re-resolved.
  int? configVersion;
}
