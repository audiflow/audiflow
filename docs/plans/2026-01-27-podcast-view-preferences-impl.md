# Podcast View Preferences Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add per-podcast persistence for view mode, episode filter, and episode sort order using Drift database with cursor-based pagination.

**Architecture:** New Drift table `PodcastViewPreferences` with lazy initialization. Repository + datasource pattern. Riverpod controller replaces existing global `episodeFilterStateProvider` and in-memory `podcastViewModeControllerProvider`.

**Tech Stack:** Drift, Riverpod (code generation), Flutter

---

## Task 1: Create Drift Table for Podcast View Preferences

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart`

**Step 1: Create the Drift table definition**

```dart
import 'package:drift/drift.dart';

import '../../../features/subscription/models/subscriptions.dart';

/// Drift table for per-podcast view preferences.
///
/// Stores view mode, episode filter, and sort order for each podcast.
/// Rows are created lazily on first user interaction.
class PodcastViewPreferences extends Table {
  /// Foreign key to Subscriptions table.
  IntColumn get podcastId => integer().references(Subscriptions, #id)();

  /// View mode: 'episodes' or 'seasons'.
  TextColumn get viewMode => text().withDefault(const Constant('episodes'))();

  /// Episode filter: 'all', 'unplayed', or 'inProgress'.
  TextColumn get episodeFilter => text().withDefault(const Constant('all'))();

  /// Episode sort order: 'asc' or 'desc'.
  TextColumn get episodeSortOrder => text().withDefault(const Constant('desc'))();

  @override
  Set<Column> get primaryKey => {podcastId};
}
```

**Step 2: Verify file created**

Run: `ls -la packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart`
Expected: File exists

---

## Task 2: Register Table in Database and Add Migration

**Files:**
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart`

**Step 1: Add import and register table**

Add import at line 9:
```dart
import '../../features/feed/models/podcast_view_preference.dart';
```

Update `@DriftDatabase` annotation (line 18):
```dart
@DriftDatabase(tables: [Subscriptions, Episodes, PlaybackHistories, Seasons, PodcastViewPreferences])
```

**Step 2: Update schema version and add migration**

Change `schemaVersion` (line 27):
```dart
@override
int get schemaVersion => 7;
```

Add migration in `onUpgrade` after line 52:
```dart
      // Migration from v6 to v7: add PodcastViewPreferences table
      if (7 <= to && from < 7) {
        await m.createTable(podcastViewPreferences);
      }
```

**Step 3: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generated `app_database.g.dart` with new table

**Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart packages/audiflow_domain/lib/src/common/database/app_database.dart
git commit -m "feat(domain): add PodcastViewPreferences Drift table"
```

---

## Task 3: Create Local Datasource for Preferences

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/datasources/local/podcast_view_preference_local_datasource.dart`

**Step 1: Create the datasource**

```dart
import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';
import '../../models/podcast_view_preference.dart';

/// Local datasource for podcast view preferences using Drift.
class PodcastViewPreferenceLocalDatasource {
  PodcastViewPreferenceLocalDatasource(this._db);

  final AppDatabase _db;

  /// Gets preference for a podcast, returns null if not set.
  Future<PodcastViewPreference?> getPreference(int podcastId) {
    return (_db.select(_db.podcastViewPreferences)
          ..where((p) => p.podcastId.equals(podcastId)))
        .getSingleOrNull();
  }

  /// Watches preference for a podcast (emits null if not set).
  Stream<PodcastViewPreference?> watchPreference(int podcastId) {
    return (_db.select(_db.podcastViewPreferences)
          ..where((p) => p.podcastId.equals(podcastId)))
        .watchSingleOrNull();
  }

  /// Upserts preference (insert or update on conflict).
  Future<void> upsertPreference(PodcastViewPreferencesCompanion companion) {
    return _db.into(_db.podcastViewPreferences).insertOnConflictUpdate(companion);
  }

  /// Deletes preference for a podcast.
  Future<int> deletePreference(int podcastId) {
    return (_db.delete(_db.podcastViewPreferences)
          ..where((p) => p.podcastId.equals(podcastId)))
        .go();
  }
}
```

**Step 2: Verify file created**

Run: `ls -la packages/audiflow_domain/lib/src/features/feed/datasources/local/podcast_view_preference_local_datasource.dart`
Expected: File exists

---

## Task 4: Create Repository Interface and Implementation

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/repositories/podcast_view_preference_repository.dart`

**Step 1: Create repository with interface and implementation**

```dart
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../podcast_detail/presentation/widgets/episode_filter_chips.dart';
import '../datasources/local/podcast_view_preference_local_datasource.dart';
import '../models/podcast_view_preference.dart';
import '../models/season_sort.dart';
import '../presentation/controllers/podcast_view_mode_controller.dart';

part 'podcast_view_preference_repository.g.dart';

/// Repository for managing podcast view preferences.
abstract class PodcastViewPreferenceRepository {
  /// Gets preference for a podcast, returns defaults if not set.
  Future<PodcastViewPreferenceData> getPreference(int podcastId);

  /// Watches preference for a podcast, emits defaults if not set.
  Stream<PodcastViewPreferenceData> watchPreference(int podcastId);

  /// Updates view mode for a podcast.
  Future<void> updateViewMode(int podcastId, PodcastViewMode viewMode);

  /// Updates episode filter for a podcast.
  Future<void> updateEpisodeFilter(int podcastId, EpisodeFilter filter);

  /// Updates episode sort order for a podcast.
  Future<void> updateEpisodeSortOrder(int podcastId, SortOrder order);
}

/// Data class for podcast view preferences with typed values.
class PodcastViewPreferenceData {
  const PodcastViewPreferenceData({
    required this.podcastId,
    required this.viewMode,
    required this.episodeFilter,
    required this.episodeSortOrder,
  });

  final int podcastId;
  final PodcastViewMode viewMode;
  final EpisodeFilter episodeFilter;
  final SortOrder episodeSortOrder;

  /// Default preferences for a podcast.
  factory PodcastViewPreferenceData.defaults(int podcastId) {
    return PodcastViewPreferenceData(
      podcastId: podcastId,
      viewMode: PodcastViewMode.episodes,
      episodeFilter: EpisodeFilter.all,
      episodeSortOrder: SortOrder.descending,
    );
  }
}

/// Implementation of [PodcastViewPreferenceRepository].
class PodcastViewPreferenceRepositoryImpl
    implements PodcastViewPreferenceRepository {
  PodcastViewPreferenceRepositoryImpl(this._datasource);

  final PodcastViewPreferenceLocalDatasource _datasource;

  @override
  Future<PodcastViewPreferenceData> getPreference(int podcastId) async {
    final pref = await _datasource.getPreference(podcastId);
    return _toData(podcastId, pref);
  }

  @override
  Stream<PodcastViewPreferenceData> watchPreference(int podcastId) {
    return _datasource.watchPreference(podcastId).map(
      (pref) => _toData(podcastId, pref),
    );
  }

  @override
  Future<void> updateViewMode(int podcastId, PodcastViewMode viewMode) {
    return _datasource.upsertPreference(
      PodcastViewPreferencesCompanion(
        podcastId: Value(podcastId),
        viewMode: Value(_viewModeToString(viewMode)),
      ),
    );
  }

  @override
  Future<void> updateEpisodeFilter(int podcastId, EpisodeFilter filter) {
    return _datasource.upsertPreference(
      PodcastViewPreferencesCompanion(
        podcastId: Value(podcastId),
        episodeFilter: Value(_filterToString(filter)),
      ),
    );
  }

  @override
  Future<void> updateEpisodeSortOrder(int podcastId, SortOrder order) {
    return _datasource.upsertPreference(
      PodcastViewPreferencesCompanion(
        podcastId: Value(podcastId),
        episodeSortOrder: Value(_orderToString(order)),
      ),
    );
  }

  PodcastViewPreferenceData _toData(int podcastId, PodcastViewPreference? pref) {
    if (pref == null) {
      return PodcastViewPreferenceData.defaults(podcastId);
    }
    return PodcastViewPreferenceData(
      podcastId: podcastId,
      viewMode: _parseViewMode(pref.viewMode),
      episodeFilter: _parseFilter(pref.episodeFilter),
      episodeSortOrder: _parseOrder(pref.episodeSortOrder),
    );
  }

  PodcastViewMode _parseViewMode(String value) {
    return switch (value) {
      'seasons' => PodcastViewMode.seasons,
      _ => PodcastViewMode.episodes,
    };
  }

  EpisodeFilter _parseFilter(String value) {
    return switch (value) {
      'unplayed' => EpisodeFilter.unplayed,
      'inProgress' => EpisodeFilter.inProgress,
      _ => EpisodeFilter.all,
    };
  }

  SortOrder _parseOrder(String value) {
    return switch (value) {
      'asc' => SortOrder.ascending,
      _ => SortOrder.descending,
    };
  }

  String _viewModeToString(PodcastViewMode mode) {
    return switch (mode) {
      PodcastViewMode.episodes => 'episodes',
      PodcastViewMode.seasons => 'seasons',
    };
  }

  String _filterToString(EpisodeFilter filter) {
    return switch (filter) {
      EpisodeFilter.all => 'all',
      EpisodeFilter.unplayed => 'unplayed',
      EpisodeFilter.inProgress => 'inProgress',
    };
  }

  String _orderToString(SortOrder order) {
    return switch (order) {
      SortOrder.ascending => 'asc',
      SortOrder.descending => 'desc',
    };
  }
}

/// Provider for [PodcastViewPreferenceLocalDatasource].
@riverpod
PodcastViewPreferenceLocalDatasource podcastViewPreferenceLocalDatasource(
  PodcastViewPreferenceLocalDatasourceRef ref,
) {
  final db = ref.watch(databaseProvider);
  return PodcastViewPreferenceLocalDatasource(db);
}

/// Provider for [PodcastViewPreferenceRepository].
@riverpod
PodcastViewPreferenceRepository podcastViewPreferenceRepository(
  PodcastViewPreferenceRepositoryRef ref,
) {
  final datasource = ref.watch(podcastViewPreferenceLocalDatasourceProvider);
  return PodcastViewPreferenceRepositoryImpl(datasource);
}
```

**Step 2: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generated `.g.dart` file

**Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/datasources/local/podcast_view_preference_local_datasource.dart packages/audiflow_domain/lib/src/features/feed/repositories/podcast_view_preference_repository.dart
git commit -m "feat(domain): add podcast view preference repository"
```

---

## Task 5: Create Riverpod Providers for Preferences

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/providers/podcast_view_preference_providers.dart`

**Step 1: Create the providers file**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../podcast_detail/presentation/widgets/episode_filter_chips.dart';
import '../models/season_sort.dart';
import '../presentation/controllers/podcast_view_mode_controller.dart';
import '../repositories/podcast_view_preference_repository.dart';

part 'podcast_view_preference_providers.g.dart';

/// Watches podcast view preference for a given podcast ID.
///
/// Returns defaults if no preference is stored.
@riverpod
Stream<PodcastViewPreferenceData> podcastViewPreference(
  PodcastViewPreferenceRef ref,
  int podcastId,
) {
  final repo = ref.watch(podcastViewPreferenceRepositoryProvider);
  return repo.watchPreference(podcastId);
}

/// Controller for updating podcast view preferences.
///
/// Persists changes to Drift database immediately.
@riverpod
class PodcastViewPreferenceController
    extends _$PodcastViewPreferenceController {
  @override
  Future<PodcastViewPreferenceData> build(int podcastId) async {
    final repo = ref.watch(podcastViewPreferenceRepositoryProvider);
    return repo.getPreference(podcastId);
  }

  /// Sets the view mode and persists to database.
  Future<void> setViewMode(PodcastViewMode mode) async {
    final repo = ref.read(podcastViewPreferenceRepositoryProvider);
    await repo.updateViewMode(podcastId, mode);
    ref.invalidateSelf();
  }

  /// Toggles between episodes and seasons view modes.
  Future<void> toggleViewMode() async {
    final current = state.value;
    if (current == null) return;

    final newMode = current.viewMode == PodcastViewMode.episodes
        ? PodcastViewMode.seasons
        : PodcastViewMode.episodes;
    await setViewMode(newMode);
  }

  /// Sets the episode filter and persists to database.
  Future<void> setEpisodeFilter(EpisodeFilter filter) async {
    final repo = ref.read(podcastViewPreferenceRepositoryProvider);
    await repo.updateEpisodeFilter(podcastId, filter);
    ref.invalidateSelf();
  }

  /// Sets the episode sort order and persists to database.
  Future<void> setEpisodeSortOrder(SortOrder order) async {
    final repo = ref.read(podcastViewPreferenceRepositoryProvider);
    await repo.updateEpisodeSortOrder(podcastId, order);
    ref.invalidateSelf();
  }

  /// Toggles episode sort order between ascending and descending.
  Future<void> toggleEpisodeSortOrder() async {
    final current = state.value;
    if (current == null) return;

    final newOrder = current.episodeSortOrder == SortOrder.ascending
        ? SortOrder.descending
        : SortOrder.ascending;
    await setEpisodeSortOrder(newOrder);
  }
}
```

**Step 2: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generated `.g.dart` file

**Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/providers/podcast_view_preference_providers.dart
git commit -m "feat(domain): add podcast view preference Riverpod providers"
```

---

## Task 6: Export New Types from audiflow_domain

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

**Step 1: Add exports for new files**

Add these exports (find appropriate location in the exports list):
```dart
export 'src/features/feed/models/podcast_view_preference.dart';
export 'src/features/feed/repositories/podcast_view_preference_repository.dart';
export 'src/features/feed/providers/podcast_view_preference_providers.dart';
```

**Step 2: Run analyze to verify exports**

Run: `cd packages/audiflow_domain && flutter analyze`
Expected: No errors

**Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): export podcast view preference types"
```

---

## Task 7: Move EpisodeFilter Enum to Domain Layer

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/episode_filter.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_filter_chips.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

**Step 1: Create new EpisodeFilter enum in domain**

```dart
/// Filter options for episode list.
enum EpisodeFilter {
  all('All'),
  unplayed('Unplayed'),
  inProgress('In Progress');

  const EpisodeFilter(this.label);
  final String label;
}
```

**Step 2: Update episode_filter_chips.dart to import from domain**

Remove the `EpisodeFilter` enum definition (lines 5-12) and add import:
```dart
import 'package:audiflow_domain/audiflow_domain.dart' show EpisodeFilter;
```

**Step 3: Export from audiflow_domain.dart**

```dart
export 'src/features/feed/models/episode_filter.dart';
```

**Step 4: Update repository imports**

Update `podcast_view_preference_repository.dart` to import from local file instead of app package.

**Step 5: Run analyze**

Run: `melos run analyze`
Expected: No errors

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/episode_filter.dart packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_filter_chips.dart packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "refactor(domain): move EpisodeFilter enum to domain layer"
```

---

## Task 8: Move PodcastViewMode Enum to Domain Layer

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/podcast_view_mode.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_view_mode_controller.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

**Step 1: Create new PodcastViewMode enum in domain**

```dart
/// View modes for the podcast detail screen.
enum PodcastViewMode {
  /// Flat list of all episodes.
  episodes,

  /// Grouped by season.
  seasons,
}
```

**Step 2: Update podcast_view_mode_controller.dart**

Remove the enum definition (lines 5-12) and add import:
```dart
import 'package:audiflow_domain/audiflow_domain.dart' show PodcastViewMode;
```

**Step 3: Export from audiflow_domain.dart**

```dart
export 'src/features/feed/models/podcast_view_mode.dart';
```

**Step 4: Update repository imports**

Update `podcast_view_preference_repository.dart` to import from local file.

**Step 5: Run analyze**

Run: `melos run analyze`
Expected: No errors

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/podcast_view_mode.dart packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_view_mode_controller.dart packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "refactor(domain): move PodcastViewMode enum to domain layer"
```

---

## Task 9: Create Episode Sort Bottom Sheet Widget

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_sort_sheet.dart`

**Step 1: Create the widget**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for selecting episode sort options.
class EpisodeSortSheet extends StatelessWidget {
  const EpisodeSortSheet({
    super.key,
    required this.currentOrder,
    required this.onSortSelected,
  });

  final SortOrder currentOrder;
  final void Function(SortOrder order) onSortSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort by', style: theme.textTheme.titleLarge),
            const SizedBox(height: Spacing.md),
            _buildSortOption(
              context,
              'Episode number (oldest first)',
              SortOrder.ascending,
            ),
            _buildSortOption(
              context,
              'Episode number (newest first)',
              SortOrder.descending,
            ),
            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String label,
    SortOrder order,
  ) {
    final isSelected = currentOrder == order;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(label),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: colorScheme.primary)
          : null,
      onTap: () {
        onSortSelected(order);
        Navigator.pop(context);
      },
    );
  }
}

/// Shows the episode sort bottom sheet.
void showEpisodeSortSheet({
  required BuildContext context,
  required SortOrder currentOrder,
  required void Function(SortOrder order) onSortSelected,
}) {
  showModalBottomSheet(
    context: context,
    builder: (_) => EpisodeSortSheet(
      currentOrder: currentOrder,
      onSortSelected: onSortSelected,
    ),
  );
}
```

**Step 2: Verify file created**

Run: `ls -la packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_sort_sheet.dart`
Expected: File exists

**Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_sort_sheet.dart
git commit -m "feat(ui): add episode sort bottom sheet widget"
```

---

## Task 10: Update Podcast Detail Screen to Use Persisted Preferences

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart`

**Step 1: Add imports**

Add import for episode sort sheet:
```dart
import '../widgets/episode_sort_sheet.dart';
```

**Step 2: Update AppBar to show sort button in episodes view too**

Replace line 37 (`final showSortButton = viewMode == PodcastViewMode.seasons;`) and update the actions section (lines 42-48):

```dart
    // Get subscription ID for preference lookup
    final subscriptionAsync = ref.watch(
      subscriptionByItunesIdProvider(podcast.id),
    );
    final subscriptionId = subscriptionAsync.value?.id;

    // Get preferences if subscribed
    final prefsAsync = subscriptionId != null
        ? ref.watch(podcastViewPreferenceControllerProvider(subscriptionId))
        : null;
    final viewMode = prefsAsync?.value?.viewMode ?? PodcastViewMode.episodes;

    return Scaffold(
      appBar: AppBar(
        title: Text(podcast.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (subscriptionId != null)
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: viewMode == PodcastViewMode.seasons
                  ? 'Sort seasons'
                  : 'Sort episodes',
              onPressed: () => viewMode == PodcastViewMode.seasons
                  ? _showSeasonSortSheet(context, ref)
                  : _showEpisodeSortSheet(context, ref, subscriptionId),
            ),
        ],
      ),
      body: _buildBody(context, ref, theme, colorScheme),
    );
```

**Step 3: Add episode sort sheet method**

Add after `_showSortSheet` method:
```dart
  void _showEpisodeSortSheet(BuildContext context, WidgetRef ref, int subscriptionId) {
    final prefs = ref.read(podcastViewPreferenceControllerProvider(subscriptionId));
    final currentOrder = prefs.value?.episodeSortOrder ?? SortOrder.descending;

    showEpisodeSortSheet(
      context: context,
      currentOrder: currentOrder,
      onSortSelected: (order) {
        ref
            .read(podcastViewPreferenceControllerProvider(subscriptionId).notifier)
            .setEpisodeSortOrder(order);
      },
    );
  }
```

**Step 4: Update _buildContent to use persisted preferences**

Update the view mode and filter to use persisted preferences:
```dart
    // Get subscription for preference lookup
    final subscriptionAsync = ref.watch(
      subscriptionByFeedUrlProvider(feedUrl),
    );
    final subscription = subscriptionAsync.value;

    // Use persisted preferences if subscribed, otherwise defaults
    final prefsAsync = subscription != null
        ? ref.watch(podcastViewPreferenceControllerProvider(subscription.id))
        : null;
    final prefs = prefsAsync?.value;

    final viewMode = prefs?.viewMode ?? PodcastViewMode.episodes;
    final filter = prefs?.episodeFilter ?? EpisodeFilter.all;
```

**Step 5: Update filter chips to use persisted preference**

Update the filter chips `onSelected` callback:
```dart
EpisodeFilterChips(
  selected: filter,
  onSelected: (f) {
    if (subscription != null) {
      ref
          .read(podcastViewPreferenceControllerProvider(subscription.id).notifier)
          .setEpisodeFilter(f);
    }
  },
),
```

**Step 6: Update view mode toggle to use persisted preference**

Update the toggle `onChanged` callback:
```dart
SeasonViewToggle(
  selected: viewMode,
  onChanged: (mode) {
    if (subscription != null) {
      ref
          .read(podcastViewPreferenceControllerProvider(subscription.id).notifier)
          .toggleViewMode();
    }
  },
),
```

**Step 7: Run analyze**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors

**Step 8: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart
git commit -m "feat(ui): integrate persisted podcast view preferences"
```

---

## Task 11: Update Episode Filtering to Include Sort Order

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart`

**Step 1: Update filteredEpisodesProvider to accept sort order**

Rename and update the provider to include sorting:
```dart
/// Filters and sorts episodes based on preferences.
///
/// Returns filtered and sorted list of [PodcastItem].
@riverpod
Future<List<PodcastItem>> filteredSortedEpisodes(
  Ref ref,
  String feedUrl,
  EpisodeFilter filter,
  SortOrder sortOrder,
) async {
  final feed = await ref.watch(podcastDetailProvider(feedUrl).future);
  var episodes = feed.episodes;

  // Apply filter
  if (filter != EpisodeFilter.all) {
    final episodeRepo = ref.watch(episodeRepositoryProvider);
    final historyRepo = ref.watch(playbackHistoryRepositoryProvider);

    final filtered = <PodcastItem>[];
    for (final item in episodes) {
      if (item.enclosureUrl == null) continue;

      final episode = await episodeRepo.getByAudioUrl(item.enclosureUrl!);

      if (episode == null) {
        if (filter == EpisodeFilter.unplayed) filtered.add(item);
        continue;
      }

      final history = await historyRepo.getByEpisodeId(episode.id);
      final isCompleted = history?.completedAt != null;
      final isInProgress =
          history != null && 0 < history.positionMs && !isCompleted;

      if (filter == EpisodeFilter.unplayed && !isCompleted && !isInProgress) {
        filtered.add(item);
      } else if (filter == EpisodeFilter.inProgress && isInProgress) {
        filtered.add(item);
      }
    }
    episodes = filtered;
  }

  // Sort by episode number
  final sorted = List<PodcastItem>.from(episodes);
  sorted.sort((a, b) {
    final aNum = a.episodeNumber ?? 0;
    final bNum = b.episodeNumber ?? 0;
    return sortOrder == SortOrder.ascending
        ? aNum.compareTo(bNum)
        : bNum.compareTo(aNum);
  });

  return sorted;
}
```

**Step 2: Keep old provider for backward compatibility (deprecated)**

Add `@Deprecated` annotation to old provider or update all call sites.

**Step 3: Run code generation**

Run: `cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs`
Expected: Generated file updated

**Step 4: Update podcast_detail_screen.dart to use new provider**

Update the call site to pass sort order:
```dart
final filteredAsync = ref.watch(
  filteredSortedEpisodesProvider(
    feedUrl,
    filter,
    prefs?.episodeSortOrder ?? SortOrder.descending,
  ),
);
```

**Step 5: Run analyze**

Run: `melos run analyze`
Expected: No errors

**Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart
git commit -m "feat(domain): add episode sorting to filtered episodes provider"
```

---

## Task 12: Remove Deprecated Global Filter State

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart`

**Step 1: Remove EpisodeFilterState class**

Remove the entire `EpisodeFilterState` class (lines 222-229):
```dart
// DELETE THIS:
/// Manages the current episode filter selection.
@riverpod
class EpisodeFilterState extends _$EpisodeFilterState {
  @override
  EpisodeFilter build() => EpisodeFilter.all;

  void setFilter(EpisodeFilter filter) => state = filter;
}
```

**Step 2: Remove old filteredEpisodesProvider if not used elsewhere**

Search for usages and remove if no longer needed.

**Step 3: Run code generation**

Run: `cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs`
Expected: Generated file updated

**Step 4: Run analyze**

Run: `melos run analyze`
Expected: No errors

**Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart
git commit -m "refactor(domain): remove deprecated global episode filter state"
```

---

## Task 13: Add Subscription Lookup Provider by iTunes ID

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository.dart`

**Step 1: Check if provider exists, if not add it**

Add provider if missing:
```dart
/// Gets subscription by iTunes ID.
@riverpod
Future<Subscription?> subscriptionByItunesId(
  SubscriptionByItunesIdRef ref,
  String itunesId,
) {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getByItunesId(itunesId);
}
```

**Step 2: Add method to repository interface if missing**

Ensure `getByItunesId(String itunesId)` exists in the repository.

**Step 3: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

**Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/subscription/repositories/
git commit -m "feat(domain): add subscription lookup by iTunes ID provider"
```

---

## Task 14: Write Tests for Podcast View Preference Repository

**Files:**
- Create: `packages/audiflow_domain/test/features/feed/repositories/podcast_view_preference_repository_test.dart`

**Step 1: Create test file**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late PodcastViewPreferenceLocalDatasource datasource;
  late PodcastViewPreferenceRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.forTesting(testDatabaseExecutor());
    datasource = PodcastViewPreferenceLocalDatasource(db);
    repository = PodcastViewPreferenceRepositoryImpl(datasource);
  });

  tearDown(() async {
    await db.close();
  });

  group('PodcastViewPreferenceRepository', () {
    test('getPreference returns defaults for non-existent podcast', () async {
      final pref = await repository.getPreference(999);

      expect(pref.podcastId, 999);
      expect(pref.viewMode, PodcastViewMode.episodes);
      expect(pref.episodeFilter, EpisodeFilter.all);
      expect(pref.episodeSortOrder, SortOrder.descending);
    });

    test('updateViewMode persists and retrieves correctly', () async {
      await repository.updateViewMode(1, PodcastViewMode.seasons);
      final pref = await repository.getPreference(1);

      expect(pref.viewMode, PodcastViewMode.seasons);
    });

    test('updateEpisodeFilter persists and retrieves correctly', () async {
      await repository.updateEpisodeFilter(1, EpisodeFilter.unplayed);
      final pref = await repository.getPreference(1);

      expect(pref.episodeFilter, EpisodeFilter.unplayed);
    });

    test('updateEpisodeSortOrder persists and retrieves correctly', () async {
      await repository.updateEpisodeSortOrder(1, SortOrder.ascending);
      final pref = await repository.getPreference(1);

      expect(pref.episodeSortOrder, SortOrder.ascending);
    });

    test('watchPreference emits updates', () async {
      final stream = repository.watchPreference(1);

      await repository.updateViewMode(1, PodcastViewMode.seasons);

      await expectLater(
        stream,
        emits(predicate<PodcastViewPreferenceData>(
          (p) => p.viewMode == PodcastViewMode.seasons,
        )),
      );
    });
  });
}
```

**Step 2: Run tests**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/repositories/podcast_view_preference_repository_test.dart`
Expected: All tests pass

**Step 3: Commit**

```bash
git add packages/audiflow_domain/test/features/feed/repositories/podcast_view_preference_repository_test.dart
git commit -m "test(domain): add podcast view preference repository tests"
```

---

## Task 15: Final Integration Test and Cleanup

**Step 1: Run full test suite**

Run: `melos run test`
Expected: All tests pass

**Step 2: Run full analysis**

Run: `melos run analyze`
Expected: No errors or warnings

**Step 3: Run the app and test manually**

Run: `cd packages/audiflow_app && flutter run`
Expected:
- Navigate to a subscribed podcast
- Toggle Episodes/Seasons view - persists after leaving and returning
- Change filter to Unplayed - persists after leaving and returning
- Open episode sort sheet and change order - persists after leaving and returning
- Sort icon appears in both Episodes and Seasons views

**Step 4: Final commit**

```bash
git add .
git commit -m "feat(podcast): complete podcast view preferences feature"
```

---

## Summary

| Task | Description | Estimated Steps |
|------|-------------|-----------------|
| 1 | Create Drift table | 2 |
| 2 | Register table and migration | 4 |
| 3 | Create local datasource | 2 |
| 4 | Create repository | 3 |
| 5 | Create Riverpod providers | 3 |
| 6 | Export from domain | 3 |
| 7 | Move EpisodeFilter to domain | 6 |
| 8 | Move PodcastViewMode to domain | 6 |
| 9 | Create episode sort sheet | 3 |
| 10 | Update podcast detail screen | 8 |
| 11 | Update filtering with sort | 6 |
| 12 | Remove deprecated state | 5 |
| 13 | Add subscription lookup | 4 |
| 14 | Write tests | 3 |
| 15 | Final integration | 4 |

**Total: 15 tasks**
