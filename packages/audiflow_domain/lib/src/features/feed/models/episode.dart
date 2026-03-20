import 'package:isar_community/isar.dart';

part 'episode.g.dart';

@collection
class Episode {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('guid')], unique: true)
  late int podcastId;

  late String guid;
  late String title;
  String? description;
  late String audioUrl;
  int? durationMs;
  DateTime? publishedAt;
  String? imageUrl;
  int? episodeNumber;
  int? seasonNumber;
  bool isFavorited = false;
  DateTime? favoritedAt;
}
