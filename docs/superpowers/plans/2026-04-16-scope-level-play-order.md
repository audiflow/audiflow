# Scope-Level Play Order Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add per-podcast and per-playlist/group override for adhoc queue play order, cascading to the global setting.

**Architecture:** Two cascade paths (podcast -> global; group -> playlist -> global) backed by separate Isar collections for user preferences, with a shared bottom sheet picker on three screens. The `QueueService` stops reading the global setting directly; callers resolve the effective order and pass it explicitly.

**Tech Stack:** Flutter/Dart, Isar (persistence), Riverpod (state), existing `audiflow_domain`/`audiflow_app`/`audiflow_core` packages.

---

## File Structure

### New Files

| File | Purpose |
|------|---------|
| `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_user_preference.dart` | Isar collection for per-playlist user overrides |
| `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_user_preference.dart` | Isar collection for per-group user overrides |
| `packages/audiflow_domain/lib/src/features/feed/repositories/play_order_preference_repository.dart` | Interface + impl + Riverpod providers |
| `packages/audiflow_domain/lib/src/features/feed/datasources/local/play_order_preference_local_datasource.dart` | Isar CRUD for the three preference collections |
| `packages/audiflow_domain/test/features/feed/repositories/play_order_preference_repository_test.dart` | Unit tests for cascade resolution |
| `packages/audiflow_domain/test/features/feed/datasources/local/play_order_preference_local_datasource_test.dart` | Datasource CRUD tests |
| `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/play_order_bottom_sheet.dart` | Shared bottom sheet picker widget |
| `packages/audiflow_app/test/features/podcast_detail/presentation/widgets/play_order_bottom_sheet_test.dart` | Widget test for bottom sheet |

### Modified Files

| File | Change |
|------|--------|
| `packages/audiflow_core/lib/src/models/auto_play_order.dart` | Add `defaultOrder` value |
| `packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart` | Add `String? autoPlayOrder` field |
| `packages/audiflow_domain/lib/src/common/providers/database_provider.dart` | Register two new Isar schemas |
| `packages/audiflow_domain/lib/audiflow_domain.dart` | Export new files |
| `packages/audiflow_domain/lib/src/features/queue/services/queue_service.dart` | Replace `forceDisplayOrder` with `effectiveOrder` |
| `packages/audiflow_domain/test/features/queue/services/queue_service_test.dart` | Update tests for new parameter |
| `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart` | Update `_parseAutoPlayOrder` for `defaultOrder` |
| `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart` | Replace `SearchableAppBar`, add popup menu |
| `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart` | Replace `SearchableAppBar`, add popup menu |
| `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_group_episodes_screen.dart` | Add play order to existing popup menu |
| `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart` | Accept `AutoPlayOrder` instead of no order param |
| `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart` | Replace `forceDisplayOrder` with `effectiveOrder` |
| `packages/audiflow_app/lib/features/station/presentation/screens/station_detail_screen.dart` | Adapt to new `effectiveOrder` parameter |
| `packages/audiflow_app/lib/l10n/app_en.arb` | Add l10n keys for play order menu/bottom sheet |
| `packages/audiflow_app/lib/l10n/app_ja.arb` | Add l10n keys (Japanese) |

---

### Task 1: Extend AutoPlayOrder Enum

**Files:**
- Modify: `packages/audiflow_core/lib/src/models/auto_play_order.dart`
- Modify: `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart:294-300`

- [ ] **Step 1: Add `defaultOrder` to `AutoPlayOrder`**

```dart
// packages/audiflow_core/lib/src/models/auto_play_order.dart
enum AutoPlayOrder {
  /// Inherit from parent scope or global setting.
  defaultOrder,

  /// Chronological order, oldest episode first.
  oldestFirst,

  /// Follow the current display order on screen.
  asDisplayed,
}
```

- [ ] **Step 2: Update `_parseAutoPlayOrder` in `AppSettingsRepositoryImpl`**

In `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart`, line 294-300, add `'defaultOrder'` case:

```dart
AutoPlayOrder _parseAutoPlayOrder(String? name) {
  return switch (name) {
    'defaultOrder' => AutoPlayOrder.defaultOrder,
    'oldestFirst' => AutoPlayOrder.oldestFirst,
    'asDisplayed' => AutoPlayOrder.asDisplayed,
    _ => SettingsDefaults.autoPlayOrder,
  };
}
```

- [ ] **Step 3: Run analyze to verify no breakage**

Run: `cd packages/audiflow_core && flutter analyze`
Expected: No errors (adding an enum value is non-breaking for switch expressions with `_` defaults)

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_core/lib/src/models/auto_play_order.dart packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart
git commit -m "feat(core): add defaultOrder to AutoPlayOrder enum"
```

---

### Task 2: Add `autoPlayOrder` Field to `PodcastViewPreference`

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart`

- [ ] **Step 1: Add `autoPlayOrder` field**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart
@collection
class PodcastViewPreference {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int podcastId;

  String viewMode = 'episodes';
  String episodeFilter = 'all';
  String episodeSortOrder = 'desc';
  String seasonSortField = 'seasonNumber';
  String seasonSortOrder = 'desc';
  String? selectedPlaylistId;

  /// Per-podcast adhoc queue play order override.
  /// null means inherit from global setting.
  String? autoPlayOrder;
}
```

- [ ] **Step 2: Run codegen for Isar**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Regenerates `podcast_view_preference.g.dart` with new field

- [ ] **Step 3: Verify analyze passes**

Run: `cd packages/audiflow_domain && flutter analyze`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.g.dart
git commit -m "feat(domain): add autoPlayOrder field to PodcastViewPreference"
```

---

### Task 3: Create New Isar Collections

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_user_preference.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_user_preference.dart`
- Modify: `packages/audiflow_domain/lib/src/common/providers/database_provider.dart:27-42`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Create `SmartPlaylistUserPreference` collection**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_user_preference.dart
import 'package:isar_community/isar.dart';

part 'smart_playlist_user_preference.g.dart';

@collection
@Name('SmartPlaylistUserPreference')
class SmartPlaylistUserPreference {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('playlistId')], unique: true)
  late int podcastId;

  late String playlistId;

  /// Per-playlist adhoc queue play order override.
  /// null means inherit from global setting.
  String? autoPlayOrder;
}
```

- [ ] **Step 2: Create `SmartPlaylistGroupUserPreference` collection**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_user_preference.dart
import 'package:isar_community/isar.dart';

part 'smart_playlist_group_user_preference.g.dart';

@collection
@Name('SmartPlaylistGroupUserPreference')
class SmartPlaylistGroupUserPreference {
  Id id = Isar.autoIncrement;

  @Index(
    composite: [CompositeIndex('playlistId'), CompositeIndex('groupId')],
    unique: true,
  )
  late int podcastId;

  late String playlistId;
  late String groupId;

  /// Per-group adhoc queue play order override.
  /// null means inherit from playlist-level or global setting.
  String? autoPlayOrder;
}
```

- [ ] **Step 3: Register schemas in `database_provider.dart`**

Add imports at `packages/audiflow_domain/lib/src/common/providers/database_provider.dart` (after line 12):

```dart
import '../../features/feed/models/smart_playlist_group_user_preference.dart';
import '../../features/feed/models/smart_playlist_user_preference.dart';
```

Add to the `isarSchemas` list (after `PodcastViewPreferenceSchema` at line 34):

```dart
SmartPlaylistUserPreferenceSchema,
SmartPlaylistGroupUserPreferenceSchema,
```

- [ ] **Step 4: Add exports to barrel file**

In `packages/audiflow_domain/lib/audiflow_domain.dart`, add after the `podcast_view_preference.dart` export (line 78):

```dart
export 'src/features/feed/models/smart_playlist_group_user_preference.dart';
export 'src/features/feed/models/smart_playlist_user_preference.dart';
```

- [ ] **Step 5: Run codegen**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `.g.dart` files for both new collections

- [ ] **Step 6: Verify analyze passes**

Run: `cd packages/audiflow_domain && flutter analyze`
Expected: No errors

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_user_preference.dart packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_user_preference.g.dart packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_user_preference.dart packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_user_preference.g.dart packages/audiflow_domain/lib/src/common/providers/database_provider.dart packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add SmartPlaylistUserPreference and SmartPlaylistGroupUserPreference collections"
```

---

### Task 4: Create Play Order Preference Datasource

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/datasources/local/play_order_preference_local_datasource.dart`
- Create: `packages/audiflow_domain/test/features/feed/datasources/local/play_order_preference_local_datasource_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/datasources/local/play_order_preference_local_datasource_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late PlayOrderPreferenceLocalDatasource datasource;

  setUp(() async {
    isar = await openTestIsar();
    datasource = PlayOrderPreferenceLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close();
  });

  group('podcast play order', () {
    test('returns null when no preference set', () async {
      final result = await datasource.getPodcastPlayOrder(1);
      check(result).isNull();
    });

    test('stores and retrieves podcast play order', () async {
      await datasource.setPodcastPlayOrder(1, 'asDisplayed');
      final result = await datasource.getPodcastPlayOrder(1);
      check(result).equals('asDisplayed');
    });

    test('clears podcast play order when set to null', () async {
      await datasource.setPodcastPlayOrder(1, 'asDisplayed');
      await datasource.setPodcastPlayOrder(1, null);
      final result = await datasource.getPodcastPlayOrder(1);
      check(result).isNull();
    });

    test('updates existing podcast play order', () async {
      await datasource.setPodcastPlayOrder(1, 'asDisplayed');
      await datasource.setPodcastPlayOrder(1, 'oldestFirst');
      final result = await datasource.getPodcastPlayOrder(1);
      check(result).equals('oldestFirst');
    });
  });

  group('playlist play order', () {
    test('returns null when no preference set', () async {
      final result = await datasource.getPlaylistPlayOrder(1, 'regular');
      check(result).isNull();
    });

    test('stores and retrieves playlist play order', () async {
      await datasource.setPlaylistPlayOrder(1, 'regular', 'oldestFirst');
      final result = await datasource.getPlaylistPlayOrder(1, 'regular');
      check(result).equals('oldestFirst');
    });

    test('different playlists have independent preferences', () async {
      await datasource.setPlaylistPlayOrder(1, 'regular', 'oldestFirst');
      await datasource.setPlaylistPlayOrder(1, 'short', 'asDisplayed');
      check(await datasource.getPlaylistPlayOrder(1, 'regular'))
          .equals('oldestFirst');
      check(await datasource.getPlaylistPlayOrder(1, 'short'))
          .equals('asDisplayed');
    });

    test('clears playlist play order when set to null', () async {
      await datasource.setPlaylistPlayOrder(1, 'regular', 'oldestFirst');
      await datasource.setPlaylistPlayOrder(1, 'regular', null);
      final result = await datasource.getPlaylistPlayOrder(1, 'regular');
      check(result).isNull();
    });
  });

  group('group play order', () {
    test('returns null when no preference set', () async {
      final result =
          await datasource.getGroupPlayOrder(1, 'regular', 'season_1');
      check(result).isNull();
    });

    test('stores and retrieves group play order', () async {
      await datasource.setGroupPlayOrder(
        1, 'regular', 'season_1', 'asDisplayed',
      );
      final result =
          await datasource.getGroupPlayOrder(1, 'regular', 'season_1');
      check(result).equals('asDisplayed');
    });

    test('different groups have independent preferences', () async {
      await datasource.setGroupPlayOrder(
        1, 'regular', 'season_1', 'asDisplayed',
      );
      await datasource.setGroupPlayOrder(
        1, 'regular', 'season_2', 'oldestFirst',
      );
      check(await datasource.getGroupPlayOrder(1, 'regular', 'season_1'))
          .equals('asDisplayed');
      check(await datasource.getGroupPlayOrder(1, 'regular', 'season_2'))
          .equals('oldestFirst');
    });

    test('clears group play order when set to null', () async {
      await datasource.setGroupPlayOrder(
        1, 'regular', 'season_1', 'asDisplayed',
      );
      await datasource.setGroupPlayOrder(1, 'regular', 'season_1', null);
      final result =
          await datasource.getGroupPlayOrder(1, 'regular', 'season_1');
      check(result).isNull();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/datasources/local/play_order_preference_local_datasource_test.dart`
Expected: Compilation error -- `PlayOrderPreferenceLocalDatasource` does not exist

- [ ] **Step 3: Write the datasource implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/datasources/local/play_order_preference_local_datasource.dart
import 'package:isar_community/isar.dart';

import '../../models/podcast_view_preference.dart';
import '../../models/smart_playlist_group_user_preference.dart';
import '../../models/smart_playlist_user_preference.dart';

class PlayOrderPreferenceLocalDatasource {
  PlayOrderPreferenceLocalDatasource(this._isar);

  final Isar _isar;

  // -- Podcast level (uses existing PodcastViewPreference) --

  Future<String?> getPodcastPlayOrder(int podcastId) async {
    final pref =
        await _isar.podcastViewPreferences.getByPodcastId(podcastId);
    return pref?.autoPlayOrder;
  }

  Future<void> setPodcastPlayOrder(int podcastId, String? order) async {
    await _isar.writeTxn(() async {
      final existing =
          await _isar.podcastViewPreferences.getByPodcastId(podcastId);
      final pref = existing ?? (PodcastViewPreference()..podcastId = podcastId);
      pref.autoPlayOrder = order;
      await _isar.podcastViewPreferences.put(pref);
    });
  }

  // -- Playlist level --

  Future<String?> getPlaylistPlayOrder(
    int podcastId,
    String playlistId,
  ) async {
    final pref = await _isar.smartPlaylistUserPreferences
        .getByPodcastIdPlaylistId(podcastId, playlistId);
    return pref?.autoPlayOrder;
  }

  Future<void> setPlaylistPlayOrder(
    int podcastId,
    String playlistId,
    String? order,
  ) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.smartPlaylistUserPreferences
          .getByPodcastIdPlaylistId(podcastId, playlistId);
      if (order == null && existing != null) {
        await _isar.smartPlaylistUserPreferences.delete(existing.id);
        return;
      }
      if (order == null) return;
      final pref = existing ??
          (SmartPlaylistUserPreference()
            ..podcastId = podcastId
            ..playlistId = playlistId);
      pref.autoPlayOrder = order;
      await _isar.smartPlaylistUserPreferences.put(pref);
    });
  }

  // -- Group level --

  Future<String?> getGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
  ) async {
    final pref = await _isar.smartPlaylistGroupUserPreferences
        .getByPodcastIdPlaylistIdGroupId(podcastId, playlistId, groupId);
    return pref?.autoPlayOrder;
  }

  Future<void> setGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
    String? order,
  ) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.smartPlaylistGroupUserPreferences
          .getByPodcastIdPlaylistIdGroupId(podcastId, playlistId, groupId);
      if (order == null && existing != null) {
        await _isar.smartPlaylistGroupUserPreferences.delete(existing.id);
        return;
      }
      if (order == null) return;
      final pref = existing ??
          (SmartPlaylistGroupUserPreference()
            ..podcastId = podcastId
            ..playlistId = playlistId
            ..groupId = groupId);
      pref.autoPlayOrder = order;
      await _isar.smartPlaylistGroupUserPreferences.put(pref);
    });
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/datasources/local/play_order_preference_local_datasource_test.dart`
Expected: All tests pass

Note: The test helper `openTestIsar()` must include the two new schemas. Check `test/helpers/isar_test_helper.dart` and add `SmartPlaylistUserPreferenceSchema` and `SmartPlaylistGroupUserPreferenceSchema` to its schema list if they are not already included via `isarSchemas`.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/datasources/local/play_order_preference_local_datasource.dart packages/audiflow_domain/test/features/feed/datasources/local/play_order_preference_local_datasource_test.dart
git commit -m "feat(domain): add PlayOrderPreferenceLocalDatasource with tests"
```

---

### Task 5: Create Play Order Preference Repository

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/repositories/play_order_preference_repository.dart`
- Create: `packages/audiflow_domain/test/features/feed/repositories/play_order_preference_repository_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Write the failing test for cascade resolution**

```dart
// packages/audiflow_domain/test/features/feed/repositories/play_order_preference_repository_test.dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late PlayOrderPreferenceLocalDatasource datasource;
  late _FakeAppSettingsRepository fakeSettings;
  late PlayOrderPreferenceRepositoryImpl repository;

  setUp(() async {
    isar = await openTestIsar();
    datasource = PlayOrderPreferenceLocalDatasource(isar);
    fakeSettings = _FakeAppSettingsRepository();
    repository = PlayOrderPreferenceRepositoryImpl(
      datasource: datasource,
      settingsRepository: fakeSettings,
    );
  });

  tearDown(() async {
    await isar.close();
  });

  group('resolveForPodcast (path A)', () {
    test('returns global when no podcast override', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.asDisplayed;
      final result = await repository.resolveForPodcast(1);
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('returns podcast override when set', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.asDisplayed;
      await repository.setPodcastPlayOrder(1, AutoPlayOrder.oldestFirst);
      final result = await repository.resolveForPodcast(1);
      check(result).equals(AutoPlayOrder.oldestFirst);
    });

    test('returns global when podcast is set to defaultOrder', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.asDisplayed;
      await repository.setPodcastPlayOrder(1, AutoPlayOrder.defaultOrder);
      final result = await repository.resolveForPodcast(1);
      check(result).equals(AutoPlayOrder.asDisplayed);
    });
  });

  group('resolveForPlaylist (path B, playlist level)', () {
    test('returns global when no playlist override', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      final result = await repository.resolveForPlaylist(1, 'regular');
      check(result).equals(AutoPlayOrder.oldestFirst);
    });

    test('returns playlist override when set', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      await repository.setPlaylistPlayOrder(
        1, 'regular', AutoPlayOrder.asDisplayed,
      );
      final result = await repository.resolveForPlaylist(1, 'regular');
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('returns global when playlist is set to defaultOrder', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      await repository.setPlaylistPlayOrder(
        1, 'regular', AutoPlayOrder.defaultOrder,
      );
      final result = await repository.resolveForPlaylist(1, 'regular');
      check(result).equals(AutoPlayOrder.oldestFirst);
    });
  });

  group('resolveForGroup (path B, full cascade)', () {
    test('returns global when no overrides', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      final result = await repository.resolveForGroup(
        1, 'regular', 'season_1',
      );
      check(result).equals(AutoPlayOrder.oldestFirst);
    });

    test('returns group override when set', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      await repository.setGroupPlayOrder(
        1, 'regular', 'season_1', AutoPlayOrder.asDisplayed,
      );
      final result = await repository.resolveForGroup(
        1, 'regular', 'season_1',
      );
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('falls through to playlist when group is defaultOrder', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      await repository.setPlaylistPlayOrder(
        1, 'regular', AutoPlayOrder.asDisplayed,
      );
      await repository.setGroupPlayOrder(
        1, 'regular', 'season_1', AutoPlayOrder.defaultOrder,
      );
      final result = await repository.resolveForGroup(
        1, 'regular', 'season_1',
      );
      check(result).equals(AutoPlayOrder.asDisplayed);
    });

    test('falls through to global when both are defaultOrder', () async {
      fakeSettings.autoPlayOrder = AutoPlayOrder.asDisplayed;
      await repository.setPlaylistPlayOrder(
        1, 'regular', AutoPlayOrder.defaultOrder,
      );
      await repository.setGroupPlayOrder(
        1, 'regular', 'season_1', AutoPlayOrder.defaultOrder,
      );
      final result = await repository.resolveForGroup(
        1, 'regular', 'season_1',
      );
      check(result).equals(AutoPlayOrder.asDisplayed);
    });
  });

  group('setPodcastPlayOrder', () {
    test('clears override when set to null', () async {
      await repository.setPodcastPlayOrder(1, AutoPlayOrder.asDisplayed);
      await repository.setPodcastPlayOrder(1, null);
      fakeSettings.autoPlayOrder = AutoPlayOrder.oldestFirst;
      final result = await repository.resolveForPodcast(1);
      check(result).equals(AutoPlayOrder.oldestFirst);
    });
  });
}

class _FakeAppSettingsRepository implements AppSettingsRepository {
  AutoPlayOrder autoPlayOrder = AutoPlayOrder.oldestFirst;

  @override
  AutoPlayOrder getAutoPlayOrder() => autoPlayOrder;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/repositories/play_order_preference_repository_test.dart`
Expected: Compilation error -- `PlayOrderPreferenceRepositoryImpl` does not exist

- [ ] **Step 3: Write repository interface and implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/repositories/play_order_preference_repository.dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../settings/repositories/app_settings_repository.dart';
import '../datasources/local/play_order_preference_local_datasource.dart';

part 'play_order_preference_repository.g.dart';

abstract interface class PlayOrderPreferenceRepository {
  Future<AutoPlayOrder?> getPodcastPlayOrder(int podcastId);
  Future<void> setPodcastPlayOrder(int podcastId, AutoPlayOrder? order);

  Future<AutoPlayOrder?> getPlaylistPlayOrder(
    int podcastId,
    String playlistId,
  );
  Future<void> setPlaylistPlayOrder(
    int podcastId,
    String playlistId,
    AutoPlayOrder? order,
  );

  Future<AutoPlayOrder?> getGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
  );
  Future<void> setGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
    AutoPlayOrder? order,
  );

  Future<AutoPlayOrder> resolveForPodcast(int podcastId);
  Future<AutoPlayOrder> resolveForPlaylist(int podcastId, String playlistId);
  Future<AutoPlayOrder> resolveForGroup(
    int podcastId,
    String playlistId,
    String groupId,
  );
}

class PlayOrderPreferenceRepositoryImpl
    implements PlayOrderPreferenceRepository {
  PlayOrderPreferenceRepositoryImpl({
    required PlayOrderPreferenceLocalDatasource datasource,
    required AppSettingsRepository settingsRepository,
  }) : _datasource = datasource,
       _settingsRepository = settingsRepository;

  final PlayOrderPreferenceLocalDatasource _datasource;
  final AppSettingsRepository _settingsRepository;

  @override
  Future<AutoPlayOrder?> getPodcastPlayOrder(int podcastId) async {
    final value = await _datasource.getPodcastPlayOrder(podcastId);
    return _parseOrder(value);
  }

  @override
  Future<void> setPodcastPlayOrder(int podcastId, AutoPlayOrder? order) {
    return _datasource.setPodcastPlayOrder(podcastId, _toStorageValue(order));
  }

  @override
  Future<AutoPlayOrder?> getPlaylistPlayOrder(
    int podcastId,
    String playlistId,
  ) async {
    final value =
        await _datasource.getPlaylistPlayOrder(podcastId, playlistId);
    return _parseOrder(value);
  }

  @override
  Future<void> setPlaylistPlayOrder(
    int podcastId,
    String playlistId,
    AutoPlayOrder? order,
  ) {
    return _datasource.setPlaylistPlayOrder(
      podcastId, playlistId, _toStorageValue(order),
    );
  }

  @override
  Future<AutoPlayOrder?> getGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
  ) async {
    final value =
        await _datasource.getGroupPlayOrder(podcastId, playlistId, groupId);
    return _parseOrder(value);
  }

  @override
  Future<void> setGroupPlayOrder(
    int podcastId,
    String playlistId,
    String groupId,
    AutoPlayOrder? order,
  ) {
    return _datasource.setGroupPlayOrder(
      podcastId, playlistId, groupId, _toStorageValue(order),
    );
  }

  @override
  Future<AutoPlayOrder> resolveForPodcast(int podcastId) async {
    final podcastOrder = await getPodcastPlayOrder(podcastId);
    if (podcastOrder != null && podcastOrder != AutoPlayOrder.defaultOrder) {
      return podcastOrder;
    }
    return _settingsRepository.getAutoPlayOrder();
  }

  @override
  Future<AutoPlayOrder> resolveForPlaylist(
    int podcastId,
    String playlistId,
  ) async {
    final playlistOrder = await getPlaylistPlayOrder(podcastId, playlistId);
    if (playlistOrder != null &&
        playlistOrder != AutoPlayOrder.defaultOrder) {
      return playlistOrder;
    }
    return _settingsRepository.getAutoPlayOrder();
  }

  @override
  Future<AutoPlayOrder> resolveForGroup(
    int podcastId,
    String playlistId,
    String groupId,
  ) async {
    final groupOrder =
        await getGroupPlayOrder(podcastId, playlistId, groupId);
    if (groupOrder != null && groupOrder != AutoPlayOrder.defaultOrder) {
      return groupOrder;
    }
    return resolveForPlaylist(podcastId, playlistId);
  }

  AutoPlayOrder? _parseOrder(String? value) {
    return switch (value) {
      'defaultOrder' => AutoPlayOrder.defaultOrder,
      'oldestFirst' => AutoPlayOrder.oldestFirst,
      'asDisplayed' => AutoPlayOrder.asDisplayed,
      _ => null,
    };
  }

  String? _toStorageValue(AutoPlayOrder? order) {
    if (order == null || order == AutoPlayOrder.defaultOrder) return null;
    return order.name;
  }
}

@riverpod
PlayOrderPreferenceLocalDatasource playOrderPreferenceLocalDatasource(
  Ref ref,
) {
  final isar = ref.watch(isarProvider);
  return PlayOrderPreferenceLocalDatasource(isar);
}

@riverpod
PlayOrderPreferenceRepository playOrderPreferenceRepository(Ref ref) {
  final datasource = ref.watch(playOrderPreferenceLocalDatasourceProvider);
  final settings = ref.watch(appSettingsRepositoryProvider);
  return PlayOrderPreferenceRepositoryImpl(
    datasource: datasource,
    settingsRepository: settings,
  );
}
```

- [ ] **Step 4: Add exports to barrel file**

In `packages/audiflow_domain/lib/audiflow_domain.dart`, add:

```dart
export 'src/features/feed/datasources/local/play_order_preference_local_datasource.dart';
export 'src/features/feed/repositories/play_order_preference_repository.dart';
```

- [ ] **Step 5: Run codegen (for Riverpod providers)**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 6: Run tests to verify they pass**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/repositories/play_order_preference_repository_test.dart`
Expected: All tests pass

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/repositories/play_order_preference_repository.dart packages/audiflow_domain/lib/src/features/feed/repositories/play_order_preference_repository.g.dart packages/audiflow_domain/test/features/feed/repositories/play_order_preference_repository_test.dart packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add PlayOrderPreferenceRepository with cascade resolution"
```

---

### Task 6: Update QueueService to Accept Effective Order

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/queue/services/queue_service.dart:118-136`
- Modify: `packages/audiflow_domain/test/features/queue/services/queue_service_test.dart:540-597`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart:494`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart:30,53,446-451`
- Modify: `packages/audiflow_app/lib/features/station/presentation/screens/station_detail_screen.dart:357`

- [ ] **Step 1: Update existing tests first**

In `packages/audiflow_domain/test/features/queue/services/queue_service_test.dart`, replace the `with forceDisplayOrder` group (lines 540-597) with:

```dart
group('with effectiveOrder', () {
  test(
    'preserves display order when effectiveOrder is asDisplayed',
    () async {
      final siblingIds = [50, 30, 10, 40, 20];
      final starting = _episode(
        id: 30,
        episodeNumber: 3,
        publishedAt: DateTime(2024, 3),
      );

      when(mockEpisodeRepo.getById(30)).thenAnswer((_) async => starting);
      _stubReplaceWithAdhoc(mockQueueRepo);

      await service.createAdhocQueue(
        startingEpisodeId: 30,
        sourceContext: 'Station',
        siblingEpisodeIds: siblingIds,
        effectiveOrder: AutoPlayOrder.asDisplayed,
      );

      verify(
        mockQueueRepo.replaceWithAdhoc(
          episodeIds: [10, 40, 20],
          sourceContext: 'Station',
        ),
      ).called(1);

      verifyNever(mockEpisodeRepo.getByIds(any));
    },
  );

  test('empty queue when starting episode is last in list', () async {
    final siblingIds = [10, 20, 30];
    final starting = _episode(id: 30);

    when(mockEpisodeRepo.getById(30)).thenAnswer((_) async => starting);
    _stubReplaceWithAdhoc(mockQueueRepo);

    await service.createAdhocQueue(
      startingEpisodeId: 30,
      sourceContext: 'Station',
      siblingEpisodeIds: siblingIds,
      effectiveOrder: AutoPlayOrder.asDisplayed,
    );

    verify(
      mockQueueRepo.replaceWithAdhoc(
        episodeIds: [],
        sourceContext: 'Station',
      ),
    ).called(1);
  });

  test('uses oldest-first sort when effectiveOrder is oldestFirst',
      () async {
    final siblingIds = [30, 10, 20];
    final episodes = [
      _episode(
        id: 10, episodeNumber: 1, publishedAt: DateTime(2024, 1),
      ),
      _episode(
        id: 20, episodeNumber: 2, publishedAt: DateTime(2024, 2),
      ),
      _episode(
        id: 30, episodeNumber: 3, publishedAt: DateTime(2024, 3),
      ),
    ];
    final starting = episodes[2]; // id=30

    when(mockEpisodeRepo.getById(30)).thenAnswer((_) async => starting);
    when(mockEpisodeRepo.getByIds(siblingIds))
        .thenAnswer((_) async => List.of(episodes));
    _stubReplaceWithAdhoc(mockQueueRepo);

    // Global is asDisplayed, but effectiveOrder overrides
    when(mockSettingsRepo.getAutoPlayOrder())
        .thenReturn(AutoPlayOrder.asDisplayed);

    await service.createAdhocQueue(
      startingEpisodeId: 30,
      sourceContext: 'Podcast',
      siblingEpisodeIds: siblingIds,
      effectiveOrder: AutoPlayOrder.oldestFirst,
    );

    // After ep 30 (2024-03) there are no later episodes
    verify(
      mockQueueRepo.replaceWithAdhoc(
        episodeIds: [],
        sourceContext: 'Podcast',
      ),
    ).called(1);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd packages/audiflow_domain && flutter test test/features/queue/services/queue_service_test.dart`
Expected: Compilation error -- no parameter `effectiveOrder`

- [ ] **Step 3: Update `createAdhocQueue` in QueueService**

In `packages/audiflow_domain/lib/src/features/queue/services/queue_service.dart`, change the method signature (lines 118-122) and condition (line 135-136):

Replace:
```dart
Future<void> createAdhocQueue({
  required int startingEpisodeId,
  required String sourceContext,
  List<int>? siblingEpisodeIds,
  bool forceDisplayOrder = false,
}) async {
```

With:
```dart
Future<void> createAdhocQueue({
  required int startingEpisodeId,
  required String sourceContext,
  List<int>? siblingEpisodeIds,
  AutoPlayOrder? effectiveOrder,
}) async {
```

Replace the condition (lines 135-136):
```dart
      if (forceDisplayOrder ||
          _settingsRepository.getAutoPlayOrder() == AutoPlayOrder.asDisplayed) {
```

With:
```dart
      final order = effectiveOrder ?? _settingsRepository.getAutoPlayOrder();
      if (order == AutoPlayOrder.asDisplayed) {
```

Update the doc comment (lines 112-115) to describe `effectiveOrder` instead of `forceDisplayOrder`.

- [ ] **Step 4: Update all call sites**

**`smart_playlist_episode_list_tile.dart`:**
- Line 30: Replace `this.forceDisplayOrder = false,` with `this.effectiveOrder,`
- Line 53: Replace `final bool forceDisplayOrder;` with `final AutoPlayOrder? effectiveOrder;`
- Lines 446-451: Replace `forceDisplayOrder: forceDisplayOrder,` with `effectiveOrder: effectiveOrder,`

**`episode_list_tile.dart`:**
- Add constructor param: `this.effectiveOrder,` (after `siblingEpisodeIds`)
- Add field: `final AutoPlayOrder? effectiveOrder;`
- Line 494: Add `effectiveOrder: effectiveOrder,` to `createAdhocQueue` call

**`station_detail_screen.dart`:**
- Line 357: Replace `forceDisplayOrder: true,` with `effectiveOrder: AutoPlayOrder.asDisplayed,`

- [ ] **Step 5: Run all tests**

Run: `cd packages/audiflow_domain && flutter test test/features/queue/services/queue_service_test.dart`
Expected: All tests pass

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/queue/services/queue_service.dart packages/audiflow_domain/test/features/queue/services/queue_service_test.dart packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart packages/audiflow_app/lib/features/station/presentation/screens/station_detail_screen.dart
git commit -m "refactor(queue): replace forceDisplayOrder with effectiveOrder in createAdhocQueue"
```

---

### Task 7: Add Localization Keys

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

- [ ] **Step 1: Add English l10n keys**

Add to `packages/audiflow_app/lib/l10n/app_en.arb`:

```json
"playOrderMenuTitle": "Play order",
"@playOrderMenuTitle": { "description": "Menu entry for play order preference" },
"playOrderDefault": "Default ({resolvedOrder})",
"@playOrderDefault": {
  "description": "Default play order option showing resolved parent value",
  "placeholders": {
    "resolvedOrder": { "type": "String" }
  }
},
"playOrderOldestFirst": "Oldest first",
"@playOrderOldestFirst": { "description": "Play order: chronological" },
"playOrderAsDisplayed": "As displayed",
"@playOrderAsDisplayed": { "description": "Play order: screen order" }
```

- [ ] **Step 2: Add Japanese l10n keys**

Add to `packages/audiflow_app/lib/l10n/app_ja.arb`:

```json
"playOrderMenuTitle": "再生順序",
"playOrderDefault": "デフォルト ({resolvedOrder})",
"playOrderOldestFirst": "古い順",
"playOrderAsDisplayed": "表示順"
```

- [ ] **Step 3: Run l10n codegen**

Run: `cd packages/audiflow_app && flutter gen-l10n`
Expected: Generates updated localization files

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/l10n/
git commit -m "feat(l10n): add play order preference strings (en/ja)"
```

---

### Task 8: Create Play Order Bottom Sheet Widget

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/play_order_bottom_sheet.dart`
- Create: `packages/audiflow_app/test/features/podcast_detail/presentation/widgets/play_order_bottom_sheet_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
// packages/audiflow_app/test/features/podcast_detail/presentation/widgets/play_order_bottom_sheet_test.dart
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/play_order_bottom_sheet.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/l10n_test_helper.dart';

void main() {
  group('PlayOrderBottomSheet', () {
    testWidgets('shows three radio options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showPlayOrderBottomSheet(
                  context: context,
                  currentOrder: AutoPlayOrder.defaultOrder,
                  resolvedParentOrder: AutoPlayOrder.oldestFirst,
                  onOrderSelected: (_) {},
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      check(find.byType(RadioListTile<AutoPlayOrder>).evaluate().length)
          .equals(3);
    });

    testWidgets('selects current order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showPlayOrderBottomSheet(
                  context: context,
                  currentOrder: AutoPlayOrder.asDisplayed,
                  resolvedParentOrder: AutoPlayOrder.oldestFirst,
                  onOrderSelected: (_) {},
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final asDisplayedTile = tester.widget<RadioListTile<AutoPlayOrder>>(
        find.byWidgetPredicate(
          (w) =>
              w is RadioListTile<AutoPlayOrder> &&
              w.value == AutoPlayOrder.asDisplayed,
        ),
      );
      check(asDisplayedTile.groupValue).equals(AutoPlayOrder.asDisplayed);
    });

    testWidgets('calls onOrderSelected and closes on tap', (tester) async {
      AutoPlayOrder? selected;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showPlayOrderBottomSheet(
                  context: context,
                  currentOrder: AutoPlayOrder.defaultOrder,
                  resolvedParentOrder: AutoPlayOrder.oldestFirst,
                  onOrderSelected: (order) => selected = order,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('As displayed'));
      await tester.pumpAndSettle();

      check(selected).equals(AutoPlayOrder.asDisplayed);
    });
  });
}
```

Note: If `l10n_test_helper.dart` does not exist, create it with `testLocalizationsDelegates` that includes `AppLocalizations.delegate`, `GlobalMaterialLocalizations.delegate`, and `GlobalWidgetsLocalizations.delegate`. Check existing test helpers first.

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/widgets/play_order_bottom_sheet_test.dart`
Expected: Compilation error -- `showPlayOrderBottomSheet` does not exist

- [ ] **Step 3: Implement the bottom sheet**

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/play_order_bottom_sheet.dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

Future<void> showPlayOrderBottomSheet({
  required BuildContext context,
  required AutoPlayOrder currentOrder,
  required AutoPlayOrder resolvedParentOrder,
  required ValueChanged<AutoPlayOrder> onOrderSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => _PlayOrderBottomSheet(
      currentOrder: currentOrder,
      resolvedParentOrder: resolvedParentOrder,
      onOrderSelected: (order) {
        onOrderSelected(order);
        Navigator.of(context).pop();
      },
    ),
  );
}

class _PlayOrderBottomSheet extends StatelessWidget {
  const _PlayOrderBottomSheet({
    required this.currentOrder,
    required this.resolvedParentOrder,
    required this.onOrderSelected,
  });

  final AutoPlayOrder currentOrder;
  final AutoPlayOrder resolvedParentOrder;
  final ValueChanged<AutoPlayOrder> onOrderSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resolvedLabel = _orderLabel(l10n, resolvedParentOrder);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.playOrderMenuTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioListTile<AutoPlayOrder>(
            title: Text(l10n.playOrderDefault(resolvedLabel)),
            value: AutoPlayOrder.defaultOrder,
            groupValue: currentOrder,
            onChanged: (_) => onOrderSelected(AutoPlayOrder.defaultOrder),
          ),
          RadioListTile<AutoPlayOrder>(
            title: Text(l10n.playOrderOldestFirst),
            value: AutoPlayOrder.oldestFirst,
            groupValue: currentOrder,
            onChanged: (_) => onOrderSelected(AutoPlayOrder.oldestFirst),
          ),
          RadioListTile<AutoPlayOrder>(
            title: Text(l10n.playOrderAsDisplayed),
            value: AutoPlayOrder.asDisplayed,
            groupValue: currentOrder,
            onChanged: (_) => onOrderSelected(AutoPlayOrder.asDisplayed),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _orderLabel(AppLocalizations l10n, AutoPlayOrder order) {
    return switch (order) {
      AutoPlayOrder.oldestFirst => l10n.playOrderOldestFirst,
      AutoPlayOrder.asDisplayed => l10n.playOrderAsDisplayed,
      AutoPlayOrder.defaultOrder => l10n.playOrderOldestFirst,
    };
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/widgets/play_order_bottom_sheet_test.dart`
Expected: All tests pass

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/play_order_bottom_sheet.dart packages/audiflow_app/test/features/podcast_detail/presentation/widgets/play_order_bottom_sheet_test.dart
git commit -m "feat(app): add play order bottom sheet picker widget"
```

---

### Task 9: Update PodcastDetailScreen (AppBar + Search + Menu)

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart:92-98`

- [ ] **Step 1: Replace SearchableAppBar with plain AppBar + PopupMenuButton**

In `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart`, replace the `SearchableAppBar` (lines 92-96) with:

```dart
appBar: AppBar(
  title: Text(podcast.name, maxLines: 1, overflow: TextOverflow.ellipsis),
  actions: [
    PopupMenuButton<String>(
      onSelected: (value) => _onMenuAction(value),
      itemBuilder: (context) {
        final l10n = AppLocalizations.of(context);
        return [
          PopupMenuItem(
            value: 'play_order',
            child: ListTile(
              leading: const Icon(Icons.sort),
              title: Text(l10n.playOrderMenuTitle),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ];
      },
    ),
  ],
),
```

- [ ] **Step 2: Add search TextField below appbar**

Add `_searchController`, `_searchDebounce` timer, and `_onSearchChanged` method to the state class (follow the pattern from `SmartPlaylistGroupEpisodesScreen` lines 58-60, 117-122). Add a `SliverToBoxAdapter` with a search `TextField` as the first sliver in the `CustomScrollView` body:

```dart
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: MaterialLocalizations.of(context).searchFieldLabel,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _searchDebounce?.cancel();
                setState(() => _searchQuery = '');
              },
            );
          },
        ),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  ),
),
```

Remember to dispose `_searchController` and cancel `_searchDebounce` in `dispose()`.

- [ ] **Step 3: Add `_onMenuAction` method**

```dart
void _onMenuAction(String action) {
  if (action != 'play_order') return;
  final feedUrl = podcast.feedUrl;
  if (feedUrl == null) return;
  final subscription =
      ref.read(subscriptionByFeedUrlProvider(feedUrl)).value;
  if (subscription == null) return;

  final repo = ref.read(playOrderPreferenceRepositoryProvider);
  repo.getPodcastPlayOrder(subscription.id).then((currentOrder) {
    if (!mounted) return;
    showPlayOrderBottomSheet(
      context: context,
      currentOrder: currentOrder ?? AutoPlayOrder.defaultOrder,
      resolvedParentOrder:
          ref.read(appSettingsRepositoryProvider).getAutoPlayOrder(),
      onOrderSelected: (order) {
        repo.setPodcastPlayOrder(subscription.id, order);
      },
    );
  });
}
```

- [ ] **Step 4: Wire resolved order to EpisodeListTile**

Where `EpisodeListTile` is built in this screen, resolve the effective order and pass it. The simplest approach: read from the repository in the build method (async) or use a `FutureProvider`. For initial implementation, the parent screen resolves once and passes down:

Add a state field `AutoPlayOrder? _resolvedPlayOrder;` and resolve it when the subscription becomes available. Pass it to each `EpisodeListTile` as `effectiveOrder: _resolvedPlayOrder`.

- [ ] **Step 5: Run analyze**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart
git commit -m "feat(app): replace SearchableAppBar with AppBar + popup menu on podcast detail screen"
```

---

### Task 10: Update SmartPlaylistEpisodesScreen (Playlist-Level Menu)

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart:78-82`

- [ ] **Step 1: Replace SearchableAppBar with plain AppBar + PopupMenuButton**

In `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart`, replace the `SearchableAppBar` (lines 78-82) with:

```dart
appBar: AppBar(
  title: Text(widget.smartPlaylist.formattedDisplayName),
  actions: [
    PopupMenuButton<String>(
      onSelected: (value) => _onMenuAction(value),
      itemBuilder: (context) {
        final l10n = AppLocalizations.of(context);
        return [
          PopupMenuItem(
            value: 'play_order',
            child: ListTile(
              leading: const Icon(Icons.sort),
              title: Text(l10n.playOrderMenuTitle),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ];
      },
    ),
  ],
),
```

- [ ] **Step 2: Add search TextField below appbar**

Add `_searchController` and `_searchDebounce` timer to the state. Replace the direct `_searchQuery` usage with the debounced pattern. Add a `SliverToBoxAdapter` with search `TextField` at the top of the `CustomScrollView` slivers (same pattern as Task 9 Step 2).

- [ ] **Step 3: Add `_onMenuAction` for playlist-level play order**

```dart
void _onMenuAction(String action) {
  if (action != 'play_order') return;
  final podcastId = widget.podcast.id;
  final playlistId = widget.smartPlaylist.playlistId;
  final repo = ref.read(playOrderPreferenceRepositoryProvider);

  repo.getPlaylistPlayOrder(podcastId, playlistId).then((currentOrder) {
    if (!mounted) return;
    showPlayOrderBottomSheet(
      context: context,
      currentOrder: currentOrder ?? AutoPlayOrder.defaultOrder,
      resolvedParentOrder:
          ref.read(appSettingsRepositoryProvider).getAutoPlayOrder(),
      onOrderSelected: (order) {
        repo.setPlaylistPlayOrder(podcastId, playlistId, order);
      },
    );
  });
}
```

- [ ] **Step 4: Wire resolved order to SmartPlaylistEpisodeListTile**

Where `SmartPlaylistEpisodeListTile` is built, pass the resolved `effectiveOrder` from `resolveForPlaylist()`. Same approach as Task 9 Step 4: resolve once in state and pass down.

- [ ] **Step 5: Run analyze**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart
git commit -m "feat(app): add play order menu to smart playlist episodes screen"
```

---

### Task 11: Update SmartPlaylistGroupEpisodesScreen (Group-Level Menu)

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_group_episodes_screen.dart:133-209`

- [ ] **Step 1: Add play order entry to existing PopupMenuButton**

In `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_group_episodes_screen.dart`, add a new `PopupMenuItem` to the existing `itemBuilder` (at the start of the list, before download items at line 177):

```dart
PopupMenuItem(
  value: 'play_order',
  child: ListTile(
    leading: const Icon(Icons.sort),
    title: Text(l10n.playOrderMenuTitle),
    dense: true,
    contentPadding: EdgeInsets.zero,
  ),
),
```

- [ ] **Step 2: Handle the new menu action**

In the `onSelected` callback (line 134), add a case for `'play_order'`:

```dart
case 'play_order':
  _showPlayOrderSheet();
```

- [ ] **Step 3: Implement `_showPlayOrderSheet`**

```dart
void _showPlayOrderSheet() {
  final podcastId = widget.group.podcastId;
  final playlistId = widget.parentPlaylist.playlistId;
  final groupId = widget.group.groupId;
  final repo = ref.read(playOrderPreferenceRepositoryProvider);

  repo.getGroupPlayOrder(podcastId, playlistId, groupId).then((currentOrder) {
    if (!mounted) return;
    repo.resolveForPlaylist(podcastId, playlistId).then((parentOrder) {
      if (!mounted) return;
      showPlayOrderBottomSheet(
        context: context,
        currentOrder: currentOrder ?? AutoPlayOrder.defaultOrder,
        resolvedParentOrder: parentOrder,
        onOrderSelected: (order) {
          repo.setGroupPlayOrder(podcastId, playlistId, groupId, order);
        },
      );
    });
  });
}
```

- [ ] **Step 4: Wire resolved order to SmartPlaylistEpisodeListTile**

Where `SmartPlaylistEpisodeListTile` instances are built, pass the resolved `effectiveOrder` from `resolveForGroup()`. Resolve once in state and pass down.

- [ ] **Step 5: Run analyze**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_group_episodes_screen.dart
git commit -m "feat(app): add play order menu to smart playlist group episodes screen"
```

---

### Task 12: Full Test Suite Verification

**Files:** All modified test files

- [ ] **Step 1: Run domain tests**

Run: `cd packages/audiflow_domain && flutter test`
Expected: All tests pass

- [ ] **Step 2: Run app tests**

Run: `cd packages/audiflow_app && flutter test`
Expected: All tests pass

- [ ] **Step 3: Run full analyze**

Run: `flutter analyze`
Expected: No errors or warnings

- [ ] **Step 4: Run full test suite via melos**

Run: `melos run test`
Expected: All packages pass

- [ ] **Step 5: Final commit if any fixups needed**

```bash
git add -A
git commit -m "test: fix test failures from play order feature"
```
