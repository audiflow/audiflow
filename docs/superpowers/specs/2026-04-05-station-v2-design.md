# Station v2 Design: Episode Limit & Podcast Picker

## Overview

Updates to the Station feature replacing time-span-based episode filtering (`publishedWithinDays`) with count-based limiting ("latest N episodes"), adding per-podcast episode limit overrides, a podcast grouping mode, and a redesigned podcast selection UI.

Builds on the existing Station v1 design (`2026-03-20-station-design.md`).

## Changes from v1

| Area | v1 | v2 |
|------|----|----|
| Episode limiting | Time-span (`publishedWithinDays`: 7/14/30/90 days) | Count-based (`defaultEpisodeLimit`: 1/2/3/4/5/10/all) per podcast |
| Per-podcast config | None (all podcasts use station-level filters) | Per-podcast episode limit override |
| Podcast selection | Inline checkbox list in editor | Fullscreen modal with search + sort |
| Episode display | Flat list, pubdate order only | Flat or grouped by podcast |
| Podcast ordering | Not configurable | Subscribe order / Name / Manual |

## Data Model Changes

### Station collection

Remove:
- `publishedWithinDays: int?`

Add:
- `defaultEpisodeLimit: int?` -- default episode count per podcast. Values: 1, 2, 3, 4, 5, 10, `null` (all). Default: 3
- `groupByPodcast: bool` -- whether to group episodes by podcast in detail view. Default: false
- `podcastSortType: String` -- ordering of podcasts when grouped. Values: `subscribe_asc`, `subscribe_desc`, `name_asc`, `name_desc`, `manual`. Default: `manual`

### StationPodcast collection

Add:
- `episodeLimit: int?` -- per-podcast override. `null` = use station default. Same value set as `defaultEpisodeLimit`
- `sortOrder: int` -- manual sort position. Default: 0

### StationReconciler changes

Current logic queries episodes per podcast and applies filter conditions. The change replaces the date-cutoff filter with a count-based limit:

**Before:**
```
For each podcast in station:
  Query episodes WHERE publishedAt >= cutoffDate
  Apply attribute filters
```

**After:**
```
For each podcast in station:
  Resolve episodeLimit = stationPodcast.episodeLimit ?? station.defaultEpisodeLimit
  Query episodes ORDER BY publishedAt DESC
  If episodeLimit != null: LIMIT episodeLimit
  Apply attribute filters (hideCompleted, downloaded, favorited, duration)
```

The count limit is applied before other attribute filters. This means "latest 3" gives the 3 most recent episodes, then attribute filters (hideCompleted, etc.) reduce that set further.

### Episode ordering in detail view

**Group by podcast OFF:**
All episodes sorted by `publishedAt` (ascending or descending per `episodeSortType`).

**Group by podcast ON:**
Episodes ordered by podcast sort first, then by `publishedAt` within each podcast's block. No section headers in UI -- podcast artwork provides visual grouping.

Podcast sort types when grouped:
- `subscribe_asc` / `subscribe_desc` -- by `StationPodcast.addedAt`
- `name_asc` / `name_desc` -- alphabetical by podcast name
- `manual` -- by `StationPodcast.sortOrder`

## UI: Station Editor

### Section order

1. Station name (text field, max 50 chars)
2. Episodes -- station default limit. Tap to show picker (1, 2, 3, 4, 5, 10, All). Displays as `Latest N >`
3. Filter toggles:
   - Hide played episodes (toggle)
   - Downloaded only (toggle)
   - Favorites only (toggle)
4. Duration filter (toggle + shorter/longer selector + minutes input). Minutes text input selects all text on focus
5. Episode sort (segmented: Newest / Oldest)
6. Group by podcast (toggle)
7. Podcasts section:
   - Section header row: "PODCASTS" label + sort button
   - "Select podcasts..." row (tap opens fullscreen modal). Shows `N / total >`
   - Selected podcast list with per-podcast episode limit
8. Delete station button (edit mode only)

### Podcast sort button behavior

The sort button in the Podcasts section header shows the current sort type as a label:

| Sort type | Button label | Tap action |
|-----------|-------------|------------|
| `subscribe_asc` | Subscribe (old) v | ActionSheet with 5 sort options |
| `subscribe_desc` | Subscribe (new) v | ActionSheet with 5 sort options |
| `name_asc` | Name A-Z v | ActionSheet with 5 sort options |
| `name_desc` | Name Z-A v | ActionSheet with 5 sort options |
| `manual` | Reorder | Enter drag-handle reorder mode |

ActionSheet options: Subscribe (old), Subscribe (new), Name A-Z, Name Z-A, Manual.

### Reorder mode (manual sort)

When the user taps "Reorder":
- Each podcast row shows a drag handle on the right
- Episode limit indicators are hidden during reorder
- Button label changes to "Done"
- Long-press + drag to reorder (ReorderableListView)
- Tap "Done" to exit reorder mode and persist `sortOrder` values

### Per-podcast episode limit (inline expand)

Each selected podcast row displays: artwork + name + `Latest N (down chevron)`

- Down chevron (gray) when collapsed -- indicates expandable
- Up chevron (blue) when expanded -- indicates collapsible

Tap to expand inline: shows chip selector with options: 1, 2, 3, 4, 5, 10, All, Default (N). The "Default (N)" chip shows the current station default value. Selecting "Default" sets `episodeLimit` to `null`.

### Manual sort order preservation

When the podcast sort is `manual` and the user edits the selection:
- **Newly added podcasts**: inserted at the top of the list (lowest `sortOrder`)
- **Existing podcasts** (including those toggled off and back on during the same edit session): retain their original `sortOrder`
- **Removed podcasts**: their `sortOrder` data is discarded

This ensures the user's manual arrangement is preserved across edits.

## UI: Podcast Picker Modal

Fullscreen modal pushed on top of the editor.

### Header
- Cancel (left) -- discard changes, return to editor
- "Select Podcasts" title (center)
- Done (right, bold) -- save selection, return to editor

### Search bar
- Real-time text filter against podcast name
- Clear button (X) when text is present

### Sort bar
- Left: count label (e.g., "75 subscribed" or "3 results" when searching)
- Right: sort button with current sort label + down arrow

Sort options (ActionSheet): Name A-Z, Name Z-A, Recently subscribed, Recently updated. Sort state is local to the modal (resets on close). Default: Name A-Z.

### Podcast list
- All subscribed (non-cached) podcasts shown in a scrollable list
- Each row: checkbox (circle) + artwork + podcast name
- Tap anywhere on row to toggle selection
- Selected: filled blue circle with checkmark
- Unselected: gray outline circle

## UI: Station Detail Screen

No changes to the screen structure. Episode list renders differently based on `groupByPodcast`:

**OFF:** Flat list sorted by `publishedAt` (ascending or descending). Same as v1.

**ON:** Episodes rendered in podcast order (per `podcastSortType`), with each podcast's episodes grouped consecutively. No section headers -- the podcast artwork on each episode row provides visual context.

## Migration

### Isar schema migration

- `Station.publishedWithinDays` removed, `Station.defaultEpisodeLimit` added (default: 3)
- `Station.groupByPodcast` added (default: false)
- `Station.podcastSortType` added (default: 'manual')
- `StationPodcast.episodeLimit` added (default: null)
- `StationPodcast.sortOrder` added (default: 0)

Existing stations get `defaultEpisodeLimit = 3` as a reasonable default. `sortOrder` for existing StationPodcast entries is assigned based on current `addedAt` order.

No data loss -- the time-span filter is simply replaced.

### Reconciler

Full reconciliation runs for all stations on first launch after migration to populate StationEpisode with count-based results.

## Test Strategy

| Layer | Target | Approach |
|-------|--------|----------|
| Model | New fields serialization, default values | Unit test |
| Reconciler | Count-based limiting per podcast, default vs override, null (all), interaction with attribute filters | Unit test |
| Reconciler | Grouped ordering (subscribe/name/manual), flat ordering | Unit test |
| Controller | Episode limit picker state, podcast sort state, reorder mode, manual sort preservation | Unit test |
| Controller | Podcast picker modal: search filter, sort, selection toggle, cancel/done | Unit test |
| Widget | Inline expand/collapse, chevron direction, chip selector | Widget test |
| Widget | Reorder mode enter/exit, drag handle visibility | Widget test |
| Widget | Picker modal: search, sort, checkbox states | Widget test |
| Integration | Create station with per-podcast limits -> verify episode counts -> change grouping -> verify order | Integration test |
| Migration | Existing stations get correct defaults, sortOrder assigned from addedAt | Unit test |

Coverage target: 80%+
