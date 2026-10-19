import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Jumps the queue to [queueItemId] and plays its episode: what tapping a
/// row in the Queue tab does, shared with the CarPlay Up Next list.
///
/// Returns false when the item is no longer in the queue.
Future<bool> playQueueItem(Ref ref, int queueItemId) async {
  final episode = await ref.read(queueServiceProvider).skipToItem(queueItemId);
  if (episode == null) return false;
  await startEpisode(ref, episode, PlaySource.queue);
  return true;
}

/// Plays [episode] with its podcast's now-playing metadata, reporting
/// [source] to analytics.
Future<void> startEpisode(Ref ref, Episode episode, PlaySource source) async {
  final subscription = await ref
      .read(subscriptionRepositoryProvider)
      .getById(episode.podcastId);
  final controller = ref.read(audioPlayerControllerProvider.notifier)
    ..markPlaySource(source);
  await controller.play(
    episode.audioUrl,
    metadata: nowPlayingInfoForEpisode(episode, subscription),
  );
}
