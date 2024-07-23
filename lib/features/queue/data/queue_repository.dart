import 'package:audiflow/features/queue/model/queue.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_repository.g.dart';

abstract class QueueRepository {
  Future<Queue> loadQueue();

  Future<void> saveQueue(Queue queue);
}

@Riverpod(keepAlive: true)
QueueRepository queueRepository(QueueRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
