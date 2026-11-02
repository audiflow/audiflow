import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../car/models/car_list_item.dart';
import '../../car/services/car_change_batcher.dart';
import 'session_queue.dart';

/// Publishes the app's queue to the platform media session and maps taps on
/// its rows back to the app.
///
/// Changes are coalesced: replacing the queue inserts up to 100 rows one by
/// one, and each publish makes the plugin rebuild the whole session queue. At
/// flush the current state is read, and an unchanged list is not sent again.
///
/// Text goes out first. Once [enableArtwork] has been called, images follow
/// in one more publish; a row whose image fails stays without one.
class SessionQueuePublisher {
  SessionQueuePublisher({
    required this._readQueue,
    required this._readNowPlaying,
    required this._readTitle,
    required this._publish,
    required this._playQueueItem,
    required this._continueNowPlaying,
    required this._resolveArtwork,
    required this._logger,
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _changes = CarChangeBatcher(onFlush: (_) => _flush(), delay: delay);
  }

  /// Null while the queue is loading or failed: the last good list stays.
  final PlaybackQueue? Function() _readQueue;
  final NowPlayingInfo? Function() _readNowPlaying;
  final String Function() _readTitle;
  final void Function(List<MediaItem> items, int? activeIndex, String title)
  _publish;
  final Future<bool> Function(int queueItemId) _playQueueItem;
  final Future<bool> Function(int? episodeId) _continueNowPlaying;
  final Future<Uri?> Function(String artworkUrl) _resolveArtwork;
  final Logger _logger;

  late final CarChangeBatcher _changes;

  List<SessionQueueEntry> _entries = const [];
  int? _activeIndex;

  /// What was last sent. [MediaItem] equality compares ids only, so this keeps
  /// the fields a host shows; null means the session must be sent the list.
  List<Object?>? _published;

  bool _artworkEnabled = false;

  /// Images ready for the rows of the current list.
  final Map<String, Uri> _artwork = {};

  /// Downloads under way, shared by overlapping flushes: a burst of queue
  /// changes must not ask for the same images again.
  final Map<String, Future<void>> _artworkInFlight = {};

  /// Incremented per flush, so a slow image set cannot republish over a newer
  /// list. The newer flush waits for the same downloads.
  int _generation = 0;

  /// Starts fetching images for the rows.
  void enableArtwork() {
    if (_artworkEnabled) return;
    _artworkEnabled = true;
    markChanged();
  }

  /// Records that the queue, the now-playing episode or the title changed.
  void markChanged() => _changes.add(const {CarSection.upNext});

  /// Sends the list at the next change even if it looks the same: a stopped
  /// service clears the platform's copy, and a new session starts empty.
  void forgetPublished() => _published = null;

  /// Acts on a tap on row [index] of the published list.
  Future<void> tap(int index) async {
    if (index < 0 || _entries.length <= index) {
      _logger.w('Session queue tap out of range: $index');
      return;
    }
    final entry = _entries[index];
    final played = await switch (entry) {
      SessionUpNextEntry(:final queueItemId) => _playQueueItem(queueItemId),
      SessionNowPlayingEntry(:final episodeId) => _continueNowPlaying(
        episodeId,
      ),
    };
    if (!played) _logger.w('Nothing to play for ${entry.mediaId}');
  }

  void dispose() => _changes.dispose();

  void _flush() {
    final queue = _readQueue();
    if (queue == null) return;
    final (:entries, :activeIndex) = buildSessionQueue(
      queue: queue,
      nowPlaying: _readNowPlaying(),
    );
    final generation = ++_generation;
    _entries = entries;
    _activeIndex = activeIndex;
    final urls = {for (final entry in entries) ?entry.artworkUrl};
    _artwork.removeWhere((url, _) => !urls.contains(url));
    _publishIfChanged();
    if (_artworkEnabled) unawaited(_fillArtwork(urls, generation));
  }

  void _publishIfChanged() {
    final items = [for (final entry in _entries) _toMediaItem(entry)];
    final title = _readTitle();
    final snapshot = [
      title,
      _activeIndex,
      for (final item in items) (item.id, item.title, item.artist, item.artUri),
    ];
    if (_published case final published? when listEquals(published, snapshot)) {
      return;
    }
    _published = snapshot;
    _publish(items, _activeIndex, title);
  }

  Future<void> _fillArtwork(Set<String> urls, int generation) async {
    final missing = urls.where((url) => !_artwork.containsKey(url));
    await Future.wait([
      for (final url in missing)
        _artworkInFlight[url] ??= _fetchArtwork(url).whenComplete(() {
          // Not returned: whenComplete would then wait on its own future.
          unawaited(_artworkInFlight.remove(url));
        }),
    ]);
    if (generation == _generation) _publishIfChanged();
  }

  Future<void> _fetchArtwork(String url) async {
    try {
      final uri = await _resolveArtwork(url);
      if (uri != null) _artwork[url] = uri;
    } on Object catch (e) {
      // One bad image must not lose the rest of the list.
      _logger.w('Session queue artwork failed: $url', error: e);
    }
  }

  MediaItem _toMediaItem(SessionQueueEntry entry) => MediaItem(
    id: entry.mediaId,
    title: entry.title,
    artist: entry.podcastTitle,
    displaySubtitle: entry.podcastTitle,
    artUri: _artwork[entry.artworkUrl],
  );
}
