import 'package:audiflow/events/queue_event.dart';
import 'package:audiflow/features/queue/data/manual_queue_repository.dart';
import 'package:audiflow/features/queue/model/queue_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManualQueueRepositoryChangeHandler implements ManualQueueRepository {
  ManualQueueRepositoryChangeHandler(this._ref, this._inner);

  final Ref _ref;
  final ManualQueueRepository _inner;

  @override
  Future<List<ManualQueueItem>> load() => _inner.load();

  @override
  Future<ManualQueueItem> prepend({
    required int pid,
    required int eid,
  }) async {
    final item = await _inner.prepend(pid: pid, eid: eid);
    _ref
        .read(manualQueueEventStreamProvider.notifier)
        .add(ManualQueueItemAddedEvent(item));
    return item;
  }

  @override
  Future<ManualQueueItem> append({
    required int pid,
    required int eid,
  }) async {
    final item = await _inner.append(pid: pid, eid: eid);
    _ref
        .read(manualQueueEventStreamProvider.notifier)
        .add(ManualQueueItemAddedEvent(item));
    return item;
  }

  @override
  Future<List<ManualQueueItem>> move(
    ManualQueueItem item, {
    ManualQueueItem? before,
    ManualQueueItem? after,
  }) async {
    final items = await _inner.move(item, before: before, after: after);
    _ref
        .read(manualQueueEventStreamProvider.notifier)
        .add(ManualQueueItemsUpdatedEvent(items));
    return items;
  }

  @override
  Future<void> remove(ManualQueueItem item) async {
    await _inner.remove(item);
    _ref
        .read(manualQueueEventStreamProvider.notifier)
        .add(ManualQueueItemsRemovedEvent(item));
  }

  @override
  Future<ManualQueueItem?> pop() async {
    final item = await _inner.pop();
    if (item != null) {
      _ref
          .read(manualQueueEventStreamProvider.notifier)
          .add(ManualQueueItemDeletedEvent(item));
    }
    return item;
  }

  @override
  Future<void> clear() async {
    await _inner.clear();
    _ref
        .read(manualQueueEventStreamProvider.notifier)
        .add(const ManualQueueItemClearedEvent());
  }
}
