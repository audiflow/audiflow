import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:logger/logger.dart';

import 'now_playing_artwork_preparer.dart';

/// Publishes [NowPlayingInfo] to audio_service's media item stream.
///
/// Metadata goes out immediately so the lock screen updates without delay;
/// the artwork follows as a local `file:` URI once
/// [NowPlayingArtworkPreparer] has downscaled it. Every later emission
/// (for example a duration update) carries that URI along, so the platform
/// side never has to wait on a download of its own (#453).
class NowPlayingMediaItemSync {
  NowPlayingMediaItemSync({
    required this._readCurrent,
    required this._publish,
    required this._artworkPreparer,
    required this._logger,
  });

  final MediaItem? Function() _readCurrent;
  final void Function(MediaItem?) _publish;
  final NowPlayingArtworkPreparer _artworkPreparer;
  final Logger _logger;

  /// Incremented per [sync] so a slow artwork fetch cannot decorate an
  /// item that has since been replaced or cleared.
  int _generation = 0;

  /// Replaces the platform media item, or clears it for null [info].
  void sync(NowPlayingInfo? info) {
    final generation = ++_generation;
    if (info == null) {
      _logger.d('[AudioHandler] NowPlaying cleared');
      _publish(null);
      return;
    }
    _logger.i(
      '[AudioHandler] NowPlaying: '
      '${info.episodeTitle} - ${info.podcastTitle}',
    );
    _publish(_toMediaItem(info));
    final artworkUrl = info.artworkUrl;
    if (artworkUrl != null) {
      unawaited(_attachArtworkGuarded(artworkUrl, generation));
    }
  }

  /// Updates only the duration, preserving artwork and other fields.
  void updateDuration(Duration duration) {
    final current = _readCurrent();
    if (current == null || current.duration == duration) return;
    _publish(current.copyWith(duration: duration));
  }

  MediaItem _toMediaItem(NowPlayingInfo info) {
    final current = _readCurrent();
    return MediaItem(
      id: info.episodeUrl,
      title: info.episodeTitle,
      artist: info.podcastTitle,
      duration: info.totalDuration,
      // The same episode is re-published on its own (a seek in the
      // post-restore state re-sets NowPlayingInfo), and dropping the
      // artwork here would blank the lock screen until the fetch below
      // resolves.
      artUri: current?.id == info.episodeUrl ? current?.artUri : null,
    );
  }

  /// Artwork is decorative: no failure here may escape into the zone and
  /// be reported as an unhandled error, since [sync] cannot await it.
  Future<void> _attachArtworkGuarded(String artworkUrl, int generation) async {
    try {
      await _attachArtwork(artworkUrl, generation);
    } on Object catch (e, stack) {
      _logger.w(
        '[AudioHandler] Artwork attach failed for $artworkUrl',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _attachArtwork(String artworkUrl, int generation) async {
    final prepared = await _artworkPreparer.prepare(artworkUrl);
    final current = _readCurrent();
    if (generation != _generation || current == null) return;
    // Without a local copy, let audio_service try the remote URL itself;
    // that is the pre-#453 path and still works on Android. A feed can
    // carry an unparseable URL, which leaves the item without artwork.
    final fallback = Uri.tryParse(artworkUrl);
    if (prepared == null && fallback == null) return;
    _publish(current.copyWith(artUri: prepared ?? fallback));
  }
}
