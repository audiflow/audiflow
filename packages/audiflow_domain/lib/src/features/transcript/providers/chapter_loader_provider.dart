import 'dart:async';

import 'package:riverpod/riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../player/controllers/sleep_timer_controller.dart';
import '../../player/services/now_playing_controller.dart';
import '../services/chapter_service.dart';
import 'transcript_providers.dart';

part 'chapter_loader_provider.g.dart';

/// Loads on-demand chapters for the now-playing episode.
///
/// Chapters that are not stored during feed sync are fetched when an episode
/// becomes the now-playing one, which covers both starting playback and
/// opening the player. Chapter providers are refreshed once new chapters
/// are stored, so the player picks them up without reopening.
///
/// Read once at startup to activate; kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
void nowPlayingChapterLoader(Ref ref) {
  ref.listen<int?>(
    nowPlayingControllerProvider.select((info) => info?.episode?.id),
    (_, episodeId) {
      if (episodeId == null) return;
      unawaited(_load(ref, episodeId));
    },
    fireImmediately: true,
  );
}

Future<void> _load(Ref ref, int episodeId) async {
  final changed = await ref
      .read(chapterServiceProvider)
      .ensureChapters(episodeId);
  if (!changed || !ref.mounted) return;
  ref.invalidate(episodeChaptersProvider(episodeId));
  ref.invalidate(currentEpisodeHasChaptersProvider);
}
