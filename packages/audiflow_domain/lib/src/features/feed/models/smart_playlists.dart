import 'package:isar_community/isar.dart';

part 'smart_playlists.g.dart';

@collection
@Name('SmartPlaylist')
class SmartPlaylistEntity {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('playlistNumber')], unique: true)
  late int podcastId;

  late int playlistNumber;
  late String displayName;
  late int sortKey;
  late String resolverType;
  String? thumbnailUrl;
  bool yearGrouped = false;
  String playlistStructure = 'split';
  String yearHeaderMode = 'none';
}
