# Smart Playlist JSON Patterns Design

## Overview

Move smart playlist pattern definitions from hardcoded Dart constants to a static JSON asset bundled in the app. Restructure the model into a two-level hierarchy: a top-level pattern config that matches a podcast, containing multiple playlist definitions each with their own resolver config, extractors, and sorting. This establishes the JSON format and deserialization pipeline as a stepping stone toward server-downloaded patterns.

## Goals

- Define smart playlist patterns in JSON instead of Dart code
- Restructure into two-level hierarchy: pattern config (podcast matching) -> playlist definitions (per-playlist config)
- Unified playlist schema: every playlist uses the same fields regardless of resolver type
- Eliminate the opaque `config` map — all fields are named and typed
- Keep the loading code source-agnostic so the JSON source can later swap from asset to server + local cache

## Non-Goals

- Server-downloaded patterns (future)
- Pattern merge/priority logic between bundled and server patterns (future)
- User-defined patterns (future)

---

## Architecture

### Loading Flow

```
App startup
  -> rootBundle.loadString('assets/smart_playlist_patterns.json')  [audiflow_app]
  -> SmartPlaylistPatternLoader.parse(jsonString)                  [audiflow_domain]
  -> List<SmartPlaylistPatternConfig>
  -> SmartPlaylistResolverService (updated to iterate playlists)
```

### Future Swap Point

Replace `rootBundle.loadString(...)` with HTTP fetch + local cache. The `SmartPlaylistPatternLoader.parse()` call stays identical since the JSON format is the same.

---

## Model Structure

### Two-Level Hierarchy

```dart
/// Top-level: matches a podcast by GUID or feed URL.
final class SmartPlaylistPatternConfig {
  final String id;
  final String? podcastGuid;
  final List<String>? feedUrlPatterns;
  final bool yearGroupedEpisodes;
  final List<SmartPlaylistDefinition> playlists;
}

/// Per-playlist definition with unified schema.
/// All fields are named and typed. Fields irrelevant to a
/// resolver type are simply null/ignored.
final class SmartPlaylistDefinition {
  final String id;
  final String displayName;
  final String resolverType;
  final int priority;

  // Display config
  final String? contentType;        // "groups" | "episodes"
  final String? yearHeaderMode;     // "none" | "firstEpisode" | "perEpisode"
  final bool episodeYearHeaders;

  // Episode routing (which episodes belong to this playlist)
  final String? titleFilter;
  final String? excludeFilter;
  final String? requireFilter;

  // Resolver-specific
  final int? nullSeasonGroupKey;    // was config['groupNullSeasonAs']
  final List<SmartPlaylistGroupDef>? groups;

  // Per-playlist extractors and sorting
  final SmartPlaylistSortSpec? customSort;
  final SmartPlaylistTitleExtractor? titleExtractor;
  final EpisodeNumberExtractor? episodeNumberExtractor;
  final SmartPlaylistEpisodeExtractor? smartPlaylistEpisodeExtractor;
}

/// Static group definition within a playlist.
final class SmartPlaylistGroupDef {
  final String id;
  final String displayName;
  final String? pattern;            // null = fallback group
}
```

---

## JSON Format

### Full Example: COTEN RADIO

```json
{
  "version": 1,
  "patterns": [
    {
      "id": "coten_radio",
      "feedUrlPatterns": [
        "https://anchor\\.fm/s/8c2088c/podcast/rss",
        "https://.*anchor\\.fm.*\\b8c2088c\\b.*"
      ],
      "yearGroupedEpisodes": false,
      "playlists": [
        {
          "id": "regular",
          "displayName": "レギュラーシリーズ",
          "resolverType": "rss",
          "contentType": "groups",
          "yearHeaderMode": "firstEpisode",
          "episodeYearHeaders": false,
          "titleFilter": "【\\d+-\\d+】",
          "excludeFilter": "【COTEN RADIO\\s*ショート",
          "nullSeasonGroupKey": 0,
          "customSort": {
            "type": "composite",
            "rules": [
              {
                "field": "playlistNumber",
                "order": "ascending",
                "condition": { "type": "sortKeyGreaterThan", "value": 0 }
              },
              {
                "field": "newestEpisodeDate",
                "order": "ascending"
              }
            ]
          },
          "titleExtractor": {
            "source": "title",
            "pattern": "【?COTEN RADIO(ショート)?\\s+(.+?)編?\\s*(\\d+|前編|中編|後編)】",
            "group": 2,
            "fallbackValue": "番外編",
            "fallback": {
              "source": "title",
              "pattern": "【番外編",
              "group": 0,
              "template": "番外編"
            }
          },
          "episodeNumberExtractor": {
            "pattern": "(\\d+)】",
            "captureGroup": 1,
            "fallbackToRss": true
          },
          "smartPlaylistEpisodeExtractor": {
            "source": "title",
            "pattern": "【(\\d+)-(\\d+)】",
            "seasonGroup": 1,
            "episodeGroup": 2,
            "fallbackSeasonNumber": 0,
            "fallbackEpisodePattern": "【番外編[＃#](\\d+)】",
            "fallbackEpisodeCaptureGroup": 1
          }
        },
        {
          "id": "short",
          "displayName": "ショートシリーズ",
          "resolverType": "rss",
          "contentType": "groups",
          "yearHeaderMode": "firstEpisode",
          "episodeYearHeaders": false,
          "titleFilter": "【\\d+-\\d+】",
          "requireFilter": "【COTEN RADIO\\s*ショート",
          "nullSeasonGroupKey": 0,
          "customSort": {
            "type": "composite",
            "rules": [
              {
                "field": "playlistNumber",
                "order": "ascending",
                "condition": { "type": "sortKeyGreaterThan", "value": 0 }
              },
              {
                "field": "newestEpisodeDate",
                "order": "ascending"
              }
            ]
          },
          "titleExtractor": {
            "source": "title",
            "pattern": "【?COTEN RADIO(ショート)?\\s+(.+?)編?\\s*(\\d+|前編|中編|後編)】",
            "group": 2,
            "fallbackValue": "番外編",
            "fallback": {
              "source": "title",
              "pattern": "【番外編",
              "group": 0,
              "template": "番外編"
            }
          },
          "episodeNumberExtractor": {
            "pattern": "(\\d+)】",
            "captureGroup": 1,
            "fallbackToRss": true
          },
          "smartPlaylistEpisodeExtractor": {
            "source": "title",
            "pattern": "【(\\d+)-(\\d+)】",
            "seasonGroup": 1,
            "episodeGroup": 2,
            "fallbackSeasonNumber": 0,
            "fallbackEpisodePattern": "【番外編[＃#](\\d+)】",
            "fallbackEpisodeCaptureGroup": 1
          }
        },
        {
          "id": "extras",
          "displayName": "その他(番外編など)",
          "resolverType": "rss",
          "contentType": "groups",
          "yearHeaderMode": "perEpisode",
          "episodeYearHeaders": false,
          "nullSeasonGroupKey": 0
        }
      ]
    }
  ]
}
```

### Full Example: NewsConnect

```json
{
  "version": 1,
  "patterns": [
    {
      "id": "news_connect",
      "feedUrlPatterns": [
        "https://anchor\\.fm/s/81fb5eec/podcast/rss",
        "https://.*anchor\\.fm.*81fb5eec.*"
      ],
      "yearGroupedEpisodes": true,
      "playlists": [
        {
          "id": "by_category",
          "displayName": "カテゴリ別",
          "resolverType": "category",
          "contentType": "groups",
          "yearHeaderMode": "none",
          "episodeYearHeaders": true,
          "groups": [
            { "id": "daily_news", "displayName": "平日版", "pattern": "【\\d+月\\d+日】" },
            { "id": "saturday", "displayName": "土曜版", "pattern": "【土曜版" },
            { "id": "news_talk", "displayName": "ニュース小話", "pattern": "【ニュース小話" },
            { "id": "special", "displayName": "特別編", "pattern": "【.*?特別編.*?】" },
            { "id": "expat", "displayName": "越境日本人編", "pattern": "【越境日本人編" },
            { "id": "holiday", "displayName": "祝日版", "pattern": "【祝日版" },
            { "id": "other", "displayName": "その他" }
          ]
        },
        {
          "id": "by_year",
          "displayName": "年別",
          "resolverType": "category",
          "contentType": "groups",
          "yearHeaderMode": "perEpisode",
          "episodeYearHeaders": false,
          "groups": [
            { "id": "daily_news", "displayName": "平日版", "pattern": "【\\d+月\\d+日】" },
            { "id": "saturday", "displayName": "土曜版", "pattern": "【土曜版" },
            { "id": "news_talk", "displayName": "ニュース小話", "pattern": "【ニュース小話" },
            { "id": "special", "displayName": "特別編", "pattern": "【.*?特別編.*?】" },
            { "id": "expat", "displayName": "越境日本人編", "pattern": "【越境日本人編" },
            { "id": "holiday", "displayName": "祝日版", "pattern": "【祝日版" },
            { "id": "other", "displayName": "その他" }
          ]
        }
      ]
    }
  ]
}
```

### Format Decisions

- **Top-level `version` field**: For future format migrations when server-downloaded.
- **Unified playlist schema**: Every playlist uses the same fields. Fields irrelevant to a resolver type are null/absent and ignored.
- **No opaque `config` map**: All fields are named and typed. `groupNullSeasonAs` became `nullSeasonGroupKey`. `groups` is a first-class field.
- **Sort specs use `type` discriminator**: `"simple"` or `"composite"` to deserialize the sealed class.
- **Condition uses `type` discriminator**: `"sortKeyGreaterThan"` (extensible for future condition types).
- **Group definitions**: `SmartPlaylistGroupDef` with `id`, `displayName`, and optional `pattern` (null = fallback group).

---

## Changes

### 1. New models

- `SmartPlaylistPatternConfig` — top-level pattern with podcast matching and playlist list
- `SmartPlaylistDefinition` — per-playlist config with unified schema, `fromJson`/`toJson`
- `SmartPlaylistGroupDef` — static group definition, `fromJson`/`toJson`

### 2. `audiflow_domain/.../smart_playlist_sort.dart`

Add `fromJson`/`toJson` to the sort hierarchy:
- `SmartPlaylistSortSpec` (factory `fromJson` with `type` discriminator)
- `SimpleSmartPlaylistSort`
- `CompositeSmartPlaylistSort`
- `SmartPlaylistSortRule`
- `SortKeyGreaterThan` / `SmartPlaylistSortCondition`

### 3. `audiflow_domain/.../services/smart_playlist_pattern_loader.dart` (new)

```dart
final class SmartPlaylistPatternLoader {
  /// Parses a JSON string into a list of pattern configs.
  ///
  /// Throws [FormatException] if the version is unsupported.
  static List<SmartPlaylistPatternConfig> parse(String jsonString);
}
```

Pure function, no Flutter dependency. Validates `version` field.

### 4. `audiflow_domain/lib/audiflow_domain.dart`

Export new models and loader.

### 5. `audiflow_app/assets/smart_playlist_patterns.json` (new)

JSON with both COTEN RADIO and NewsConnect patterns.

### 6. `audiflow_app/pubspec.yaml`

Declare asset path.

### 7. `audiflow_app` provider layer

A provider that loads JSON via `rootBundle.loadString(...)` and passes to `SmartPlaylistPatternLoader.parse()`.

### 8. Resolver service updates

`SmartPlaylistResolverService` updated to:
- Accept `List<SmartPlaylistPatternConfig>` instead of `List<SmartPlaylistPattern>`
- Iterate playlists within a matched pattern config
- Pass `SmartPlaylistDefinition` to resolvers instead of `SmartPlaylistPattern`

### 9. Resolver interface update

Resolvers receive `SmartPlaylistDefinition` instead of `SmartPlaylistPattern`. They read typed fields directly instead of from opaque `config` map.

### 10. `audiflow_domain/.../smart_playlist_providers.dart`

- Replace `_registeredPatterns` const list with provider that accepts loaded patterns
- Update all references from `SmartPlaylistPattern` to `SmartPlaylistPatternConfig` / `SmartPlaylistDefinition`

### 11. Remove old `SmartPlaylistPattern`

Replace with `SmartPlaylistPatternConfig` + `SmartPlaylistDefinition`. The old class is deleted.

### 12. Existing pattern files

`coten_radio_pattern.dart` and `news_connect_pattern.dart` are deleted. The JSON asset is the source of truth. Test fixtures use JSON directly.

### 13. Tests

- JSON round-trip: parse JSON, verify fields match expected values
- `SmartPlaylistPatternLoader.parse()` with valid and invalid inputs
- Sort spec serialization for all variants
- Resolver tests updated for new model types

---

## Revision History

- 2026-02-02: Initial design
- 2026-02-02: Restructured to two-level hierarchy with unified playlist schema, eliminated opaque config map
