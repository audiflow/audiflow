import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Seeks the now-playing episode to [position].
///
/// With audio loaded this seeks the player. After a restore, before any
/// audio is loaded, it moves the saved position instead so the display
/// reflects the seek and the next play() starts there.
Future<void> seekNowPlaying(WidgetRef ref, Duration position) async {
  final controller = ref.read(audioPlayerControllerProvider.notifier);
  if (controller.currentUrl != null) {
    await controller.seek(position);
    return;
  }
  await _saveSeekWithoutAudio(ref, position);
}

Future<void> _saveSeekWithoutAudio(WidgetRef ref, Duration position) async {
  final nowPlaying = ref.read(nowPlayingControllerProvider);
  if (nowPlaying == null) return;
  ref
      .read(nowPlayingControllerProvider.notifier)
      .setNowPlaying(nowPlaying.copyWith(savedPosition: position));
  final episode = nowPlaying.episode;
  if (episode == null) return;
  // Persist so play() seeks to this position.
  await ref
      .read(playbackHistoryRepositoryProvider)
      .saveProgress(episodeId: episode.id, positionMs: position.inMilliseconds);
}
