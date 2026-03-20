# Station Feature Design

## Overview

Stations are user-created collections of podcasts with condition-based episode filtering. They provide a way to group subscribed podcasts by topic (e.g., "News", "Tech") and automatically surface relevant episodes based on configurable filters.

Key differentiator from Queue: Stations collect episodes via conditions only (no manual episode adds). Queue remains the sole manual episode collection.

## Requirements

### Core
- Users create named stations and add subscribed podcasts
- Episodes are collected automatically based on filter conditions
- Each station has configurable playback order
- Stations appear in the Library tab as a vertical list section
- Maximum 15 stations per user

### Filters

**Playback state (exclusive selection, one only):**

| Filter | Condition |
|--------|-----------|
| `all` | No filtering (default) |
| `unplayed` | PlaybackHistory missing or (`completedAt == null` and `positionMs == 0`) |
| `inProgress` | PlaybackHistory exists and `completedAt == null` and `0 < positionMs` |

**Attribute filters (AND combination, multiple allowed):**

| Filter | Parameter | Condition |
|--------|-----------|-----------|
| `downloaded` | — | DownloadTask status equals `DownloadStatus.completed` |
| `favorited` | — | Episode.isFavorited == true |
| `duration` | operator (shorterThan/longerThan), minutes | Episode.durationMs compared to threshold |
| `publishedWithin` | days (7/14/30/90) | Episode.publishedAt within N days of now |

### Playback order (per station)
- `newest` — most recent first (default)
- `oldest` — oldest first

Note: `manual` ordering is deferred to backlog. Since episodes are dynamically resolved via filters, manual ordering requires snapshot semantics or a separate join table — complexity not justified for v1.

## Architecture

### Approach: Pure Local (Isar Only)

Stations are fully local Isar collections. No external config involvement, no cross-repo coordination. Aligns with existing patterns (Subscription, QueueItem).

**Rationale:**
- Simple — no cross-repo schema coordination required
- Instant CRUD, offline-first by default
- Fully within audiflow repo scope
- Export/import is a natural v2 enhancement

### Package placement

Following the existing architecture rules:

| Component | Package | Path |
|-----------|---------|------|
| Station, StationPodcast models | `audiflow_domain` | `lib/src/features/station/models/` |
| StationRepository | `audiflow_domain` | `lib/src/features/station/repositories/` |
| StationEpisodeResolver | `audiflow_domain` | `lib/src/features/station/services/` |
| StationDetailScreen, StationEditScreen | `audiflow_app` | `lib/features/station/presentation/` |
| SubscriptionsListScreen | `audiflow_app` | `lib/features/library/presentation/screens/` |
| Station widgets | `audiflow_app` | `lib/features/station/presentation/widgets/` (move to `audiflow_ui` only if reused across 2+ features) |

## Data Model

### Station (Isar collection)

```
@collection
Station:
  id: Id (Isar auto)
  name: String (required, max 50 chars)
  sortOrder: int (display ordering)
  episodeSortType: String (newest / oldest)
  createdAt: DateTime
  updatedAt: DateTime
```

### StationPodcast (Isar collection)

```
@collection
StationPodcast:
  id: Id (Isar auto)
  stationId: int (index)
  podcastId: int (Subscription.id, local reference)
  addedAt: DateTime

  Composite unique index: (stationId, podcastId)
```

`podcastId` references `Subscription.id` (Isar local ID). For future export/import, the export process joins with Subscription to include `feedUrl` and `itunesId` for cross-device matching.

### Station filter fields (embedded on Station)

The `Station` collection holds filter configuration as embedded objects:

```
Station (filter fields):
  playbackState: String = 'all' (all / unplayed / inProgress)
  filterDownloaded: bool = false
  filterFavorited: bool = false
  durationFilter: StationDurationFilter? (nullable, absent = no filter)
  publishedWithinDays: int? (nullable: 7 / 14 / 30 / 90, absent = no filter)

@embedded
StationDurationFilter:
  durationOperator: String (shorterThan / longerThan)
  durationMinutes: int
```

Flat fields are used for simple boolean/enum filters. Only `StationDurationFilter` needs a separate embedded object (two fields). This avoids unnecessary abstraction layers.

### Episode model change

Add to existing `Episode` collection:

```
+ isFavorited: bool = false
+ favoritedAt: DateTime? (for sort ordering in future Favorites station)
```

`isCompleted` / `completedAt` already exists in `PlaybackHistory` collection and is accessed via `PlaybackHistoryRepository.isCompleted()`.

### Prerequisites

The `isFavorited` / `favoritedAt` fields and the favorite toggle UI (episode list tile, episode detail) must land before or alongside Station filters that use the `favorited` condition. The toggle can be implemented as a standalone prerequisite PR.

### Cascade delete behavior

Isar has no foreign key constraints. When a `Subscription` is deleted:
- `StationPodcast` entries referencing the deleted `podcastId` become orphaned
- `StationEpisodeResolver` must gracefully skip podcasts with no matching Subscription
- A cleanup job (or lazy cleanup on station access) should remove orphaned `StationPodcast` entries

## Repository Layer

### StationRepository (interface)

```dart
abstract class StationRepository {
  Stream<List<Station>> watchAll();
  Future<Station?> findById(int id);
  Future<Station> create(Station station);
  Future<void> update(Station station);
  Future<void> delete(int id);
  Future<void> reorder(List<int> stationIds);
  Future<int> count();
}
```

### StationPodcastRepository (interface)

```dart
abstract class StationPodcastRepository {
  Stream<List<StationPodcast>> watchByStation(int stationId);
  Future<void> add(int stationId, int podcastId);
  Future<void> remove(int stationId, int podcastId);
  Future<void> removeAllForStation(int stationId);
}
```

## Station Episode System (Event-Driven)

### StationEpisode (Isar collection)

Materialized view of resolved episodes per station. The UI reads directly from this table.

```
@collection
StationEpisode:
  id: Id (Isar auto)
  stationId: int (index)
  episodeId: int
  sortKey: DateTime (publishedAt copy, for Isar-native sort + pagination)

  Composite unique index: (stationId, episodeId)
```

### Triggers

Events that cause the system to reconcile station episodes:

| Trigger | Source | Reconciliation |
|---------|--------|----------------|
| New episode from feed refresh | FeedSyncService | Differential — evaluate new episodes against each station's conditions |
| Playback state change | PlayerEvent (started, completed) | Differential — re-evaluate the affected episode across stations |
| Download state change | DownloadEvent (completed, deleted) | Differential — re-evaluate the affected episode across stations |
| Favorite toggled | Episode.isFavorited change | Differential — re-evaluate the affected episode across stations |
| Station filter changed | StationEditScreen save | Full — recalculate all episodes for the modified station |
| Station podcast added/removed | StationEditScreen save | Full — recalculate all episodes for the modified station |
| Subscription deleted | SubscriptionRepository.delete | Differential — remove all StationEpisode/StationPodcast entries for the deleted podcastId |

### StationReconciler (service)

Orchestrates episode resolution and StationEpisode table updates.

**Full reconciliation** (station config changes):
```
Input: Station (with filters) + StationPodcasts
  1. Fetch all Episodes from Isar for each podcastId
  2. Evaluate each episode against station conditions:
     Playback state (exclusive):
       - all: pass
       - unplayed: PlaybackHistory missing or (completedAt == null and positionMs == 0)
       - inProgress: PlaybackHistory exists and completedAt == null and 0 < positionMs
     Attribute filters (AND):
       - downloaded: DownloadTask status equals DownloadStatus.completed
       - favorited: Episode.isFavorited == true
       - duration: compare Episode.durationMs with threshold
       - publishedWithin: Episode.publishedAt within N days
  3. Diff against current StationEpisode rows for this station
  4. Batch insert new matches, batch delete removed matches
```

**Differential reconciliation** (individual episode events):
```
Input: episodeId + event type
  1. Find all stations whose podcasts include this episode's podcastId
  2. Evaluate the episode against each station's conditions
  3. For each station:
     - If matches and not in StationEpisode: insert
     - If no longer matches and in StationEpisode: delete
```

### StationEpisodeRepository (interface)

```dart
abstract class StationEpisodeRepository {
  Stream<List<StationEpisode>> watchByStation(int stationId, {int? limit, int? offset});
  Future<int> countByStation(int stationId);
  Future<void> reconcileFull(int stationId);
  Future<void> reconcileEpisode(int episodeId);
  Future<void> removeAllForStation(int stationId);
  Future<void> removeByPodcast(int podcastId);
}
```

### Integration with existing event system

The reconciler subscribes to existing Riverpod event streams:
- `playerEventStreamProvider` — playback state changes
- `downloadEventStreamProvider` — download state changes
- Feed sync completion events
- Episode favorite toggle events

Reconciliation runs in the background. The UI observes `watchByStation()` and updates reactively via Riverpod.

## UI Structure

### Library Tab (modified)

```
Library Tab
+-- STATIONS section (vertical list)
|   +-- Station 1 --> StationDetailScreen
|   +-- Station 2 --> StationDetailScreen
|   +-- ...
+-- Subscriptions > (group entry, always collapsed)
    +-- tap --> SubscriptionsListScreen
```

Station list items display:
- Mosaic of podcast artworks (2x2 grid)
- Station name
- Summary text (e.g., "4 podcasts, 12 episodes")

### New Screens

**StationDetailScreen** (`/station/:stationId`)
- Header with station name and edit button
- Filtered episode list
- Play all button
- Active filter indicators

**StationEditScreen** (`/station/:stationId/edit` or `/station/new`)
- Name field (max 50 chars)
- Podcast picker (from subscriptions, excluding isCached)
- Playback state filter (exclusive radio)
- Attribute filters (toggles/pickers)
- Playback order setting

**SubscriptionsListScreen** (`/subscriptions`)
- Existing subscription list (moved from Library tab inline to dedicated screen)

### Routing

```dart
/station/:stationId        --> StationDetailScreen
/station/:stationId/edit   --> StationEditScreen
/station/new               --> StationEditScreen (create mode)
/subscriptions             --> SubscriptionsListScreen
```

## Validation Rules

| Rule | Value |
|------|-------|
| Station name | Required, max 50 characters |
| Station limit | 15 per user |
| Podcast addition | Subscribed only (isCached == false) |
| Playback state filter | Exclusive selection (one at a time) |
| Attribute filters | Multiple allowed (AND combination) |

## Test Strategy

| Layer | Target | Approach |
|-------|--------|----------|
| Model | Station, StationPodcast, StationEpisode serialization, embedded filters | Unit test |
| Repository | CRUD, watch streams, limit enforcement, cascade delete, pagination | Unit test with Isar test instance |
| Reconciler (full) | Filter combinations, sort order, diff correctness, edge cases (empty station, no matches) | Unit test |
| Reconciler (differential) | Single episode add/remove across multiple stations, orphan cleanup | Unit test |
| Triggers | Event-to-reconciliation wiring, correct station targeting | Unit test |
| Controller | Create/edit/delete state transitions, validation errors | Unit test |
| Widget | Station list in Library, empty state, limit reached state | Widget test |
| Integration | Create station -> add podcasts -> trigger events -> verify StationEpisode updates -> UI reflects | Integration test |

Coverage target: 80%+

## Future Enhancements (Backlog)

### Default Station (Queue Fallback)
When the queue is empty, auto-play episodes from a designated station. Provides a "never-ending playback" experience bridging queue and station features.

### Export/Import
Export station definitions as JSON (joining with Subscription to include `feedUrl`, `itunesId` for cross-device matching). Import with 2-step matching: `itunesId` first, `feedUrl` hash fallback.

### PodcastIndex API Support
Evaluate PodcastIndex as an alternative/supplementary search API. Would add `podcastIndexId` to Subscription model for additional cross-device identifier coverage.

### Station-specific Playback Speed
Per-station playback speed setting (e.g., news at 1.5x, storytelling at 1.0x). Auto-switches when playing from a station.

### Manual Episode Ordering
Manual playback order within a station. Requires snapshot semantics or a join table to persist per-episode positions for dynamically resolved episode sets.

### Station Artwork Auto-generation
Mosaic/grid composition of podcast artworks within a station for visual identification.
