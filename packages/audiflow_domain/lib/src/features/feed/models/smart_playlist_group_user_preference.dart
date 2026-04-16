import 'package:isar_community/isar.dart';

part 'smart_playlist_group_user_preference.g.dart';

@collection
@Name('SmartPlaylistGroupUserPreference')
class SmartPlaylistGroupUserPreference {
  Id id = Isar.autoIncrement;

  @Index(
    composite: [CompositeIndex('playlistId'), CompositeIndex('groupId')],
    unique: true,
  )
  late int podcastId;

  late String playlistId;
  late String groupId;

  String? autoPlayOrder;
}
