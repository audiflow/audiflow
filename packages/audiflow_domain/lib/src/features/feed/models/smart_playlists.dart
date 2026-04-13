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

  /// Config version for cache invalidation.
  ///
  /// Matches [PatternSummary.dataVersion] when resolved from a
  /// config pattern. Null for generic season-based resolution.
  /// When the upstream config version changes, the cache is
  /// invalidated and re-resolved.
  int? configVersion;
}
