# COTEN RADIO Season Extractor Design

## Overview

Custom season extractor for COTEN RADIO podcast (`https://anchor.fm/s/8c2088c/podcast/rss`). Handles two episode patterns:

- **Regular seasons**: `【62-15】...【COTEN RADIO リンカン編15】` with positive `seasonNumber`
- **番外編 (Extras)**: `【番外編＃135】...` with `seasonNumber = 0` or `null`

## Data Model

### New `Seasons` Drift Table

```dart
class Seasons extends Table {
  IntColumn get podcastId => integer()();
  IntColumn get seasonNumber => integer()();
  TextColumn get displayName => text()();
  IntColumn get sortKey => integer()();
  TextColumn get resolverType => text()();

  @override
  Set<Column> get primaryKey => {podcastId, seasonNumber};
}
```

**Notes:**
- Composite primary key: `(podcastId, seasonNumber)`
- No FK on Episodes table; join via `episodes.podcastId == seasons.podcastId AND episodes.seasonNumber == seasons.seasonNumber`
- `sortKey` derived from max `episodeNumber` in season

## Extractors

### SeasonTitleExtractor

Extracts season display name from episode title.

**Regex:** `【COTEN RADIO (ショート)?\s*(.+?)\s+\d+】`
- Capture group 2: season title (e.g., "リンカン編")
- Handles optional "ショート" variant

**Fallback:** If `seasonNumber <= 0` or `null` → "番外編"

### EpisodeNumberExtractor (New)

Extracts episode-in-season number on-demand when listing episodes.

**For `seasonNumber > 0`:**
- Regex: `(\d+)】`
- Capture group 1: episode number (e.g., 15)

**For `seasonNumber <= 0` or `null`:**
- Use RSS `episodeNumber` directly

## RssMetadataResolver Changes

### New Config Option

```json
{
  "resolverType": "rss",
  "config": {
    "groupNullSeasonAs": 0
  }
}
```

When `groupNullSeasonAs` is set, episodes with `null` or `0` seasonNumber are grouped into the specified season number.

### sortKey Calculation

```dart
final sortKey = seasonEpisodes
    .map((e) => e.episodeNumber ?? 0)
    .reduce(max);
```

Sorts by highest episodeNumber (stable, unlike pubDate which can change on re-publish).

## SeasonPattern Changes

### feedUrlPatterns (List)

Changed from single `feedUrlPattern` to list for publisher-wide patterns:

```dart
final List<String>? feedUrlPatterns;
```

### Matching Logic

```dart
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
```

**Note:** Patterns are anchored with `^` and `$` for full URL matching.

### New Field

```dart
final EpisodeNumberExtractor? episodeNumberExtractor;
```

## COTEN RADIO Configuration

```json
{
  "id": "coten_radio",
  "feedUrlPatterns": [
    "https://anchor\\.fm/s/8c2088c/podcast/rss"
  ],
  "resolverType": "rss",
  "config": {
    "groupNullSeasonAs": 0
  },
  "titleExtractor": {
    "type": "regex",
    "pattern": "【COTEN RADIO (ショート)?\\s*(.+?)\\s+\\d+】",
    "captureGroup": 2,
    "fallback": "番外編"
  },
  "episodeNumberExtractor": {
    "type": "regex",
    "pattern": "(\\d+)】",
    "captureGroup": 1,
    "fallbackToRss": true
  }
}
```

## Implementation Files

| Action | File |
|--------|------|
| Create | `packages/audiflow_domain/lib/src/features/feed/models/seasons.dart` |
| Create | `packages/audiflow_domain/lib/src/features/feed/models/episode_number_extractor.dart` |
| Modify | `packages/audiflow_domain/lib/src/features/feed/models/season_pattern.dart` |
| Modify | `packages/audiflow_domain/lib/src/features/feed/resolvers/rss_metadata_resolver.dart` |
| Create | `assets/season_patterns/coten_radio.json` |
| Create | Database migration for `Seasons` table |
