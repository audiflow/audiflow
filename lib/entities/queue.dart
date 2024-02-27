// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

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
  Iterable<QueueItem> get primary {
    return queue.where((q) => q.type == QueueType.primary);
  }

  Iterable<QueueItem> get adhoc {
    return queue.where((element) => element.type == QueueType.adhoc);
  }

  bool contains(String guid) {
    return queue.any((element) => element.guid == guid);
  }
}

enum QueueType {
  primary,
  adhoc,
}

@freezed
class QueueItem with _$QueueItem {
  const factory QueueItem({
    required String guid,
    required QueueType type,
  }) = _QueueItem;

  factory QueueItem.primary({
    required String guid,
  }) {
    return QueueItem(
      guid: guid,
      type: QueueType.primary,
    );
  }

  factory QueueItem.adHoc({
    required String guid,
  }) {
    return QueueItem(
      guid: guid,
      type: QueueType.adhoc,
    );
  }

  factory QueueItem.fromJson(Map<String, dynamic> json) =>
      _$QueueItemFromJson(json);
}
