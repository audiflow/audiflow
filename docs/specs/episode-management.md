# Episode Management Specification

Status: Implemented

## Episode Tracking

### Progress Persistence

Playback position is saved periodically to the `PlaybackPositions` Drift table during playback. On resume, position is restored from the database.

### Auto-Completion

Episodes are automatically marked as completed when playback reaches 95% of total duration. This threshold accounts for episodes with trailing silence or credits.

### Manual Toggle

Users can manually mark episodes as played/unplayed regardless of actual playback position. This overrides the auto-completion state.

### Playback History

`PlaybackHistory` Drift table tracks: `episodeId`, `positionMs`, `durationMs`, `completedAt` (nullable), `lastPlayedAt`.

- `completedAt != null` = episode fully played
- `positionMs > 0 && completedAt == null` = in progress
- No entry or `positionMs == 0` = unplayed

### Continue Listening

A "Continue Listening" section surfaces episodes with in-progress playback state, ordered by `lastPlayedAt` descending.

## Episode List Optimization

### Performance Problem

Large podcast feeds (500+ episodes) caused UI jank during initial rendering due to synchronous RSS parsing and full-list database queries.

### Solutions Implemented

1. **Isolate-based RSS parsing**: Feed parsing runs in a separate isolate via `compute()`, keeping the UI thread responsive
2. **Early-stop optimization**: When displaying a filtered/limited view, parsing stops after enough episodes are collected rather than parsing the entire feed
3. **Batched database updates**: Episode metadata updates are batched into single transactions rather than individual inserts
4. **Lazy episode loading**: Only visible episodes are fully hydrated with playback state; off-screen episodes use lightweight placeholders

## Per-Podcast View Preferences

### Persisted Settings

Each subscribed podcast stores its own view preferences in the `PodcastViewPreferences` Drift table:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `podcastId` | int (PK) | - | FK to Subscriptions |
| `viewMode` | text | `episodes` | `episodes` or `seasons` (smart playlist) |
| `episodeFilter` | text | `all` | `all`, `unplayed`, or `inProgress` |
| `episodeSortOrder` | text | `desc` | `asc` or `desc` |

### Behavior

- Preferences load automatically when navigating to a podcast detail screen
- Changes persist immediately on user interaction (no "save" button)
- Default values used for unsubscribed podcasts or first-time views
- Stream-based: UI reacts to preference changes via Drift `watch()`

### UI Components

- **Segmented control**: Episodes / Seasons toggle (visible only when smart playlist resolvers succeed)
- **Filter chips**: All / Unplayed / In Progress
- **Sort bottom sheet**: Episode number ascending/descending
- **Sort button**: Icon in AppBar, available in both Episodes and Seasons views

### Architecture

```dart
// Domain layer
PodcastViewPreferenceRepository       // Interface + impl in audiflow_domain
PodcastViewPreferenceLocalDatasource  // Drift operations
PodcastViewPreferenceController       // @riverpod with per-podcastId build

// Presentation layer
EpisodeFilterChips                    // audiflow_app widget
EpisodeSortSheet                      // audiflow_app bottom sheet
SeasonViewToggle                      // audiflow_app widget
```

### Enum Placement

`EpisodeFilter`, `PodcastViewMode`, and `SortOrder` enums live in `audiflow_domain` (not `audiflow_app`) so that the repository layer can reference them without cross-package imports.
