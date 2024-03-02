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
    @Default(<QueueItem>[]) List<QueueItem> primary,
    @Default(<QueueItem>[]) List<QueueItem> adhoc,
  }) = _Queue;

  factory Queue.fromJson(Map<String, dynamic> json) => _$QueueFromJson(json);
}

extension QueueExt on Queue {
  bool contains(String guid, {QueueType? type}) {
    switch (type) {
      case QueueType.primary:
        return primary.any((element) => element.guid == guid);
      case QueueType.adhoc:
        return adhoc.any((element) => element.guid == guid);
      case null:
        return primary.any((element) => element.guid == guid) ||
            adhoc.any((element) => element.guid == guid);
    }
  }

  int indexOf(QueueItem item) {
    switch (item.type) {
      case QueueType.primary:
        return primary.indexWhere((element) => element.id == item.id);
      case QueueType.adhoc:
        return adhoc.indexWhere((element) => element.id == item.id);
    }
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
