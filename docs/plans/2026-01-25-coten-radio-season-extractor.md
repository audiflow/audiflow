# COTEN RADIO Season Extractor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add custom season extraction support for COTEN RADIO podcast with Seasons persistence, enhanced pattern matching, and episode number extraction.

**Architecture:** Extend existing season resolver system with: (1) new Seasons Drift table for persistence, (2) EpisodeNumberExtractor for on-demand extraction, (3) enhanced SeasonPattern with multiple URL patterns, (4) RssMetadataResolver config for grouping null seasons.

**Tech Stack:** Drift (SQLite), Riverpod, dart:core RegExp

---

## Task 1: Create Seasons Drift Table

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/seasons.dart`
- Test: `packages/audiflow_domain/test/features/feed/models/seasons_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/models/seasons_test.dart
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_domain/src/features/feed/models/seasons.dart';

void main() {
  group('Seasons table', () {
    test('has correct columns defined', () {
      final seasons = Seasons();
      expect(seasons.podcastId, isA<GeneratedColumn<int>>());
      expect(seasons.seasonNumber, isA<GeneratedColumn<int>>());
      expect(seasons.displayName, isA<GeneratedColumn<String>>());
      expect(seasons.sortKey, isA<GeneratedColumn<int>>());
      expect(seasons.resolverType, isA<GeneratedColumn<String>>());
    });

    test('has composite primary key', () {
      final seasons = Seasons();
      expect(seasons.primaryKey, containsAll([seasons.podcastId, seasons.seasonNumber]));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && dart test test/features/feed/models/seasons_test.dart`
Expected: FAIL with import error

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/seasons.dart
import 'package:drift/drift.dart';

/// Drift table for persisted season metadata.
///
/// Uses composite primary key (podcastId, seasonNumber) for natural joins
/// with Episodes table without requiring FK modifications.
class Seasons extends Table {
  /// Foreign key to podcast (part of composite PK).
  IntColumn get podcastId => integer()();

  /// Season number matching episode.seasonNumber (part of composite PK).
  /// Use 0 for ungrouped/extras seasons like "番外編".
  IntColumn get seasonNumber => integer()();

  /// Display name (e.g., "リンカン編", "番外編").
  TextColumn get displayName => text()();

  /// Sort key for ordering seasons (typically max episodeNumber in season).
  IntColumn get sortKey => integer()();

  /// Resolver type that generated this season (e.g., "rss").
  TextColumn get resolverType => text()();

  @override
  Set<Column> get primaryKey => {podcastId, seasonNumber};
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_domain && dart test test/features/feed/models/seasons_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/seasons.dart packages/audiflow_domain/test/features/feed/models/seasons_test.dart
git commit -m "feat(domain): add Seasons Drift table with composite primary key"
```

---

## Task 2: Register Seasons Table in Database

**Files:**
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart`

**Step 1: Write the failing test**

Run existing database tests to establish baseline.

Run: `cd packages/audiflow_domain && dart test test/common/database/`
Expected: PASS (baseline)

**Step 2: Modify database to include Seasons**

```dart
// packages/audiflow_domain/lib/src/common/database/app_database.dart
// Add import at top:
import '../../features/feed/models/seasons.dart';

// Update @DriftDatabase annotation:
@DriftDatabase(tables: [Subscriptions, Episodes, PlaybackHistories, Seasons])
class AppDatabase extends _$AppDatabase {
  // ...

  @override
  int get schemaVersion => 5;  // Increment from 4 to 5

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // ... existing migrations ...
      // Migration from v4 to v5: add Seasons table
      if (5 <= to && from < 5) {
        await m.createTable(seasons);
      }
    },
  );
}
```

**Step 3: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates app_database.g.dart with Season data class

**Step 4: Run tests to verify**

Run: `cd packages/audiflow_domain && dart test`
Expected: PASS

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/common/database/app_database.dart packages/audiflow_domain/lib/src/common/database/app_database.g.dart packages/audiflow_domain/lib/src/features/feed/models/seasons.dart
git commit -m "feat(domain): register Seasons table in AppDatabase with migration v5"
```

---

## Task 3: Create EpisodeNumberExtractor

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/episode_number_extractor.dart`
- Test: `packages/audiflow_domain/test/features/feed/models/episode_number_extractor_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/models/episode_number_extractor_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EpisodeNumberExtractor', () {
    Episode makeEpisode({
      String title = 'Test',
      int? episodeNumber,
      int? seasonNumber,
    }) {
      return Episode(
        id: 1,
        podcastId: 1,
        guid: 'guid-1',
        title: title,
        audioUrl: 'https://example.com/1.mp3',
        episodeNumber: episodeNumber,
        seasonNumber: seasonNumber,
        publishedAt: DateTime(2024, 1, 1),
      );
    }

    test('creates from JSON config', () {
      final json = {
        'pattern': r'(\d+)】',
        'captureGroup': 1,
        'fallbackToRss': true,
      };

      final extractor = EpisodeNumberExtractor.fromJson(json);

      expect(extractor.pattern, r'(\d+)】');
      expect(extractor.captureGroup, 1);
      expect(extractor.fallbackToRss, isTrue);
    });

    test('extracts number from title using regex for positive seasonNumber', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final episode = makeEpisode(
        title: '【62-15】リンカン【COTEN RADIO リンカン編15】',
        seasonNumber: 62,
        episodeNumber: 100,
      );

      final result = extractor.extract(episode);
      expect(result, 15);
    });

    test('uses RSS episodeNumber for null/zero seasonNumber', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final episode = makeEpisode(
        title: '【番外編＃135】仏教のこと',
        seasonNumber: null,
        episodeNumber: 135,
      );

      final result = extractor.extract(episode);
      expect(result, 135);
    });

    test('uses RSS episodeNumber for seasonNumber zero', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final episode = makeEpisode(
        title: '【番外編＃135】仏教のこと',
        seasonNumber: 0,
        episodeNumber: 135,
      );

      final result = extractor.extract(episode);
      expect(result, 135);
    });

    test('falls back to RSS when pattern does not match', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final episode = makeEpisode(
        title: 'No pattern here',
        seasonNumber: 5,
        episodeNumber: 42,
      );

      final result = extractor.extract(episode);
      expect(result, 42);
    });

    test('returns null when no match and fallback disabled', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: false,
      );

      final episode = makeEpisode(
        title: 'No pattern here',
        seasonNumber: 5,
        episodeNumber: null,
      );

      final result = extractor.extract(episode);
      expect(result, isNull);
    });

    test('converts to JSON', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final json = extractor.toJson();

      expect(json['pattern'], r'(\d+)】');
      expect(json['captureGroup'], 1);
      expect(json['fallbackToRss'], true);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && dart test test/features/feed/models/episode_number_extractor_test.dart`
Expected: FAIL with import error

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/episode_number_extractor.dart
import '../../../common/database/app_database.dart';

/// Extracts episode-in-season number from episode data on-demand.
///
/// For episodes with positive seasonNumber, extracts from title using regex.
/// For episodes with null/zero seasonNumber (e.g., 番外編), uses RSS episodeNumber.
final class EpisodeNumberExtractor {
  const EpisodeNumberExtractor({
    required this.pattern,
    this.captureGroup = 1,
    this.fallbackToRss = true,
  });

  /// Creates an extractor from JSON configuration.
  factory EpisodeNumberExtractor.fromJson(Map<String, dynamic> json) {
    return EpisodeNumberExtractor(
      pattern: json['pattern'] as String,
      captureGroup: (json['captureGroup'] as int?) ?? 1,
      fallbackToRss: (json['fallbackToRss'] as bool?) ?? true,
    );
  }

  /// Regex pattern to extract episode number from title.
  final String pattern;

  /// Capture group index to use (default: 1).
  final int captureGroup;

  /// Whether to fall back to RSS episodeNumber when extraction fails.
  final bool fallbackToRss;

  /// Converts to JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'pattern': pattern,
      'captureGroup': captureGroup,
      'fallbackToRss': fallbackToRss,
    };
  }

  /// Extracts episode number from an episode.
  ///
  /// For positive seasonNumber: extracts from title using regex.
  /// For null/zero seasonNumber: uses RSS episodeNumber directly.
  int? extract(Episode episode) {
    // For null/zero seasonNumber (e.g., 番外編), use RSS episodeNumber directly
    final seasonNum = episode.seasonNumber;
    if (seasonNum == null || 1 > seasonNum) {
      return episode.episodeNumber;
    }

    // Try regex extraction from title
    final regex = RegExp(pattern);
    final match = regex.firstMatch(episode.title);

    if (match != null && captureGroup <= match.groupCount) {
      final captured = match.group(captureGroup);
      if (captured != null) {
        final parsed = int.tryParse(captured);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    // Fall back to RSS episodeNumber if enabled
    if (fallbackToRss) {
      return episode.episodeNumber;
    }

    return null;
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_domain && dart test test/features/feed/models/episode_number_extractor_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/episode_number_extractor.dart packages/audiflow_domain/test/features/feed/models/episode_number_extractor_test.dart
git commit -m "feat(domain): add EpisodeNumberExtractor for on-demand episode number extraction"
```

---

## Task 4: Update SeasonPattern with feedUrlPatterns and EpisodeNumberExtractor

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/season_pattern.dart`
- Modify: `packages/audiflow_domain/test/features/feed/models/season_pattern_test.dart`

**Step 1: Write the failing test**

```dart
// Add to packages/audiflow_domain/test/features/feed/models/season_pattern_test.dart

    test('SeasonPattern supports feedUrlPatterns list', () {
      final pattern = SeasonPattern(
        id: 'coten_radio',
        feedUrlPatterns: [
          r'https://anchor\.fm/s/8c2088c/podcast/rss',
          r'https://anchor\.fm/s/another/podcast/rss',
        ],
        resolverType: 'rss',
        config: {},
      );

      expect(pattern.feedUrlPatterns, hasLength(2));
    });

    test('matchesPodcast matches any pattern in feedUrlPatterns with anchoring', () {
      final pattern = SeasonPattern(
        id: 'coten_radio',
        feedUrlPatterns: [
          r'https://anchor\.fm/s/8c2088c/podcast/rss',
        ],
        resolverType: 'rss',
        config: {},
      );

      expect(
        pattern.matchesPodcast(null, 'https://anchor.fm/s/8c2088c/podcast/rss'),
        isTrue,
      );
      expect(
        pattern.matchesPodcast(null, 'https://other.com/https://anchor.fm/s/8c2088c/podcast/rss'),
        isFalse,
      );
    });

    test('SeasonPattern can have episodeNumberExtractor', () {
      final pattern = SeasonPattern(
        id: 'test',
        resolverType: 'rss',
        config: {},
        episodeNumberExtractor: EpisodeNumberExtractor(
          pattern: r'(\d+)】',
          captureGroup: 1,
        ),
      );

      expect(pattern.episodeNumberExtractor, isNotNull);
    });
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && dart test test/features/feed/models/season_pattern_test.dart`
Expected: FAIL (feedUrlPatterns not defined)

**Step 3: Update implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/season_pattern.dart
import 'episode_number_extractor.dart';
import 'season_sort.dart';
import 'season_title_extractor.dart';

/// Configuration for how to group episodes into seasons for a specific podcast.
final class SeasonPattern {
  const SeasonPattern({
    required this.id,
    this.podcastGuid,
    @Deprecated('Use feedUrlPatterns instead') this.feedUrlPattern,
    this.feedUrlPatterns,
    required this.resolverType,
    required this.config,
    this.priority = 0,
    this.customSort,
    this.titleExtractor,
    this.episodeNumberExtractor,
  });

  /// Unique identifier for this pattern.
  final String id;

  /// Match by podcast GUID (checked first).
  final String? podcastGuid;

  /// Match by feed URL regex pattern (fallback).
  /// @deprecated Use [feedUrlPatterns] instead.
  final String? feedUrlPattern;

  /// Match by any of these feed URL regex patterns (anchored with ^$).
  final List<String>? feedUrlPatterns;

  /// Which resolver type to use (e.g., "rss", "title_appearance").
  final String resolverType;

  /// Resolver-specific configuration.
  final Map<String, dynamic> config;

  /// Priority for pattern ordering (higher = checked first).
  final int priority;

  /// Custom default sort for seasons from this pattern.
  final SeasonSortSpec? customSort;

  /// Custom title extractor for generating season display names.
  ///
  /// When provided, overrides the default title generation logic.
  final SeasonTitleExtractor? titleExtractor;

  /// Extractor for episode-in-season numbers (on-demand).
  final EpisodeNumberExtractor? episodeNumberExtractor;

  /// Returns true if this pattern matches the given podcast.
  bool matchesPodcast(String? guid, String feedUrl) {
    // Match by GUID first
    if (podcastGuid != null && guid == podcastGuid) {
      return true;
    }

    // Try feedUrlPatterns (anchored matching)
    if (feedUrlPatterns != null) {
      for (final pattern in feedUrlPatterns!) {
        final regex = RegExp('^$pattern\$');
        if (regex.hasMatch(feedUrl)) {
          return true;
        }
      }
    }

    // Fall back to legacy feedUrlPattern (unanchored for backwards compat)
    // ignore: deprecated_member_use_from_same_package
    if (feedUrlPattern != null) {
      // ignore: deprecated_member_use_from_same_package
      final regex = RegExp(feedUrlPattern!);
      if (regex.hasMatch(feedUrl)) {
        return true;
      }
    }

    return false;
  }
}
```

**Step 4: Update test imports and run**

```dart
// Add import at top of test file:
import 'package:audiflow_domain/src/features/feed/models/episode_number_extractor.dart';
```

Run: `cd packages/audiflow_domain && dart test test/features/feed/models/season_pattern_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/season_pattern.dart packages/audiflow_domain/test/features/feed/models/season_pattern_test.dart
git commit -m "feat(domain): add feedUrlPatterns and episodeNumberExtractor to SeasonPattern"
```

---

## Task 5: Update RssMetadataResolver with groupNullSeasonAs Config

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/rss_metadata_resolver.dart`
- Create: `packages/audiflow_domain/test/features/feed/resolvers/rss_metadata_resolver_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/resolvers/rss_metadata_resolver_test.dart
import 'dart:math';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RssMetadataResolver', () {
    Episode makeEpisode({
      required int id,
      required String title,
      int? seasonNumber,
      int? episodeNumber,
    }) {
      return Episode(
        id: id,
        podcastId: 1,
        guid: 'guid-$id',
        title: title,
        audioUrl: 'https://example.com/$id.mp3',
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        publishedAt: DateTime(2024, 1, 1),
      );
    }

    test('groups episodes by seasonNumber', () {
      final resolver = RssMetadataResolver();
      final episodes = [
        makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1, episodeNumber: 1),
        makeEpisode(id: 2, title: 'Ep2', seasonNumber: 1, episodeNumber: 2),
        makeEpisode(id: 3, title: 'Ep3', seasonNumber: 2, episodeNumber: 1),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons, hasLength(2));
      expect(result.seasons[0].episodeIds, [1, 2]);
      expect(result.seasons[1].episodeIds, [3]);
    });

    test('treats null seasonNumber as ungrouped by default', () {
      final resolver = RssMetadataResolver();
      final episodes = [
        makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1, episodeNumber: 1),
        makeEpisode(id: 2, title: 'Ep2', seasonNumber: null, episodeNumber: 100),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons, hasLength(1));
      expect(result.ungroupedEpisodeIds, [2]);
    });

    test('groups null/zero seasonNumber when groupNullSeasonAs is configured', () {
      final resolver = RssMetadataResolver();
      final pattern = SeasonPattern(
        id: 'test',
        resolverType: 'rss',
        config: {'groupNullSeasonAs': 0},
      );
      final episodes = [
        makeEpisode(id: 1, title: 'Ep1', seasonNumber: 62, episodeNumber: 1),
        makeEpisode(id: 2, title: 'Bangai1', seasonNumber: null, episodeNumber: 100),
        makeEpisode(id: 3, title: 'Bangai2', seasonNumber: 0, episodeNumber: 101),
      ];

      final result = resolver.resolve(episodes, pattern);

      expect(result, isNotNull);
      expect(result!.seasons, hasLength(2));
      expect(result.ungroupedEpisodeIds, isEmpty);

      final season0 = result.seasons.firstWhere((s) => s.id == 'season_0');
      expect(season0.episodeIds, containsAll([2, 3]));
    });

    test('calculates sortKey from max episodeNumber in season', () {
      final resolver = RssMetadataResolver();
      final episodes = [
        makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1, episodeNumber: 5),
        makeEpisode(id: 2, title: 'Ep2', seasonNumber: 1, episodeNumber: 10),
        makeEpisode(id: 3, title: 'Ep3', seasonNumber: 2, episodeNumber: 3),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      final season1 = result!.seasons.firstWhere((s) => s.id == 'season_1');
      final season2 = result.seasons.firstWhere((s) => s.id == 'season_2');

      expect(season1.sortKey, 10); // max of 5, 10
      expect(season2.sortKey, 3);
    });
  });
}
```

**Step 2: Run test to verify baseline failures**

Run: `cd packages/audiflow_domain && dart test test/features/feed/resolvers/rss_metadata_resolver_test.dart`
Expected: FAIL (groupNullSeasonAs not implemented, sortKey uses seasonNumber not episodeNumber)

**Step 3: Update implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/resolvers/rss_metadata_resolver.dart
import 'dart:math';

import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';
import '../models/season_title_extractor.dart';
import 'season_resolver.dart';

/// Resolver that groups episodes using RSS metadata (seasonNumber field).
class RssMetadataResolver implements SeasonResolver {
  @override
  String get type => 'rss';

  @override
  SeasonSortSpec get defaultSort =>
      const SimpleSeasonSort(SeasonSortField.seasonNumber, SortOrder.ascending);

  @override
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern) {
    final grouped = <int, List<Episode>>{};
    final ungrouped = <int>[];

    // Check for groupNullSeasonAs config
    final groupNullAs = pattern?.config['groupNullSeasonAs'] as int?;

    for (final episode in episodes) {
      final seasonNum = episode.seasonNumber;

      if (seasonNum != null && 1 <= seasonNum) {
        // Positive season number - group normally
        grouped.putIfAbsent(seasonNum, () => []).add(episode);
      } else if (groupNullAs != null) {
        // Null/zero season number with groupNullSeasonAs config
        grouped.putIfAbsent(groupNullAs, () => []).add(episode);
      } else {
        // No config for grouping - mark as ungrouped
        ungrouped.add(episode.id);
      }
    }

    // Return null if no episodes have season numbers
    if (grouped.isEmpty) {
      return null;
    }

    final titleExtractor = pattern?.titleExtractor;

    final seasons = grouped.entries.map((entry) {
      final seasonEpisodes = entry.value;
      final displayName = _extractDisplayName(
        seasonNumber: entry.key,
        episodes: seasonEpisodes,
        titleExtractor: titleExtractor,
      );

      // Calculate sortKey from max episodeNumber
      final sortKey = _calculateSortKey(seasonEpisodes);

      return Season(
        id: 'season_${entry.key}',
        displayName: displayName,
        sortKey: sortKey,
        episodeIds: seasonEpisodes.map((e) => e.id).toList(),
      );
    }).toList()..sort((a, b) => a.sortKey.compareTo(b.sortKey));

    return SeasonGrouping(
      seasons: seasons,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  String _extractDisplayName({
    required int seasonNumber,
    required List<Episode> episodes,
    required SeasonTitleExtractor? titleExtractor,
  }) {
    if (titleExtractor == null || episodes.isEmpty) {
      return 'Season $seasonNumber';
    }

    // Try to extract title from first episode
    final extracted = titleExtractor.extract(episodes.first);
    return extracted ?? 'Season $seasonNumber';
  }

  int _calculateSortKey(List<Episode> episodes) {
    if (episodes.isEmpty) return 0;

    return episodes
        .map((e) => e.episodeNumber ?? 0)
        .reduce(max);
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_domain && dart test test/features/feed/resolvers/rss_metadata_resolver_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/resolvers/rss_metadata_resolver.dart packages/audiflow_domain/test/features/feed/resolvers/rss_metadata_resolver_test.dart
git commit -m "feat(domain): add groupNullSeasonAs config and sortKey by max episodeNumber"
```

---

## Task 6: Update SeasonTitleExtractor for 番外編 Fallback

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/season_title_extractor.dart`
- Modify: `packages/audiflow_domain/test/features/feed/models/season_title_extractor_test.dart`

**Step 1: Write the failing test**

```dart
// Add to packages/audiflow_domain/test/features/feed/models/season_title_extractor_test.dart

    test('uses fallback string for null/zero seasonNumber', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'【COTEN RADIO (ショート)?\s*(.+?)\s+\d+】',
        group: 2,
        fallbackValue: '番外編',
      );

      final episode = makeEpisode(
        title: '【番外編＃135】仏教のこと',
        seasonNumber: null,
      );
      final result = extractor.extract(episode);

      expect(result, '番外編');
    });

    test('uses fallback string for seasonNumber zero', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'【COTEN RADIO (ショート)?\s*(.+?)\s+\d+】',
        group: 2,
        fallbackValue: '番外編',
      );

      final episode = makeEpisode(
        title: '【番外編＃135】仏教のこと',
        seasonNumber: 0,
      );
      final result = extractor.extract(episode);

      expect(result, '番外編');
    });

    test('extracts COTEN RADIO season title from regular episode', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'【COTEN RADIO (ショート)?\s*(.+?)\s+\d+】',
        group: 2,
        fallbackValue: '番外編',
      );

      final episode = makeEpisode(
        title: '【62-15】何が変わった？【COTEN RADIO リンカン編15】',
        seasonNumber: 62,
      );
      final result = extractor.extract(episode);

      expect(result, 'リンカン編');
    });

    test('extracts COTEN RADIO short season title', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'【COTEN RADIO (ショート)?\s*(.+?)\s+\d+】',
        group: 2,
        fallbackValue: '番外編',
      );

      final episode = makeEpisode(
        title: '【1-1】概要【COTEN RADIO ショート 織田信長編1】',
        seasonNumber: 1,
      );
      final result = extractor.extract(episode);

      expect(result, '織田信長編');
    });
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && dart test test/features/feed/models/season_title_extractor_test.dart`
Expected: FAIL (fallbackValue not implemented)

**Step 3: Update implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/season_title_extractor.dart
// Add fallbackValue field and logic

import '../../../common/database/app_database.dart';

/// Configuration for extracting season display names from episode data.
final class SeasonTitleExtractor {
  const SeasonTitleExtractor({
    required this.source,
    this.pattern,
    this.group = 0,
    this.template,
    this.fallback,
    this.fallbackValue,
  });

  /// Creates an extractor from JSON configuration.
  factory SeasonTitleExtractor.fromJson(Map<String, dynamic> json) {
    return SeasonTitleExtractor(
      source: json['source'] as String,
      pattern: json['pattern'] as String?,
      group: (json['group'] as int?) ?? 0,
      template: json['template'] as String?,
      fallback: json['fallback'] != null
          ? SeasonTitleExtractor.fromJson(
              json['fallback'] as Map<String, dynamic>,
            )
          : null,
      fallbackValue: json['fallbackValue'] as String?,
    );
  }

  /// Episode field to extract from.
  final String source;

  /// Regex pattern to extract value (optional).
  final String? pattern;

  /// Capture group to use from regex match (default: 0 = full match).
  final int group;

  /// Template for formatting the extracted value.
  final String? template;

  /// Fallback extractor to use when this one fails.
  final SeasonTitleExtractor? fallback;

  /// Fallback string value for null/zero seasonNumber episodes.
  final String? fallbackValue;

  /// Converts to JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'source': source,
      if (pattern != null) 'pattern': pattern,
      if (group != 0) 'group': group,
      if (template != null) 'template': template,
      if (fallback != null) 'fallback': fallback!.toJson(),
      if (fallbackValue != null) 'fallbackValue': fallbackValue,
    };
  }

  /// Extracts the season title from an episode.
  String? extract(Episode episode) {
    // For null/zero seasonNumber, use fallbackValue if available
    final seasonNum = episode.seasonNumber;
    if (fallbackValue != null && (seasonNum == null || 1 > seasonNum)) {
      return fallbackValue;
    }

    final sourceValue = _getSourceValue(episode);

    if (sourceValue == null) {
      return fallback?.extract(episode);
    }

    String? result;

    if (pattern != null) {
      result = _extractWithPattern(sourceValue);
    } else {
      result = sourceValue;
    }

    if (result == null) {
      return fallback?.extract(episode);
    }

    if (template != null) {
      result = template!.replaceAll('{value}', result);
    }

    return result;
  }

  String? _getSourceValue(Episode episode) {
    return switch (source) {
      'title' => episode.title,
      'description' => episode.description,
      'seasonNumber' => episode.seasonNumber?.toString(),
      'episodeNumber' => episode.episodeNumber?.toString(),
      _ => null,
    };
  }

  String? _extractWithPattern(String value) {
    final regex = RegExp(pattern!);
    final match = regex.firstMatch(value);

    if (match == null) {
      return null;
    }

    if (group == 0) {
      return match.group(0);
    }

    if (match.groupCount < group) {
      return null;
    }

    return match.group(group);
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_domain && dart test test/features/feed/models/season_title_extractor_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/season_title_extractor.dart packages/audiflow_domain/test/features/feed/models/season_title_extractor_test.dart
git commit -m "feat(domain): add fallbackValue to SeasonTitleExtractor for 番外編 support"
```

---

## Task 7: Export New Types from audiflow_domain

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

**Step 1: Add exports**

```dart
// Add to packages/audiflow_domain/lib/audiflow_domain.dart in Feed feature section:
export 'src/features/feed/models/episode_number_extractor.dart';
export 'src/features/feed/models/seasons.dart';
```

**Step 2: Run analysis**

Run: `cd packages/audiflow_domain && dart analyze`
Expected: No issues

**Step 3: Run all tests**

Run: `cd packages/audiflow_domain && dart test`
Expected: PASS

**Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "chore(domain): export EpisodeNumberExtractor and Seasons table"
```

---

## Task 8: Create COTEN RADIO Pattern Configuration

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/patterns/coten_radio_pattern.dart`
- Test: `packages/audiflow_domain/test/features/feed/patterns/coten_radio_pattern_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/patterns/coten_radio_pattern_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_domain/src/features/feed/patterns/coten_radio_pattern.dart';

void main() {
  group('cotenRadioPattern', () {
    test('matches COTEN RADIO feed URL', () {
      expect(
        cotenRadioPattern.matchesPodcast(
          null,
          'https://anchor.fm/s/8c2088c/podcast/rss',
        ),
        isTrue,
      );
    });

    test('does not match other feed URLs', () {
      expect(
        cotenRadioPattern.matchesPodcast(
          null,
          'https://feeds.example.com/podcast/rss',
        ),
        isFalse,
      );
    });

    test('has correct resolver type', () {
      expect(cotenRadioPattern.resolverType, 'rss');
    });

    test('has groupNullSeasonAs config', () {
      expect(cotenRadioPattern.config['groupNullSeasonAs'], 0);
    });

    test('titleExtractor extracts season name from regular episode', () {
      final episode = Episode(
        id: 1,
        podcastId: 1,
        guid: 'guid-1',
        title: '【62-15】何が変わった？【COTEN RADIO リンカン編15】',
        audioUrl: 'https://example.com/1.mp3',
        seasonNumber: 62,
        publishedAt: DateTime(2024, 1, 1),
      );

      final result = cotenRadioPattern.titleExtractor!.extract(episode);
      expect(result, 'リンカン編');
    });

    test('titleExtractor returns 番外編 for null seasonNumber', () {
      final episode = Episode(
        id: 1,
        podcastId: 1,
        guid: 'guid-1',
        title: '【番外編＃135】仏教のこと',
        audioUrl: 'https://example.com/1.mp3',
        seasonNumber: null,
        publishedAt: DateTime(2024, 1, 1),
      );

      final result = cotenRadioPattern.titleExtractor!.extract(episode);
      expect(result, '番外編');
    });

    test('episodeNumberExtractor extracts from regular episode title', () {
      final episode = Episode(
        id: 1,
        podcastId: 1,
        guid: 'guid-1',
        title: '【62-15】何が変わった？【COTEN RADIO リンカン編15】',
        audioUrl: 'https://example.com/1.mp3',
        seasonNumber: 62,
        episodeNumber: 100,
        publishedAt: DateTime(2024, 1, 1),
      );

      final result = cotenRadioPattern.episodeNumberExtractor!.extract(episode);
      expect(result, 15);
    });

    test('episodeNumberExtractor uses RSS episodeNumber for 番外編', () {
      final episode = Episode(
        id: 1,
        podcastId: 1,
        guid: 'guid-1',
        title: '【番外編＃135】仏教のこと',
        audioUrl: 'https://example.com/1.mp3',
        seasonNumber: null,
        episodeNumber: 135,
        publishedAt: DateTime(2024, 1, 1),
      );

      final result = cotenRadioPattern.episodeNumberExtractor!.extract(episode);
      expect(result, 135);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && dart test test/features/feed/patterns/coten_radio_pattern_test.dart`
Expected: FAIL with import error

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/patterns/coten_radio_pattern.dart
import '../models/episode_number_extractor.dart';
import '../models/season_pattern.dart';
import '../models/season_title_extractor.dart';

/// Pre-configured SeasonPattern for COTEN RADIO podcast.
///
/// Handles:
/// - Regular seasons: `【COTEN RADIO リンカン編15】` → season title "リンカン編"
/// - 番外編 (extras): `【番外編＃135】` → season title "番外編"
const SeasonPattern cotenRadioPattern = SeasonPattern(
  id: 'coten_radio',
  feedUrlPatterns: [
    r'https://anchor\.fm/s/8c2088c/podcast/rss',
  ],
  resolverType: 'rss',
  config: {
    'groupNullSeasonAs': 0,
  },
  titleExtractor: SeasonTitleExtractor(
    source: 'title',
    pattern: r'【COTEN RADIO (ショート)?\s*(.+?)\s+\d+】',
    group: 2,
    fallbackValue: '番外編',
  ),
  episodeNumberExtractor: EpisodeNumberExtractor(
    pattern: r'(\d+)】',
    captureGroup: 1,
    fallbackToRss: true,
  ),
);
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_domain && dart test test/features/feed/patterns/coten_radio_pattern_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/patterns/coten_radio_pattern.dart packages/audiflow_domain/test/features/feed/patterns/coten_radio_pattern_test.dart
git commit -m "feat(domain): add COTEN RADIO season pattern configuration"
```

---

## Task 9: Run Full Test Suite and Format

**Step 1: Run dart format**

Run: `cd packages/audiflow_domain && dart format lib test`

**Step 2: Run dart fix**

Run: `cd packages/audiflow_domain && dart fix --apply`

**Step 3: Run analyzer**

Run: `cd packages/audiflow_domain && dart analyze`
Expected: No issues

**Step 4: Run all tests**

Run: `cd packages/audiflow_domain && dart test`
Expected: All PASS

**Step 5: Final commit**

```bash
git add -A
git commit -m "chore(domain): format and fix lints"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Create Seasons Drift table | `seasons.dart`, test |
| 2 | Register table in AppDatabase | `app_database.dart` |
| 3 | Create EpisodeNumberExtractor | `episode_number_extractor.dart`, test |
| 4 | Update SeasonPattern | `season_pattern.dart`, test |
| 5 | Update RssMetadataResolver | `rss_metadata_resolver.dart`, test |
| 6 | Update SeasonTitleExtractor | `season_title_extractor.dart`, test |
| 7 | Export new types | `audiflow_domain.dart` |
| 8 | Create COTEN RADIO pattern | `coten_radio_pattern.dart`, test |
| 9 | Format and verify | All files |
