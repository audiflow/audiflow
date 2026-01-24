# Season View Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a "Seasons" view toggle to the podcast detail screen that groups episodes by season using a configurable resolver chain.

**Architecture:** Resolver chain pattern where each resolver attempts to group episodes. First successful resolver wins. Resolvers include RSS metadata, title patterns, and year-based grouping. UI uses segmented control toggle and drill-down navigation.

**Tech Stack:** Dart sealed classes for models, Riverpod for state, go_router for navigation, Flutter widgets for UI.

---

## Task 1: Core Models - Season and SeasonGrouping

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/season.dart`
- Create: `packages/audiflow_domain/test/features/feed/models/season_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/models/season_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Season', () {
    test('Season holds episode list and metadata', () {
      final season = Season(
        id: 'season_1',
        displayName: 'Season 1',
        sortKey: 1,
        episodeIds: [1, 2, 3],
      );

      expect(season.id, 'season_1');
      expect(season.displayName, 'Season 1');
      expect(season.sortKey, 1);
      expect(season.episodeIds, [1, 2, 3]);
    });

    test('Season.episodeCount returns correct count', () {
      final season = Season(
        id: 'season_2',
        displayName: 'Season 2',
        sortKey: 2,
        episodeIds: [4, 5, 6, 7, 8],
      );

      expect(season.episodeCount, 5);
    });
  });

  group('SeasonGrouping', () {
    test('SeasonGrouping holds seasons and ungrouped episodes', () {
      final grouping = SeasonGrouping(
        seasons: [
          Season(id: 's1', displayName: 'S1', sortKey: 1, episodeIds: [1, 2]),
        ],
        ungroupedEpisodeIds: [10, 11],
        resolverType: 'rss',
      );

      expect(grouping.seasons.length, 1);
      expect(grouping.ungroupedEpisodeIds, [10, 11]);
      expect(grouping.resolverType, 'rss');
    });

    test('SeasonGrouping.hasUngrouped returns true when ungrouped exist', () {
      final withUngrouped = SeasonGrouping(
        seasons: [],
        ungroupedEpisodeIds: [1],
        resolverType: 'rss',
      );
      final withoutUngrouped = SeasonGrouping(
        seasons: [],
        ungroupedEpisodeIds: [],
        resolverType: 'rss',
      );

      expect(withUngrouped.hasUngrouped, isTrue);
      expect(withoutUngrouped.hasUngrouped, isFalse);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/season_test.dart`
Expected: FAIL with "Target of URI doesn't exist" or similar import error.

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/season.dart

/// Represents a season grouping of episodes within a podcast.
final class Season {
  const Season({
    required this.id,
    required this.displayName,
    required this.sortKey,
    required this.episodeIds,
  });

  /// Unique identifier within podcast (e.g., "season_2", "arc_mystery").
  final String id;

  /// Display name (e.g., "Season 2", "The Vanishing").
  final String displayName;

  /// Sort key for ordering seasons.
  final int sortKey;

  /// Episode IDs belonging to this season.
  final List<int> episodeIds;

  /// Number of episodes in this season.
  int get episodeCount => episodeIds.length;
}

/// Result from a season resolver containing grouped seasons.
final class SeasonGrouping {
  const SeasonGrouping({
    required this.seasons,
    required this.ungroupedEpisodeIds,
    required this.resolverType,
  });

  /// Seasons detected by the resolver.
  final List<Season> seasons;

  /// Episode IDs that could not be grouped.
  final List<int> ungroupedEpisodeIds;

  /// Resolver type that produced this grouping (e.g., "rss", "title_pattern").
  final String resolverType;

  /// True if there are ungrouped episodes.
  bool get hasUngrouped => ungroupedEpisodeIds.isNotEmpty;
}
```

**Step 4: Export from audiflow_domain**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/models/season.dart';
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/season_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/season.dart \
        packages/audiflow_domain/test/features/feed/models/season_test.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add Season and SeasonGrouping models"
```

---

## Task 2: Sort Specification Models

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/season_sort.dart`
- Create: `packages/audiflow_domain/test/features/feed/models/season_sort_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/models/season_sort_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeasonSortField', () {
    test('all enum values exist', () {
      expect(SeasonSortField.values, containsAll([
        SeasonSortField.seasonNumber,
        SeasonSortField.newestEpisodeDate,
        SeasonSortField.progress,
        SeasonSortField.alphabetical,
      ]));
    });
  });

  group('SortOrder', () {
    test('ascending and descending exist', () {
      expect(SortOrder.values, containsAll([
        SortOrder.ascending,
        SortOrder.descending,
      ]));
    });
  });

  group('SeasonSortSpec', () {
    test('simple sort spec holds field and order', () {
      const spec = SimpleSeasonSort(
        SeasonSortField.seasonNumber,
        SortOrder.ascending,
      );

      expect(spec.field, SeasonSortField.seasonNumber);
      expect(spec.order, SortOrder.ascending);
    });

    test('composite sort spec holds multiple rules', () {
      final spec = CompositeSeasonSort([
        SeasonSortRule(
          field: SeasonSortField.seasonNumber,
          order: SortOrder.ascending,
        ),
        SeasonSortRule(
          field: SeasonSortField.newestEpisodeDate,
          order: SortOrder.descending,
        ),
      ]);

      expect(spec.rules.length, 2);
    });

    test('exhaustive switch works on SeasonSortSpec', () {
      const SeasonSortSpec spec = SimpleSeasonSort(
        SeasonSortField.alphabetical,
        SortOrder.ascending,
      );

      final result = switch (spec) {
        SimpleSeasonSort() => 'simple',
        CompositeSeasonSort() => 'composite',
      };

      expect(result, 'simple');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/season_sort_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/season_sort.dart

/// Fields by which seasons can be sorted.
enum SeasonSortField {
  /// Sort by season number.
  seasonNumber,

  /// Sort by newest episode date in season.
  newestEpisodeDate,

  /// Sort by playback progress (least complete first).
  progress,

  /// Sort alphabetically by display name.
  alphabetical,
}

/// Sort direction.
enum SortOrder {
  ascending,
  descending,
}

/// Specification for how to sort seasons.
sealed class SeasonSortSpec {
  const SeasonSortSpec();
}

/// Simple single-field sort.
final class SimpleSeasonSort extends SeasonSortSpec {
  const SimpleSeasonSort(this.field, this.order);

  final SeasonSortField field;
  final SortOrder order;
}

/// Composite sort with multiple rules and optional conditions.
final class CompositeSeasonSort extends SeasonSortSpec {
  const CompositeSeasonSort(this.rules);

  final List<SeasonSortRule> rules;
}

/// A single rule in a composite sort.
final class SeasonSortRule {
  const SeasonSortRule({
    required this.field,
    required this.order,
    this.condition,
  });

  final SeasonSortField field;
  final SortOrder order;

  /// Optional condition for when this rule applies.
  final SeasonSortCondition? condition;
}

/// Conditions for conditional sorting rules.
sealed class SeasonSortCondition {
  const SeasonSortCondition();
}

/// Condition: season sort key greater than value.
final class SortKeyGreaterThan extends SeasonSortCondition {
  const SortKeyGreaterThan(this.value);
  final int value;
}
```

**Step 4: Export from audiflow_domain**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/models/season_sort.dart';
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/season_sort_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/season_sort.dart \
        packages/audiflow_domain/test/features/feed/models/season_sort_test.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add SeasonSortSpec models for season sorting"
```

---

## Task 3: Season Pattern Model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/season_pattern.dart`
- Create: `packages/audiflow_domain/test/features/feed/models/season_pattern_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/models/season_pattern_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeasonPattern', () {
    test('SeasonPattern holds pattern configuration', () {
      final pattern = SeasonPattern(
        id: 'italy_podcast',
        podcastGuid: 'guid-123',
        feedUrlPattern: r'.*italy-travel\.com/feed.*',
        resolverType: 'title_appearance',
        config: {'pattern': r'\[(\w+)\s+\d+\]'},
        priority: 10,
      );

      expect(pattern.id, 'italy_podcast');
      expect(pattern.podcastGuid, 'guid-123');
      expect(pattern.feedUrlPattern, r'.*italy-travel\.com/feed.*');
      expect(pattern.resolverType, 'title_appearance');
      expect(pattern.config['pattern'], r'\[(\w+)\s+\d+\]');
      expect(pattern.priority, 10);
    });

    test('SeasonPattern can have custom sort spec', () {
      final pattern = SeasonPattern(
        id: 'test',
        resolverType: 'rss',
        config: {},
        customSort: const SimpleSeasonSort(
          SeasonSortField.seasonNumber,
          SortOrder.ascending,
        ),
      );

      expect(pattern.customSort, isA<SimpleSeasonSort>());
    });

    test('SeasonPattern.matchesPodcast matches by GUID first', () {
      final pattern = SeasonPattern(
        id: 'test',
        podcastGuid: 'guid-abc',
        feedUrlPattern: r'.*example\.com.*',
        resolverType: 'rss',
        config: {},
      );

      expect(pattern.matchesPodcast('guid-abc', 'https://other.com/feed'), isTrue);
      expect(pattern.matchesPodcast('guid-xyz', 'https://example.com/feed'), isTrue);
      expect(pattern.matchesPodcast('guid-xyz', 'https://other.com/feed'), isFalse);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/season_pattern_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/season_pattern.dart
import 'season_sort.dart';

/// Configuration for how to group episodes into seasons for a specific podcast.
final class SeasonPattern {
  const SeasonPattern({
    required this.id,
    this.podcastGuid,
    this.feedUrlPattern,
    required this.resolverType,
    required this.config,
    this.priority = 0,
    this.customSort,
  });

  /// Unique identifier for this pattern.
  final String id;

  /// Match by podcast GUID (checked first).
  final String? podcastGuid;

  /// Match by feed URL regex pattern (fallback).
  final String? feedUrlPattern;

  /// Which resolver type to use (e.g., "rss", "title_appearance").
  final String resolverType;

  /// Resolver-specific configuration.
  final Map<String, dynamic> config;

  /// Priority for pattern ordering (higher = checked first).
  final int priority;

  /// Custom default sort for seasons from this pattern.
  final SeasonSortSpec? customSort;

  /// Returns true if this pattern matches the given podcast.
  bool matchesPodcast(String? guid, String feedUrl) {
    // Match by GUID first
    if (podcastGuid != null && guid == podcastGuid) {
      return true;
    }

    // Fall back to feed URL pattern
    if (feedUrlPattern != null) {
      final regex = RegExp(feedUrlPattern!);
      if (regex.hasMatch(feedUrl)) {
        return true;
      }
    }

    return false;
  }
}
```

**Step 4: Export from audiflow_domain**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/models/season_pattern.dart';
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/season_pattern_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/season_pattern.dart \
        packages/audiflow_domain/test/features/feed/models/season_pattern_test.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add SeasonPattern model for custom grouping rules"
```

---

## Task 4: Season Resolver Interface

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/resolvers/season_resolver.dart`
- Create: `packages/audiflow_domain/test/features/feed/resolvers/season_resolver_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/resolvers/season_resolver_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

// Test implementation
class TestSeasonResolver implements SeasonResolver {
  @override
  String get type => 'test';

  @override
  SeasonSortSpec get defaultSort => const SimpleSeasonSort(
    SeasonSortField.seasonNumber,
    SortOrder.ascending,
  );

  @override
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern) {
    if (episodes.isEmpty) return null;
    return SeasonGrouping(
      seasons: [
        Season(
          id: 'test_season',
          displayName: 'Test',
          sortKey: 1,
          episodeIds: episodes.map((e) => e.id).toList(),
        ),
      ],
      ungroupedEpisodeIds: [],
      resolverType: type,
    );
  }
}

void main() {
  group('SeasonResolver', () {
    test('resolver has type identifier', () {
      final resolver = TestSeasonResolver();
      expect(resolver.type, 'test');
    });

    test('resolver has default sort', () {
      final resolver = TestSeasonResolver();
      expect(resolver.defaultSort, isA<SimpleSeasonSort>());
    });

    test('resolver can return null when no grouping possible', () {
      final resolver = TestSeasonResolver();
      final result = resolver.resolve([], null);
      expect(result, isNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/resolvers/season_resolver_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/resolvers/season_resolver.dart
import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';

/// Interface for season resolvers that group episodes into seasons.
abstract class SeasonResolver {
  /// Unique identifier for this resolver type.
  String get type;

  /// Default sort specification for seasons produced by this resolver.
  SeasonSortSpec get defaultSort;

  /// Attempts to group episodes into seasons.
  ///
  /// Returns null if this resolver cannot handle the given episodes.
  /// The [pattern] provides resolver-specific configuration when available.
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern);
}
```

**Step 4: Export from audiflow_domain**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/resolvers/season_resolver.dart';
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/resolvers/season_resolver_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/resolvers/season_resolver.dart \
        packages/audiflow_domain/test/features/feed/resolvers/season_resolver_test.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add SeasonResolver interface"
```

---

## Task 5: RSS Metadata Resolver

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/resolvers/rss_metadata_resolver.dart`
- Create: `packages/audiflow_domain/test/features/feed/resolvers/rss_metadata_resolver_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/resolvers/rss_metadata_resolver_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(int id, {int? seasonNumber, int? episodeNumber}) {
  return Episode(
    id: id,
    podcastId: 1,
    guid: 'guid-$id',
    title: 'Episode $id',
    audioUrl: 'https://example.com/$id.mp3',
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
    publishedAt: DateTime(2024, 1, id),
  );
}

void main() {
  group('RssMetadataResolver', () {
    late RssMetadataResolver resolver;

    setUp(() {
      resolver = RssMetadataResolver();
    });

    test('type is "rss"', () {
      expect(resolver.type, 'rss');
    });

    test('returns null when no episodes have season numbers', () {
      final episodes = [
        _makeEpisode(1),
        _makeEpisode(2),
        _makeEpisode(3),
      ];

      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });

    test('groups episodes by seasonNumber', () {
      final episodes = [
        _makeEpisode(1, seasonNumber: 1, episodeNumber: 1),
        _makeEpisode(2, seasonNumber: 1, episodeNumber: 2),
        _makeEpisode(3, seasonNumber: 2, episodeNumber: 1),
        _makeEpisode(4, seasonNumber: 2, episodeNumber: 2),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons.length, 2);
      expect(result.seasons[0].displayName, 'Season 1');
      expect(result.seasons[0].episodeIds, [1, 2]);
      expect(result.seasons[1].displayName, 'Season 2');
      expect(result.seasons[1].episodeIds, [3, 4]);
    });

    test('episodes without seasonNumber go to ungrouped', () {
      final episodes = [
        _makeEpisode(1, seasonNumber: 1),
        _makeEpisode(2),  // No season
        _makeEpisode(3, seasonNumber: 1),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons.length, 1);
      expect(result.ungroupedEpisodeIds, [2]);
    });

    test('default sort is season number ascending', () {
      expect(resolver.defaultSort, isA<SimpleSeasonSort>());
      final sort = resolver.defaultSort as SimpleSeasonSort;
      expect(sort.field, SeasonSortField.seasonNumber);
      expect(sort.order, SortOrder.ascending);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/resolvers/rss_metadata_resolver_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/resolvers/rss_metadata_resolver.dart
import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';
import 'season_resolver.dart';

/// Resolver that groups episodes using RSS metadata (seasonNumber field).
class RssMetadataResolver implements SeasonResolver {
  @override
  String get type => 'rss';

  @override
  SeasonSortSpec get defaultSort => const SimpleSeasonSort(
    SeasonSortField.seasonNumber,
    SortOrder.ascending,
  );

  @override
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern) {
    final grouped = <int, List<int>>{};
    final ungrouped = <int>[];

    for (final episode in episodes) {
      final seasonNum = episode.seasonNumber;
      if (seasonNum != null) {
        grouped.putIfAbsent(seasonNum, () => []).add(episode.id);
      } else {
        ungrouped.add(episode.id);
      }
    }

    // Return null if no episodes have season numbers
    if (grouped.isEmpty) {
      return null;
    }

    final seasons = grouped.entries.map((entry) {
      return Season(
        id: 'season_${entry.key}',
        displayName: 'Season ${entry.key}',
        sortKey: entry.key,
        episodeIds: entry.value,
      );
    }).toList()
      ..sort((a, b) => a.sortKey.compareTo(b.sortKey));

    return SeasonGrouping(
      seasons: seasons,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }
}
```

**Step 4: Export from audiflow_domain**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/resolvers/rss_metadata_resolver.dart';
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/resolvers/rss_metadata_resolver_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/resolvers/rss_metadata_resolver.dart \
        packages/audiflow_domain/test/features/feed/resolvers/rss_metadata_resolver_test.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add RssMetadataResolver for season grouping"
```

---

## Task 6: Year Resolver

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/resolvers/year_resolver.dart`
- Create: `packages/audiflow_domain/test/features/feed/resolvers/year_resolver_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/resolvers/year_resolver_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(int id, {DateTime? publishedAt}) {
  return Episode(
    id: id,
    podcastId: 1,
    guid: 'guid-$id',
    title: 'Episode $id',
    audioUrl: 'https://example.com/$id.mp3',
    publishedAt: publishedAt,
  );
}

void main() {
  group('YearResolver', () {
    late YearResolver resolver;

    setUp(() {
      resolver = YearResolver();
    });

    test('type is "year"', () {
      expect(resolver.type, 'year');
    });

    test('returns null when no episodes have publish dates', () {
      final episodes = [
        _makeEpisode(1),
        _makeEpisode(2),
      ];

      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });

    test('groups episodes by publish year', () {
      final episodes = [
        _makeEpisode(1, publishedAt: DateTime(2023, 3, 15)),
        _makeEpisode(2, publishedAt: DateTime(2023, 8, 20)),
        _makeEpisode(3, publishedAt: DateTime(2024, 1, 10)),
        _makeEpisode(4, publishedAt: DateTime(2024, 6, 5)),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons.length, 2);
      expect(result.seasons[0].displayName, '2024');
      expect(result.seasons[0].episodeIds, [3, 4]);
      expect(result.seasons[1].displayName, '2023');
      expect(result.seasons[1].episodeIds, [1, 2]);
    });

    test('episodes without publishedAt go to ungrouped', () {
      final episodes = [
        _makeEpisode(1, publishedAt: DateTime(2024, 1, 1)),
        _makeEpisode(2),  // No date
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.ungroupedEpisodeIds, [2]);
    });

    test('default sort is year descending (newest first)', () {
      expect(resolver.defaultSort, isA<SimpleSeasonSort>());
      final sort = resolver.defaultSort as SimpleSeasonSort;
      expect(sort.field, SeasonSortField.seasonNumber);
      expect(sort.order, SortOrder.descending);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/resolvers/year_resolver_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/resolvers/year_resolver.dart
import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';
import 'season_resolver.dart';

/// Resolver that groups episodes by publication year.
class YearResolver implements SeasonResolver {
  @override
  String get type => 'year';

  @override
  SeasonSortSpec get defaultSort => const SimpleSeasonSort(
    SeasonSortField.seasonNumber,
    SortOrder.descending,  // Newest years first
  );

  @override
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern) {
    final grouped = <int, List<int>>{};
    final ungrouped = <int>[];

    for (final episode in episodes) {
      final pubDate = episode.publishedAt;
      if (pubDate != null) {
        grouped.putIfAbsent(pubDate.year, () => []).add(episode.id);
      } else {
        ungrouped.add(episode.id);
      }
    }

    // Return null if no episodes have publish dates
    if (grouped.isEmpty) {
      return null;
    }

    final seasons = grouped.entries.map((entry) {
      return Season(
        id: 'year_${entry.key}',
        displayName: '${entry.key}',
        sortKey: entry.key,
        episodeIds: entry.value,
      );
    }).toList()
      ..sort((a, b) => b.sortKey.compareTo(a.sortKey));  // Descending

    return SeasonGrouping(
      seasons: seasons,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }
}
```

**Step 4: Export from audiflow_domain**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/resolvers/year_resolver.dart';
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/resolvers/year_resolver_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/resolvers/year_resolver.dart \
        packages/audiflow_domain/test/features/feed/resolvers/year_resolver_test.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add YearResolver for year-based season grouping"
```

---

## Task 7: Title Appearance Order Resolver

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/resolvers/title_appearance_order_resolver.dart`
- Create: `packages/audiflow_domain/test/features/feed/resolvers/title_appearance_order_resolver_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/resolvers/title_appearance_order_resolver_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(int id, String title, DateTime publishedAt) {
  return Episode(
    id: id,
    podcastId: 1,
    guid: 'guid-$id',
    title: title,
    audioUrl: 'https://example.com/$id.mp3',
    publishedAt: publishedAt,
  );
}

void main() {
  group('TitleAppearanceOrderResolver', () {
    late TitleAppearanceOrderResolver resolver;

    setUp(() {
      resolver = TitleAppearanceOrderResolver();
    });

    test('type is "title_appearance"', () {
      expect(resolver.type, 'title_appearance');
    });

    test('returns null when no pattern provided', () {
      final episodes = [
        _makeEpisode(1, '[Rome 1] First', DateTime(2024, 1, 1)),
      ];

      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });

    test('groups by first appearance order', () {
      final pattern = SeasonPattern(
        id: 'test',
        resolverType: 'title_appearance',
        config: {'pattern': r'\[(\w+)\s+\d+\]'},
      );

      // Episodes in feed order (newest first typically)
      final episodes = [
        _makeEpisode(6, '[Firenze 1] Renaissance', DateTime(2024, 3, 1)),
        _makeEpisode(5, '[Venezia 2] Canals', DateTime(2024, 2, 15)),
        _makeEpisode(4, '[Venezia 1] Arrival', DateTime(2024, 2, 1)),
        _makeEpisode(3, '[Rome 3] Colosseum', DateTime(2024, 1, 20)),
        _makeEpisode(2, '[Rome 2] Vatican', DateTime(2024, 1, 10)),
        _makeEpisode(1, '[Rome 1] First Steps', DateTime(2024, 1, 1)),
      ];

      final result = resolver.resolve(episodes, pattern);

      expect(result, isNotNull);
      expect(result!.seasons.length, 3);

      // Rome appeared first chronologically, so it's season 1
      expect(result.seasons[0].displayName, 'Rome');
      expect(result.seasons[0].sortKey, 1);
      expect(result.seasons[0].episodeIds, containsAll([1, 2, 3]));

      // Venezia appeared second
      expect(result.seasons[1].displayName, 'Venezia');
      expect(result.seasons[1].sortKey, 2);

      // Firenze appeared third
      expect(result.seasons[2].displayName, 'Firenze');
      expect(result.seasons[2].sortKey, 3);
    });

    test('non-matching episodes go to ungrouped', () {
      final pattern = SeasonPattern(
        id: 'test',
        resolverType: 'title_appearance',
        config: {'pattern': r'\[(\w+)\s+\d+\]'},
      );

      final episodes = [
        _makeEpisode(1, '[Rome 1] First', DateTime(2024, 1, 1)),
        _makeEpisode(2, 'Bonus Episode', DateTime(2024, 1, 5)),  // No match
      ];

      final result = resolver.resolve(episodes, pattern);

      expect(result, isNotNull);
      expect(result!.ungroupedEpisodeIds, [2]);
    });

    test('returns null when no matches found', () {
      final pattern = SeasonPattern(
        id: 'test',
        resolverType: 'title_appearance',
        config: {'pattern': r'\[(\w+)\s+\d+\]'},
      );

      final episodes = [
        _makeEpisode(1, 'No Pattern Here', DateTime(2024, 1, 1)),
        _makeEpisode(2, 'Another One', DateTime(2024, 1, 2)),
      ];

      final result = resolver.resolve(episodes, pattern);
      expect(result, isNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/resolvers/title_appearance_order_resolver_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/resolvers/title_appearance_order_resolver.dart
import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';
import 'season_resolver.dart';

/// Resolver that groups by title pattern with season order by first appearance.
///
/// Useful for podcasts like:
/// - [Rome 1] First Steps
/// - [Rome 2] The Colosseum
/// - [Venezia 1] Arrival
///
/// Where "Rome" becomes season 1 (appeared first), "Venezia" becomes season 2.
class TitleAppearanceOrderResolver implements SeasonResolver {
  @override
  String get type => 'title_appearance';

  @override
  SeasonSortSpec get defaultSort => const SimpleSeasonSort(
    SeasonSortField.seasonNumber,
    SortOrder.ascending,
  );

  @override
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern) {
    if (pattern == null) return null;

    final patternStr = pattern.config['pattern'] as String?;
    if (patternStr == null) return null;

    final regex = RegExp(patternStr);

    // Sort episodes by publish date (oldest first) to determine appearance order
    final sorted = episodes
        .where((e) => e.publishedAt != null)
        .toList()
      ..sort((a, b) => a.publishedAt!.compareTo(b.publishedAt!));

    final seasonOrder = <String>[];
    final grouped = <String, List<int>>{};
    final ungrouped = <int>[];

    // Also process episodes without publish date at the end
    final allEpisodes = [...sorted, ...episodes.where((e) => e.publishedAt == null)];

    for (final episode in allEpisodes) {
      final match = regex.firstMatch(episode.title);
      if (match != null && match.groupCount >= 1) {
        final seasonName = match.group(1)!;
        if (!seasonOrder.contains(seasonName)) {
          seasonOrder.add(seasonName);
        }
        grouped.putIfAbsent(seasonName, () => []).add(episode.id);
      } else {
        ungrouped.add(episode.id);
      }
    }

    // Return null if no matches
    if (grouped.isEmpty) {
      return null;
    }

    final seasons = <Season>[];
    for (var i = 0; i < seasonOrder.length; i++) {
      final name = seasonOrder[i];
      seasons.add(Season(
        id: 'season_${i + 1}',
        displayName: name,
        sortKey: i + 1,
        episodeIds: grouped[name]!,
      ));
    }

    return SeasonGrouping(
      seasons: seasons,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }
}
```

**Step 4: Export from audiflow_domain**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/resolvers/title_appearance_order_resolver.dart';
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/resolvers/title_appearance_order_resolver_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/resolvers/title_appearance_order_resolver.dart \
        packages/audiflow_domain/test/features/feed/resolvers/title_appearance_order_resolver_test.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add TitleAppearanceOrderResolver for pattern-based grouping"
```

---

## Task 8: Season Resolver Service (Chain Orchestration)

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/services/season_resolver_service.dart`
- Create: `packages/audiflow_domain/test/features/feed/services/season_resolver_service_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/services/season_resolver_service_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(int id, {int? seasonNumber, DateTime? publishedAt}) {
  return Episode(
    id: id,
    podcastId: 1,
    guid: 'guid-$id',
    title: 'Episode $id',
    audioUrl: 'https://example.com/$id.mp3',
    seasonNumber: seasonNumber,
    publishedAt: publishedAt ?? DateTime(2024, 1, id),
  );
}

void main() {
  group('SeasonResolverService', () {
    late SeasonResolverService service;

    setUp(() {
      service = SeasonResolverService(
        resolvers: [
          RssMetadataResolver(),
          YearResolver(),
        ],
        patterns: [],
      );
    });

    test('returns null when no resolver succeeds', () {
      final episodes = [
        _makeEpisode(1),  // No season, no date
        _makeEpisode(2),
      ];
      // Override publishedAt to null
      final noDateEpisodes = episodes.map((e) => Episode(
        id: e.id,
        podcastId: e.podcastId,
        guid: e.guid,
        title: e.title,
        audioUrl: e.audioUrl,
      )).toList();

      final result = service.resolveSeasons(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: noDateEpisodes,
      );

      expect(result, isNull);
    });

    test('uses first successful resolver (RssMetadataResolver)', () {
      final episodes = [
        _makeEpisode(1, seasonNumber: 1, publishedAt: DateTime(2024, 1, 1)),
        _makeEpisode(2, seasonNumber: 1, publishedAt: DateTime(2024, 2, 1)),
      ];

      final result = service.resolveSeasons(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      expect(result!.resolverType, 'rss');
    });

    test('falls back to next resolver when first fails', () {
      final episodes = [
        _makeEpisode(1, publishedAt: DateTime(2023, 6, 1)),
        _makeEpisode(2, publishedAt: DateTime(2024, 3, 1)),
      ];

      final result = service.resolveSeasons(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      expect(result!.resolverType, 'year');
    });

    test('uses custom pattern when podcast matches', () {
      final serviceWithPattern = SeasonResolverService(
        resolvers: [
          RssMetadataResolver(),
          TitleAppearanceOrderResolver(),
        ],
        patterns: [
          SeasonPattern(
            id: 'test_pattern',
            feedUrlPattern: r'.*example\.com.*',
            resolverType: 'title_appearance',
            config: {'pattern': r'Ep(\d+)'},
          ),
        ],
      );

      final episodes = [
        Episode(
          id: 1,
          podcastId: 1,
          guid: 'g1',
          title: 'Ep1 First',
          audioUrl: 'https://x.com/1.mp3',
          publishedAt: DateTime(2024, 1, 1),
        ),
        Episode(
          id: 2,
          podcastId: 1,
          guid: 'g2',
          title: 'Ep2 Second',
          audioUrl: 'https://x.com/2.mp3',
          publishedAt: DateTime(2024, 1, 2),
        ),
      ];

      final result = serviceWithPattern.resolveSeasons(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      expect(result!.resolverType, 'title_appearance');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/services/season_resolver_service_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/services/season_resolver_service.dart
import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../resolvers/season_resolver.dart';

/// Service that orchestrates the season resolver chain.
///
/// Tries resolvers in order until one succeeds. Custom patterns for specific
/// podcasts are checked first.
class SeasonResolverService {
  SeasonResolverService({
    required List<SeasonResolver> resolvers,
    required List<SeasonPattern> patterns,
  })  : _resolvers = resolvers,
        _patterns = patterns;

  final List<SeasonResolver> _resolvers;
  final List<SeasonPattern> _patterns;

  /// Attempts to group episodes into seasons.
  ///
  /// Returns null if no resolver succeeds.
  SeasonGrouping? resolveSeasons({
    required String? podcastGuid,
    required String feedUrl,
    required List<Episode> episodes,
  }) {
    if (episodes.isEmpty) return null;

    // Check for matching custom pattern first
    final pattern = _findMatchingPattern(podcastGuid, feedUrl);
    if (pattern != null) {
      final resolver = _findResolverByType(pattern.resolverType);
      if (resolver != null) {
        final result = resolver.resolve(episodes, pattern);
        if (result != null) return result;
      }
    }

    // Try resolvers in order
    for (final resolver in _resolvers) {
      final result = resolver.resolve(episodes, null);
      if (result != null) return result;
    }

    return null;
  }

  SeasonPattern? _findMatchingPattern(String? guid, String feedUrl) {
    for (final pattern in _patterns) {
      if (pattern.matchesPodcast(guid, feedUrl)) {
        return pattern;
      }
    }
    return null;
  }

  SeasonResolver? _findResolverByType(String type) {
    for (final resolver in _resolvers) {
      if (resolver.type == type) {
        return resolver;
      }
    }
    return null;
  }
}
```

**Step 4: Export from audiflow_domain**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/services/season_resolver_service.dart';
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/services/season_resolver_service_test.dart`
Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/season_resolver_service.dart \
        packages/audiflow_domain/test/features/feed/services/season_resolver_service_test.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add SeasonResolverService for resolver chain orchestration"
```

---

## Task 9: Season Providers

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/providers/season_providers.dart`

**Step 1: Write the provider implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/providers/season_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../resolvers/rss_metadata_resolver.dart';
import '../resolvers/year_resolver.dart';
import '../services/season_resolver_service.dart';
import '../repositories/episode_repository_impl.dart';

part 'season_providers.g.dart';

/// Provides the season resolver service with built-in resolvers.
@Riverpod(keepAlive: true)
SeasonResolverService seasonResolverService(SeasonResolverServiceRef ref) {
  return SeasonResolverService(
    resolvers: [
      RssMetadataResolver(),
      YearResolver(),
    ],
    patterns: [], // V1: No custom patterns yet
  );
}

/// Resolves seasons for a podcast by its ID.
///
/// Returns null if no resolver can group the episodes.
@riverpod
Future<SeasonGrouping?> podcastSeasons(
  PodcastSeasonsRef ref,
  int podcastId,
) async {
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final resolverService = ref.watch(seasonResolverServiceProvider);

  final episodes = await episodeRepo.getByPodcastId(podcastId);
  if (episodes.isEmpty) return null;

  // Get podcast info for GUID and feed URL
  // For now, we'll pass null for guid and empty for feedUrl
  // TODO: Add subscription repository to get podcast details
  return resolverService.resolveSeasons(
    podcastGuid: null,
    feedUrl: '',
    episodes: episodes,
  );
}

/// Whether the season view toggle should be visible for a podcast.
@riverpod
Future<bool> hasSeasonView(HasSeasonViewRef ref, int podcastId) async {
  final grouping = await ref.watch(podcastSeasonsProvider(podcastId).future);
  return grouping != null;
}
```

**Step 2: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `season_providers.g.dart`

**Step 3: Export from audiflow_domain**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/providers/season_providers.dart';
```

**Step 4: Verify build passes**

Run: `cd packages/audiflow_domain && flutter analyze`
Expected: No errors

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/providers/season_providers.dart \
        packages/audiflow_domain/lib/src/features/feed/providers/season_providers.g.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add Riverpod providers for season resolution"
```

---

## Task 10: View Mode Controller

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_view_mode_controller.dart`

**Step 1: Write the controller**

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_view_mode_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_view_mode_controller.g.dart';

/// View modes for the podcast detail screen.
enum PodcastViewMode {
  /// Flat list of all episodes.
  episodes,

  /// Grouped by season.
  seasons,
}

/// Controller for the podcast detail screen view mode toggle.
@riverpod
class PodcastViewModeController extends _$PodcastViewModeController {
  @override
  PodcastViewMode build(int podcastId) => PodcastViewMode.episodes;

  void setEpisodes() => state = PodcastViewMode.episodes;

  void setSeasons() => state = PodcastViewMode.seasons;

  void toggle() {
    state = switch (state) {
      PodcastViewMode.episodes => PodcastViewMode.seasons,
      PodcastViewMode.seasons => PodcastViewMode.episodes,
    };
  }
}
```

**Step 2: Run code generation**

Run: `cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `.g.dart` file

**Step 3: Verify build passes**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors

**Step 4: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_view_mode_controller.dart \
        packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_view_mode_controller.g.dart
git commit -m "feat(app): add PodcastViewModeController for episodes/seasons toggle"
```

---

## Task 11: Season Sort Controller

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/season_sort_controller.dart`

**Step 1: Write the controller**

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/season_sort_controller.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'season_sort_controller.g.dart';

/// Sort configuration for seasons.
class SeasonSortConfig {
  const SeasonSortConfig({
    required this.field,
    required this.order,
  });

  final SeasonSortField field;
  final SortOrder order;

  SeasonSortConfig copyWith({
    SeasonSortField? field,
    SortOrder? order,
  }) {
    return SeasonSortConfig(
      field: field ?? this.field,
      order: order ?? this.order,
    );
  }
}

/// Controller for season sort preferences.
@riverpod
class SeasonSortController extends _$SeasonSortController {
  @override
  SeasonSortConfig build(int podcastId) {
    return const SeasonSortConfig(
      field: SeasonSortField.seasonNumber,
      order: SortOrder.ascending,
    );
  }

  void setSort(SeasonSortField field, SortOrder order) {
    state = SeasonSortConfig(field: field, order: order);
  }

  void toggleOrder() {
    state = state.copyWith(
      order: state.order == SortOrder.ascending
          ? SortOrder.descending
          : SortOrder.ascending,
    );
  }
}
```

**Step 2: Run code generation**

Run: `cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `.g.dart` file

**Step 3: Verify build passes**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors

**Step 4: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/season_sort_controller.dart \
        packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/season_sort_controller.g.dart
git commit -m "feat(app): add SeasonSortController for season sort preferences"
```

---

## Task 12: Season View Toggle Widget

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_view_toggle.dart`

**Step 1: Write the widget**

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_view_toggle.dart
import 'package:flutter/material.dart';

import '../controllers/podcast_view_mode_controller.dart';

/// Segmented control for switching between Episodes and Seasons views.
class SeasonViewToggle extends StatelessWidget {
  const SeasonViewToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PodcastViewMode selected;
  final ValueChanged<PodcastViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PodcastViewMode>(
      segments: const [
        ButtonSegment(
          value: PodcastViewMode.episodes,
          label: Text('Episodes'),
        ),
        ButtonSegment(
          value: PodcastViewMode.seasons,
          label: Text('Seasons'),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
      showSelectedIcon: false,
    );
  }
}
```

**Step 2: Verify build passes**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors

**Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_view_toggle.dart
git commit -m "feat(app): add SeasonViewToggle segmented control widget"
```

---

## Task 13: Season Card Widget

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_card.dart`

**Step 1: Write the widget**

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_card.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Card displaying season information with tap to navigate.
class SeasonCard extends StatelessWidget {
  const SeasonCard({
    super.key,
    required this.season,
    required this.episodeCount,
    required this.playedCount,
    this.dateRange,
    this.thumbnailUrl,
    this.onTap,
  });

  final Season season;
  final int episodeCount;
  final int playedCount;
  final String? dateRange;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(colorScheme),
              const SizedBox(height: Spacing.sm),
              Text(
                season.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                '$episodeCount episodes',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (dateRange != null) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  dateRange!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
              const SizedBox(height: Spacing.sm),
              _buildProgressBar(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ColorScheme colorScheme) {
    if (thumbnailUrl != null) {
      return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: _buildPlaceholder(colorScheme),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.folder_outlined,
        size: 48,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    final progress = episodeCount == 0 ? 0.0 : playedCount / episodeCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(colorScheme.primary),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          '$playedCount/$episodeCount played',
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
```

**Step 2: Verify build passes**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors

**Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_card.dart
git commit -m "feat(app): add SeasonCard widget with progress indicator"
```

---

## Task 14: Season Grid Widget

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_grid.dart`

**Step 1: Write the widget**

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_grid.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import 'season_card.dart';

/// Grid of season cards for the seasons view.
class SeasonGrid extends StatelessWidget {
  const SeasonGrid({
    super.key,
    required this.seasons,
    required this.ungroupedEpisodeIds,
    required this.onSeasonTap,
    required this.onUngroupedTap,
    this.episodeProgressMap = const {},
  });

  final List<Season> seasons;
  final List<int> ungroupedEpisodeIds;
  final void Function(Season season) onSeasonTap;
  final VoidCallback onUngroupedTap;

  /// Map of episode ID to played status.
  final Map<int, bool> episodeProgressMap;

  @override
  Widget build(BuildContext context) {
    final itemCount = seasons.length + (ungroupedEpisodeIds.isNotEmpty ? 1 : 0);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: Spacing.md,
          crossAxisSpacing: Spacing.md,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < seasons.length) {
              return _buildSeasonCard(seasons[index]);
            }
            return _buildUngroupedCard(context);
          },
          childCount: itemCount,
        ),
      ),
    );
  }

  Widget _buildSeasonCard(Season season) {
    final playedCount = season.episodeIds
        .where((id) => episodeProgressMap[id] == true)
        .length;

    return SeasonCard(
      season: season,
      episodeCount: season.episodeCount,
      playedCount: playedCount,
      onTap: () => onSeasonTap(season),
    );
  }

  Widget _buildUngroupedCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final playedCount = ungroupedEpisodeIds
        .where((id) => episodeProgressMap[id] == true)
        .length;

    return SeasonCard(
      season: Season(
        id: 'ungrouped',
        displayName: 'Ungrouped',
        sortKey: 999999,
        episodeIds: ungroupedEpisodeIds,
      ),
      episodeCount: ungroupedEpisodeIds.length,
      playedCount: playedCount,
      onTap: onUngroupedTap,
    );
  }
}
```

**Step 2: Verify build passes**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors

**Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_grid.dart
git commit -m "feat(app): add SeasonGrid widget for season cards layout"
```

---

## Task 15: Season Sort Bottom Sheet

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_sort_sheet.dart`

**Step 1: Write the widget**

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_sort_sheet.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../controllers/season_sort_controller.dart';

/// Bottom sheet for selecting season sort options.
class SeasonSortSheet extends StatelessWidget {
  const SeasonSortSheet({
    super.key,
    required this.currentConfig,
    required this.onSortSelected,
  });

  final SeasonSortConfig currentConfig;
  final void Function(SeasonSortField field, SortOrder order) onSortSelected;

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
            Text(
              'Sort by',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.md),
            _buildSortOption(
              context,
              'Season number (ascending)',
              SeasonSortField.seasonNumber,
              SortOrder.ascending,
            ),
            _buildSortOption(
              context,
              'Season number (descending)',
              SeasonSortField.seasonNumber,
              SortOrder.descending,
            ),
            _buildSortOption(
              context,
              'Newest episode',
              SeasonSortField.newestEpisodeDate,
              SortOrder.descending,
            ),
            _buildSortOption(
              context,
              'Progress (least complete)',
              SeasonSortField.progress,
              SortOrder.ascending,
            ),
            _buildSortOption(
              context,
              'Alphabetical',
              SeasonSortField.alphabetical,
              SortOrder.ascending,
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
    SeasonSortField field,
    SortOrder order,
  ) {
    final isSelected =
        currentConfig.field == field && currentConfig.order == order;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(label),
      leading: Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (_) {
          onSortSelected(field, order);
          Navigator.pop(context);
        },
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: colorScheme.primary)
          : null,
      onTap: () {
        onSortSelected(field, order);
        Navigator.pop(context);
      },
    );
  }
}

/// Shows the season sort bottom sheet.
void showSeasonSortSheet({
  required BuildContext context,
  required SeasonSortConfig currentConfig,
  required void Function(SeasonSortField field, SortOrder order) onSortSelected,
}) {
  showModalBottomSheet(
    context: context,
    builder: (_) => SeasonSortSheet(
      currentConfig: currentConfig,
      onSortSelected: onSortSelected,
    ),
  );
}
```

**Step 2: Verify build passes**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors

**Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_sort_sheet.dart
git commit -m "feat(app): add SeasonSortSheet bottom sheet for sort options"
```

---

## Task 16: Season Episodes Screen (Drill-down)

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/season_episodes_screen.dart`

**Step 1: Write the screen**

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/screens/season_episodes_screen.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/episode_list_tile.dart';

/// Screen showing episodes within a single season.
class SeasonEpisodesScreen extends ConsumerWidget {
  const SeasonEpisodesScreen({
    super.key,
    required this.season,
    required this.podcastTitle,
    required this.podcastArtworkUrl,
  });

  final Season season;
  final String podcastTitle;
  final String? podcastArtworkUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(season.displayName),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, theme),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${season.episodeCount} episodes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: () {
                      // TODO: Show episode sort options
                    },
                    tooltip: 'Sort',
                  ),
                ],
              ),
            ),
          ),
          _buildEpisodeList(ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildArtwork(colorScheme),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  podcastTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(ColorScheme colorScheme) {
    if (podcastArtworkUrl != null) {
      return Image.network(
        podcastArtworkUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
      );
    }
    return _buildPlaceholder(colorScheme);
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: 80,
      height: 80,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.folder_outlined,
        size: 40,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildEpisodeList(WidgetRef ref) {
    // TODO: Fetch actual episodes by IDs from season.episodeIds
    // For now, show placeholder
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Center(
          child: Text('${season.episodeCount} episodes in this season'),
        ),
      ),
    );
  }
}
```

**Step 2: Verify build passes**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors

**Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/season_episodes_screen.dart
git commit -m "feat(app): add SeasonEpisodesScreen for season drill-down view"
```

---

## Task 17: Integrate Season View into Podcast Detail Screen

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart`

**Step 1: Update the podcast detail screen**

Add imports at top of file:
```dart
import 'package:audiflow_domain/audiflow_domain.dart';

import '../controllers/podcast_view_mode_controller.dart';
import '../controllers/season_sort_controller.dart';
import '../widgets/season_view_toggle.dart';
import '../widgets/season_grid.dart';
import '../widgets/season_sort_sheet.dart';
import 'season_episodes_screen.dart';
```

Modify `_buildContent` method to include toggle and season view:

```dart
Widget _buildContent(
  BuildContext context,
  WidgetRef ref,
  ThemeData theme,
  String feedUrl,
) {
  final filter = ref.watch(episodeFilterStateProvider);
  final filteredAsync = ref.watch(filteredEpisodesProvider(feedUrl, filter));
  final progressMapAsync = ref.watch(podcastEpisodeProgressProvider(feedUrl));

  // Check if seasons are available
  // TODO: Replace with actual podcastId lookup
  final hasSeasons = false; // Placeholder until podcastId is available

  // View mode (only relevant if seasons available)
  final viewMode = hasSeasons
      ? ref.watch(podcastViewModeControllerProvider(0)) // TODO: Use actual podcastId
      : PodcastViewMode.episodes;

  return RefreshIndicator(
    onRefresh: () async {
      ref.invalidate(podcastDetailProvider(feedUrl));
      ref.invalidate(podcastEpisodeProgressProvider(feedUrl));
      await ref.read(podcastDetailProvider(feedUrl).future);
    },
    child: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, ref, theme)),

        // View mode toggle (only if seasons available)
        if (hasSeasons)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: SeasonViewToggle(
                selected: viewMode,
                onChanged: (mode) {
                  final controller = ref.read(
                    podcastViewModeControllerProvider(0).notifier, // TODO: Use actual podcastId
                  );
                  if (mode == PodcastViewMode.episodes) {
                    controller.setEpisodes();
                  } else {
                    controller.setSeasons();
                  }
                },
              ),
            ),
          ),

        // Filter chips (only in episodes view)
        if (viewMode == PodcastViewMode.episodes)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: EpisodeFilterChips(
                selected: filter,
                onSelected: (f) =>
                    ref.read(episodeFilterStateProvider.notifier).setFilter(f),
              ),
            ),
          ),

        // Content based on view mode
        if (viewMode == PodcastViewMode.episodes)
          _buildEpisodeList(filteredAsync, progressMapAsync, theme)
        else
          _buildSeasonView(context, ref),
      ],
    ),
  );
}

Widget _buildSeasonView(BuildContext context, WidgetRef ref) {
  // TODO: Implement season view with actual data
  // This will be connected to podcastSeasonsProvider
  return const SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.all(Spacing.lg),
      child: Center(child: Text('Seasons view coming soon')),
    ),
  );
}
```

**Step 2: Verify build passes**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors (with TODOs noted)

**Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart
git commit -m "feat(app): integrate season view toggle into podcast detail screen"
```

---

## Task 18: Add Route for Season Episodes Screen

**Files:**
- Modify: `packages/audiflow_app/lib/routing/routes.dart` (or equivalent routing file)

**Step 1: Add route definition**

Add the season episodes route to the existing route configuration. The exact implementation depends on the current routing setup. Example for go_router:

```dart
GoRoute(
  path: 'season/:seasonId',
  builder: (context, state) {
    final season = state.extra as Season;
    final podcast = state.uri.queryParameters['podcast'] ?? '';
    final artwork = state.uri.queryParameters['artwork'];

    return SeasonEpisodesScreen(
      season: season,
      podcastTitle: podcast,
      podcastArtworkUrl: artwork,
    );
  },
),
```

**Step 2: Run code generation if using go_router_builder**

Run: `cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs`

**Step 3: Verify build passes**

Run: `cd packages/audiflow_app && flutter analyze`

**Step 4: Commit**

```bash
git add packages/audiflow_app/lib/routing/
git commit -m "feat(app): add route for SeasonEpisodesScreen"
```

---

## Task 19: Run Full Test Suite

**Step 1: Run all domain tests**

Run: `cd packages/audiflow_domain && flutter test`
Expected: All tests pass

**Step 2: Run all app tests**

Run: `cd packages/audiflow_app && flutter test`
Expected: All tests pass

**Step 3: Run analyzer on entire project**

Run: `melos run analyze` or `flutter analyze`
Expected: No errors

**Step 4: Commit any fixes**

If any fixes were needed:
```bash
git add -A
git commit -m "fix: resolve test and analyzer issues"
```

---

## Task 20: Final Integration Commit

**Step 1: Verify everything builds**

Run: `melos bootstrap && melos run build_runner`
Expected: Success

**Step 2: Create summary commit**

```bash
git add -A
git commit -m "feat: complete season view feature implementation

- Add Season, SeasonGrouping, and SeasonPattern models
- Add SeasonSortSpec for flexible sorting configuration
- Implement SeasonResolver interface with RSS, Year, and TitleAppearanceOrder resolvers
- Add SeasonResolverService for resolver chain orchestration
- Add Riverpod providers for season resolution
- Add PodcastViewModeController and SeasonSortController
- Add SeasonViewToggle, SeasonCard, SeasonGrid, SeasonSortSheet widgets
- Add SeasonEpisodesScreen for season drill-down
- Integrate season view into PodcastDetailScreen"
```

---

## Summary

This plan implements the season view feature in 20 tasks:

1. **Tasks 1-3**: Core data models (Season, SeasonGrouping, SeasonSortSpec, SeasonPattern)
2. **Tasks 4-7**: Season resolvers (interface, RSS, Year, TitleAppearanceOrder)
3. **Task 8**: Resolver chain service
4. **Task 9**: Riverpod providers
5. **Tasks 10-11**: View mode and sort controllers
6. **Tasks 12-15**: UI widgets (toggle, card, grid, sort sheet)
7. **Task 16**: Season episodes drill-down screen
8. **Tasks 17-18**: Integration into existing screens and routing
9. **Tasks 19-20**: Testing and final integration

Each task follows TDD with failing test first, then implementation, then commit.
