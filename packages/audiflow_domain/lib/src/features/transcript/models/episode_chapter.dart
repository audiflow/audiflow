import 'package:isar_community/isar.dart';

part 'episode_chapter.g.dart';

@collection
class EpisodeChapter {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('sortOrder')], unique: true)
  late int episodeId;

  late int sortOrder;
  late String title;
  late int startMs;
  int? endMs;
  String? url;
  String? imageUrl;
}
