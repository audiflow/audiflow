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
class SessionQueuePublisher {
  SessionQueuePublisher({
    required this._readQueue,
    required this._readNowPlaying,
    required this._publish,
    required this._playQueueItem,
    required this._continueNowPlaying,
    required this._logger,
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _changes = CarChangeBatcher(onFlush: (_) => _flush(), delay: delay);
  }

  /// Null while the queue is loading or failed: the last good list stays.
  final PlaybackQueue? Function() _readQueue;
  final NowPlayingInfo? Function() _readNowPlaying;
  final void Function(List<MediaItem> items, int? activeIndex) _publish;
  final Future<bool> Function(int queueItemId) _playQueueItem;
  final Future<bool> Function(int? episodeId) _continueNowPlaying;
  final Logger _logger;

  late final CarChangeBatcher _changes;

  List<SessionQueueEntry> _entries = const [];

  /// What was last sent. [MediaItem] equality compares ids only, so this keeps
  /// the fields a host shows; null means the session must be sent the list.
  List<Object?>? _published;

  /// Records that the queue or the now-playing episode changed.
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
    final items = [for (final entry in entries) _toMediaItem(entry)];
    final snapshot = [
      activeIndex,
      for (final item in items) (item.id, item.title, item.artist, item.artUri),
    ];
    _entries = entries;
    if (_published case final published? when listEquals(published, snapshot)) {
      return;
    }
    _published = snapshot;
    _publish(items, activeIndex);
  }

  MediaItem _toMediaItem(SessionQueueEntry entry) => MediaItem(
    id: entry.mediaId,
    title: entry.title,
    artist: entry.podcastTitle,
    displaySubtitle: entry.podcastTitle,
  );
}
