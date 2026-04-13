# Schema v4 Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adopt upstream smartplaylist schema v4 — rename enums, fields, resolvers, and classes; remove deprecated fields; update all tests and vendored schemas.

**Architecture:** Pure rename + simplification. No new features. Domain model renames propagate from definition models through resolvers, services, providers, and into app/CLI. The Isar entity (`SmartPlaylistEntity`) keeps its `playlistStructure` DB column name for backward compat but stores new values (`separate`/`combined`). `Presentation.fromString()` handles both old and new values for cached data.

**Tech Stack:** Dart, Flutter, Isar, Riverpod

---

## File Map

### Create
- (none — all changes are modifications or file renames)

### Modify (models)
- `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist.dart` — rename `PlaylistStructure` → `Presentation`, values `split`→`separate` / `grouped`→`combined`; rename `playlistStructure` field → `presentation` on `SmartPlaylist`
- `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_definition.dart` — rename `playlistStructure` → `presentation` (required), `episodeExtractor` → `numberingExtractor`; remove `priority`, `nullSeasonGroupKey`
- `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_def.dart` — rename `episodeExtractor` → `numberingExtractor`
- `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_episode_extractor.dart` — rename class `SmartPlaylistEpisodeExtractor` → `NumberingExtractor`; rename file to `numbering_extractor.dart`
- `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_pattern.dart` — rename `episodeExtractor` → `numberingExtractor` (deprecated class, but keep aligned)
- `packages/audiflow_domain/lib/src/features/feed/models/group_list_config.dart` — update doc comment ref only

### Modify (resolvers — file renames + class renames + type string changes)
- `rss_metadata_resolver.dart` → `season_number_resolver.dart`: `RssMetadataResolver` → `SeasonNumberResolver`, type `'rss'` → `'seasonNumber'`; remove `nullSeasonGroupKey` handling
- `category_resolver.dart` → `title_classifier_resolver.dart`: `CategoryResolver` → `TitleClassifierResolver`, type `'category'` → `'titleClassifier'`; update doc comment ref to `playlistStructure`→`presentation`
- `title_appearance_order_resolver.dart` → `title_discovery_resolver.dart`: `TitleAppearanceOrderResolver` → `TitleDiscoveryResolver`, type `'titleAppearanceOrder'` → `'titleDiscovery'`

### Modify (services)
- `smart_playlist_resolver_service.dart` — remove priority sorting; rename `PlaylistStructure` → `Presentation`, `playlistStructure` → `presentation`
- `episode_extractor_resolver.dart` — rename `SmartPlaylistEpisodeExtractor` → `NumberingExtractor`, field refs `episodeExtractor` → `numberingExtractor`

### Modify (providers)
- `smart_playlist_providers.dart` — rename resolver classes, `PlaylistStructure` → `Presentation`, `playlistStructure` → `presentation` on entity

### Modify (barrel files)
- `audiflow_domain.dart` — update export paths for renamed files
- `patterns.dart` — update export paths for renamed files

### Modify (app)
- `inline_playlist_section.dart` — `PlaylistStructure` → `Presentation`, `playlistStructure` → `presentation`, `grouped` → `combined`
- `smart_playlist_episodes_screen.dart` — same renames

### Modify (CLI)
- `smart_playlist_episode_extractor_diagnostics.dart` — `SmartPlaylistEpisodeExtractor` → `NumberingExtractor`; rename file to `numbering_extractor_diagnostics.dart`
- `smart_playlist_debug_command.dart` — update import

### Modify (vendored schemas)
- `test/fixtures/playlist-definition.schema.json` — replace with v4
- `test/fixtures/pattern-index.schema.json` — replace with v4
- `test/fixtures/pattern-meta.schema.json` — replace with v4

### Modify (tests — all under `packages/audiflow_domain/test/features/feed/`)
- `models/schema_conformance_test.dart` — update all enum assertions, schema version, resolver types, field names
- `models/smart_playlist_test.dart` — `PlaylistStructure` → `Presentation`, value renames
- `models/smart_playlist_definition_test.dart` — remove `priority`/`nullSeasonGroupKey`, rename fields/resolver types
- `models/smart_playlist_episode_extractor_test.dart` — rename class, rename file
- `resolvers/rss_metadata_resolver_test.dart` → `season_number_resolver_test.dart` — rename class, type, remove `nullSeasonGroupKey` test
- `resolvers/category_resolver_test.dart` → `title_classifier_resolver_test.dart` — rename class, type
- `resolvers/title_appearance_order_resolver_test.dart` → `title_discovery_resolver_test.dart` — rename class, type
- `services/smart_playlist_resolver_service_test.dart` — rename resolver classes, types, `playlistStructure` → `presentation` values
- `providers/enrich_playlist_test.dart` — `PlaylistStructure` → `Presentation`, `playlistStructure` → `presentation` values

---

### Task 1: Copy vendored v4 schemas

**Files:**
- Modify: `packages/audiflow_domain/test/fixtures/playlist-definition.schema.json`
- Modify: `packages/audiflow_domain/test/fixtures/pattern-index.schema.json`
- Modify: `packages/audiflow_domain/test/fixtures/pattern-meta.schema.json`

- [ ] **Step 1: Copy v4 schemas from the smartplaylist repo**

```bash
cp $SMARTPLAYLIST_REPO/schema/playlist-definition.schema.json \
   packages/audiflow_domain/test/fixtures/playlist-definition.schema.json

cp $SMARTPLAYLIST_REPO/schema/pattern-index.schema.json \
   packages/audiflow_domain/test/fixtures/pattern-index.schema.json

cp $SMARTPLAYLIST_REPO/schema/pattern-meta.schema.json \
   packages/audiflow_domain/test/fixtures/pattern-meta.schema.json
```

- [ ] **Step 2: Verify schemas are v4**

```bash
grep '"$id"' packages/audiflow_domain/test/fixtures/*.schema.json
```

Expected: all three contain `v4` in the URI.

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/test/fixtures/*.schema.json
git commit -m "chore(domain): vendor v4 smartplaylist schemas"
```

---

### Task 2: Rename PlaylistStructure enum to Presentation

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist.dart`

- [ ] **Step 1: Rename enum and values**

In `smart_playlist.dart`, rename:
- `PlaylistStructure` → `Presentation`
- `split` → `separate`
- `grouped` → `combined`
- `fromString` handles both old (`split`/`grouped`) and new values for Isar cache compat:

```dart
enum Presentation {
  separate,
  combined;

  static Presentation fromString(String? value) {
    return switch (value) {
      'combined' || 'grouped' => Presentation.combined,
      _ => Presentation.separate,
    };
  }
}
```

- [ ] **Step 2: Rename field on SmartPlaylist class**

In the same file, rename `playlistStructure` → `presentation` on `SmartPlaylist`:
- Constructor parameter: `this.playlistStructure` → `this.presentation`
- Field declaration: `final PlaylistStructure playlistStructure` → `final Presentation presentation`
- Default value: `PlaylistStructure.split` → `Presentation.separate`
- `copyWith` parameter and body: rename accordingly

- [ ] **Step 3: Rename field on SmartPlaylistGrouping**

No changes needed — `SmartPlaylistGrouping` has no `playlistStructure` field.

- [ ] **Step 4: Run analyze to find all compile errors**

```bash
cd packages/audiflow_domain && flutter analyze 2>&1 | head -50
```

Expected: compile errors in files that still reference `PlaylistStructure` / `playlistStructure`. Do NOT fix yet — subsequent tasks handle each file.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlist.dart
git commit -m "refactor(domain): rename PlaylistStructure to Presentation with v4 values"
```

---

### Task 3: Rename SmartPlaylistEpisodeExtractor to NumberingExtractor

**Files:**
- Rename: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_episode_extractor.dart` → `numbering_extractor.dart`

- [ ] **Step 1: Rename the file**

```bash
cd packages/audiflow_domain
git mv lib/src/features/feed/models/smart_playlist_episode_extractor.dart \
       lib/src/features/feed/models/numbering_extractor.dart
```

- [ ] **Step 2: Rename the class inside the file**

In `numbering_extractor.dart`:
- Rename `SmartPlaylistEpisodeExtractor` → `NumberingExtractor` (class name and factory)
- Keep `SmartPlaylistEpisodeResult` as-is (it's a result type, not a schema type)

- [ ] **Step 3: Update imports in model files that reference the old name**

Update import in each file from `smart_playlist_episode_extractor.dart` to `numbering_extractor.dart` and class references from `SmartPlaylistEpisodeExtractor` to `NumberingExtractor`:

- `smart_playlist_definition.dart`
- `smart_playlist_group_def.dart`
- `smart_playlist_pattern.dart`
- `episode_extractor_resolver.dart` (service)

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor(domain): rename SmartPlaylistEpisodeExtractor to NumberingExtractor"
```

---

### Task 4: Update SmartPlaylistDefinition

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_definition.dart`

- [ ] **Step 1: Remove `priority` and `nullSeasonGroupKey` fields**

Remove from constructor, field declarations, fromJson, and toJson:
- `this.priority = 0` → delete
- `this.nullSeasonGroupKey` → delete
- `final int priority;` → delete
- `final int? nullSeasonGroupKey;` → delete
- Remove from `fromJson`: `priority: (json['priority'] as int?) ?? 0,` and `nullSeasonGroupKey: json['nullSeasonGroupKey'] as int?,`
- Remove from `toJson`: `if (priority != 0) 'priority': priority,` and `if (nullSeasonGroupKey != null) 'nullSeasonGroupKey': nullSeasonGroupKey,`

- [ ] **Step 2: Rename `playlistStructure` to `presentation` (make required)**

- Constructor: `this.playlistStructure,` → `required this.presentation,`
- Field: `final String? playlistStructure;` → `final String presentation;`
- fromJson: `playlistStructure: json['playlistStructure'] as String?,` → `presentation: json['presentation'] as String,`
- toJson: `if (playlistStructure != null) 'playlistStructure': playlistStructure,` → `'presentation': presentation,`

- [ ] **Step 3: Rename `episodeExtractor` to `numberingExtractor`**

- Constructor: `this.episodeExtractor,` → `this.numberingExtractor,`
- Field: `final NumberingExtractor? episodeExtractor;` → `final NumberingExtractor? numberingExtractor;`
- fromJson: rename both the JSON key and the field:
  ```dart
  numberingExtractor: json['numberingExtractor'] != null
      ? NumberingExtractor.fromJson(
          json['numberingExtractor'] as Map<String, dynamic>,
        )
      : null,
  ```
- toJson: `if (episodeExtractor != null) 'episodeExtractor': episodeExtractor!.toJson(),` → `if (numberingExtractor != null) 'numberingExtractor': numberingExtractor!.toJson(),`

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_definition.dart
git commit -m "refactor(domain): update SmartPlaylistDefinition for v4 schema"
```

---

### Task 5: Update SmartPlaylistGroupDef

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_def.dart`

- [ ] **Step 1: Rename `episodeExtractor` to `numberingExtractor`**

- Constructor: `this.episodeExtractor,` → `this.numberingExtractor,`
- Field: `final NumberingExtractor? episodeExtractor;` → `final NumberingExtractor? numberingExtractor;`
- fromJson: change JSON key from `'episodeExtractor'` to `'numberingExtractor'`
- toJson: change key from `'episodeExtractor'` to `'numberingExtractor'`
- Update import from `smart_playlist_episode_extractor.dart` to `numbering_extractor.dart` (if not done in Task 3)

- [ ] **Step 2: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_def.dart
git commit -m "refactor(domain): rename episodeExtractor to numberingExtractor in GroupDef"
```

---

### Task 6: Update SmartPlaylistPattern (deprecated model)

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_pattern.dart`

- [ ] **Step 1: Rename `episodeExtractor` field to `numberingExtractor`**

- Constructor parameter and field declaration
- Update import

- [ ] **Step 2: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_pattern.dart
git commit -m "refactor(domain): rename episodeExtractor in deprecated SmartPlaylistPattern"
```

---

### Task 7: Rename resolver files and classes

**Files:**
- Rename: `resolvers/rss_metadata_resolver.dart` → `resolvers/season_number_resolver.dart`
- Rename: `resolvers/category_resolver.dart` → `resolvers/title_classifier_resolver.dart`
- Rename: `resolvers/title_appearance_order_resolver.dart` → `resolvers/title_discovery_resolver.dart`

- [ ] **Step 1: Rename files**

```bash
cd packages/audiflow_domain/lib/src/features/feed
git mv resolvers/rss_metadata_resolver.dart resolvers/season_number_resolver.dart
git mv resolvers/category_resolver.dart resolvers/title_classifier_resolver.dart
git mv resolvers/title_appearance_order_resolver.dart resolvers/title_discovery_resolver.dart
```

- [ ] **Step 2: Rename SeasonNumberResolver (was RssMetadataResolver)**

In `season_number_resolver.dart`:
- Class: `RssMetadataResolver` → `SeasonNumberResolver`
- `type`: `'rss'` → `'seasonNumber'`
- Remove `nullSeasonGroupKey` handling from `_resolveBySeasonNumber`:
  - Remove `final groupNullAs = definition?.nullSeasonGroupKey;`
  - Remove the `else if (groupNullAs != null)` branch — episodes without season go straight to `ungrouped`
- Update doc comment

```dart
class SeasonNumberResolver implements SmartPlaylistResolver {
  @override
  String get type => 'seasonNumber';

  // ... rest stays the same except nullSeasonGroupKey removal
```

- [ ] **Step 3: Rename TitleClassifierResolver (was CategoryResolver)**

In `title_classifier_resolver.dart`:
- Class: `CategoryResolver` → `TitleClassifierResolver`
- `type`: `'category'` → `'titleClassifier'`
- Update doc comment (change `playlistStructure` ref to `presentation`)

```dart
class TitleClassifierResolver implements SmartPlaylistResolver {
  @override
  String get type => 'titleClassifier';
```

- [ ] **Step 4: Rename TitleDiscoveryResolver (was TitleAppearanceOrderResolver)**

In `title_discovery_resolver.dart`:
- Class: `TitleAppearanceOrderResolver` → `TitleDiscoveryResolver`
- `type`: `'titleAppearanceOrder'` → `'titleDiscovery'`

```dart
class TitleDiscoveryResolver implements SmartPlaylistResolver {
  @override
  String get type => 'titleDiscovery';
```

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor(domain): rename resolvers for v4 schema"
```

---

### Task 8: Update resolver service

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/smart_playlist_resolver_service.dart`

- [ ] **Step 1: Remove priority-based sorting**

Replace `_sortByProcessingOrder` to only separate filtered vs fallback definitions without sorting by priority:

```dart
static List<SmartPlaylistDefinition> _sortByProcessingOrder(
  List<SmartPlaylistDefinition> definitions,
) {
  final filtered = <SmartPlaylistDefinition>[];
  final fallbacks = <SmartPlaylistDefinition>[];

  for (final def in definitions) {
    if (_hasFilters(def)) {
      filtered.add(def);
    } else {
      fallbacks.add(def);
    }
  }

  return [...filtered, ...fallbacks];
}
```

- [ ] **Step 2: Rename PlaylistStructure → Presentation references**

In `_resolveWithConfig`:
- `final playlistStructure = PlaylistStructure.fromString(definition.playlistStructure,);` → `final presentation = Presentation.fromString(definition.presentation,);`
- `if (playlistStructure == PlaylistStructure.grouped)` → `if (presentation == Presentation.combined)`
- In the SmartPlaylist constructor calls: `playlistStructure: playlistStructure,` → `presentation: presentation,`

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/smart_playlist_resolver_service.dart
git commit -m "refactor(domain): update resolver service for v4 schema"
```

---

### Task 9: Update EpisodeExtractorResolver service

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/episode_extractor_resolver.dart`

- [ ] **Step 1: Rename references**

- Import: `smart_playlist_episode_extractor.dart` → `numbering_extractor.dart`
- Return type and field refs: `SmartPlaylistEpisodeExtractor` → `NumberingExtractor`
- `definition.episodeExtractor` → `definition.numberingExtractor`
- `group.episodeExtractor` → `group.numberingExtractor`

- [ ] **Step 2: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/episode_extractor_resolver.dart
git commit -m "refactor(domain): update EpisodeExtractorResolver for v4 naming"
```

---

### Task 10: Update providers

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/providers/smart_playlist_providers.dart`

- [ ] **Step 1: Update resolver imports and instantiation**

Replace imports:
```dart
import '../resolvers/category_resolver.dart';
import '../resolvers/rss_metadata_resolver.dart';
import '../resolvers/title_appearance_order_resolver.dart';
```
with:
```dart
import '../resolvers/season_number_resolver.dart';
import '../resolvers/title_classifier_resolver.dart';
import '../resolvers/title_discovery_resolver.dart';
```

Replace all instantiations:
- `RssMetadataResolver()` → `SeasonNumberResolver()`
- `CategoryResolver()` → `TitleClassifierResolver()`
- `TitleAppearanceOrderResolver()` → `TitleDiscoveryResolver()`

This occurs in three places: `smartPlaylistResolverService`, `_resolveAndPersistSmartPlaylists`, and `_reResolveFromEpisodes`.

- [ ] **Step 2: Rename PlaylistStructure → Presentation in cache code**

In `_buildGroupingFromCache`:
- `PlaylistStructure.grouped` → `Presentation.combined`
- `PlaylistStructure.fromString(entity.playlistStructure)` → `Presentation.fromString(entity.playlistStructure)`
- `playlistStructure: playlistStructure,` → `presentation: playlistStructure,` (keep variable name `playlistStructure` since it reads from entity field, but pass to `presentation` parameter)

Actually, for clarity rename the local variable too:
```dart
final presentation = groups != null && groups.isNotEmpty
    ? Presentation.combined
    : Presentation.fromString(entity.playlistStructure);

playlists.add(
  SmartPlaylist(
    ...
    presentation: presentation,
    ...
  ),
);
```

In `_enrichPlaylist`:
- `..playlistStructure = playlist.playlistStructure.name` → `..playlistStructure = playlist.presentation.name`

- [ ] **Step 3: Rename `SmartPlaylistSchemaVersion` doc comment**

Update `dev/v3` reference to `dev/v4` in the doc comment.

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/providers/smart_playlist_providers.dart
git commit -m "refactor(domain): update providers for v4 resolver names and presentation enum"
```

---

### Task 11: Update barrel files

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`
- Modify: `packages/audiflow_domain/lib/patterns.dart`

- [ ] **Step 1: Update audiflow_domain.dart exports**

```dart
// Old:
export 'src/features/feed/models/smart_playlist_episode_extractor.dart';
export 'src/features/feed/resolvers/category_resolver.dart';
export 'src/features/feed/resolvers/rss_metadata_resolver.dart';
export 'src/features/feed/resolvers/title_appearance_order_resolver.dart';

// New:
export 'src/features/feed/models/numbering_extractor.dart';
export 'src/features/feed/resolvers/season_number_resolver.dart';
export 'src/features/feed/resolvers/title_classifier_resolver.dart';
export 'src/features/feed/resolvers/title_discovery_resolver.dart';
```

- [ ] **Step 2: Update patterns.dart exports**

```dart
// Old:
export 'src/features/feed/models/smart_playlist_episode_extractor.dart';

// New:
export 'src/features/feed/models/numbering_extractor.dart';
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/audiflow_domain.dart packages/audiflow_domain/lib/patterns.dart
git commit -m "refactor(domain): update barrel exports for v4 file renames"
```

---

### Task 12: Update app-level code

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/inline_playlist_section.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart`

- [ ] **Step 1: Update inline_playlist_section.dart**

- Import: `PlaylistStructure,` → `Presentation,`
- Usage: `playlist.playlistStructure == PlaylistStructure.grouped` → `playlist.presentation == Presentation.combined`

- [ ] **Step 2: Update smart_playlist_episodes_screen.dart**

- Usage: `widget.smartPlaylist.playlistStructure == PlaylistStructure.grouped` → `widget.smartPlaylist.presentation == Presentation.combined` (two occurrences)

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/
git commit -m "refactor(app): update presentation references for v4 schema"
```

---

### Task 13: Update CLI code

**Files:**
- Rename: `packages/audiflow_cli/lib/src/diagnostics/smart_playlist_episode_extractor_diagnostics.dart` → `numbering_extractor_diagnostics.dart`
- Modify: `packages/audiflow_cli/lib/src/commands/smart_playlist_debug_command.dart`

- [ ] **Step 1: Rename diagnostics file**

```bash
cd packages/audiflow_cli
git mv lib/src/diagnostics/smart_playlist_episode_extractor_diagnostics.dart \
       lib/src/diagnostics/numbering_extractor_diagnostics.dart
```

- [ ] **Step 2: Rename class in diagnostics file**

In `numbering_extractor_diagnostics.dart`:
- `SmartPlaylistEpisodeExtractorDiagnostics` → `NumberingExtractorDiagnostics`
- `SmartPlaylistEpisodeExtractor` → `NumberingExtractor` (field type and doc refs)
- Keep `SmartPlaylistEpisodeDiagnosticResult` as-is

- [ ] **Step 3: Update import in debug command**

In `smart_playlist_debug_command.dart`:
- Update import path
- Update class reference: `SmartPlaylistEpisodeExtractorDiagnostics` → `NumberingExtractorDiagnostics`

- [ ] **Step 4: Check CLI barrel file for exports**

Search for and update any export of the old file name in `packages/audiflow_cli/lib/audiflow_cli.dart`.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_cli/
git commit -m "refactor(cli): rename diagnostics for v4 NumberingExtractor"
```

---

### Task 14: Update domain model tests

**Files:**
- Modify: `packages/audiflow_domain/test/features/feed/models/smart_playlist_test.dart`
- Modify: `packages/audiflow_domain/test/features/feed/models/smart_playlist_definition_test.dart`
- Rename+Modify: `test/features/feed/models/smart_playlist_episode_extractor_test.dart` → `numbering_extractor_test.dart`

- [ ] **Step 1: Update smart_playlist_test.dart**

- `PlaylistStructure` → `Presentation` everywhere
- `.split` → `.separate`, `.grouped` → `.combined`
- `playlistStructure` → `presentation` (field access and constructor args)
- Test names: update `'playlistStructure'` to `'presentation'` in descriptions
- Resolver type string `'rss'` → `'seasonNumber'` in SmartPlaylistGrouping test data

```dart
group('Presentation', () {
  test('has separate and combined values', () {
    expect(Presentation.values, hasLength(2));
    expect(Presentation.separate.name, 'separate');
    expect(Presentation.combined.name, 'combined');
  });
});
```

```dart
test('defaults to separate presentation with no year binding', () {
  // ...
  expect(playlist.presentation, Presentation.separate);
});

test('supports combined presentation', () {
  // ...
  final playlist = SmartPlaylist(
    // ...
    presentation: Presentation.combined,
    yearBinding: YearBinding.pinToYear,
    groups: groups,
  );
  expect(playlist.presentation, Presentation.combined);
});
```

- [ ] **Step 2: Update smart_playlist_definition_test.dart**

- Remove `priority` and `nullSeasonGroupKey` from test data and assertions
- Rename `episodeExtractor:` → `numberingExtractor:` in constructor calls
- `SmartPlaylistEpisodeExtractor` → `NumberingExtractor`
- Rename `resolverType: 'rss'` → `resolverType: 'seasonNumber'` and `'category'` → `'titleClassifier'`
- Add `presentation: 'separate'` or `'combined'` to all definitions (now required)
- Remove assertion `expect(decoded.priority, ...)` and `expect(decoded.nullSeasonGroupKey, ...)`
- Update minimal definition test: `presentation` is now required, so add it; assert it appears in JSON keys
- Rename `decoded.episodeExtractor` → `decoded.numberingExtractor`

- [ ] **Step 3: Rename episode extractor test file**

```bash
cd packages/audiflow_domain
git mv test/features/feed/models/smart_playlist_episode_extractor_test.dart \
       test/features/feed/models/numbering_extractor_test.dart
```

In `numbering_extractor_test.dart`, rename `SmartPlaylistEpisodeExtractor` → `NumberingExtractor` everywhere.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "test(domain): update model tests for v4 schema"
```

---

### Task 15: Update resolver tests

**Files:**
- Rename+Modify: `resolvers/rss_metadata_resolver_test.dart` → `season_number_resolver_test.dart`
- Rename+Modify: `resolvers/category_resolver_test.dart` → `title_classifier_resolver_test.dart`
- Rename+Modify: `resolvers/title_appearance_order_resolver_test.dart` → `title_discovery_resolver_test.dart`

- [ ] **Step 1: Rename test files**

```bash
cd packages/audiflow_domain/test/features/feed
git mv resolvers/rss_metadata_resolver_test.dart resolvers/season_number_resolver_test.dart
git mv resolvers/category_resolver_test.dart resolvers/title_classifier_resolver_test.dart
git mv resolvers/title_appearance_order_resolver_test.dart resolvers/title_discovery_resolver_test.dart
```

- [ ] **Step 2: Update season_number_resolver_test.dart**

- `RssMetadataResolver` → `SeasonNumberResolver`
- `resolver.type` assertion: `'rss'` → `'seasonNumber'`
- `resolverType: 'rss'` → `resolverType: 'seasonNumber'` in definition constructors
- Add `presentation: 'separate'` to all `SmartPlaylistDefinition` constructors
- Remove the `nullSeasonGroupKey` test case entirely (field removed)
- Group name: `'RssMetadataResolver'` → `'SeasonNumberResolver'`
- Remove `nullSeasonGroupKey` from any remaining test definitions

- [ ] **Step 3: Update title_classifier_resolver_test.dart**

- `CategoryResolver` → `TitleClassifierResolver`
- `resolver.type` assertion: `'category'` → `'titleClassifier'`
- `resolverType: 'category'` → `resolverType: 'titleClassifier'` in definitions
- Add `presentation: 'separate'` to all definitions
- Group name: `'CategoryResolver'` → `'TitleClassifierResolver'`

- [ ] **Step 4: Update title_discovery_resolver_test.dart**

- `TitleAppearanceOrderResolver` → `TitleDiscoveryResolver`
- `resolver.type` assertion: `'titleAppearanceOrder'` → `'titleDiscovery'`
- `resolverType: 'titleAppearanceOrder'` → `resolverType: 'titleDiscovery'` in definitions
- Add `presentation: 'separate'` to all definitions
- Group name: `'TitleAppearanceOrderResolver'` → `'TitleDiscoveryResolver'`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "test(domain): rename and update resolver tests for v4"
```

---

### Task 16: Update service and provider tests

**Files:**
- Modify: `test/features/feed/services/smart_playlist_resolver_service_test.dart`
- Modify: `test/features/feed/providers/enrich_playlist_test.dart`

- [ ] **Step 1: Update resolver service test**

- `RssMetadataResolver()` → `SeasonNumberResolver()`
- `resolverType: 'rss'` → `resolverType: 'seasonNumber'` in definitions and assertions
- `result!.resolverType, 'rss'` → `result!.resolverType, 'seasonNumber'`
- `playlistStructure: 'grouped'` → `presentation: 'combined'` in definitions
- `playlistStructure: 'split'` → `presentation: 'separate'` in definitions
- `PlaylistStructure.grouped` → `Presentation.combined` in assertions
- `playlist.playlistStructure` → `playlist.presentation`
- Add `presentation: 'separate'` to all definitions that don't specify it (now required)
- Remove `priority: 10` from filter test definitions (field removed)
- Test names: update `'playlistStructure'` to `'presentation'` in descriptions
- `'wraps resolver playlists as groups when playlistStructure is grouped'` → `'wraps resolver playlists as groups when presentation is combined'`

- [ ] **Step 2: Update enrich_playlist_test.dart**

- `PlaylistStructure.grouped` → `Presentation.combined`
- `PlaylistStructure.fromString(entity.playlistStructure)` → `Presentation.fromString(entity.playlistStructure)` (if referenced)
- `playlistStructure: 'grouped'` → `presentation: 'combined'` in definition constructors
- `playlistStructure: 'split'` → `presentation: 'separate'` in definition constructors
- `entity.playlistStructure, 'split'` → keep as `'split'` for legacy entity compat check, OR update to `'separate'`
- `entity.playlistStructure, 'grouped'` → update to `'combined'`
- `playlist.playlistStructure` → `playlist.presentation`
- `PlaylistStructure` → `Presentation` in all assertions
- `resolverType: 'rss'` → `resolverType: 'seasonNumber'` in definitions
- Add `presentation: 'separate'` to definitions that don't specify it
- `RssMetadataResolver()` and `CategoryResolver()` references: these are in the provider which was already updated, no direct references expected here
- The entity field `playlistStructure` stays as the Isar column name — assertions about entity values should use new presentation values since _enrichPlaylist now writes `playlist.presentation.name`

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "test(domain): update service and provider tests for v4"
```

---

### Task 17: Update schema conformance test

**Files:**
- Modify: `packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart`

- [ ] **Step 1: Update minimal definition test**

```dart
test('minimal SmartPlaylistDefinition round-trips', () {
  const def = SmartPlaylistDefinition(
    id: 'main',
    displayName: 'Main Episodes',
    resolverType: 'seasonNumber',
    presentation: 'separate',
  );
  expect(validate(def.toJson()), isEmpty);
});
```

- [ ] **Step 2: Update full definition test**

```dart
test('full SmartPlaylistDefinition round-trips', () {
  final def = SmartPlaylistDefinition(
    id: 'seasons',
    displayName: 'Seasons',
    resolverType: 'seasonNumber',
    presentation: 'combined',
    prependSeasonNumber: true,
    episodeFilters: EpisodeFilters(
      require: [EpisodeFilterEntry(title: r'S\d+')],
      exclude: [EpisodeFilterEntry(title: r'Trailer')],
    ),
    groupList: GroupListConfig(
      yearBinding: YearBinding.pinToYear,
      userSortable: true,
      showDateRange: true,
      sort: SmartPlaylistSortRule(
        field: SmartPlaylistSortField.playlistNumber,
        order: SortOrder.descending,
      ),
    ),
    episodeList: EpisodeListConfig(
      showYearHeaders: true,
      sort: EpisodeSortRule(
        field: EpisodeSortField.publishedAt,
        order: SortOrder.descending,
      ),
    ),
    groups: [
      SmartPlaylistGroupDef(
        id: 'main',
        displayName: 'Main',
        pattern: r'^Main\b',
      ),
      SmartPlaylistGroupDef(id: 'other', displayName: 'Other'),
    ],
    titleExtractor: SmartPlaylistTitleExtractor(
      source: 'title',
      pattern: r'\[(.+?)\]',
      group: 1,
      template: 'Season {value}',
    ),
    numberingExtractor: NumberingExtractor(
      source: 'title',
      pattern: r'\[(\d+)-(\d+)\]',
      seasonGroup: 1,
      episodeGroup: 2,
      fallbackToRss: true,
    ),
  );
  expect(validate(def.toJson()), isEmpty);
});
```

- [ ] **Step 3: Update enum conformance tests**

```dart
test('resolverTypes match schema oneOf', () {
  final props = schema['properties'] as Map<String, dynamic>;
  final resolverType = props['resolverType'] as Map<String, dynamic>;
  final schemaValues = _extractEnum(resolverType);
  expect(
    schemaValues,
    containsAll([
      'seasonNumber', 'titleClassifier', 'year', 'titleDiscovery',
    ]),
  );
});

test('presentation values match schema', () {
  final props = schema['properties'] as Map<String, dynamic>;
  final ps = props['presentation'] as Map<String, dynamic>;
  final schemaValues = _extractEnum(ps);
  expect(schemaValues, containsAll(['separate', 'combined']));
});
```

- [ ] **Step 4: Update extractor enum test**

```dart
test('numberingExtractorSources match schema enum', () {
  final numberingExtractor = defs['NumberingExtractor'] as Map<String, dynamic>;
  final props = numberingExtractor['properties'] as Map<String, dynamic>;
  final source = props['source'] as Map<String, dynamic>;
  final schemaValues = _extractEnum(source);
  expect(schemaValues, containsAll(['title', 'description']));
});
```

- [ ] **Step 5: Update schema version tests**

```dart
test(r'playlist-definition schema has v4 $id', () {
  expect(
    schema[r'$id'],
    equals('https://audiflow.app/schema/v4/playlist-definition.json'),
  );
});

test(r'pattern-index schema has v4 $id', () {
  expect(
    patternIndexSchema[r'$id'],
    equals('https://audiflow.app/schema/v4/pattern-index.json'),
  );
});

test(r'pattern-meta schema has v4 $id', () {
  expect(
    patternMetaSchema[r'$id'],
    equals('https://audiflow.app/schema/v4/pattern-meta.json'),
  );
});
```

- [ ] **Step 6: Update RootMeta schemaVersion in tests**

```dart
test('minimal RootMeta round-trips', () {
  final meta = RootMeta(dataVersion: 1, schemaVersion: 4, patterns: []);
  expect(validatePatternIndex(meta.toJson()), isEmpty);
});

test('full RootMeta with patterns round-trips', () {
  final meta = RootMeta(
    dataVersion: 5,
    schemaVersion: 4,
    // ...
```

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart
git commit -m "test(domain): update schema conformance test for v4"
```

---

### Task 18: Update remaining test files with stale references

**Files:**
- Check and update any remaining files referencing old names (mock files, other test helpers)

- [ ] **Step 1: Search for remaining old references**

```bash
cd packages/audiflow_domain
grep -rn 'SmartPlaylistEpisodeExtractor\|episodeExtractor\|PlaylistStructure\|playlistStructure\|RssMetadataResolver\|CategoryResolver\|TitleAppearanceOrderResolver\|nullSeasonGroupKey' test/ lib/ --include='*.dart' | grep -v '.g.dart'
```

Fix any remaining references found. Key files to check:
- `test/features/feed/services/feed_sync_service_test.mocks.dart` — auto-generated, may need regeneration
- `test/features/feed/services/background_refresh_service_test.dart` — may reference `episodeExtractor`
- `test/features/feed/services/feed_sync_executor_test.dart` — may reference `episodeExtractor`
- `packages/audiflow_app/test/features/library/presentation/controllers/library_controller_test.dart` — references `SmartPlaylistEpisodeExtractor`

- [ ] **Step 2: Update app test file**

In `library_controller_test.dart`, rename `SmartPlaylistEpisodeExtractor` → `NumberingExtractor`.

- [ ] **Step 3: Regenerate mock files if needed**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor: fix remaining v3 references across codebase"
```

---

### Task 19: Update documentation

**Files:**
- Modify: `docs/integration/smartplaylist.md` — update schema version refs and field names
- Modify: `.claude/rules/project/architecture.md` — update resolver type references
- Modify: `CLAUDE.md` — if it references v3 specifically

- [ ] **Step 1: Update smartplaylist integration doc**

Change references from v3 to v4 field names and resolver types.

- [ ] **Step 2: Update architecture.md**

Update the "Valid resolver types" section:
```
**Valid resolver types** (from schema): `seasonNumber`, `titleClassifier`, `year`, `titleDiscovery`
```

- [ ] **Step 3: Commit**

```bash
git add docs/ .claude/ CLAUDE.md
git commit -m "docs: update references for v4 schema"
```

---

### Task 20: Run full verification

- [ ] **Step 1: Run analyze**

```bash
flutter analyze
```

Expected: zero issues.

- [ ] **Step 2: Run all tests**

```bash
melos run test
```

Expected: all pass.

- [ ] **Step 3: Run codegen (if any generated files are stale)**

```bash
melos run codegen
```

- [ ] **Step 4: Run conformance test specifically**

```bash
flutter test packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart
```

Expected: all pass — models serialize to valid v4 JSON.
