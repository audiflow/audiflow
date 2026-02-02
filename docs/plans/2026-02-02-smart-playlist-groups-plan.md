# Smart Playlist Groups Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure SmartPlaylist to support a two-level hierarchy (playlist -> groups -> episodes) with year-based grouping modes.

**Architecture:** SmartPlaylist gains a `contentType` (episodes vs groups) and `yearHeaderMode` (none/firstEpisode/perEpisode). `SmartPlaylistSubCategory` is replaced by `SmartPlaylistGroup`. Resolvers produce groups inside playlists. UI navigates from group cards to filtered episode lists.

**Tech Stack:** Dart/Flutter, Drift (SQLite), Riverpod, go_router

---

### Task 1: Add enums and SmartPlaylistGroup model

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist.dart`
- Test: `packages/audiflow_domain/test/features/feed/models/smart_playlist_test.dart`

**Step 1: Write failing tests for new enums and SmartPlaylistGroup**

```dart
// Add to smart_playlist_test.dart

group('SmartPlaylistContentType', () {
  test('has episodes and groups values', () {
    expect(SmartPlaylistContentType.values, hasLength(2));
    expect(SmartPlaylistContentType.episodes.name, 'episodes');
    expect(SmartPlaylistContentType.groups.name, 'groups');
  });
});

group('YearHeaderMode', () {
  test('has none, firstEpisode, and perEpisode values', () {
    expect(YearHeaderMode.values, hasLength(3));
    expect(YearHeaderMode.none.name, 'none');
    expect(YearHeaderMode.firstEpisode.name, 'firstEpisode');
    expect(YearHeaderMode.perEpisode.name, 'perEpisode');
  });
});

group('SmartPlaylistGroup', () {
  test('holds group data with episode IDs', () {
    final group = SmartPlaylistGroup(
      id: 'lincoln',
      displayName: 'Lincoln',
      sortKey: 1,
      episodeIds: [1, 2, 3],
    );

    expect(group.id, 'lincoln');
    expect(group.displayName, 'Lincoln');
    expect(group.sortKey, 1);
    expect(group.episodeIds, [1, 2, 3]);
    expect(group.thumbnailUrl, isNull);
    expect(group.yearOverride, isNull);
  });

  test('episodeCount returns correct count', () {
    final group = SmartPlaylistGroup(
      id: 'g1',
      displayName: 'G1',
      sortKey: 1,
      episodeIds: [1, 2, 3, 4],
    );
    expect(group.episodeCount, 4);
  });

  test('supports yearOverride', () {
    final group = SmartPlaylistGroup(
      id: 'g1',
      displayName: 'G1',
      sortKey: 1,
      episodeIds: [1],
      yearOverride: YearHeaderMode.perEpisode,
    );
    expect(group.yearOverride, YearHeaderMode.perEpisode);
  });
});
```

**Step 2: Run tests to verify they fail**

Run: `melos run test -- --scope=audiflow_domain` or use `run_tests` tool on `packages/audiflow_domain` with path `test/features/feed/models/smart_playlist_test.dart`
Expected: FAIL - `SmartPlaylistContentType`, `YearHeaderMode`, `SmartPlaylistGroup` not defined

**Step 3: Implement enums and SmartPlaylistGroup**

Add to top of `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist.dart`:

```dart
/// Whether a smart playlist directly contains episodes or groups.
enum SmartPlaylistContentType {
  /// Playlist directly contains an episode list.
  episodes,

  /// Playlist contains groups; tapping a group opens its episode list.
  groups,
}

/// How year headers are applied to groups or episodes.
enum YearHeaderMode {
  /// No year headers.
  none,

  /// Group's year = first episode's publishedAt year. Group appears once.
  firstEpisode,

  /// Group appears under each year it has episodes in.
  /// Tapping shows only that year's episodes.
  perEpisode,
}

/// A group within a smart playlist containing episodes.
final class SmartPlaylistGroup {
  const SmartPlaylistGroup({
    required this.id,
    required this.displayName,
    required this.sortKey,
    required this.episodeIds,
    this.thumbnailUrl,
    this.yearOverride,
  });

  /// Unique identifier within the parent playlist.
  final String id;

  /// Display name for the group.
  final String displayName;

  /// Sort key for ordering groups.
  final int sortKey;

  /// Episode IDs belonging to this group.
  final List<int> episodeIds;

  /// Thumbnail URL from the latest episode in this group.
  final String? thumbnailUrl;

  /// Per-group override of the parent playlist's yearHeaderMode.
  final YearHeaderMode? yearOverride;

  /// Number of episodes in this group.
  int get episodeCount => episodeIds.length;
}
```

**Step 4: Run tests to verify they pass**

Run: `run_tests` tool on `packages/audiflow_domain` with path `test/features/feed/models/smart_playlist_test.dart`
Expected: PASS

**Step 5: Commit**

```
feat(domain): add SmartPlaylistGroup model and year header enums
```

---

### Task 2: Restructure SmartPlaylist model

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist.dart`
- Test: `packages/audiflow_domain/test/features/feed/models/smart_playlist_test.dart`

**Step 1: Write failing tests for restructured SmartPlaylist**

```dart
// Add to existing SmartPlaylist group in smart_playlist_test.dart

test('defaults to episodes contentType with no year headers', () {
  final playlist = SmartPlaylist(
    id: 'p1',
    displayName: 'P1',
    sortKey: 1,
    episodeIds: [1, 2],
  );

  expect(playlist.contentType, SmartPlaylistContentType.episodes);
  expect(playlist.yearHeaderMode, YearHeaderMode.none);
  expect(playlist.episodeYearHeaders, isFalse);
  expect(playlist.groups, isNull);
});

test('supports groups contentType', () {
  final groups = [
    SmartPlaylistGroup(
      id: 'g1',
      displayName: 'G1',
      sortKey: 1,
      episodeIds: [1, 2],
    ),
  ];
  final playlist = SmartPlaylist(
    id: 'p1',
    displayName: 'P1',
    sortKey: 1,
    episodeIds: [],
    contentType: SmartPlaylistContentType.groups,
    yearHeaderMode: YearHeaderMode.firstEpisode,
    groups: groups,
  );

  expect(playlist.contentType, SmartPlaylistContentType.groups);
  expect(playlist.yearHeaderMode, YearHeaderMode.firstEpisode);
  expect(playlist.groups, hasLength(1));
  expect(playlist.groups!.first.id, 'g1');
});

test('copyWith preserves new fields', () {
  final playlist = SmartPlaylist(
    id: 'p1',
    displayName: 'P1',
    sortKey: 1,
    episodeIds: [],
    contentType: SmartPlaylistContentType.groups,
    yearHeaderMode: YearHeaderMode.perEpisode,
    episodeYearHeaders: true,
  );

  final copied = playlist.copyWith(displayName: 'P2');
  expect(copied.contentType, SmartPlaylistContentType.groups);
  expect(copied.yearHeaderMode, YearHeaderMode.perEpisode);
  expect(copied.episodeYearHeaders, isTrue);
  expect(copied.displayName, 'P2');
});
```

**Step 2: Run tests to verify they fail**

Expected: FAIL - `contentType`, `yearHeaderMode`, `episodeYearHeaders`, `groups` params not recognized

**Step 3: Update SmartPlaylist class**

Replace `SmartPlaylistSubCategory` and update `SmartPlaylist` in `smart_playlist.dart`:

- Remove `SmartPlaylistSubCategory` class entirely
- Remove `yearGrouped` and `subCategories` fields from `SmartPlaylist`
- Add fields: `contentType`, `yearHeaderMode`, `episodeYearHeaders`, `groups`
- Update `copyWith` to include new fields

```dart
final class SmartPlaylist {
  const SmartPlaylist({
    required this.id,
    required this.displayName,
    required this.sortKey,
    required this.episodeIds,
    this.thumbnailUrl,
    this.contentType = SmartPlaylistContentType.episodes,
    this.yearHeaderMode = YearHeaderMode.none,
    this.episodeYearHeaders = false,
    this.groups,
  });

  final String id;
  final String displayName;
  final int sortKey;
  final List<int> episodeIds;
  final String? thumbnailUrl;
  final SmartPlaylistContentType contentType;
  final YearHeaderMode yearHeaderMode;
  final bool episodeYearHeaders;
  final List<SmartPlaylistGroup>? groups;

  int get episodeCount => episodeIds.length;

  SmartPlaylist copyWith({
    String? id,
    String? displayName,
    int? sortKey,
    List<int>? episodeIds,
    String? thumbnailUrl,
    SmartPlaylistContentType? contentType,
    YearHeaderMode? yearHeaderMode,
    bool? episodeYearHeaders,
    List<SmartPlaylistGroup>? groups,
  }) {
    return SmartPlaylist(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      sortKey: sortKey ?? this.sortKey,
      episodeIds: episodeIds ?? this.episodeIds,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      contentType: contentType ?? this.contentType,
      yearHeaderMode: yearHeaderMode ?? this.yearHeaderMode,
      episodeYearHeaders: episodeYearHeaders ?? this.episodeYearHeaders,
      groups: groups ?? this.groups,
    );
  }
}
```

**Step 4: Run tests to verify they pass**

Expected: PASS for model tests. Compilation errors expected in other files (resolved in later tasks).

**Step 5: Commit**

```
refactor(domain): restructure SmartPlaylist with contentType and groups
```

---

### Task 3: Fix compilation errors from SmartPlaylistSubCategory removal

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/category_resolver.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/providers/smart_playlist_providers.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/smart_playlist_card.dart`
- Modify: `packages/audiflow_ui/lib/src/widgets/lists/sub_category_slivers.dart` (keep for now, update later)

This task is a bridge: replace all `SmartPlaylistSubCategory` references with `SmartPlaylistGroup`, and replace `yearGrouped` with the new enum fields. The goal is to restore compilation, not to implement new behavior yet.

**Step 1: Update CategoryResolver to produce SmartPlaylistGroup instead of SmartPlaylistSubCategory**

In `category_resolver.dart`:
- Change `_resolveSubCategories` to return `List<SmartPlaylistGroup>?`
- Replace `SmartPlaylistSubCategory(...)` with `SmartPlaylistGroup(...)`
- Update `SmartPlaylist(...)` calls: replace `yearGrouped:` with `yearHeaderMode:` and `subCategories:` with `groups:`
- In the `resolve` method, set `contentType: SmartPlaylistContentType.groups` when groups exist

**Step 2: Update smart_playlist_providers.dart**

- Replace all `SmartPlaylistSubCategory` with `SmartPlaylistGroup`
- Replace `yearGrouped:` with appropriate `yearHeaderMode:` values
- Replace `subCategories:` with `groups:`
- In `_resolveSubCategoriesFromConfig`, rename and return `SmartPlaylistGroup` list

**Step 3: Update SmartPlaylistEpisodesScreen**

- Replace `widget.smartPlaylist.subCategories` with `widget.smartPlaylist.groups`
- Replace `widget.smartPlaylist.yearGrouped` check with `widget.smartPlaylist.yearHeaderMode != YearHeaderMode.none` (for episode-level year headers, use `widget.smartPlaylist.episodeYearHeaders`)
- Update `_buildSubCategorySlivers` to read from `groups` field and map to `SubCategoryData`

**Step 4: Update SmartPlaylistCard**

- Replace `smartPlaylist.yearGrouped` with `smartPlaylist.yearHeaderMode != YearHeaderMode.none`

**Step 5: Run analyze to verify no compilation errors**

Run: `analyze_files` tool on all packages
Expected: No errors

**Step 6: Run all tests**

Run: `run_tests` tool on `packages/audiflow_domain`
Expected: Some tests may fail due to `yearGrouped` references in test files -- fix those too.

**Step 7: Commit**

```
refactor(domain): replace SmartPlaylistSubCategory with SmartPlaylistGroup
```

---

### Task 4: Update RssMetadataResolver to produce groups

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/rss_metadata_resolver.dart`
- Test: `packages/audiflow_domain/test/features/feed/resolvers/smart_playlist_resolver_test.dart` (or create new test file)

Currently `RssMetadataResolver` produces one `SmartPlaylist` per season number. For patterns with the new `playlists` config, it should produce parent SmartPlaylists containing SmartPlaylistGroups.

**Step 1: Write failing test for new playlist-with-groups config**

```dart
// In a test file for RssMetadataResolver

test('produces parent playlists with groups when playlists config exists', () {
  // Create episodes with title patterns matching COTEN format
  final episodes = [
    _makeEpisode(id: 1, title: '【62-1】Lincoln intro', seasonNumber: 62),
    _makeEpisode(id: 2, title: '【62-2】Lincoln pt2', seasonNumber: 62),
    _makeEpisode(id: 3, title: '【COTEN RADIOショート ニコラ・テスラ編1】...', seasonNumber: 63),
    _makeEpisode(id: 4, title: '【番外編#100】...', seasonNumber: 0),
  ];

  final pattern = SmartPlaylistPattern(
    id: 'test',
    resolverType: 'rss',
    titleExtractor: /* existing COTEN extractor */,
    config: {
      'groupNullSeasonAs': 0,
      'playlists': [
        {
          'id': 'regular',
          'displayName': 'Regular Series',
          'contentType': 'groups',
          'yearHeaderMode': 'firstEpisode',
          'titleFilter': r'【\d+-\d+】',
          'excludeFilter': r'【COTEN RADIO\s*ショート',
        },
        {
          'id': 'short',
          'displayName': 'Short Series',
          'contentType': 'groups',
          'yearHeaderMode': 'firstEpisode',
          'titleFilter': r'【\d+-\d+】',
          'requireFilter': r'【COTEN RADIO\s*ショート',
        },
        {
          'id': 'extras',
          'displayName': 'Others (Extras)',
          'contentType': 'groups',
          'yearHeaderMode': 'perEpisode',
        },
      ],
    },
  );

  final result = resolver.resolve(episodes, pattern);

  expect(result, isNotNull);
  expect(result!.playlists, hasLength(3));

  final regular = result.playlists.firstWhere((p) => p.id == 'regular');
  expect(regular.contentType, SmartPlaylistContentType.groups);
  expect(regular.yearHeaderMode, YearHeaderMode.firstEpisode);
  expect(regular.groups, isNotNull);
  // Lincoln group should contain episodes 1, 2
  expect(regular.groups!.any((g) => g.episodeIds.contains(1)), isTrue);

  final short = result.playlists.firstWhere((p) => p.id == 'short');
  expect(short.groups, isNotNull);
  // Tesla group should contain episode 3
  expect(short.groups!.any((g) => g.episodeIds.contains(3)), isTrue);

  final extras = result.playlists.firstWhere((p) => p.id == 'extras');
  expect(extras.yearHeaderMode, YearHeaderMode.perEpisode);
  // Episode 4 (bangai-hen) should be in extras
  expect(extras.groups, isNotNull);
});
```

**Step 2: Run test to verify it fails**

Expected: FAIL - resolver doesn't handle `playlists` config

**Step 3: Implement playlist-with-groups logic in RssMetadataResolver**

In `rss_metadata_resolver.dart`, update `resolve()`:
- Check for `pattern?.config['playlists']` config
- If present: use new `_resolveWithParentPlaylists()` method
  - Filter episodes into parent playlists by title pattern (`titleFilter`, `excludeFilter`, `requireFilter`)
  - Within each parent playlist, group episodes by season number into `SmartPlaylistGroup`s
  - Use the existing title extractor for group display names
- If absent: use current behavior (backwards compatible)

**Step 4: Run test to verify it passes**

Expected: PASS

**Step 5: Commit**

```
feat(domain): add parent playlist support to RssMetadataResolver
```

---

### Task 5: Update CategoryResolver to produce groups

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/category_resolver.dart`
- Test: `packages/audiflow_domain/test/features/feed/resolvers/` (existing or new test)

Currently `CategoryResolver` produces SmartPlaylists with subCategories. Update to produce SmartPlaylists with groups, using the new `playlists` config format.

**Step 1: Write failing test for new playlists config**

```dart
test('produces parent playlists with groups from playlists config', () {
  final episodes = [
    _makeEpisode(id: 1, title: '【1月15日】News...'),
    _makeEpisode(id: 2, title: '【土曜版 #10】...'),
    _makeEpisode(id: 3, title: '【ニュース小話 #5】...'),
  ];

  final pattern = SmartPlaylistPattern(
    id: 'test',
    resolverType: 'category',
    config: {
      'playlists': [
        {
          'id': 'by_category',
          'displayName': 'By Category',
          'contentType': 'groups',
          'yearHeaderMode': 'none',
          'episodeYearHeaders': true,
          'groups': [
            {'id': 'daily', 'displayName': 'Daily', 'pattern': r'【\d+月\d+日】'},
            {'id': 'saturday', 'displayName': 'Saturday', 'pattern': r'【土曜版'},
            {'id': 'news_talk', 'displayName': 'News Talk', 'pattern': r'【ニュース小話'},
          ],
        },
        {
          'id': 'by_year',
          'displayName': 'By Year',
          'contentType': 'groups',
          'yearHeaderMode': 'perEpisode',
          'episodeYearHeaders': false,
          'groups': [
            {'id': 'daily', 'displayName': 'Daily', 'pattern': r'【\d+月\d+日】'},
            {'id': 'saturday', 'displayName': 'Saturday', 'pattern': r'【土曜版'},
            {'id': 'news_talk', 'displayName': 'News Talk', 'pattern': r'【ニュース小話'},
          ],
        },
      ],
    },
  );

  final result = resolver.resolve(episodes, pattern);

  expect(result, isNotNull);
  expect(result!.playlists, hasLength(2));

  final byCategory = result.playlists.firstWhere((p) => p.id == 'by_category');
  expect(byCategory.contentType, SmartPlaylistContentType.groups);
  expect(byCategory.yearHeaderMode, YearHeaderMode.none);
  expect(byCategory.episodeYearHeaders, isTrue);
  expect(byCategory.groups, isNotNull);

  final byYear = result.playlists.firstWhere((p) => p.id == 'by_year');
  expect(byYear.yearHeaderMode, YearHeaderMode.perEpisode);
  expect(byYear.groups, isNotNull);
});
```

**Step 2: Run test to verify it fails**

**Step 3: Implement new playlists config in CategoryResolver**

- Check for `pattern?.config['playlists']`
- If present: build parent playlists, each with groups from title pattern matching
- If absent: use legacy `categories` config (backwards compatible)
- Each group's episodeIds = episodes matching that group's pattern

**Step 4: Run tests to verify they pass**

**Step 5: Commit**

```
feat(domain): add parent playlist support to CategoryResolver
```

---

### Task 6: Update COTEN and NewsConnect patterns

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/patterns/coten_radio_pattern.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/patterns/news_connect_pattern.dart`
- Test: `packages/audiflow_domain/test/features/feed/patterns/coten_radio_pattern_test.dart`
- Test: `packages/audiflow_domain/test/features/feed/patterns/news_connect_pattern_test.dart`

**Step 1: Update COTEN pattern config**

Replace current config with new `playlists` format:
```dart
config: {
  'groupNullSeasonAs': 0,
  'playlists': [
    {
      'id': 'regular',
      'displayName': 'Regular Series',
      'contentType': 'groups',
      'yearHeaderMode': 'firstEpisode',
      'episodeYearHeaders': false,
      'titleFilter': r'【\d+-\d+】',
      'excludeFilter': r'【COTEN RADIO\s*ショート',
    },
    {
      'id': 'short',
      'displayName': 'Short Series',
      'contentType': 'groups',
      'yearHeaderMode': 'firstEpisode',
      'episodeYearHeaders': false,
      'titleFilter': r'【\d+-\d+】',
      'requireFilter': r'【COTEN RADIO\s*ショート',
    },
    {
      'id': 'extras',
      'displayName': 'Others (Extras)',
      'contentType': 'groups',
      'yearHeaderMode': 'perEpisode',
      'episodeYearHeaders': false,
    },
  ],
},
```

Remove `yearGroupedPlaylists` from config (replaced by per-playlist `yearHeaderMode`).

**Step 2: Update NewsConnect pattern config**

Replace current `categories` config with `playlists` format:
```dart
config: {
  'playlists': [
    {
      'id': 'by_category',
      'displayName': 'By Category',
      'contentType': 'groups',
      'yearHeaderMode': 'none',
      'episodeYearHeaders': true,
      'groups': [
        {'id': 'daily_news', 'displayName': 'Daily News', 'pattern': r'【\d+月\d+日】'},
        {'id': 'saturday', 'displayName': 'Saturday', 'pattern': r'【土曜版'},
        {'id': 'news_talk', 'displayName': 'News Talk', 'pattern': r'【ニュース小話'},
        {'id': 'special', 'displayName': 'Special', 'pattern': r'【.*?特別編.*?】'},
        {'id': 'expat', 'displayName': 'Expat', 'pattern': r'【越境日本人編'},
        {'id': 'holiday', 'displayName': 'Holiday', 'pattern': r'【祝日版'},
      ],
    },
    {
      'id': 'by_year',
      'displayName': 'By Year',
      'contentType': 'groups',
      'yearHeaderMode': 'perEpisode',
      'episodeYearHeaders': false,
      'groups': [/* same group definitions */],
    },
  ],
},
```

**Step 3: Update existing pattern tests**

Fix any tests that reference old config format.

**Step 4: Run tests**

**Step 5: Commit**

```
feat(domain): update COTEN and NewsConnect patterns with playlists config
```

---

### Task 7: Update providers for groups support

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/providers/smart_playlist_providers.dart`

Update `_buildGroupingFromCache`, `_buildCategoryGroupingFromCache`, and `_resolveSubCategoriesFromConfig` to work with the new model.

**Step 1: Update `_buildGroupingFromCache`**

- When building SmartPlaylist from cache, set `contentType`, `yearHeaderMode`, `episodeYearHeaders` from cached entity
- For category-based resolvers, re-resolve produces groups instead of subCategories

**Step 2: Update `_resolveSubCategoriesFromConfig`**

- Rename to `_resolveGroupsFromConfig`
- Return `List<SmartPlaylistGroup>?` instead of `List<SmartPlaylistSubCategory>?`

**Step 3: Update `_resolveAndPersistSmartPlaylists`**

- When persisting enriched playlists, include new fields in companion

**Step 4: Run all tests**

**Step 5: Commit**

```
refactor(domain): update providers for SmartPlaylistGroup support
```

---

### Task 8: Database migration for new fields

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlists.dart`
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/datasources/local/smart_playlist_local_datasource.dart`

**Step 1: Add new columns to SmartPlaylists Drift table**

In `smart_playlists.dart`, add:
```dart
TextColumn get contentType =>
    text().withDefault(const Constant('episodes'))();

TextColumn get yearHeaderMode =>
    text().withDefault(const Constant('none'))();

BoolColumn get episodeYearHeaders =>
    boolean().withDefault(const Constant(false))();
```

Keep `yearGrouped` for now (migration reads it, then it's unused).

**Step 2: Add migration in app_database.dart**

Bump `schemaVersion` to 13. Add migration:
```dart
// Migration from v12 to v13: add contentType, yearHeaderMode, episodeYearHeaders columns
if (13 <= to && from < 13) {
  await m.addColumn(smartPlaylists, smartPlaylists.contentType);
  await m.addColumn(smartPlaylists, smartPlaylists.yearHeaderMode);
  await m.addColumn(smartPlaylists, smartPlaylists.episodeYearHeaders);
}
```

**Step 3: Run code generation**

Run: `dart run build_runner build --delete-conflicting-outputs` in `packages/audiflow_domain`

**Step 4: Update local datasource to use new fields**

In `smart_playlist_local_datasource.dart`, no structural changes needed -- companions handle new columns via defaults.

**Step 5: Run analyze and tests**

**Step 6: Commit**

```
feat(domain): add database migration for smart playlist groups fields
```

---

### Task 9: SmartPlaylistGroups table (new)

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_groups.dart`
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/datasources/local/smart_playlist_local_datasource.dart`

**Step 1: Create Drift table**

```dart
import 'package:drift/drift.dart';

import '../../subscription/models/subscriptions.dart';

/// Drift table for persisted smart playlist group data.
@DataClassName('SmartPlaylistGroupEntity')
class SmartPlaylistGroups extends Table {
  IntColumn get podcastId => integer().references(Subscriptions, #id)();
  TextColumn get playlistId => text()();
  TextColumn get groupId => text()();
  TextColumn get displayName => text()();
  IntColumn get sortKey => integer()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get episodeIds => text()(); // JSON-encoded list
  TextColumn get yearOverride => text().nullable()();

  @override
  Set<Column> get primaryKey => {podcastId, playlistId, groupId};
}
```

**Step 2: Register table in AppDatabase**

Add `SmartPlaylistGroups` to the `@DriftDatabase(tables: [...])` list.

**Step 3: Add migration**

Bump `schemaVersion` to 14 (or combine with task 8 if done together):
```dart
if (14 <= to && from < 14) {
  await m.createTable(smartPlaylistGroups);
}
```

**Step 4: Add datasource methods for groups**

In `smart_playlist_local_datasource.dart`:
```dart
Future<List<SmartPlaylistGroupEntity>> getGroupsByPlaylist(
  int podcastId,
  String playlistId,
) { ... }

Future<void> upsertGroupsForPlaylist(
  int podcastId,
  String playlistId,
  List<SmartPlaylistGroupsCompanion> companions,
) { ... }
```

**Step 5: Run code generation, analyze, tests**

**Step 6: Commit**

```
feat(domain): add SmartPlaylistGroups database table
```

---

### Task 10: Group list UI in SmartPlaylistEpisodesScreen

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart`

When `smartPlaylist.contentType == SmartPlaylistContentType.groups`, display a list of group cards instead of an episode list.

**Step 1: Add group list rendering**

In `_buildEpisodeList`, add early check:
```dart
if (widget.smartPlaylist.contentType == SmartPlaylistContentType.groups &&
    widget.smartPlaylist.groups != null) {
  return _buildGroupList(context, theme);
}
```

**Step 2: Implement `_buildGroupList`**

Build group cards using existing `SmartPlaylistCard` widget or a new group card widget. If `yearHeaderMode != none`, group the groups by year and use `buildYearGroupedSlivers`.

For `firstEpisode` mode: assign each group to a year based on first episode's publishedAt.
For `perEpisode` mode: duplicate groups under each year they have episodes in.

**Step 3: Handle group tap navigation**

When a group card is tapped, navigate to a new screen showing the group's episodes. Pass the group's `episodeIds` (filtered by year if `perEpisode` mode).

**Step 4: Run analyze**

**Step 5: Commit**

```
feat(ui): add group list view to SmartPlaylistEpisodesScreen
```

---

### Task 11: Group episode list screen

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_group_episodes_screen.dart`
- Modify: `packages/audiflow_app/lib/routing/app_router.dart`

A screen showing episodes within a group. Similar to SmartPlaylistEpisodesScreen but for a group's episodes.

**Step 1: Create the screen**

Reuse much of SmartPlaylistEpisodesScreen logic:
- Header with group name and podcast info
- Episode list with optional year headers (controlled by `episodeYearHeaders`)
- Sort toggle
- Uses `smartPlaylistEpisodesProvider` with the group's episodeIds

**Step 2: Add route**

In `app_router.dart`, add a nested route under the smart-playlist route:
```dart
static const String smartPlaylistGroupEpisodes =
    'smart-playlist/:playlistId/group/:groupId';
```

**Step 3: Wire navigation from group cards**

In the group list (Task 10), tapping a group navigates to this route with:
- `episodeIds` (filtered by year if perEpisode mode)
- `episodeYearHeaders` from parent playlist
- `podcastTitle`, `podcastArtworkUrl`, etc.

**Step 4: Run analyze**

**Step 5: Commit**

```
feat(ui): add group episodes screen with routing
```

---

### Task 12: Remove sub_category_slivers dependency

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart`
- Potentially modify: `packages/audiflow_ui/lib/src/widgets/lists/sub_category_slivers.dart`
- Modify: `packages/audiflow_ui/lib/audiflow_ui.dart`

Since `SmartPlaylistSubCategory` is removed and groups now navigate to their own screens instead of inline expand/collapse, the sub_category_slivers widget is no longer needed for smart playlists.

**Step 1: Remove `_buildSubCategorySlivers` from SmartPlaylistEpisodesScreen**

This method used the old `subCategories` field. With the new design, groups always navigate to a separate screen.

**Step 2: Clean up sub_category_slivers.dart**

If no other code uses `buildSubCategorySlivers`, it can be removed or kept for future use. Check for other references first.

**Step 3: Run analyze and tests**

**Step 4: Commit**

```
refactor(ui): remove sub-category inline display from smart playlists
```

---

### Task 13: Remove yearGrouped column from DB (cleanup)

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlists.dart`

Remove the `yearGrouped` column from the Drift table now that it's replaced by `yearHeaderMode` and `episodeYearHeaders`. This is a data migration -- existing `yearGrouped=true` rows should have `yearHeaderMode` set appropriately during migration.

**Step 1: Add migration logic**

In `app_database.dart`, in the migration for the new version:
```dart
// Migrate yearGrouped data to yearHeaderMode
await customStatement(
  "UPDATE seasons SET year_header_mode = 'perEpisode' WHERE year_grouped = 1",
);
```

Then remove the `yearGrouped` column from the table definition (Drift handles column removal via `m.deleteColumn` or by not including it in the next schema version).

Note: Drift doesn't support `deleteColumn` easily. The safer approach is to keep the column in the Drift table but stop using it, and add a `@Deprecated` annotation. Or use a full table recreation migration.

**Step 2: Remove `yearGrouped` references from all Dart code**

Remove any remaining `yearGrouped` usage in providers, resolvers, UI.

**Step 3: Run analyze and tests**

**Step 4: Commit**

```
chore(domain): deprecate yearGrouped column in favor of yearHeaderMode
```

---

### Task 14: Integration testing and end-to-end verification

**Files:**
- Test: `packages/audiflow_domain/test/features/feed/resolvers/smart_playlist_resolver_test.dart`
- Test: `packages/audiflow_domain/test/features/feed/services/smart_playlist_resolver_service_test.dart`
- Test: `packages/audiflow_domain/test/features/feed/models/smart_playlist_year_grouped_test.dart`

**Step 1: Update all existing tests**

Fix any tests that reference removed fields (`yearGrouped`, `subCategories`).

**Step 2: Add integration test for full resolver chain**

Test the full flow: episodes -> resolver service -> SmartPlaylistGrouping with groups.

**Step 3: Run full test suite**

Run: `run_tests` tool on `packages/audiflow_domain`
Expected: All tests pass

**Step 4: Run analyze on all packages**

Run: `analyze_files` tool on all roots
Expected: No errors

**Step 5: Commit**

```
test(domain): update and add tests for smart playlist groups
```

---

## Task Dependency Summary

```
Task 1 (enums + group model)
  -> Task 2 (restructure SmartPlaylist)
    -> Task 3 (fix compilation errors)
      -> Task 4 (RssMetadataResolver groups) ─┐
      -> Task 5 (CategoryResolver groups) ─────┤
      -> Task 6 (pattern configs) ─────────────┤
      -> Task 7 (providers update) ────────────┤
      -> Task 8 (DB migration columns) ────────┤
      -> Task 9 (DB groups table) ─────────────┤
                                                │
      All above complete ──────────────────────>┤
        -> Task 10 (group list UI)              │
          -> Task 11 (group episodes screen)    │
            -> Task 12 (cleanup sub_category)   │
              -> Task 13 (cleanup yearGrouped)  │
                -> Task 14 (integration tests)  │
```

Tasks 4-9 can be done in parallel after Task 3.
Tasks 10-14 are sequential.
