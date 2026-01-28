# Play Queue Feature Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement a play queue feature with manual queue (Play Next/Play Later) and adhoc queue (auto-generated from episode lists), with persistence, drag-to-reorder, and auto-play next.

**Architecture:** Domain-driven design with Drift for persistence, Riverpod for state management. Queue items stored in database, loaded into in-memory state on startup. QueueService orchestrates all queue operations, integrates with AudioPlayerController for playback.

**Tech Stack:** Flutter, Drift, Riverpod (with codegen), Freezed, go_router

---

## Phase 1: Data Layer (audiflow_domain)

### Task 1: Create QueueItem Drift Table

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/queue/models/queue_item.dart`

**Step 1: Create the Drift table definition**

```dart
import 'package:drift/drift.dart';

import '../../feed/models/episode.dart';

/// Queue items table for persistent queue storage.
///
/// Supports both manual queue items (user-added) and adhoc queue items
/// (auto-generated from episode lists).
class QueueItems extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Reference to the episode in the queue.
  IntColumn get episodeId => integer().references(Episodes, #id)();

  /// Position in the queue (sparse values: 0, 10, 20... for easy insertion).
  IntColumn get position => integer()();

  /// Whether this is an adhoc queue item (true) or manual (false).
  BoolColumn get isAdhoc => boolean().withDefault(const Constant(false))();

  /// Source context for adhoc items (e.g., "Season 2").
  TextColumn get sourceContext => text().nullable()();

  /// When this item was added to the queue.
  DateTimeColumn get addedAt => dateTime()();
}
```

**Step 2: Run codegen to verify table compiles**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Build succeeds (table not yet registered in database)

**Step 3: Commit**

```bash
jj describe -m "feat(queue): add QueueItems drift table definition"
```

---

### Task 2: Create PlaybackQueue Freezed Model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/queue/models/playback_queue.dart`

**Step 1: Create the freezed in-memory state model**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../feed/models/episode.dart';
import 'queue_item.dart';

part 'playback_queue.freezed.dart';

/// A queue item joined with its episode data.
@freezed
class QueueItemWithEpisode with _$QueueItemWithEpisode {
  const factory QueueItemWithEpisode({
    required QueueItem queueItem,
    required Episode episode,
  }) = _QueueItemWithEpisode;
}

/// In-memory representation of the playback queue.
@freezed
class PlaybackQueue with _$PlaybackQueue {
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
}
```

**Step 2: Run codegen**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: `playback_queue.freezed.dart` generated

**Step 3: Commit**

```bash
jj describe -m "feat(queue): add PlaybackQueue freezed model"
```

---

### Task 3: Register QueueItems Table and Add Migration

**Files:**
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart`

**Step 1: Add import and register table**

Add to imports:
```dart
import '../../features/queue/models/queue_item.dart';
```

Add `QueueItems` to the `@DriftDatabase` tables list:
```dart
@DriftDatabase(
  tables: [
    Subscriptions,
    Episodes,
    PlaybackHistories,
    Seasons,
    PodcastViewPreferences,
    DownloadTasks,
    QueueItems,  // Add this
  ],
)
```

**Step 2: Increment schema version and add migration**

Change `schemaVersion` from 9 to 10.

Add migration in `onUpgrade`:
```dart
// Migration v10: Add QueueItems table
if (10 <= to && from < 10) {
  await m.createTable(queueItems);
}
```

**Step 3: Run codegen**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: `app_database.g.dart` regenerated with QueueItems

**Step 4: Commit**

```bash
jj describe -m "feat(queue): register QueueItems table and add migration v10"
```

---

### Task 4: Create Queue Local Datasource

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/queue/datasources/local/queue_local_datasource.dart`

**Step 1: Create the datasource class**

```dart
import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';
import '../../models/queue_item.dart';

/// Local datasource for queue item persistence using Drift.
class QueueLocalDatasource {
  QueueLocalDatasource(this._db);

  final AppDatabase _db;

  /// Inserts a new queue item. Returns the inserted item's ID.
  Future<int> insert(QueueItemsCompanion companion) {
    return _db.into(_db.queueItems).insert(companion);
  }

  /// Gets all queue items ordered by position.
  Future<List<QueueItem>> getAll() {
    return (_db.select(_db.queueItems)
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
  }

  /// Watches all queue items ordered by position.
  Stream<List<QueueItem>> watchAll() {
    return (_db.select(_db.queueItems)
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
  }

  /// Gets the maximum position value in the queue.
  Future<int> getMaxPosition() async {
    final query = _db.selectOnly(_db.queueItems)
      ..addColumns([_db.queueItems.position.max()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.queueItems.position.max()) ?? -10;
  }

  /// Gets the minimum position value in the queue.
  Future<int> getMinPosition() async {
    final query = _db.selectOnly(_db.queueItems)
      ..addColumns([_db.queueItems.position.min()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.queueItems.position.min()) ?? 10;
  }

  /// Updates the position of a queue item.
  Future<int> updatePosition(int id, int newPosition) {
    return (_db.update(_db.queueItems)..where((t) => t.id.equals(id)))
        .write(QueueItemsCompanion(position: Value(newPosition)));
  }

  /// Deletes a queue item by ID.
  Future<int> deleteById(int id) {
    return (_db.delete(_db.queueItems)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all queue items.
  Future<int> deleteAll() {
    return _db.delete(_db.queueItems).go();
  }

  /// Deletes all adhoc queue items.
  Future<int> deleteAllAdhoc() {
    return (_db.delete(_db.queueItems)..where((t) => t.isAdhoc.equals(true)))
        .go();
  }

  /// Deletes all manual (non-adhoc) queue items.
  Future<int> deleteAllManual() {
    return (_db.delete(_db.queueItems)..where((t) => t.isAdhoc.equals(false)))
        .go();
  }

  /// Gets count of manual (non-adhoc) items.
  Future<int> getManualCount() async {
    final query = _db.selectOnly(_db.queueItems)
      ..where(_db.queueItems.isAdhoc.equals(false))
      ..addColumns([_db.queueItems.id.count()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.queueItems.id.count()) ?? 0;
  }

  /// Gets count of adhoc items.
  Future<int> getAdhocCount() async {
    final query = _db.selectOnly(_db.queueItems)
      ..where(_db.queueItems.isAdhoc.equals(true))
      ..addColumns([_db.queueItems.id.count()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.queueItems.id.count()) ?? 0;
  }

  /// Shifts all positions by a delta (used for Play Next insertion).
  Future<void> shiftPositions(int delta) async {
    await _db.customStatement(
      'UPDATE queue_items SET position = position + ?',
      [delta],
    );
  }

  /// Shifts positions of items at or after a given position.
  Future<void> shiftPositionsFrom(int fromPosition, int delta) async {
    await _db.customStatement(
      'UPDATE queue_items SET position = position + ? WHERE position >= ?',
      [delta, fromPosition],
    );
  }
}
```

**Step 2: Commit**

```bash
jj describe -m "feat(queue): add QueueLocalDatasource for drift operations"
```

---

### Task 5: Create Queue Repository Interface

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/queue/repositories/queue_repository.dart`

**Step 1: Create the repository interface**

```dart
import '../../feed/models/episode.dart';
import '../models/playback_queue.dart';
import '../models/queue_item.dart';

/// Repository interface for queue operations.
abstract class QueueRepository {
  /// Adds an episode to the end of the manual queue (Play Later).
  Future<QueueItem> addToEnd(int episodeId);

  /// Adds an episode to the front of the manual queue (Play Next).
  Future<QueueItem> addToFront(int episodeId);

  /// Replaces the entire queue with adhoc items from episode list.
  ///
  /// [episodeIds] should be ordered by episode number ascending.
  /// [sourceContext] describes the source (e.g., "Season 2").
  Future<void> replaceWithAdhoc({
    required List<int> episodeIds,
    required String sourceContext,
  });

  /// Removes a queue item by its ID.
  Future<void> remove(int queueItemId);

  /// Removes the first item from the queue (after playback completes).
  Future<void> removeFirst();

  /// Clears the entire queue.
  Future<void> clearAll();

  /// Reorders an item from one position to another.
  Future<void> reorder(int queueItemId, int newIndex);

  /// Gets the current queue state with episode data joined.
  Future<PlaybackQueue> getQueue();

  /// Watches the queue state with episode data joined.
  Stream<PlaybackQueue> watchQueue();

  /// Returns true if there are manual items in the queue.
  Future<bool> hasManualItems();

  /// Gets the next episode to play (manual first, then adhoc).
  Future<Episode?> getNextEpisode();
}
```

**Step 2: Commit**

```bash
jj describe -m "feat(queue): add QueueRepository interface"
```

---

### Task 6: Create Queue Repository Implementation

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/queue/repositories/queue_repository_impl.dart`

**Step 1: Create the repository implementation**

```dart
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../audiflow_domain.dart';
import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../../feed/models/episode.dart';
import '../../feed/repositories/episode_repository.dart';
import '../datasources/local/queue_local_datasource.dart';
import '../models/playback_queue.dart';
import '../models/queue_item.dart';
import 'queue_repository.dart';

part 'queue_repository_impl.g.dart';

/// Maximum number of adhoc items allowed.
const int maxAdhocItems = 100;

/// Position increment for sparse ordering.
const int positionIncrement = 10;

@Riverpod(keepAlive: true)
QueueRepository queueRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final datasource = QueueLocalDatasource(db);
  return QueueRepositoryImpl(
    datasource: datasource,
    db: db,
    episodeRepository: episodeRepo,
  );
}

class QueueRepositoryImpl implements QueueRepository {
  QueueRepositoryImpl({
    required QueueLocalDatasource datasource,
    required AppDatabase db,
    required EpisodeRepository episodeRepository,
  })  : _datasource = datasource,
        _db = db,
        _episodeRepository = episodeRepository;

  final QueueLocalDatasource _datasource;
  final AppDatabase _db;
  final EpisodeRepository _episodeRepository;

  @override
  Future<QueueItem> addToEnd(int episodeId) async {
    final maxPos = await _datasource.getMaxPosition();
    final newPosition = maxPos + positionIncrement;

    final id = await _datasource.insert(
      QueueItemsCompanion.insert(
        episodeId: episodeId,
        position: newPosition,
        isAdhoc: const Value(false),
        addedAt: DateTime.now(),
      ),
    );

    final items = await _datasource.getAll();
    return items.firstWhere((item) => item.id == id);
  }

  @override
  Future<QueueItem> addToFront(int episodeId) async {
    final minPos = await _datasource.getMinPosition();
    final newPosition = minPos - positionIncrement;

    final id = await _datasource.insert(
      QueueItemsCompanion.insert(
        episodeId: episodeId,
        position: newPosition,
        isAdhoc: const Value(false),
        addedAt: DateTime.now(),
      ),
    );

    final items = await _datasource.getAll();
    return items.firstWhere((item) => item.id == id);
  }

  @override
  Future<void> replaceWithAdhoc({
    required List<int> episodeIds,
    required String sourceContext,
  }) async {
    await _datasource.deleteAll();

    final limitedIds = episodeIds.take(maxAdhocItems).toList();
    final now = DateTime.now();

    for (var i = 0; i < limitedIds.length; i++) {
      await _datasource.insert(
        QueueItemsCompanion.insert(
          episodeId: limitedIds[i],
          position: i * positionIncrement,
          isAdhoc: const Value(true),
          sourceContext: Value(sourceContext),
          addedAt: now,
        ),
      );
    }
  }

  @override
  Future<void> remove(int queueItemId) async {
    await _datasource.deleteById(queueItemId);
  }

  @override
  Future<void> removeFirst() async {
    final items = await _datasource.getAll();
    if (items.isEmpty) return;

    // Manual items have priority, find first manual or first adhoc
    final manualItems = items.where((i) => !i.isAdhoc).toList();
    final firstItem = manualItems.isNotEmpty ? manualItems.first : items.first;

    await _datasource.deleteById(firstItem.id);
  }

  @override
  Future<void> clearAll() async {
    await _datasource.deleteAll();
  }

  @override
  Future<void> reorder(int queueItemId, int newIndex) async {
    final items = await _datasource.getAll();
    final allItems = _separateAndMerge(items);

    if (newIndex < 0 || allItems.length <= newIndex) return;

    final itemIndex = allItems.indexWhere((i) => i.id == queueItemId);
    if (0 > itemIndex) return;

    // Calculate new position based on neighbors
    int newPosition;
    if (newIndex == 0) {
      newPosition = allItems.first.position - positionIncrement;
    } else if (newIndex == allItems.length - 1) {
      newPosition = allItems.last.position + positionIncrement;
    } else {
      final before = allItems[newIndex - 1];
      final after = allItems[newIndex];
      newPosition = (before.position + after.position) ~/ 2;
    }

    await _datasource.updatePosition(queueItemId, newPosition);
  }

  @override
  Future<PlaybackQueue> getQueue() async {
    final items = await _datasource.getAll();
    return _buildPlaybackQueue(items);
  }

  @override
  Stream<PlaybackQueue> watchQueue() {
    return _datasource.watchAll().asyncMap(_buildPlaybackQueue);
  }

  @override
  Future<bool> hasManualItems() async {
    final count = await _datasource.getManualCount();
    return 0 < count;
  }

  @override
  Future<Episode?> getNextEpisode() async {
    final queue = await getQueue();
    return queue.nextItem?.episode;
  }

  /// Builds PlaybackQueue from raw queue items.
  Future<PlaybackQueue> _buildPlaybackQueue(List<QueueItem> items) async {
    final manualItems = <QueueItemWithEpisode>[];
    final adhocItems = <QueueItemWithEpisode>[];
    String? adhocContext;

    for (final item in items) {
      final episode = await _episodeRepository.getById(item.episodeId);
      if (episode == null) continue;

      final withEpisode = QueueItemWithEpisode(
        queueItem: item,
        episode: episode,
      );

      if (item.isAdhoc) {
        adhocItems.add(withEpisode);
        adhocContext ??= item.sourceContext;
      } else {
        manualItems.add(withEpisode);
      }
    }

    return PlaybackQueue(
      manualItems: manualItems,
      adhocItems: adhocItems,
      adhocSourceContext: adhocContext,
    );
  }

  /// Separates items by type and merges in playback order (manual first).
  List<QueueItem> _separateAndMerge(List<QueueItem> items) {
    final manual = items.where((i) => !i.isAdhoc).toList();
    final adhoc = items.where((i) => i.isAdhoc).toList();
    return [...manual, ...adhoc];
  }
}
```

**Step 2: Run codegen**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: `queue_repository_impl.g.dart` generated

**Step 3: Commit**

```bash
jj describe -m "feat(queue): add QueueRepositoryImpl with riverpod provider"
```

---

### Task 7: Create Queue Service

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/queue/services/queue_service.dart`

**Step 1: Create the service**

```dart
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../feed/models/episode.dart';
import '../../feed/repositories/episode_repository.dart';
import '../models/playback_queue.dart';
import '../repositories/queue_repository.dart';
import '../repositories/queue_repository_impl.dart';

part 'queue_service.g.dart';

@Riverpod(keepAlive: true)
QueueService queueService(Ref ref) {
  final repository = ref.watch(queueRepositoryProvider);
  final episodeRepository = ref.watch(episodeRepositoryProvider);
  final logger = ref.watch(namedLoggerProvider('QueueService'));

  return QueueService(
    repository: repository,
    episodeRepository: episodeRepository,
    logger: logger,
  );
}

/// High-level service for queue operations.
class QueueService {
  QueueService({
    required QueueRepository repository,
    required EpisodeRepository episodeRepository,
    required Logger logger,
  })  : _repository = repository,
        _episodeRepository = episodeRepository,
        _logger = logger;

  final QueueRepository _repository;
  final EpisodeRepository _episodeRepository;
  final Logger _logger;

  /// Adds episode to end of queue (Play Later).
  Future<void> playLater(int episodeId) async {
    _logger.d('Adding episode $episodeId to queue (Play Later)');
    await _repository.addToEnd(episodeId);
  }

  /// Adds episode to front of queue (Play Next).
  Future<void> playNext(int episodeId) async {
    _logger.d('Adding episode $episodeId to queue (Play Next)');
    await _repository.addToFront(episodeId);
  }

  /// Creates adhoc queue from episode list.
  ///
  /// [startingEpisodeId] is the episode that will start playing.
  /// [podcastId] is used to fetch subsequent episodes.
  /// [sourceContext] describes the source (e.g., "Season 2").
  ///
  /// Returns false if user should be prompted for confirmation (manual queue exists).
  Future<bool> shouldConfirmAdhocReplace() async {
    return _repository.hasManualItems();
  }

  /// Creates adhoc queue starting from given episode.
  ///
  /// Fetches episodes from the same podcast, ordered by episode number ascending,
  /// starting after the given episode.
  Future<void> createAdhocQueue({
    required int startingEpisodeId,
    required String sourceContext,
  }) async {
    _logger.d('Creating adhoc queue from episode $startingEpisodeId');

    final startingEpisode = await _episodeRepository.getById(startingEpisodeId);
    if (startingEpisode == null) {
      _logger.w('Starting episode not found: $startingEpisodeId');
      return;
    }

    // Get subsequent episodes by episode number ascending
    final subsequentEpisodes = await _episodeRepository.getSubsequentEpisodes(
      podcastId: startingEpisode.podcastId,
      afterEpisodeNumber: startingEpisode.episodeNumber,
      limit: 100,
    );

    final episodeIds = subsequentEpisodes.map((e) => e.id).toList();

    await _repository.replaceWithAdhoc(
      episodeIds: episodeIds,
      sourceContext: sourceContext,
    );

    _logger.i('Created adhoc queue with ${episodeIds.length} episodes');
  }

  /// Removes an item from the queue.
  Future<void> removeItem(int queueItemId) async {
    _logger.d('Removing queue item $queueItemId');
    await _repository.remove(queueItemId);
  }

  /// Clears the entire queue.
  Future<void> clearQueue() async {
    _logger.d('Clearing queue');
    await _repository.clearAll();
  }

  /// Reorders an item to a new position.
  Future<void> reorderItem(int queueItemId, int newIndex) async {
    _logger.d('Reordering item $queueItemId to index $newIndex');
    await _repository.reorder(queueItemId, newIndex);
  }

  /// Gets the next episode and removes current from queue.
  ///
  /// Call this when playback completes.
  Future<Episode?> getNextAndRemoveCurrent() async {
    await _repository.removeFirst();
    return _repository.getNextEpisode();
  }

  /// Gets the current queue state.
  Future<PlaybackQueue> getQueue() => _repository.getQueue();

  /// Watches the queue state.
  Stream<PlaybackQueue> watchQueue() => _repository.watchQueue();

  /// Skips to a specific item in the queue.
  ///
  /// Removes all items before it, making it the current playback target.
  Future<Episode?> skipToItem(int queueItemId) async {
    final queue = await _repository.getQueue();
    final allItems = queue.allItems;

    final targetIndex = allItems.indexWhere(
      (item) => item.queueItem.id == queueItemId,
    );

    if (0 > targetIndex) return null;

    // Remove all items before the target
    for (var i = 0; i < targetIndex; i++) {
      await _repository.remove(allItems[i].queueItem.id);
    }

    return allItems[targetIndex].episode;
  }
}
```

**Step 2: Run codegen**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: `queue_service.g.dart` generated

**Step 3: Commit**

```bash
jj describe -m "feat(queue): add QueueService with high-level queue operations"
```

---

### Task 8: Create Queue Providers

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/queue/providers/queue_providers.dart`

**Step 1: Create stream providers**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/playback_queue.dart';
import '../repositories/queue_repository_impl.dart';

part 'queue_providers.g.dart';

/// Watches the current queue state.
@riverpod
Stream<PlaybackQueue> playbackQueue(Ref ref) {
  final repository = ref.watch(queueRepositoryProvider);
  return repository.watchQueue();
}

/// Gets the total number of items in queue.
@riverpod
Future<int> queueItemCount(Ref ref) async {
  final queue = await ref.watch(playbackQueueProvider.future);
  return queue.totalCount;
}

/// Returns true if manual queue has items (for adhoc confirmation).
@riverpod
Future<bool> hasManualQueueItems(Ref ref) async {
  final queue = await ref.watch(playbackQueueProvider.future);
  return queue.hasManualItems;
}
```

**Step 2: Run codegen**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: `queue_providers.g.dart` generated

**Step 3: Commit**

```bash
jj describe -m "feat(queue): add queue state providers"
```

---

### Task 9: Export Queue Feature from Domain Package

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

**Step 1: Add queue feature exports**

Add these exports to the barrel file:

```dart
// Queue feature
export 'src/features/queue/models/queue_item.dart';
export 'src/features/queue/models/playback_queue.dart';
export 'src/features/queue/repositories/queue_repository.dart';
export 'src/features/queue/repositories/queue_repository_impl.dart';
export 'src/features/queue/services/queue_service.dart';
export 'src/features/queue/providers/queue_providers.dart';
```

**Step 2: Commit**

```bash
jj describe -m "feat(queue): export queue feature from domain package"
```

---

### Task 10: Add getSubsequentEpisodes to Episode Repository

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository_impl.dart`

**Step 1: Add method to interface**

Add to `EpisodeRepository`:
```dart
/// Gets episodes after a given episode number, ordered ascending.
Future<List<Episode>> getSubsequentEpisodes({
  required int podcastId,
  required int? afterEpisodeNumber,
  required int limit,
});
```

**Step 2: Add implementation**

Add to `EpisodeRepositoryImpl`:
```dart
@override
Future<List<Episode>> getSubsequentEpisodes({
  required int podcastId,
  required int? afterEpisodeNumber,
  required int limit,
}) async {
  return _datasource.getSubsequentEpisodes(
    podcastId: podcastId,
    afterEpisodeNumber: afterEpisodeNumber,
    limit: limit,
  );
}
```

**Step 3: Add datasource method**

Add to `EpisodeLocalDatasource`:
```dart
/// Gets episodes after a given episode number, ordered by episode number ascending.
Future<List<Episode>> getSubsequentEpisodes({
  required int podcastId,
  required int? afterEpisodeNumber,
  required int limit,
}) {
  final query = _db.select(_db.episodes)
    ..where((t) => t.podcastId.equals(podcastId));

  if (afterEpisodeNumber != null) {
    query.where((t) => t.episodeNumber.isBiggerThanValue(afterEpisodeNumber));
  }

  query
    ..orderBy([(t) => OrderingTerm.asc(t.episodeNumber)])
    ..limit(limit);

  return query.get();
}
```

**Step 4: Commit**

```bash
jj describe -m "feat(episode): add getSubsequentEpisodes for adhoc queue"
```

---

## Phase 2: Presentation Layer (audiflow_app)

### Task 11: Create Queue Controller

**Files:**
- Create: `packages/audiflow_app/lib/features/queue/presentation/controllers/queue_controller.dart`

**Step 1: Create the controller**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_controller.g.dart';

/// Controller for queue screen state and actions.
@riverpod
class QueueController extends _$QueueController {
  @override
  Stream<PlaybackQueue> build() {
    final service = ref.watch(queueServiceProvider);
    return service.watchQueue();
  }

  /// Adds episode to queue (Play Later).
  Future<void> playLater(int episodeId) async {
    final service = ref.read(queueServiceProvider);
    await service.playLater(episodeId);
  }

  /// Adds episode to front of queue (Play Next).
  Future<void> playNext(int episodeId) async {
    final service = ref.read(queueServiceProvider);
    await service.playNext(episodeId);
  }

  /// Removes an item from the queue.
  Future<void> removeItem(int queueItemId) async {
    final service = ref.read(queueServiceProvider);
    await service.removeItem(queueItemId);
  }

  /// Clears the entire queue.
  Future<void> clearQueue() async {
    final service = ref.read(queueServiceProvider);
    await service.clearQueue();
  }

  /// Reorders an item to a new position.
  Future<void> reorderItem(int queueItemId, int newIndex) async {
    final service = ref.read(queueServiceProvider);
    await service.reorderItem(queueItemId, newIndex);
  }

  /// Skips to a specific item and starts playback.
  Future<void> skipToItem(int queueItemId) async {
    final service = ref.read(queueServiceProvider);
    final episode = await service.skipToItem(queueItemId);
    if (episode != null) {
      // TODO: Integrate with player to start playback
      // ref.read(audioPlayerControllerProvider.notifier).play(episode);
    }
  }
}
```

**Step 2: Run codegen**

Run: `cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs`
Expected: `queue_controller.g.dart` generated

**Step 3: Commit**

```bash
jj describe -m "feat(queue): add QueueController for queue screen"
```

---

### Task 12: Create Now Playing Card Widget

**Files:**
- Create: `packages/audiflow_app/lib/features/queue/presentation/widgets/now_playing_card.dart`

**Step 1: Create the widget**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';

/// Card displaying the currently playing episode at top of queue screen.
class NowPlayingCard extends StatelessWidget {
  const NowPlayingCard({
    required this.episode,
    super.key,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Artwork
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: episode.imageUrl != null
                  ? Image.network(
                      episode.imageUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            const SizedBox(width: 16),
            // Episode info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOW PLAYING',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    episode.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      color: Colors.grey[300],
      child: const Icon(Icons.podcasts, color: Colors.grey),
    );
  }
}
```

**Step 2: Commit**

```bash
jj describe -m "feat(queue): add NowPlayingCard widget"
```

---

### Task 13: Create Queue List Tile Widget

**Files:**
- Create: `packages/audiflow_app/lib/features/queue/presentation/widgets/queue_list_tile.dart`

**Step 1: Create the widget**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A single queue item tile with drag handle and swipe to remove.
class QueueListTile extends StatelessWidget {
  const QueueListTile({
    required this.item,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final QueueItemWithEpisode item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final episode = item.episode;
    final isAdhoc = item.queueItem.isAdhoc;

    return Dismissible(
      key: Key('queue_item_${item.queueItem.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(
          Symbols.delete,
          color: theme.colorScheme.onError,
        ),
      ),
      child: ListTile(
        leading: const Icon(Symbols.drag_handle),
        title: Text(
          episode.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                _formatDuration(episode.durationMs),
                style: theme.textTheme.bodySmall,
              ),
            ),
            if (isAdhoc)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDuration(int? durationMs) {
    if (durationMs == null) return '';
    final duration = Duration(milliseconds: durationMs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (0 < hours) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }
}
```

**Step 2: Commit**

```bash
jj describe -m "feat(queue): add QueueListTile widget with swipe to remove"
```

---

### Task 14: Create Clear Queue Button Widget

**Files:**
- Create: `packages/audiflow_app/lib/features/queue/presentation/widgets/clear_queue_button.dart`

**Step 1: Create the widget with double-tap confirmation**

```dart
import 'dart:async';

import 'package:flutter/material.dart';

/// Clear button with confirmation that appears in the same position.
///
/// First tap shows "Confirm?", second tap (within timeout) clears.
class ClearQueueButton extends StatefulWidget {
  const ClearQueueButton({
    required this.onClear,
    super.key,
  });

  final VoidCallback onClear;

  @override
  State<ClearQueueButton> createState() => _ClearQueueButtonState();
}

class _ClearQueueButtonState extends State<ClearQueueButton> {
  bool _confirming = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (_confirming) {
      _resetTimer?.cancel();
      setState(() => _confirming = false);
      widget.onClear();
    } else {
      setState(() => _confirming = true);
      _resetTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _confirming = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: _handleTap,
      child: Text(
        _confirming ? 'Confirm?' : 'Clear',
        style: TextStyle(
          color: _confirming ? theme.colorScheme.error : null,
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
jj describe -m "feat(queue): add ClearQueueButton with double-tap confirmation"
```

---

### Task 15: Create Queue Screen

**Files:**
- Create: `packages/audiflow_app/lib/features/queue/presentation/screens/queue_screen.dart`

**Step 1: Create the screen**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../player/services/now_playing_controller.dart';
import '../controllers/queue_controller.dart';
import '../widgets/clear_queue_button.dart';
import '../widgets/now_playing_card.dart';
import '../widgets/queue_list_tile.dart';

/// Screen displaying the playback queue.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueControllerProvider);
    final nowPlaying = ref.watch(nowPlayingControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        actions: [
          queueAsync.whenOrNull(
            data: (queue) => queue.hasItems
                ? ClearQueueButton(
                    onClear: () => ref
                        .read(queueControllerProvider.notifier)
                        .clearQueue(),
                  )
                : null,
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: queueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (queue) => _buildQueueContent(context, ref, queue, nowPlaying),
      ),
    );
  }

  Widget _buildQueueContent(
    BuildContext context,
    WidgetRef ref,
    PlaybackQueue queue,
    NowPlayingInfo? nowPlaying,
  ) {
    final theme = Theme.of(context);
    final hasNowPlaying = nowPlaying != null;
    final hasItems = queue.hasItems;

    if (!hasNowPlaying && !hasItems) {
      return _buildEmptyState(context);
    }

    return CustomScrollView(
      slivers: [
        // Now Playing section
        if (hasNowPlaying && nowPlaying.episode != null)
          SliverToBoxAdapter(
            child: NowPlayingCard(episode: nowPlaying.episode!),
          ),

        // Up Next header
        if (hasItems)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'UP NEXT',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ),

        // Queue items (reorderable)
        if (hasItems)
          SliverReorderableList(
            itemCount: queue.allItems.length,
            itemBuilder: (context, index) {
              final item = queue.allItems[index];
              return ReorderableDragStartListener(
                key: Key('queue_item_${item.queueItem.id}'),
                index: index,
                child: QueueListTile(
                  item: item,
                  onTap: () => ref
                      .read(queueControllerProvider.notifier)
                      .skipToItem(item.queueItem.id),
                  onRemove: () => ref
                      .read(queueControllerProvider.notifier)
                      .removeItem(item.queueItem.id),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              if (newIndex < oldIndex) {
                // Adjust for removal
              }
              final item = queue.allItems[oldIndex];
              ref
                  .read(queueControllerProvider.notifier)
                  .reorderItem(item.queueItem.id, newIndex);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.queue_music,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Your queue is empty',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add episodes to build your listening queue',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Run codegen**

Run: `cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs`

**Step 3: Commit**

```bash
jj describe -m "feat(queue): add QueueScreen with reorderable list"
```

---

### Task 16: Add Queue Tab to Bottom Navigation

**Files:**
- Modify: `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart`
- Modify: `packages/audiflow_app/lib/routing/app_router.dart`

**Step 1: Add Queue destination to NavigationBar**

In `scaffold_with_nav_bar.dart`, add Queue destination (insert between Library and Settings):

```dart
NavigationDestination(
  icon: Icon(Symbols.queue_music),
  selectedIcon: Icon(Symbols.queue_music, fill: 1),
  label: 'Queue',
),
```

**Step 2: Add Queue branch to StatefulShellRoute**

In `app_router.dart`, add the queue branch to the StatefulShellRoute:

```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/queue',
      builder: (context, state) => const QueueScreen(),
    ),
  ],
),
```

**Step 3: Update imports**

Add import for QueueScreen:
```dart
import '../features/queue/presentation/screens/queue_screen.dart';
```

**Step 4: Commit**

```bash
jj describe -m "feat(queue): add Queue tab to bottom navigation"
```

---

## Phase 3: Integration

### Task 17: Create Add to Queue Button Widget

**Files:**
- Create: `packages/audiflow_ui/lib/src/widgets/queue/add_to_queue_button.dart`
- Modify: `packages/audiflow_ui/lib/audiflow_ui.dart`

**Step 1: Create the widget**

```dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Button to add episode to queue.
///
/// - Tap: Play Later (add to end)
/// - Long press: Play Next (add to front)
class AddToQueueButton extends StatelessWidget {
  const AddToQueueButton({
    required this.onPlayLater,
    required this.onPlayNext,
    this.iconSize = 24,
    super.key,
  });

  final VoidCallback onPlayLater;
  final VoidCallback onPlayNext;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onPlayNext();
      },
      child: IconButton(
        icon: Icon(Symbols.playlist_add, size: iconSize),
        tooltip: 'Add to queue (long press for Play Next)',
        onPressed: onPlayLater,
      ),
    );
  }
}
```

**Step 2: Export from audiflow_ui**

Add to `audiflow_ui.dart`:
```dart
export 'src/widgets/queue/add_to_queue_button.dart';
```

**Step 3: Add haptic import**

Add to widget file:
```dart
import 'package:flutter/services.dart';
```

**Step 4: Commit**

```bash
jj describe -m "feat(ui): add AddToQueueButton with long-press for Play Next"
```

---

### Task 18: Integrate Add to Queue in Episode List Tile

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart`

**Step 1: Add queue button to episode tile**

Add import:
```dart
import 'package:audiflow_ui/audiflow_ui.dart';
import '../../../queue/presentation/controllers/queue_controller.dart';
```

Add button to trailing row:
```dart
AddToQueueButton(
  onPlayLater: () {
    ref.read(queueControllerProvider.notifier).playLater(episode.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to queue'), duration: Duration(seconds: 1)),
    );
  },
  onPlayNext: () {
    ref.read(queueControllerProvider.notifier).playNext(episode.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Playing next'), duration: Duration(seconds: 1)),
    );
  },
),
```

**Step 2: Commit**

```bash
jj describe -m "feat(queue): add queue button to episode list tile"
```

---

### Task 19: Integrate Adhoc Queue with Episode Playback

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart`

**Step 1: Create adhoc queue dialog**

Add method to show confirmation:
```dart
Future<bool> _showReplaceQueueDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Replace queue?'),
      content: const Text(
        'Starting playback will replace your current queue with episodes from this list.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Replace'),
        ),
      ],
    ),
  );
  return result ?? false;
}
```

**Step 2: Modify play button to create adhoc queue**

Wrap play action with adhoc queue logic:
```dart
Future<void> _handlePlay(BuildContext context, WidgetRef ref, Episode episode) async {
  final queueService = ref.read(queueServiceProvider);

  // Check if confirmation needed
  final shouldConfirm = await queueService.shouldConfirmAdhocReplace();

  if (shouldConfirm) {
    final confirmed = await _showReplaceQueueDialog(context);
    if (!confirmed) return;
  }

  // Create adhoc queue and start playback
  await queueService.createAdhocQueue(
    startingEpisodeId: episode.id,
    sourceContext: 'Episodes', // TODO: Get actual context from screen
  );

  // Start playback
  ref.read(audioPlayerControllerProvider.notifier).play(episode.audioUrl);
}
```

**Step 3: Commit**

```bash
jj describe -m "feat(queue): integrate adhoc queue creation with episode playback"
```

---

### Task 20: Integrate Auto-Play Next with Player

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/player/services/audio_player_controller.dart`

**Step 1: Add queue service dependency**

Add to constructor/provider:
```dart
final QueueService _queueService;
```

**Step 2: Handle playback completion**

In the playback state listener, when playback completes:
```dart
void _onPlaybackComplete() async {
  final nextEpisode = await _queueService.getNextAndRemoveCurrent();

  if (nextEpisode != null) {
    _logger.i('Auto-playing next episode: ${nextEpisode.title}');
    await play(nextEpisode.audioUrl);
    _nowPlayingController.setNowPlaying(
      NowPlayingInfo(
        episodeUrl: nextEpisode.audioUrl,
        episodeTitle: nextEpisode.title,
        podcastTitle: '', // TODO: Get podcast title
        artworkUrl: nextEpisode.imageUrl,
        episode: nextEpisode,
      ),
    );
  } else {
    _logger.i('Queue empty, stopping playback');
    _nowPlayingController.clear();
  }
}
```

**Step 3: Commit**

```bash
jj describe -m "feat(player): integrate auto-play next from queue"
```

---

## Phase 4: Testing

### Task 21: Write Queue Repository Tests

**Files:**
- Create: `packages/audiflow_domain/test/features/queue/repositories/queue_repository_impl_test.dart`

**Step 1: Create test file with basic tests**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// TODO: Generate mocks and implement tests for:
// - addToEnd adds item with correct position
// - addToFront adds item with lower position
// - replaceWithAdhoc clears queue and adds adhoc items
// - replaceWithAdhoc respects max 100 limit
// - remove deletes correct item
// - reorder updates positions correctly
// - getQueue returns items in correct order (manual first)
// - hasManualItems returns true only when manual items exist

void main() {
  group('QueueRepositoryImpl', () {
    test('placeholder', () {
      // TODO: Implement tests
    });
  });
}
```

**Step 2: Commit**

```bash
jj describe -m "test(queue): add placeholder for queue repository tests"
```

---

### Task 22: Write Queue Service Tests

**Files:**
- Create: `packages/audiflow_domain/test/features/queue/services/queue_service_test.dart`

**Step 1: Create test file**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// TODO: Generate mocks and implement tests for:
// - playLater calls repository.addToEnd
// - playNext calls repository.addToFront
// - createAdhocQueue fetches subsequent episodes and replaces queue
// - getNextAndRemoveCurrent removes first and returns next
// - skipToItem removes preceding items

void main() {
  group('QueueService', () {
    test('placeholder', () {
      // TODO: Implement tests
    });
  });
}
```

**Step 2: Commit**

```bash
jj describe -m "test(queue): add placeholder for queue service tests"
```

---

### Task 23: Write Queue Screen Widget Tests

**Files:**
- Create: `packages/audiflow_app/test/features/queue/presentation/screens/queue_screen_test.dart`

**Step 1: Create test file**

```dart
import 'package:flutter_test/flutter_test.dart';

// TODO: Implement widget tests for:
// - Shows empty state when queue is empty
// - Shows Now Playing card when episode is playing
// - Shows queue items in correct order
// - Swipe to remove works
// - Clear button shows confirmation
// - Double-tap clear actually clears

void main() {
  group('QueueScreen', () {
    testWidgets('placeholder', (tester) async {
      // TODO: Implement tests
    });
  });
}
```

**Step 2: Commit**

```bash
jj describe -m "test(queue): add placeholder for queue screen tests"
```

---

## Phase 5: Final Integration

### Task 24: Run Full Build and Fix Issues

**Step 1: Run codegen for all packages**

Run: `melos run build_runner`

**Step 2: Run analyzer**

Run: `melos run analyze`
Fix any issues found.

**Step 3: Run tests**

Run: `melos run test`
Fix any failing tests.

**Step 4: Commit fixes**

```bash
jj describe -m "fix(queue): resolve build and lint issues"
```

---

### Task 25: Update NowPlayingInfo to Include Episode

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/player/models/now_playing_info.dart`

**Step 1: Add episode field to NowPlayingInfo**

```dart
@freezed
class NowPlayingInfo with _$NowPlayingInfo {
  const factory NowPlayingInfo({
    required String episodeUrl,
    required String episodeTitle,
    required String podcastTitle,
    String? artworkUrl,
    Episode? episode,  // Add this field
  }) = _NowPlayingInfo;
}
```

**Step 2: Run codegen**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

**Step 3: Commit**

```bash
jj describe -m "feat(player): add episode field to NowPlayingInfo"
```

---

### Task 26: Final Commit and Summary

**Step 1: Squash or organize commits**

Review commit history and organize if needed.

**Step 2: Create summary commit**

```bash
jj describe -m "feat(queue): complete play queue feature implementation

- Add QueueItems Drift table with migration v10
- Add PlaybackQueue freezed model
- Implement QueueRepository and QueueService
- Create QueueScreen with reorderable list
- Add Queue tab to bottom navigation
- Integrate Add to Queue button in episode tiles
- Implement adhoc queue from episode list playback
- Integrate auto-play next with AudioPlayerController
- Add placeholder tests for repository, service, and screen"
```

---

## File Summary

### New Files Created

**audiflow_domain:**
- `lib/src/features/queue/models/queue_item.dart`
- `lib/src/features/queue/models/playback_queue.dart`
- `lib/src/features/queue/datasources/local/queue_local_datasource.dart`
- `lib/src/features/queue/repositories/queue_repository.dart`
- `lib/src/features/queue/repositories/queue_repository_impl.dart`
- `lib/src/features/queue/services/queue_service.dart`
- `lib/src/features/queue/providers/queue_providers.dart`
- `test/features/queue/repositories/queue_repository_impl_test.dart`
- `test/features/queue/services/queue_service_test.dart`

**audiflow_app:**
- `lib/features/queue/presentation/controllers/queue_controller.dart`
- `lib/features/queue/presentation/screens/queue_screen.dart`
- `lib/features/queue/presentation/widgets/now_playing_card.dart`
- `lib/features/queue/presentation/widgets/queue_list_tile.dart`
- `lib/features/queue/presentation/widgets/clear_queue_button.dart`
- `test/features/queue/presentation/screens/queue_screen_test.dart`

**audiflow_ui:**
- `lib/src/widgets/queue/add_to_queue_button.dart`

### Files Modified

**audiflow_domain:**
- `lib/src/common/database/app_database.dart` (register table, migration)
- `lib/audiflow_domain.dart` (exports)
- `lib/src/features/feed/repositories/episode_repository.dart` (interface)
- `lib/src/features/feed/repositories/episode_repository_impl.dart` (impl)
- `lib/src/features/feed/datasources/local/episode_local_datasource.dart`
- `lib/src/features/player/services/audio_player_controller.dart`
- `lib/src/features/player/models/now_playing_info.dart`

**audiflow_app:**
- `lib/routing/scaffold_with_nav_bar.dart` (navigation)
- `lib/routing/app_router.dart` (routes)
- `lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart`

**audiflow_ui:**
- `lib/audiflow_ui.dart` (exports)
