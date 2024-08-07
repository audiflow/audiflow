import 'package:audiflow/features/queue/data/queue_repository.dart';
import 'package:audiflow/features/queue/model/auto_queue_builder_info.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:isar/isar.dart';

class IsarQueueRepository implements QueueRepository {
  IsarQueueRepository(this.isar);

  final Isar isar;

  @override
  Future<Queue> loadQueue() async {
    return await isar.queues.get(1) ?? Queue.empty();
  }

  @override
  Future<void> saveQueue(Queue queue) async {
    await isar.writeTxn(() => isar.queues.put(queue));
  }

  @override
  Future<String?> loadAutoQueueBuilderData(AutoQueueBuilderType type) async {
    final model = await isar.autoQueueBuilderInfos.get(type.index);
    return model?.json;
  }

  @override
  Future<void> saveAutoQueueBuilderData(
    AutoQueueBuilderType type,
    String json,
  ) async {
    final model = AutoQueueBuilderInfo(type: type, json: json);
    await isar.writeTxn(() => isar.autoQueueBuilderInfos.put(model));
  }
}
