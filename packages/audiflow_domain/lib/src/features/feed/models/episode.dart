import 'package:drift/drift.dart';

import '../../subscription/models/subscriptions.dart';

/// Drift table for podcast episodes.
///
/// Persisted when podcast feed is fetched. Upserted on feed refresh
/// using the composite unique key (podcastId, guid).
class Episodes extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to Subscriptions table.
  IntColumn get podcastId => integer().references(Subscriptions, #id)();

  /// Unique identifier from RSS feed (guid element).
  TextColumn get guid => text()();

  /// Episode title.
  TextColumn get title => text()();

  /// Episode description/show notes (nullable).
  TextColumn get description => text().nullable()();

  /// URL to the audio file.
  TextColumn get audioUrl => text()();

  /// Duration in milliseconds (nullable, may not be in feed).
  IntColumn get durationMs => integer().nullable()();

  /// Publication date (nullable).
  DateTimeColumn get publishedAt => dateTime().nullable()();

  /// Episode artwork URL (nullable, falls back to podcast artwork).
  TextColumn get imageUrl => text().nullable()();

  /// Episode number within season (nullable).
  IntColumn get episodeNumber => integer().nullable()();

  /// Season number (nullable).
  IntColumn get seasonNumber => integer().nullable()();

  /// Composite unique key for upsert matching.
  @override
  List<Set<Column>> get uniqueKeys => [
    {podcastId, guid},
  ];
}
