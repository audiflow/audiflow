// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seasoning/entities/episode.dart';

part 'queue_event.freezed.dart';

@freezed
class QueueEvent with _$QueueEvent {
  const factory QueueEvent.add({
    required Episode episode,
    int? position,
  }) = QueueAddEvent;

  const factory QueueEvent.remove({
    required Episode episode,
  }) = QueueRemoveEvent;

  const factory QueueEvent.move({
    required Episode episode,
    required int oldIndex,
    required int newIndex,
  }) = QueueMoveEvent;

  const factory QueueEvent.clear() = QueueClearEvent;
}

@freezed
class QueueListEvent with _$QueueListEvent {
  const factory QueueListEvent.empty() = EmptyQueueListEvent;

  const factory QueueListEvent.list({
    required Episode playing,
    required List<Episode> queue,
  }) = ReadyQueueListEvent;
}
