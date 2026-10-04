import 'package:riverpod/riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../transcript/models/episode_chapter.dart';
import '../../transcript/providers/transcript_providers.dart';
import '../models/current_chapter.dart';
import '../services/audio_player_service.dart';
import '../services/now_playing_controller.dart';

part 'current_chapter_providers.g.dart';

/// Chapters of the now-playing episode, ordered by start time.
///
/// Empty when nothing is playing, the episode is not stored locally, or it
/// has no chapters.
@riverpod
Future<List<EpisodeChapter>> currentEpisodeChapters(Ref ref) async {
  final episodeId = ref.watch(
    nowPlayingControllerProvider.select((info) => info?.episode?.id),
  );
  if (episodeId == null) return const [];
  final chapters = await ref.watch(episodeChaptersProvider(episodeId).future);
  // Sorted defensively: chapter lookup by position depends on the order.
  return [...chapters]..sort((a, b) => a.startMs.compareTo(b.startMs));
}

/// The chapter containing the current playback position.
///
/// Null when the episode has no chapters or the position is before the
/// first chapter. Only notifies listeners when the chapter changes, not on
/// every progress tick.
@riverpod
CurrentChapter? currentChapter(Ref ref) {
  final chapters = ref.watch(currentEpisodeChaptersProvider).value;
  if (chapters == null || chapters.isEmpty) return null;
  final position = _currentPosition(ref);
  if (position == null) return null;
  final index = chapterIndexAt(chapters, position);
  if (index == null) return null;
  return CurrentChapter(index: index, chapter: chapters[index]);
}

/// Live position while audio is loaded, else the restored saved position.
///
/// The progress stream reports a zero duration while idle, which mirrors
/// the player screen's own fallback.
Duration? _currentPosition(Ref ref) {
  final live = ref.watch(playbackProgressProvider);
  if (live != null && 0 < live.duration.inMilliseconds) return live.position;
  return ref.watch(
    nowPlayingControllerProvider.select((info) => info?.savedPosition),
  );
}
