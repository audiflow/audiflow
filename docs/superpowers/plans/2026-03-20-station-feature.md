# Station Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add user-created podcast collections (Stations) with event-driven episode filtering to audiflow.

**Architecture:** Pure Local (Isar Only). Three new Isar collections (Station, StationPodcast, StationEpisode) with an event-driven reconciler that maintains a materialized view of filtered episodes. The Library tab is restructured with a Stations section and a collapsed Subscriptions group entry.

**Tech Stack:** Flutter, Isar, Riverpod (code-gen), go_router, freezed, checks (test assertions)

**Spec:** `docs/superpowers/specs/2026-03-20-station-design.md`

---

## File Structure

### audiflow_domain — `packages/audiflow_domain/lib/src/features/station/`

| File | Responsibility |
|------|---------------|
| `models/station.dart` | Station Isar collection with embedded filter fields |
| `models/station_duration_filter.dart` | Embedded duration filter object |
| `models/station_podcast.dart` | StationPodcast Isar collection (station-podcast join) |
| `models/station_episode.dart` | StationEpisode Isar collection (materialized view) |
| `models/station_playback_state.dart` | Enum for playback state filter (all/unplayed/inProgress) |
| `models/station_episode_sort.dart` | Enum for episode sort type (newest/oldest) |
| `datasources/local/station_local_datasource.dart` | Isar CRUD for Station |
| `datasources/local/station_podcast_local_datasource.dart` | Isar CRUD for StationPodcast |
| `datasources/local/station_episode_local_datasource.dart` | Isar CRUD for StationEpisode |
| `repositories/station_repository.dart` | Station repository interface |
| `repositories/station_repository_impl.dart` | Station repository implementation + Riverpod provider |
| `repositories/station_podcast_repository.dart` | StationPodcast repository interface |
| `repositories/station_podcast_repository_impl.dart` | StationPodcast repository implementation + provider |
| `repositories/station_episode_repository.dart` | StationEpisode repository interface |
| `repositories/station_episode_repository_impl.dart` | StationEpisode repository implementation + provider |
| `services/station_reconciler.dart` | Full + differential reconciliation logic |
| `services/station_reconciler_service.dart` | Riverpod service wiring reconciler to event streams |

### audiflow_domain — Episode model change

| File | Change |
|------|--------|
| `features/feed/models/episode.dart` | Add `isFavorited` bool + `favoritedAt` DateTime? fields |

### audiflow_app — `packages/audiflow_app/lib/features/station/`

| File | Responsibility |
|------|---------------|
| `presentation/screens/station_detail_screen.dart` | Filtered episode list for a station |
| `presentation/screens/station_edit_screen.dart` | Create/edit station (name, podcasts, filters, sort) |
| `presentation/controllers/station_list_controller.dart` | Riverpod controller for station list in Library |
| `presentation/controllers/station_detail_controller.dart` | Riverpod controller for station detail |
| `presentation/controllers/station_edit_controller.dart` | Riverpod controller for station edit form |
| `presentation/widgets/station_list_tile.dart` | Station row widget with artwork mosaic |

### audiflow_app — Library + routing changes

| File | Change |
|------|--------|
| `features/library/presentation/screens/library_screen.dart` | Restructure: add Stations section, collapse Subscriptions into group entry |
| `features/library/presentation/screens/subscriptions_list_screen.dart` | New: dedicated subscriptions list screen |
| `routing/app_router.dart` | Add station + subscriptions routes |

### audiflow_app — Isar registration

| File | Change |
|------|--------|
| `main.dart` | Register StationSchema, StationPodcastSchema, StationEpisodeSchema |

---

## Task 1: Episode Model — Add isFavorited Fields

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/episode.dart`
- Test: `packages/audiflow_domain/test/features/feed/models/episode_favorite_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/models/episode_favorite_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestIsar([EpisodeSchema]);
  });

  tearDown(() => isar.close());

  test('isFavorited defaults to false', () {
    final episode = Episode()
      ..podcastId = 1
      ..guid = 'ep-1'
      ..title = 'Test'
      ..audioUrl = 'https://example.com/ep.mp3';

    check(episode.isFavorited).isFalse();
    check(episode.favoritedAt).isNull();
  });

  test('isFavorited persists through Isar round-trip', () async {
    final episode = Episode()
      ..podcastId = 1
      ..guid = 'ep-1'
      ..title = 'Test'
      ..audioUrl = 'https://example.com/ep.mp3'
      ..isFavorited = true
      ..favoritedAt = DateTime(2026, 3, 20);

    await isar.writeTxn(() => isar.episodes.put(episode));

    final loaded = await isar.episodes.get(episode.id);
    check(loaded).isNotNull();
    check(loaded!.isFavorited).isTrue();
    check(loaded.favoritedAt).equals(DateTime(2026, 3, 20));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/episode_favorite_test.dart`
Expected: FAIL — `isFavorited` field does not exist

- [ ] **Step 3: Add fields to Episode model**

In `packages/audiflow_domain/lib/src/features/feed/models/episode.dart`, add after the last field:

```dart
  bool isFavorited = false;
  DateTime? favoritedAt;
```

- [ ] **Step 4: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/episode_favorite_test.dart`
Expected: PASS

- [ ] **Step 6: Run full test suite to check no regressions**

Run: `cd packages/audiflow_domain && flutter test`
Expected: All tests pass

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/episode.dart \
       packages/audiflow_domain/lib/src/features/feed/models/episode.g.dart \
       packages/audiflow_domain/test/features/feed/models/episode_favorite_test.dart
git commit -m "feat(domain): add isFavorited and favoritedAt to Episode model"
```

---

## Task 2: Station Isar Models

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/station/models/station_playback_state.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/models/station_episode_sort.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/models/station_duration_filter.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/models/station.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/models/station_podcast.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/models/station_episode.dart`
- Test: `packages/audiflow_domain/test/features/station/models/station_test.dart`
- Test: `packages/audiflow_domain/test/features/station/models/station_podcast_test.dart`
- Test: `packages/audiflow_domain/test/features/station/models/station_episode_test.dart`

- [ ] **Step 1: Create enum files**

```dart
// packages/audiflow_domain/lib/src/features/station/models/station_playback_state.dart

/// Playback state filter for a station (exclusive selection).
enum StationPlaybackState {
  all,
  unplayed,
  inProgress;

  static StationPlaybackState fromString(String value) => switch (value) {
    'unplayed' => StationPlaybackState.unplayed,
    'inProgress' => StationPlaybackState.inProgress,
    _ => StationPlaybackState.all,
  };
}
```

```dart
// packages/audiflow_domain/lib/src/features/station/models/station_episode_sort.dart

/// Sort order for episodes within a station.
enum StationEpisodeSort {
  newest,
  oldest;

  static StationEpisodeSort fromString(String value) => switch (value) {
    'oldest' => StationEpisodeSort.oldest,
    _ => StationEpisodeSort.newest,
  };
}
```

- [ ] **Step 2: Create StationDurationFilter embedded object**

```dart
// packages/audiflow_domain/lib/src/features/station/models/station_duration_filter.dart
import 'package:isar_community/isar.dart';

part 'station_duration_filter.g.dart';

@embedded
class StationDurationFilter {
  /// 'shorterThan' or 'longerThan'
  String durationOperator = 'shorterThan';

  int durationMinutes = 30;
}
```

- [ ] **Step 3: Create Station Isar collection**

```dart
// packages/audiflow_domain/lib/src/features/station/models/station.dart
import 'package:isar_community/isar.dart';

import 'station_duration_filter.dart';
import 'station_episode_sort.dart';
import 'station_playback_state.dart';

part 'station.g.dart';

@collection
class Station {
  Id id = Isar.autoIncrement;

  late String name;
  int sortOrder = 0;

  /// Stored as string, use [episodeSort] getter.
  String episodeSortType = 'newest';

  // -- Filter fields (flat for simple types) --

  /// Stored as string, use [playbackStateFilter] getter.
  String playbackState = 'all';

  bool filterDownloaded = false;
  bool filterFavorited = false;

  StationDurationFilter? durationFilter;

  /// Null means no publishedWithin filter.
  int? publishedWithinDays;

  late DateTime createdAt;
  late DateTime updatedAt;

  // -- Convenience getters (not persisted) --

  @ignore
  StationPlaybackState get playbackStateFilter =>
      StationPlaybackState.fromString(playbackState);

  @ignore
  set playbackStateFilter(StationPlaybackState value) =>
      playbackState = value.name;

  @ignore
  StationEpisodeSort get episodeSort =>
      StationEpisodeSort.fromString(episodeSortType);

  @ignore
  set episodeSort(StationEpisodeSort value) =>
      episodeSortType = value.name;
}
```

- [ ] **Step 4: Create StationPodcast Isar collection**

```dart
// packages/audiflow_domain/lib/src/features/station/models/station_podcast.dart
import 'package:isar_community/isar.dart';

part 'station_podcast.g.dart';

@collection
class StationPodcast {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('podcastId')], unique: true)
  late int stationId;

  late int podcastId;
  late DateTime addedAt;
}
```

- [ ] **Step 5: Create StationEpisode Isar collection**

```dart
// packages/audiflow_domain/lib/src/features/station/models/station_episode.dart
import 'package:isar_community/isar.dart';

part 'station_episode.g.dart';

@collection
class StationEpisode {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('episodeId')], unique: true)
  late int stationId;

  late int episodeId;

  /// Copy of Episode.publishedAt for Isar-native sort + pagination.
  DateTime? sortKey;
}
```

- [ ] **Step 6: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 7: Write model tests**

```dart
// packages/audiflow_domain/test/features/station/models/station_test.dart
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:audiflow_domain/src/features/station/models/station.dart';
import 'package:audiflow_domain/src/features/station/models/station_duration_filter.dart';
import 'package:audiflow_domain/src/features/station/models/station_playback_state.dart';
import 'package:audiflow_domain/src/features/station/models/station_episode_sort.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestIsar([StationSchema]);
  });

  tearDown(() => isar.close());

  test('Station persists with default filter values', () async {
    final station = Station()
      ..name = 'News'
      ..createdAt = DateTime(2026, 3, 20)
      ..updatedAt = DateTime(2026, 3, 20);

    await isar.writeTxn(() => isar.stations.put(station));

    final loaded = await isar.stations.get(station.id);
    check(loaded).isNotNull();
    check(loaded!.name).equals('News');
    check(loaded.playbackStateFilter).equals(StationPlaybackState.all);
    check(loaded.episodeSort).equals(StationEpisodeSort.newest);
    check(loaded.filterDownloaded).isFalse();
    check(loaded.filterFavorited).isFalse();
    check(loaded.durationFilter).isNull();
    check(loaded.publishedWithinDays).isNull();
  });

  test('Station persists with all filters configured', () async {
    final duration = StationDurationFilter()
      ..durationOperator = 'shorterThan'
      ..durationMinutes = 15;

    final station = Station()
      ..name = 'Commute'
      ..sortOrder = 1
      ..episodeSortType = 'oldest'
      ..playbackState = 'unplayed'
      ..filterDownloaded = true
      ..filterFavorited = true
      ..durationFilter = duration
      ..publishedWithinDays = 7
      ..createdAt = DateTime(2026, 3, 20)
      ..updatedAt = DateTime(2026, 3, 20);

    await isar.writeTxn(() => isar.stations.put(station));

    final loaded = await isar.stations.get(station.id);
    check(loaded).isNotNull();
    check(loaded!.playbackStateFilter).equals(StationPlaybackState.unplayed);
    check(loaded.episodeSort).equals(StationEpisodeSort.oldest);
    check(loaded.filterDownloaded).isTrue();
    check(loaded.filterFavorited).isTrue();
    check(loaded.durationFilter).isNotNull();
    check(loaded.durationFilter!.durationOperator).equals('shorterThan');
    check(loaded.durationFilter!.durationMinutes).equals(15);
    check(loaded.publishedWithinDays).equals(7);
  });
}
```

```dart
// packages/audiflow_domain/test/features/station/models/station_podcast_test.dart
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:audiflow_domain/src/features/station/models/station_podcast.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestIsar([StationPodcastSchema]);
  });

  tearDown(() => isar.close());

  test('StationPodcast persists and enforces composite unique index', () async {
    final sp = StationPodcast()
      ..stationId = 1
      ..podcastId = 42
      ..addedAt = DateTime(2026, 3, 20);

    await isar.writeTxn(() => isar.stationPodcasts.put(sp));

    final loaded = await isar.stationPodcasts.get(sp.id);
    check(loaded).isNotNull();
    check(loaded!.stationId).equals(1);
    check(loaded.podcastId).equals(42);

    // Duplicate (same stationId + podcastId) should overwrite via unique index
    final duplicate = StationPodcast()
      ..stationId = 1
      ..podcastId = 42
      ..addedAt = DateTime(2026, 3, 21);

    await isar.writeTxn(() => isar.stationPodcasts.put(duplicate));

    final count = await isar.stationPodcasts
        .filter()
        .stationIdEqualTo(1)
        .and()
        .podcastIdEqualTo(42)
        .count();
    check(count).equals(1);
  });
}
```

```dart
// packages/audiflow_domain/test/features/station/models/station_episode_test.dart
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:audiflow_domain/src/features/station/models/station_episode.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestIsar([StationEpisodeSchema]);
  });

  tearDown(() => isar.close());

  test('StationEpisode persists with sortKey', () async {
    final se = StationEpisode()
      ..stationId = 1
      ..episodeId = 100
      ..sortKey = DateTime(2026, 3, 20);

    await isar.writeTxn(() => isar.stationEpisodes.put(se));

    final loaded = await isar.stationEpisodes.get(se.id);
    check(loaded).isNotNull();
    check(loaded!.stationId).equals(1);
    check(loaded.episodeId).equals(100);
    check(loaded.sortKey).equals(DateTime(2026, 3, 20));
  });

  test('composite unique index prevents duplicate stationId+episodeId', () async {
    final se1 = StationEpisode()
      ..stationId = 1
      ..episodeId = 100
      ..sortKey = DateTime(2026, 3, 20);
    final se2 = StationEpisode()
      ..stationId = 1
      ..episodeId = 100
      ..sortKey = DateTime(2026, 3, 21);

    await isar.writeTxn(() => isar.stationEpisodes.put(se1));
    await isar.writeTxn(() => isar.stationEpisodes.put(se2));

    final count = await isar.stationEpisodes
        .filter()
        .stationIdEqualTo(1)
        .and()
        .episodeIdEqualTo(100)
        .count();
    check(count).equals(1);
  });
}
```

- [ ] **Step 8: Run tests**

Run: `cd packages/audiflow_domain && flutter test test/features/station/`
Expected: All pass

- [ ] **Step 9: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/station/
git add packages/audiflow_domain/test/features/station/
git commit -m "feat(domain): add Station, StationPodcast, StationEpisode Isar models"
```

---

## Task 3: Station Datasources

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/station/datasources/local/station_local_datasource.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/datasources/local/station_podcast_local_datasource.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/datasources/local/station_episode_local_datasource.dart`
- Test: `packages/audiflow_domain/test/features/station/datasources/local/station_local_datasource_test.dart`
- Test: `packages/audiflow_domain/test/features/station/datasources/local/station_podcast_local_datasource_test.dart`
- Test: `packages/audiflow_domain/test/features/station/datasources/local/station_episode_local_datasource_test.dart`

- [ ] **Step 1: Write failing tests for StationLocalDatasource**

Test CRUD operations: insert, getAll, getById, update, delete, watchAll, count, reorder. See the SubscriptionLocalDatasource pattern — constructor takes `Isar` instance, uses `writeTxn()` for mutations, filter queries for reads, `watch(fireImmediately: true)` for streams.

Key test cases:
- Insert and retrieve a station
- watchAll emits updates on insert
- count returns correct number
- delete removes station
- reorder updates sortOrder for each station ID
- count enforces that the caller can check the 15-station limit

- [ ] **Step 2: Run tests — expect FAIL (class does not exist)**

- [ ] **Step 3: Implement StationLocalDatasource**

Follow the SubscriptionLocalDatasource pattern. Key methods:

```dart
class StationLocalDatasource {
  StationLocalDatasource(this._isar);
  final Isar _isar;

  Future<Station> insert(Station station) async { ... }
  Future<Station?> getById(int id) => _isar.stations.get(id);
  Future<List<Station>> getAll() => _isar.stations.where().sortBySortOrder().findAll();
  Stream<List<Station>> watchAll() => _isar.stations.where().sortBySortOrder().watch(fireImmediately: true);
  Future<void> update(Station station) async { ... }
  Future<bool> delete(int id) => _isar.writeTxn(() => _isar.stations.delete(id));
  Future<int> count() => _isar.stations.count();
  Future<void> reorder(List<int> stationIds) async { ... }
}
```

- [ ] **Step 4: Run tests — expect PASS**

- [ ] **Step 5: Repeat for StationPodcastLocalDatasource**

Key methods: `insert`, `getByStation(stationId)`, `watchByStation(stationId)`, `delete(stationId, podcastId)`, `deleteAllForStation(stationId)`, `getStationIdsForPodcast(podcastId)`.

- [ ] **Step 6: Repeat for StationEpisodeLocalDatasource**

Key methods: `watchByStation(stationId, {limit, offset})`, `countByStation(stationId)`, `putAll(List<StationEpisode>)`, `deleteByIds(List<int>)`, `deleteAllForStation(stationId)`, `deleteByPodcast(podcastId)` (requires join through StationPodcast — query episodes whose stationId belongs to stations containing that podcastId), `getByStationAndEpisode(stationId, episodeId)`.

- [ ] **Step 7: Run all datasource tests**

Run: `cd packages/audiflow_domain && flutter test test/features/station/datasources/`
Expected: All pass

- [ ] **Step 8: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/station/datasources/
git add packages/audiflow_domain/test/features/station/datasources/
git commit -m "feat(domain): add Station datasources for Isar operations"
```

---

## Task 4: Station Repositories

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/station/repositories/station_repository.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/repositories/station_repository_impl.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/repositories/station_podcast_repository.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/repositories/station_podcast_repository_impl.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/repositories/station_episode_repository.dart`
- Create: `packages/audiflow_domain/lib/src/features/station/repositories/station_episode_repository_impl.dart`
- Test: `packages/audiflow_domain/test/features/station/repositories/station_repository_impl_test.dart`

- [ ] **Step 1: Write failing test for StationRepositoryImpl**

Test that `create` enforces the 15-station limit by throwing `StationLimitExceededException` when count is already at the limit.

- [ ] **Step 2: Run test — expect FAIL**

- [ ] **Step 3: Create repository interface**

```dart
// packages/audiflow_domain/lib/src/features/station/repositories/station_repository.dart
import '../models/station.dart';

abstract class StationRepository {
  Stream<List<Station>> watchAll();
  Future<Station?> findById(int id);
  Future<Station> create(Station station);
  Future<void> update(Station station);
  Future<void> delete(int id);
  Future<void> reorder(List<int> stationIds);
  Future<int> count();
}

class StationLimitExceededException implements Exception {
  const StationLimitExceededException();

  static const int maxStations = 15;

  @override
  String toString() => 'Station limit of $maxStations reached';
}
```

- [ ] **Step 4: Create repository implementation with Riverpod provider**

Follow the SubscriptionRepositoryImpl pattern — `@Riverpod(keepAlive: true)` provider that injects Isar via `isarProvider`, creates datasource, returns impl. The `create` method checks `count()` before inserting and throws `StationLimitExceededException` if limit reached.

- [ ] **Step 5: Create StationPodcastRepository interface + impl**

Same pattern. Interface defines `watchByStation`, `add`, `remove`, `removeAllForStation`. Impl delegates to datasource.

- [ ] **Step 6: Create StationEpisodeRepository interface + impl**

Interface defines `watchByStation({limit, offset})`, `countByStation`, `removeAllForStation`, `removeByPodcast`. Reconciliation methods (`reconcileFull`, `reconcileEpisode`) live in the StationReconciler service, not here — keep repository focused on CRUD.

- [ ] **Step 7: Run tests**

Run: `cd packages/audiflow_domain && flutter test test/features/station/repositories/`
Expected: All pass

- [ ] **Step 8: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/station/repositories/
git add packages/audiflow_domain/test/features/station/repositories/
git commit -m "feat(domain): add Station repository interfaces and implementations"
```

---

## Task 5: Station Reconciler

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/station/services/station_reconciler.dart`
- Test: `packages/audiflow_domain/test/features/station/services/station_reconciler_test.dart`

This is the most complex component. The reconciler evaluates episodes against station filter conditions and maintains the StationEpisode materialized view.

- [ ] **Step 1: Write failing test for full reconciliation — unplayed filter**

Create test with Isar containing: 1 Station (playbackState=unplayed), 2 StationPodcasts, 3 Episodes (1 with PlaybackHistory completed, 1 with no history, 1 with in-progress history). After `reconcileFull`, verify StationEpisode contains only the unplayed episode.

Schemas needed in test Isar: `StationSchema`, `StationPodcastSchema`, `StationEpisodeSchema`, `EpisodeSchema`, `PlaybackHistorySchema`, `DownloadTaskSchema`.

- [ ] **Step 2: Run test — expect FAIL**

- [ ] **Step 3: Implement StationReconciler.reconcileFull**

```dart
class StationReconciler {
  StationReconciler({
    required Isar isar,
  }) : _isar = isar;

  final Isar _isar;

  /// Full reconciliation: recalculate all episodes for a station.
  Future<void> reconcileFull(int stationId) async {
    final station = await _isar.stations.get(stationId);
    if (station == null) return;

    final stationPodcasts = await _isar.stationPodcasts
        .filter()
        .stationIdEqualTo(stationId)
        .findAll();

    final podcastIds = stationPodcasts.map((sp) => sp.podcastId).toList();

    // Fetch candidate episodes for all podcasts in this station
    final episodes = <Episode>[];
    for (final podcastId in podcastIds) {
      final podcastEpisodes = await _isar.episodes
          .filter()
          .podcastIdEqualTo(podcastId)
          .findAll();
      episodes.addAll(podcastEpisodes);
    }

    // Evaluate each episode against station conditions
    final matchingEpisodeIds = <int>[];
    for (final episode in episodes) {
      if (await _matchesConditions(episode, station)) {
        matchingEpisodeIds.add(episode.id);
      }
    }

    // Diff against current StationEpisode rows
    final currentEntries = await _isar.stationEpisodes
        .filter()
        .stationIdEqualTo(stationId)
        .findAll();
    final currentIds = currentEntries.map((e) => e.episodeId).toSet();
    final targetIds = matchingEpisodeIds.toSet();

    final toInsert = targetIds.difference(currentIds);
    final toDelete = currentIds.difference(targetIds);

    // Build episode map for sortKey lookup
    final episodeMap = {for (final e in episodes) e.id: e};

    await _isar.writeTxn(() async {
      // Delete removed entries
      if (toDelete.isNotEmpty) {
        final deleteIds = currentEntries
            .where((e) => toDelete.contains(e.episodeId))
            .map((e) => e.id)
            .toList();
        await _isar.stationEpisodes.deleteAll(deleteIds);
      }

      // Insert new entries
      if (toInsert.isNotEmpty) {
        final newEntries = toInsert.map((episodeId) {
          return StationEpisode()
            ..stationId = stationId
            ..episodeId = episodeId
            ..sortKey = episodeMap[episodeId]?.publishedAt;
        }).toList();
        await _isar.stationEpisodes.putAll(newEntries);
      }
    });
  }

  /// Evaluates whether an episode matches all station filter conditions.
  Future<bool> _matchesConditions(Episode episode, Station station) async {
    // Playback state filter (exclusive)
    if (!await _matchesPlaybackState(episode, station.playbackStateFilter)) {
      return false;
    }
    // Attribute filters (AND)
    if (station.filterDownloaded && !await _isDownloaded(episode.id)) {
      return false;
    }
    if (station.filterFavorited && !episode.isFavorited) {
      return false;
    }
    if (station.durationFilter != null && !_matchesDuration(episode, station.durationFilter!)) {
      return false;
    }
    if (station.publishedWithinDays != null && !_matchesPublishedWithin(episode, station.publishedWithinDays!)) {
      return false;
    }
    return true;
  }
  // ... helper methods for each filter condition
}
```

- [ ] **Step 4: Run test — expect PASS**

- [ ] **Step 5: Write failing tests for remaining filter types**

Test cases:
- `downloaded` filter: only episodes with `DownloadStatus.completed` pass
- `favorited` filter: only episodes with `isFavorited == true` pass
- `duration shorterThan`: only episodes with durationMs below threshold pass
- `duration longerThan`: only episodes with durationMs above threshold pass
- `publishedWithin 7 days`: only recent episodes pass
- `inProgress` filter: only episodes with PlaybackHistory (positionMs > 0, completedAt == null) pass
- Combined filters: `unplayed AND downloaded AND publishedWithin 30 days`

- [ ] **Step 6: Run tests — expect FAIL for new tests**

- [ ] **Step 7: Implement helper methods for each filter**

- [ ] **Step 8: Run tests — expect all PASS**

- [ ] **Step 9: Write failing test for differential reconciliation**

Test that `reconcileEpisode(episodeId)` correctly adds/removes the episode from affected stations when an episode's state changes (e.g., marking as favorited should add it to stations with `filterFavorited`).

- [ ] **Step 10: Implement reconcileEpisode**

```dart
  /// Differential reconciliation: re-evaluate a single episode
  /// across all stations that include its podcast.
  Future<void> reconcileEpisode(int episodeId) async {
    final episode = await _isar.episodes.get(episodeId);
    if (episode == null) return;

    // Find all stations that include this episode's podcast
    final stationPodcasts = await _isar.stationPodcasts
        .filter()
        .podcastIdEqualTo(episode.podcastId)
        .findAll();

    for (final sp in stationPodcasts) {
      final station = await _isar.stations.get(sp.stationId);
      if (station == null) continue;

      final matches = await _matchesConditions(episode, station);
      final existing = await _isar.stationEpisodes
          .filter()
          .stationIdEqualTo(sp.stationId)
          .and()
          .episodeIdEqualTo(episodeId)
          .findFirst();

      await _isar.writeTxn(() async {
        if (matches && existing == null) {
          await _isar.stationEpisodes.put(
            StationEpisode()
              ..stationId = sp.stationId
              ..episodeId = episodeId
              ..sortKey = episode.publishedAt,
          );
        } else if (!matches && existing != null) {
          await _isar.stationEpisodes.delete(existing.id);
        }
      });
    }
  }
```

- [ ] **Step 11: Run tests — expect PASS**

- [ ] **Step 12: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/station/services/station_reconciler.dart
git add packages/audiflow_domain/test/features/station/services/station_reconciler_test.dart
git commit -m "feat(domain): add StationReconciler with full and differential reconciliation"
```

---

## Task 6: Reconciler Service (Event Wiring)

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/station/services/station_reconciler_service.dart`
- Test: `packages/audiflow_domain/test/features/station/services/station_reconciler_service_test.dart`

- [ ] **Step 1: Write failing test**

Test that the service calls `reconcileEpisode` when a playback event is received. Use a fake/stub reconciler.

- [ ] **Step 2: Run test — expect FAIL**

- [ ] **Step 3: Implement StationReconcilerService**

Riverpod `@Riverpod(keepAlive: true)` service that:
- Creates `StationReconciler` with Isar instance
- Exposes `onEpisodeChanged(int episodeId)` — calls `reconcileEpisode`
- Exposes `onStationConfigChanged(int stationId)` — calls `reconcileFull`
- Exposes `onSubscriptionDeleted(int podcastId)` — cleans up StationPodcast and StationEpisode entries

The actual event stream subscriptions (PlayerEvent, DownloadEvent, etc.) will be wired in Task 10 after the UI is ready, to avoid triggering reconciliation before the schema is registered.

- [ ] **Step 4: Run test — expect PASS**

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/station/services/
git add packages/audiflow_domain/test/features/station/services/
git commit -m "feat(domain): add StationReconcilerService for event-driven reconciliation"
```

---

## Task 7: Domain Exports and Isar Registration

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`
- Modify: `packages/audiflow_app/lib/main.dart`

- [ ] **Step 1: Add station exports to audiflow_domain.dart**

Add after the Queue feature exports:

```dart
// Station feature
export 'src/features/station/models/station.dart';
export 'src/features/station/models/station_duration_filter.dart';
export 'src/features/station/models/station_episode.dart';
export 'src/features/station/models/station_episode_sort.dart';
export 'src/features/station/models/station_playback_state.dart';
export 'src/features/station/models/station_podcast.dart';
export 'src/features/station/datasources/local/station_local_datasource.dart';
export 'src/features/station/datasources/local/station_podcast_local_datasource.dart';
export 'src/features/station/datasources/local/station_episode_local_datasource.dart';
export 'src/features/station/repositories/station_repository.dart';
export 'src/features/station/repositories/station_repository_impl.dart';
export 'src/features/station/repositories/station_podcast_repository.dart';
export 'src/features/station/repositories/station_podcast_repository_impl.dart';
export 'src/features/station/repositories/station_episode_repository.dart';
export 'src/features/station/repositories/station_episode_repository_impl.dart';
export 'src/features/station/services/station_reconciler.dart';
export 'src/features/station/services/station_reconciler_service.dart';
```

- [ ] **Step 2: Register schemas in main.dart**

In `packages/audiflow_app/lib/main.dart`, add to the `Isar.open` schema list:

```dart
      StationSchema,
      StationPodcastSchema,
      StationEpisodeSchema,
```

- [ ] **Step 3: Run build to verify no import errors**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/audiflow_domain.dart
git add packages/audiflow_app/lib/main.dart
git commit -m "feat: register Station schemas and export domain APIs"
```

---

## Task 8: Library Screen Restructure

**Files:**
- Create: `packages/audiflow_app/lib/features/library/presentation/screens/subscriptions_list_screen.dart`
- Modify: `packages/audiflow_app/lib/features/library/presentation/screens/library_screen.dart`
- Create: `packages/audiflow_app/lib/features/station/presentation/controllers/station_list_controller.dart`
- Create: `packages/audiflow_app/lib/features/station/presentation/widgets/station_list_tile.dart`
- Modify: `packages/audiflow_app/lib/routing/app_router.dart`
- Test: `packages/audiflow_app/test/features/library/presentation/screens/subscriptions_list_screen_test.dart`

- [ ] **Step 1: Create SubscriptionsListScreen**

Extract the current subscription list from LibraryScreen into a standalone screen. This is mostly a move — the CustomScrollView with SliverList/SliverGrid of subscriptions becomes this screen's body.

- [ ] **Step 2: Create StationListController**

```dart
@riverpod
Stream<List<Station>> stationList(Ref ref) {
  return ref.watch(stationRepositoryProvider).watchAll();
}
```

- [ ] **Step 3: Create StationListTile widget**

Displays: 2x2 artwork mosaic, station name, summary text ("N podcasts, M episodes"). Taps navigate to `/library/station/:stationId`.

- [ ] **Step 4: Modify LibraryScreen**

Replace the current subscription list with:
1. ContinueListeningSection (unchanged)
2. STATIONS section header + list of StationListTile widgets
3. "Subscriptions >" group entry that navigates to `/subscriptions`

```dart
// Station section
SliverToBoxAdapter(child: _StationSectionHeader()),
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) => StationListTile(station: stations[index], ...),
    childCount: stations.length,
  ),
),
// Subscriptions group entry
SliverToBoxAdapter(
  child: ListTile(
    title: Text(l10n.libraryYourPodcasts),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.push('${AppRoutes.library}/subscriptions'),
  ),
),
```

- [ ] **Step 5: Add routes to app_router.dart**

Add to the library branch routes:

```dart
GoRoute(
  path: 'subscriptions',
  builder: (context, state) => const SubscriptionsListScreen(),
  routes: [
    GoRoute(
      path: 'podcast/:id',
      builder: (context, state) => _buildPodcastDetailScreen(state),
      // ... same nested routes as current library/podcast/:id
    ),
  ],
),
GoRoute(
  path: 'station/:stationId',
  builder: (context, state) => _buildStationDetailScreen(state),
  routes: [
    GoRoute(
      path: 'edit',
      builder: (context, state) => _buildStationEditScreen(state),
    ),
  ],
),
// IMPORTANT: Define station/new BEFORE station/:stationId
// to prevent go_router from matching "new" as a stationId.
GoRoute(
  path: 'station/new',
  builder: (context, state) => const StationEditScreen(),
),
```

Add to `AppRoutes`:

```dart
static const String subscriptions = '/library/subscriptions';
static const String stationDetail = '/library/station';
static const String stationNew = '/library/station/new';
```

- [ ] **Step 6: Write widget test for LibraryScreen restructure**

Verify that the Library tab shows station section and subscriptions group entry.

- [ ] **Step 7: Run tests**

Run: `cd packages/audiflow_app && flutter test`
Expected: All pass (existing library tests may need updating for the new structure)

- [ ] **Step 8: Commit**

```bash
git add packages/audiflow_app/lib/features/library/
git add packages/audiflow_app/lib/features/station/presentation/
git add packages/audiflow_app/lib/routing/app_router.dart
git add packages/audiflow_app/test/
git commit -m "feat(app): restructure Library tab with Stations section and collapsed Subscriptions"
```

---

## Task 9: Station Detail and Edit Screens

**Files:**
- Create: `packages/audiflow_app/lib/features/station/presentation/screens/station_detail_screen.dart`
- Create: `packages/audiflow_app/lib/features/station/presentation/screens/station_edit_screen.dart`
- Create: `packages/audiflow_app/lib/features/station/presentation/controllers/station_detail_controller.dart`
- Create: `packages/audiflow_app/lib/features/station/presentation/controllers/station_edit_controller.dart`

- [ ] **Step 1: Create StationDetailController**

```dart
@riverpod
Stream<List<StationEpisode>> stationEpisodes(Ref ref, int stationId) {
  return ref.watch(stationEpisodeRepositoryProvider)
      .watchByStation(stationId);
}

@riverpod
Future<Station?> stationById(Ref ref, int stationId) {
  return ref.watch(stationRepositoryProvider).findById(stationId);
}
```

- [ ] **Step 2: Create StationDetailScreen**

Displays: header with station name and edit button, filtered episode list (reads from StationEpisode), play all button, active filter indicators. Episodes are loaded by joining StationEpisode.episodeId with Episode collection.

- [ ] **Step 3: Create StationEditController**

Manages form state: name validation (required, max 50 chars), podcast picker state, filter toggles, save/delete operations. On save, calls `stationRepositoryProvider.create/update` then `stationReconcilerServiceProvider.onStationConfigChanged`.

- [ ] **Step 4: Create StationEditScreen**

Form with: name TextField, podcast picker (shows subscriptions excluding isCached), playback state radio group, attribute filter toggles (downloaded, favorited), duration filter picker, publishedWithin dropdown, episode sort selector.

- [ ] **Step 5: Wire up route builders in app_router.dart**

Add `_buildStationDetailScreen` and `_buildStationEditScreen` helper methods following the existing `_buildPodcastDetailScreen` pattern.

- [ ] **Step 6: Run full app test suite**

Run: `cd packages/audiflow_app && flutter test`
Expected: All pass

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_app/lib/features/station/
git add packages/audiflow_app/lib/routing/app_router.dart
git commit -m "feat(app): add Station detail and edit screens with controllers"
```

---

## Task 10: Event Wiring (Direct Call Integration)

The codebase uses direct service method calls (not event streams). The reconciler is triggered by modifying existing services to call `StationReconcilerService` after state mutations.

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/player/services/playback_history_service.dart`
- Modify: `packages/audiflow_domain/lib/src/features/download/services/download_service.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/feed_sync_service.dart`
- Modify: `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository_impl.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/repositories/episode_favorite_repository.dart` (if no existing favorite toggle exists)
- Create: `packages/audiflow_domain/lib/src/features/feed/repositories/episode_favorite_repository_impl.dart`

- [ ] **Step 1: Wire playback history changes**

In `PlaybackHistoryService`, after `markCompleted(episodeId)` and `onPlaybackStarted(episodeId, ...)`:
- Inject `StationReconcilerService` via constructor
- Call `_reconcilerService.onEpisodeChanged(episodeId)` after each state mutation

The `PlaybackHistoryService` is created via `playbackHistoryServiceProvider` — add `StationReconcilerService` as a dependency.

- [ ] **Step 2: Wire download state changes**

In `DownloadService`, after download completion and deletion:
- Inject `StationReconcilerService`
- Call `_reconcilerService.onEpisodeChanged(episodeId)` when download status changes to completed or is deleted

- [ ] **Step 3: Wire feed sync completion**

In `FeedSyncService`, after syncing a podcast's feed (new episodes inserted):
- Inject `StationReconcilerService`
- Call `_reconcilerService.onStationConfigChanged(stationId)` for each station containing the synced podcast
- Or: call `_reconcilerService.onEpisodeChanged(episodeId)` for each newly inserted episode

- [ ] **Step 4: Wire subscription deletion**

In `SubscriptionRepositoryImpl.deleteById`:
- Before or after deletion, call `_reconcilerService.onSubscriptionDeleted(podcastId)` which:
  1. Deletes all `StationPodcast` entries where `podcastId` matches
  2. Runs `reconcileFull` for each affected station to remove orphaned StationEpisode entries

- [ ] **Step 5: Create Episode favorite toggle**

Create `EpisodeFavoriteRepository` (interface + impl) with:
- `toggleFavorite(int episodeId)` — flips `isFavorited`, sets/clears `favoritedAt`
- After toggle, calls `_reconcilerService.onEpisodeChanged(episodeId)`

This provides the prerequisite for the Station favorited filter and the future Favorites station.

- [ ] **Step 6: Run full test suite**

Run: `melos run test`
Expected: All pass. Existing tests for PlaybackHistoryService and DownloadService may need updating to provide a stub StationReconcilerService.

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/services/playback_history_service.dart
git add packages/audiflow_domain/lib/src/features/download/services/download_service.dart
git add packages/audiflow_domain/lib/src/features/feed/services/feed_sync_service.dart
git add packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository_impl.dart
git add packages/audiflow_domain/lib/src/features/feed/repositories/episode_favorite_repository*
git commit -m "feat: wire Station reconciler to playback, download, sync, and subscription services"
```

---

## Task 11: Integration Test

**Files:**
- Create: `packages/audiflow_domain/test/features/station/integration/station_full_flow_test.dart`

- [ ] **Step 1: Write integration test**

End-to-end test with real Isar:
1. Create a Station with `unplayed` + `publishedWithin 30 days` filters
2. Add 2 podcasts to the station
3. Insert episodes: mix of old, new, played, unplayed
4. Run `reconcileFull`
5. Verify StationEpisode contains only new + unplayed episodes
6. Simulate playback completion on one episode
7. Run `reconcileEpisode`
8. Verify that episode is removed from StationEpisode
9. Delete the station
10. Verify all StationPodcast and StationEpisode entries are cleaned up

- [ ] **Step 2: Run integration test**

Run: `cd packages/audiflow_domain && flutter test test/features/station/integration/`
Expected: PASS

- [ ] **Step 3: Run full suite and analyze**

Run: `melos run test && cd packages/audiflow_app && flutter analyze`
Expected: All tests pass, zero analysis issues

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_domain/test/features/station/integration/
git commit -m "test(domain): add Station feature integration test"
```

---

## Task 12: Localization

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

- [ ] **Step 1: Add English strings**

```json
"stationSectionTitle": "Stations",
"stationNew": "New Station",
"stationName": "Station Name",
"stationNameHint": "e.g., News, Tech, Comedy",
"stationPodcasts": "Podcasts",
"stationFilters": "Filters",
"stationPlaybackOrder": "Playback Order",
"stationNewest": "Newest First",
"stationOldest": "Oldest First",
"stationFilterAll": "All Episodes",
"stationFilterUnplayed": "Unplayed",
"stationFilterInProgress": "In Progress",
"stationFilterDownloaded": "Downloaded Only",
"stationFilterFavorited": "Favorites Only",
"stationFilterDuration": "Duration",
"stationFilterShorterThan": "Shorter than {minutes} min",
"stationFilterLongerThan": "Longer than {minutes} min",
"stationFilterPublishedWithin": "Published within {days} days",
"stationLimitReached": "Station limit reached ({max})",
"stationDeleteConfirm": "Delete this station?",
"stationEpisodeCount": "{count, plural, =0{No episodes} =1{1 episode} other{{count} episodes}}",
"stationPodcastCount": "{count, plural, =1{1 podcast} other{{count} podcasts}}",
"stationEmpty": "No episodes match your filters",
"stationPlayAll": "Play All"
```

- [ ] **Step 2: Add Japanese strings**

```json
"stationSectionTitle": "ステーション",
"stationNew": "新規ステーション",
"stationName": "ステーション名",
"stationNameHint": "例: ニュース、テック、お笑い",
"stationPodcasts": "ポッドキャスト",
"stationFilters": "フィルタ",
"stationPlaybackOrder": "再生順",
"stationNewest": "新しい順",
"stationOldest": "古い順",
"stationFilterAll": "全エピソード",
"stationFilterUnplayed": "未再生",
"stationFilterInProgress": "再生中",
"stationFilterDownloaded": "ダウンロード済みのみ",
"stationFilterFavorited": "お気に入りのみ",
"stationFilterDuration": "再生時間",
"stationFilterShorterThan": "{minutes}分未満",
"stationFilterLongerThan": "{minutes}分以上",
"stationFilterPublishedWithin": "過去{days}日以内",
"stationLimitReached": "ステーション上限に達しました({max})",
"stationDeleteConfirm": "このステーションを削除しますか？",
"stationEpisodeCount": "{count, plural, =0{エピソードなし} other{{count}エピソード}}",
"stationPodcastCount": "{count, plural, other{{count}ポッドキャスト}}",
"stationEmpty": "フィルタに一致するエピソードがありません",
"stationPlayAll": "すべて再生"
```

- [ ] **Step 3: Generate localization files**

Run: `cd packages/audiflow_app && flutter gen-l10n`

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/l10n/
git commit -m "feat(l10n): add Station feature localization strings (en/ja)"
```

---

## Task 13: Final Verification

- [ ] **Step 1: Run code generation across all packages**

Run: `melos run codegen`

- [ ] **Step 2: Run analyzer**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: Zero issues

- [ ] **Step 3: Run full test suite**

Run: `melos run test`
Expected: All tests pass, 80%+ coverage on new code

- [ ] **Step 4: Format all Dart files**

Run: `melos run format` (or `dart format .`)

- [ ] **Step 5: Final commit if any formatting changes**

```bash
git add packages/audiflow_domain/ packages/audiflow_app/
git commit -m "chore: format and clean up Station feature code"
```
