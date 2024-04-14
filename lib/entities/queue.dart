// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:nanoid/nanoid.dart';

part 'queue.freezed.dart';
part 'queue.g.dart';

/// The current persistable queue.

@collection
class Queue {
  Queue({required String encoded})
      : queue = (jsonDecode(encoded) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(QueueItem.fromJson)
            .toList();

  factory Queue.empty() {
    return Queue(encoded: '[]');
  }

  factory Queue.from(List<QueueItem> queue) {
    return Queue.empty().copyWith(queue: queue);
  }

  final Id id = 1;

  @ignore
  final List<QueueItem> queue;

  String get encoded => jsonEncode(queue);

  Queue copyWith({required List<QueueItem> queue}) {
    final newQueue = Queue(encoded: jsonEncode(queue));
    return newQueue;
  }
}

extension QueueExt on Queue {
  bool containsEpisode({required int eid, QueueType? type}) {
    return queue.any(
      (element) => element.eid == eid && (type == null || element.type == type),
    );
  }
}

enum QueueType {
  primary,
  adhoc,
}

@freezed
class QueueItem with _$QueueItem {
  const factory QueueItem({
    required String id,
    required int pid,
    required int eid,
    required QueueType type,
  }) = _QueueItem;

  factory QueueItem.primary({
    required int pid,
    required int eid,
  }) {
    return QueueItem(
      id: nanoid(),
      pid: pid,
      eid: eid,
      type: QueueType.primary,
    );
  }

  factory QueueItem.adhoc({
    required int pid,
    required int eid,
  }) {
    return QueueItem(
      id: nanoid(),
      pid: pid,
      eid: eid,
      type: QueueType.adhoc,
    );
  }

  factory QueueItem.fromJson(Map<String, dynamic> json) =>
      _$QueueItemFromJson(json);
}
