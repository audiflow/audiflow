import 'package:audiflow/features/queue/model/queue_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manual_queue_repository.g.dart';

abstract class ManualQueueRepository {
  Future<List<ManualQueueItem>> load();

  Future<ManualQueueItem> prepend({
    required int pid,
    required int eid,
  });

  Future<ManualQueueItem> append({
    required int pid,
    required int eid,
  });

  Future<List<ManualQueueItem>> move(
    ManualQueueItem item, {
    ManualQueueItem? before,
    ManualQueueItem? after,
  });

  Future<void> remove(ManualQueueItem item);

  Future<ManualQueueItem?> pop();

  Future<void> clear();
}

@Riverpod(keepAlive: true)
ManualQueueRepository manualQueueRepository(ManualQueueRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
