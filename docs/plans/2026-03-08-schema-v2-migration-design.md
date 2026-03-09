# Smart Playlist Schema v1 to v2 Migration

## Context

The smart playlist JSON schema has been updated from v1 to v2 in the
`audiflow-smartplaylist-schema` repo. This is a clean cut -- no backward
compatibility with v1. All data repos will be migrated to v2 simultaneously.

## Schema Changes Summary

### Renames

| v1 | v2 |
|----|-----|
| `contentType` (enum: `episodes`, `groups`) | `playlistStructure` (enum: `split`, `grouped`) |
| `yearHeaderMode` (enum: `none`, `firstEpisode`, `perEpisode`) | `groupList.yearBinding` (enum: `none`, `pinToYear`, `splitByYear`) |
| `smartPlaylistEpisodeExtractor` | `episodeExtractor` |
| `showSeasonNumber` | `prependSeasonNumber` |
| `showSortOrderToggle` | `groupList.userSortable` (default: `true`) |
| `episodeYearHeaders` | `episodeList.showYearHeaders` |

### Restructured

- Flat filters (`titleFilter`, `excludeFilter`, `requireFilter`) become
  `episodeFilters: { require: [EpisodeFilterEntry], exclude: [EpisodeFilterEntry] }`
  where `EpisodeFilterEntry` is `{ title?, description? }`.
- `yearHeaderMode`, `showSortOrderToggle`, `showDateRange`, `customSort` move
  into `groupList` object.
- `episodeYearHeaders` moves into `episodeList` object (with new `sort` and
  `titleExtractor` fields).
- `customSort` (SortSpec with rules array) simplifies to `groupList.sort`
  (single SortRule).

### New

- `EpisodeFilterEntry` -- filter condition with `title?` and `description?`
- `GroupListConfig` -- `{ yearBinding?, userSortable?, showDateRange?, sort? }`
- `EpisodeListConfig` -- `{ showYearHeaders?, sort?, titleExtractor? }`
- `EpisodeSortRule` -- `{ field (publishedAt|episodeNumber|title), order }`
- `GroupDisplayConfig` -- per-group display overrides `{ showDateRange?, yearBinding? }`
- `GroupDef.display`, `GroupDef.episodeList`, `GroupDef.episodeExtractor`
  cascading overrides

### Removed

- `SmartPlaylistSortSpec` (multi-rule sort array)
- `SmartPlaylistSortCondition` / `SortKeyGreaterThan` (conditional sort)
- `SmartPlaylistSortField.progress` (runtime concern)
- `GroupDef.sortOrder` (use `GroupDef.episodeList.sort`)

## Drift Tables

Drift tables are cache-only (rebuilt on feed sync). Config fields like
`showDateRange`, `userSortable`, `prependSeasonNumber`, sort specs are NOT
persisted -- they come from JSON config at runtime.

Migration: drop and recreate smart playlist tables. Rename persisted columns:
- `SmartPlaylists.contentType` column renamed to `playlistStructure`
- `SmartPlaylistGroups.episodeYearHeaders` column removed

## Approach

Single branch, bottom-up migration:

1. Vendor v2 schema fixture
2. Create new model files (EpisodeFilterEntry, EpisodeFilters, GroupListConfig,
   EpisodeListConfig, EpisodeSortRule, GroupDisplayConfig)
3. Update existing models (enums, SmartPlaylistDefinition, SmartPlaylistGroupDef,
   SmartPlaylist, sort models)
4. Update Drift tables + migration
5. Update resolver service and providers
6. Update UI layer
7. Update all tests
8. Run conformance tests to validate
