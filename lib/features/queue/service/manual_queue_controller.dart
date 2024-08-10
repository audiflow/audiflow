import 'package:audiflow/features/queue/model/queue_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manual_queue_controller.g.dart';

@Riverpod(keepAlive: true)
class ManualQueueController extends _$ManualQueueController {
  @override
  List<QueueItem> build() => [];

  Future<List<QueueItem>> load() => throw UnimplementedError();

  Future<QueueItem> prepend({
    required int pid,
    required int eid,
  }) =>
      throw UnimplementedError();

  Future<QueueItem> append({
    required int pid,
    required int eid,
  }) =>
      throw UnimplementedError();

  Future<List<QueueItem>> move(
    QueueItem item, {
    QueueItem? before,
    QueueItem? after,
  }) =>
      throw UnimplementedError();

  Future<QueueItem?> pop() => throw UnimplementedError();

  Future<void> clear() => throw UnimplementedError();
}
