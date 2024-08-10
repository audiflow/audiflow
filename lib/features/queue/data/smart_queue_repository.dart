import 'package:audiflow/features/queue/model/smart_queue.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'smart_queue_repository.g.dart';

abstract class SmartQueueRepository {
  Future<SmartQueueInfo?> load();

  Future<void> save(SmartQueueInfo model);
}

@Riverpod(keepAlive: true)
SmartQueueRepository smartQueueRepository(SmartQueueRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
