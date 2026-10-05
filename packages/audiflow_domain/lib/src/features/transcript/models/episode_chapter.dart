import 'package:isar_community/isar.dart';

import 'chapter_source.dart';

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

  /// Origin of this chapter.
  ///
  /// Rows written before this field existed read back as
  /// [ChapterSource.podlove]; see [ChapterSource] for why.
  @Enumerated(EnumType.name)
  ChapterSource source = ChapterSource.podlove;

  /// URL of the file these chapters were fetched from, for sources that
  /// live outside the feed (`<podcast:chapters>` JSON); null otherwise.
  String? sourceUrl;
}
