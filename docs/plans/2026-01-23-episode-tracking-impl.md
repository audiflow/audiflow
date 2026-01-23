# Episode Tracking Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Track episode playback progress with auto-completion at 95%, manual toggle, and "Continue Listening" UI.

**Architecture:** Add Episodes and PlaybackHistories Drift tables, create repository/service layer for progress tracking, integrate with existing AudioPlayerController, and add UI components for progress display and filtering.

**Tech Stack:** Drift (SQLite), Riverpod with code generation, Freezed for immutable models, Flutter widgets.

---

## Task 1: Create Episodes Drift Table

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/episode.dart`
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart`

**Step 1: Create the Episodes table model**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/episode.dart
import 'package:drift/drift.dart';

import '../../../common/database/app_database.dart';

/// Drift table for podcast episodes.
///
/// Persisted when podcast feed is fetched. Upserted on feed refresh
/// using the composite unique key (podcastId, guid).
class Episodes extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to Subscriptions table.
  IntColumn get podcastId => integer().references(Subscriptions, #id)();

  /// Unique identifier from RSS feed (guid element).
  TextColumn get guid => text()();

  /// Episode title.
  TextColumn get title => text()();

  /// Episode description/show notes (nullable).
  TextColumn get description => text().nullable()();

  /// URL to the audio file.
  TextColumn get audioUrl => text()();

  /// Duration in milliseconds (nullable, may not be in feed).
  IntColumn get durationMs => integer().nullable()();

  /// Publication date (nullable).
  DateTimeColumn get publishedAt => dateTime().nullable()();

  /// Episode artwork URL (nullable, falls back to podcast artwork).
  TextColumn get imageUrl => text().nullable()();

  /// Episode number within season (nullable).
  IntColumn get episodeNumber => integer().nullable()();

  /// Season number (nullable).
  IntColumn get seasonNumber => integer().nullable()();

  /// Composite unique key for upsert matching.
  @override
  List<Set<Column>> get uniqueKeys => [
    {podcastId, guid},
  ];
}
```

**Step 2: Register Episodes table in AppDatabase**

Update `packages/audiflow_domain/lib/src/common/database/app_database.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/subscription/models/subscriptions.dart';
import '../../features/feed/models/episode.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Subscriptions, Episodes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(subscriptions);
      }
      if (from < 3) {
        await m.createTable(episodes);
      }
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'audiflow.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
```

**Step 3: Run code generation**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 4: Verify compilation**

```bash
cd packages/audiflow_domain && dart analyze
```

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/episode.dart packages/audiflow_domain/lib/src/common/database/app_database.dart packages/audiflow_domain/lib/src/common/database/app_database.g.dart
git commit -m "feat(domain): add Episodes Drift table"
```

---

## Task 2: Create PlaybackHistories Drift Table

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/player/models/playback_history.dart`
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart`

**Step 1: Create the PlaybackHistories table model**

```dart
// packages/audiflow_domain/lib/src/features/player/models/playback_history.dart
import 'package:drift/drift.dart';

import '../../feed/models/episode.dart';

/// Drift table for tracking episode playback progress.
///
/// Stores position, completion status, timestamps, and play count
/// for each episode the user has started listening to.
class PlaybackHistories extends Table {
  /// Foreign key to Episodes table (also serves as primary key).
  IntColumn get episodeId => integer().references(Episodes, #id)();

  /// Current playback position in milliseconds.
  IntColumn get positionMs => integer().withDefault(const Constant(0))();

  /// Episode duration in milliseconds (cached from playback).
  IntColumn get durationMs => integer().nullable()();

  /// When the episode was marked as completed (null = not completed).
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// When the user first started playing this episode.
  DateTimeColumn get firstPlayedAt => dateTime().nullable()();

  /// When the user last played this episode.
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();

  /// Number of times the episode was started from the beginning.
  IntColumn get playCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {episodeId};
}
```

**Step 2: Register PlaybackHistories table in AppDatabase**

Update `packages/audiflow_domain/lib/src/common/database/app_database.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/subscription/models/subscriptions.dart';
import '../../features/feed/models/episode.dart';
import '../../features/player/models/playback_history.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Subscriptions, Episodes, PlaybackHistories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(subscriptions);
      }
      if (from < 3) {
        await m.createTable(episodes);
      }
      if (from < 4) {
        await m.createTable(playbackHistories);
      }
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'audiflow.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
```

**Step 3: Run code generation**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 4: Verify compilation**

```bash
cd packages/audiflow_domain && dart analyze
```

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/models/playback_history.dart packages/audiflow_domain/lib/src/common/database/app_database.dart packages/audiflow_domain/lib/src/common/database/app_database.g.dart
git commit -m "feat(domain): add PlaybackHistories Drift table"
```

---

## Task 3: Create Episode Local Datasource

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/datasources/local/episode_local_datasource.dart`

**Step 1: Create the datasource**

```dart
// packages/audiflow_domain/lib/src/features/feed/datasources/local/episode_local_datasource.dart
import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';

/// Local datasource for episode operations using Drift.
///
/// Provides CRUD operations and upsert support for the Episodes table.
class EpisodeLocalDatasource {
  EpisodeLocalDatasource(this._db);

  final AppDatabase _db;

  /// Upserts an episode (insert or update on conflict).
  ///
  /// Matches on composite key (podcastId, guid). Returns the episode ID.
  Future<int> upsert(EpisodesCompanion companion) async {
    return _db.into(_db.episodes).insertOnConflictUpdate(companion);
  }

  /// Upserts multiple episodes in a batch.
  Future<void> upsertAll(List<EpisodesCompanion> companions) async {
    await _db.batch((batch) {
      for (final companion in companions) {
        batch.insert(
          _db.episodes,
          companion,
          onConflict: DoUpdate(
            (old) => companion,
            target: [_db.episodes.podcastId, _db.episodes.guid],
          ),
        );
      }
    });
  }

  /// Returns all episodes for a podcast, ordered by publish date (newest first).
  Future<List<Episode>> getByPodcastId(int podcastId) {
    return (_db.select(_db.episodes)
          ..where((e) => e.podcastId.equals(podcastId))
          ..orderBy([
            (e) => OrderingTerm(expression: e.publishedAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Watches episodes for a podcast, emitting updates when data changes.
  Stream<List<Episode>> watchByPodcastId(int podcastId) {
    return (_db.select(_db.episodes)
          ..where((e) => e.podcastId.equals(podcastId))
          ..orderBy([
            (e) => OrderingTerm(expression: e.publishedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Returns an episode by its ID.
  Future<Episode?> getById(int id) {
    return (_db.select(_db.episodes)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
  }

  /// Returns an episode by podcast ID and guid.
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) {
    return (_db.select(_db.episodes)
          ..where((e) => e.podcastId.equals(podcastId) & e.guid.equals(guid)))
        .getSingleOrNull();
  }

  /// Returns an episode by its audio URL.
  Future<Episode?> getByAudioUrl(String audioUrl) {
    return (_db.select(_db.episodes)..where((e) => e.audioUrl.equals(audioUrl)))
        .getSingleOrNull();
  }

  /// Deletes all episodes for a podcast.
  Future<int> deleteByPodcastId(int podcastId) {
    return (_db.delete(_db.episodes)
          ..where((e) => e.podcastId.equals(podcastId)))
        .go();
  }
}
```

**Step 2: Verify compilation**

```bash
cd packages/audiflow_domain && dart analyze
```

**Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/datasources/local/episode_local_datasource.dart
git commit -m "feat(domain): add EpisodeLocalDatasource"
```

---

## Task 4: Create PlaybackHistory Local Datasource

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/player/datasources/local/playback_history_local_datasource.dart`

**Step 1: Create the datasource**

```dart
// packages/audiflow_domain/lib/src/features/player/datasources/local/playback_history_local_datasource.dart
import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';

/// Local datasource for playback history operations using Drift.
///
/// Provides CRUD operations for tracking episode playback progress.
class PlaybackHistoryLocalDatasource {
  PlaybackHistoryLocalDatasource(this._db);

  final AppDatabase _db;

  /// Returns playback history for an episode, or null if not found.
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) {
    return (_db.select(_db.playbackHistories)
          ..where((h) => h.episodeId.equals(episodeId)))
        .getSingleOrNull();
  }

  /// Upserts playback history (insert or update on conflict).
  Future<void> upsert(PlaybackHistoriesCompanion companion) async {
    await _db.into(_db.playbackHistories).insertOnConflictUpdate(companion);
  }

  /// Updates playback position and lastPlayedAt timestamp.
  Future<void> updateProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
  }) async {
    final now = DateTime.now();
    final existing = await getByEpisodeId(episodeId);

    if (existing == null) {
      // First time playing - create new record
      await upsert(
        PlaybackHistoriesCompanion.insert(
          episodeId: episodeId,
          positionMs: Value(positionMs),
          durationMs: Value(durationMs),
          firstPlayedAt: Value(now),
          lastPlayedAt: Value(now),
          playCount: const Value(1),
        ),
      );
    } else {
      // Update existing record
      await (_db.update(_db.playbackHistories)
            ..where((h) => h.episodeId.equals(episodeId)))
          .write(
        PlaybackHistoriesCompanion(
          positionMs: Value(positionMs),
          durationMs: durationMs != null ? Value(durationMs) : const Value.absent(),
          lastPlayedAt: Value(now),
        ),
      );
    }
  }

  /// Marks an episode as completed.
  Future<void> markCompleted(int episodeId) async {
    final now = DateTime.now();
    final existing = await getByEpisodeId(episodeId);

    if (existing == null) {
      await upsert(
        PlaybackHistoriesCompanion.insert(
          episodeId: episodeId,
          completedAt: Value(now),
          lastPlayedAt: Value(now),
        ),
      );
    } else {
      await (_db.update(_db.playbackHistories)
            ..where((h) => h.episodeId.equals(episodeId)))
          .write(
        PlaybackHistoriesCompanion(
          completedAt: Value(now),
          lastPlayedAt: Value(now),
        ),
      );
    }
  }

  /// Marks an episode as incomplete (removes completedAt).
  Future<void> markIncomplete(int episodeId) async {
    await (_db.update(_db.playbackHistories)
          ..where((h) => h.episodeId.equals(episodeId)))
        .write(
      const PlaybackHistoriesCompanion(completedAt: Value(null)),
    );
  }

  /// Increments play count (called when starting from beginning).
  Future<void> incrementPlayCount(int episodeId) async {
    final existing = await getByEpisodeId(episodeId);
    if (existing != null) {
      await (_db.update(_db.playbackHistories)
            ..where((h) => h.episodeId.equals(episodeId)))
          .write(
        PlaybackHistoriesCompanion(
          playCount: Value(existing.playCount + 1),
        ),
      );
    }
  }

  /// Returns episodes that are in progress (started but not completed).
  ///
  /// Ordered by lastPlayedAt descending, limited to [limit] items.
  Future<List<PlaybackHistory>> getInProgress({int limit = 10}) {
    return (_db.select(_db.playbackHistories)
          ..where(
            (h) => h.positionMs.isBiggerThanValue(0) & h.completedAt.isNull(),
          )
          ..orderBy([
            (h) => OrderingTerm(expression: h.lastPlayedAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  /// Watches episodes that are in progress.
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10}) {
    return (_db.select(_db.playbackHistories)
          ..where(
            (h) => h.positionMs.isBiggerThanValue(0) & h.completedAt.isNull(),
          )
          ..orderBy([
            (h) => OrderingTerm(expression: h.lastPlayedAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  /// Returns true if the episode is completed.
  Future<bool> isCompleted(int episodeId) async {
    final history = await getByEpisodeId(episodeId);
    return history?.completedAt != null;
  }
}
```

**Step 2: Verify compilation**

```bash
cd packages/audiflow_domain && dart analyze
```

**Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/datasources/local/playback_history_local_datasource.dart
git commit -m "feat(domain): add PlaybackHistoryLocalDatasource"
```

---

## Task 5: Create PlaybackHistory Repository

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/player/repositories/playback_history_repository.dart`
- Create: `packages/audiflow_domain/lib/src/features/player/repositories/playback_history_repository_impl.dart`

**Step 1: Create the repository interface**

```dart
// packages/audiflow_domain/lib/src/features/player/repositories/playback_history_repository.dart
import '../../../../common/database/app_database.dart';

/// Repository interface for playback history operations.
abstract class PlaybackHistoryRepository {
  /// Returns playback history for an episode, or null if not found.
  Future<PlaybackHistory?> getByEpisodeId(int episodeId);

  /// Saves playback progress for an episode.
  Future<void> saveProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
  });

  /// Marks an episode as completed.
  Future<void> markCompleted(int episodeId);

  /// Marks an episode as incomplete.
  Future<void> markIncomplete(int episodeId);

  /// Increments play count when starting from beginning.
  Future<void> incrementPlayCount(int episodeId);

  /// Returns true if the episode is completed.
  Future<bool> isCompleted(int episodeId);

  /// Returns the progress percentage (0.0 to 1.0) for an episode.
  Future<double?> getProgressPercent(int episodeId);

  /// Watches episodes that are in progress (for "Continue Listening").
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10});
}
```

**Step 2: Create the repository implementation**

```dart
// packages/audiflow_domain/lib/src/features/player/repositories/playback_history_repository_impl.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../common/database/app_database.dart';
import '../../../../common/providers/database_provider.dart';
import '../datasources/local/playback_history_local_datasource.dart';
import 'playback_history_repository.dart';

part 'playback_history_repository_impl.g.dart';

/// Provides the PlaybackHistoryLocalDatasource.
@riverpod
PlaybackHistoryLocalDatasource playbackHistoryLocalDatasource(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return PlaybackHistoryLocalDatasource(db);
}

/// Provides the PlaybackHistoryRepository implementation.
@riverpod
PlaybackHistoryRepository playbackHistoryRepository(Ref ref) {
  final datasource = ref.watch(playbackHistoryLocalDatasourceProvider);
  return PlaybackHistoryRepositoryImpl(datasource);
}

/// Implementation of [PlaybackHistoryRepository].
class PlaybackHistoryRepositoryImpl implements PlaybackHistoryRepository {
  PlaybackHistoryRepositoryImpl(this._datasource);

  final PlaybackHistoryLocalDatasource _datasource;

  @override
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) {
    return _datasource.getByEpisodeId(episodeId);
  }

  @override
  Future<void> saveProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
  }) {
    return _datasource.updateProgress(
      episodeId: episodeId,
      positionMs: positionMs,
      durationMs: durationMs,
    );
  }

  @override
  Future<void> markCompleted(int episodeId) {
    return _datasource.markCompleted(episodeId);
  }

  @override
  Future<void> markIncomplete(int episodeId) {
    return _datasource.markIncomplete(episodeId);
  }

  @override
  Future<void> incrementPlayCount(int episodeId) {
    return _datasource.incrementPlayCount(episodeId);
  }

  @override
  Future<bool> isCompleted(int episodeId) {
    return _datasource.isCompleted(episodeId);
  }

  @override
  Future<double?> getProgressPercent(int episodeId) async {
    final history = await _datasource.getByEpisodeId(episodeId);
    if (history == null) return null;
    if (history.durationMs == null || history.durationMs == 0) return null;
    return history.positionMs / history.durationMs!;
  }

  @override
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10}) {
    return _datasource.watchInProgress(limit: limit);
  }
}
```

**Step 3: Run code generation**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 4: Verify compilation**

```bash
cd packages/audiflow_domain && dart analyze
```

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/repositories/playback_history_repository.dart packages/audiflow_domain/lib/src/features/player/repositories/playback_history_repository_impl.dart packages/audiflow_domain/lib/src/features/player/repositories/playback_history_repository_impl.g.dart
git commit -m "feat(domain): add PlaybackHistoryRepository"
```

---

## Task 6: Create PlaybackHistoryService

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/player/services/playback_history_service.dart`

**Step 1: Create the service**

```dart
// packages/audiflow_domain/lib/src/features/player/services/playback_history_service.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/playback_progress.dart';
import '../repositories/playback_history_repository.dart';
import '../repositories/playback_history_repository_impl.dart';

part 'playback_history_service.g.dart';

/// Provides the PlaybackHistoryService.
@Riverpod(keepAlive: true)
PlaybackHistoryService playbackHistoryService(Ref ref) {
  final repository = ref.watch(playbackHistoryRepositoryProvider);
  return PlaybackHistoryService(repository);
}

/// Service for managing playback history with auto-completion logic.
///
/// Handles progress saving throttling and automatic completion detection.
class PlaybackHistoryService {
  PlaybackHistoryService(this._repository);

  final PlaybackHistoryRepository _repository;

  /// Threshold at which an episode is considered "completed" (95%).
  static const double completionThreshold = 0.95;

  /// Minimum interval between progress saves (15 seconds).
  static const int saveIntervalMs = 15000;

  /// Position threshold for considering playback "from beginning" (5 seconds).
  static const int fromBeginningThresholdMs = 5000;

  int _lastSavedPositionMs = 0;
  int? _currentEpisodeId;

  /// Called when playback starts for an episode.
  ///
  /// Increments play count if starting from the beginning.
  Future<void> onPlaybackStarted(int episodeId, int positionMs) async {
    _currentEpisodeId = episodeId;
    _lastSavedPositionMs = positionMs;

    // Increment play count if starting from beginning
    if (positionMs < fromBeginningThresholdMs) {
      await _repository.incrementPlayCount(episodeId);
    }
  }

  /// Called on each progress update during playback.
  ///
  /// Throttles saves to every 15 seconds. Auto-marks as completed
  /// when progress reaches 95%.
  Future<void> onProgressUpdate(int episodeId, PlaybackProgress progress) async {
    final positionMs = progress.position.inMilliseconds;
    final durationMs = progress.duration.inMilliseconds;

    // Throttle saves to every 15 seconds
    final delta = (positionMs - _lastSavedPositionMs).abs();
    if (delta < saveIntervalMs) return;

    _lastSavedPositionMs = positionMs;

    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: positionMs,
      durationMs: durationMs,
    );

    // Auto-complete check
    if (0 < durationMs) {
      final progressPercent = positionMs / durationMs;
      if (completionThreshold <= progressPercent) {
        final isAlreadyCompleted = await _repository.isCompleted(episodeId);
        if (!isAlreadyCompleted) {
          await _repository.markCompleted(episodeId);
        }
      }
    }
  }

  /// Called when playback is paused.
  ///
  /// Forces an immediate save regardless of throttle interval.
  Future<void> onPlaybackPaused(int episodeId, PlaybackProgress progress) async {
    _lastSavedPositionMs = progress.position.inMilliseconds;

    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: progress.position.inMilliseconds,
      durationMs: progress.duration.inMilliseconds,
    );
  }

  /// Called when playback stops or switches to a different episode.
  ///
  /// Forces final save and resets tracking state.
  Future<void> onPlaybackStopped(int episodeId, PlaybackProgress progress) async {
    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: progress.position.inMilliseconds,
      durationMs: progress.duration.inMilliseconds,
    );

    _currentEpisodeId = null;
    _lastSavedPositionMs = 0;
  }

  /// Manually marks an episode as completed.
  Future<void> markCompleted(int episodeId) {
    return _repository.markCompleted(episodeId);
  }

  /// Manually marks an episode as incomplete.
  Future<void> markIncomplete(int episodeId) {
    return _repository.markIncomplete(episodeId);
  }

  /// Resets tracking state (e.g., when app goes to background).
  void reset() {
    _currentEpisodeId = null;
    _lastSavedPositionMs = 0;
  }
}
```

**Step 2: Run code generation**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 3: Verify compilation**

```bash
cd packages/audiflow_domain && dart analyze
```

**Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/services/playback_history_service.dart packages/audiflow_domain/lib/src/features/player/services/playback_history_service.g.dart
git commit -m "feat(domain): add PlaybackHistoryService with auto-completion"
```

---

## Task 7: Create Episode Repository

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository_impl.dart`

**Step 1: Create the repository interface**

```dart
// packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository.dart
import '../../../../common/database/app_database.dart';

/// Repository interface for episode operations.
abstract class EpisodeRepository {
  /// Returns all episodes for a podcast.
  Future<List<Episode>> getByPodcastId(int podcastId);

  /// Watches episodes for a podcast.
  Stream<List<Episode>> watchByPodcastId(int podcastId);

  /// Returns an episode by its ID.
  Future<Episode?> getById(int id);

  /// Returns an episode by its audio URL.
  Future<Episode?> getByAudioUrl(String audioUrl);

  /// Upserts episodes for a podcast (from RSS feed).
  Future<void> upsertEpisodes(int podcastId, List<EpisodesCompanion> episodes);
}
```

**Step 2: Create the repository implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository_impl.dart
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../common/database/app_database.dart';
import '../../../../common/providers/database_provider.dart';
import '../datasources/local/episode_local_datasource.dart';
import 'episode_repository.dart';

part 'episode_repository_impl.g.dart';

/// Provides the EpisodeLocalDatasource.
@riverpod
EpisodeLocalDatasource episodeLocalDatasource(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return EpisodeLocalDatasource(db);
}

/// Provides the EpisodeRepository implementation.
@riverpod
EpisodeRepository episodeRepository(Ref ref) {
  final datasource = ref.watch(episodeLocalDatasourceProvider);
  return EpisodeRepositoryImpl(datasource);
}

/// Implementation of [EpisodeRepository].
class EpisodeRepositoryImpl implements EpisodeRepository {
  EpisodeRepositoryImpl(this._datasource);

  final EpisodeLocalDatasource _datasource;

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) {
    return _datasource.getByPodcastId(podcastId);
  }

  @override
  Stream<List<Episode>> watchByPodcastId(int podcastId) {
    return _datasource.watchByPodcastId(podcastId);
  }

  @override
  Future<Episode?> getById(int id) {
    return _datasource.getById(id);
  }

  @override
  Future<Episode?> getByAudioUrl(String audioUrl) {
    return _datasource.getByAudioUrl(audioUrl);
  }

  @override
  Future<void> upsertEpisodes(int podcastId, List<EpisodesCompanion> episodes) {
    return _datasource.upsertAll(episodes);
  }
}
```

**Step 3: Run code generation**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 4: Verify compilation**

```bash
cd packages/audiflow_domain && dart analyze
```

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository.dart packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository_impl.dart packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository_impl.g.dart
git commit -m "feat(domain): add EpisodeRepository"
```

---

## Task 8: Update Domain Package Exports

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

**Step 1: Add new exports**

Add the following exports to `packages/audiflow_domain/lib/audiflow_domain.dart`:

```dart
// Feed feature - Episodes
export 'src/features/feed/models/episode.dart';
export 'src/features/feed/datasources/local/episode_local_datasource.dart';
export 'src/features/feed/repositories/episode_repository.dart';
export 'src/features/feed/repositories/episode_repository_impl.dart';

// Player feature - Playback History
export 'src/features/player/models/playback_history.dart';
export 'src/features/player/datasources/local/playback_history_local_datasource.dart';
export 'src/features/player/repositories/playback_history_repository.dart';
export 'src/features/player/repositories/playback_history_repository_impl.dart';
export 'src/features/player/services/playback_history_service.dart';
```

**Step 2: Verify compilation**

```bash
cd packages/audiflow_domain && dart analyze
```

**Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "chore(domain): export episode tracking types"
```

---

## Task 9: Create EpisodeWithProgress Model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/player/models/episode_with_progress.dart`

**Step 1: Create the model**

```dart
// packages/audiflow_domain/lib/src/features/player/models/episode_with_progress.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../common/database/app_database.dart';

part 'episode_with_progress.freezed.dart';

/// Episode combined with its playback progress.
///
/// Used for displaying episodes with progress indicators.
@freezed
sealed class EpisodeWithProgress with _$EpisodeWithProgress {
  const EpisodeWithProgress._();

  const factory EpisodeWithProgress({
    required Episode episode,
    PlaybackHistory? history,
  }) = _EpisodeWithProgress;

  /// Returns true if episode has been completed.
  bool get isCompleted => history?.completedAt != null;

  /// Returns true if episode is in progress (started but not completed).
  bool get isInProgress =>
      history != null &&
      0 < history!.positionMs &&
      history!.completedAt == null;

  /// Returns the progress percentage (0.0 to 1.0).
  double? get progressPercent {
    if (history == null) return null;
    final duration = history!.durationMs;
    if (duration == null || duration == 0) return null;
    return history!.positionMs / duration;
  }

  /// Returns the remaining duration in milliseconds.
  int? get remainingMs {
    if (history == null) return null;
    final duration = history!.durationMs;
    if (duration == null) return null;
    return duration - history!.positionMs;
  }

  /// Returns formatted remaining time (e.g., "18 min left").
  String? get remainingTimeFormatted {
    final remaining = remainingMs;
    if (remaining == null) return null;

    final minutes = (remaining / 60000).round();
    if (60 <= minutes) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins == 0 ? '$hours hr left' : '$hours hr $mins min left';
    }
    return '$minutes min left';
  }
}
```

**Step 2: Run code generation**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 3: Add export to audiflow_domain.dart**

```dart
export 'src/features/player/models/episode_with_progress.dart';
```

**Step 4: Verify compilation**

```bash
cd packages/audiflow_domain && dart analyze
```

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/models/episode_with_progress.dart packages/audiflow_domain/lib/src/features/player/models/episode_with_progress.freezed.dart packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add EpisodeWithProgress model"
```

---

## Task 10: Create Continue Listening Controller

**Files:**
- Create: `packages/audiflow_app/lib/features/library/presentation/controllers/continue_listening_controller.dart`

**Step 1: Create the controller**

```dart
// packages/audiflow_app/lib/features/library/presentation/controllers/continue_listening_controller.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'continue_listening_controller.g.dart';

/// Provides the list of episodes in progress with their details.
///
/// Combines PlaybackHistory with Episode data for display.
@riverpod
Stream<List<EpisodeWithProgress>> continueListeningEpisodes(Ref ref) async* {
  final historyRepo = ref.watch(playbackHistoryRepositoryProvider);
  final episodeRepo = ref.watch(episodeRepositoryProvider);

  await for (final histories in historyRepo.watchInProgress(limit: 10)) {
    final episodes = <EpisodeWithProgress>[];

    for (final history in histories) {
      final episode = await episodeRepo.getById(history.episodeId);
      if (episode != null) {
        episodes.add(EpisodeWithProgress(episode: episode, history: history));
      }
    }

    yield episodes;
  }
}
```

**Step 2: Run code generation**

```bash
cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs
```

**Step 3: Verify compilation**

```bash
cd packages/audiflow_app && dart analyze
```

**Step 4: Commit**

```bash
git add packages/audiflow_app/lib/features/library/presentation/controllers/continue_listening_controller.dart packages/audiflow_app/lib/features/library/presentation/controllers/continue_listening_controller.g.dart
git commit -m "feat(app): add ContinueListeningController"
```

---

## Task 11: Create Continue Listening UI Widget

**Files:**
- Create: `packages/audiflow_app/lib/features/library/presentation/widgets/continue_listening_section.dart`

**Step 1: Create the widget**

```dart
// packages/audiflow_app/lib/features/library/presentation/widgets/continue_listening_section.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/continue_listening_controller.dart';

/// Horizontal scrolling section showing episodes in progress.
///
/// Hidden when there are no in-progress episodes.
class ContinueListeningSection extends ConsumerWidget {
  const ContinueListeningSection({
    super.key,
    this.onEpisodeTap,
  });

  final void Function(EpisodeWithProgress episode)? onEpisodeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(continueListeningEpisodesProvider);

    return episodesAsync.when(
      data: (episodes) {
        if (episodes.isEmpty) return const SizedBox.shrink();
        return _buildSection(context, episodes);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSection(BuildContext context, List<EpisodeWithProgress> episodes) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.md,
            Spacing.md,
            Spacing.sm,
          ),
          child: Text(
            'Continue Listening',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            itemCount: episodes.length,
            separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
            itemBuilder: (context, index) {
              final episode = episodes[index];
              return _ContinueListeningCard(
                episode: episode,
                onTap: () => onEpisodeTap?.call(episode),
              );
            },
          ),
        ),
        const SizedBox(height: Spacing.md),
        const Divider(height: 1),
      ],
    );
  }
}

class _ContinueListeningCard extends StatelessWidget {
  const _ContinueListeningCard({
    required this.episode,
    this.onTap,
  });

  final EpisodeWithProgress episode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 100,
                height: 100,
                child: episode.episode.imageUrl != null
                    ? ExtendedImage.network(
                        episode.episode.imageUrl!,
                        fit: BoxFit.cover,
                        cache: true,
                        loadStateChanged: (state) {
                          if (state.extendedImageLoadState == LoadState.failed) {
                            return _buildPlaceholder(colorScheme);
                          }
                          return null;
                        },
                      )
                    : _buildPlaceholder(colorScheme),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            // Title
            Text(
              episode.episode.title,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Remaining time
            if (episode.remainingTimeFormatted != null)
              Text(
                episode.remainingTimeFormatted!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.podcasts,
        size: 40,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
```

**Step 2: Verify compilation**

```bash
cd packages/audiflow_app && dart analyze
```

**Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/library/presentation/widgets/continue_listening_section.dart
git commit -m "feat(app): add ContinueListeningSection widget"
```

---

## Task 12: Integrate Continue Listening into Library Screen

**Files:**
- Modify: `packages/audiflow_app/lib/features/library/presentation/screens/library_screen.dart`

**Step 1: Update LibraryScreen**

Update `_buildContent` to include ContinueListeningSection:

```dart
import '../widgets/continue_listening_section.dart';

// In _buildContent method, replace ListView.builder with:
Widget _buildContent(BuildContext context, WidgetRef ref, List subscriptions) {
  if (subscriptions.isEmpty) {
    return _buildEmptyState(context);
  }

  return CustomScrollView(
    slivers: [
      // Continue Listening section (non-sliver, wrapped)
      SliverToBoxAdapter(
        child: ContinueListeningSection(
          onEpisodeTap: (episode) => _onContinueListeningTap(context, ref, episode),
        ),
      ),
      // Section header
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.md,
            Spacing.md,
            Spacing.sm,
          ),
          child: Text(
            'Your Podcasts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // Subscription list
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final subscription = subscriptions[index];
            return SubscriptionListTile(
              key: ValueKey(subscription.itunesId),
              subscription: subscription,
              onTap: () {
                final podcast = subscription.toPodcast();
                context.push(
                  '${AppRoutes.library}/podcast/${podcast.id}',
                  extra: podcast,
                );
              },
            );
          },
          childCount: subscriptions.length,
        ),
      ),
    ],
  );
}

void _onContinueListeningTap(
  BuildContext context,
  WidgetRef ref,
  EpisodeWithProgress episode,
) {
  // Start playback from saved position
  final controller = ref.read(audioPlayerControllerProvider.notifier);
  final audioUrl = episode.episode.audioUrl;
  final position = Duration(milliseconds: episode.history?.positionMs ?? 0);

  controller.play(
    audioUrl,
    metadata: NowPlayingInfo(
      episodeUrl: audioUrl,
      episodeTitle: episode.episode.title,
      podcastTitle: '', // TODO: Get from subscription
      artworkUrl: episode.episode.imageUrl,
      totalDuration: episode.episode.durationMs != null
          ? Duration(milliseconds: episode.episode.durationMs!)
          : null,
    ),
  );

  // Seek to saved position after playback starts
  Future.delayed(const Duration(milliseconds: 500), () {
    controller.seek(position);
  });
}
```

Note: This is a partial implementation. The full integration requires updating the build method signature to pass `ref` to `_buildContent`. Review the existing code structure and adapt accordingly.

**Step 2: Verify compilation**

```bash
cd packages/audiflow_app && dart analyze
```

**Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/library/presentation/screens/library_screen.dart
git commit -m "feat(app): integrate ContinueListeningSection into LibraryScreen"
```

---

## Task 13: Create Episode Progress Indicator Widget

**Files:**
- Create: `packages/audiflow_ui/lib/src/widgets/indicators/episode_progress_indicator.dart`

**Step 1: Create the widget**

```dart
// packages/audiflow_ui/lib/src/widgets/indicators/episode_progress_indicator.dart
import 'package:flutter/material.dart';

/// Displays episode progress state: unplayed, in-progress, or completed.
///
/// Shows "X min left" for in-progress, checkmark for completed,
/// and nothing for unplayed episodes.
class EpisodeProgressIndicator extends StatelessWidget {
  const EpisodeProgressIndicator({
    super.key,
    required this.isCompleted,
    required this.isInProgress,
    this.remainingTimeFormatted,
  });

  final bool isCompleted;
  final bool isInProgress;
  final String? remainingTimeFormatted;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return _buildCompleted(context);
    }
    if (isInProgress && remainingTimeFormatted != null) {
      return _buildInProgress(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildCompleted(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle,
          size: 16,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          'Played',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInProgress(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      remainingTimeFormatted!,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: colorScheme.tertiary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
```

**Step 2: Export from audiflow_ui**

Add to `packages/audiflow_ui/lib/audiflow_ui.dart`:

```dart
export 'src/widgets/indicators/episode_progress_indicator.dart';
```

**Step 3: Verify compilation**

```bash
cd packages/audiflow_ui && dart analyze
```

**Step 4: Commit**

```bash
git add packages/audiflow_ui/lib/src/widgets/indicators/episode_progress_indicator.dart packages/audiflow_ui/lib/audiflow_ui.dart
git commit -m "feat(ui): add EpisodeProgressIndicator widget"
```

---

## Task 14: Create Episode Filter Chips Widget

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_filter_chips.dart`

**Step 1: Create the filter enum and widget**

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_filter_chips.dart
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Filter options for episode list.
enum EpisodeFilter {
  all('All'),
  unplayed('Unplayed'),
  inProgress('In Progress');

  const EpisodeFilter(this.label);
  final String label;
}

/// Chip row for filtering episodes by playback status.
class EpisodeFilterChips extends StatelessWidget {
  const EpisodeFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final EpisodeFilter selected;
  final ValueChanged<EpisodeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: EpisodeFilter.values.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: Spacing.xs),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

**Step 2: Verify compilation**

```bash
cd packages/audiflow_app && dart analyze
```

**Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_filter_chips.dart
git commit -m "feat(app): add EpisodeFilterChips widget"
```

---

## Task 15: Write Unit Tests for PlaybackHistoryService

**Files:**
- Create: `packages/audiflow_domain/test/features/player/services/playback_history_service_test.dart`

**Step 1: Create the test file**

```dart
// packages/audiflow_domain/test/features/player/services/playback_history_service_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([PlaybackHistoryRepository])
import 'playback_history_service_test.mocks.dart';

void main() {
  late MockPlaybackHistoryRepository mockRepository;
  late PlaybackHistoryService service;

  setUp(() {
    mockRepository = MockPlaybackHistoryRepository();
    service = PlaybackHistoryService(mockRepository);
  });

  group('onProgressUpdate', () {
    test('saves progress when interval exceeded', () async {
      const episodeId = 1;
      final progress = PlaybackProgress(
        position: const Duration(seconds: 20),
        duration: const Duration(minutes: 30),
        bufferedPosition: const Duration(seconds: 25),
      );

      when(mockRepository.saveProgress(
        episodeId: anyNamed('episodeId'),
        positionMs: anyNamed('positionMs'),
        durationMs: anyNamed('durationMs'),
      )).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);

      await service.onProgressUpdate(episodeId, progress);

      verify(mockRepository.saveProgress(
        episodeId: episodeId,
        positionMs: 20000,
        durationMs: 1800000,
      )).called(1);
    });

    test('does not save progress when interval not exceeded', () async {
      const episodeId = 1;
      final progress1 = PlaybackProgress(
        position: const Duration(seconds: 5),
        duration: const Duration(minutes: 30),
        bufferedPosition: const Duration(seconds: 10),
      );
      final progress2 = PlaybackProgress(
        position: const Duration(seconds: 10),
        duration: const Duration(minutes: 30),
        bufferedPosition: const Duration(seconds: 15),
      );

      when(mockRepository.saveProgress(
        episodeId: anyNamed('episodeId'),
        positionMs: anyNamed('positionMs'),
        durationMs: anyNamed('durationMs'),
      )).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);

      await service.onProgressUpdate(episodeId, progress1);
      await service.onProgressUpdate(episodeId, progress2);

      // Only first call should save (interval is 15 seconds)
      verify(mockRepository.saveProgress(
        episodeId: episodeId,
        positionMs: 5000,
        durationMs: 1800000,
      )).called(1);
    });

    test('marks as completed when threshold reached', () async {
      const episodeId = 1;
      final progress = PlaybackProgress(
        position: const Duration(seconds: 570), // 95% of 10 minutes
        duration: const Duration(minutes: 10),
        bufferedPosition: const Duration(minutes: 10),
      );

      when(mockRepository.saveProgress(
        episodeId: anyNamed('episodeId'),
        positionMs: anyNamed('positionMs'),
        durationMs: anyNamed('durationMs'),
      )).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);
      when(mockRepository.markCompleted(any)).thenAnswer((_) async {});

      await service.onProgressUpdate(episodeId, progress);

      verify(mockRepository.markCompleted(episodeId)).called(1);
    });

    test('does not mark completed if already completed', () async {
      const episodeId = 1;
      final progress = PlaybackProgress(
        position: const Duration(seconds: 570),
        duration: const Duration(minutes: 10),
        bufferedPosition: const Duration(minutes: 10),
      );

      when(mockRepository.saveProgress(
        episodeId: anyNamed('episodeId'),
        positionMs: anyNamed('positionMs'),
        durationMs: anyNamed('durationMs'),
      )).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => true);

      await service.onProgressUpdate(episodeId, progress);

      verifyNever(mockRepository.markCompleted(any));
    });
  });

  group('onPlaybackStarted', () {
    test('increments play count when starting from beginning', () async {
      const episodeId = 1;
      const positionMs = 1000; // 1 second (under threshold)

      when(mockRepository.incrementPlayCount(any)).thenAnswer((_) async {});

      await service.onPlaybackStarted(episodeId, positionMs);

      verify(mockRepository.incrementPlayCount(episodeId)).called(1);
    });

    test('does not increment play count when resuming', () async {
      const episodeId = 1;
      const positionMs = 60000; // 1 minute (over threshold)

      await service.onPlaybackStarted(episodeId, positionMs);

      verifyNever(mockRepository.incrementPlayCount(any));
    });
  });
}
```

**Step 2: Run code generation for mocks**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 3: Run tests**

```bash
cd packages/audiflow_domain && flutter test test/features/player/services/playback_history_service_test.dart
```

**Step 4: Commit**

```bash
git add packages/audiflow_domain/test/features/player/services/playback_history_service_test.dart packages/audiflow_domain/test/features/player/services/playback_history_service_test.mocks.dart
git commit -m "test(domain): add PlaybackHistoryService tests"
```

---

## Summary

This implementation plan covers:

1. **Data layer** (Tasks 1-4): Episodes and PlaybackHistories Drift tables with datasources
2. **Repository layer** (Tasks 5, 7): PlaybackHistoryRepository and EpisodeRepository
3. **Service layer** (Task 6): PlaybackHistoryService with auto-completion logic
4. **Domain exports** (Task 8): Updated package exports
5. **Models** (Task 9): EpisodeWithProgress for UI display
6. **Controllers** (Task 10): ContinueListeningController
7. **UI widgets** (Tasks 11, 13, 14): ContinueListeningSection, EpisodeProgressIndicator, EpisodeFilterChips
8. **Integration** (Task 12): Library screen with Continue Listening
9. **Tests** (Task 15): Unit tests for PlaybackHistoryService

**Not covered in this plan** (requires additional tasks):
- Integration with AudioPlayerController to call PlaybackHistoryService
- Persisting episodes on feed fetch
- Updating EpisodeListTile to show progress indicators
- Episode filter integration in podcast detail screen
- Manual mark played/unplayed UI (long-press menu)
