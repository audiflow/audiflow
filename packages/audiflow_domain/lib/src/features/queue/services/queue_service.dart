import 'package:audiflow_core/audiflow_core.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../feed/models/episode.dart';
import '../models/queue_item.dart';
import '../../feed/repositories/episode_repository.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../../settings/providers/settings_providers.dart';
import '../../settings/repositories/app_settings_repository.dart';
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
  final settingsRepository = ref.watch(appSettingsRepositoryProvider);
  final logger = ref.watch(namedLoggerProvider('Queue'));

  return QueueService(
    repository: repository,
    episodeRepository: episodeRepository,
    settingsRepository: settingsRepository,
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
    required this._repository,
    required this._episodeRepository,
    required this._settingsRepository,
    required this._logger,
  });

  final QueueRepository _repository;
  final EpisodeRepository _episodeRepository;
  final AppSettingsRepository _settingsRepository;
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

  /// Creates an adhoc queue of episodes following the given episode.
  ///
  /// The starting episode is NOT included in the queue (it becomes "now
  /// playing"). Only subsequent episodes are queued.
  ///
  /// When [siblingEpisodeIds] is provided, the queue is built from those
  /// IDs only (filtered to episodes after the starting one). This is used
  /// for smart playlists where episodes are grouped by title pattern.
  ///
  /// When [siblingEpisodeIds] is null, subsequent episodes are fetched from
  /// the database by podcast and episode number.
  ///
  /// When [effectiveOrder] is provided, it overrides the user's global
  /// auto-play order setting for this queue. Use this for contexts that
  /// define their own sort (e.g., stations passing [AutoPlayOrder.asDisplayed]).
  ///
  /// [sourceContext] describes where the episodes came from (e.g., "Season 2").
  Future<void> createAdhocQueue({
    required int startingEpisodeId,
    required String sourceContext,
    List<int>? siblingEpisodeIds,
    AutoPlayOrder? effectiveOrder,
  }) async {
    final startingEpisode = await _episodeRepository.getById(startingEpisodeId);
    if (startingEpisode == null) {
      _logger.w(
        'createAdhocQueue: Starting episode not found: $startingEpisodeId',
      );
      return;
    }

    List<int> episodeIds;

    if (siblingEpisodeIds != null) {
      final fromHere = await episodesFromHere(
        startingEpisodeId: startingEpisodeId,
        siblingEpisodeIds: siblingEpisodeIds,
        effectiveOrder: effectiveOrder,
      );
      episodeIds = fromHere.skip(1).toList();
    } else {
      // Get subsequent episodes (episode number ascending, after starting)
      final subsequentEpisodes = await _episodeRepository.getSubsequentEpisodes(
        podcastId: startingEpisode.podcastId,
        afterEpisodeNumber: startingEpisode.episodeNumber,
        limit: 100,
      );
      episodeIds = subsequentEpisodes.map((e) => e.id).toList();
    }

    await _repository.replaceWithAdhoc(
      episodeIds: episodeIds,
      sourceContext: sourceContext,
    );

    _logger.i(
      'Created adhoc queue from "$sourceContext" with ${episodeIds.length} '
      'episode(s), after: ${startingEpisode.title}',
    );
  }

  /// Returns [startingEpisodeId] followed by the episodes after it in
  /// [siblingEpisodeIds], ordered by [effectiveOrder] (falling back to the
  /// user's auto-play order). Empty when the starting episode is not in
  /// the list.
  Future<List<int>> episodesFromHere({
    required int startingEpisodeId,
    required List<int> siblingEpisodeIds,
    AutoPlayOrder? effectiveOrder,
  }) async {
    final order = effectiveOrder ?? _settingsRepository.getAutoPlayOrder();
    final ordered = order == AutoPlayOrder.asDisplayed
        ? siblingEpisodeIds
        : await _chronologicalIds(siblingEpisodeIds);
    final startIndex = ordered.indexOf(startingEpisodeId);
    if (startIndex < 0) return [];
    return ordered.sublist(startIndex);
  }

  /// Puts the episodes from [startingEpisodeId] onward at the front of the
  /// manual queue (bulk Play Next). Returns how many were added.
  Future<int> playNextFromHere({
    required int startingEpisodeId,
    required List<int> siblingEpisodeIds,
    AutoPlayOrder? effectiveOrder,
  }) async {
    final episodeIds = await episodesFromHere(
      startingEpisodeId: startingEpisodeId,
      siblingEpisodeIds: siblingEpisodeIds,
      effectiveOrder: effectiveOrder,
    );
    await _repository.addAllToFront(episodeIds);
    _logger.i('Added ${episodeIds.length} episode(s) to queue (Play Next)');
    return episodeIds.length;
  }

  /// Appends the episodes from [startingEpisodeId] onward to the manual
  /// queue (bulk Play Later). Returns how many were added.
  Future<int> playLaterFromHere({
    required int startingEpisodeId,
    required List<int> siblingEpisodeIds,
    AutoPlayOrder? effectiveOrder,
  }) async {
    final episodeIds = await episodesFromHere(
      startingEpisodeId: startingEpisodeId,
      siblingEpisodeIds: siblingEpisodeIds,
      effectiveOrder: effectiveOrder,
    );
    await _repository.addAllToEnd(episodeIds);
    _logger.i('Added ${episodeIds.length} episode(s) to queue (Play Later)');
    return episodeIds.length;
  }

  /// Sorts by publishedAt (chronological) with episodeNumber as fallback.
  Future<List<int>> _chronologicalIds(List<int> episodeIds) async {
    final episodes = await _episodeRepository.getByIds(episodeIds);
    episodes.sort(_compareChronologically);
    return episodes.map((e) => e.id).toList();
  }

  static int _compareChronologically(Episode a, Episode b) {
    final aPub = a.publishedAt;
    final bPub = b.publishedAt;
    if (aPub != null && bPub != null) {
      final cmp = aPub.compareTo(bPub);
      if (cmp != 0) return cmp;
    } else if (aPub != null) {
      return -1;
    } else if (bPub != null) {
      return 1;
    }
    final aNum = a.episodeNumber;
    final bNum = b.episodeNumber;
    if (aNum != null && bNum != null) return aNum.compareTo(bNum);
    return 0;
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

  /// Pops the next episode from the queue head.
  ///
  /// Reads the queue, takes the first item (manual priority, then adhoc),
  /// removes that specific item by ID, and returns its episode. Returns
  /// null if the queue is empty. Removing by ID avoids desync when orphan
  /// queue items (deleted episodes) sit at the database head.
  Future<Episode?> popNextEpisode() async {
    final queue = await _repository.getQueue();
    final nextItem = queue.nextItem;

    if (nextItem == null) {
      _logger.d('Queue is now empty');
      return null;
    }

    await _repository.remove(nextItem.queueItem.id);
    _logger.i('Next episode: ${nextItem.episode.title}');
    return nextItem.episode;
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

    // Remove all items up to and including the target
    for (var i = 0; i <= targetIndex; i++) {
      await _repository.remove(allItems[i].queueItem.id);
    }

    final targetEpisode = allItems[targetIndex].episode;
    _logger.i('Skipped to: ${targetEpisode.title}');

    return targetEpisode;
  }
}
