import 'package:drift/drift.dart';

import 'episode_transcript.dart';

/// Drift table for transcript segments (cues/lines).
///
/// Populated on demand when the user opens a transcript.
/// Each segment is a timed text entry within a transcript file.
class TranscriptSegments extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to EpisodeTranscripts table.
  IntColumn get transcriptId => integer().references(EpisodeTranscripts, #id)();

  /// Start time in milliseconds.
  IntColumn get startMs => integer()();

  /// End time in milliseconds.
  IntColumn get endMs => integer()();

  /// The transcript text content.
  TextColumn get body => text()();

  /// Speaker name for this segment (nullable).
  TextColumn get speaker => text().nullable()();
}
