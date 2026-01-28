import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/playback_queue.dart';
import '../repositories/queue_repository_impl.dart';

part 'queue_providers.g.dart';

/// Watches the current queue state.
@riverpod
Stream<PlaybackQueue> playbackQueue(Ref ref) {
  final repository = ref.watch(queueRepositoryProvider);
  return repository.watchQueue();
}

/// Gets the total number of items in queue.
@riverpod
Future<int> queueItemCount(Ref ref) async {
  final queue = await ref.watch(playbackQueueProvider.future);
  return queue.totalCount;
}

/// Returns true if manual queue has items (for adhoc confirmation).
@riverpod
Future<bool> hasManualQueueItems(Ref ref) async {
  final queue = await ref.watch(playbackQueueProvider.future);
  return queue.hasManualItems;
}
