import 'package:drift/drift.dart';

import '../../feed/models/episode.dart';

/// Drift table for episode chapters.
///
/// Populated during feed sync from RSS `<podcast:chapters>` data.
/// Chapters provide navigation points within an episode.
class EpisodeChapters extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to Episodes table.
  IntColumn get episodeId => integer().references(Episodes, #id)();

  /// Order of this chapter within the episode.
  IntColumn get sortOrder => integer()();

  /// Chapter title.
  TextColumn get title => text()();

  /// Start time in milliseconds.
  IntColumn get startMs => integer()();

  /// End time in milliseconds (nullable, may extend to next chapter).
  IntColumn get endMs => integer().nullable()();

  /// External URL associated with this chapter (nullable).
  TextColumn get url => text().nullable()();

  /// Chapter artwork URL (nullable).
  TextColumn get imageUrl => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {episodeId, sortOrder},
  ];
}
