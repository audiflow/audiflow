import 'package:audiflow/features/queue/data/manual_queue_repository.dart';
import 'package:audiflow/features/queue/model/queue_item.dart';
import 'package:collection/collection.dart';
import 'package:isar/isar.dart';

class IsarManualQueueRepository implements ManualQueueRepository {
  IsarManualQueueRepository(this.isar);

  final Isar isar;
  static const _ordinalStep = 10;

  @override
  Future<List<ManualQueueItem>> load() async {
    return isar.manualQueueItems.where().sortByOrdinal().findAll();
  }

  @override
  Future<ManualQueueItem> prepend({
    required int pid,
    required int eid,
  }) async {
    return isar.writeTxn(() async {
      final first =
          await isar.manualQueueItems.where().sortByOrdinal().findFirst();
      final ordinal = (first?.ordinal ?? 1000) - _ordinalStep;
      final newItem = ManualQueueItem(
        pid: pid,
        eid: eid,
        ordinal: ordinal,
      );
      await isar.manualQueueItems.put(newItem);
      return newItem;
    });
  }

  @override
  Future<ManualQueueItem> append({
    required int pid,
    required int eid,
  }) async {
    return isar.writeTxn(() async {
      final first =
          await isar.manualQueueItems.where().sortByOrdinal().findFirst();
      final ordinal = (first?.ordinal ?? 1000) + _ordinalStep;
      final newItem = ManualQueueItem(
        pid: pid,
        eid: eid,
        ordinal: ordinal,
      );
      await isar.manualQueueItems.put(newItem);
      return newItem;
    });
  }

  @override
  Future<List<ManualQueueItem>> move(
    ManualQueueItem item, {
    ManualQueueItem? before,
    ManualQueueItem? after,
  }) async {
    assert((before == null) != (after == null));
    return isar.writeTxn(() async {
      return before != null
          ? _moveBefore(item, before)
          : _moveAfter(item, after!);
    });
  }

  @override
  Future<ManualQueueItem?> pop() async {
    return isar.writeTxn(() async {
      final first =
          await isar.manualQueueItems.where().sortByOrdinal().findFirst();
      if (first == null) {
        return null;
      }
      await isar.manualQueueItems.delete(first.id!);
      return first;
    });
  }

  @override
  Future<void> clear() async {
    await isar.writeTxn(() => isar.manualQueueItems.clear());
  }

  Future<List<ManualQueueItem>> _moveBefore(
    ManualQueueItem item,
    ManualQueueItem before,
  ) async {
    final items = await isar.manualQueueItems
        .where()
        .ordinalLessThan(before.ordinal)
        .sortByOrdinalDesc()
        .limit(2)
        .findAll();
    if (items.isEmpty) {
      // Move to the top
      final newItem = item.copyWith(
        ordinal: before.ordinal - _ordinalStep,
      );
      await isar.manualQueueItems.put(newItem);
      return [newItem];
    } else if (items.contains(item)) {
      if (items[1].id == item.id) {
        // Already in the correct position
        return [];
      }
      // swap positions
      final newItems = [
        items[0].copyWith(ordinal: items[1].ordinal),
        items[1].copyWith(ordinal: items[0].ordinal),
      ];
      await isar.manualQueueItems.putAll(newItems);
      return newItems;
    }

    if (2 <= items[1].ordinal - before.ordinal) {
      // There is enough space between `items[1]` and `before`.
      final newItem = item.copyWith(
        ordinal: (items[1].ordinal + before.ordinal) ~/ 2,
      );
      await isar.manualQueueItems.put(newItem);
      return [newItem];
    } else if (3 < items.first.ordinal - before.ordinal) {
      // We can still insert one item between `items[0]` and `before` by
      // arranging `items[1].ordinal`.
      final step = (items.first.ordinal - before.ordinal) ~/ 3;
      final newItems = [
        items[1].copyWith(ordinal: items[0].ordinal + step),
        item.copyWith(ordinal: items[0].ordinal + step * 2),
      ];
      await isar.manualQueueItems.putAll(newItems);
      return newItems;
    }

    // Reorder all items before `before`.
    final rest = await isar.manualQueueItems
        .where()
        .ordinalLessThan(before.ordinal)
        .sortByOrdinalDesc()
        .findAll();
    final newItems = rest
        .mapIndexed(
          (i, e) =>
              e.copyWith(ordinal: before.ordinal - (i + 1) * _ordinalStep),
        )
        .toList();
    await isar.manualQueueItems.putAll(newItems);
    return newItems;
  }

  Future<List<ManualQueueItem>> _moveAfter(
    ManualQueueItem item,
    ManualQueueItem after,
  ) async {
    final items = await isar.manualQueueItems
        .where()
        .ordinalGreaterThan(after.ordinal)
        .sortByOrdinal()
        .limit(2)
        .findAll();
    if (items.isEmpty) {
      // Move to the bottom
      final newItem = item.copyWith(
        ordinal: after.ordinal + _ordinalStep,
      );
      await isar.manualQueueItems.put(newItem);
      return [newItem];
    } else if (items.contains(item)) {
      if (items[0].id == item.id) {
        // Already in the correct position
        return [];
      }
      // swap positions
      final newItems = [
        items[0].copyWith(ordinal: items[1].ordinal),
        items[1].copyWith(ordinal: items[0].ordinal),
      ];
      await isar.manualQueueItems.putAll(newItems);
      return newItems;
    }

    if (2 <= after.ordinal - items[0].ordinal) {
      // There is enough space between `after` and `items[0]`.
      final newItem = item.copyWith(
        ordinal: (items[0].ordinal + after.ordinal) ~/ 2,
      );
      await isar.manualQueueItems.put(newItem);
      return [newItem];
    } else if (3 < after.ordinal - items[1].ordinal) {
      // We can still insert one item between `after` and `items[1]` by
      // arranging `items[0].ordinal`.
      final step = (after.ordinal - items[1].ordinal) ~/ 3;
      final newItems = [
        items[0].copyWith(ordinal: items[1].ordinal + step),
        item.copyWith(ordinal: items[1].ordinal + step * 2),
      ];
      await isar.manualQueueItems.putAll(newItems);
      return newItems;
    }

    // Reorder all items after `after`.
    final rest = await isar.manualQueueItems
        .where()
        .ordinalGreaterThan(after.ordinal)
        .sortByOrdinal()
        .findAll();
    final newItems = rest
        .mapIndexed(
          (i, e) => e.copyWith(ordinal: after.ordinal + (i + 1) * _ordinalStep),
        )
        .toList();
    await isar.manualQueueItems.putAll(newItems);
    return newItems;
  }
}
