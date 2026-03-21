import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../feed/datasources/local/episode_local_datasource.dart';
import '../../feed/models/episode.dart';
import '../../subscription/datasources/local/subscription_local_datasource.dart';
import '../datasources/local/queue_local_datasource.dart';
import '../models/playback_queue.dart';
import '../models/queue_item.dart';
import 'queue_repository.dart';

part 'queue_repository_impl.g.dart';

/// Maximum number of adhoc items to keep in the queue.
const int _maxAdhocItems = 100;

/// Position increment for sparse positioning.
const int _positionIncrement = 10;

/// Provides a singleton [QueueRepository] instance.
@Riverpod(keepAlive: true)
QueueRepository queueRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  final queueDatasource = QueueLocalDatasource(isar);
  final episodeDatasource = EpisodeLocalDatasource(isar);
  final subscriptionDatasource = SubscriptionLocalDatasource(isar);
  return QueueRepositoryImpl(
    queueDatasource: queueDatasource,
    episodeDatasource: episodeDatasource,
    subscriptionDatasource: subscriptionDatasource,
  );
}

/// Implementation of [QueueRepository] using Isar database.
class QueueRepositoryImpl implements QueueRepository {
  QueueRepositoryImpl({
    required QueueLocalDatasource queueDatasource,
    required EpisodeLocalDatasource episodeDatasource,
    required SubscriptionLocalDatasource subscriptionDatasource,
  }) : _queueDatasource = queueDatasource,
       _episodeDatasource = episodeDatasource,
       _subscriptionDatasource = subscriptionDatasource;

  final QueueLocalDatasource _queueDatasource;
  final EpisodeLocalDatasource _episodeDatasource;
  final SubscriptionLocalDatasource _subscriptionDatasource;

  @override
  Future<QueueItem> addToEnd(int episodeId) async {
    final maxPosition = await _queueDatasource.getMaxPosition();
    final newPosition = maxPosition + _positionIncrement;

    final item = QueueItem()
      ..episodeId = episodeId
      ..position = newPosition
      ..isAdhoc = false
      ..addedAt = DateTime.now();

    final id = await _queueDatasource.insert(item);
    final items = await _queueDatasource.getAll();
    return items.firstWhere((item) => item.id == id);
  }

  @override
  Future<QueueItem> addToFront(int episodeId) async {
    final minPosition = await _queueDatasource.getMinPosition();
    final newPosition = minPosition - _positionIncrement;

    final item = QueueItem()
      ..episodeId = episodeId
      ..position = newPosition
      ..isAdhoc = false
      ..addedAt = DateTime.now();

    final id = await _queueDatasource.insert(item);
    final items = await _queueDatasource.getAll();
    return items.firstWhere((item) => item.id == id);
  }

  @override
  Future<void> replaceWithAdhoc({
    required List<int> episodeIds,
    required String sourceContext,
  }) async {
    await _queueDatasource.deleteAll();

    // Limit adhoc items to prevent unbounded growth
    final limitedIds = episodeIds.length <= _maxAdhocItems
        ? episodeIds
        : episodeIds.sublist(0, _maxAdhocItems);

    var position = 0;
    for (final episodeId in limitedIds) {
      final item = QueueItem()
        ..episodeId = episodeId
        ..position = position
        ..isAdhoc = true
        ..sourceContext = sourceContext
        ..addedAt = DateTime.now();
      await _queueDatasource.insert(item);
      position += _positionIncrement;
    }
  }

  @override
  Future<void> remove(int queueItemId) async {
    await _queueDatasource.deleteById(queueItemId);
  }

  @override
  Future<void> removeFirst() async {
    final allItems = await _queueDatasource.getAll();
    if (allItems.isEmpty) return;

    // Manual items have priority
    final manualItems = allItems.where((item) => !item.isAdhoc).toList();
    if (manualItems.isNotEmpty) {
      await _queueDatasource.deleteById(manualItems.first.id);
      return;
    }

    // Fall back to first adhoc item
    await _queueDatasource.deleteById(allItems.first.id);
  }

  @override
  Future<void> clearAll() async {
    await _queueDatasource.deleteAll();
  }

  @override
  Future<void> reorder(int queueItemId, int newIndex) async {
    final allItems = await _queueDatasource.getAll();
    if (allItems.isEmpty) return;

    // Separate into manual and adhoc, maintaining position order
    final manualItems = allItems.where((item) => !item.isAdhoc).toList();
    final adhocItems = allItems.where((item) => item.isAdhoc).toList();

    // Combined list: manual first, then adhoc
    final combined = [...manualItems, ...adhocItems];

    // Validate new index bounds
    if (newIndex < 0 || combined.length <= newIndex) return;

    // Find the item to move
    final itemIndex = combined.indexWhere((item) => item.id == queueItemId);
    if (itemIndex < 0) return;
    if (itemIndex == newIndex) return;

    // Calculate new position based on neighbors
    final newPosition = _calculateNewPosition(combined, newIndex, itemIndex);
    await _queueDatasource.updatePosition(queueItemId, newPosition);
  }

  /// Calculates a new position value for reordering.
  int _calculateNewPosition(
    List<QueueItem> items,
    int targetIndex,
    int currentIndex,
  ) {
    // Moving to first position
    if (targetIndex == 0) {
      return items.first.position - _positionIncrement;
    }

    // Moving to last position
    if (targetIndex == items.length - 1) {
      return items.last.position + _positionIncrement;
    }

    // Moving between two items
    final before = currentIndex < targetIndex
        ? items[targetIndex]
        : items[targetIndex - 1];
    final after = currentIndex < targetIndex
        ? items[targetIndex + 1]
        : items[targetIndex];

    // Use midpoint between neighbors
    return (before.position + after.position) ~/ 2;
  }

  @override
  Future<PlaybackQueue> getQueue() async {
    final items = await _queueDatasource.getAll();
    return _buildPlaybackQueue(items);
  }

  @override
  Stream<PlaybackQueue> watchQueue() {
    return _queueDatasource.watchAll().asyncMap(_buildPlaybackQueue);
  }

  /// Builds a [PlaybackQueue] by joining queue items with episode data.
  ///
  /// Resolves artwork for each item: episode image first, then podcast artwork.
  Future<PlaybackQueue> _buildPlaybackQueue(List<QueueItem> items) async {
    if (items.isEmpty) {
      return const PlaybackQueue();
    }

    // Fetch all episodes in a single query
    final episodeIds = items.map((item) => item.episodeId).toList();
    final episodes = await _episodeDatasource.getByIds(episodeIds);
    final episodeMap = {for (final e in episodes) e.id: e};

    // Batch-fetch subscriptions for artwork fallback
    final podcastIds = episodes.map((e) => e.podcastId).toSet().toList();
    final subscriptions = await _subscriptionDatasource.getByIds(podcastIds);
    final subscriptionMap = {for (final s in subscriptions) s.id: s};

    // Separate items into manual and adhoc
    final manualItems = <QueueItemWithEpisode>[];
    final adhocItems = <QueueItemWithEpisode>[];
    String? adhocSourceContext;

    for (final item in items) {
      final episode = episodeMap[item.episodeId];
      if (episode == null) continue;

      final artworkUrl =
          episode.imageUrl ?? subscriptionMap[episode.podcastId]?.artworkUrl;

      final queueItemWithEpisode = QueueItemWithEpisode(
        queueItem: item,
        episode: episode,
        artworkUrl: artworkUrl,
      );

      if (item.isAdhoc) {
        adhocItems.add(queueItemWithEpisode);
        adhocSourceContext ??= item.sourceContext;
      } else {
        manualItems.add(queueItemWithEpisode);
      }
    }

    return PlaybackQueue(
      manualItems: manualItems,
      adhocItems: adhocItems,
      adhocSourceContext: adhocSourceContext,
    );
  }

  @override
  Future<bool> hasManualItems() async {
    final count = await _queueDatasource.getManualCount();
    return 0 < count;
  }

  @override
  Future<Episode?> getNextEpisode() async {
    final queue = await getQueue();
    return queue.nextItem?.episode;
  }
}
