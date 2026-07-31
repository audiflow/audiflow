---
refs:
  id: arch:smart-playlist-cache
  kind: architecture
  title: "Preset (smart playlist) cache"
  related:
    - integration:preset
  modules:
    - packages/audiflow_domain/lib/src/features/feed/resolvers/
    - packages/audiflow_domain/lib/src/features/feed/providers/
    - packages/audiflow_domain/lib/src/features/feed/models/
---
# Smart Playlist Cache Invalidation

## Problem

Auto-detect smart playlist resolvers cache their grouping results in Isar (`SmartPlaylistEntity`). When resolver heuristics change (e.g., a new season-number reliability check), devices with pre-existing cached data continue to show stale groupings until the cache is manually cleared.

## Solution: Heuristic Versioning

Each resolver declares a `heuristicVersion` that must be bumped when its auto-detect logic changes. A combined version (sum of all resolver versions) is stored alongside cached results. On cache load, the stored version is compared to the current combined version. A mismatch triggers a purge and re-resolve.

### How it works

1. `SmartPlaylistResolver` interface defines `int get heuristicVersion`
2. Each resolver (`SeasonNumberResolver`, `TitleClassifierResolver`, `TitleDiscoveryResolver`, `YearResolver`) returns its own version
3. `autoDetectHeuristicVersion` in `smart_playlist_providers.dart` sums all resolver versions automatically
4. When persisting auto-detect results, the combined version is stored in `SmartPlaylistEntity.heuristicVersion`
5. On cache load for auto-detect (no pattern config), `heuristicVersion` is checked: mismatch or null (pre-existing data) triggers re-resolve

### When to bump

Bump the `heuristicVersion` in the resolver you changed. The combined version updates automatically.

Examples of changes that require a bump:

- Modifying `hasReliableSeasonNumbers` thresholds
- Changing how a resolver decides whether to group or return null
- Adding/removing grouping criteria within a resolver
- Changing how episodes are assigned to groups in auto-detect mode

Changes that do NOT require a bump:

- Config-driven (pattern) logic changes (those use `configVersion` from upstream)
- Display name extraction changes (cosmetic, same grouping)
- Sort order changes (handled by user preferences)

### Cache paths

| Source | Cache key | Invalidation |
|--------|-----------|--------------|
| Pattern-driven config | `SmartPlaylistEntity.configVersion` | Upstream `PatternSummary.dataVersion` change |
| Auto-detect resolver | `SmartPlaylistEntity.heuristicVersion` | Any resolver's `heuristicVersion` bump |

### Config version migration

Episode numbering (`Episode.seasonNumber` / `episodeNumber`) is extracted from preset rules only at ingest, so a config update leaves already-stored episodes with stale numbering. When a `configVersion` mismatch is detected on cache load, `_migrateToNewConfigVersion` (in `providers/preset_providers.dart`):

1. Fetches the new config and re-runs `EpisodeReExtractionService` over all stored episodes of the podcast, persisting any numbering changes
2. Deletes the stale `SmartPlaylistEntity` and `SmartPlaylistGroupEntity` rows for the podcast
3. Re-resolves and persists the grouping, advancing `configVersion` to the new `dataVersion`

If the config fetch fails, the stale cache is kept and a transient in-memory re-resolve is served; the migration retries on the next read.

### Manual escape hatch

The Storage & Data screen has a "Podcast Cache" clear button that purges all `SmartPlaylistEntity` rows, the disk config cache, and subscription HTTP cache headers.

## File locations

| File | Role |
|------|------|
| `resolvers/smart_playlist_resolver.dart` | Interface with `heuristicVersion` |
| `resolvers/season_number_resolver.dart` | Season resolver (version 2 after `hasReliableSeasonNumbers`) |
| `resolvers/title_classifier_resolver.dart` | Title classifier resolver (version 1) |
| `resolvers/title_discovery_resolver.dart` | Title discovery resolver (version 1) |
| `resolvers/year_resolver.dart` | Year resolver (version 1) |
| `providers/smart_playlist_providers.dart` | Combined version computation + cache check |
| `models/smart_playlists.dart` | `SmartPlaylistEntity.heuristicVersion` field |
