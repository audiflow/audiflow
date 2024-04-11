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
      : queue = jsonDecode(encoded) as List<QueueItem>;

  factory Queue.empty() {
    return Queue(encoded: '[]');
  }

  final Id id = 1;

  @ignore
  final List<QueueItem> queue;

  String get encoded => jsonEncode(queue);
}

extension QueueExt on Queue {
  bool contains({required String guid, QueueType? type}) {
    return queue.any(
      (element) =>
          element.guid == guid && (type == null || element.type == type),
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
    required String pguid,
    required String guid,
    required QueueType type,
  }) = _QueueItem;

  factory QueueItem.primary({
    required String pguid,
    required String guid,
  }) {
    return QueueItem(
      id: nanoid(),
      pguid: pguid,
      guid: guid,
      type: QueueType.primary,
    );
  }

  factory QueueItem.adhoc({
    required String pguid,
    required String guid,
  }) {
    return QueueItem(
      id: nanoid(),
      pguid: pguid,
      guid: guid,
      type: QueueType.adhoc,
    );
  }

  factory QueueItem.fromJson(Map<String, dynamic> json) =>
      _$QueueItemFromJson(json);
}
