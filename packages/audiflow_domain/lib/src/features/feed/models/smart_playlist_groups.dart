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
}
