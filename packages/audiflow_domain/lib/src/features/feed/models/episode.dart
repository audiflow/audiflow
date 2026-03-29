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

  /// Rich HTML content from <content:encoded>.
  String? contentEncoded;

  /// iTunes summary (fallback for show notes).
  String? summary;

  /// Episode web page URL.
  String? link;

  bool isFavorited = false;
  DateTime? favoritedAt;
}
