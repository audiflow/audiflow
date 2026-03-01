import 'package:drift/drift.dart';

import '../../feed/models/episode.dart';

/// Drift table for episode transcript metadata.
///
/// Populated during feed sync from RSS `<podcast:transcript>` tags.
/// Each episode may have multiple transcripts in different formats.
class EpisodeTranscripts extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to Episodes table.
  IntColumn get episodeId => integer().references(Episodes, #id)();

  /// URL where the transcript file is hosted.
  TextColumn get url => text()();

  /// MIME type of the transcript (e.g., 'text/vtt', 'application/srt').
  TextColumn get type => text()();

  /// Language code for the transcript (nullable).
  TextColumn get language => text().nullable()();

  /// Relationship tag (e.g., 'captions') (nullable).
  TextColumn get rel => text().nullable()();

  /// When the transcript content was last fetched (nullable).
  DateTimeColumn get fetchedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {episodeId, url},
  ];
}
