import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/playback_history.dart';
import '../repositories/playback_history_repository_impl.dart';

part 'episode_playback_history_provider.g.dart';

/// Live playback history of one episode, or null before its first play.
///
/// Emits after every history write (progress saves included), so
/// watchers that display it should `select` what they show to avoid
/// rebuilding on writes that change nothing visible.
@riverpod
Stream<PlaybackHistory?> episodePlaybackHistory(Ref ref, int episodeId) {
  return ref
      .watch(playbackHistoryRepositoryProvider)
      .watchByEpisodeId(episodeId);
}
