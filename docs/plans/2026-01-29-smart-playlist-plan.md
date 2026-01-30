# Smart Playlist Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rename Season to SmartPlaylist, add year-based episode grouping, create CategoryResolver for NewsConnect, and set up i18n infrastructure.

**Architecture:** Plugin-based resolver chain with SmartPlaylistPattern configs per podcast. CategoryResolver is a new resolver type for predefined title-pattern grouping. Year grouping is a per-playlist flag rendered as section headers in the UI. i18n uses Flutter's gen-l10n with ARB files.

**Tech Stack:** Flutter/Dart, Drift (SQLite), Riverpod, go_router, flutter_localizations

---

## Phase 1: i18n Infrastructure

### Task 1: Create l10n configuration

**Files:**
- Create: `packages/audiflow_app/l10n.yaml`

**Step 1: Create l10n.yaml**

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

**Step 2: Commit**

```bash
git add packages/audiflow_app/l10n.yaml
git commit -m "chore(l10n): add l10n.yaml configuration"
```

### Task 2: Create English ARB file

**Files:**
- Create: `packages/audiflow_app/lib/l10n/app_en.arb`

**Step 1: Create app_en.arb**

```json
{
  "@@locale": "en",
  "smartPlaylistDailyNews": "Daily News",
  "@smartPlaylistDailyNews": { "description": "NewsConnect weekday episodes playlist name" },
  "smartPlaylistPrograms": "Programs",
  "@smartPlaylistPrograms": { "description": "NewsConnect non-weekday episodes playlist name" },
  "smartPlaylistExtras": "Extras",
  "@smartPlaylistExtras": { "description": "COTEN Radio extras playlist name" },
  "smartPlaylistOthers": "Others",
  "@smartPlaylistOthers": { "description": "Catch-all playlist name for uncategorized episodes" },
  "smartPlaylistSectionTitle": "Smart Playlists",
  "@smartPlaylistSectionTitle": { "description": "Section header for smart playlists in podcast detail" },
  "episodesLabel": "Episodes",
  "@episodesLabel": { "description": "Label for episodes view tab" },
  "smartPlaylistsLabel": "Smart Playlists",
  "@smartPlaylistsLabel": { "description": "Label for smart playlists view tab" }
}
```

**Step 2: Commit**

```bash
git add packages/audiflow_app/lib/l10n/app_en.arb
git commit -m "chore(l10n): add English ARB file with smart playlist keys"
```

### Task 3: Create Japanese ARB file

**Files:**
- Create: `packages/audiflow_app/lib/l10n/app_ja.arb`

**Step 1: Create app_ja.arb**

```json
{
  "@@locale": "ja",
  "smartPlaylistDailyNews": "平日版",
  "smartPlaylistPrograms": "特集",
  "smartPlaylistExtras": "番外編",
  "smartPlaylistOthers": "その他",
  "smartPlaylistSectionTitle": "スマートプレイリスト",
  "episodesLabel": "エピソード",
  "smartPlaylistsLabel": "スマートプレイリスト"
}
```

**Step 2: Commit**

```bash
git add packages/audiflow_app/lib/l10n/app_ja.arb
git commit -m "chore(l10n): add Japanese ARB file with smart playlist keys"
```

### Task 4: Enable l10n generation in pubspec.yaml

**Files:**
- Modify: `packages/audiflow_app/pubspec.yaml`

**Step 1: Add `generate: true` under the `flutter:` section**

In `packages/audiflow_app/pubspec.yaml`, add `generate: true` under the `flutter:` key (alongside `uses-material-design: true`).

**Step 2: Run code generation**

```bash
cd packages/audiflow_app && flutter gen-l10n
```

Expected: generates `lib/l10n/app_localizations.dart` and related files.

**Step 3: Commit**

```bash
git add packages/audiflow_app/pubspec.yaml packages/audiflow_app/lib/l10n/
git commit -m "chore(l10n): enable flutter gen-l10n in pubspec"
```

### Task 5: Wire localization delegates into MaterialApp

**Files:**
- Modify: `packages/audiflow_app/lib/app/app.dart`

**Step 1: Read the current app.dart file**

**Step 2: Add imports and delegates**

Add to MaterialApp.router:
```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

// In MaterialApp.router:
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,
```

**Step 3: Run analyze to verify**

```bash
cd packages/audiflow_app && dart analyze lib/app/app.dart
```

**Step 4: Commit**

```bash
git add packages/audiflow_app/lib/app/app.dart
git commit -m "feat(l10n): wire localization delegates into MaterialApp"
```

---

## Phase 2: Rename Season -> SmartPlaylist (Domain Layer)

> This is the largest phase. Each task renames files in one logical group.
> After ALL renames, run build_runner once to regenerate everything.

### Task 6: Rename core model - Season -> SmartPlaylist

**Files:**
- Rename: `packages/audiflow_domain/lib/src/features/feed/models/season.dart` -> `smart_playlist.dart`

**Step 1: Create new file `smart_playlist.dart`**

Copy `season.dart` content, rename:
- `Season` -> `SmartPlaylist`
- `SeasonGrouping` -> `SmartPlaylistGrouping`
- All doc comments referencing "season" -> "smart playlist"
- `copyWith` return type

**Step 2: Delete old `season.dart`**

**Step 3: Update all imports in the domain package**

Search and replace across `packages/audiflow_domain/lib/`:
- `import '...season.dart'` -> `import '...smart_playlist.dart'`
- `Season` (class) -> `SmartPlaylist`
- `SeasonGrouping` -> `SmartPlaylistGrouping`

Files to update (non-exhaustive - grep for all):
- `resolvers/season_resolver.dart`
- `resolvers/rss_metadata_resolver.dart`
- `resolvers/title_appearance_order_resolver.dart`
- `resolvers/year_resolver.dart`
- `services/season_resolver_service.dart`
- `providers/season_providers.dart`
- `datasources/local/season_local_datasource.dart`

**Step 4: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "refactor(domain): rename Season to SmartPlaylist"
```

### Task 7: Rename Drift table - Seasons -> SmartPlaylists

**Files:**
- Rename: `packages/audiflow_domain/lib/src/features/feed/models/seasons.dart` -> `smart_playlists.dart`

**Step 1: Create new `smart_playlists.dart`**

```dart
import 'package:drift/drift.dart';
import '../../../features/subscription/models/subscriptions.dart';

/// Drift table for persisted smart playlist metadata.
@DataClassName('SmartPlaylistEntity')
class SmartPlaylists extends Table {
  IntColumn get podcastId => integer().references(Subscriptions, #id)();
  IntColumn get playlistNumber => integer()();
  TextColumn get displayName => text()();
  IntColumn get sortKey => integer()();
  TextColumn get resolverType => text()();
  TextColumn get thumbnailUrl => text().nullable()();
  BoolColumn get yearGrouped => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {podcastId, playlistNumber};
}
```

Note: The column name changes from `seasonNumber` to `playlistNumber`. The DB migration (Task 12) will handle the actual SQLite rename.

**Step 2: Delete old `seasons.dart`**

**Step 3: Update `app_database.dart`**

- Change import from `seasons.dart` to `smart_playlists.dart`
- Change `Seasons` to `SmartPlaylists` in `@DriftDatabase` tables list
- Update migration references: `seasons` -> `smartPlaylists`

**Step 4: Update all references**

- `SeasonEntity` -> `SmartPlaylistEntity`
- `SeasonsCompanion` -> `SmartPlaylistsCompanion`
- `Seasons` table -> `SmartPlaylists`
- All files importing `seasons.dart`

**Step 5: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "refactor(domain): rename Seasons Drift table to SmartPlaylists"
```

### Task 8: Rename SeasonPattern -> SmartPlaylistPattern

**Files:**
- Rename: `models/season_pattern.dart` -> `smart_playlist_pattern.dart`

**Step 1: Rename class and file**

- `SeasonPattern` -> `SmartPlaylistPattern`
- Update all doc comments
- Update `matchesPodcast` method (no logic change, just class name)

**Step 2: Update all imports and references**

Files referencing `SeasonPattern`:
- `resolvers/season_resolver.dart`
- `resolvers/*.dart` (all resolvers)
- `services/season_resolver_service.dart`
- `providers/season_providers.dart`
- `patterns/coten_radio_pattern.dart`
- `models/season_title_extractor.dart`

**Step 3: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "refactor(domain): rename SeasonPattern to SmartPlaylistPattern"
```

### Task 9: Rename remaining model files

**Files:**
- Rename: `models/season_sort.dart` -> `smart_playlist_sort.dart`
- Rename: `models/season_title_extractor.dart` -> `smart_playlist_title_extractor.dart`
- Rename: `models/season_episode_extractor.dart` -> `smart_playlist_episode_extractor.dart`

**Step 1: Rename classes**

- `SeasonSortField` -> `SmartPlaylistSortField`
- `SeasonSortSpec` -> `SmartPlaylistSortSpec`
- `SimpleSeasonSort` -> `SimpleSmartPlaylistSort`
- `CompositeSeasonSort` -> `CompositeSmartPlaylistSort`
- `SeasonSortRule` -> `SmartPlaylistSortRule`
- `SeasonSortCondition` -> `SmartPlaylistSortCondition`
- `SortKeyGreaterThan` -> `SortKeyGreaterThan` (keep - it's generic)
- `SeasonTitleExtractor` -> `SmartPlaylistTitleExtractor`
- `SeasonEpisodeExtractor` -> `SmartPlaylistEpisodeExtractor`
- `SeasonEpisodeResult` -> `SmartPlaylistEpisodeResult`

**Step 2: Update all imports and references across domain package**

**Step 3: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "refactor(domain): rename season sort/extractor models to smart playlist"
```

### Task 10: Rename resolver files and interface

**Files:**
- Rename: `resolvers/season_resolver.dart` -> `smart_playlist_resolver.dart`

**Step 1: Rename interface**

- `SeasonResolver` -> `SmartPlaylistResolver`
- Update return type references to `SmartPlaylistGrouping`
- Update parameter type to `SmartPlaylistPattern`

**Step 2: Update all resolver implementations**

In each resolver file (`rss_metadata_resolver.dart`, `title_appearance_order_resolver.dart`, `year_resolver.dart`):
- Change `implements SeasonResolver` -> `implements SmartPlaylistResolver`
- Update import path
- Update all `Season(...)` constructors to `SmartPlaylist(...)`
- Update `SeasonGrouping(...)` to `SmartPlaylistGrouping(...)`

**Step 3: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "refactor(domain): rename SeasonResolver to SmartPlaylistResolver"
```

### Task 11: Rename service and datasource files

**Files:**
- Rename: `services/season_resolver_service.dart` -> `smart_playlist_resolver_service.dart`
- Rename: `datasources/local/season_local_datasource.dart` -> `smart_playlist_local_datasource.dart`

**Step 1: Rename classes**

- `SeasonResolverService` -> `SmartPlaylistResolverService`
- `SeasonLocalDatasource` -> `SmartPlaylistLocalDatasource`

**Step 2: Update all references in providers, repositories**

**Step 3: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "refactor(domain): rename season service and datasource to smart playlist"
```

### Task 12: Rename providers file

**Files:**
- Rename: `providers/season_providers.dart` -> `smart_playlist_providers.dart`

**Step 1: Rename all provider functions and types**

- `seasonLocalDatasource` -> `smartPlaylistLocalDatasource`
- `seasonResolverService` -> `smartPlaylistResolverService`
- `seasonPatternByFeedUrl` -> `smartPlaylistPatternByFeedUrl`
- `podcastSeasons` -> `podcastSmartPlaylists`
- `hasSeasonView` -> `hasSmartPlaylistView`
- `hasSeasonViewByFeedUrl` -> `hasSmartPlaylistViewByFeedUrl`
- `podcastSeasonsByFeedUrl` -> `podcastSmartPlaylistsByFeedUrl`
- `seasonEpisodes` -> `smartPlaylistEpisodes`
- `SeasonEpisodeData` -> `SmartPlaylistEpisodeData`
- All internal helper functions

**Step 2: Update the `_registeredPatterns` list and imports**

**Step 3: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "refactor(domain): rename season providers to smart playlist"
```

### Task 13: Rename podcast view preference references

**Files:**
- Modify: `models/podcast_view_preference.dart`
- Modify: `providers/podcast_view_preference_providers.dart`
- Modify: `repositories/podcast_view_preference_repository.dart`

**Step 1: Update column comments and view mode values**

In `podcast_view_preference.dart`:
- Change view mode comment from `'seasons'` to `'smartPlaylists'`
- Change column comments from "Season sort" to "Smart playlist sort"
- Note: Do NOT rename DB column names (`seasonSortField`, `seasonSortOrder`) yet - that requires a migration. Leave the Drift column names as-is for now to avoid a breaking migration.

In providers/repository:
- Update string literals: `'seasons'` -> `'smartPlaylists'` in view mode logic
- Rename functions: `seasonSort*` -> `smartPlaylistSort*`

**Step 2: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "refactor(domain): update view preference references to smart playlist"
```

### Task 14: Update export file

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

**Step 1: Update all export paths and show names**

Replace all season-related exports with smart playlist equivalents:
- `season.dart` -> `smart_playlist.dart`
- `season_pattern.dart` -> `smart_playlist_pattern.dart`
- `season_sort.dart` -> `smart_playlist_sort.dart`
- `season_title_extractor.dart` -> `smart_playlist_title_extractor.dart`
- `seasons.dart` -> `smart_playlists.dart`
- `season_episode_extractor.dart` -> `smart_playlist_episode_extractor.dart`
- `season_resolver.dart` -> `smart_playlist_resolver.dart`
- `season_resolver_service.dart` -> `smart_playlist_resolver_service.dart`
- `season_providers.dart` -> `smart_playlist_providers.dart`
- `season_local_datasource.dart` -> `smart_playlist_local_datasource.dart`
- `SeasonEntity` -> `SmartPlaylistEntity`
- `SeasonsCompanion` -> `SmartPlaylistsCompanion`

**Step 2: Commit**

```bash
git add packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "refactor(domain): update audiflow_domain exports for smart playlist"
```

### Task 15: Run build_runner for domain package

**Step 1: Run code generation**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

Expected: All `.g.dart` files regenerated with new class names.

**Step 2: Run analyze**

```bash
cd packages/audiflow_domain && dart analyze
```

Fix any issues found.

**Step 3: Commit generated files**

```bash
git add -A packages/audiflow_domain/
git commit -m "chore(domain): regenerate code after smart playlist rename"
```

---

## Phase 3: Rename Season -> SmartPlaylist (App Layer)

### Task 16: Rename app presentation files

**Files to rename (all in `packages/audiflow_app/lib/features/podcast_detail/presentation/`):**
- `screens/season_episodes_screen.dart` -> `screens/smart_playlist_episodes_screen.dart`
- `widgets/season_card.dart` -> `widgets/smart_playlist_card.dart`
- `widgets/season_grid.dart` -> `widgets/smart_playlist_grid.dart`
- `widgets/season_sort_sheet.dart` -> `widgets/smart_playlist_sort_sheet.dart`
- `widgets/season_view_toggle.dart` -> `widgets/smart_playlist_view_toggle.dart`
- `widgets/season_episode_list_tile.dart` -> `widgets/smart_playlist_episode_list_tile.dart`
- `controllers/season_sort_controller.dart` -> `controllers/smart_playlist_sort_controller.dart`

**Step 1: Rename each file and update class names**

For each file, rename the class:
- `SeasonEpisodesScreen` -> `SmartPlaylistEpisodesScreen`
- `SeasonCard` -> `SmartPlaylistCard`
- `SeasonGrid` -> `SmartPlaylistGrid`
- `SeasonSortSheet` -> `SmartPlaylistSortSheet`
- `SeasonViewToggle` -> `SmartPlaylistViewToggle`
- `SeasonEpisodeListTile` -> `SmartPlaylistEpisodeListTile`
- `SeasonSortController` -> `SmartPlaylistSortController`
- `SeasonSortConfig` -> `SmartPlaylistSortConfig`

**Step 2: Update all imports within these files to use new domain names**

**Step 3: Update `podcast_detail_screen.dart` and `podcast_detail_controller.dart`**

These files reference season widgets/providers heavily. Update all imports and references.

**Step 4: Commit**

```bash
git add -A packages/audiflow_app/lib/features/
git commit -m "refactor(app): rename season UI components to smart playlist"
```

### Task 17: Update routing

**Files:**
- Modify: `packages/audiflow_app/lib/routing/app_router.dart`
- Modify: `packages/audiflow_app/lib/routing/routes.dart` (if exists)

**Step 1: Update route names and imports**

- `SeasonEpisodesRoute` -> `SmartPlaylistEpisodesRoute`
- Update path segment: `/seasons/` -> `/smart-playlists/`
- Update imports to new screen file

**Step 2: Commit**

```bash
git add -A packages/audiflow_app/lib/routing/
git commit -m "refactor(app): update routes for smart playlist rename"
```

### Task 18: Rename CLI package references

**Files:**
- All files in `packages/audiflow_cli/` referencing Season

**Step 1: Rename CLI files**

- `commands/season_debug_command.dart` -> `commands/smart_playlist_debug_command.dart`
- `diagnostics/season_episode_extractor_diagnostics.dart` -> `diagnostics/smart_playlist_episode_extractor_diagnostics.dart`
- Update class names and all references

**Step 2: Update CLI exports and registration**

**Step 3: Commit**

```bash
git add -A packages/audiflow_cli/
git commit -m "refactor(cli): rename season references to smart playlist"
```

### Task 19: Run build_runner for all packages and verify

**Step 1: Run melos build_runner**

```bash
melos run build_runner
```

**Step 2: Run analyze across all packages**

```bash
melos run analyze
```

**Step 3: Fix any remaining compilation errors**

**Step 4: Commit**

```bash
git add -A
git commit -m "chore: regenerate all code after smart playlist rename"
```

### Task 20: Update and run all existing tests

**Step 1: Rename test files**

All test files in `packages/audiflow_domain/test/features/feed/` referencing season:
- `models/season_test.dart` -> `models/smart_playlist_test.dart`
- `models/seasons_test.dart` -> `models/smart_playlists_test.dart`
- `models/season_pattern_test.dart` -> `models/smart_playlist_pattern_test.dart`
- `models/season_sort_test.dart` -> `models/smart_playlist_sort_test.dart`
- `models/season_title_extractor_test.dart` -> `models/smart_playlist_title_extractor_test.dart`
- `models/season_episode_extractor_test.dart` -> `models/smart_playlist_episode_extractor_test.dart`
- `resolvers/season_resolver_test.dart` -> `resolvers/smart_playlist_resolver_test.dart`
- `services/season_resolver_service_test.dart` -> `services/smart_playlist_resolver_service_test.dart`
- `patterns/coten_radio_pattern_test.dart` (keep name, update internal references)

Similarly for CLI test files.

**Step 2: Update test content - replace all Season references with SmartPlaylist**

**Step 3: Run tests**

```bash
melos run test
```

Expected: All tests pass.

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor(test): rename season tests to smart playlist"
```

---

## Phase 4: DB Migration

### Task 21: Add DB migration for rename + yearGrouped column

**Files:**
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart`

**Step 1: Increment schema version to 11**

**Step 2: Add migration**

```dart
// Migration from v10 to v11: rename Seasons -> SmartPlaylists, add yearGrouped
if (11 <= to && from < 11) {
  // Rename table
  await m.database.customStatement(
    'ALTER TABLE seasons RENAME TO smart_playlists',
  );
  // Rename column
  await m.database.customStatement(
    'ALTER TABLE smart_playlists RENAME COLUMN season_number TO playlist_number',
  );
  // Add yearGrouped column
  await m.database.customStatement(
    'ALTER TABLE smart_playlists ADD COLUMN year_grouped INTEGER NOT NULL DEFAULT 0',
  );
}
```

**Step 3: Run build_runner to regenerate database code**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 4: Run analyze**

**Step 5: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "feat(domain): add DB migration v11 for smart playlist rename"
```

---

## Phase 5: Add yearGrouped to SmartPlaylist Model

### Task 22: Add yearGrouped to runtime SmartPlaylist model

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist.dart`

**Step 1: Write test**

Create `packages/audiflow_domain/test/features/feed/models/smart_playlist_year_grouped_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:test/test.dart';

void main() {
  group('SmartPlaylist.yearGrouped', () {
    test('defaults to false', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
      );
      expect(playlist.yearGrouped, isFalse);
    });

    test('can be set to true', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearGrouped: true,
      );
      expect(playlist.yearGrouped, isTrue);
    });

    test('copyWith preserves yearGrouped', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearGrouped: true,
      );
      final copy = playlist.copyWith(displayName: 'Updated');
      expect(copy.yearGrouped, isTrue);
    });
  });
}
```

**Step 2: Run test to verify it fails**

```bash
cd packages/audiflow_domain && dart test test/features/feed/models/smart_playlist_year_grouped_test.dart
```

Expected: FAIL (no yearGrouped field yet)

**Step 3: Add yearGrouped field to SmartPlaylist**

```dart
final class SmartPlaylist {
  const SmartPlaylist({
    required this.id,
    required this.displayName,
    required this.sortKey,
    required this.episodeIds,
    this.thumbnailUrl,
    this.yearGrouped = false,
  });

  // ... existing fields ...

  /// Whether episodes in this playlist are grouped by year in the UI.
  final bool yearGrouped;

  SmartPlaylist copyWith({
    String? id,
    String? displayName,
    int? sortKey,
    List<int>? episodeIds,
    String? thumbnailUrl,
    bool? yearGrouped,
  }) {
    return SmartPlaylist(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      sortKey: sortKey ?? this.sortKey,
      episodeIds: episodeIds ?? this.episodeIds,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      yearGrouped: yearGrouped ?? this.yearGrouped,
    );
  }
}
```

**Step 4: Run test to verify it passes**

**Step 5: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "feat(domain): add yearGrouped to SmartPlaylist model"
```

---

## Phase 6: CategoryResolver + NewsConnect Pattern

### Task 23: Create CategoryResolver

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/resolvers/category_resolver.dart`
- Create: `packages/audiflow_domain/test/features/feed/resolvers/category_resolver_test.dart`

**Step 1: Write test**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:test/test.dart';

// Helper to create a minimal Episode-like object for testing.
// Use the test helper already in the project if one exists, otherwise
// create mock episodes with the fields the resolver needs.

void main() {
  group('CategoryResolver', () {
    late CategoryResolver resolver;

    setUp(() {
      resolver = CategoryResolver();
    });

    test('type is "category"', () {
      expect(resolver.type, 'category');
    });

    test('returns null without pattern', () {
      final result = resolver.resolve([], null);
      expect(result, isNull);
    });

    test('returns null without categories config', () {
      final pattern = SmartPlaylistPattern(
        id: 'test',
        resolverType: 'category',
        config: {},
      );
      final result = resolver.resolve([], pattern);
      expect(result, isNull);
    });

    test('groups episodes by category pattern', () {
      // Test with NewsConnect-style categories
      final pattern = SmartPlaylistPattern(
        id: 'news_connect',
        resolverType: 'category',
        config: {
          'categories': [
            {
              'id': 'daily_news',
              'displayName': 'Daily News',
              'pattern': r'【\d+月\d+日】',
              'yearGrouped': true,
              'sortKey': 1,
            },
            {
              'id': 'programs',
              'displayName': 'Programs',
              'pattern': r'【(?!\d+月\d+日)(\S+)',
              'yearGrouped': false,
              'sortKey': 2,
            },
          ],
        },
      );

      // Create test episodes (need actual Episode instances from Drift)
      // This test will use the Episode Drift model directly
      // Episodes will be created via test helpers

      // Verify: daily_news playlist has weekday episodes
      // Verify: programs playlist has sat/sun/special episodes
      // Verify: yearGrouped flags are set correctly per playlist
    });
  });
}
```

Note: The exact Episode construction depends on the Drift-generated model. The implementer should read existing test helpers in the test directory and use the same pattern.

**Step 2: Implement CategoryResolver**

```dart
import '../../../common/database/app_database.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern.dart';
import '../models/smart_playlist_sort.dart';
import 'smart_playlist_resolver.dart';

/// Resolver that groups episodes into predefined categories by title pattern.
///
/// Reads category definitions from the pattern's config. Each category has
/// a regex pattern, display name, sort key, and yearGrouped flag.
/// Episodes are matched against categories in order (first match wins).
class CategoryResolver implements SmartPlaylistResolver {
  @override
  String get type => 'category';

  @override
  SmartPlaylistSortSpec get defaultSort => const SimpleSmartPlaylistSort(
    SmartPlaylistSortField.playlistNumber,
    SortOrder.ascending,
  );

  @override
  SmartPlaylistGrouping? resolve(
    List<Episode> episodes,
    SmartPlaylistPattern? pattern,
  ) {
    if (pattern == null) return null;

    final categoriesRaw = pattern.config['categories'] as List<dynamic>?;
    if (categoriesRaw == null || categoriesRaw.isEmpty) return null;

    final categories = categoriesRaw.cast<Map<String, dynamic>>();

    // Build regex list
    final matchers = categories.map((c) {
      return (
        regex: RegExp(c['pattern'] as String),
        id: c['id'] as String,
        displayName: c['displayName'] as String,
        yearGrouped: c['yearGrouped'] as bool? ?? false,
        sortKey: c['sortKey'] as int,
      );
    }).toList();

    final grouped = <String, List<Episode>>{};
    final ungrouped = <int>[];

    for (final episode in episodes) {
      var matched = false;
      for (final matcher in matchers) {
        if (matcher.regex.hasMatch(episode.title)) {
          grouped.putIfAbsent(matcher.id, () => []).add(episode);
          matched = true;
          break;
        }
      }
      if (!matched) {
        ungrouped.add(episode.id);
      }
    }

    if (grouped.isEmpty) return null;

    final playlists = matchers
        .where((m) => grouped.containsKey(m.id))
        .map((m) => SmartPlaylist(
              id: 'playlist_${m.id}',
              displayName: m.displayName,
              sortKey: m.sortKey,
              episodeIds: grouped[m.id]!.map((e) => e.id).toList(),
              yearGrouped: m.yearGrouped,
            ))
        .toList();

    return SmartPlaylistGrouping(
      playlists: playlists,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }
}
```

Note: The field name in `SmartPlaylistGrouping` should be `playlists` (renamed from `seasons` in Task 6). If it was renamed to `smartPlaylists` or kept as `seasons`, adjust accordingly.

**Step 3: Run test**

```bash
cd packages/audiflow_domain && dart test test/features/feed/resolvers/category_resolver_test.dart
```

**Step 4: Register in resolver service**

In `smart_playlist_providers.dart`, add `CategoryResolver()` to the resolvers list:

```dart
SmartPlaylistResolverService(
  resolvers: [RssMetadataResolver(), CategoryResolver(), YearResolver()],
  patterns: _registeredPatterns,
);
```

**Step 5: Export from audiflow_domain.dart**

```dart
export 'src/features/feed/resolvers/category_resolver.dart';
```

**Step 6: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "feat(domain): add CategoryResolver for predefined episode grouping"
```

### Task 24: Create NewsConnect pattern

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/patterns/news_connect_pattern.dart`
- Create: `packages/audiflow_domain/test/features/feed/patterns/news_connect_pattern_test.dart`

**Step 1: Write test**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:test/test.dart';

void main() {
  group('newsConnectPattern', () {
    test('matches anchor.fm feed URL', () {
      expect(
        newsConnectPattern.matchesPodcast(
          null,
          'https://anchor.fm/s/81fb5eec/podcast/rss',
        ),
        isTrue,
      );
    });

    test('does not match other feed URLs', () {
      expect(
        newsConnectPattern.matchesPodcast(
          null,
          'https://anchor.fm/s/8c2088c/podcast/rss',
        ),
        isFalse,
      );
    });

    test('has category resolver type', () {
      expect(newsConnectPattern.resolverType, 'category');
    });

    test('defines 2 categories', () {
      final categories =
          newsConnectPattern.config['categories'] as List<dynamic>;
      expect(categories.length, 2);
    });
  });
}
```

**Step 2: Run test - expect failure**

**Step 3: Implement pattern**

```dart
import '../models/smart_playlist_pattern.dart';

/// Pre-configured SmartPlaylistPattern for NewsConnect podcast.
///
/// Groups episodes into two smart playlists:
/// - Daily News: weekday episodes matching 【MM月DD日】pattern (yearGrouped)
/// - Programs: all other episodes (土曜版, ニュース小話, 特別編)
const SmartPlaylistPattern newsConnectPattern = SmartPlaylistPattern(
  id: 'news_connect',
  feedUrlPatterns: [
    r'https://anchor\.fm/s/81fb5eec/podcast/rss',
    r'https://.*anchor\.fm.*81fb5eec.*',
  ],
  resolverType: 'category',
  config: {
    'categories': [
      {
        'id': 'daily_news',
        'displayName': '平日版',
        'pattern': r'【\d+月\d+日】',
        'yearGrouped': true,
        'sortKey': 1,
      },
      {
        'id': 'programs',
        'displayName': '特集',
        'pattern': r'【(?!\d+月\d+日)\S+',
        'yearGrouped': false,
        'sortKey': 2,
      },
    ],
  },
);
```

Note: Display names are hardcoded in Japanese here. When the l10n system is wired into the resolver (a future enhancement), these can be replaced with l10n keys. For now, the display name in the pattern config is used directly.

**Step 4: Run test - expect pass**

**Step 5: Register pattern in providers**

In `smart_playlist_providers.dart`:

```dart
import '../patterns/news_connect_pattern.dart';

const _registeredPatterns = [cotenRadioPattern, newsConnectPattern];
```

**Step 6: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "feat(domain): add NewsConnect smart playlist pattern"
```

### Task 25: Update COTEN pattern for yearGrouped

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/patterns/coten_radio_pattern.dart`
- Modify: `packages/audiflow_domain/test/features/feed/patterns/coten_radio_pattern_test.dart`

**Step 1: Read existing COTEN pattern and tests**

**Step 2: Add yearGrouped configuration**

The COTEN pattern uses the `rss` resolver type. The yearGrouped flag needs to flow from the pattern config to the resolved SmartPlaylist objects.

Add to pattern config:
```dart
config: {
  'groupNullSeasonAs': 0,
  'yearGroupedPlaylists': {
    0: true,    // 番外編 (season 0) -> yearGrouped
  },
  'catchAllPlaylist': {
    'displayName': 'その他',
    'yearGrouped': true,
  },
},
```

Note: The RssMetadataResolver will need to read `yearGroupedPlaylists` from config and set `yearGrouped` on the appropriate SmartPlaylist objects. This requires a modification to the resolver.

**Step 3: Update RssMetadataResolver to support yearGrouped config**

In `rss_metadata_resolver.dart`, after building SmartPlaylist objects, check if the pattern config has `yearGroupedPlaylists` and set the flag:

```dart
final yearGroupedMap = pattern?.config['yearGroupedPlaylists'] as Map<String, dynamic>?;
// When building each SmartPlaylist, check if its sortKey (season number) is in the map
```

**Step 4: Add catch-all logic for その他**

Episodes that don't match any known COTEN season pattern (not standard seasons, not 番外編) should be grouped into an "その他" playlist with `yearGrouped: true`.

This may require updating the `titleExtractor` to have a second fallback level, or adding a `catchAllPlaylist` config that the resolver reads.

**Step 5: Update tests**

Add test cases verifying:
- 番外編 episodes get `yearGrouped: true`
- Standard seasons get `yearGrouped: false`
- Unmatched episodes go to その他 with `yearGrouped: true`

**Step 6: Run tests**

```bash
cd packages/audiflow_domain && dart test test/features/feed/patterns/coten_radio_pattern_test.dart
```

**Step 7: Commit**

```bash
git add -A packages/audiflow_domain/
git commit -m "feat(domain): add yearGrouped and catch-all to COTEN pattern"
```

---

## Phase 7: UI Updates

### Task 26: Update SmartPlaylist episodes screen for year grouping

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart`

**Step 1: Read current screen implementation**

**Step 2: Add year section headers**

When the SmartPlaylist has `yearGrouped: true`, group episodes by `publishedAt` year and render sticky year headers:

```dart
// Pseudocode for the build method:
if (playlist.yearGrouped) {
  // Group episodes by year (descending)
  final episodesByYear = <int, List<Episode>>{};
  for (final ep in episodes) {
    final year = ep.publishedAt?.year ?? 0;
    episodesByYear.putIfAbsent(year, () => []).add(ep);
  }
  final sortedYears = episodesByYear.keys.toList()
    ..sort((a, b) => b.compareTo(a)); // newest first

  return SliverList(
    delegate: SliverChildBuilderDelegate((context, index) {
      // Interleave year headers and episode tiles
    }),
  );
} else {
  // Existing flat list behavior
}
```

**Step 3: Commit**

```bash
git add -A packages/audiflow_app/
git commit -m "feat(app): add year section headers for yearGrouped playlists"
```

### Task 27: Update SmartPlaylist card to show yearGrouped indicator

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/smart_playlist_card.dart`

**Step 1: Read current card widget**

**Step 2: Optionally add a small visual indicator**

This is a minor UI enhancement. The card could show a calendar icon or year badge when `yearGrouped` is true. Keep it simple.

**Step 3: Commit**

```bash
git add -A packages/audiflow_app/
git commit -m "feat(app): add yearGrouped visual indicator to smart playlist card"
```

---

## Phase 8: Final Verification

### Task 28: Run full test suite

**Step 1: Run all tests**

```bash
melos run test
```

**Step 2: Run analyze**

```bash
melos run analyze
```

**Step 3: Fix any failures**

**Step 4: Commit fixes if needed**

### Task 29: Run format and fix

**Step 1: Format all code**

Use `dart_format` tool on all modified packages.

**Step 2: Run dart fix**

Use `dart_fix` tool on all modified packages.

**Step 3: Commit**

```bash
git add -A
git commit -m "chore: format and fix after smart playlist implementation"
```

### Task 30: Verify app builds

**Step 1: Build the app**

```bash
cd packages/audiflow_app && flutter build apk --flavor dev -t lib/main_dev.dart --debug
```

Expected: Build succeeds.

**Step 2: Commit any remaining fixes**

---

## Dependency Graph

```
Task 1-5 (i18n) -> independent, do first
Task 6-15 (domain rename) -> sequential, each depends on previous
Task 15 (build_runner) -> depends on all domain renames
Task 16-18 (app rename) -> depends on Task 15
Task 19 (build_runner all) -> depends on Task 16-18
Task 20 (tests rename) -> depends on Task 19
Task 21 (DB migration) -> depends on Task 7 (Drift table rename)
Task 22 (yearGrouped model) -> depends on Task 6
Task 23 (CategoryResolver) -> depends on Task 10 (resolver interface)
Task 24 (NewsConnect pattern) -> depends on Task 23
Task 25 (COTEN update) -> depends on Task 8, Task 22
Task 26-27 (UI) -> depends on Task 16, Task 22
Task 28-30 (verification) -> depends on all above
```

## Key Risks

1. **Generated file conflicts**: Build_runner may fail if imports reference deleted files. Run build_runner after each major rename batch.
2. **DB migration ordering**: The table rename must happen before any code references the new table name at runtime. Test migration with both fresh install and upgrade scenarios.
3. **86 files affected**: High risk of missed references. Use IDE global search after each rename batch.
4. **CLI package**: May have its own test infrastructure. Check before assuming domain test helpers work there.
