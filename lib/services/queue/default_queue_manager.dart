// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    return state.queue.isNotEmpty ? removeByIndex(0) : null;
  }

  @override
  Future<void> prepend(QueueItem item) async {
    final isNewEpisode = !state.contains(guid: item.guid);
    state = state.copyWith(queue: [item, ...state.queue]);
    await _repository.saveQueue(state);
    if (isNewEpisode) {
      await _markEpisodeAsQueued(item.guid);
    }
  }

  @override
  Future<void> append(QueueItem item) async {
    final isNewEpisode = !state.contains(guid: item.guid);

    final i = state.queue.lastIndexWhere((q) => q.type == item.type);
    if (0 <= i) {
      final newQueue = List.of(state.queue)..insert(i + 1, item);
      state = state.copyWith(queue: newQueue);
    } else if (item.type == QueueType.adhoc || state.queue.isEmpty) {
      state = state.copyWith(queue: [...state.queue, item]);
    } else {
      state = state.copyWith(queue: [item, ...state.queue]);
    }

    await _repository.saveQueue(state);
    if (isNewEpisode) {
      await _markEpisodeAsQueued(item.guid);
    }
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

    await _repository.saveQueue(state);
    await _markEpisodesAsQueued(items.map((item) => item.guid));
  }

  @override
  Future<void> replaceAll(Iterable<QueueItem> items) async {
    if (items.isEmpty) {
      return clear();
    }

    final type = items.first.type;
    final remaining = state.queue.where((q) => q.type != type);
    final removing = state.queue.where((q) => q.type == type);
    final newEpisodes =
        items.map((q) => q.guid).where((guid) => state.contains(guid: guid));

    state = state.copyWith(
      queue: type == QueueType.primary
          ? [...items, ...remaining]
          : [...remaining, ...items],
    );
    await _repository.saveQueue(state);

    final purgingEpisodes = removing
        .map((item) => item.guid)
        .whereNot((guid) => state.contains(guid: guid));
    await _unmarkEpisodesAsQueued(purgingEpisodes);
    await _markEpisodesAsQueued(newEpisodes);
  }

  @override
  Future<QueueItem> removeByIndex(int index) async {
    assert(0 <= index && index < state.queue.length, 'Invalid index');

    final removedItem = state.queue[index];
    state = state.copyWith(queue: List.of(state.queue)..removeAt(index));
    await _repository.saveQueue(state);

    if (!state.contains(guid: removedItem.guid)) {
      await _unmarkEpisodeAsQueued(removedItem.guid);
    }
    return removedItem;
  }

  @override
  Future<void> removeFromTop({required QueueItem to}) async {
    final i = state.queue.indexOf(to);
    assert(0 <= i, 'Queue item not found');
    if (i == 0 || state.queue.sublist(0, i).every((q) => q.type == to.type)) {
      return replaceAll(state.queue.sublist(i + 1));
    }

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
    await replaceAll(newQueue);
  }

  @override
  Future<void> reorder(int oldIndex, int newIndex) async {
    final newQueue = List.of(state.queue);
    final temp = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex - (oldIndex < newIndex ? 1 : 0), temp);

    state = state.copyWith(queue: newQueue);
    await _repository.saveQueue(state);
  }

  @override
  Future<void> clear({QueueType? type}) async {
    final removing = type == QueueType.primary
        ? state.queue.where((q) => q.type != QueueType.primary)
        : type == QueueType.adhoc
            ? state.queue.where((q) => q.type != QueueType.adhoc)
            : [...state.queue];
    final newQueue = type == QueueType.primary
        ? state.queue.where((q) => q.type == QueueType.primary)
        : type == QueueType.adhoc
            ? state.queue.where((q) => q.type == QueueType.adhoc)
            : <QueueItem>[];

    state = state.copyWith(queue: newQueue.toList());
    await _repository.saveQueue(state);

    final purgingEpisodes = removing
        .map((item) => item.guid)
        .whereNot((guid) => state.contains(guid: guid));
    await _unmarkEpisodesAsQueued(purgingEpisodes);
  }

  Future<void> _markEpisodeAsQueued(String guid) async {
    final param = EpisodeStatsUpdateParam(guid: guid, inQueue: true);
    await _repository.updateEpisodeStats(param);
  }

  Future<void> _markEpisodesAsQueued(Iterable<String> guids) async {
    final params =
        guids.map((guid) => EpisodeStatsUpdateParam(guid: guid, inQueue: true));
    await _repository.updateEpisodeStatsList(params);
  }

  Future<void> _unmarkEpisodeAsQueued(String guid) async {
    final param = EpisodeStatsUpdateParam(guid: guid, inQueue: false);
    await _repository.updateEpisodeStats(param);
  }

  Future<void> _unmarkEpisodesAsQueued(Iterable<String> guids) async {
    final params = guids
        .map((guid) => EpisodeStatsUpdateParam(guid: guid, inQueue: false));
    await _repository.updateEpisodeStatsList(params);
  }
}
