import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';

/// Local datasource for queue item persistence using Drift.
///
/// Provides low-level database operations for the QueueItems table.
/// Used by QueueRepository to manage the play queue.
class QueueLocalDatasource {
  QueueLocalDatasource(this._db);

  final AppDatabase _db;

  /// Inserts a new queue item. Returns the inserted item's ID.
  Future<int> insert(QueueItemsCompanion companion) {
    return _db.into(_db.queueItems).insert(companion);
  }

  /// Gets all queue items ordered by position.
  Future<List<QueueItem>> getAll() {
    return (_db.select(
      _db.queueItems,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
  }

  /// Watches all queue items ordered by position.
  Stream<List<QueueItem>> watchAll() {
    return (_db.select(
      _db.queueItems,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).watch();
  }

  /// Gets the maximum position value in the queue.
  ///
  /// Returns -10 if no items exist (allows first item to use position 0).
  Future<int> getMaxPosition() async {
    final query = _db.selectOnly(_db.queueItems)
      ..addColumns([_db.queueItems.position.max()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.queueItems.position.max()) ?? -10;
  }

  /// Gets the minimum position value in the queue.
  ///
  /// Returns 10 if no items exist (allows first item to use position 0).
  Future<int> getMinPosition() async {
    final query = _db.selectOnly(_db.queueItems)
      ..addColumns([_db.queueItems.position.min()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.queueItems.position.min()) ?? 10;
  }

  /// Updates the position of a queue item.
  Future<int> updatePosition(int id, int newPosition) {
    return (_db.update(_db.queueItems)..where((t) => t.id.equals(id))).write(
      QueueItemsCompanion(position: Value(newPosition)),
    );
  }

  /// Deletes a queue item by ID.
  Future<int> deleteById(int id) {
    return (_db.delete(_db.queueItems)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all queue items.
  Future<int> deleteAll() {
    return _db.delete(_db.queueItems).go();
  }

  /// Deletes all adhoc queue items.
  Future<int> deleteAllAdhoc() {
    return (_db.delete(
      _db.queueItems,
    )..where((t) => t.isAdhoc.equals(true))).go();
  }

  /// Deletes all manual (non-adhoc) queue items.
  Future<int> deleteAllManual() {
    return (_db.delete(
      _db.queueItems,
    )..where((t) => t.isAdhoc.equals(false))).go();
  }

  /// Gets count of manual (non-adhoc) items.
  Future<int> getManualCount() async {
    final query = _db.selectOnly(_db.queueItems)
      ..where(_db.queueItems.isAdhoc.equals(false))
      ..addColumns([_db.queueItems.id.count()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.queueItems.id.count()) ?? 0;
  }

  /// Gets count of adhoc items.
  Future<int> getAdhocCount() async {
    final query = _db.selectOnly(_db.queueItems)
      ..where(_db.queueItems.isAdhoc.equals(true))
      ..addColumns([_db.queueItems.id.count()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.queueItems.id.count()) ?? 0;
  }

  /// Shifts all positions by a delta (used for Play Next insertion).
  Future<void> shiftPositions(int delta) async {
    await _db.customStatement(
      'UPDATE queue_items SET position = position + ?',
      [delta],
    );
  }

  /// Shifts positions of items at or after a given position.
  Future<void> shiftPositionsFrom(int fromPosition, int delta) async {
    await _db.customStatement(
      'UPDATE queue_items SET position = position + ? WHERE position >= ?',
      [delta, fromPosition],
    );
  }
}
