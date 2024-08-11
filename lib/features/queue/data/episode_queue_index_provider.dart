import 'package:audiflow/features/queue/service/queue_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_queue_index_provider.g.dart';

@riverpod
int? episodeQueueIndex(EpisodeQueueIndexRef ref, int eid) {
  ref.listen(queueManagerProvider, (_, next) {
    final index = next.queue.indexWhere((item) => item.eid == eid);
    final queueIndex = 0 <= index ? index : null;
    if (ref.state != queueIndex) {
      ref.state = queueIndex;
    }
  });

  final queue = ref.read(queueManagerProvider).queue;
  final index = queue.indexWhere((item) => item.eid == eid);
  return 0 <= index ? index : null;
}
