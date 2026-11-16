import 'package:isar_community/isar.dart';

import '../../models/queue_item.dart';
import '../../../user_state/services/queue_entry_access.dart';
import '../../../user_state/services/user_state_store.dart';

/// Local datasource for queue item persistence using Isar.
///
/// Provides low-level database operations for the QueueItem collection.
/// Used by QueueRepository to manage the play queue. Every write also
/// records the change on the item's `QueueEntry`, the copy that syncs
/// (see [QueueEntryAccess]).
class QueueLocalDatasource {
  QueueLocalDatasource(this._isar);

  final Isar _isar;

  /// User state writes go through the store; see [UserStateStore].
  late final _store = UserStateStore(_isar);
  late final _entries = QueueEntryAccess(_isar);

  /// Deletes [items] after marking their entries removed.
  Future<void> _deleteAll(List<QueueItem> items, UserStateTxn txn) async {
    await _entries.removeAll(items, txn);
    await _isar.queueItems.deleteAll([for (final i in items) i.id]);
  }

  /// Inserts a new queue item. Returns the inserted item's ID.
  Future<int> insert(QueueItem item) async {
    await _store.write((txn) => _entries.saveAll([item], txn));
    return item.id;
  }

  /// Inserts [episodeIds] as manual items before every existing item
  /// ([atFront]) or after them, keeping their order and [spacing] apart.
  ///
  /// The position lookup and all inserts share one transaction, so a queue
  /// change made meanwhile (e.g. a clear) cannot split the range.
  Future<void> insertManualRange(
    List<int> episodeIds, {
    required bool atFront,
    required int spacing,
  }) async {
    if (episodeIds.isEmpty) return;
    await _store.write((txn) async {
      final firstPosition = atFront
          ? await getMinPosition() - spacing * episodeIds.length
          : await getMaxPosition() + spacing;
      final now = DateTime.now();
      final items = [
        for (var i = 0; i < episodeIds.length; i++)
          QueueItem()
            ..episodeId = episodeIds[i]
            ..position = firstPosition + spacing * i
            ..isAdhoc = false
            ..addedAt = now,
      ];
      await _entries.saveAll(items, txn);
    });
  }

  /// Gets all queue items ordered by position.
  Future<List<QueueItem>> getAll() async {
    final items = await _isar.queueItems.where().sortByPosition().findAll();
    await _entries.compare(items);
    return items;
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
  Future<int> updatePosition(int id, int newPosition) {
    // Read inside the transaction so a concurrent write is not undone.
    return _store.write((txn) async {
      final item = await _isar.queueItems.get(id);
      if (item == null) return 0;
      item.position = newPosition;
      await _entries.saveAll([item], txn);
      return 1;
    });
  }

  /// Deletes a queue item by ID.
  ///
  /// Returns 1 if deleted, 0 if not found.
  Future<int> deleteById(int id) {
    return _store.write((txn) async {
      final item = await _isar.queueItems.get(id);
      if (item == null) return 0;
      await _deleteAll([item], txn);
      return 1;
    });
  }

  /// Deletes all queue items.
  Future<int> deleteAll() async {
    await _store.write((txn) async {
      await _deleteAll(await _isar.queueItems.where().findAll(), txn);
    });
    return 0;
  }

  /// Deletes all adhoc queue items.
  Future<int> deleteAllAdhoc() => _deleteWhere(adhoc: true);

  /// Deletes all manual (non-adhoc) queue items.
  Future<int> deleteAllManual() => _deleteWhere(adhoc: false);

  Future<int> _deleteWhere({required bool adhoc}) {
    return _store.write((txn) async {
      final items = await _isar.queueItems
          .filter()
          .isAdhocEqualTo(adhoc)
          .findAll();
      await _deleteAll(items, txn);
      return items.length;
    });
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
  Future<void> shiftPositions(int delta) {
    return _store.write((txn) async {
      final items = await _isar.queueItems.where().findAll();
      for (final item in items) {
        item.position = item.position + delta;
      }
      await _entries.saveAll(items, txn);
    });
  }

  /// Shifts positions of items at or after a given position.
  Future<void> shiftPositionsFrom(int fromPosition, int delta) {
    return _store.write((txn) async {
      // fromPosition <= position (items at or after fromPosition)
      final items = await _isar.queueItems
          .filter()
          .positionGreaterThan(fromPosition - 1)
          .findAll();
      for (final item in items) {
        item.position = item.position + delta;
      }
      await _entries.saveAll(items, txn);
    });
  }
}
