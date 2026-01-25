import 'package:drift/drift.dart';

import '../../subscription/models/subscriptions.dart';

/// Drift table for persisted season metadata.
///
/// Uses composite primary key (podcastId, seasonNumber) for natural joins
/// with Episodes table without requiring FK modifications.
class Seasons extends Table {
  /// Foreign key to Subscriptions table (part of composite PK).
  IntColumn get podcastId => integer().references(Subscriptions, #id)();

  /// Season number matching episode.seasonNumber (part of composite PK).
  /// Use 0 for ungrouped/extras seasons like "番外編".
  IntColumn get seasonNumber => integer()();

  /// Display name (e.g., "リンカン編", "番外編").
  TextColumn get displayName => text()();

  /// Sort key for ordering seasons (typically max episodeNumber in season).
  IntColumn get sortKey => integer()();

  /// Resolver type that generated this season (e.g., "rss").
  TextColumn get resolverType => text()();

  @override
  Set<Column> get primaryKey => {podcastId, seasonNumber};
}
