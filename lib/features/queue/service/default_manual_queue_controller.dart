import 'dart:async';

import 'package:audiflow/events/queue_event.dart';
import 'package:audiflow/features/queue/data/manual_queue_repository.dart';
import 'package:audiflow/features/queue/model/queue_item.dart';
import 'package:audiflow/features/queue/service/manual_queue_controller.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'default_manual_queue_controller.g.dart';

@Riverpod(keepAlive: true)
class DefaultManualQueueController extends _$DefaultManualQueueController
    implements ManualQueueController {
  @override
  List<QueueItem> build() {
    _load().then(
      (_) => _listen(),
    );
    return [];
  }

  Future<void> _load() async {
    state = await ref.read(manualQueueRepositoryProvider).load();
  }

  void _listen() {
    ref.listen(manualQueueEventStreamProvider, (_, next) {
      switch (next.requireValue) {
        case ManualQueueItemAddedEvent(item: final item):
          final i = state.indexWhere((other) => item.ordinal < other.ordinal);
          if (0 <= i) {
            state = List.of(state)..insert(i, item);
          } else {
            state = [...state, item];
          }
        case ManualQueueItemsUpdatedEvent(items: final items):
          final ids = items.map((i) => i.id).toSet();
          state = [...state.where((other) => !ids.contains(other.id)), ...items]
              .sorted((a, b) => a.ordinal.compareTo(b.ordinal));
        case ManualQueueItemDeletedEvent(item: final item):
          state = state.where((other) => other.id != item.id).toList();
        case ManualQueueItemClearedEvent():
          state = [];
      }
    });
  }

  ManualQueueRepository get _repository =>
      ref.read(manualQueueRepositoryProvider);

  @override
  Future<QueueItem> append({
    required int pid,
    required int eid,
  }) {
    return _repository.append(pid: pid, eid: eid);
  }

  @override
  Future<void> clear() {
    return _repository.clear();
  }

  @override
  Future<List<QueueItem>> load() {
    return _repository.load();
  }

  @override
  Future<List<QueueItem>> move(
    QueueItem item, {
    QueueItem? before,
    QueueItem? after,
  }) {
    return _repository.move(
      item as ManualQueueItem,
      before: before as ManualQueueItem?,
      after: after as ManualQueueItem?,
    );
  }

  @override
  Future<ManualQueueItem> prepend({
    required int pid,
    required int eid,
  }) {
    return _repository.prepend(pid: pid, eid: eid);
  }

  @override
  Future<List<QueueItem>> remove(QueueItem item) {
    return _repository.remove(item));
  }

  @override
  Future<ManualQueueItem?> pop() {
    return _repository.pop();
  }
}
