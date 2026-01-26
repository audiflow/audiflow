# Podcast View Preferences Design

## Overview

Add episode sorting and persist all view settings (view mode, filter, sort order) per-podcast using Drift database.

## Current State

- **View modes:** Episodes/Seasons (not persisted)
- **Episode filter:** All/Unplayed/In Progress (global, not per-podcast)
- **Episode sort:** None
- **Season sort:** Persisted per-podcast via `seasonSortControllerProvider`

## Requirements

1. Episode sorting by episode number (ascending/descending)
2. Per-podcast persistence for:
   - View mode (Episodes/Seasons)
   - Episode filter (All/Unplayed/In Progress)
   - Episode sort order (asc/desc)
3. Sort UI: AppBar icon + bottom sheet (same pattern as seasons)
4. Database-level sorting with cursor-based pagination

## Data Model

**New Drift Table** in `audiflow_domain`:

```dart
// packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart

class PodcastViewPreferences extends Table {
  IntColumn get podcastId => integer().references(Subscriptions, #id)();
  TextColumn get viewMode => text().withDefault(const Constant('episodes'))();
  TextColumn get episodeFilter => text().withDefault(const Constant('all'))();
  TextColumn get episodeSortOrder => text().withDefault(const Constant('desc'))();

  @override
  Set<Column> get primaryKey => {podcastId};
}
```

**Defaults:**
- View mode: `episodes`
- Filter: `all`
- Episode sort: `desc` (highest episode number first)

## Domain Layer

**Repository:**

```dart
// packages/audiflow_domain/lib/src/features/feed/repositories/podcast_view_preference_repository.dart

abstract class PodcastViewPreferenceRepository {
  Future<PodcastViewPreference> getPreference(int podcastId);
  Stream<PodcastViewPreference> watchPreference(int podcastId);
  Future<void> updatePreference(int podcastId, {
    PodcastViewMode? viewMode,
    EpisodeFilter? episodeFilter,
    SortOrder? episodeSortOrder,
  });
}
```

**Riverpod Providers:**

```dart
@riverpod
Stream<PodcastViewPreference> podcastViewPreference(ref, int podcastId);

@riverpod
class PodcastViewPreferenceController extends _$... {
  void setViewMode(PodcastViewMode mode);
  void setEpisodeFilter(EpisodeFilter filter);
  void setEpisodeSortOrder(SortOrder order);
}
```

## Database-Level Sorting with Cursor Pagination

```dart
// Cursor-based query for virtual list
Stream<List<Episode>> watchEpisodes({
  required int podcastId,
  required EpisodeFilter filter,
  required SortOrder sortOrder,
  required int limit,
  int? cursorEpisodeNumber,
  int? cursorId,
}) {
  var query = select(episodes)
    ..where((e) => e.podcastId.equals(podcastId))
    ..where((e) => _applyFilter(e, filter))
    ..limit(limit);

  if (cursorEpisodeNumber != null) {
    if (sortOrder == SortOrder.descending) {
      query = query..where((e) =>
        e.episodeNumber.isSmallerThanValue(cursorEpisodeNumber) |
        (e.episodeNumber.equals(cursorEpisodeNumber) & e.id.isSmallerThanValue(cursorId!))
      );
    } else {
      query = query..where((e) =>
        e.episodeNumber.isBiggerThanValue(cursorEpisodeNumber) |
        (e.episodeNumber.equals(cursorEpisodeNumber) & e.id.isBiggerThanValue(cursorId!))
      );
    }
  }

  query = query..orderBy([
    (e) => OrderingTerm(
      expression: e.episodeNumber,
      mode: sortOrder == SortOrder.descending ? OrderingMode.desc : OrderingMode.asc,
    ),
    (e) => OrderingTerm(expression: e.id, mode: OrderingMode.desc),
  ]);

  return query.watch();
}
```

## Presentation Layer

**Episode Sort Bottom Sheet:**

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_sort_sheet.dart

void showEpisodeSortSheet({
  required BuildContext context,
  required SortOrder currentOrder,
  required void Function(SortOrder) onSortSelected,
});
```

**AppBar Changes:**

- Sort icon visible in both Episodes and Seasons views
- Episodes view: opens `showEpisodeSortSheet`
- Seasons view: opens `showSeasonSortSheet` (existing)

**Filter/Toggle Changes:**

- `EpisodeFilterChips` reads from per-podcast preference
- `SeasonViewToggle` persists via preference controller

## Initialization

Lazy initialization - no migration needed:

```dart
Future<PodcastViewPreference> getPreference(int podcastId) async {
  final result = await (select(podcastViewPreferences)
    ..where((p) => p.podcastId.equals(podcastId))
  ).getSingleOrNull();

  return result ?? PodcastViewPreference(
    podcastId: podcastId,
    viewMode: PodcastViewMode.episodes,
    episodeFilter: EpisodeFilter.all,
    episodeSortOrder: SortOrder.descending,
  );
}

Future<void> updatePreference(...) async {
  await into(podcastViewPreferences).insertOnConflictUpdate(...);
}
```

## File Changes

**New Files:**

| Package | File | Purpose |
|---------|------|---------|
| `audiflow_domain` | `models/podcast_view_preference.dart` | Drift table |
| `audiflow_domain` | `datasources/local/podcast_view_preference_datasource.dart` | Drift queries |
| `audiflow_domain` | `repositories/podcast_view_preference_repository.dart` | Interface + impl |
| `audiflow_domain` | `providers/podcast_view_preference_providers.dart` | Riverpod providers |
| `audiflow_app` | `widgets/episode_sort_sheet.dart` | Sort bottom sheet UI |

**Modified Files:**

| File | Changes |
|------|---------|
| `database.dart` | Add table, increment schema version |
| `podcast_detail_screen.dart` | Sort icon in episodes view, wire preferences |
| `episode_filter_chips.dart` | Read from per-podcast preference |
| `season_view_toggle.dart` | Persist via preference controller |
| `podcast_detail_controller.dart` | Replace global filter, add cursor-based provider |
| `episode_local_datasource.dart` | Add cursor-paginated sorted query |

**Removed:**

- `episodeFilterStateProvider` (global) - replaced by per-podcast preference
