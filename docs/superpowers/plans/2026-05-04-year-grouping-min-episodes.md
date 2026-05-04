# Year Grouping Minimum Episodes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Suppress the auto-detect year-grouped smart-playlist tab when a podcast has fewer than 30 total episodes.

**Architecture:** Gate at the resolver layer. `YearResolver.resolve` returns `null` when there is no explicit `SmartPlaylistDefinition` and the episode list is below a constant threshold defined in `audiflow_core`. Bump `YearResolver.heuristicVersion` so previously-cached auto-detect groupings are invalidated by the existing cache-purge path in `podcastSmartPlaylists`.

**Tech Stack:** Flutter / Dart 3.9, Isar, Riverpod 3, `flutter_test`, Melos workspace.

---

## Spec

`docs/superpowers/specs/2026-05-04-year-grouping-min-episodes-design.md`

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `packages/audiflow_core/lib/src/constants/app_constants.dart` | Modify | Expose `AppConstants.autoYearGroupingMinEpisodes`. |
| `packages/audiflow_domain/lib/src/features/feed/resolvers/year_resolver.dart` | Modify | Threshold guard at top of `resolve`; bump `heuristicVersion` from `1` to `2`. |
| `packages/audiflow_domain/test/features/feed/resolvers/year_resolver_test.dart` | Modify | New cases: below threshold returns null, at threshold returns grouping, definition non-null bypasses threshold, heuristicVersion is 2. |
| `packages/audiflow_domain/test/features/feed/services/smart_playlist_resolver_service_test.dart` | Modify | Adjust two auto-detect Year fallback cases that use < 30 episode fixtures so the resolver still returns. |

## Pre-flight

Verify the working branch is `feat/year-grouping-min-episodes` (created during brainstorming). If not, create and switch:

```bash
git rev-parse --abbrev-ref HEAD
# expected: feat/year-grouping-min-episodes
```

---

### Task 1: Expose threshold constant

**Files:**
- Modify: `packages/audiflow_core/lib/src/constants/app_constants.dart`

- [ ] **Step 1: Add constant**

Replace the file contents with:

```dart
/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// Application name
  static const String appName = 'Audiflow';

  /// API timeout duration
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Minimum splash screen display time
  static const Duration minSplashDuration = Duration(seconds: 1);

  /// Minimum total episode count required to expose the auto-detect
  /// year-grouping smart-playlist tab. Below this threshold the year
  /// fallback is suppressed so the smart-playlist toggle stays hidden
  /// for small feeds.
  ///
  /// Only applies to the auto-detect path (no curated config). Explicit
  /// `year` definitions in pattern configs bypass this threshold.
  static const int autoYearGroupingMinEpisodes = 30;
}
```

- [ ] **Step 2: Run audiflow_core tests**

Run: `cd packages/audiflow_core && flutter test`
Expected: PASS (no behavioral change yet).

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_core/lib/src/constants/app_constants.dart
git commit -m "feat(core): expose autoYearGroupingMinEpisodes constant"
```

---

### Task 2: Failing test for below-threshold suppression

**Files:**
- Modify: `packages/audiflow_domain/test/features/feed/resolvers/year_resolver_test.dart`

- [ ] **Step 1: Add helper and below-threshold test**

Open the file and add the following test inside the existing `group('YearResolver', ...)` block, after the existing `'episodes without publishedAt go to ungrouped'` test:

```dart
    test(
      'returns null on auto-detect when episode count is below threshold',
      () {
        final episodes = List.generate(
          29,
          (i) => _makeEpisode(i + 1, publishedAt: DateTime(2024, 1, i + 1)),
        );

        final result = resolver.resolve(episodes, null);

        expect(result, isNull);
      },
    );

    test(
      'returns grouping on auto-detect when episode count meets threshold',
      () {
        final episodes = List.generate(
          30,
          (i) => _makeEpisode(i + 1, publishedAt: DateTime(2024, 1, i + 1)),
        );

        final result = resolver.resolve(episodes, null);

        expect(result, isNotNull);
        expect(result!.playlists, hasLength(1));
        expect(result.playlists.first.displayName, '2024');
      },
    );

    test(
      'explicit definition bypasses threshold for small feeds',
      () {
        final episodes = List.generate(
          5,
          (i) => _makeEpisode(i + 1, publishedAt: DateTime(2024, 1, i + 1)),
        );

        final definition = const SmartPlaylistDefinition(
          id: 'years',
          displayName: 'Years',
          grouping: GroupingConfig(by: 'year'),
          priority: 0,
        );

        final result = resolver.resolve(episodes, definition);

        expect(result, isNotNull);
        expect(result!.playlists, hasLength(1));
      },
    );

    test('heuristicVersion is bumped to 2', () {
      expect(resolver.heuristicVersion, 2);
    });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/resolvers/year_resolver_test.dart`
Expected: 4 failures.
- below-threshold: FAIL because `result` is non-null (current behavior groups even 29 episodes).
- meets-threshold: PASS (incidental — current behavior already groups). Acceptable; this test will keep passing under the new code too.
- explicit-definition: PASS (incidental). Acceptable.
- heuristicVersion: FAIL — currently `1`, expected `2`.

If only 2 of 4 fail (the two listed as FAIL), proceed. The two passing tests are intentional regression guards.

---

### Task 3: Implement threshold guard and bump heuristicVersion

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/resolvers/year_resolver.dart`

- [ ] **Step 1: Add import and threshold guard**

Replace the file contents with:

```dart
import 'package:audiflow_core/audiflow_core.dart' show AppConstants;

import '../models/episode.dart';
import '../extensions/episode_extensions.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_definition.dart';
import '../models/smart_playlist_sort.dart';
import '../models/smart_playlist_title_extractor.dart';
import 'smart_playlist_resolver.dart';

/// Resolver that groups episodes by publication year.
class YearResolver implements SmartPlaylistResolver {
  @override
  String get type => 'year';

  /// Bumped to 2 when the auto-detect minimum-episode threshold was
  /// added. The bump invalidates cached auto-detect groupings so feeds
  /// previously below the threshold drop their cached year tab.
  @override
  int get heuristicVersion => 2;

  @override
  SmartPlaylistSortRule get defaultSort => const SmartPlaylistSortRule(
    field: SmartPlaylistSortField.playlistNumber,
    order: SortOrder.descending, // Newest years first
  );

  @override
  SmartPlaylistGrouping? resolve(
    List<Episode> episodes,
    SmartPlaylistDefinition? definition,
  ) {
    // Auto-detect path: skip year grouping for small feeds. Explicit
    // year configs (definition != null) bypass the threshold so curated
    // patterns can group small podcasts.
    if (definition == null &&
        episodes.length < AppConstants.autoYearGroupingMinEpisodes) {
      return null;
    }

    final grouped = <int, List<Episode>>{};
    final ungrouped = <int>[];

    for (final episode in episodes) {
      final pubDate = episode.publishedAt;
      if (pubDate != null) {
        grouped.putIfAbsent(pubDate.year, () => []).add(episode);
      } else {
        ungrouped.add(episode.id);
      }
    }

    // Return null if no episodes have publish dates
    if (grouped.isEmpty) {
      return null;
    }

    final titleExtractor = definition?.groupItem?.titleExtractor;

    final playlists = grouped.entries.map((entry) {
      final playlistEpisodes = entry.value;
      final displayName = _extractDisplayName(
        year: entry.key,
        episodes: playlistEpisodes,
        titleExtractor: titleExtractor,
      );

      return SmartPlaylist(
        id: 'year_${entry.key}',
        displayName: displayName,
        sortKey: entry.key,
        episodeIds: playlistEpisodes.map((e) => e.id).toList(),
      );
    }).toList()..sort((a, b) => b.sortKey.compareTo(a.sortKey)); // Descending

    return SmartPlaylistGrouping(
      playlists: playlists,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  String _extractDisplayName({
    required int year,
    required List<Episode> episodes,
    required SmartPlaylistTitleExtractor? titleExtractor,
  }) {
    if (titleExtractor == null || episodes.isEmpty) {
      return '$year';
    }

    // Try to extract title from first episode
    final extracted = titleExtractor.extract(episodes.first.toEpisodeData());
    return extracted ?? '$year';
  }
}
```

- [ ] **Step 2: Run year_resolver tests**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/resolvers/year_resolver_test.dart`
Expected: all tests in this file PASS.

If a pre-existing test (`returns null when no episodes have publish dates`) now fails because the 2-episode fixture trips the threshold first instead of the publishedAt-empty branch, update that test to use 30 episodes without publish dates:

```dart
    test('returns null when no episodes have publish dates', () {
      final episodes = List.generate(30, (i) => _makeEpisode(i + 1));

      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });
```

Re-run the file. Expected: all PASS.

Same applies to `'groups episodes by publish year'` and `'episodes without publishedAt go to ungrouped'` if they fall below 30 episodes. Expand each fixture to at least 30 episodes preserving the assertions:

```dart
    test('groups episodes by publish year', () {
      final episodes = [
        for (var i = 0; i < 15; i++)
          _makeEpisode(i + 1, publishedAt: DateTime(2023, 3, (i % 28) + 1)),
        for (var i = 0; i < 15; i++)
          _makeEpisode(
            i + 16,
            publishedAt: DateTime(2024, 1, (i % 28) + 1),
          ),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.playlists.length, 2);
      expect(result.playlists[0].displayName, '2024');
      expect(
        result.playlists[0].episodeIds,
        List.generate(15, (i) => i + 16),
      );
      expect(result.playlists[1].displayName, '2023');
      expect(
        result.playlists[1].episodeIds,
        List.generate(15, (i) => i + 1),
      );
    });

    test('episodes without publishedAt go to ungrouped', () {
      final dated = List.generate(
        29,
        (i) => _makeEpisode(i + 1, publishedAt: DateTime(2024, 1, (i % 28) + 1)),
      );
      final undated = _makeEpisode(30); // No date

      final result = resolver.resolve([...dated, undated], null);

      expect(result, isNotNull);
      expect(result!.ungroupedEpisodeIds, [30]);
    });
```

Re-run. Expected: all PASS.

- [ ] **Step 3: Commit**

```bash
git add \
  packages/audiflow_domain/lib/src/features/feed/resolvers/year_resolver.dart \
  packages/audiflow_domain/test/features/feed/resolvers/year_resolver_test.dart
git commit -m "feat(domain): suppress auto year grouping for small podcasts"
```

---

### Task 4: Adjust resolver service tests that exercised the small-feed Year fallback

**Files:**
- Modify: `packages/audiflow_domain/test/features/feed/services/smart_playlist_resolver_service_test.dart`

Two existing tests assume `YearResolver` succeeds in auto-detect mode with only 2 fixture episodes. Both must be expanded so the threshold does not suppress the fallback.

- [ ] **Step 1: Run the suite to confirm failures before editing**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/services/smart_playlist_resolver_service_test.dart`
Expected:
- `'falls through SeasonNumberResolver when metadata is unreliable'` FAILS — `result` is now `null`.
- `'falls back to next resolver when first fails'` FAILS — `result` is now `null`.
- All other tests PASS.

If the failure list differs, stop and re-read the file before editing.

- [ ] **Step 2: Expand fixtures in the two failing tests**

Replace the body of `'falls through SeasonNumberResolver when metadata is unreliable'` with:

```dart
    test('falls through SeasonNumberResolver when metadata is unreliable', () {
      // All S1 -> SeasonNumberResolver treats as non-seasonal in auto-detect,
      // so YearResolver takes over. Use enough episodes to clear the
      // YearResolver auto-detect threshold.
      final episodes = [
        for (var i = 0; i < 15; i++)
          _makeEpisode(
            i + 1,
            seasonNumber: 1,
            publishedAt: DateTime(2023, 1, (i % 28) + 1),
          ),
        for (var i = 0; i < 15; i++)
          _makeEpisode(
            i + 16,
            seasonNumber: 1,
            publishedAt: DateTime(2024, 1, (i % 28) + 1),
          ),
      ];

      final result = service.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      expect(result!.resolverType, 'year');
    });
```

Replace the body of `'falls back to next resolver when first fails'` with:

```dart
    test('falls back to next resolver when first fails', () {
      final episodes = [
        for (var i = 0; i < 15; i++)
          _makeEpisode(
            i + 1,
            publishedAt: DateTime(2023, 6, (i % 28) + 1),
          ),
        for (var i = 0; i < 15; i++)
          _makeEpisode(
            i + 16,
            publishedAt: DateTime(2024, 3, (i % 28) + 1),
          ),
      ];

      final result = service.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      expect(result!.resolverType, 'year');
    });
```

- [ ] **Step 3: Run the resolver service suite**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/services/smart_playlist_resolver_service_test.dart`
Expected: all PASS.

- [ ] **Step 4: Run the full domain test suite**

Run: `cd packages/audiflow_domain && flutter test`
Expected: all PASS. If any other test relies on auto-detect Year fallback with < 30 episodes, expand its fixture using the same pattern as Step 2.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/test/features/feed/services/smart_playlist_resolver_service_test.dart
git commit -m "test(domain): expand Year fallback fixtures past min-episode threshold"
```

---

### Task 5: Final validation

- [ ] **Step 1: Static analysis**

Run: `flutter analyze`
Expected: zero issues.

- [ ] **Step 2: Full test sweep across affected packages**

Run:

```bash
cd packages/audiflow_core && flutter test
cd ../audiflow_domain && flutter test
cd ../..
```

Expected: all PASS.

- [ ] **Step 3: Confirm branch is clean**

Run: `git status`
Expected: working tree clean, branch ahead of `main` by 4 commits (spec + Task 1 + Task 3 + Task 4).

---

## Out-of-scope follow-ups

- No UI changes. The smart-playlist toggle relies on the existing
  `hasSmartPlaylistView` provider, which already returns `false` when
  `podcastSmartPlaylists` returns `null`.
- No log-line additions; existing `'Smart playlist resolution result: 0
  playlists, ...'` already covers the suppressed case.
