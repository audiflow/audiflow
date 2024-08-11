import 'package:audiflow/features/queue/service/manual_queue_controller.dart';
import 'package:audiflow/features/queue/service/smart_queue_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_queue_index_provider.g.dart';

@riverpod
int? episodeQueueIndex(EpisodeQueueIndexRef ref, int eid) {
  final manualQueueIndex = ref.watch(
    manualQueueControllerProvider
        .select((items) => items.indexWhere((item) => item.eid == eid)),
  );
  if (0 <= manualQueueIndex) {
    return manualQueueIndex + 1;
  }

  final smartQueueIndex = ref.watch(
    smartQueueControllerProvider
        .select((items) => items.indexWhere((item) => item.eid == eid)),
  );
  if (0 <= smartQueueIndex) {
    return ref.read(manualQueueControllerProvider).length + smartQueueIndex + 1;
  }

  return null;
}
