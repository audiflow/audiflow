import 'package:drift/drift.dart';

import '../../feed/models/episode.dart';

/// Queue items table for persistent queue storage.
///
/// Supports both manual queue items (user-added) and adhoc queue items
/// (auto-generated from episode lists).
class QueueItems extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Reference to the episode in the queue.
  IntColumn get episodeId => integer().references(Episodes, #id)();

  /// Position in the queue (sparse values: 0, 10, 20... for easy insertion).
  IntColumn get position => integer()();

  /// Whether this is an adhoc queue item (true) or manual (false).
  BoolColumn get isAdhoc => boolean().withDefault(const Constant(false))();

  /// Source context for adhoc items (e.g., "Season 2").
  TextColumn get sourceContext => text().nullable()();

  /// When this item was added to the queue.
  DateTimeColumn get addedAt => dateTime()();
}
