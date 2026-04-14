# Schema v5 Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adopt upstream smartplaylist schema v5 — restructure flat `SmartPlaylistDefinition` into pipeline-oriented nested config objects (filter -> group -> select -> display), update `GroupDef` to v5 field names, and update all consumers.

**Architecture:** The flat definition model is decomposed into: `GroupingConfig` (by, discoveryHint, numberingExtractor, staticClassifiers), `SelectorConfig` (partitionBy, titleExtractor), `GroupListingConfig` (yearBinding, sort, userSortable), `GroupItemConfig` (showDateRange, pinToYear, prependSeasonNumber, titleExtractor), `EpisodeListingConfig` (sort, showYearHeaders), `EpisodeItemConfig` (titleExtractor). The `Presentation` enum is removed — selector presence/absence replaces it. `GroupDef` per-group overrides also use v5 names (groupListing, groupItem, episodeListing, episodeItem). `priority` returns as a required field.

**Tech Stack:** Dart, Flutter, Isar, Riverpod

---

## File Map

### Create
- `packages/audiflow_domain/lib/src/features/feed/models/grouping_config.dart` — `GroupingConfig` class
- `packages/audiflow_domain/lib/src/features/feed/models/selector_config.dart` — `SelectorConfig` class
- `packages/audiflow_domain/lib/src/features/feed/models/group_listing_config.dart` — `GroupListingConfig` class (replaces `GroupListConfig`)
- `packages/audiflow_domain/lib/src/features/feed/models/group_item_config.dart` — `GroupItemConfig` class (replaces `GroupDisplayConfig` + absorbs top-level fields)
- `packages/audiflow_domain/lib/src/features/feed/models/episode_listing_config.dart` — `EpisodeListingConfig` class (replaces `EpisodeListConfig` minus titleExtractor)
- `packages/audiflow_domain/lib/src/features/feed/models/episode_item_config.dart` — `EpisodeItemConfig` class

### Delete (after migration)
- `packages/audiflow_domain/lib/src/features/feed/models/group_list_config.dart`
- `packages/audiflow_domain/lib/src/features/feed/models/group_display_config.dart`
- `packages/audiflow_domain/lib/src/features/feed/models/episode_list_config.dart`

### Modify
- `smart_playlist_definition.dart` — restructure to v5 fields
- `smart_playlist_group_def.dart` — replace `display`/`episodeList` with `groupListing`/`groupItem`/`episodeListing`/`episodeItem`
- `smart_playlist.dart` — remove `Presentation` enum; replace `presentation` field with `hasSelector` or selector-based approach
- `smart_playlist_resolver_service.dart` — read from v5 nested config objects
- `episode_extractor_resolver.dart` — read `grouping.numberingExtractor` and `grouping.staticClassifiers`
- `smart_playlist_providers.dart` — update field access paths
- `title_discovery_resolver.dart` — read `grouping.discoveryHint` instead of `groups[0].pattern`
- `title_classifier_resolver.dart` — read `grouping.staticClassifiers` instead of `groups`
- `season_number_resolver.dart` — read `groupItem.titleExtractor` instead of `titleExtractor`
- `audiflow_domain.dart` / `patterns.dart` — update exports
- App-level widgets (`inline_playlist_section.dart`, `smart_playlist_episodes_screen.dart`)
- Schema conformance test and all model/resolver/service tests

---

### Task 1: Copy vendored v5 schemas

**Files:**
- Modify: `packages/audiflow_domain/test/fixtures/playlist-definition.schema.json`
- Modify: `packages/audiflow_domain/test/fixtures/pattern-index.schema.json`
- Modify: `packages/audiflow_domain/test/fixtures/pattern-meta.schema.json`

- [ ] **Step 1: Copy v5 schemas from the editor repo**

```bash
cp /Users/tohru/Documents/src/ghq/github.com/audiflow/audiflow-smartplaylist-editor/crates/sp_core/assets/playlist-definition.schema.json \
   packages/audiflow_domain/test/fixtures/playlist-definition.schema.json

cp /Users/tohru/Documents/src/ghq/github.com/audiflow/audiflow-smartplaylist-editor/crates/sp_core/assets/pattern-index.schema.json \
   packages/audiflow_domain/test/fixtures/pattern-index.schema.json

cp /Users/tohru/Documents/src/ghq/github.com/audiflow/audiflow-smartplaylist-editor/crates/sp_core/assets/pattern-meta.schema.json \
   packages/audiflow_domain/test/fixtures/pattern-meta.schema.json
```

- [ ] **Step 2: Verify the playlist-definition schema is v5**

```bash
grep '"$id"' packages/audiflow_domain/test/fixtures/playlist-definition.schema.json
```

Expected: `https://audiflow.app/schema/v5/playlist-definition.json`

Note: pattern-index and pattern-meta schemas may still say v4 in their $id — that's correct if upstream hasn't bumped those.

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/test/fixtures/*.schema.json
git commit -m "chore(domain): vendor v5 smartplaylist schemas"
```

---

### Task 2: Create new v5 config model classes

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/grouping_config.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/models/selector_config.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/models/group_listing_config.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/models/group_item_config.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/models/episode_listing_config.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/models/episode_item_config.dart`

- [ ] **Step 1: Create GroupingConfig**

```dart
// grouping_config.dart
import 'numbering_extractor.dart';
import 'smart_playlist_group_def.dart';

/// Defines how episodes are organized into groups.
final class GroupingConfig {
  const GroupingConfig({
    required this.by,
    this.discoveryHint,
    this.numberingExtractor,
    this.staticClassifiers,
  });

  factory GroupingConfig.fromJson(Map<String, dynamic> json) {
    return GroupingConfig(
      by: json['by'] as String,
      discoveryHint: json['discoveryHint'] as String?,
      numberingExtractor: json['numberingExtractor'] != null
          ? NumberingExtractor.fromJson(
              json['numberingExtractor'] as Map<String, dynamic>,
            )
          : null,
      staticClassifiers: (json['staticClassifiers'] as List<dynamic>?)
          ?.map(
            (g) => SmartPlaylistGroupDef.fromJson(g as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Grouping strategy: seasonNumber, year, titleDiscovery, titleClassifier.
  final String by;

  /// Regex pattern for titleDiscovery fallback.
  final String? discoveryHint;

  /// Parses season/episode numbers from titles.
  final NumberingExtractor? numberingExtractor;

  /// Group definitions for titleClassifier.
  final List<SmartPlaylistGroupDef>? staticClassifiers;

  Map<String, dynamic> toJson() {
    return {
      'by': by,
      if (discoveryHint != null) 'discoveryHint': discoveryHint,
      if (numberingExtractor != null)
        'numberingExtractor': numberingExtractor!.toJson(),
      if (staticClassifiers != null)
        'staticClassifiers':
            staticClassifiers!.map((g) => g.toJson()).toList(),
    };
  }
}
```

- [ ] **Step 2: Create SelectorConfig**

```dart
// selector_config.dart
import 'smart_playlist_title_extractor.dart';

/// Controls how resolver groups map to selector dropdown entries.
final class SelectorConfig {
  const SelectorConfig({this.partitionBy, this.titleExtractor});

  factory SelectorConfig.fromJson(Map<String, dynamic> json) {
    return SelectorConfig(
      partitionBy: json['partitionBy'] as String?,
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// How to partition groups: group, seasonNumber, year.
  final String? partitionBy;

  /// Names for partitioned selector entries.
  final SmartPlaylistTitleExtractor? titleExtractor;

  Map<String, dynamic> toJson() {
    return {
      if (partitionBy != null) 'partitionBy': partitionBy,
      if (titleExtractor != null) 'titleExtractor': titleExtractor!.toJson(),
    };
  }
}
```

- [ ] **Step 3: Create GroupListingConfig**

```dart
// group_listing_config.dart
import 'smart_playlist.dart';
import 'smart_playlist_sort.dart';

/// How the group list is arranged.
final class GroupListingConfig {
  const GroupListingConfig({this.yearBinding, this.sort, this.userSortable});

  factory GroupListingConfig.fromJson(Map<String, dynamic> json) {
    return GroupListingConfig(
      yearBinding: json['yearBinding'] != null
          ? YearBinding.fromString(json['yearBinding'] as String)
          : null,
      sort: json['sort'] != null
          ? SmartPlaylistSortRule.fromJson(json['sort'] as Map<String, dynamic>)
          : null,
      userSortable: json['userSortable'] as bool?,
    );
  }

  /// How groups relate to year sections.
  final YearBinding? yearBinding;

  /// Sort rule for ordering groups.
  final SmartPlaylistSortRule? sort;

  /// Allow users to flip sort order at runtime.
  final bool? userSortable;

  Map<String, dynamic> toJson() {
    return {
      if (yearBinding != null) 'yearBinding': yearBinding!.name,
      if (sort != null) 'sort': sort!.toJson(),
      if (userSortable != null) 'userSortable': userSortable,
    };
  }
}
```

- [ ] **Step 4: Create GroupItemConfig**

```dart
// group_item_config.dart
import 'smart_playlist_title_extractor.dart';

/// Defaults for individual group card display.
final class GroupItemConfig {
  const GroupItemConfig({
    this.showDateRange,
    this.pinToYear,
    this.prependSeasonNumber,
    this.titleExtractor,
  });

  factory GroupItemConfig.fromJson(Map<String, dynamic> json) {
    return GroupItemConfig(
      showDateRange: json['showDateRange'] as bool?,
      pinToYear: json['pinToYear'] as bool?,
      prependSeasonNumber: json['prependSeasonNumber'] as bool?,
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Show date range on group card.
  final bool? showDateRange;

  /// Pin group to its earliest year's section.
  final bool? pinToYear;

  /// Prefix group title with season number (e.g. "S13").
  final bool? prependSeasonNumber;

  /// Generates group display names from episode data.
  final SmartPlaylistTitleExtractor? titleExtractor;

  Map<String, dynamic> toJson() {
    return {
      if (showDateRange != null) 'showDateRange': showDateRange,
      if (pinToYear != null) 'pinToYear': pinToYear,
      if (prependSeasonNumber != null)
        'prependSeasonNumber': prependSeasonNumber,
      if (titleExtractor != null) 'titleExtractor': titleExtractor!.toJson(),
    };
  }
}
```

- [ ] **Step 5: Create EpisodeListingConfig**

```dart
// episode_listing_config.dart
import 'episode_sort_rule.dart';

/// How episodes are arranged within groups.
final class EpisodeListingConfig {
  const EpisodeListingConfig({this.sort, this.showYearHeaders});

  factory EpisodeListingConfig.fromJson(Map<String, dynamic> json) {
    return EpisodeListingConfig(
      sort: json['sort'] != null
          ? EpisodeSortRule.fromJson(json['sort'] as Map<String, dynamic>)
          : null,
      showYearHeaders: json['showYearHeaders'] as bool?,
    );
  }

  /// Sort rule for ordering episodes within a group.
  final EpisodeSortRule? sort;

  /// Show year dividers in episode list.
  final bool? showYearHeaders;

  Map<String, dynamic> toJson() {
    return {
      if (sort != null) 'sort': sort!.toJson(),
      if (showYearHeaders != null) 'showYearHeaders': showYearHeaders,
    };
  }
}
```

- [ ] **Step 6: Create EpisodeItemConfig**

```dart
// episode_item_config.dart
import 'smart_playlist_title_extractor.dart';

/// Defaults for individual episode row display.
final class EpisodeItemConfig {
  const EpisodeItemConfig({this.titleExtractor});

  factory EpisodeItemConfig.fromJson(Map<String, dynamic> json) {
    return EpisodeItemConfig(
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Transforms episode display names.
  final SmartPlaylistTitleExtractor? titleExtractor;

  Map<String, dynamic> toJson() {
    return {
      if (titleExtractor != null) 'titleExtractor': titleExtractor!.toJson(),
    };
  }
}
```

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/grouping_config.dart \
       packages/audiflow_domain/lib/src/features/feed/models/selector_config.dart \
       packages/audiflow_domain/lib/src/features/feed/models/group_listing_config.dart \
       packages/audiflow_domain/lib/src/features/feed/models/group_item_config.dart \
       packages/audiflow_domain/lib/src/features/feed/models/episode_listing_config.dart \
       packages/audiflow_domain/lib/src/features/feed/models/episode_item_config.dart
git commit -m "feat(domain): add v5 config model classes"
```

---

### Task 3: Update SmartPlaylistGroupDef to v5 field names

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_def.dart`

- [ ] **Step 1: Replace display/episodeList with v5 nested config fields**

The v5 GroupDef has: `groupListing` (yearBinding), `groupItem` (showDateRange), `episodeListing` (showYearHeaders, sort), `episodeItem` (titleExtractor), `numberingExtractor`.

Replace the entire file content:

```dart
import 'episode_item_config.dart';
import 'episode_listing_config.dart';
import 'group_item_config.dart';
import 'group_listing_config.dart';
import 'numbering_extractor.dart';

/// Static group definition within a playlist (a.k.a. static classifier).
final class SmartPlaylistGroupDef {
  const SmartPlaylistGroupDef({
    required this.id,
    required this.displayName,
    this.pattern,
    this.groupListing,
    this.groupItem,
    this.episodeListing,
    this.episodeItem,
    this.numberingExtractor,
  });

  factory SmartPlaylistGroupDef.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistGroupDef(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      pattern: json['pattern'] as String?,
      groupListing: json['groupListing'] != null
          ? GroupListingConfig.fromJson(
              json['groupListing'] as Map<String, dynamic>,
            )
          : null,
      groupItem: json['groupItem'] != null
          ? GroupItemConfig.fromJson(
              json['groupItem'] as Map<String, dynamic>,
            )
          : null,
      episodeListing: json['episodeListing'] != null
          ? EpisodeListingConfig.fromJson(
              json['episodeListing'] as Map<String, dynamic>,
            )
          : null,
      episodeItem: json['episodeItem'] != null
          ? EpisodeItemConfig.fromJson(
              json['episodeItem'] as Map<String, dynamic>,
            )
          : null,
      numberingExtractor: json['numberingExtractor'] != null
          ? NumberingExtractor.fromJson(
              json['numberingExtractor'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String id;
  final String displayName;

  /// Regex pattern to match episode titles. Null = catch-all.
  final String? pattern;

  /// Per-group overrides for the group list.
  final GroupListingConfig? groupListing;

  /// Per-group overrides for the group card.
  final GroupItemConfig? groupItem;

  /// Per-group overrides for episode list arrangement.
  final EpisodeListingConfig? episodeListing;

  /// Per-group overrides for episode row display.
  final EpisodeItemConfig? episodeItem;

  /// Per-group override for episode number extraction.
  final NumberingExtractor? numberingExtractor;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      if (pattern != null) 'pattern': pattern,
      if (groupListing != null) 'groupListing': groupListing!.toJson(),
      if (groupItem != null) 'groupItem': groupItem!.toJson(),
      if (episodeListing != null) 'episodeListing': episodeListing!.toJson(),
      if (episodeItem != null) 'episodeItem': episodeItem!.toJson(),
      if (numberingExtractor != null)
        'numberingExtractor': numberingExtractor!.toJson(),
    };
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_def.dart
git commit -m "refactor(domain): update SmartPlaylistGroupDef to v5 field names"
```

---

### Task 4: Restructure SmartPlaylistDefinition to v5

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_definition.dart`

- [ ] **Step 1: Replace with v5 structure**

v5 required fields: `id`, `displayName`, `grouping`, `priority`.
v5 optional fields: `selector`, `groupListing`, `groupItem`, `episodeListing`, `episodeItem`, `episodeFilters`.

Replace the entire file:

```dart
import 'episode_filters.dart';
import 'episode_item_config.dart';
import 'episode_listing_config.dart';
import 'group_item_config.dart';
import 'group_listing_config.dart';
import 'grouping_config.dart';
import 'selector_config.dart';

/// Unified per-playlist definition with all fields strongly typed.
///
/// Follows the v5 pipeline: filter -> group -> select -> display.
final class SmartPlaylistDefinition {
  const SmartPlaylistDefinition({
    required this.id,
    required this.displayName,
    required this.grouping,
    required this.priority,
    this.selector,
    this.groupListing,
    this.groupItem,
    this.episodeListing,
    this.episodeItem,
    this.episodeFilters,
  });

  factory SmartPlaylistDefinition.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistDefinition(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      grouping: GroupingConfig.fromJson(
        json['grouping'] as Map<String, dynamic>,
      ),
      priority: json['priority'] as int,
      selector: json['selector'] != null
          ? SelectorConfig.fromJson(
              json['selector'] as Map<String, dynamic>,
            )
          : null,
      groupListing: json['groupListing'] != null
          ? GroupListingConfig.fromJson(
              json['groupListing'] as Map<String, dynamic>,
            )
          : null,
      groupItem: json['groupItem'] != null
          ? GroupItemConfig.fromJson(
              json['groupItem'] as Map<String, dynamic>,
            )
          : null,
      episodeListing: json['episodeListing'] != null
          ? EpisodeListingConfig.fromJson(
              json['episodeListing'] as Map<String, dynamic>,
            )
          : null,
      episodeItem: json['episodeItem'] != null
          ? EpisodeItemConfig.fromJson(
              json['episodeItem'] as Map<String, dynamic>,
            )
          : null,
      episodeFilters: json['episodeFilters'] != null
          ? EpisodeFilters.fromJson(
              json['episodeFilters'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String id;
  final String displayName;

  /// How episodes are organized into groups.
  final GroupingConfig grouping;

  /// Controls the order playlists claim episodes.
  final int priority;

  /// Controls how groups map to selector dropdown entries.
  /// Absent = all groups as cards inside a single entry (combined).
  /// Present with partitionBy = each partition becomes its own entry.
  final SelectorConfig? selector;

  /// How the group list is arranged.
  final GroupListingConfig? groupListing;

  /// Defaults for individual group card display.
  final GroupItemConfig? groupItem;

  /// How episodes are arranged within groups.
  final EpisodeListingConfig? episodeListing;

  /// Defaults for individual episode row display.
  final EpisodeItemConfig? episodeItem;

  /// Episode filters applied before grouping.
  final EpisodeFilters? episodeFilters;

  /// Whether selector is present (separate mode) or absent (combined mode).
  bool get isSeparate => selector != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'grouping': grouping.toJson(),
      'priority': priority,
      if (selector != null) 'selector': selector!.toJson(),
      if (groupListing != null) 'groupListing': groupListing!.toJson(),
      if (groupItem != null) 'groupItem': groupItem!.toJson(),
      if (episodeListing != null) 'episodeListing': episodeListing!.toJson(),
      if (episodeItem != null) 'episodeItem': episodeItem!.toJson(),
      if (episodeFilters != null) 'episodeFilters': episodeFilters!.toJson(),
    };
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_definition.dart
git commit -m "refactor(domain): restructure SmartPlaylistDefinition to v5 pipeline"
```

---

### Task 5: Remove Presentation enum and delete obsolete config files

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist.dart` — remove `Presentation` enum, replace `presentation` field
- Delete: `packages/audiflow_domain/lib/src/features/feed/models/group_list_config.dart`
- Delete: `packages/audiflow_domain/lib/src/features/feed/models/group_display_config.dart`
- Delete: `packages/audiflow_domain/lib/src/features/feed/models/episode_list_config.dart`

- [ ] **Step 1: Remove Presentation enum from smart_playlist.dart**

Delete the entire `Presentation` enum (lines 6-24 in current file).

- [ ] **Step 2: Replace `presentation` field on SmartPlaylist**

On `SmartPlaylist`: rename field `presentation` → `isSeparate` (bool). Default to `false` (combined).

In constructor: `this.presentation = Presentation.separate` → `this.isSeparate = false`
In `copyWith`: same rename.

The `SmartPlaylist` domain model doesn't need the full `SelectorConfig` — it only needs to know whether the playlist is in separate vs combined mode for display purposes.

- [ ] **Step 3: Delete obsolete files**

```bash
git rm packages/audiflow_domain/lib/src/features/feed/models/group_list_config.dart
git rm packages/audiflow_domain/lib/src/features/feed/models/group_display_config.dart
git rm packages/audiflow_domain/lib/src/features/feed/models/episode_list_config.dart
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor(domain): remove Presentation enum and obsolete v4 config classes"
```

---

### Task 6: Update barrel files

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`
- Modify: `packages/audiflow_domain/lib/patterns.dart`

- [ ] **Step 1: Update audiflow_domain.dart exports**

Remove:
```dart
export 'src/features/feed/models/group_display_config.dart';
export 'src/features/feed/models/group_list_config.dart';
export 'src/features/feed/models/episode_list_config.dart';  // if present separately
```

Add:
```dart
export 'src/features/feed/models/episode_item_config.dart';
export 'src/features/feed/models/episode_listing_config.dart';
export 'src/features/feed/models/group_item_config.dart';
export 'src/features/feed/models/group_listing_config.dart';
export 'src/features/feed/models/grouping_config.dart';
export 'src/features/feed/models/selector_config.dart';
```

Note: `EpisodeListConfig` was already exported — remove that export. Keep existing exports for files that didn't change.

- [ ] **Step 2: Update patterns.dart exports if needed**

Check if any of the deleted files were exported from `patterns.dart`. If so, replace with new file exports.

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/audiflow_domain.dart packages/audiflow_domain/lib/patterns.dart
git commit -m "refactor(domain): update barrel exports for v5 config classes"
```

---

### Task 7: Update resolver service for v5 field paths

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/smart_playlist_resolver_service.dart`

- [ ] **Step 1: Update field access paths**

Replace all v4 field accesses with v5 equivalents:

| v4 access | v5 access |
|-----------|-----------|
| `definition.resolverType` | `definition.grouping.by` |
| `definition.presentation` | `definition.isSeparate` (bool getter) |
| `definition.groupList?.yearBinding` | `definition.groupListing?.yearBinding` |
| `definition.groupList?.showDateRange` | `definition.groupItem?.showDateRange` |
| `definition.groupList?.userSortable` | `definition.groupListing?.userSortable` |
| `definition.groupList?.sort` | `definition.groupListing?.sort` |
| `definition.episodeList?.sort` | `definition.episodeListing?.sort` |
| `definition.episodeList?.showYearHeaders` | `definition.episodeListing?.showYearHeaders` |
| `definition.prependSeasonNumber` | `definition.groupItem?.prependSeasonNumber ?? false` |
| `definition.groups` | `definition.grouping.staticClassifiers` |
| `Presentation.fromString(definition.presentation)` | `definition.isSeparate` |
| `presentation == Presentation.combined` | `!definition.isSeparate` |

For per-group overrides in the combined branch:
| v4 | v5 |
|----|-----|
| `gDef?.display?.yearBinding` | `gDef?.groupListing?.yearBinding` |
| `gDef?.display?.showDateRange` | `gDef?.groupItem?.showDateRange` |
| `gDef?.episodeList?.showYearHeaders` | `gDef?.episodeListing?.showYearHeaders` |
| `gDef?.episodeList?.sort` | `gDef?.episodeListing?.sort` |

Remove imports of `Presentation` (no longer exists).

Restore priority-based sorting in `_sortByProcessingOrder` (priority is back as a required field):

```dart
filtered.sort((a, b) => a.priority.compareTo(b.priority));
fallbacks.sort((a, b) => a.priority.compareTo(b.priority));
```

On `SmartPlaylist` constructor calls: replace `presentation: presentation` with `isSeparate: definition.isSeparate`.

- [ ] **Step 2: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/smart_playlist_resolver_service.dart
git commit -m "refactor(domain): update resolver service for v5 field paths"
```

---

### Task 8: Update resolvers for v5 field paths

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/title_discovery_resolver.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/title_classifier_resolver.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/season_number_resolver.dart`

- [ ] **Step 1: Update TitleDiscoveryResolver**

Change:
- `definition.titleExtractor` → `definition.groupItem?.titleExtractor`
- `definition.groups?.firstOrNull?.pattern` → `definition.grouping.discoveryHint`

- [ ] **Step 2: Update TitleClassifierResolver**

Change:
- `definition.groups` → `definition.grouping.staticClassifiers`
- `groupDefs == null || groupDefs.isEmpty` → same null/empty check on `staticClassifiers`

- [ ] **Step 3: Update SeasonNumberResolver**

Change:
- `definition?.titleExtractor` → `definition?.groupItem?.titleExtractor`

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/resolvers/
git commit -m "refactor(domain): update resolvers for v5 field paths"
```

---

### Task 9: Update EpisodeExtractorResolver and providers

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/episode_extractor_resolver.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/providers/smart_playlist_providers.dart`

- [ ] **Step 1: Update EpisodeExtractorResolver**

Change:
- `definition.groups` → `definition.grouping.staticClassifiers`
- `definition.numberingExtractor` → `definition.grouping.numberingExtractor`
- `group.numberingExtractor` stays the same (GroupDef field name unchanged)

- [ ] **Step 2: Update providers**

In `_buildGroupingFromCache`:
- `Presentation.combined` → remove; use `isSeparate` bool
- `Presentation.fromString(entity.playlistStructure)` → keep reading from entity but convert: `entity.playlistStructure != 'separate'` gives `isSeparate = false` (combined), or `isSeparate = true` for separate
- Actually simpler: `isSeparate: entity.playlistStructure == 'separate'` but also check persisted groups: if groups exist → `isSeparate: false`
- `presentation:` constructor arg → `isSeparate:`

In `_enrichPlaylist`:
- `..playlistStructure = playlist.presentation.name` → `..playlistStructure = playlist.isSeparate ? 'separate' : 'combined'`

Remove import of `Presentation` enum.

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/episode_extractor_resolver.dart \
       packages/audiflow_domain/lib/src/features/feed/providers/smart_playlist_providers.dart
git commit -m "refactor(domain): update extractor resolver and providers for v5"
```

---

### Task 10: Update app-level code

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/inline_playlist_section.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart`

- [ ] **Step 1: Update inline_playlist_section.dart**

- Remove import of `Presentation`
- `playlist.presentation == Presentation.combined` → `!playlist.isSeparate`

- [ ] **Step 2: Update smart_playlist_episodes_screen.dart**

- `widget.smartPlaylist.presentation == Presentation.combined` → `!widget.smartPlaylist.isSeparate` (two occurrences)

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/
git commit -m "refactor(app): update to v5 isSeparate field"
```

---

### Task 11: Delete SmartPlaylistPattern deprecated model references

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_pattern.dart`

- [ ] **Step 1: Check if this deprecated model references removed types**

If it imports `GroupListConfig`, `EpisodeListConfig`, or `GroupDisplayConfig`, update or remove those imports. This model is `@Deprecated` — keep it minimally functional but remove references to deleted classes.

- [ ] **Step 2: Commit if changes needed**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_pattern.dart
git commit -m "refactor(domain): clean up deprecated SmartPlaylistPattern for v5"
```

---

### Task 12: Update all tests

**Files:**
- All test files under `packages/audiflow_domain/test/features/feed/`
- `packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart`
- All resolver, service, provider, and model tests

- [ ] **Step 1: Update schema conformance test**

Key changes:
- Required fields: `['id', 'displayName', 'grouping', 'priority']`
- Minimal definition now needs `grouping: GroupingConfig(by: 'seasonNumber')` and `priority: 0`
- Full definition restructured with nested configs
- Enum tests: `resolverType` → `grouping.by` (access `schema['properties']['grouping']` then drill into `$defs/GroupingConfig`)
- `presentation` → check `selector` in schema properties
- `EpisodeExtractor` → `NumberingExtractor` in $defs (may already be done)
- Schema $id: playlist-definition should be v5

- [ ] **Step 2: Update model tests**

- `smart_playlist_test.dart`: remove `Presentation` enum tests; replace `presentation` field tests with `isSeparate` bool tests
- `smart_playlist_definition_test.dart`: restructure to v5 constructors with `grouping:`, `priority:`, `selector:`, etc.
- `smart_playlist_group_def_test.dart`: if exists, update `display`/`episodeList` → `groupListing`/`groupItem`/`episodeListing`/`episodeItem`

- [ ] **Step 3: Update resolver tests**

- All definitions in test data need `grouping:` and `priority:` fields
- `resolverType: 'seasonNumber'` → `grouping: GroupingConfig(by: 'seasonNumber')`
- `groups: [...]` → `grouping: GroupingConfig(by: 'titleClassifier', staticClassifiers: [...])`
- For titleDiscovery: `groups: [SmartPlaylistGroupDef(pattern: ...)]` → `grouping: GroupingConfig(by: 'titleDiscovery', discoveryHint: ...)`

- [ ] **Step 4: Update service and provider tests**

- Same field path changes as production code
- `playlistStructure: 'grouped'`/`presentation: 'combined'` → no `selector` (combined mode)
- `playlistStructure: 'split'`/`presentation: 'separate'` → `selector: SelectorConfig(partitionBy: 'group')`
- `PlaylistStructure.grouped`/`Presentation.combined` → `!playlist.isSeparate`
- `playlist.presentation` → `playlist.isSeparate`

- [ ] **Step 5: Fix remaining references**

```bash
grep -rn 'Presentation\|GroupListConfig\|EpisodeListConfig\|GroupDisplayConfig\|resolverType\|\.presentation\b' \
  --include='*.dart' packages/ | grep -v '.g.dart' | grep -v '.mocks.dart'
```

Fix any remaining references.

- [ ] **Step 6: Regenerate mocks if needed**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "test: update all tests for v5 schema migration"
```

---

### Task 13: Update documentation and verify

**Files:**
- Modify: `docs/integration/smartplaylist.md`
- Modify: `.claude/rules/project/architecture.md`

- [ ] **Step 1: Update docs with v5 field names and structure**

- [ ] **Step 2: Update flavor config base URLs if needed**

Check if upstream has a v5 asset path. If so, update `packages/audiflow_core/lib/src/config/flavor_config.dart` from `/v4/` to `/v5/`.

- [ ] **Step 3: Run full verification**

```bash
flutter analyze
melos run test
flutter test packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "docs: update references for v5 schema"
```
