# SmartPlaylist Remote Config Loading - Design Document

## Problem

The audiflow app bundles all SmartPlaylist configs as a single `assets/smart_playlist_patterns.json` file. Every config update requires an app release. The smartplaylist-web project has migrated configs to a split-file format hosted on GCS (dev) and GitHub Pages (prod), enabling community contributors to create and edit configs via a web editor with PR workflow.

The audiflow app needs to adopt this new split-file format and fetch configs remotely instead of from bundled assets.

## Architecture

### Split Config Format

Configs are stored as a three-level file hierarchy:

```
meta.json                              # Root: pattern summaries + versions
coten_radio/
  meta.json                            # Pattern: feed matching + playlist IDs
  playlists/
    regular.json                       # Playlist definition
    short.json
rebuild_fm/
  meta.json
  playlists/
    ...
```

**Level 1 - Root meta** (`meta.json`): Lists all available patterns with version numbers for cache invalidation. Small payload, fetched on every app start.

**Level 2 - Pattern meta** (`{patternId}/meta.json`): Contains feed URL regex patterns, podcast GUID, and an ordered list of playlist IDs.

**Level 3 - Playlist definitions** (`{patternId}/playlists/{id}.json`): Individual playlist configs using the same JSON schema as the current bundled format.

### Config Hosting

| Environment | Source |
|-------------|--------|
| dev | `https://storage.googleapis.com/audiflow-dev-config` |
| prod | GitHub Pages (TBD URL) |

Base URL injected via `FlavorConfig.smartPlaylistConfigBaseUrl`.

### Fetch Strategy: Lazy Per-Podcast

1. **Startup**: Fetch root `meta.json` (lightweight, always hits network)
2. **Cache reconciliation**: Compare pattern versions against local cache, evict stale entries
3. **On podcast view**: If a pattern matches the subscribed podcast, load assembled config from cache or fetch remotely
4. **Offline fallback**: If root meta fetch fails, use last cached copy. If no cache at all, app works without pattern configs (auto-resolve still functions).

## Caching

### Disk Cache with Version-Based Invalidation

Cached files stored under `{cacheDir}/smartplaylist/`, mirroring the remote file structure. A `versions.json` file tracks cached pattern versions for quick staleness checks.

```
{cacheDir}/smartplaylist/
  versions.json                    # {"coten_radio": 3, "rebuild_fm": 1}
  meta.json                        # Root meta (overwritten on each fetch)
  coten_radio/
    meta.json                      # Pattern meta
    playlists/
      regular.json
      short.json
  rebuild_fm/
    ...
```

### Invalidation Logic

1. Fetch root `meta.json` from remote
2. Compare each `PatternSummary.version` against `versions.json`
3. Version unchanged: skip, use cached assembled config
4. Version bumped: evict that pattern's entire directory, re-fetch on next access
5. Pattern removed from root meta: evict cached directory
6. Pattern added: nothing to evict, fetch on first access

Most app starts require zero network beyond the small root meta fetch.

## New Models

Three new models in `audiflow_domain`, independent of `sp_shared`. These mirror the split-file JSON format.

### PatternSummary

From root `meta.json`. Used for pattern discovery and cache invalidation.

```dart
final class PatternSummary {
  final String id;
  final int version;           // Cache invalidation key
  final String displayName;
  final String feedUrlHint;    // Quick pre-filter (plain string, not regex)
  final int playlistCount;
}
```

### RootMeta

Root `meta.json` envelope.

```dart
final class RootMeta {
  final int version;           // Schema version
  final List<PatternSummary> patterns;
}
```

### PatternMeta

Pattern-level `{id}/meta.json`.

```dart
final class PatternMeta {
  final int version;
  final String id;
  final String? podcastGuid;
  final List<String> feedUrlPatterns;
  final bool yearGroupedEpisodes;
  final List<String> playlists;   // Ordered playlist IDs
}
```

### ConfigAssembler

Combines a `PatternMeta` + `List<SmartPlaylistDefinition>` into the existing `SmartPlaylistPatternConfig`. Trivial mapping, no changes to existing models.

## Repository Layer

### SmartPlaylistConfigRepository

```dart
abstract class SmartPlaylistConfigRepository {
  Future<RootMeta> fetchRootMeta();
  Future<SmartPlaylistPatternConfig> getConfig(PatternSummary summary);
  PatternSummary? findMatchingPattern(String? podcastGuid, String feedUrl);
  Future<void> reconcileCache(List<PatternSummary> latest);
}
```

### Implementation

- **Remote datasource**: Dio (already in project) fetches from `configBaseUrl`
- **Local datasource**: Reads/writes JSON files under `{cacheDir}/smartplaylist/`
- **Version tracking**: `versions.json` maps `patternId` to `version` for quick staleness checks
- **Deduplication**: In-flight request map prevents concurrent fetches for the same pattern

## App Integration

### Startup Flow

Current:
```dart
final patternsJson = await rootBundle.loadString('assets/smart_playlist_patterns.json');
final patterns = SmartPlaylistPatternLoader.parse(patternsJson);
container.read(smartPlaylistPatternsProvider.notifier).setPatterns(patterns);
```

New:
```dart
final configRepo = container.read(smartPlaylistConfigRepositoryProvider);
final rootMeta = await configRepo.fetchRootMeta();
await configRepo.reconcileCache(rootMeta.patterns);
container.read(patternSummariesProvider.notifier).setSummaries(rootMeta.patterns);
```

### Podcast View Flow

Current: Searches pre-loaded `List<SmartPlaylistPatternConfig>` in memory.

New: Looks up `PatternSummary` from lightweight list, then fetches/caches full config on demand.

```dart
final configRepo = ref.read(smartPlaylistConfigRepositoryProvider);
final summary = configRepo.findMatchingPattern(podcastGuid, feedUrl);
if (summary == null) { /* fallback: auto-resolve */ }
final config = await configRepo.getConfig(summary); // cache-aware
// ... rest of resolver flow unchanged
```

### What Changes

| Component | Change |
|-----------|--------|
| `smartPlaylistPatternsProvider` | Replaced by `patternSummariesProvider` (lightweight summaries, not full configs) |
| `main.dart` | Replace asset loading with remote fetch + cache reconciliation |
| `flavor_config.dart` | Add `smartPlaylistConfigBaseUrl` |
| `smart_playlist_providers.dart` | Update for lazy loading via repository |

### What Stays the Same

- `SmartPlaylistResolverService` - untouched
- All resolvers - untouched
- `SmartPlaylistPatternConfig` model - untouched
- `SmartPlaylistDefinition` model - untouched
- `SmartPlaylistPatternConfig.matchesPodcast()` - still used after lazy-load
- Database persistence of resolved playlists - untouched

## Error Handling

**Network failures**: Root meta fetch fails at startup: use last cached `meta.json` from disk. If no cache exists (fresh install), app continues without pattern configs. Auto-resolve works for all podcasts regardless.

**Individual config fetch fails**: Return error to caller, don't evict existing cache. Retry on next podcast view.

**First launch (cold cache)**: Root meta fetched and stored. No configs cached yet. Each podcast view triggers a fetch for its matching pattern. After first view, config is cached for future offline use.

**Concurrent access**: Multiple podcast views requesting the same pattern simultaneously are deduplicated via a `Map<String, Future>` of in-flight requests.

## File Changes

### New Files (8)

| File | Package | Purpose |
|------|---------|---------|
| `pattern_summary.dart` | audiflow_domain/models | Model |
| `root_meta.dart` | audiflow_domain/models | Model |
| `pattern_meta.dart` | audiflow_domain/models | Model |
| `config_assembler.dart` | audiflow_domain/services | Assembles split files into PatternConfig |
| `smart_playlist_config_repository.dart` | audiflow_domain/repositories | Interface |
| `smart_playlist_config_repository_impl.dart` | audiflow_domain/repositories | Implementation |
| `smart_playlist_remote_datasource.dart` | audiflow_domain/datasources/remote | Dio fetch |
| `smart_playlist_cache_datasource.dart` | audiflow_domain/datasources/local | Disk cache |

### Modified Files (3)

| File | Change |
|------|--------|
| `main.dart` | Replace asset loading with remote fetch + cache reconciliation |
| `smart_playlist_providers.dart` | New `patternSummariesProvider`, update lazy loading |
| `flavor_config.dart` | Add `smartPlaylistConfigBaseUrl` |

### Deleted Files (1)

| File | Reason |
|------|--------|
| `assets/smart_playlist_patterns.json` | Replaced by remote configs |

## Out of Scope

- No dependency on `sp_shared` (models kept independent)
- No changes to resolvers, definitions, or existing models
- No changes to database layer or resolved playlist caching
- No changes to the smartplaylist-web project

## Implementation Status (as of 2026-02-10)

### smartplaylist-web project (separate repo)

| Component | Status |
|-----------|--------|
| sp_shared (models, resolvers, schema) | Complete |
| sp_server (API, auth, config routes) | ~90% (Git Trees API pending) |
| sp_web (Flutter web editor) | ~85% (widget tests missing) |
| mcp_server (MCP protocol) | Complete |
| GCS hosting (dev) | Deployed |
| Docker + Cloud Run deployment | Deployed |

### audiflow adoption (this design)

Not yet started. All changes are in the audiflow repo.
