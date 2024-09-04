import 'package:audiflow/features/queue/model/queue.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_controller.g.dart';

@Riverpod(keepAlive: true)
class QueueController extends _$QueueController {
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

  Future<List<QueueItem>> removeFromTop({
    required QueueType type,
    required int count,
  }) =>
      throw UnimplementedError();

  Future<void> reorder(int oldIndex, int newIndex) =>
      throw UnimplementedError();

  Future<void> clear({QueueType? type}) => throw UnimplementedError();
}
