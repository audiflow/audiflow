# Smart Playlist JSON Patterns Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace hardcoded Dart smart playlist pattern constants with a JSON asset, restructuring into a two-level hierarchy with unified playlist schema.

**Architecture:** Top-level `SmartPlaylistPatternConfig` matches podcasts by GUID/feed URL and contains `List<SmartPlaylistDefinition>`. Each definition has a unified schema with all fields (display, routing, sorting, extractors) as typed properties. No opaque `config` map. Resolvers accept `SmartPlaylistDefinition` directly.

**Tech Stack:** Dart, Flutter assets, Riverpod, existing extractor/sort models

**Design doc:** `docs/plans/2026-02-02-smart-playlist-json-patterns-design.md`

---

### Task 1: Add JSON serialization to SmartPlaylistSortSpec hierarchy

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_sort.dart`
- Create: `packages/audiflow_domain/test/features/feed/models/smart_playlist_sort_json_test.dart`

**Step 1: Write the failing test**

```dart
// smart_playlist_sort_json_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistSortSpec JSON', () {
    test('SimpleSmartPlaylistSort round-trip', () {
      const sort = SimpleSmartPlaylistSort(
        SmartPlaylistSortField.playlistNumber,
        SortOrder.ascending,
      );
      final json = sort.toJson();
      final decoded = SmartPlaylistSortSpec.fromJson(json);

      expect(decoded, isA<SimpleSmartPlaylistSort>());
      final simple = decoded as SimpleSmartPlaylistSort;
      expect(simple.field, SmartPlaylistSortField.playlistNumber);
      expect(simple.order, SortOrder.ascending);
    });

    test('CompositeSmartPlaylistSort round-trip', () {
      const sort = CompositeSmartPlaylistSort([
        SmartPlaylistSortRule(
          field: SmartPlaylistSortField.playlistNumber,
          order: SortOrder.ascending,
          condition: SortKeyGreaterThan(0),
        ),
        SmartPlaylistSortRule(
          field: SmartPlaylistSortField.newestEpisodeDate,
          order: SortOrder.ascending,
        ),
      ]);
      final json = sort.toJson();
      final decoded = SmartPlaylistSortSpec.fromJson(json);

      expect(decoded, isA<CompositeSmartPlaylistSort>());
      final composite = decoded as CompositeSmartPlaylistSort;
      expect(composite.rules, hasLength(2));
      expect(composite.rules[0].condition, isA<SortKeyGreaterThan>());
      expect(
        (composite.rules[0].condition! as SortKeyGreaterThan).value,
        0,
      );
      expect(composite.rules[1].condition, isNull);
    });

    test('fromJson throws on unknown type', () {
      expect(
        () => SmartPlaylistSortSpec.fromJson({'type': 'unknown'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `run_tests` on `packages/audiflow_domain` with path `test/features/feed/models/smart_playlist_sort_json_test.dart`
Expected: FAIL — `fromJson`/`toJson` not defined

**Step 3: Implement serialization**

Add to `smart_playlist_sort.dart`:

- `SmartPlaylistSortSpec`: factory `fromJson(Map<String, dynamic> json)` using `type` discriminator (`simple`/`composite`), abstract `toJson()`
- `SimpleSmartPlaylistSort.fromJson`, `.toJson()` — serializes `field` and `order` as strings
- `CompositeSmartPlaylistSort.fromJson`, `.toJson()` — serializes `rules` list
- `SmartPlaylistSortRule.fromJson`, `.toJson()` — serializes with optional `condition`
- `SmartPlaylistSortCondition`: factory `fromJson` with `type` discriminator, abstract `toJson()`
- `SortKeyGreaterThan.fromJson`, `.toJson()`

Enum serialization: `SmartPlaylistSortField` and `SortOrder` use `.name` for `toJson` and name-based lookup for `fromJson`.

**Step 4: Run test to verify it passes**

Run: `run_tests` on `packages/audiflow_domain` with path `test/features/feed/models/smart_playlist_sort_json_test.dart`
Expected: PASS

**Step 5: Run existing sort tests to verify no regressions**

Run: `run_tests` on `packages/audiflow_domain` with path `test/features/feed/models/smart_playlist_sort_test.dart`
Expected: PASS

**Step 6: Commit**

```
feat(domain): add JSON serialization to SmartPlaylistSortSpec hierarchy
```

---

### Task 2: Create SmartPlaylistGroupDef model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_def.dart`
- Create: `packages/audiflow_domain/test/features/feed/models/smart_playlist_group_def_test.dart`

**Step 1: Write the failing test**

```dart
// smart_playlist_group_def_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_group_def.dart';

void main() {
  group('SmartPlaylistGroupDef JSON', () {
    test('round-trip with pattern', () {
      const def = SmartPlaylistGroupDef(
        id: 'daily_news',
        displayName: '平日版',
        pattern: r'【\d+月\d+日】',
      );
      final json = def.toJson();
      final decoded = SmartPlaylistGroupDef.fromJson(json);

      expect(decoded.id, 'daily_news');
      expect(decoded.displayName, '平日版');
      expect(decoded.pattern, r'【\d+月\d+日】');
    });

    test('round-trip without pattern (fallback group)', () {
      const def = SmartPlaylistGroupDef(
        id: 'other',
        displayName: 'その他',
      );
      final json = def.toJson();
      final decoded = SmartPlaylistGroupDef.fromJson(json);

      expect(decoded.id, 'other');
      expect(decoded.displayName, 'その他');
      expect(decoded.pattern, isNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Expected: FAIL — file doesn't exist

**Step 3: Implement SmartPlaylistGroupDef**

```dart
// smart_playlist_group_def.dart

/// Static group definition within a playlist.
///
/// Groups with a [pattern] match episodes by title regex.
/// Groups without a pattern act as fallback (catch-all).
final class SmartPlaylistGroupDef {
  const SmartPlaylistGroupDef({
    required this.id,
    required this.displayName,
    this.pattern,
  });

  factory SmartPlaylistGroupDef.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistGroupDef(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      pattern: json['pattern'] as String?,
    );
  }

  final String id;
  final String displayName;

  /// Regex pattern to match episode titles. Null means fallback group.
  final String? pattern;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      if (pattern != null) 'pattern': pattern,
    };
  }
}
```

**Step 4: Run test to verify it passes**

Expected: PASS

**Step 5: Commit**

```
feat(domain): add SmartPlaylistGroupDef model with JSON serialization
```

---

### Task 3: Create SmartPlaylistDefinition model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_definition.dart`
- Create: `packages/audiflow_domain/test/features/feed/models/smart_playlist_definition_test.dart`

**Step 1: Write the failing test**

```dart
// smart_playlist_definition_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_definition.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_group_def.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistDefinition JSON', () {
    test('round-trip with full RSS config (COTEN regular)', () {
      final def = SmartPlaylistDefinition(
        id: 'regular',
        displayName: 'レギュラーシリーズ',
        resolverType: 'rss',
        contentType: 'groups',
        yearHeaderMode: 'firstEpisode',
        episodeYearHeaders: false,
        titleFilter: r'【\d+-\d+】',
        excludeFilter: r'【COTEN RADIO\s*ショート',
        nullSeasonGroupKey: 0,
        customSort: const CompositeSmartPlaylistSort([
          SmartPlaylistSortRule(
            field: SmartPlaylistSortField.playlistNumber,
            order: SortOrder.ascending,
            condition: SortKeyGreaterThan(0),
          ),
        ]),
        titleExtractor: const SmartPlaylistTitleExtractor(
          source: 'title',
          pattern: r'test',
          group: 2,
        ),
      );
      final json = def.toJson();
      final decoded = SmartPlaylistDefinition.fromJson(json);

      expect(decoded.id, 'regular');
      expect(decoded.resolverType, 'rss');
      expect(decoded.contentType, 'groups');
      expect(decoded.titleFilter, r'【\d+-\d+】');
      expect(decoded.excludeFilter, r'【COTEN RADIO\s*ショート');
      expect(decoded.nullSeasonGroupKey, 0);
      expect(decoded.customSort, isA<CompositeSmartPlaylistSort>());
      expect(decoded.titleExtractor, isNotNull);
    });

    test('round-trip with category groups (NewsConnect)', () {
      final def = SmartPlaylistDefinition(
        id: 'by_category',
        displayName: 'カテゴリ別',
        resolverType: 'category',
        contentType: 'groups',
        yearHeaderMode: 'none',
        episodeYearHeaders: true,
        groups: const [
          SmartPlaylistGroupDef(
            id: 'daily',
            displayName: '平日版',
            pattern: r'【\d+月\d+日】',
          ),
          SmartPlaylistGroupDef(id: 'other', displayName: 'その他'),
        ],
      );
      final json = def.toJson();
      final decoded = SmartPlaylistDefinition.fromJson(json);

      expect(decoded.groups, hasLength(2));
      expect(decoded.groups![0].pattern, r'【\d+月\d+日】');
      expect(decoded.groups![1].pattern, isNull);
      expect(decoded.episodeYearHeaders, true);
    });

    test('minimal definition (extras playlist)', () {
      final def = SmartPlaylistDefinition(
        id: 'extras',
        displayName: 'その他',
        resolverType: 'rss',
      );
      final json = def.toJson();
      final decoded = SmartPlaylistDefinition.fromJson(json);

      expect(decoded.id, 'extras');
      expect(decoded.contentType, isNull);
      expect(decoded.customSort, isNull);
      expect(decoded.groups, isNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Expected: FAIL — file doesn't exist

**Step 3: Implement SmartPlaylistDefinition**

```dart
// smart_playlist_definition.dart
import 'episode_number_extractor.dart';
import 'smart_playlist_episode_extractor.dart';
import 'smart_playlist_group_def.dart';
import 'smart_playlist_sort.dart';
import 'smart_playlist_title_extractor.dart';

/// Per-playlist definition with unified schema.
///
/// All fields are named and typed. Fields irrelevant to a
/// resolver type are null and ignored by that resolver.
final class SmartPlaylistDefinition {
  const SmartPlaylistDefinition({
    required this.id,
    required this.displayName,
    required this.resolverType,
    this.priority = 0,
    this.contentType,
    this.yearHeaderMode,
    this.episodeYearHeaders = false,
    this.titleFilter,
    this.excludeFilter,
    this.requireFilter,
    this.nullSeasonGroupKey,
    this.groups,
    this.customSort,
    this.titleExtractor,
    this.episodeNumberExtractor,
    this.smartPlaylistEpisodeExtractor,
  });

  factory SmartPlaylistDefinition.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistDefinition(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      resolverType: json['resolverType'] as String,
      priority: (json['priority'] as int?) ?? 0,
      contentType: json['contentType'] as String?,
      yearHeaderMode: json['yearHeaderMode'] as String?,
      episodeYearHeaders: (json['episodeYearHeaders'] as bool?) ?? false,
      titleFilter: json['titleFilter'] as String?,
      excludeFilter: json['excludeFilter'] as String?,
      requireFilter: json['requireFilter'] as String?,
      nullSeasonGroupKey: json['nullSeasonGroupKey'] as int?,
      groups: (json['groups'] as List<dynamic>?)
          ?.map((g) =>
              SmartPlaylistGroupDef.fromJson(g as Map<String, dynamic>))
          .toList(),
      customSort: json['customSort'] != null
          ? SmartPlaylistSortSpec.fromJson(
              json['customSort'] as Map<String, dynamic>)
          : null,
      titleExtractor: json['titleExtractor'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['titleExtractor'] as Map<String, dynamic>)
          : null,
      episodeNumberExtractor: json['episodeNumberExtractor'] != null
          ? EpisodeNumberExtractor.fromJson(
              json['episodeNumberExtractor'] as Map<String, dynamic>)
          : null,
      smartPlaylistEpisodeExtractor:
          json['smartPlaylistEpisodeExtractor'] != null
              ? SmartPlaylistEpisodeExtractor.fromJson(
                  json['smartPlaylistEpisodeExtractor']
                      as Map<String, dynamic>)
              : null,
    );
  }

  final String id;
  final String displayName;
  final String resolverType;
  final int priority;

  // Display config
  final String? contentType;
  final String? yearHeaderMode;
  final bool episodeYearHeaders;

  // Episode routing
  final String? titleFilter;
  final String? excludeFilter;
  final String? requireFilter;

  // Resolver-specific
  final int? nullSeasonGroupKey;
  final List<SmartPlaylistGroupDef>? groups;

  // Per-playlist extractors and sorting
  final SmartPlaylistSortSpec? customSort;
  final SmartPlaylistTitleExtractor? titleExtractor;
  final EpisodeNumberExtractor? episodeNumberExtractor;
  final SmartPlaylistEpisodeExtractor? smartPlaylistEpisodeExtractor;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'resolverType': resolverType,
      if (priority != 0) 'priority': priority,
      if (contentType != null) 'contentType': contentType,
      if (yearHeaderMode != null) 'yearHeaderMode': yearHeaderMode,
      if (episodeYearHeaders) 'episodeYearHeaders': episodeYearHeaders,
      if (titleFilter != null) 'titleFilter': titleFilter,
      if (excludeFilter != null) 'excludeFilter': excludeFilter,
      if (requireFilter != null) 'requireFilter': requireFilter,
      if (nullSeasonGroupKey != null)
        'nullSeasonGroupKey': nullSeasonGroupKey,
      if (groups != null) 'groups': groups!.map((g) => g.toJson()).toList(),
      if (customSort != null) 'customSort': customSort!.toJson(),
      if (titleExtractor != null)
        'titleExtractor': titleExtractor!.toJson(),
      if (episodeNumberExtractor != null)
        'episodeNumberExtractor': episodeNumberExtractor!.toJson(),
      if (smartPlaylistEpisodeExtractor != null)
        'smartPlaylistEpisodeExtractor':
            smartPlaylistEpisodeExtractor!.toJson(),
    };
  }
}
```

**Step 4: Run test to verify it passes**

Expected: PASS

**Step 5: Commit**

```
feat(domain): add SmartPlaylistDefinition model with unified schema
```

---

### Task 4: Create SmartPlaylistPatternConfig model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_pattern_config.dart`
- Create: `packages/audiflow_domain/test/features/feed/models/smart_playlist_pattern_config_test.dart`

**Step 1: Write the failing test**

```dart
// smart_playlist_pattern_config_test.dart
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_definition.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_pattern_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistPatternConfig JSON', () {
    test('round-trip', () {
      final config = SmartPlaylistPatternConfig(
        id: 'test_podcast',
        feedUrlPatterns: [r'https://example\.com/feed'],
        yearGroupedEpisodes: true,
        playlists: [
          SmartPlaylistDefinition(
            id: 'main',
            displayName: 'Main',
            resolverType: 'rss',
          ),
        ],
      );
      final json = config.toJson();
      final decoded = SmartPlaylistPatternConfig.fromJson(json);

      expect(decoded.id, 'test_podcast');
      expect(decoded.feedUrlPatterns, [r'https://example\.com/feed']);
      expect(decoded.yearGroupedEpisodes, true);
      expect(decoded.playlists, hasLength(1));
      expect(decoded.playlists[0].id, 'main');
    });

    test('matchesPodcast by feed URL', () {
      final config = SmartPlaylistPatternConfig(
        id: 'test',
        feedUrlPatterns: [r'https://example\.com/feed\.rss'],
        playlists: [],
      );

      expect(config.matchesPodcast(null, 'https://example.com/feed.rss'), true);
      expect(config.matchesPodcast(null, 'https://other.com/feed'), false);
    });

    test('matchesPodcast by GUID', () {
      final config = SmartPlaylistPatternConfig(
        id: 'test',
        podcastGuid: 'abc-123',
        playlists: [],
      );

      expect(config.matchesPodcast('abc-123', 'https://any.com'), true);
      expect(config.matchesPodcast('xyz', 'https://any.com'), false);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Expected: FAIL — file doesn't exist

**Step 3: Implement SmartPlaylistPatternConfig**

```dart
// smart_playlist_pattern_config.dart
import 'smart_playlist_definition.dart';

/// Top-level pattern config that matches a podcast by GUID or
/// feed URL, containing playlist definitions.
final class SmartPlaylistPatternConfig {
  const SmartPlaylistPatternConfig({
    required this.id,
    this.podcastGuid,
    this.feedUrlPatterns,
    this.yearGroupedEpisodes = false,
    required this.playlists,
  });

  factory SmartPlaylistPatternConfig.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistPatternConfig(
      id: json['id'] as String,
      podcastGuid: json['podcastGuid'] as String?,
      feedUrlPatterns: (json['feedUrlPatterns'] as List<dynamic>?)
          ?.cast<String>(),
      yearGroupedEpisodes:
          (json['yearGroupedEpisodes'] as bool?) ?? false,
      playlists: (json['playlists'] as List<dynamic>)
          .map((p) => SmartPlaylistDefinition.fromJson(
              p as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String? podcastGuid;
  final List<String>? feedUrlPatterns;
  final bool yearGroupedEpisodes;
  final List<SmartPlaylistDefinition> playlists;

  /// Returns true if this config matches the given podcast.
  bool matchesPodcast(String? guid, String feedUrl) {
    if (podcastGuid != null && guid == podcastGuid) {
      return true;
    }
    if (feedUrlPatterns != null) {
      for (final pattern in feedUrlPatterns!) {
        final regex = RegExp('^$pattern\$');
        if (regex.hasMatch(feedUrl)) {
          return true;
        }
      }
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (podcastGuid != null) 'podcastGuid': podcastGuid,
      if (feedUrlPatterns != null) 'feedUrlPatterns': feedUrlPatterns,
      if (yearGroupedEpisodes) 'yearGroupedEpisodes': yearGroupedEpisodes,
      'playlists': playlists.map((p) => p.toJson()).toList(),
    };
  }
}
```

**Step 4: Run test to verify it passes**

Expected: PASS

**Step 5: Commit**

```
feat(domain): add SmartPlaylistPatternConfig model
```

---

### Task 5: Create SmartPlaylistPatternLoader

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/services/smart_playlist_pattern_loader.dart`
- Create: `packages/audiflow_domain/test/features/feed/services/smart_playlist_pattern_loader_test.dart`

**Step 1: Write the failing test**

```dart
// smart_playlist_pattern_loader_test.dart
import 'dart:convert';

import 'package:audiflow_domain/src/features/feed/models/smart_playlist_pattern_config.dart';
import 'package:audiflow_domain/src/features/feed/services/smart_playlist_pattern_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistPatternLoader', () {
    test('parses valid JSON with version 1', () {
      final json = jsonEncode({
        'version': 1,
        'patterns': [
          {
            'id': 'test',
            'feedUrlPatterns': [r'https://example\.com/feed'],
            'playlists': [
              {
                'id': 'main',
                'displayName': 'Main',
                'resolverType': 'rss',
              },
            ],
          },
        ],
      });

      final result = SmartPlaylistPatternLoader.parse(json);
      expect(result, hasLength(1));
      expect(result[0].id, 'test');
      expect(result[0].playlists, hasLength(1));
    });

    test('throws FormatException on unsupported version', () {
      final json = jsonEncode({
        'version': 99,
        'patterns': [],
      });

      expect(
        () => SmartPlaylistPatternLoader.parse(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException on missing version', () {
      final json = jsonEncode({'patterns': []});

      expect(
        () => SmartPlaylistPatternLoader.parse(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('returns empty list for empty patterns', () {
      final json = jsonEncode({
        'version': 1,
        'patterns': [],
      });

      final result = SmartPlaylistPatternLoader.parse(json);
      expect(result, isEmpty);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Expected: FAIL — file doesn't exist

**Step 3: Implement SmartPlaylistPatternLoader**

```dart
// smart_playlist_pattern_loader.dart
import 'dart:convert';

import '../models/smart_playlist_pattern_config.dart';

/// Parses smart playlist pattern JSON into typed models.
///
/// Pure function with no Flutter dependency. The JSON source
/// can be a bundled asset or a server response.
final class SmartPlaylistPatternLoader {
  SmartPlaylistPatternLoader._();

  static const _supportedVersion = 1;

  /// Parses a JSON string into a list of pattern configs.
  ///
  /// Throws [FormatException] if the version is missing or
  /// unsupported.
  static List<SmartPlaylistPatternConfig> parse(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final version = data['version'] as int?;
    if (version == null) {
      throw const FormatException(
        'Missing "version" field in smart playlist patterns JSON',
      );
    }
    if (version != _supportedVersion) {
      throw FormatException(
        'Unsupported smart playlist patterns version: $version '
        '(supported: $_supportedVersion)',
      );
    }

    final patterns = data['patterns'] as List<dynamic>;
    return patterns
        .map((p) => SmartPlaylistPatternConfig.fromJson(
            p as Map<String, dynamic>))
        .toList();
  }
}
```

**Step 4: Run test to verify it passes**

Expected: PASS

**Step 5: Commit**

```
feat(domain): add SmartPlaylistPatternLoader for JSON parsing
```

---

### Task 6: Update resolver interface and all resolvers

This task updates `SmartPlaylistResolver` to accept `SmartPlaylistDefinition` instead of `SmartPlaylistPattern`, and updates all four resolvers.

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/smart_playlist_resolver.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/rss_metadata_resolver.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/category_resolver.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/year_resolver.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/title_appearance_order_resolver.dart`

**Step 1: Update resolver interface**

Change `smart_playlist_resolver.dart`:
- Replace `import '../models/smart_playlist_pattern.dart'` with `import '../models/smart_playlist_definition.dart'`
- Change `resolve` signature: `SmartPlaylistPattern? pattern` -> `SmartPlaylistDefinition? definition`

**Step 2: Update RssMetadataResolver**

Key changes in `rss_metadata_resolver.dart`:
- `resolve` accepts `SmartPlaylistDefinition? definition` instead of `SmartPlaylistPattern? pattern`
- Remove `_resolveWithParentPlaylists` — the service layer now handles iterating playlists
- `_resolveBySeasonNumber` reads `definition.nullSeasonGroupKey` instead of `pattern.config['groupNullSeasonAs']`
- `_buildGroups` reads `definition.titleExtractor` instead of `pattern.titleExtractor`
- `_PlaylistFilter` is removed — episode routing (titleFilter/excludeFilter/requireFilter) moves to the service layer
- Display config (`contentType`, `yearHeaderMode`, `episodeYearHeaders`) is read from `definition` typed fields

**Step 3: Update CategoryResolver**

Key changes in `category_resolver.dart`:
- `resolve` accepts `SmartPlaylistDefinition? definition`
- Remove `_resolvePlaylists` — service layer handles iterating playlists
- Group definitions come from `definition.groups` (typed `List<SmartPlaylistGroupDef>`) instead of `definition.config['groups']`
- `_resolvePlaylistGroups` reads group patterns from `SmartPlaylistGroupDef.pattern`

**Step 4: Update YearResolver**

Key changes in `year_resolver.dart`:
- `resolve` accepts `SmartPlaylistDefinition? definition`
- Reads `definition?.titleExtractor` instead of `pattern?.titleExtractor`

**Step 5: Update TitleAppearanceOrderResolver**

Key changes in `title_appearance_order_resolver.dart`:
- `resolve` accepts `SmartPlaylistDefinition? definition`
- Reads `definition.titleExtractor` and falls back to `definition.groups?[0].pattern` or similar approach for the regex pattern (previously read from `pattern.config['pattern']`)

**Step 6: Run all resolver tests**

Run: `run_tests` on `packages/audiflow_domain` with path `test/features/feed/resolvers/`
Expected: FAIL — tests still use old `SmartPlaylistPattern`

**Step 7: Update resolver tests**

Update all test files in `test/features/feed/resolvers/` to use `SmartPlaylistDefinition` instead of `SmartPlaylistPattern`. Replace `config: {...}` with typed fields.

**Step 8: Run all resolver tests**

Expected: PASS

**Step 9: Commit**

```
refactor(domain): update resolver interface to accept SmartPlaylistDefinition
```

---

### Task 7: Update SmartPlaylistResolverService

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/smart_playlist_resolver_service.dart`
- Modify: `packages/audiflow_domain/test/features/feed/services/smart_playlist_resolver_service_test.dart`

**Step 1: Update service**

Key changes in `smart_playlist_resolver_service.dart`:
- Accept `List<SmartPlaylistPatternConfig>` instead of `List<SmartPlaylistPattern>`
- `_findMatchingPattern` returns `SmartPlaylistPatternConfig?` using `.matchesPodcast()`
- When a pattern matches, iterate its `playlists` and call the appropriate resolver for each `SmartPlaylistDefinition`
- Episode routing (titleFilter/excludeFilter/requireFilter) is applied before passing episodes to resolver
- Combine per-playlist results into a single `SmartPlaylistGrouping`
- Fallback resolvers (no pattern match) still work as before, receiving null definition

**Step 2: Update service test**

Update `smart_playlist_resolver_service_test.dart`:
- Replace `SmartPlaylistPattern` with `SmartPlaylistPatternConfig` containing `SmartPlaylistDefinition` playlists
- Update the custom pattern test to use the new model

**Step 3: Run tests**

Run: `run_tests` on `packages/audiflow_domain` with path `test/features/feed/services/smart_playlist_resolver_service_test.dart`
Expected: PASS

**Step 4: Commit**

```
refactor(domain): update SmartPlaylistResolverService for new model hierarchy
```

---

### Task 8: Update smart_playlist_providers.dart

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/providers/smart_playlist_providers.dart`

**Step 1: Update providers**

Key changes:
- Remove imports of `coten_radio_pattern.dart` and `news_connect_pattern.dart`
- Remove `const _registeredPatterns` list
- Add `smartPlaylistPatternsProvider` — a `@Riverpod(keepAlive: true)` provider that accepts `List<SmartPlaylistPatternConfig>` (initially empty, overridden by app layer)
- Update `smartPlaylistResolverServiceProvider` to read patterns from the new provider
- Update `smartPlaylistPatternByFeedUrlProvider` to use `SmartPlaylistPatternConfig`
- Update `_buildGroupingFromCache` and `_reResolveFromEpisodes` to use new model types
- Update all references from `SmartPlaylistPattern` to `SmartPlaylistPatternConfig` / `SmartPlaylistDefinition`

**Step 2: Run code generation**

Run: `build_runner` in `packages/audiflow_domain`

**Step 3: Run all smart playlist tests**

Run: `run_tests` on `packages/audiflow_domain` with path `test/features/feed/`
Expected: Some tests may need updating for new model types

**Step 4: Fix any remaining test failures**

Update pattern-related tests that still reference old `SmartPlaylistPattern`.

**Step 5: Commit**

```
refactor(domain): update smart_playlist_providers for new pattern config model
```

---

### Task 9: Update exports and remove old model

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`
- Delete: `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_pattern.dart`
- Delete: `packages/audiflow_domain/lib/src/features/feed/patterns/coten_radio_pattern.dart`
- Delete: `packages/audiflow_domain/lib/src/features/feed/patterns/news_connect_pattern.dart`

**Step 1: Update exports**

In `audiflow_domain.dart`:
- Remove: `export 'src/features/feed/models/smart_playlist_pattern.dart'`
- Remove: `export 'src/features/feed/patterns/news_connect_pattern.dart'`
- Add: `export 'src/features/feed/models/smart_playlist_pattern_config.dart'`
- Add: `export 'src/features/feed/models/smart_playlist_definition.dart'`
- Add: `export 'src/features/feed/models/smart_playlist_group_def.dart'`
- Add: `export 'src/features/feed/services/smart_playlist_pattern_loader.dart'`

**Step 2: Delete old files**

Delete:
- `smart_playlist_pattern.dart`
- `coten_radio_pattern.dart`
- `news_connect_pattern.dart`

**Step 3: Fix compilation errors**

Search for any remaining imports of the deleted files and update them.

**Step 4: Delete old pattern tests**

Delete:
- `test/features/feed/patterns/coten_radio_pattern_test.dart`
- `test/features/feed/patterns/news_connect_pattern_test.dart`
- `test/features/feed/models/smart_playlist_pattern_test.dart`

**Step 5: Run full test suite**

Run: `run_tests` on `packages/audiflow_domain`
Expected: PASS

**Step 6: Analyze**

Run: `analyze_files` on `packages/audiflow_domain`
Expected: No errors

**Step 7: Commit**

```
refactor(domain): remove old SmartPlaylistPattern and hardcoded pattern files
```

---

### Task 10: Create JSON asset and wire up in app

**Files:**
- Create: `packages/audiflow_app/assets/smart_playlist_patterns.json`
- Modify: `packages/audiflow_app/pubspec.yaml`
- Modify: `packages/audiflow_app/lib/app/providers.dart` (or appropriate provider file)

**Step 1: Create the JSON asset**

Write `packages/audiflow_app/assets/smart_playlist_patterns.json` with the full COTEN RADIO and NewsConnect patterns from the design doc.

**Step 2: Declare asset in pubspec.yaml**

Add to `packages/audiflow_app/pubspec.yaml` under `flutter.assets`:
```yaml
- assets/smart_playlist_patterns.json
```

**Step 3: Create app-layer provider**

In the appropriate app provider file, create a provider that:
1. Loads JSON via `rootBundle.loadString('assets/smart_playlist_patterns.json')`
2. Calls `SmartPlaylistPatternLoader.parse(jsonString)`
3. Overrides `smartPlaylistPatternsProvider` in domain

**Step 4: Run analyze**

Run: `analyze_files` on `packages/audiflow_app`
Expected: No errors

**Step 5: Commit**

```
feat(app): add smart playlist patterns JSON asset and loading provider
```

---

### Task 11: Integration verification

**Step 1: Run full domain test suite**

Run: `run_tests` on `packages/audiflow_domain`
Expected: PASS

**Step 2: Run full app analysis**

Run: `analyze_files` on all packages
Expected: No errors

**Step 3: Format all changed files**

Run: `dart_format` on all packages

**Step 4: Final commit if any formatting changes**

```
chore: format
```
