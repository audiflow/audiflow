# Smart Playlist Design

## Overview

Rename the existing "Season" concept to "Smart Playlist" and extend it with:
- Year-based episode grouping (per-playlist flag)
- Category-based resolver for predefined episode groupings
- NewsConnect podcast pattern with custom title-based categorization
- Full i18n infrastructure (Japanese + English)

## Data Model

### SmartPlaylist (replaces Season)

```dart
class SmartPlaylist {
  final String id;
  final String displayName;
  final int sortKey;
  final List<int> episodeIds;
  final String? thumbnailUrl;
  final bool yearGrouped; // NEW
}
```

When `yearGrouped` is true, the UI renders year section headers within the
episode list. Year is derived from each episode's `publishedAt`.

### SmartPlaylists Drift Table (replaces Seasons)

```dart
class SmartPlaylists extends Table {
  IntColumn get podcastId => integer()();
  IntColumn get playlistNumber => integer()();
  TextColumn get displayName => text()();
  IntColumn get sortKey => integer()();
  TextColumn get resolverType => text()();
  TextColumn get thumbnailUrl => text().nullable()();
  BoolColumn get yearGrouped => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {podcastId, playlistNumber};
}
```

DB migration: rename `seasons` table, add `year_grouped` column.

### SmartPlaylistPattern (replaces SeasonPattern)

Same structure as `SeasonPattern` with the same fields. The pattern's config
and extractors determine how episodes are grouped into playlists.

For category-based patterns (NewsConnect), the config includes a `categories`
list defining each playlist's matching rules:

```dart
config: {
  'categories': [
    {
      'id': 'daily_news',
      'displayNameKey': 'smart_playlist_daily_news',
      'pattern': r'【\d+月\d+日】',
      'yearGrouped': true,
      'sortKey': 1,
    },
    {
      'id': 'programs',
      'displayNameKey': 'smart_playlist_programs',
      'pattern': r'【(?![\d]+月)(\w+)',
      'yearGrouped': false,
      'sortKey': 2,
    },
  ],
}
```

## Resolvers

### CategoryResolver (NEW)

Groups episodes into predefined categories by matching title patterns.

- Reads `categories` from pattern config
- For each episode, tests title against each category's regex (first match wins)
- Builds one SmartPlaylist per category
- Unmatched episodes go to ungrouped list

### Existing Resolvers (renamed)

- `RssMetadataResolver` -> works as before
- `TitleAppearanceOrderResolver` -> works as before (used by COTEN)
- `YearResolver` -> works as before (fallback)

All renamed to use SmartPlaylist terminology internally.

## Podcast Patterns

### NewsConnect

```
Feed URL: https://anchor.fm/s/81fb5eec/podcast/rss
Resolver: category
Playlists:
  1. Daily News (yearGrouped=true)
     - Matches: 【\d+月\d+日】
     - Display: "Daily News" / "平日版"
  2. Programs (yearGrouped=false)
     - Matches: everything else with 【(\w+) prefix
     - Display: "Programs" / "特集"
```

### COTEN Radio (updated)

```
Feed URL: https://anchor.fm/s/8c2088c/podcast/rss
Resolver: rss (existing)
Changes:
  - 番外編: yearGrouped=true
  - その他 (catch-all): yearGrouped=true
  - Standard seasons: yearGrouped=false (unchanged)
```

## UI Hierarchy

### yearGrouped=true (e.g., NewsConnect Daily News)

```
Smart Playlist: 平日版
├── 2025
│   ├── 【1月29日】EU・インド...
│   ├── 【1月28日】中国軍...
│   └── ...
├── 2024
│   ├── 【12月31日】...
│   └── ...
```

### yearGrouped=false (e.g., NewsConnect Programs)

```
Smart Playlist: 特集
├── 【土曜版 #62】直木賞候補...
├── 【ニュース小話 #200】日本国債...
└── ...
```

### COTEN 番外編 (yearGrouped=true)

```
Smart Playlist: 番外編
├── 2025
│   ├── 【番外編＃140】...
│   └── ...
├── 2024
│   ├── 【番外編＃130】...
│   └── ...
```

## Localization

### i18n Infrastructure Setup

- Create `l10n.yaml` in `packages/audiflow_app/`
- Create ARB files: `app_en.arb`, `app_ja.arb`
- Add `generate: true` to `pubspec.yaml`
- Add `localizationsDelegates` and `supportedLocales` to MaterialApp

### Translation Keys

| Key | English | Japanese |
|-----|---------|----------|
| `smart_playlist_daily_news` | Daily News | 平日版 |
| `smart_playlist_programs` | Programs | 特集 |
| `smart_playlist_weekdays` | Weekdays | 平日版 |
| `smart_playlist_saturdays` | Saturday Edition | 土曜版 |
| `smart_playlist_sundays` | News Chat | ニュース小話 |
| `smart_playlist_specials` | Special Edition | 特別編 |
| `smart_playlist_extras` | Extras | 番外編 |
| `smart_playlist_others` | Others | その他 |

## Implementation Order

1. **i18n setup** - ARB files, gen-l10n config, MaterialApp integration
2. **Rename Season -> SmartPlaylist** - models, Drift table, providers, services, resolvers, UI
3. **DB migration** - rename table, add `yearGrouped` column
4. **Add `yearGrouped` to SmartPlaylist model** - runtime model + Drift table
5. **Create CategoryResolver** - new resolver for predefined category grouping
6. **Create NewsConnect pattern** - category-based with 2 playlists
7. **Update COTEN pattern** - add yearGrouped flags, その他 catch-all
8. **Update UI** - year section headers for yearGrouped playlists
9. **Code generation** - build_runner for all affected packages
10. **Tests** - unit tests for CategoryResolver, NewsConnect pattern, year grouping
