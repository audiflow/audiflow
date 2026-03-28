import 'package:freezed_annotation/freezed_annotation.dart';

import '../../feed/models/episode.dart';
import '../models/queue_item.dart';

part 'playback_queue.freezed.dart';

/// A queue item joined with its episode data.
@freezed
sealed class QueueItemWithEpisode with _$QueueItemWithEpisode {
  const factory QueueItemWithEpisode({
    required QueueItem queueItem,
    required Episode episode,

    /// Resolved artwork URL (episode image, falling back to podcast artwork).
    String? artworkUrl,

    /// iTunes ID from the parent subscription, used for share links.
    String? itunesId,
  }) = _QueueItemWithEpisode;
}

/// In-memory representation of the playback queue.
@freezed
sealed class PlaybackQueue with _$PlaybackQueue {
  const factory PlaybackQueue({
    /// Currently playing episode (not in queue items).
    Episode? currentEpisode,

    /// Manually added queue items (Play Next / Play Later).
    @Default([]) List<QueueItemWithEpisode> manualItems,

    /// Auto-generated queue items from episode list playback.
    @Default([]) List<QueueItemWithEpisode> adhocItems,

    /// Source context for adhoc items (e.g., "Season 2").
    String? adhocSourceContext,
  }) = _PlaybackQueue;

  const PlaybackQueue._();

  /// Total number of items in queue (excluding current).
  int get totalCount => manualItems.length + adhocItems.length;

  /// Whether the queue has any items.
  bool get hasItems => 0 < totalCount;

  /// Whether there are manual items in the queue.
  bool get hasManualItems => manualItems.isNotEmpty;

  /// Get the next item to play (manual first, then adhoc).
  QueueItemWithEpisode? get nextItem {
    if (manualItems.isNotEmpty) return manualItems.first;
    if (adhocItems.isNotEmpty) return adhocItems.first;
    return null;
  }

  /// All items in playback order.
  List<QueueItemWithEpisode> get allItems => [...manualItems, ...adhocItems];

  /// Items in playback order, optionally excluding the first item whose
  /// [Episode.audioUrl] matches [nowPlayingUrl]. Only the first match is
  /// removed so that deliberately queued duplicates are preserved. Returns
  /// [allItems] unchanged when [nowPlayingUrl] is null or empty.
  List<QueueItemWithEpisode> upNextItems({String? nowPlayingUrl}) {
    if (nowPlayingUrl == null || nowPlayingUrl.isEmpty) return allItems;
    final items = allItems.toList();
    final index = items.indexWhere(
      (item) => item.episode.audioUrl == nowPlayingUrl,
    );
    if (0 <= index) items.removeAt(index);
    return items;
  }
}
