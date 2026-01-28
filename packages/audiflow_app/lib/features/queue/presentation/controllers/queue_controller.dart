import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_controller.g.dart';

/// Controller for queue screen state and actions.
@riverpod
class QueueController extends _$QueueController {
  @override
  Stream<PlaybackQueue> build() {
    final service = ref.watch(queueServiceProvider);
    return service.watchQueue();
  }

  Future<void> playLater(int episodeId) async {
    final service = ref.read(queueServiceProvider);
    await service.playLater(episodeId);
  }

  Future<void> playNext(int episodeId) async {
    final service = ref.read(queueServiceProvider);
    await service.playNext(episodeId);
  }

  Future<void> removeItem(int queueItemId) async {
    final service = ref.read(queueServiceProvider);
    await service.removeItem(queueItemId);
  }

  Future<void> clearQueue() async {
    final service = ref.read(queueServiceProvider);
    await service.clearQueue();
  }

  Future<void> reorderItem(int queueItemId, int newIndex) async {
    final service = ref.read(queueServiceProvider);
    await service.reorderItem(queueItemId, newIndex);
  }

  Future<void> skipToItem(int queueItemId) async {
    final service = ref.read(queueServiceProvider);
    await service.skipToItem(queueItemId);
    // TODO: Integrate with player to start playback
  }
}
