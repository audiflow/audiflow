# Smart Playlist Specification

Status: Implemented

## Evolution

Season View -> Smart Playlist rename -> Groups hierarchy -> JSON patterns -> Remote config.

Originally designed as "Season View" for grouping episodes by season metadata. Evolved through several iterations into a general-purpose "Smart Playlist" system with a two-level hierarchy (playlists -> groups), JSON-defined patterns, and remote configuration.

## Architecture Overview

### Resolver Chain

A prioritized chain of resolvers attempts to group episodes. The chain stops at the first resolver that succeeds.

```
SmartPlaylistResolverService
  1. Match podcast against pattern configs (by GUID or exact feed URL)
  2. For each playlist definition in the matched config:
     - Route to the appropriate resolver by resolverType
     - Filter episodes by titleFilter/excludeFilter/requireFilter
     - Resolver groups episodes into SmartPlaylists with optional Groups
  3. If no pattern matches: no smart playlist view available
```

### Built-in Resolvers

| Resolver | Type ID | Logic |
|----------|---------|-------|
| `RssMetadataResolver` | `rss` | Groups by `episode.seasonNumber` from RSS metadata |
| `CategoryResolver` | `category` | Groups by title pattern matching against predefined categories |
| `TitleAppearanceOrderResolver` | `title_appearance` | Regex captures name; orders by first appearance |
| `YearResolver` | `year` | Groups by `publishedAt.year` |

## Two-Level Hierarchy

### SmartPlaylist

```
SmartPlaylist
  id, displayName, sortKey, thumbnailUrl
  contentType: episodes | groups
  yearHeaderMode: none | firstEpisode | perEpisode
  episodeYearHeaders: bool
  episodeIds: List<int>              // when contentType == episodes
  groups: List<SmartPlaylistGroup>?  // when contentType == groups
```

### SmartPlaylistGroup

```
SmartPlaylistGroup
  id, displayName, sortKey, thumbnailUrl
  episodeIds: List<int>
  yearOverride: YearHeaderMode?      // per-group override
```

### Year Header Modes

- `none`: No year headers
- `firstEpisode`: Group's year = first episode's year; group appears once under that year
- `perEpisode`: Group appears under each year it has episodes in; tapping shows only that year's episodes

## JSON Pattern Format

Patterns define how episodes are grouped for specific podcasts. Two-level hierarchy: pattern config (podcast matching) -> playlist definitions.

### SmartPlaylistPatternConfig (top-level)

```dart
final class SmartPlaylistPatternConfig {
  final String id;
  final String? podcastGuid;
  final List<String>? feedUrls;  // Exact feed URLs for matching
  final bool yearGroupedEpisodes;
  final List<SmartPlaylistDefinition> playlists;
}
```

### SmartPlaylistDefinition (per-playlist)

Unified schema -- all fields are named and typed (no opaque `config` map):

```dart
final class SmartPlaylistDefinition {
  final String id, displayName, resolverType;
  final int priority;
  final String? contentType, yearHeaderMode;
  final bool episodeYearHeaders;
  final String? titleFilter, excludeFilter, requireFilter;
  final int? nullSeasonGroupKey;
  final List<SmartPlaylistGroupDef>? groups;
  final SmartPlaylistSortSpec? customSort;
  final SmartPlaylistTitleExtractor? titleExtractor;
  final EpisodeNumberExtractor? episodeNumberExtractor;
  final SmartPlaylistEpisodeExtractor? smartPlaylistEpisodeExtractor;
}
```

### JSON Format (version 1)

```json
{
  "version": 1,
  "patterns": [
    {
      "id": "coten_radio",
      "feedUrls": ["https://anchor.fm/s/8c2088c/podcast/rss"],
      "yearGroupedEpisodes": false,
      "playlists": [
        {
          "id": "regular",
          "displayName": "...",
          "resolverType": "rss",
          "contentType": "groups",
          "yearHeaderMode": "firstEpisode",
          "titleFilter": "...",
          "titleExtractor": { ... },
          "episodeNumberExtractor": { ... }
        }
      ]
    }
  ]
}
```

## Remote Config

### Split-File Format

Configs stored as a three-level file hierarchy hosted on GCS (dev) and GitHub Pages (prod):

```
meta.json                              # Root: pattern summaries + versions
coten_radio/
  meta.json                            # Pattern: feed matching + playlist IDs
  playlists/
    regular.json                       # Individual playlist definition
    short.json
```

### Fetch Strategy: Lazy Per-Podcast

1. **Startup**: Fetch root `meta.json` (lightweight, always hits network)
2. **Cache reconciliation**: Compare pattern versions against local cache, evict stale entries
3. **On podcast view**: If pattern matches, load assembled config from cache or fetch remotely
4. **Offline fallback**: If root meta fetch fails, use last cached copy. If no cache, app works without patterns (auto-resolve still functions)

### Caching

Disk cache under `{cacheDir}/smartplaylist/` mirroring remote structure. `versions.json` tracks cached pattern versions for quick staleness checks. Version-based invalidation: unchanged versions skip, bumped versions evict and re-fetch.

### Models

- **RootMeta**: Schema version + `List<PatternSummary>`
- **PatternSummary**: `id`, `version` (cache key), `displayName`, `feedUrlHint` (quick pre-filter)
- **PatternMeta**: Pattern-level metadata with feed matching + ordered playlist IDs
- **ConfigAssembler**: Combines `PatternMeta` + `List<SmartPlaylistDefinition>` into `SmartPlaylistPatternConfig`

## Sticky Year Headers

### Sliver-Based Architecture

Replaced accordion-style `ExpansionTile` with sliver-based sticky headers using `SliverPersistentHeader(pinned: true)`.

Visibility rules: Year headers appear only when year grouping is enabled AND 2+ distinct years exist.

### Reusable Widget

`YearGroupedEpisodeSliverList<T>` in `audiflow_ui` accepts pre-grouped data, item builder, and scroll controller. Returns alternating `SliverPersistentHeader` + `SliverList.builder` pairs.

### Year Picker

Tapping sticky header opens `YearPickerBottomSheet`. Scroll-to-year uses offset calculation with jump (50+ episodes) or animate (fewer than 50) threshold.

## Reference Patterns

### COTEN Radio

Uses `rss` resolver with title extractors. Three playlists: Regular Series (groups by title-extracted series names), Short Series, and Others (extras). `SeasonEpisodeExtractor` handles the `【62-15】` title prefix format where RSS metadata is unreliable.

### NewsConnect

Uses `category` resolver. Two playlists: "By Category" (groups by title pattern: daily news, saturday edition, news talk, etc.) and "By Year" (same groups split by year with `perEpisode` year headers).

## File Structure

```
audiflow_domain/.../features/feed/
  models/
    smart_playlist.dart, smart_playlist_pattern_config.dart,
    smart_playlist_definition.dart, smart_playlist_group_def.dart,
    smart_playlist_sort.dart, smart_playlist_title_extractor.dart
  resolvers/
    smart_playlist_resolver.dart (interface),
    rss_metadata_resolver.dart, category_resolver.dart,
    title_appearance_order_resolver.dart, year_resolver.dart
  services/
    smart_playlist_resolver_service.dart, smart_playlist_pattern_loader.dart,
    config_assembler.dart
  repositories/
    smart_playlist_config_repository.dart (+ impl)
  datasources/
    remote/smart_playlist_remote_datasource.dart
    local/smart_playlist_cache_datasource.dart
```
