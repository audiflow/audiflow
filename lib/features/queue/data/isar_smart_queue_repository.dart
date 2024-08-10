import 'package:audiflow/features/queue/data/smart_queue_repository.dart';
import 'package:audiflow/features/queue/model/smart_queue.dart';
import 'package:isar/isar.dart';

class IsarSmartQueueRepository implements SmartQueueRepository {
  IsarSmartQueueRepository(this.isar);

  final Isar isar;

  @override
  Future<SmartQueueInfo?> load() => isar.smartQueueInfos.get(1);

  @override
  Future<void> save(SmartQueueInfo model) =>
      isar.writeTxn(() => isar.smartQueueInfos.put(model));
}
