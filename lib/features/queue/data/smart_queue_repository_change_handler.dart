import 'package:audiflow/events/queue_event.dart';
import 'package:audiflow/features/queue/data/smart_queue_repository.dart';
import 'package:audiflow/features/queue/model/smart_queue.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class SmartQueueRepositoryChangeHandler implements SmartQueueRepository {
  SmartQueueRepositoryChangeHandler(this._ref, this._inner);

  final Ref _ref;
  final SmartQueueRepository _inner;

  @override
  Future<SmartQueueInfo?> load() => _inner.load();

  @override
  Future<void> save(SmartQueueInfo model) async {
    await _inner.save(model);
    _ref
        .read(smartQueueEventStreamProvider.notifier)
        .add(SmartQueueUpdatedEvent(model));
  }
}

@Riverpod(keepAlive: true)
SmartQueueRepository smartQueueRepository(SmartQueueRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
