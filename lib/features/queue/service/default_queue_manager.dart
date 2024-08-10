import 'dart:async';

import 'package:audiflow/features/queue/data/queue_repository.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:audiflow/features/queue/service/queue_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'default_queue_manager.g.dart';

@Riverpod(keepAlive: true)
class DefaultQueueManager extends _$DefaultQueueManager
    implements QueueManager {
  @override
  Queue build() => Queue.empty();

  QueueRepository get _queueRepository => ref.read(queueRepositoryProvider);

  @override
  Future<void> ensureInitialized() async {
    state = await _queueRepository.loadQueue();
  }

  @override
  Future<QueueItem?> pop() async {
    return state.queue.isNotEmpty ? removeByIndex(0) : null;
  }

  @override
  Future<void> prepend(QueueItem item) async {
    state = state.copyWith(queue: [item, ...state.queue]);
    await _queueRepository.saveQueue(state);
  }

  @override
  Future<void> append(QueueItem item) async {
    final i = state.queue.lastIndexWhere((q) => q.type == item.type);
    if (0 <= i) {
      final newQueue = List.of(state.queue)..insert(i + 1, item);
      state = state.copyWith(queue: newQueue);
    } else if (item.type == QueueType.adhoc || state.queue.isEmpty) {
      state = state.copyWith(queue: [...state.queue, item]);
    } else {
      state = state.copyWith(queue: [item, ...state.queue]);
    }

    await _queueRepository.saveQueue(state);
  }

  @override
  Future<void> appendAll(Iterable<QueueItem> items) async {
    if (items.isEmpty) {
      return;
    }

    assert(
      items.every((item) => item.type == items.first.type),
      'All items must have the same type',
    );

    final type = items.first.type;
    final i = state.queue.lastIndexWhere((q) => q.type == type);
    if (0 <= i) {
      final newQueue = List.of(state.queue)..insertAll(i + 1, items);
      state = state.copyWith(queue: newQueue);
    } else if (type == QueueType.adhoc || state.queue.isEmpty) {
      state = state.copyWith(queue: [...state.queue, ...items]);
    } else {
      state = state.copyWith(queue: [...items, ...state.queue]);
    }

    await _queueRepository.saveQueue(state);
  }

  @override
  Future<void> replaceAll(Iterable<QueueItem> items) async {
    if (items.isEmpty) {
      return clear();
    }

    final type = items.first.type;
    final remaining = state.queue.where((q) => q.type != type);
    state = state.copyWith(
      queue: type == QueueType.primary
          ? [...items, ...remaining]
          : [...remaining, ...items],
    );
    await _queueRepository.saveQueue(state);
  }

  @override
  Future<QueueItem> removeByIndex(int index) async {
    assert(0 <= index && index < state.queue.length, 'Invalid index');

    final removedItem = state.queue[index];
    state = state.copyWith(queue: List.of(state.queue)..removeAt(index));
    await _queueRepository.saveQueue(state);
    return removedItem;
  }

  @override
  Future<void> removeFromTop({required QueueItem to}) async {
    final i = state.queue.indexOf(to);
    assert(0 <= i, 'Queue item not found');

    final primary = (to.type == QueueType.primary
            ? state.queue.sublist(i + 1)
            : state.queue)
        .where((q) => q.type == QueueType.primary);
    final adhoc =
        (to.type == QueueType.adhoc ? state.queue.sublist(i + 1) : state.queue)
            .where((q) => q.type == QueueType.adhoc);
    final newQueue = to.type == QueueType.primary
        ? [...primary, ...adhoc]
        : [...adhoc, ...primary];
    state = state.copyWith(queue: newQueue);

    await _queueRepository.saveQueue(state);
  }

  @override
  Future<void> reorder(int oldIndex, int newIndex) async {
    final newQueue = List.of(state.queue);
    final temp = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex - (oldIndex < newIndex ? 1 : 0), temp);

    state = state.copyWith(queue: newQueue);
    await _queueRepository.saveQueue(state);
  }

  @override
  Future<void> clear({QueueType? type}) async {
    final newQueue = type == QueueType.primary
        ? state.queue.where((q) => q.type == QueueType.primary)
        : type == QueueType.adhoc
            ? state.queue.where((q) => q.type == QueueType.adhoc)
            : <QueueItem>[];

    state = state.copyWith(queue: newQueue.toList());
    await _queueRepository.saveQueue(state);
  }
}
