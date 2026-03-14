import '../../feed/models/episode.dart';
import '../models/playback_queue.dart';
import '../models/queue_item.dart';

/// Repository interface for queue operations.
///
/// Provides high-level operations for managing the playback queue,
/// including manual (Play Next/Later) and adhoc (episode list) items.
abstract class QueueRepository {
  /// Adds an episode to the end of the manual queue (Play Later).
  ///
  /// Returns the created queue item.
  Future<QueueItem> addToEnd(int episodeId);

  /// Adds an episode to the front of the manual queue (Play Next).
  ///
  /// Returns the created queue item.
  Future<QueueItem> addToFront(int episodeId);

  /// Replaces the entire queue with adhoc items from an episode list.
  ///
  /// Clears all existing items and inserts new adhoc items from
  /// [episodeIds]. The [sourceContext] describes where the episodes
  /// came from (e.g., "Season 2").
  Future<void> replaceWithAdhoc({
    required List<int> episodeIds,
    required String sourceContext,
  });

  /// Removes a queue item by its ID.
  Future<void> remove(int queueItemId);

  /// Removes the first item from the queue (after playback completes).
  ///
  /// Manual items are prioritized over adhoc items.
  Future<void> removeFirst();

  /// Clears the entire queue.
  Future<void> clearAll();

  /// Reorders an item to a new position.
  ///
  /// The [queueItemId] identifies the item to move, and [newIndex] is
  /// the target index in the combined list (manual items first, then
  /// adhoc).
  Future<void> reorder(int queueItemId, int newIndex);

  /// Gets the current queue state with episode data joined.
  Future<PlaybackQueue> getQueue();

  /// Watches the queue state with episode data joined.
  ///
  /// Emits a new [PlaybackQueue] whenever the queue changes.
  Stream<PlaybackQueue> watchQueue();

  /// Returns true if there are manual items in the queue.
  Future<bool> hasManualItems();

  /// Gets the next episode to play (manual first, then adhoc).
  ///
  /// Returns null if the queue is empty.
  Future<Episode?> getNextEpisode();
}
