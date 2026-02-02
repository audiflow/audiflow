# Smart Playlist Groups Design

## Problem

The current SmartPlaylist model supports flat episode lists with optional
subCategories for nested display. This is insufficient for podcasts that need
a two-level hierarchy: playlists contain groups, groups contain episodes.

Examples:
- COTEN Radio: "Regular Series" playlist contains groups like "Lincoln",
  "Nikola Tesla", each with their own episode lists
- NewsConnect: "By Category" playlist contains groups like "Saturday Edition",
  "News Talk", each navigating to a dedicated episode list

## Data Model

### SmartPlaylist (restructured)

```
SmartPlaylist
  id: String
  displayName: String
  sortKey: int
  thumbnailUrl: String?
  contentType: SmartPlaylistContentType  // NEW: episodes | groups
  yearHeaderMode: YearHeaderMode         // NEW: none | firstEpisode | perEpisode
  episodeYearHeaders: bool               // NEW: year headers in episode list
  episodeIds: List<int>                  // used when contentType == episodes
  groups: List<SmartPlaylistGroup>?      // used when contentType == groups
```

### SmartPlaylistGroup (new, replaces SmartPlaylistSubCategory)

```
SmartPlaylistGroup
  id: String
  displayName: String
  sortKey: int
  thumbnailUrl: String?
  episodeIds: List<int>
  yearOverride: YearHeaderMode?          // per-group override of parent mode
```

### SmartPlaylistContentType (new enum)

- `episodes` -- playlist directly contains an episode list (current behavior)
- `groups` -- playlist contains groups; tapping a group opens its episode list

### YearHeaderMode (new enum)

- `none` -- no year headers in the group/episode list
- `firstEpisode` -- group's year = first episode's publishedAt year; group
  appears once under that year
- `perEpisode` -- group appears under each year it has episodes in; tapping
  shows only that year's episodes

### Removed

- `SmartPlaylistSubCategory` -- replaced by `SmartPlaylistGroup`
- `SmartPlaylist.subCategories` -- replaced by `SmartPlaylist.groups`
- `SmartPlaylist.yearGrouped: bool` -- replaced by `yearHeaderMode` and
  `episodeYearHeaders`

## Concrete Podcast Mappings

### COTEN Radio

| SmartPlaylist | contentType | yearHeaderMode | episodeYearHeaders | Group source |
|---|---|---|---|---|
| Regular Series | groups | firstEpisode | false | Title extractor (Lincoln, Tesla, etc.) from episodes matching `【\d+-\d+】` excluding `【COTEN RADIO\s*ショート` |
| Short Series | groups | firstEpisode | false | Title extractor from episodes matching `【COTEN RADIO\s*ショート` |
| Others (Extras) | groups | perEpisode | false | Title-based grouping; groups appear under each year they have episodes in |

### NewsConnect

| SmartPlaylist | contentType | yearHeaderMode | episodeYearHeaders | Group source |
|---|---|---|---|---|
| By Category | groups | none | true | Saturday Edition, News Talk, Special, Expat, Other |
| By Year | groups | perEpisode | false | Same groups as above, split by year |

## Navigation Flow

### Group List Screen (contentType == groups)

```
SmartPlaylist screen (e.g. "Regular Series")
  [Year header: 2025]             // only if yearHeaderMode != none
    Group card (Lincoln) -> tap -> episode list screen
    Group card (Tesla) -> tap -> episode list screen
  [Year header: 2024]
    Group card (...) -> tap -> episode list screen
```

- Group cards use the existing SmartPlaylistCard widget style
- Year headers use existing buildYearGroupedSlivers component

### Episode List Screen (tapping a group)

- Reuses SmartPlaylistEpisodesScreen logic
- If `episodeYearHeaders == true`, episodes shown with year headers
- If `yearHeaderMode == perEpisode`, only that year's episodes are passed
- Sort toggle (asc/desc) available

### Direct Episode List (contentType == episodes)

- Behaves exactly as current implementation

## Resolver Changes

### SmartPlaylistGrouping (updated result)

No structural change needed -- resolvers produce SmartPlaylists that now may
contain groups in their `groups` field.

### RssMetadataResolver

Updated to support parent playlist definitions with title-pattern filters:
- Episodes are first filtered into parent playlists by title pattern
- Within each parent playlist, episodes are grouped into SmartPlaylistGroups
  by the title extractor (existing logic)
- Season number extraction uses the existing smartPlaylistEpisodeExtractor

### CategoryResolver

Updated to produce groups instead of subCategories:
- Top-level categories become SmartPlaylists
- Sub-categories become SmartPlaylistGroups within those playlists
- For "by year" views: same groups duplicated with perEpisode yearHeaderMode

## Pattern Config Changes

### COTEN Radio Pattern

```dart
config: {
  'playlists': [
    {
      'id': 'regular',
      'displayName': 'Regular Series',
      'contentType': 'groups',
      'yearHeaderMode': 'firstEpisode',
      'episodeYearHeaders': false,
      'titleFilter': r'【\d+-\d+】',
      'excludeFilter': r'【COTEN RADIO\s*ショート',
    },
    {
      'id': 'short',
      'displayName': 'Short Series',
      'contentType': 'groups',
      'yearHeaderMode': 'firstEpisode',
      'episodeYearHeaders': false,
      'titleFilter': r'【\d+-\d+】',
      'requireFilter': r'【COTEN RADIO\s*ショート',
    },
    {
      'id': 'extras',
      'displayName': 'Others (Extras)',
      'contentType': 'groups',
      'yearHeaderMode': 'perEpisode',
      'episodeYearHeaders': false,
      // Fallback: episodes not matched by above playlists
    },
  ],
}
```

### NewsConnect Pattern

```dart
config: {
  'playlists': [
    {
      'id': 'by_category',
      'displayName': 'By Category',
      'contentType': 'groups',
      'yearHeaderMode': 'none',
      'episodeYearHeaders': true,
      'groups': [
        {'id': 'saturday', 'displayName': 'Saturday Edition', 'pattern': r'【土曜版'},
        {'id': 'news_talk', 'displayName': 'News Talk', 'pattern': r'【ニュース小話'},
        {'id': 'special', 'displayName': 'Special', 'pattern': r'【.*?特別編.*?】'},
        {'id': 'expat', 'displayName': 'Expat', 'pattern': r'【越境日本人編'},
        {'id': 'other', 'displayName': 'Other'},
      ],
    },
    {
      'id': 'by_year',
      'displayName': 'By Year',
      'contentType': 'groups',
      'yearHeaderMode': 'perEpisode',
      'episodeYearHeaders': false,
      'groups': [/* same group definitions */],
    },
  ],
}
```

## Database Changes

### SmartPlaylists Table

New columns:
- `contentType` (TEXT, default 'episodes')
- `yearHeaderMode` (TEXT, default 'none')
- `episodeYearHeaders` (BOOLEAN, default false)

Remove column:
- `yearGrouped` (replaced by yearHeaderMode/episodeYearHeaders)

### SmartPlaylistGroups Table (new)

```
SmartPlaylistGroups
  podcastId: int (FK)
  playlistId: String
  groupId: String
  displayName: String
  sortKey: int
  thumbnailUrl: String?
  episodeIds: TEXT (JSON-encoded list)
  yearOverride: TEXT? (nullable)
  PRIMARY KEY: (podcastId, playlistId, groupId)
```

## Year Assignment Logic

### firstEpisode Mode

```
for each group:
  year = group.episodeIds
    .map(id -> episode.publishedAt.year)
    .first  // based on sort order
  assign group to that year
```

### perEpisode Mode

```
for each group:
  years = group.episodeIds
    .map(id -> episode.publishedAt.year)
    .toSet()
  for each year:
    create filtered view: (group, year, filteredEpisodeIds)
```

## Migration Path

1. Add new fields to SmartPlaylist model with defaults matching current behavior
2. Update resolvers to populate groups
3. Update patterns with new config format
4. Update UI to handle group list view
5. Remove SmartPlaylistSubCategory and yearGrouped field
6. DB migration: add new columns, migrate yearGrouped data, add groups table
