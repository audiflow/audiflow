import 'dart:async';

import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../player/models/now_playing_info.dart';
import '../../player/repositories/playback_history_repository.dart';
import '../../player/repositories/playback_history_repository_impl.dart';
import '../../player/services/audio_player_service.dart';
import '../../player/services/now_playing_controller.dart';
import 'sync_providers.dart';

part 'sync_playback_bridge.g.dart';

/// Moves a paused or unloaded player to a newer position another device
/// synced. Read once at startup; a build without a relay starts nothing.
@Riverpod(keepAlive: true)
void syncPlaybackBridge(Ref ref) {
  if (ref.watch(syncRelayUrlProvider) == null) return;
  final controller = ref.watch(syncControllerProvider);
  final bridge = SyncPlaybackBridge(
    history: ref.watch(playbackHistoryRepositoryProvider),
    logger: ref.watch(namedLoggerProvider('SyncPlayback')),
    nowPlaying: () => ref.read(nowPlayingControllerProvider),
    adoptPosition: (episodeId, position) => ref
        .read(audioPlayerControllerProvider.notifier)
        .adoptSyncedPosition(episodeId, position),
  );
  final merged = controller.episodesMerged.listen(bridge.onEpisodesMerged);
  ref.onDispose(merged.cancel);
}

/// The logic of [syncPlaybackBridge], apart from Riverpod for tests.
class SyncPlaybackBridge {
  SyncPlaybackBridge({
    required this._history,
    required this._logger,
    required this._nowPlaying,
    required this._adoptPosition,
  });

  final PlaybackHistoryRepository _history;
  final Logger _logger;
  final NowPlayingInfo? Function() _nowPlaying;
  final Future<void> Function(int episodeId, Duration position) _adoptPosition;

  /// Moves the now-playing episode to its merged position when another
  /// device's change reached it.
  Future<void> onEpisodesMerged(Set<String> episodeKeys) async {
    final episode = _nowPlaying()?.episode;
    final key = episode?.episodeKey;
    if (episode == null || key == null || !episodeKeys.contains(key)) return;
    try {
      final stored = await _history.getByEpisodeId(episode.id);
      if (stored == null) return;
      await _adoptPosition(
        episode.id,
        Duration(milliseconds: stored.positionMs),
      );
    } on Object catch (e, stack) {
      _logger.w('Synced position not applied', error: e, stackTrace: stack);
    }
  }
}
