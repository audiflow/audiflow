import 'dart:async';

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
  Future<String?> pop() async {
    if (state.queue.isEmpty) {
      return null;
    }

    final guid = state.queue.first.guid;
    await remove(0);
    return guid;
  }

  @override
  Future<void> prepend(Episode episode) async {
    final inQueue = state.queue.any((q) => q.guid == episode.guid);
    final newQueue = [
      QueueItem.primary(guid: episode.guid),
      ...state.queue,
    ];
    state = state.copyWith(queue: newQueue);
    await _repository.saveQueue(state);

    if (!inQueue) {
      await _markEpisodeAsQueued(episode);
    }
  }

  @override
  Future<void> append(Episode episode) async {
    final inQueue = state.queue.any((q) => q.guid == episode.guid);
    final newQueue = [
      ...state.queue,
      QueueItem.primary(guid: episode.guid),
    ];
    state = state.copyWith(queue: newQueue);
    await _repository.saveQueue(state);

    if (!inQueue) {
      await _markEpisodeAsQueued(episode);
    }
  }

  @override
  Future<void> reorder(int oldIndex, int newIndex) async {
    assert(0 <= oldIndex && oldIndex < state.queue.length, 'Invalid oldIndex');
    assert(0 <= newIndex && newIndex <= state.queue.length, 'Invalid newIndex');

    final newQueue = List.of(state.queue);
    final temp = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex - (oldIndex < newIndex ? 1 : 0), temp);
    state = state.copyWith(queue: newQueue);
    await _repository.saveQueue(state);
  }

  @override
  Future<void> addAll(List<Episode> episodes) async {
    final newQueue = [
      ...state.queue,
      ...episodes.map((e) => QueueItem.primary(guid: e.guid)),
    ];
    state = state.copyWith(queue: newQueue);
    await _repository.saveQueue(state);

    await Future.wait(episodes.map(_markEpisodeAsQueued));
  }

  @override
  Future<void> replaceAll(List<Episode> episodes) async {
    await _replaceAllAdHoc(episodes, QueueType.primary);
  }

  @override
  Future<void> replaceAllAdHoc(List<Episode> episodes) async {
    await _replaceAllAdHoc(episodes, QueueType.adhoc);
  }

  Future<void> _replaceAllAdHoc(List<Episode> episodes, QueueType type) async {
    final oldQueue = state.queue;
    final remains = oldQueue.where((item) => item.type == type);
    final adds = episodes.map((e) => QueueItem(guid: e.guid, type: type));

    final List<QueueItem> newQueue;
    switch (type) {
      case QueueType.primary:
        newQueue = [...adds, ...remains].toList();
      case QueueType.adhoc:
        newQueue = [...remains, ...adds].toList();
    }

    state = state.copyWith(queue: newQueue);
    await _repository.saveQueue(state);

    final notInQueue =
        oldQueue.where((item) => newQueue.any((i) => i.guid == item.guid));
    await Future.wait(notInQueue.map(_unmarkEpisodeAsQueued));
  }

  @override
  Future<void> remove(int index) async {
    assert(0 <= index && index < state.queue.length, 'Invalid index');

    final item = state.queue[index];
    final newQueue = List.of(state.queue)..removeAt(index);
    state = state.copyWith(queue: newQueue);
    await _repository.saveQueue(state);

    if (!newQueue.any((i) => i.guid == item.guid)) {
      await _unmarkEpisodeAsQueued(item);
    }
  }

  @override
  Future<void> clear() async {
    final oldQueue = state.queue;
    final newQueue =
        state.queue.where((item) => item.type != QueueType.primary).toList();
    state = state.copyWith(queue: newQueue);
    await _repository.saveQueue(state);

    final notInQueue =
        oldQueue.where((item) => newQueue.any((i) => i.guid == item.guid));
    await Future.wait(notInQueue.map(_unmarkEpisodeAsQueued));
  }

  Future<void> _markEpisodeAsQueued(Episode episode) async {
    final param = EpisodeStatsUpdateParam(guid: episode.guid, inQueue: true);
    await _repository.updateEpisodeStats(param);
  }

  Future<void> _unmarkEpisodeAsQueued(QueueItem item) async {
    final param = EpisodeStatsUpdateParam(guid: item.guid, inQueue: false);
    await _repository.updateEpisodeStats(param);
  }
}
