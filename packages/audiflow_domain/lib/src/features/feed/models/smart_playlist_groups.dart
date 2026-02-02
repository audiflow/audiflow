import 'package:drift/drift.dart';

import '../../subscription/models/subscriptions.dart';

/// Drift table for persisted smart playlist group data.
@DataClassName('SmartPlaylistGroupEntity')
class SmartPlaylistGroups extends Table {
  IntColumn get podcastId => integer().references(Subscriptions, #id)();
  TextColumn get playlistId => text()();
  TextColumn get groupId => text()();
  TextColumn get displayName => text()();
  IntColumn get sortKey => integer()();
  TextColumn get thumbnailUrl => text().nullable()();

  /// JSON-encoded list of episode IDs.
  TextColumn get episodeIds => text()();
  TextColumn get yearOverride => text().nullable()();
  DateTimeColumn get earliestDate => dateTime().nullable()();
  DateTimeColumn get latestDate => dateTime().nullable()();
  IntColumn get totalDurationMs => integer().nullable()();
  BoolColumn get episodeYearHeaders => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {podcastId, playlistId, groupId};
}
