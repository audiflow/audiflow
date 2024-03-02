// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';

part 'queue_manager.g.dart';

@Riverpod(keepAlive: true)
class QueueManager extends _$QueueManager {
  @override
  Queue build() => const Queue();

  Future<void> setup() => throw UnimplementedError();

  Future<QueueItem?> pop() => throw UnimplementedError();

  Future<void> prepend(QueueItem item) => throw UnimplementedError();

  Future<void> append(QueueItem item) => throw UnimplementedError();

  Future<void> appendAll(Iterable<QueueItem> items) => throw UnimplementedError();

  Future<void> replaceAll(Iterable<QueueItem> items) =>
      throw UnimplementedError();

  Future<QueueItem> removeByIndex(QueueType type, int index) =>
      throw UnimplementedError();

  Future<void> removeFromTop({required QueueItem to}) =>
      throw UnimplementedError();

  Future<void> reorder(int oldIndex, int newIndex) =>
      throw UnimplementedError();

  Future<void> clear({QueueType? type}) => throw UnimplementedError();
}
