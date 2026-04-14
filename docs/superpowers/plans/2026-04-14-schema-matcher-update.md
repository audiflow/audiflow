# Schema Matcher Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adopt upstream schema changes: `GroupDef.pattern` becomes a `Matcher` object (source + pattern), `SelectorConfig.partitionBy` drops `"group"` value.

**Architecture:** Create a `Matcher` model class, change `SmartPlaylistGroupDef.pattern` from `String?` to `Matcher?`, update resolvers and services that read the pattern to use `matcher.source` for field selection and `matcher.pattern` for regex. Update `SelectorConfig` doc to reflect only `seasonNumber`/`year`. Update vendored schema.

**Tech Stack:** Dart, Flutter

---

## File Map

### Create
- `packages/audiflow_domain/lib/src/features/feed/models/matcher.dart` — `Matcher` class with `source` and `pattern` fields

### Modify
- `smart_playlist_group_def.dart` — `pattern: String?` → `pattern: Matcher?`
- `title_classifier_resolver.dart` — read `g.pattern.source` to choose field, `g.pattern.pattern` for regex
- `episode_extractor_resolver.dart` — same: read `group.pattern.source`/`.pattern`
- `selector_config.dart` — update doc comment (remove `group` from valid values)
- `audiflow_domain.dart` — add export for `matcher.dart`
- `patterns.dart` — add export for `matcher.dart` if needed for CLI
- Test files: update all test data using `pattern:` string to `pattern: Matcher(source: 'title', pattern: '...')`
- Schema conformance test — update if it checks pattern structure
- Vendored schema — copy fresh from upstream (NEVER edit manually)

---

### Task 1: Copy updated vendored schema

**Files:**
- Modify: `packages/audiflow_domain/test/fixtures/playlist-definition.schema.json`

- [ ] **Step 1: Copy from upstream**

```bash
cp /Users/tohru/Documents/src/ghq/github.com/audiflow/audiflow-smartplaylist/schema/playlist-definition.schema.json \
   packages/audiflow_domain/test/fixtures/playlist-definition.schema.json
```

- [ ] **Step 2: Verify Matcher $def exists**

```bash
grep '"Matcher"' packages/audiflow_domain/test/fixtures/playlist-definition.schema.json
```

Expected: `"Matcher":` appears in `$defs`.

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/test/fixtures/playlist-definition.schema.json
git commit -m "chore(domain): vendor updated schema with Matcher type"
```

---

### Task 2: Create Matcher model and update GroupDef

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/matcher.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_def.dart`

- [ ] **Step 1: Create Matcher class**

```dart
// matcher.dart

/// A regex pattern plus the episode field it is evaluated against.
final class Matcher {
  const Matcher({required this.source, required this.pattern});

  factory Matcher.fromJson(Map<String, dynamic> json) {
    return Matcher(
      source: json['source'] as String,
      pattern: json['pattern'] as String,
    );
  }

  /// Episode field to match against: "title" or "description".
  final String source;

  /// Regex pattern tested against the source field.
  final String pattern;

  Map<String, dynamic> toJson() {
    return {'source': source, 'pattern': pattern};
  }
}
```

- [ ] **Step 2: Update SmartPlaylistGroupDef**

Change `pattern` field from `String?` to `Matcher?`:
- Import `matcher.dart`
- Constructor: `this.pattern` stays the same name, type changes to `Matcher?`
- fromJson: `pattern: json['pattern'] as String?` → parse as Matcher object:
  ```dart
  pattern: json['pattern'] != null
      ? Matcher.fromJson(json['pattern'] as Map<String, dynamic>)
      : null,
  ```
- Field declaration: `final String? pattern;` → `final Matcher? pattern;`
- Doc comment: update to mention Matcher
- toJson: `if (pattern != null) 'pattern': pattern,` → `if (pattern != null) 'pattern': pattern!.toJson(),`

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/matcher.dart \
       packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_def.dart
git commit -m "feat(domain): add Matcher type, update GroupDef.pattern"
```

---

### Task 3: Update resolvers to use Matcher

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/title_classifier_resolver.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/episode_extractor_resolver.dart`

- [ ] **Step 1: Update TitleClassifierResolver**

Currently the resolver reads `g.pattern` as a String and matches against `episode.title`. Change to:
- `g.pattern` is now a `Matcher?`
- When building patternGroups, extract `g.pattern!.pattern` for the regex
- When matching episodes, choose field based on `g.pattern!.source`:

```dart
for (final g in groupDefs) {
  if (g.pattern != null) {
    patternGroups.add((
      regex: RegExp(g.pattern!.pattern, caseSensitive: false),
      source: g.pattern!.source,
      id: g.id,
      displayName: g.displayName,
    ));
  } else {
    fallbackId = g.id;
    fallbackDisplayName = g.displayName;
  }
}
```

Update the record type to include `source`:
```dart
final patternGroups = <({RegExp regex, String source, String id, String displayName})>[];
```

Update the matching loop:
```dart
for (final episode in episodes) {
  var matched = false;
  for (final pg in patternGroups) {
    final text = pg.source == 'description'
        ? episode.description
        : episode.title;
    if (text != null && pg.regex.hasMatch(text)) {
      grouped.putIfAbsent(pg.id, () => []).add(episode.id);
      matched = true;
      break;
    }
  }
  // ... rest unchanged
}
```

Note: `episode.title` is non-nullable String, but `episode.description` is nullable. When source is `'title'`, use `episode.title` directly (always non-null). When source is `'description'`, use `episode.description` which may be null (no match if null).

- [ ] **Step 2: Update EpisodeExtractorResolver**

In `_findGroupExtractor`, the code checks `group.pattern == null` and uses `RegExp(group.pattern!)`. Change to:
- `group.pattern == null` stays the same (Matcher? null check)
- `RegExp(group.pattern!, ...)` → `RegExp(group.pattern!.pattern, ...)`
- Match against the correct field based on `group.pattern!.source`:

```dart
SmartPlaylistEpisodeExtractor? _findGroupExtractor(
  String title,
  String? description,
  List<SmartPlaylistGroupDef> groups,
) {
  for (final group in groups) {
    if (group.pattern == null) continue;

    final regex = RegExp(group.pattern!.pattern, caseSensitive: false);
    final text = group.pattern!.source == 'description'
        ? description
        : title;
    if (text != null && regex.hasMatch(text)) {
      if (group.numberingExtractor != null) {
        return group.numberingExtractor;
      }
    }
  }
  return null;
}
```

Note: the return type is `NumberingExtractor?` not `SmartPlaylistEpisodeExtractor?` — use the correct name from the current codebase.

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/resolvers/title_classifier_resolver.dart \
       packages/audiflow_domain/lib/src/features/feed/services/episode_extractor_resolver.dart
git commit -m "refactor(domain): update resolvers to use Matcher source field"
```

---

### Task 4: Update SelectorConfig and barrel files

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/selector_config.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`
- Modify: `packages/audiflow_domain/lib/patterns.dart`

- [ ] **Step 1: Update SelectorConfig doc comment**

Change: `/// How to partition groups: group, seasonNumber, year.`
To: `/// How to partition groups: seasonNumber, year.`

No code change needed — the field is a String, we just accept whatever value the upstream sends.

- [ ] **Step 2: Add Matcher export to barrel files**

In `audiflow_domain.dart`, add:
```dart
export 'src/features/feed/models/matcher.dart';
```

In `patterns.dart`, add:
```dart
export 'src/features/feed/models/matcher.dart';
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/selector_config.dart \
       packages/audiflow_domain/lib/audiflow_domain.dart \
       packages/audiflow_domain/lib/patterns.dart
git commit -m "refactor(domain): update SelectorConfig doc, add Matcher export"
```

---

### Task 5: Update all tests

**Files:**
- All test files that construct `SmartPlaylistGroupDef` with a `pattern:` string parameter

- [ ] **Step 1: Find all test files using string patterns**

```bash
grep -rn "pattern: r'" --include='*.dart' packages/audiflow_domain/test/
grep -rn "pattern: '" --include='*.dart' packages/audiflow_domain/test/ | grep -v '.g.dart'
```

Every occurrence of `pattern: r'...'` or `pattern: '...'` in a `SmartPlaylistGroupDef` constructor needs to change to `pattern: Matcher(source: 'title', pattern: r'...')`.

Note: `NumberingExtractor` and `SmartPlaylistTitleExtractor` also have `pattern` fields — do NOT change those. Only change `SmartPlaylistGroupDef` pattern fields.

- [ ] **Step 2: Update each test file**

For each `SmartPlaylistGroupDef(... pattern: r'someRegex' ...)`, change to:
```dart
SmartPlaylistGroupDef(... pattern: Matcher(source: 'title', pattern: r'someRegex') ...)
```

Add `import 'package:audiflow_domain/audiflow_domain.dart';` if not already imported (it re-exports `Matcher`).

Key test files to update:
- `test/features/feed/resolvers/title_classifier_resolver_test.dart`
- `test/features/feed/resolvers/title_discovery_resolver_test.dart` (if any GroupDef patterns exist)
- `test/features/feed/services/smart_playlist_resolver_service_test.dart`
- `test/features/feed/models/smart_playlist_group_def_test.dart` (if exists)
- `test/features/feed/models/smart_playlist_definition_test.dart`
- `test/features/feed/models/schema_conformance_test.dart`
- `test/features/feed/services/episode_extractor_resolver_test.dart` (if exists)

- [ ] **Step 3: Run tests**

```bash
flutter test packages/audiflow_domain/test/features/feed/
```

- [ ] **Step 4: Run analyze**

```bash
flutter analyze
```

- [ ] **Step 5: Fix any remaining compile errors**

Search for stale `g.pattern` string usage:
```bash
grep -rn '\.pattern!' --include='*.dart' packages/ | grep -v '.g.dart' | grep -v 'numbering_extractor\|title_extractor\|NumberingExtractor\|TitleExtractor'
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "test: update all tests for Matcher type in GroupDef"
```

---

### Task 6: Verify

- [ ] **Step 1: Run full verification**

```bash
flutter analyze
flutter test packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart
flutter test packages/audiflow_domain/test/features/feed/
```

Expected: analyze clean, all conformance tests pass, all feed tests pass (except pre-existing Isar failures).
