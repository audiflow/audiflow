import 'package:isar_community/isar.dart';

part 'smart_playlist_user_preference.g.dart';

@collection
@Name('SmartPlaylistUserPreference')
class SmartPlaylistUserPreference {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('playlistId')], unique: true)
  late int podcastId;

  late String playlistId;

  String? autoPlayOrder;
}
