import 'dart:async';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/repository_provider.dart';
import 'package:seasoning/services/queue/queue_manager.dart';

part 'default_queue_manager.g.dart';

@Riverpod(keepAlive: true)
class DefaultQueueManager extends _$DefaultQueueManager
    implements QueueManager {
  @override
  Queue build() => const Queue();

  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<void> setup() async {
    state = await _repository.loadQueue();
  }

  @override
  Future<QueueItem?> pop() async {
    if (state.primary.isNotEmpty) {
      return removeByIndex(QueueType.primary, 0);
    } else if (state.adhoc.isNotEmpty) {
      return removeByIndex(QueueType.adhoc, 0);
    } else {
      return null;
    }
  }

  @override
  Future<void> prepend(QueueItem item) async {
    final isNewEpisode = !state.contains(item.guid);

    if (item.type == QueueType.primary) {
      final newQueue = [item, ...state.primary];
      state = state.copyWith(primary: newQueue);
    } else {
      final newQueue = [item, ...state.adhoc];
      state = state.copyWith(adhoc: newQueue);
    }

    await _repository.saveQueue(state);
    if (isNewEpisode) {
      await _markEpisodeAsQueued(item.guid);
    }
  }

  @override
  Future<void> append(QueueItem item) async {
    final isNewEpisode = !state.contains(item.guid);
    if (item.type == QueueType.primary) {
      final newQueue = [...state.primary, item];
      state = state.copyWith(primary: newQueue);
    } else {
      final newQueue = [...state.adhoc, item];
      state = state.copyWith(adhoc: newQueue);
    }

    await _repository.saveQueue(state);
    if (isNewEpisode) {
      await _markEpisodeAsQueued(item.guid);
    }
  }

  @override
  Future<void> addAll(Iterable<QueueItem> items) async {
    assert(
      items.isEmpty || items.every((item) => item.type == items.first.type),
      'All items must have the same type',
    );

    if (items.first.type == QueueType.primary) {
      final newQueue = [...state.primary, ...items];
      state = state.copyWith(primary: newQueue);
    } else {
      final newQueue = [...state.adhoc, ...items];
      state = state.copyWith(adhoc: newQueue);
    }

    await _repository.saveQueue(state);
    await Future.wait(items.map((item) => _markEpisodeAsQueued(item.guid)));
  }

  @override
  Future<void> replaceAll(Iterable<QueueItem> items) async {
    final type = items.first.type;
    final removingItems =
        type == QueueType.primary ? state.primary : state.adhoc;
    final newEpisodes = items.map((item) => item.guid).whereNot(state.contains);

    state = state.copyWith(
      primary: type == QueueType.primary ? [...items] : state.primary,
      adhoc: type == QueueType.adhoc ? [...items] : state.adhoc,
    );
    await _repository.saveQueue(state);

    final purgingEpisodes =
        removingItems.map((item) => item.guid).whereNot(state.contains);
    await Future.wait([
      ...purgingEpisodes.map(_unmarkEpisodeAsQueued),
      ...newEpisodes.map(_markEpisodeAsQueued),
    ]);
  }

  @override
  Future<QueueItem> removeByIndex(QueueType type, int index) async {
    final queue = type == QueueType.primary ? state.primary : state.adhoc;
    assert(0 <= index && index < queue.length, 'Invalid index');

    final removedItem = queue[index];
    final newQueue = List.of(queue)..removeAt(index);

    state = state.copyWith(
      primary: type == QueueType.primary ? newQueue : state.primary,
      adhoc: type == QueueType.adhoc ? newQueue : state.adhoc,
    );
    await _repository.saveQueue(state);

    if (!state.contains(removedItem.guid)) {
      await _unmarkEpisodeAsQueued(removedItem.guid);
    }
    return removedItem;
  }

  @override
  Future<void> removeFromTop({required QueueItem to}) async {
    final queue = to.type == QueueType.primary ? state.primary : state.adhoc;
    final i = queue.indexOf(to);
    assert(0 <= i, 'Queue item not found');
    await replaceAll(queue.sublist(i + 1));
  }

  @override
  Future<void> reorder(QueueType type, int oldIndex, int newIndex) async {
    final queue = type == QueueType.primary ? state.primary : state.adhoc;
    assert(0 <= newIndex && newIndex <= queue.length, 'Invalid newIndex');

    final newQueue = List.of(queue);
    final temp = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex - (oldIndex < newIndex ? 1 : 0), temp);

    state = state.copyWith(
      primary: type == QueueType.primary ? newQueue : state.primary,
      adhoc: type == QueueType.adhoc ? newQueue : state.adhoc,
    );
    await _repository.saveQueue(state);
  }

  @override
  Future<void> clear({QueueType? type}) async {
    final removingItems = type == QueueType.primary
        ? state.primary
        : type == QueueType.adhoc
            ? state.adhoc
            : [...state.primary, ...state.adhoc];

    state = state.copyWith(
      primary: type == QueueType.primary ? [] : state.primary,
      adhoc: type == QueueType.adhoc ? [] : state.adhoc,
    );
    await _repository.saveQueue(state);

    final purgingEpisodes =
        removingItems.map((item) => item.guid).whereNot(state.contains);
    await Future.wait([
      ...purgingEpisodes.map(_unmarkEpisodeAsQueued),
    ]);
  }

  Future<void> _markEpisodeAsQueued(String guid) async {
    final param = EpisodeStatsUpdateParam(guid: guid, inQueue: true);
    await _repository.updateEpisodeStats(param);
  }

  Future<void> _unmarkEpisodeAsQueued(String guid) async {
    final param = EpisodeStatsUpdateParam(guid: guid, inQueue: false);
    await _repository.updateEpisodeStats(param);
  }
}
