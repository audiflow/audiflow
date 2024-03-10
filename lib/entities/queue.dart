// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nanoid/nanoid.dart';

part 'queue.freezed.dart';
part 'queue.g.dart';

/// The current persistable queue.

@freezed
class Queue with _$Queue {
  const factory Queue({
    @Default(<QueueItem>[]) List<QueueItem> queue,
  }) = _Queue;

  factory Queue.fromJson(Map<String, dynamic> json) => _$QueueFromJson(json);
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
    required String guid,
    required QueueType type,
  }) = _QueueItem;

  factory QueueItem.primary(String guid) {
    return QueueItem(
      id: nanoid(),
      guid: guid,
      type: QueueType.primary,
    );
  }

  factory QueueItem.adhoc(String guid) {
    return QueueItem(
      id: nanoid(),
      guid: guid,
      type: QueueType.adhoc,
    );
  }

  factory QueueItem.fromJson(Map<String, dynamic> json) =>
      _$QueueItemFromJson(json);
}
