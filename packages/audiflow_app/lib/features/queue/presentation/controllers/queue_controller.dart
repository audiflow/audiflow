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
    final episode = await service.skipToItem(queueItemId);
    if (episode == null) return;

    final subscription = await ref
        .read(subscriptionRepositoryProvider)
        .getById(episode.podcastId);
    final podcastTitle = subscription?.title ?? '';

    final controller = ref.read(audioPlayerControllerProvider.notifier);
    controller.play(
      episode.audioUrl,
      metadata: NowPlayingInfo(
        episodeUrl: episode.audioUrl,
        episodeTitle: episode.title,
        podcastTitle: podcastTitle,
        artworkUrl: episode.imageUrl,
        totalDuration: episode.durationMs != null
            ? Duration(milliseconds: episode.durationMs!)
            : null,
        episode: episode,
      ),
    );
  }
}
