// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_manager.g.dart';

@Riverpod(keepAlive: true)
class QueueManager extends _$QueueManager {
  @override
  Queue build() => Queue.empty();

  Future<void> ensureInitialized() => throw UnimplementedError();

  Future<QueueItem?> pop() => throw UnimplementedError();

  Future<void> prepend(QueueItem item) => throw UnimplementedError();

  Future<void> append(QueueItem item) => throw UnimplementedError();

  Future<void> appendAll(Iterable<QueueItem> items) =>
      throw UnimplementedError();

  Future<void> replaceAll(Iterable<QueueItem> items) =>
      throw UnimplementedError();

  Future<QueueItem> removeByIndex(int index) => throw UnimplementedError();

  Future<void> removeFromTop({required QueueItem to}) =>
      throw UnimplementedError();

  Future<void> reorder(int oldIndex, int newIndex) =>
      throw UnimplementedError();

  Future<void> clear({QueueType? type}) => throw UnimplementedError();
}
