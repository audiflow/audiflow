# Sticky Year Header for Episode Listing

## Summary

Replace the accordion-style `ExpansionTile` year grouping in all episode listing views with sliver-based sticky year headers. All episodes under each year are visible by default (no expand/collapse). Tapping a sticky header opens a bottom sheet for jumping to any year.

## Scope

Three call sites affected:

1. `smart_playlist_episodes_screen.dart` - `_buildYearGroupedList`
2. `podcast_detail_screen.dart` - `_buildYearGroupedList` (inline smart playlist)
3. `podcast_detail_screen.dart` - `_buildYearGroupedEpisodeList` (regular episodes)

Not affected: sub-category grouping, flat episode lists, episode tile widgets.

## Architecture

### Sliver Structure (per year group)

```
SliverPersistentHeader (pinned: true)  -> "2025"
SliverList.builder(episodes for 2025)  -> Episode tiles

SliverPersistentHeader (pinned: true)  -> "2024"
SliverList.builder(episodes for 2024)  -> Episode tiles
```

Flutter's native sliver pinning handles the sticky behavior: the next year header pushes the previous one off screen as the user scrolls.

### Visibility Rules

Year headers appear only when **both** conditions are met:
- Year grouping is enabled for the podcast/playlist
- There are 2 or more distinct years

Otherwise, render a flat `SliverList.builder` with no headers.

Since headers only appear when 2+ years exist, every visible header is tappable (no conditional tap logic needed).

## New Widgets

### `YearGroupedEpisodeSliverList<T>` (audiflow_ui)

**Path:** `packages/audiflow_ui/lib/src/widgets/lists/year_grouped_episode_sliver_list.dart`

Generic widget that accepts:
- `Map<int, List<T>> episodesByYear` - pre-grouped data
- `Widget Function(BuildContext, T) itemBuilder` - renders each episode tile
- `List<int> sortedYears` - year order (respects sort preference)
- `ScrollController controller` - shared with parent CustomScrollView
- `bool yearGroupingEnabled` - from podcast/playlist config

Returns a `List<Widget>` of slivers (to be spread into the parent `CustomScrollView.slivers`).

Rendering logic:
- If `!yearGroupingEnabled` or `sortedYears.length < 2`: single flat `SliverList.builder`
- Otherwise: alternating `SliverPersistentHeader` + `SliverList.builder` pairs

### `StickyYearHeaderDelegate` (audiflow_ui, private)

**Path:** `packages/audiflow_ui/lib/src/widgets/lists/sticky_year_header_delegate.dart`

A `SliverPersistentHeaderDelegate` with fixed height (`minExtent == maxExtent`, non-collapsing). Renders the year label with a subtle dropdown icon. On tap opens `YearPickerBottomSheet`.

### `YearPickerBottomSheet` (audiflow_ui)

**Path:** `packages/audiflow_ui/lib/src/widgets/lists/year_picker_bottom_sheet.dart`

A `showModalBottomSheet` with a list of year tiles. Returns the selected year. The parent widget computes the scroll target.

## Scroll-to-Year Behavior

### Offset Calculation

```
offset(year) = sum of (headerHeight + episodeCount * tileHeight)
               for each preceding year group
```

Both `headerHeight` and `tileHeight` are fixed constants declared by the delegate and tile widgets.

### Jump vs Animate Threshold

Count episodes between the current scroll position and the target year:
- Fewer than 50 episodes: `controller.animateTo(offset, duration: 300ms, curve: Curves.easeInOut)`
- 50 or more episodes: `controller.jumpTo(offset)`

### Edge Case

If the target year is the last group and shorter than the viewport, `ScrollController` clamps to `maxScrollExtent`. The header still pins correctly.

## Integration

Each call site:
1. Groups episodes by year (existing logic, unchanged)
2. Provides an `itemBuilder` for the appropriate tile type
3. Passes the `ScrollController` from the parent `CustomScrollView`

### Deleted Code

- All `ExpansionTile` + `PageStorageKey` year-grouping code in the three locations
- The `SliverList(delegate: SliverChildListDelegate([...]))` wrapping pattern

### Unchanged Code

- Episode tile widgets (`SmartPlaylistEpisodeListTile`, `EpisodeListTile`)
- Year grouping logic in controllers
- Sub-category grouping
- Progress data passing pattern

## File Placement

| File | Package | Purpose |
|------|---------|---------|
| `widgets/lists/year_grouped_episode_sliver_list.dart` | audiflow_ui | Main reusable widget |
| `widgets/lists/sticky_year_header_delegate.dart` | audiflow_ui | Pinned header delegate |
| `widgets/lists/year_picker_bottom_sheet.dart` | audiflow_ui | Year selection bottom sheet |
