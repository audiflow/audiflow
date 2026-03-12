# Smart Playlist Schema v2 Migration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate all smart playlist models, services, UI, and tests from schema v1 to v2 (clean cut, no backward compatibility).

**Architecture:** Bottom-up migration: new models first, then update existing models, services, UI, and tests. Drift tables are drop-and-recreate (cache-only data). Config fields (sort, display settings) are NOT persisted -- they come from JSON config at runtime.

**Tech Stack:** Dart, Flutter, Drift, Riverpod, hand-written JSON serialization

---

### Task 1: Create feature branch and vendor v2 schema

**Files:**
- Replace: `packages/audiflow_domain/test/fixtures/schema.json`

**Step 1: Create the feature branch**

```bash
git checkout -b refactor/schema-v2-migration
```

**Step 2: Copy the v2 schema**

Copy `~/Documents/src/projects/audiflow/audiflow-smartplaylist-dev/schema/playlist-definition.schema.json` to `packages/audiflow_domain/test/fixtures/schema.json`.

Note: The vendored schema is the playlist-definition schema only (not the top-level config envelope). The conformance test wraps definitions in a config envelope for validation. The test's `_wrapInConfig` helper and `_loadSchema`/`jsonSchema` must be updated to validate against the playlist-definition schema directly (not the config envelope).

**Step 3: Commit**

```bash
git add packages/audiflow_domain/test/fixtures/schema.json
git commit -m "chore(domain): vendor v2 playlist-definition schema"
```

---

### Task 2: Create new model files for v2 nested objects

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/episode_filter_entry.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/models/episode_filters.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/models/group_list_config.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/models/episode_list_config.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/models/episode_sort_rule.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/models/group_display_config.dart`

**Step 1: Create EpisodeFilterEntry**

```dart
// episode_filter_entry.dart
/// A single filter condition matched against episode fields.
///
/// When multiple fields are specified, all must match (AND logic).
final class EpisodeFilterEntry {
  const EpisodeFilterEntry({this.title, this.description});

  factory EpisodeFilterEntry.fromJson(Map<String, dynamic> json) {
    return EpisodeFilterEntry(
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }

  /// Case-insensitive regex pattern matched against the episode title.
  final String? title;

  /// Case-insensitive regex pattern matched against the episode
  /// description.
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    };
  }
}
```

**Step 2: Create EpisodeFilters**

```dart
// episode_filters.dart
import 'episode_filter_entry.dart';

/// Episode filters applied before resolver processing.
final class EpisodeFilters {
  const EpisodeFilters({this.require, this.exclude});

  factory EpisodeFilters.fromJson(Map<String, dynamic> json) {
    return EpisodeFilters(
      require: (json['require'] as List<dynamic>?)
          ?.map((e) =>
              EpisodeFilterEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      exclude: (json['exclude'] as List<dynamic>?)
          ?.map((e) =>
              EpisodeFilterEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Inclusion filters. Episode must match ALL entries.
  final List<EpisodeFilterEntry>? require;

  /// Exclusion filters. Episode matching ANY entry is excluded.
  final List<EpisodeFilterEntry>? exclude;

  /// Whether any filters are defined.
  bool get hasFilters =>
      (require != null && require!.isNotEmpty) ||
      (exclude != null && exclude!.isNotEmpty);

  Map<String, dynamic> toJson() {
    return {
      if (require != null) 'require': require!.map((e) => e.toJson()).toList(),
      if (exclude != null) 'exclude': exclude!.map((e) => e.toJson()).toList(),
    };
  }
}
```

**Step 3: Create EpisodeSortRule**

```dart
// episode_sort_rule.dart
import 'smart_playlist_sort.dart';

/// Fields by which episodes can be sorted within a group.
enum EpisodeSortField {
  /// Sort by episode publication date.
  publishedAt,

  /// Sort by episode number.
  episodeNumber,

  /// Sort alphabetically by episode title.
  title,
}

/// Sort rule for ordering episodes within a group or playlist.
final class EpisodeSortRule {
  const EpisodeSortRule({required this.field, required this.order});

  factory EpisodeSortRule.fromJson(Map<String, dynamic> json) {
    return EpisodeSortRule(
      field: EpisodeSortField.values.byName(json['field'] as String),
      order: SortOrder.values.byName(json['order'] as String),
    );
  }

  final EpisodeSortField field;
  final SortOrder order;

  Map<String, dynamic> toJson() => {
    'field': field.name,
    'order': order.name,
  };
}
```

**Step 4: Create GroupListConfig**

```dart
// group_list_config.dart
import 'smart_playlist.dart';
import 'smart_playlist_sort.dart';

/// Settings for the group list view (only meaningful when
/// playlistStructure is 'grouped').
final class GroupListConfig {
  const GroupListConfig({
    this.yearBinding,
    this.userSortable,
    this.showDateRange,
    this.sort,
  });

  factory GroupListConfig.fromJson(Map<String, dynamic> json) {
    return GroupListConfig(
      yearBinding: json['yearBinding'] != null
          ? YearBinding.values.byName(json['yearBinding'] as String)
          : null,
      userSortable: json['userSortable'] as bool?,
      showDateRange: json['showDateRange'] as bool?,
      sort: json['sort'] != null
          ? SmartPlaylistSortRule.fromJson(
              json['sort'] as Map<String, dynamic>)
          : null,
    );
  }

  /// How groups relate to year headers.
  final YearBinding? yearBinding;

  /// Allow users to change the sort order at runtime.
  final bool? userSortable;

  /// Show date range and duration metadata on group cards.
  final bool? showDateRange;

  /// Sort rule for ordering groups.
  final SmartPlaylistSortRule? sort;

  Map<String, dynamic> toJson() {
    return {
      if (yearBinding != null) 'yearBinding': yearBinding!.name,
      if (userSortable != null) 'userSortable': userSortable,
      if (showDateRange != null) 'showDateRange': showDateRange,
      if (sort != null) 'sort': sort!.toJson(),
    };
  }
}
```

**Step 5: Create EpisodeListConfig**

```dart
// episode_list_config.dart
import 'episode_sort_rule.dart';
import 'smart_playlist_title_extractor.dart';

/// Default display and ordering settings for episode lists.
final class EpisodeListConfig {
  const EpisodeListConfig({
    this.showYearHeaders,
    this.sort,
    this.titleExtractor,
  });

  factory EpisodeListConfig.fromJson(Map<String, dynamic> json) {
    return EpisodeListConfig(
      showYearHeaders: json['showYearHeaders'] as bool?,
      sort: json['sort'] != null
          ? EpisodeSortRule.fromJson(
              json['sort'] as Map<String, dynamic>)
          : null,
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Show year separator headers within episode lists.
  final bool? showYearHeaders;

  /// Sort rule for ordering episodes within a group.
  final EpisodeSortRule? sort;

  /// Transform episode titles for display.
  final SmartPlaylistTitleExtractor? titleExtractor;

  Map<String, dynamic> toJson() {
    return {
      if (showYearHeaders != null) 'showYearHeaders': showYearHeaders,
      if (sort != null) 'sort': sort!.toJson(),
      if (titleExtractor != null) 'titleExtractor': titleExtractor!.toJson(),
    };
  }
}
```

**Step 6: Create GroupDisplayConfig**

```dart
// group_display_config.dart
import 'smart_playlist.dart';

/// Per-group display overrides for the group card.
final class GroupDisplayConfig {
  const GroupDisplayConfig({this.showDateRange, this.yearBinding});

  factory GroupDisplayConfig.fromJson(Map<String, dynamic> json) {
    return GroupDisplayConfig(
      showDateRange: json['showDateRange'] as bool?,
      yearBinding: json['yearBinding'] != null
          ? YearBinding.values.byName(json['yearBinding'] as String)
          : null,
    );
  }

  /// Override whether date range is shown on this group's card.
  final bool? showDateRange;

  /// Override the year binding mode for this group.
  final YearBinding? yearBinding;

  Map<String, dynamic> toJson() {
    return {
      if (showDateRange != null) 'showDateRange': showDateRange,
      if (yearBinding != null) 'yearBinding': yearBinding!.name,
    };
  }
}
```

**Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/episode_filter_entry.dart \
        packages/audiflow_domain/lib/src/features/feed/models/episode_filters.dart \
        packages/audiflow_domain/lib/src/features/feed/models/episode_sort_rule.dart \
        packages/audiflow_domain/lib/src/features/feed/models/group_list_config.dart \
        packages/audiflow_domain/lib/src/features/feed/models/episode_list_config.dart \
        packages/audiflow_domain/lib/src/features/feed/models/group_display_config.dart
git commit -m "feat(domain): add v2 schema model files"
```

---

### Task 3: Update enums and sort models

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_sort.dart`

**Step 1: Rename enums in smart_playlist.dart**

Replace `SmartPlaylistContentType` with `PlaylistStructure`:

```dart
/// Whether a smart playlist splits into separate playlists or
/// groups inside one playlist.
enum PlaylistStructure {
  /// Each resolver result becomes a separate top-level playlist.
  split,

  /// All resolver results are collected as groups inside a single
  /// parent playlist.
  grouped,
}
```

Replace `YearHeaderMode` with `YearBinding`:

```dart
/// How groups relate to year headers in the group list view.
enum YearBinding {
  /// No year headers.
  none,

  /// Each group appears once, placed under the year of its
  /// earliest episode.
  pinToYear,

  /// A group appears under each year it has episodes in.
  splitByYear,
}
```

Update `SmartPlaylistGroup`:
- `yearOverride` type: `YearHeaderMode?` -> `YearBinding?`
- `episodeYearHeaders` field -> remove (now in `EpisodeListConfig`)
- `showDateRange` field -> keep (resolved at runtime from config)
- `formattedDisplayName` parameter: `showSeasonNumber` -> `prependSeasonNumber`

Update `SmartPlaylist`:
- `contentType` -> `playlistStructure` (type: `PlaylistStructure`)
- `yearHeaderMode` -> `yearBinding` (type: `YearBinding`)
- `episodeYearHeaders` -> remove
- `showSortOrderToggle` -> `userSortable` (default: `true`)
- `showSeasonNumber` -> `prependSeasonNumber`
- `customSort: SmartPlaylistSortSpec?` -> `groupSort: SmartPlaylistSortRule?`
- Update `copyWith`, remove deprecated aliases
- `formattedDisplayName`: use `prependSeasonNumber`
- `yearGrouped` deprecated getter: use `yearBinding`

**Step 2: Simplify sort models in smart_playlist_sort.dart**

Remove:
- `SmartPlaylistSortSpec` class (replaced by single `SmartPlaylistSortRule`)
- `SmartPlaylistSortCondition` sealed class
- `SortKeyGreaterThan` class
- `SmartPlaylistSortField.progress` enum value

Keep:
- `SmartPlaylistSortField` enum (without `progress`)
- `SortOrder` enum
- `SmartPlaylistSortRule` class (without `condition` field)

Updated `SmartPlaylistSortRule`:

```dart
final class SmartPlaylistSortRule {
  const SmartPlaylistSortRule({
    required this.field,
    required this.order,
  });

  factory SmartPlaylistSortRule.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistSortRule(
      field: SmartPlaylistSortField.values.byName(
          json['field'] as String),
      order: SortOrder.values.byName(json['order'] as String),
    );
  }

  final SmartPlaylistSortField field;
  final SortOrder order;

  Map<String, dynamic> toJson() => {
    'field': field.name,
    'order': order.name,
  };
}
```

**Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlist.dart \
        packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_sort.dart
git commit -m "refactor(domain): rename enums and simplify sort models for v2"
```

---

### Task 4: Update SmartPlaylistDefinition for v2

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_definition.dart`

**Step 1: Rewrite SmartPlaylistDefinition**

Replace the entire class with v2 structure:

```dart
import 'episode_filters.dart';
import 'episode_list_config.dart';
import 'group_list_config.dart';
import 'smart_playlist_episode_extractor.dart';
import 'smart_playlist_group_def.dart';
import 'smart_playlist_title_extractor.dart';

/// Unified per-playlist definition with all fields strongly typed.
final class SmartPlaylistDefinition {
  const SmartPlaylistDefinition({
    required this.id,
    required this.displayName,
    required this.resolverType,
    this.priority = 0,
    this.playlistStructure,
    this.episodeFilters,
    this.nullSeasonGroupKey,
    this.titleExtractor,
    this.prependSeasonNumber = false,
    this.groupList,
    this.episodeList,
    this.episodeExtractor,
    this.groups,
  });

  factory SmartPlaylistDefinition.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistDefinition(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      resolverType: json['resolverType'] as String,
      priority: (json['priority'] as int?) ?? 0,
      playlistStructure: json['playlistStructure'] as String?,
      episodeFilters: json['episodeFilters'] != null
          ? EpisodeFilters.fromJson(
              json['episodeFilters'] as Map<String, dynamic>)
          : null,
      nullSeasonGroupKey: json['nullSeasonGroupKey'] as int?,
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>)
          : null,
      prependSeasonNumber:
          (json['prependSeasonNumber'] as bool?) ?? false,
      groupList: json['groupList'] != null
          ? GroupListConfig.fromJson(
              json['groupList'] as Map<String, dynamic>)
          : null,
      episodeList: json['episodeList'] != null
          ? EpisodeListConfig.fromJson(
              json['episodeList'] as Map<String, dynamic>)
          : null,
      episodeExtractor: json['episodeExtractor'] != null
          ? SmartPlaylistEpisodeExtractor.fromJson(
              json['episodeExtractor'] as Map<String, dynamic>)
          : null,
      groups: (json['groups'] as List<dynamic>?)
          ?.map((g) => SmartPlaylistGroupDef.fromJson(
              g as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String displayName;
  final String resolverType;
  final int priority;

  /// Playlist structure: "split" or "grouped".
  final String? playlistStructure;

  /// Episode filters applied before resolver processing.
  final EpisodeFilters? episodeFilters;

  final int? nullSeasonGroupKey;

  /// Configuration for extracting display names from episode data.
  final SmartPlaylistTitleExtractor? titleExtractor;

  /// Whether to prepend season number label to group titles.
  final bool prependSeasonNumber;

  /// Settings for the group list view (grouped mode only).
  final GroupListConfig? groupList;

  /// Default settings for episode lists within groups.
  final EpisodeListConfig? episodeList;

  /// Configuration for extracting season/episode numbers.
  final SmartPlaylistEpisodeExtractor? episodeExtractor;

  /// Static group definitions for category-based grouping.
  final List<SmartPlaylistGroupDef>? groups;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'resolverType': resolverType,
      if (priority != 0) 'priority': priority,
      if (playlistStructure != null)
        'playlistStructure': playlistStructure,
      if (episodeFilters != null)
        'episodeFilters': episodeFilters!.toJson(),
      if (nullSeasonGroupKey != null)
        'nullSeasonGroupKey': nullSeasonGroupKey,
      if (titleExtractor != null)
        'titleExtractor': titleExtractor!.toJson(),
      if (prependSeasonNumber) 'prependSeasonNumber': prependSeasonNumber,
      if (groupList != null) 'groupList': groupList!.toJson(),
      if (episodeList != null) 'episodeList': episodeList!.toJson(),
      if (episodeExtractor != null)
        'episodeExtractor': episodeExtractor!.toJson(),
      if (groups != null)
        'groups': groups!.map((g) => g.toJson()).toList(),
    };
  }
}
```

**Step 2: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_definition.dart
git commit -m "refactor(domain): update SmartPlaylistDefinition to v2 schema"
```

---

### Task 5: Update SmartPlaylistGroupDef for v2

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_def.dart`

**Step 1: Rewrite SmartPlaylistGroupDef**

```dart
import 'episode_list_config.dart';
import 'group_display_config.dart';
import 'smart_playlist_episode_extractor.dart';

/// Static group definition within a playlist.
final class SmartPlaylistGroupDef {
  const SmartPlaylistGroupDef({
    required this.id,
    required this.displayName,
    this.pattern,
    this.display,
    this.episodeList,
    this.episodeExtractor,
  });

  factory SmartPlaylistGroupDef.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistGroupDef(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      pattern: json['pattern'] as String?,
      display: json['display'] != null
          ? GroupDisplayConfig.fromJson(
              json['display'] as Map<String, dynamic>)
          : null,
      episodeList: json['episodeList'] != null
          ? EpisodeListConfig.fromJson(
              json['episodeList'] as Map<String, dynamic>)
          : null,
      episodeExtractor: json['episodeExtractor'] != null
          ? SmartPlaylistEpisodeExtractor.fromJson(
              json['episodeExtractor'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String displayName;

  /// Regex pattern to match episode titles. Null = catch-all.
  final String? pattern;

  /// Per-group display overrides for the group card.
  final GroupDisplayConfig? display;

  /// Per-group override for episode list settings.
  final EpisodeListConfig? episodeList;

  /// Per-group override for episode number extraction.
  final SmartPlaylistEpisodeExtractor? episodeExtractor;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      if (pattern != null) 'pattern': pattern,
      if (display != null) 'display': display!.toJson(),
      if (episodeList != null) 'episodeList': episodeList!.toJson(),
      if (episodeExtractor != null)
        'episodeExtractor': episodeExtractor!.toJson(),
    };
  }
}
```

**Step 2: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_def.dart
git commit -m "refactor(domain): update SmartPlaylistGroupDef to v2 schema"
```

---

### Task 6: Update exports

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

**Step 1: Add new exports, keep existing ones**

Add these exports:

```dart
export 'src/features/feed/models/episode_filter_entry.dart';
export 'src/features/feed/models/episode_filters.dart';
export 'src/features/feed/models/episode_list_config.dart';
export 'src/features/feed/models/episode_sort_rule.dart';
export 'src/features/feed/models/group_display_config.dart';
export 'src/features/feed/models/group_list_config.dart';
```

**Step 2: Commit**

```bash
git add packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "chore(domain): export v2 model files"
```

---

### Task 7: Update Drift tables

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlists.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_groups.dart`
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart` (add migration step)

**Step 1: Update SmartPlaylists table**

In `smart_playlists.dart`:
- Rename `contentType` column to `playlistStructure` with default `'split'`
- Keep `yearHeaderMode` column as-is (still persisted, but values change: `none`, `pinToYear`, `splitByYear`)
- Remove `episodeYearHeaders` column

Note: Rename column doc comments but keep `yearHeaderMode` column name for now (column name only matters in SQL). The column stores `YearBinding.name` values (`none`, `pinToYear`, `splitByYear`).

**Step 2: Update SmartPlaylistGroups table**

In `smart_playlist_groups.dart`:
- Remove `episodeYearHeaders` column

**Step 3: Add Drift migration step**

In `app_database.dart`, add a migration step that drops and recreates the `seasons` (SmartPlaylists) and `smart_playlist_groups` tables. These are cache-only and will be rebuilt on next sync.

Find the `schemaVersion` getter and increment it. In the `migration` getter, add the new version step.

**Step 4: Run Drift code generation**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlists.dart \
        packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_groups.dart \
        packages/audiflow_domain/lib/src/common/database/app_database.dart \
        packages/audiflow_domain/lib/src/common/database/app_database.g.dart
git commit -m "refactor(domain): update Drift tables for v2 schema"
```

---

### Task 8: Update resolver service and resolvers

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/smart_playlist_resolver_service.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/rss_metadata_resolver.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/category_resolver.dart`

**Step 1: Update parse helpers in resolvers**

In `rss_metadata_resolver.dart`, rename and update the static parse methods:

```dart
static PlaylistStructure parsePlaylistStructure(String? value) {
  return switch (value) {
    'grouped' => PlaylistStructure.grouped,
    _ => PlaylistStructure.split,
  };
}

static YearBinding parseYearBinding(String? value) {
  return switch (value) {
    'pinToYear' => YearBinding.pinToYear,
    'splitByYear' => YearBinding.splitByYear,
    _ => YearBinding.none,
  };
}
```

Remove `parseContentType` and `parseYearHeaderMode`. Do the same in `category_resolver.dart`.

Update `defaultSort` in resolvers: change type from `SmartPlaylistSortSpec` to `SmartPlaylistSortRule`.

**Step 2: Update SmartPlaylistResolverService**

In `_resolveWithConfig`:
- `definition.contentType` -> `definition.playlistStructure`
- `RssMetadataResolver.parseContentType(...)` -> `RssMetadataResolver.parsePlaylistStructure(...)`
- `RssMetadataResolver.parseYearHeaderMode(...)` -> `RssMetadataResolver.parseYearBinding(...)`
- When reading `yearHeaderMode`, read from `definition.groupList?.yearBinding`
- `contentType == SmartPlaylistContentType.groups` -> `playlistStructure == PlaylistStructure.grouped`
- Update SmartPlaylistGroup construction: remove `episodeYearHeaders`, read `showDateRange` from `gDef?.display?.showDateRange ?? definition.groupList?.showDateRange ?? false`
- Update SmartPlaylist construction with new field names

In `_filterEpisodes`:
- Replace `titleFilter`/`excludeFilter`/`requireFilter` with `definition.episodeFilters`
- Implement array-based filtering: AND all `require` entries, reject if ANY `exclude` entry matches

In `_hasFilters`:
- Replace with `definition.episodeFilters?.hasFilters ?? false`

**Step 3: Update SmartPlaylistResolver interface**

Check if `SmartPlaylistResolver` abstract class references `SmartPlaylistSortSpec`. If so, update `defaultSort` to `SmartPlaylistSortRule`.

**Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/smart_playlist_resolver_service.dart \
        packages/audiflow_domain/lib/src/features/feed/resolvers/rss_metadata_resolver.dart \
        packages/audiflow_domain/lib/src/features/feed/resolvers/category_resolver.dart
git commit -m "refactor(domain): update resolver service for v2 schema"
```

---

### Task 9: Update smart_playlist_providers.dart

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/providers/smart_playlist_providers.dart`

**Step 1: Update _buildGroupingFromCache**

- `RssMetadataResolver.parseYearHeaderMode(...)` -> `RssMetadataResolver.parseYearBinding(...)`
- `yearHeaderMode:` -> `yearBinding:`

**Step 2: Update _enrichPlaylist**

- `playlist.yearHeaderMode != YearHeaderMode.none` -> `playlist.yearBinding != YearBinding.none`
- `yearHeaderMode: Value(playlist.yearHeaderMode.name)` -> update to use `yearBinding`
- Update `SmartPlaylistsCompanion.insert(...)` to use `playlistStructure` instead of `contentType`
- Remove `episodeYearHeaders` from group companion

**Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/providers/smart_playlist_providers.dart
git commit -m "refactor(domain): update smart playlist providers for v2"
```

---

### Task 10: Update UI layer

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/inline_playlist_section.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/inline_group_card.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/utils/group_sorting.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart`

**Step 1: Update inline_playlist_section.dart**

- Import: `SmartPlaylistContentType` -> `PlaylistStructure`, `YearHeaderMode` -> `YearBinding`
- `playlist.contentType == SmartPlaylistContentType.groups` -> `playlist.playlistStructure == PlaylistStructure.grouped`
- `playlist.yearHeaderMode != YearHeaderMode.none` -> `playlist.yearBinding != YearBinding.none`
- `playlist.showSortOrderToggle` -> `playlist.userSortable`
- `playlist.customSort` -> `playlist.groupSort`
- `playlist.showSeasonNumber` -> `playlist.prependSeasonNumber`
- `playlist.yearHeaderMode == YearHeaderMode.none` -> `playlist.yearBinding == YearBinding.none`
- `playlist.yearHeaderMode == YearHeaderMode.perEpisode` -> `playlist.yearBinding == YearBinding.splitByYear`

**Step 2: Update inline_group_card.dart**

- `showSeasonNumber` parameter -> `prependSeasonNumber`
- `group.formattedDisplayName(showSeasonNumber: showSeasonNumber)` -> `group.formattedDisplayName(prependSeasonNumber: prependSeasonNumber)`

**Step 3: Update group_sorting.dart**

Simplify to work with single `SmartPlaylistSortRule` instead of `SmartPlaylistSortSpec`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart'
    show
        SmartPlaylistGroup,
        SmartPlaylistSortField,
        SmartPlaylistSortRule,
        SortOrder;

/// Sorts groups using the playlist's [groupSort] rule and
/// the user's [sortOrder] toggle.
List<SmartPlaylistGroup> sortGroupsBySort(
  List<SmartPlaylistGroup> groups,
  SmartPlaylistSortRule? groupSort,
  SortOrder sortOrder,
) {
  final sorted = List<SmartPlaylistGroup>.from(groups);

  if (groupSort == null) {
    sorted.sort((a, b) {
      final cmp = a.sortKey.compareTo(b.sortKey);
      return sortOrder == SortOrder.ascending ? cmp : -cmp;
    });
    return sorted;
  }

  final invert = sortOrder != groupSort.order;

  sorted.sort((a, b) {
    final cmp = compareGroupsByField(a, b, groupSort.field);
    if (cmp != 0) {
      final directed =
          groupSort.order == SortOrder.ascending ? cmp : -cmp;
      return invert ? -directed : directed;
    }
    return 0;
  });
  return sorted;
}
```

Remove `matchesGroupCondition` function. Update `compareGroupsByField` to remove `progress` case.

**Step 4: Update podcast_detail_controller.dart**

- `_parseFeedContentType` -> `_parseFeedPlaylistStructure`, return `PlaylistStructure`, values: `'grouped'` -> `.grouped`, default `.split`
- `_parseFeedYearHeaderMode` -> `_parseFeedYearBinding`, return `YearBinding`, values: `'pinToYear'` -> `.pinToYear`, `'splitByYear'` -> `.splitByYear`, default `.none`
- Update all `SmartPlaylist(...)` constructors with new field names
- `definition.contentType` -> `definition.playlistStructure`
- `definition.yearHeaderMode` -> `definition.groupList?.yearBinding` (as String for parsing)
- `definition.episodeYearHeaders` -> remove
- `definition.showDateRange` -> `definition.groupList?.showDateRange ?? false`
- `definition.showSortOrderToggle` -> `definition.groupList?.userSortable ?? true`
- `definition.customSort` -> `definition.groupList?.sort`
- `customSort.rules` -> single sort rule logic

**Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/inline_playlist_section.dart \
        packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/inline_group_card.dart \
        packages/audiflow_app/lib/features/podcast_detail/presentation/utils/group_sorting.dart \
        packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart
git commit -m "refactor(ui): update podcast detail UI for v2 schema"
```

---

### Task 11: Update schema conformance tests

**Files:**
- Modify: `packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart`

**Step 1: Rewrite conformance tests for v2 schema**

The vendored schema is now the playlist-definition schema (not the config envelope). Update the test infrastructure:

- Remove `_wrapInConfig` helper -- validate definitions directly against the playlist-definition schema
- Update all test data to use v2 field names and values
- Update enum conformance tests to match v2 `$defs`

Key test cases to update:

**Minimal definition test:**
```dart
test('minimal SmartPlaylistDefinition round-trips', () {
  const def = SmartPlaylistDefinition(
    id: 'main',
    displayName: 'Main Episodes',
    resolverType: 'rss',
    playlistStructure: 'split',
  );
  expect(validate(def.toJson()), isEmpty);
});
```

**Full definition test:** Use all v2 fields including nested `groupList`, `episodeList`, `episodeFilters`, `episodeExtractor`.

**Enum conformance tests:**
- `playlistStructure` values: `split`, `grouped`
- `YearBinding` values: `none`, `pinToYear`, `splitByYear`
- `SortRule.field` values: `playlistNumber`, `newestEpisodeDate`, `alphabetical`
- `EpisodeSortRule.field` values: `publishedAt`, `episodeNumber`, `title`
- `SortOrder` values: `ascending`, `descending`
- Remove: `contentTypes`, `yearHeaderModes`, `sortConditionTypes` tests
- Add: `YearBinding`, `EpisodeSortRule` tests

**Schema version test:**
```dart
test(r'schema has $id', () {
  expect(
    schema[r'$id'],
    equals('https://audiflow.app/schema/v2/playlist-definition.json'),
  );
});
```

**Step 2: Commit**

```bash
git add packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart
git commit -m "test(domain): update schema conformance tests for v2"
```

---

### Task 12: Update remaining tests

**Files:**
- Modify: `packages/audiflow_domain/test/features/feed/models/smart_playlist_definition_test.dart`
- Modify: `packages/audiflow_domain/test/features/feed/models/smart_playlist_sort_test.dart`
- Modify: `packages/audiflow_domain/test/features/feed/models/smart_playlist_sort_json_test.dart`
- Modify: `packages/audiflow_app/test/features/podcast_detail/presentation/utils/group_sorting_test.dart` (if exists)
- Modify: `packages/audiflow_domain/test/features/feed/models/smart_playlist_year_grouped_test.dart`

**Step 1: Update smart_playlist_definition_test.dart**

- Replace all v1 field names with v2 equivalents
- `titleFilter`, `excludeFilter` -> `episodeFilters`
- `customSort: SmartPlaylistSortSpec(...)` -> `groupList: GroupListConfig(sort: SmartPlaylistSortRule(...))`
- `smartPlaylistEpisodeExtractor` -> `episodeExtractor`
- `showSortOrderToggle` -> `groupList.userSortable`
- `contentType` -> `playlistStructure`
- `episodeYearHeaders` -> `episodeList: EpisodeListConfig(showYearHeaders: true)`

**Step 2: Update smart_playlist_sort_test.dart**

- Remove `SmartPlaylistSortField.progress` from `all enum values exist` test
- Remove `SmartPlaylistSortSpec` tests (class no longer exists)
- Keep/update `SortOrder` and `SmartPlaylistSortField` tests

**Step 3: Update smart_playlist_sort_json_test.dart**

- Remove all `SmartPlaylistSortSpec` round-trip tests
- Remove legacy format migration tests
- Replace with `SmartPlaylistSortRule` round-trip tests
- Remove `SmartPlaylistSortCondition` tests

**Step 4: Update smart_playlist_year_grouped_test.dart**

- `parseYearHeaderMode` -> `parseYearBinding`
- `YearHeaderMode` -> `YearBinding`
- Update test values: `firstEpisode` -> `pinToYear`, `perEpisode` -> `splitByYear`

**Step 5: Update group_sorting_test.dart (if exists)**

- `sortGroupsByCustomSort` -> `sortGroupsBySort`
- `SmartPlaylistSortSpec` -> `SmartPlaylistSortRule`
- Remove condition-related test cases
- Remove `progress` sort field tests

**Step 6: Update CLI test fixture (if needed)**

Check `packages/audiflow_cli/test/fixtures/smart_playlist_patterns.json` and update to v2 format if tests reference it.

**Step 7: Commit**

```bash
git add -A packages/audiflow_domain/test/ packages/audiflow_app/test/
git commit -m "test: update all tests for v2 schema migration"
```

---

### Task 13: Fix compilation and run full test suite

**Step 1: Search for any remaining v1 references**

Search the codebase for any remaining references to removed/renamed symbols:
- `SmartPlaylistContentType`
- `YearHeaderMode`
- `SmartPlaylistSortSpec`
- `SmartPlaylistSortCondition`
- `SortKeyGreaterThan`
- `titleFilter` (in definition context)
- `excludeFilter`
- `requireFilter`
- `showSeasonNumber` (in definition/playlist context)
- `showSortOrderToggle`
- `smartPlaylistEpisodeExtractor`
- `customSort`
- `episodeYearHeaders` (in definition/group context)
- `contentType` (in smart playlist context)
- `parseContentType`
- `parseYearHeaderMode`

Fix any remaining references.

**Step 2: Run Dart analysis**

```bash
cd packages/audiflow_domain && flutter analyze
cd packages/audiflow_app && flutter analyze
```

Fix any analysis errors until clean.

**Step 3: Run tests**

```bash
flutter test packages/audiflow_domain
flutter test packages/audiflow_app
```

Fix any test failures.

**Step 4: Run schema conformance tests specifically**

```bash
flutter test packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart
```

All tests must pass.

**Step 5: Commit any fixes**

```bash
git add -A
git commit -m "fix: resolve remaining v1 references after v2 migration"
```

---

### Task 14: Update CLAUDE.md and memory

**Files:**
- Modify: `CLAUDE.md` (update Smart Playlist Schema Conformance section)

**Step 1: Update CLAUDE.md**

Update the "Smart Playlist Schema Conformance" section:
- Update valid enum values to v2 names
- Update test data rules to match v2 field names
- Note the schema version is now v2

Specifically update:
- "Resolver types" stays the same: `'rss'`, `'category'`, `'year'`, `'titleAppearanceOrder'`
- "Content types" -> "Playlist structures": `'split'`, `'grouped'`
- "Sort fields" -> remove `progress`: `SmartPlaylistSortField` enum names
- "Sort orders" stays the same: `'ascending'`, `'descending'`
- Remove sort condition types
- Add year binding values: `'none'`, `'pinToYear'`, `'splitByYear'`
- Add episode sort fields: `'publishedAt'`, `'episodeNumber'`, `'title'`

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md for v2 schema"
```
