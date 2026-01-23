import 'package:drift/drift.dart';

import '../../feed/models/episode.dart';

/// Drift table for tracking episode playback progress.
///
/// Stores position, completion status, timestamps, and play count
/// for each episode the user has started listening to.
class PlaybackHistories extends Table {
  /// Foreign key to Episodes table (also serves as primary key).
  IntColumn get episodeId => integer().references(Episodes, #id)();

  /// Current playback position in milliseconds.
  IntColumn get positionMs => integer().withDefault(const Constant(0))();

  /// Episode duration in milliseconds (cached from playback).
  IntColumn get durationMs => integer().nullable()();

  /// When the episode was marked as completed (null = not completed).
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// When the user first started playing this episode.
  DateTimeColumn get firstPlayedAt => dateTime().nullable()();

  /// When the user last played this episode.
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();

  /// Number of times the episode was started from the beginning.
  IntColumn get playCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {episodeId};
}
