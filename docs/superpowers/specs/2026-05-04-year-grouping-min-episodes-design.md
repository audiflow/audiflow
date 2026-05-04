# Suppress Auto Year Grouping for Small Podcasts

Date: 2026-05-04
Branch: `feat/year-grouping-min-episodes`

## Summary

Hide the smart-playlist toggle when the only available auto-detect grouping
is `YearResolver` and the podcast has fewer than 30 episodes. The year tab
adds little value for small feeds and clutters the detail screen.

## Problem

`SmartPlaylistResolverService` runs auto-detect resolvers in priority
order: `SeasonNumberResolver -> TitleClassifierResolver ->
TitleDiscoveryResolver -> YearResolver`.

When no curated smart-playlist config exists for a podcast and season /
title-based heuristics fail, `YearResolver` groups episodes by publish
year. The Episodes / Smart-Playlist toggle on `PodcastDetailScreen` then
exposes the year-grouped view as a separate tab.

For podcasts with very few episodes, the year tab adds minimal value: a
handful of single-episode "year" entries duplicate the episodes list. We
want to suppress that fallback below a small-feed threshold.

## Goals

- Hide the year-grouped tab when total episode count is below a
  configurable threshold and the resolution path is auto-detect Year.
- Keep all other resolver behavior unchanged.
- Avoid polluting the smart-playlist cache with sub-threshold groupings.
- Invalidate existing caches automatically so previously-resolved year
  groupings disappear after upgrade.

## Non-goals

- Suppressing season / title-classifier / title-discovery fallbacks.
- Affecting podcasts with an explicit `YearResolver` config (curated
  patterns whose `definition` selects `year` grouping).
- Filter / search-aware suppression (decision: total feed episode count).
- Runtime-configurable threshold (decision: compile-time constant).

## Decisions

- **Scope**: `YearResolver` only. Other auto-detect resolvers are
  untouched.
- **Counting basis**: total feed episode count
  (`episodes.length` passed into the resolver). Not the count of episodes
  assigned to year groups, not filter-applied count.
- **Threshold**: 30 episodes. Hard constant exposed from `audiflow_core`
  for testability and future tuning.
- **Application point**: resolver level. `YearResolver.resolve` returns
  `null` when below threshold and no explicit definition is present.
- **Cache invalidation**: bump `YearResolver.heuristicVersion` so
  `autoDetectHeuristicVersion` changes, triggering the existing stale-
  cache purge in `podcastSmartPlaylists`.
- **Explicit configs**: when `definition != null`, threshold does not
  apply. Curators can author small-feed Year groupings if desired.

## Architecture

Three files change.

### 1. `packages/audiflow_core/lib/src/constants/app_constants.dart`

Add a public constant:

```dart
class AppConstants {
  AppConstants._();

  // ...existing fields...

  /// Minimum total episode count required to show the auto-detect
  /// year-grouping tab. Below this threshold the year fallback is
  /// suppressed and the smart-playlist toggle is hidden.
  static const int autoYearGroupingMinEpisodes = 30;
}
```

The value re-exports through the existing `audiflow_core.dart` barrel.

### 2. `packages/audiflow_domain/lib/src/features/feed/resolvers/year_resolver.dart`

Add an early return at the top of `resolve` and bump
`heuristicVersion`:

```dart
import 'package:audiflow_core/audiflow_core.dart' show AppConstants;

class YearResolver implements SmartPlaylistResolver {
  @override
  String get type => 'year';

  @override
  int get heuristicVersion => 2; // was 1

  // ...

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

    // ...existing implementation unchanged...
  }
}
```

### 3. Tests
`packages/audiflow_domain/test/features/feed/resolvers/year_resolver_test.dart`

Add cases:

- 29 auto-detect episodes -> `null`.
- 30 auto-detect episodes -> grouping returned.
- 5 episodes with non-null `definition` -> grouping returned (threshold
  bypassed).
- `heuristicVersion == 2`.

Audit `packages/audiflow_domain/test/features/feed/services/smart_playlist_resolver_service_test.dart`
for cases that intentionally exercise the auto-detect Year fallback with
small fixture sets and adjust fixtures to >= 30 episodes (or pass an
explicit `definition` if testing curator behavior).

## Data Flow

```
podcastSmartPlaylists(podcastId)
  -- no usable cache --
  _resolveAndPersistSmartPlaylists
    SmartPlaylistResolverService.resolveSmartPlaylists
      Season -> TitleClassifier -> TitleDiscovery -> Year
                                                       |
                                  episodes.length < 30 |
                                  && definition == null|
                                                       v
                                                     null
      result == null -> no entities written, no group rows persisted
  return null
hasSmartPlaylistView(podcastId) -> false
shouldShowSmartPlaylistToggle -> false
PodcastDetailScreen renders Episodes only.
```

When the feed grows past 30 episodes, the next sync invalidates the
absence of cache (no stale check needed -- there is nothing cached) and
the resolver returns a grouping on the next read.

## Cache Invalidation

`autoDetectHeuristicVersion` is the sum of every resolver's
`heuristicVersion`. Bumping `YearResolver.heuristicVersion` from `1` to
`2` changes that sum, so `podcastSmartPlaylists` purges any prior
auto-detect cache the next time a podcast is opened. Curated configs
are unaffected because they use `configVersion`, not heuristic version.

## Error Handling

No new error paths. The `null` return reuses the existing "no
grouping" branch already handled by `SmartPlaylistResolverService` and
its callers.

## Edge Cases

- **Episode count drops below 30**: rare (deletions). Cache purge does
  not fire, but `_buildGroupingFromCache` keeps showing the existing
  groups until a heuristic-version bump or explicit refresh. Acceptable;
  suppression is a UX nicety, not a correctness rule.
- **Mixed publishedAt nulls**: total count is `episodes.length`,
  unaffected by null pub dates. The downstream `grouped.isEmpty` check
  still guards the no-grouping case for episodes without dates.
- **First open after upgrade with 35 cached year playlists**: heuristic
  version mismatch -> purge -> re-resolve -> still >= 30 -> grouping
  recreated.

## Observability

No new logs required. Existing `'Smart playlist resolution result: 0
playlists, N ungrouped'` line in `_resolveAndPersistSmartPlaylists`
covers the suppressed case.

## Validation

```bash
cd packages/audiflow_core && flutter test
cd packages/audiflow_domain && flutter test
flutter analyze
```
