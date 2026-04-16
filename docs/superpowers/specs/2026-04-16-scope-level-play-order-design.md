# Scope-Level Play Order Preference

## Problem

The app has a single global preference for adhoc queue adding order (`oldestFirst` / `asDisplayed`). Users want per-podcast and per-playlist granularity so that, for example, COTEN's "regular" playlist can use oldest-first while "short" uses display order.

## Design

### AutoPlayOrder Enum Extension

Add `defaultOrder` to the existing `AutoPlayOrder` enum in `audiflow_core`:

```dart
enum AutoPlayOrder {
  defaultOrder,  // inherit from parent scope / global
  oldestFirst,
  asDisplayed,
}
```

`defaultOrder` means "no override at this level; resolve from parent."

### Data Model

#### New Isar Collections (audiflow_domain)

**`SmartPlaylistUserPreference`** -- per-playlist user overrides, separate from config-synced `SmartPlaylistEntity`.

- Indexed by `(podcastId, playlistId)` (unique composite)
- Fields: `String? autoPlayOrder`

**`SmartPlaylistGroupUserPreference`** -- per-group user overrides, separate from config-synced `SmartPlaylistGroupEntity`.

- Indexed by `(podcastId, playlistId, groupId)` (unique composite)
- Fields: `String? autoPlayOrder`

These collections store only user-chosen preferences. They are never touched by config re-sync, avoiding the concern of upstream config overwrites.

#### Extend Existing Collection

**`PodcastViewPreference`** -- add `String? autoPlayOrder` field (null = default/inherit).

### Cascade Resolution

Two independent paths, each terminating at the global setting:

**Path A -- Podcast episode list:**

```
PodcastViewPreference.autoPlayOrder  -->  global AppSettings.autoPlayOrder
```

**Path B -- Smart playlist group episodes:**

```
SmartPlaylistGroupUserPreference.autoPlayOrder
  -->  SmartPlaylistUserPreference.autoPlayOrder
  -->  global AppSettings.autoPlayOrder
```

Resolution: walk up the chain; the first non-null, non-`defaultOrder` value wins. If all levels are default/null, use the global setting (which is never null -- it defaults to `oldestFirst`).

### Repository Layer

New `PlayOrderPreferenceRepository` interface + implementation:

```dart
abstract interface class PlayOrderPreferenceRepository {
  /// Per-podcast override (path A).
  AutoPlayOrder? getPodcastPlayOrder(int podcastId);
  Future<void> setPodcastPlayOrder(int podcastId, AutoPlayOrder? order);

  /// Per-playlist override (path B, playlist level).
  AutoPlayOrder? getPlaylistPlayOrder(int podcastId, String playlistId);
  Future<void> setPlaylistPlayOrder(int podcastId, String playlistId, AutoPlayOrder? order);

  /// Per-group override (path B, group level).
  AutoPlayOrder? getGroupPlayOrder(int podcastId, String playlistId, String groupId);
  Future<void> setGroupPlayOrder(int podcastId, String playlistId, String groupId, AutoPlayOrder? order);

  /// Resolve effective order for podcast episode list (path A).
  AutoPlayOrder resolveForPodcast(int podcastId);

  /// Resolve effective order for playlist group (path B).
  AutoPlayOrder resolveForGroup(int podcastId, String playlistId, String groupId);

  /// Resolve effective order for playlist level (path B, stopping at playlist).
  AutoPlayOrder resolveForPlaylist(int podcastId, String playlistId);
}
```

Setting `null` or `defaultOrder` clears the override at that level (deletes the Isar record or nulls the field).

### Queue Service Change

`QueueService.createAdhocQueue()` currently reads the global preference directly:

```dart
if (forceDisplayOrder ||
    _settingsRepository.getAutoPlayOrder() == AutoPlayOrder.asDisplayed) {
```

Change: replace `forceDisplayOrder: bool` with `effectiveOrder: AutoPlayOrder?`. When non-null, use it directly instead of reading the global preference. Callers resolve the effective order via `PlayOrderPreferenceRepository` before calling.

Keep backward compatibility: when `effectiveOrder` is null, fall back to the global preference (existing behavior for contexts without scope-level preferences, e.g., stations).

### UI Changes

#### All Three Screens: AppBar Pattern

Replace `SearchableAppBar` with a plain `AppBar` containing:
- Title text
- `PopupMenuButton` with existing actions + new "Play order" entry

Search `TextField` moves to a `SliverToBoxAdapter` below the appbar in the `CustomScrollView` body (matching the existing pattern in `SmartPlaylistGroupEpisodesScreen`).

Affected screens:
1. **`PodcastDetailScreen`** -- currently uses `SearchableAppBar`; switch to plain `AppBar` + popup menu
2. **Smart playlist screen** (playlist-level view) -- add popup menu with play order entry
3. **`SmartPlaylistGroupEpisodesScreen`** -- add play order entry to existing popup menu

#### Bottom Sheet Picker

Tapping "Play order" opens a modal bottom sheet with three radio options:

1. **Default** (shows resolved parent value in parentheses, e.g., "Default (oldest first)")
2. **Oldest first**
3. **As displayed**

The currently active option is pre-selected. Selecting "Default" clears the override at that scope level.

The bottom sheet widget should be a shared widget (in `audiflow_app` or `audiflow_ui` if reusable) since it appears on three screens with the same structure.

### Passing Resolved Order to Queue

Each episode list tile (`EpisodeListTile`, `SmartPlaylistEpisodeListTile`) currently receives `siblingEpisodeIds` and optionally `forceDisplayOrder`. Change:

- `EpisodeListTile` (podcast episode list): resolve via `resolveForPodcast(podcastId)` and pass as `effectiveOrder`
- `SmartPlaylistEpisodeListTile` (group episodes): resolve via `resolveForGroup(podcastId, playlistId, groupId)` and pass as `effectiveOrder`

### Package Responsibilities

| Package | Changes |
|---------|---------|
| `audiflow_core` | Add `defaultOrder` to `AutoPlayOrder` enum |
| `audiflow_domain` | New `SmartPlaylistUserPreference` + `SmartPlaylistGroupUserPreference` Isar collections; new `PlayOrderPreferenceRepository` interface + impl; extend `PodcastViewPreference` with `autoPlayOrder` field; register new collections in database provider |
| `audiflow_app` | UI changes on 3 screens (AppBar swap, search relocation, popup menu); bottom sheet picker widget; wire resolved order to episode list tiles and queue service calls |
| `audiflow_ui` | Extract shared bottom sheet picker if needed (optional -- can stay in `audiflow_app` if only used there) |

### Out of Scope

- Changing the global preference UI in settings (stays as-is)
- Per-station play order (stations already use `forceDisplayOrder: true`)
- Persisting search query state across screen revisits
