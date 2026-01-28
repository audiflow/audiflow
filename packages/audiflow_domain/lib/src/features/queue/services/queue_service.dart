import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/logger_provider.dart';
import '../../feed/repositories/episode_repository.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../models/playback_queue.dart';
import '../repositories/queue_repository.dart';
import '../repositories/queue_repository_impl.dart';

part 'queue_service.g.dart';

/// Provides a singleton [QueueService] instance.
///
/// The service provides high-level queue operations with proper logging
/// and coordination between the queue and episode repositories.
@Riverpod(keepAlive: true)
QueueService queueService(Ref ref) {
  final repository = ref.watch(queueRepositoryProvider);
  final episodeRepository = ref.watch(episodeRepositoryProvider);
  final logger = ref.watch(namedLoggerProvider('Queue'));

  return QueueService(
    repository: repository,
    episodeRepository: episodeRepository,
    logger: logger,
  );
}

/// High-level service for managing the playback queue.
///
/// Provides operations for:
/// - Adding episodes to the queue (Play Next / Play Later)
/// - Creating adhoc queues from episode lists
/// - Managing queue items (remove, reorder, clear)
/// - Getting the next episode for playback
class QueueService {
  QueueService({
    required QueueRepository repository,
    required EpisodeRepository episodeRepository,
    required Logger logger,
  }) : _repository = repository,
       _episodeRepository = episodeRepository,
       _logger = logger;

  final QueueRepository _repository;
  final EpisodeRepository _episodeRepository;
  final Logger _logger;

  /// Adds an episode to the end of the queue (Play Later).
  ///
  /// The episode will be played after all other queued items.
  /// Returns the created queue item, or null if the episode was not found.
  Future<QueueItem?> playLater(int episodeId) async {
    final episode = await _episodeRepository.getById(episodeId);
    if (episode == null) {
      _logger.w('playLater: Episode not found: $episodeId');
      return null;
    }

    final item = await _repository.addToEnd(episodeId);
    _logger.i('Added to queue (Play Later): ${episode.title}');
    return item;
  }

  /// Adds an episode to the front of the queue (Play Next).
  ///
  /// The episode will be played immediately after the current episode.
  /// Returns the created queue item, or null if the episode was not found.
  Future<QueueItem?> playNext(int episodeId) async {
    final episode = await _episodeRepository.getById(episodeId);
    if (episode == null) {
      _logger.w('playNext: Episode not found: $episodeId');
      return null;
    }

    final item = await _repository.addToFront(episodeId);
    _logger.i('Added to queue (Play Next): ${episode.title}');
    return item;
  }

  /// Returns true if there are manual queue items that would be replaced.
  ///
  /// Use this to determine if a confirmation dialog should be shown
  /// before creating an adhoc queue.
  Future<bool> shouldConfirmAdhocReplace() async {
    return _repository.hasManualItems();
  }

  /// Creates an adhoc queue starting from the given episode.
  ///
  /// This replaces the entire queue with episodes from the same context
  /// (e.g., season, podcast). The [startingEpisodeId] is included as the
  /// first item, followed by subsequent episodes.
  ///
  /// [sourceContext] describes where the episodes came from (e.g., "Season 2").
  Future<void> createAdhocQueue({
    required int startingEpisodeId,
    required String sourceContext,
  }) async {
    final startingEpisode = await _episodeRepository.getById(startingEpisodeId);
    if (startingEpisode == null) {
      _logger.w(
        'createAdhocQueue: Starting episode not found: $startingEpisodeId',
      );
      return;
    }

    // Get subsequent episodes with limit of 99 (total adhoc limit is 100 including start)
    final subsequentEpisodes = await _episodeRepository.getSubsequentEpisodes(
      podcastId: startingEpisode.podcastId,
      afterEpisodeNumber: startingEpisode.episodeNumber,
      limit: 99,
    );

    // Combine starting episode + subsequent episodes
    final episodeIds = [
      startingEpisodeId,
      ...subsequentEpisodes.map((e) => e.id),
    ];

    await _repository.replaceWithAdhoc(
      episodeIds: episodeIds,
      sourceContext: sourceContext,
    );

    _logger.i(
      'Created adhoc queue from "$sourceContext" with ${episodeIds.length} '
      'episode(s), starting with: ${startingEpisode.title}',
    );
  }

  /// Removes an item from the queue.
  Future<void> removeItem(int queueItemId) async {
    await _repository.remove(queueItemId);
    _logger.d('Removed queue item: $queueItemId');
  }

  /// Clears all items from the queue.
  Future<void> clearQueue() async {
    await _repository.clearAll();
    _logger.i('Queue cleared');
  }

  /// Reorders an item to a new position in the queue.
  ///
  /// [newIndex] is the target index in the combined queue list
  /// (manual items first, then adhoc items).
  Future<void> reorderItem(int queueItemId, int newIndex) async {
    await _repository.reorder(queueItemId, newIndex);
    _logger.d('Reordered queue item $queueItemId to index $newIndex');
  }

  /// Gets the next episode and removes the current first item.
  ///
  /// This is typically called when playback completes and the player
  /// needs to advance to the next episode. Returns the next episode
  /// to play, or null if the queue is empty.
  Future<Episode?> getNextAndRemoveCurrent() async {
    // Remove the current first item
    await _repository.removeFirst();

    // Get the new next episode
    final nextEpisode = await _repository.getNextEpisode();

    if (nextEpisode != null) {
      _logger.i('Next episode: ${nextEpisode.title}');
    } else {
      _logger.d('Queue is now empty');
    }

    return nextEpisode;
  }

  /// Gets the current queue state.
  Future<PlaybackQueue> getQueue() {
    return _repository.getQueue();
  }

  /// Watches the queue state for changes.
  ///
  /// Emits a new [PlaybackQueue] whenever the queue changes.
  Stream<PlaybackQueue> watchQueue() {
    return _repository.watchQueue();
  }

  /// Skips to a specific item in the queue.
  ///
  /// Removes all items before the target item and returns its episode.
  /// Returns null if the item is not found in the queue.
  Future<Episode?> skipToItem(int queueItemId) async {
    final queue = await _repository.getQueue();
    final allItems = queue.allItems;

    // Find the target item index
    final targetIndex = allItems.indexWhere(
      (item) => item.queueItem.id == queueItemId,
    );

    if (targetIndex < 0) {
      _logger.w('skipToItem: Queue item not found: $queueItemId');
      return null;
    }

    // Remove all items before the target
    for (var i = 0; i < targetIndex; i++) {
      await _repository.remove(allItems[i].queueItem.id);
    }

    final targetEpisode = allItems[targetIndex].episode;
    _logger.i('Skipped to: ${targetEpisode.title}');

    return targetEpisode;
  }
}
