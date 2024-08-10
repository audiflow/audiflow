import 'package:audiflow/features/queue/model/auto_queue_builder_info.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_repository.g.dart';

abstract class QueueRepository {
  Future<Queue> loadQueue();

  Future<void> saveQueue(Queue queue);

  Future<String?> loadAutoQueueBuilderData(AutoQueueBuilderType type);

  Future<void> saveAutoQueueBuilderData(AutoQueueBuilderType type, String json);
}

@Riverpod(keepAlive: true)
QueueRepository queueRepository(QueueRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
