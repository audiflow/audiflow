import 'package:isar_community/isar.dart';

import '../../models/queue_item.dart';

/// Local datasource for queue item persistence using Isar.
///
/// Provides low-level database operations for the QueueItem collection.
/// Used by QueueRepository to manage the play queue.
class QueueLocalDatasource {
  QueueLocalDatasource(this._isar);

  final Isar _isar;

  /// Inserts a new queue item. Returns the inserted item's ID.
  Future<int> insert(QueueItem item) async {
    await _isar.writeTxn(() => _isar.queueItems.put(item));
    return item.id;
  }

  /// Gets all queue items ordered by position.
  Future<List<QueueItem>> getAll() {
    return _isar.queueItems.where().sortByPosition().findAll();
  }

  /// Watches all queue items ordered by position.
  Stream<List<QueueItem>> watchAll() {
    return _isar.queueItems.where().sortByPosition().watch(
      fireImmediately: true,
    );
  }

  /// Gets the maximum position value in the queue.
  ///
  /// Returns -10 if no items exist (allows first item to use position 0).
  Future<int> getMaxPosition() async {
    final item = await _isar.queueItems
        .where()
        .sortByPositionDesc()
        .findFirst();
    return item?.position ?? -10;
  }

  /// Gets the minimum position value in the queue.
  ///
  /// Returns 10 if no items exist (allows first item to use position 0).
  Future<int> getMinPosition() async {
    final item = await _isar.queueItems.where().sortByPosition().findFirst();
    return item?.position ?? 10;
  }

  /// Updates the position of a queue item.
  ///
  /// Returns 1 if updated, 0 if not found.
  Future<int> updatePosition(int id, int newPosition) async {
    final item = await _isar.queueItems.get(id);
    if (item == null) return 0;

    item.position = newPosition;
    await _isar.writeTxn(() => _isar.queueItems.put(item));
    return 1;
  }

  /// Deletes a queue item by ID.
  ///
  /// Returns 1 if deleted, 0 if not found.
  Future<int> deleteById(int id) async {
    final deleted = await _isar.writeTxn(() => _isar.queueItems.delete(id));
    return deleted ? 1 : 0;
  }

  /// Deletes all queue items.
  Future<int> deleteAll() async {
    await _isar.writeTxn(() => _isar.queueItems.clear());
    return 0;
  }

  /// Deletes all adhoc queue items.
  Future<int> deleteAllAdhoc() {
    return _isar.writeTxn(
      () => _isar.queueItems.filter().isAdhocEqualTo(true).deleteAll(),
    );
  }

  /// Deletes all manual (non-adhoc) queue items.
  Future<int> deleteAllManual() {
    return _isar.writeTxn(
      () => _isar.queueItems.filter().isAdhocEqualTo(false).deleteAll(),
    );
  }

  /// Gets count of manual (non-adhoc) items.
  Future<int> getManualCount() {
    return _isar.queueItems.filter().isAdhocEqualTo(false).count();
  }

  /// Gets count of adhoc items.
  Future<int> getAdhocCount() {
    return _isar.queueItems.filter().isAdhocEqualTo(true).count();
  }

  /// Shifts all positions by a delta (used for Play Next insertion).
  Future<void> shiftPositions(int delta) async {
    final items = await getAll();
    for (final item in items) {
      item.position = item.position + delta;
    }
    await _isar.writeTxn(() => _isar.queueItems.putAll(items));
  }

  /// Shifts positions of items at or after a given position.
  Future<void> shiftPositionsFrom(int fromPosition, int delta) async {
    // fromPosition <= position (items at or after fromPosition)
    final items = await _isar.queueItems
        .filter()
        .positionGreaterThan(fromPosition - 1)
        .findAll();
    for (final item in items) {
      item.position = item.position + delta;
    }
    await _isar.writeTxn(() => _isar.queueItems.putAll(items));
  }
}
