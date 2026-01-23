# Episode Tracking Feature Design

## Overview

Track episode playback progress with automatic completion detection and manual override. Provides "Continue Listening" functionality and episode filtering.

## Requirements

- **Hybrid tracking**: Auto-mark episodes as completed at 95% progress; users can manually toggle anytime
- **Progress persistence**: Save position, timestamps (first/last played), and play count
- **UI surfaces**: Episode list indicators + Library "Continue Listening" section
- **Performance**: Integer foreign keys, efficient queries for large libraries

## Data Model

### Episodes Table

Persisted when podcast feed is fetched. Upserted on feed refresh.

```dart
class Episodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get podcastId => integer().references(Podcasts, #id)();

  // Unique identifier from RSS (for upsert matching)
  TextColumn get guid => text()();

  // Metadata
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get audioUrl => text()();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  TextColumn get imageUrl => text().nullable()();

  // For ordering
  IntColumn get episodeNumber => integer().nullable()();
  IntColumn get seasonNumber => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [{podcastId, guid}];
}
```

### PlaybackHistories Table

Tracks playback progress per episode.

```dart
class PlaybackHistories extends Table {
  // Foreign key to Episodes table (integer, fast lookups)
  IntColumn get episodeId => integer().references(Episodes, #id)();

  // Progress tracking
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().nullable()();

  // Completion (null = not completed, non-null = completed at timestamp)
  DateTimeColumn get completedAt => dateTime().nullable()();

  // History timestamps
  DateTimeColumn get firstPlayedAt => dateTime().nullable()();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();

  // Statistics
  IntColumn get playCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {episodeId};
}
```

## Repository Layer

### PlaybackHistoryRepository

```dart
abstract class PlaybackHistoryRepository {
  // Core operations
  Future<PlaybackHistory?> getByEpisodeId(int episodeId);
  Future<void> saveProgress(int episodeId, int positionMs, int? durationMs);
  Future<void> markCompleted(int episodeId);
  Future<void> markIncomplete(int episodeId);

  // Queries for UI
  Stream<List<PlaybackHistory>> watchInProgress();  // For "Continue Listening"
  Future<bool> isCompleted(int episodeId);
  Future<double?> getProgressPercent(int episodeId);
}
```

## Service Layer

### PlaybackHistoryService

Handles auto-completion logic and progress saving throttling.

```dart
class PlaybackHistoryService {
  static const completionThreshold = 0.95;
  static const saveIntervalSeconds = 15;

  int _lastSavedPositionMs = 0;

  Future<void> onProgressUpdate(int episodeId, PlaybackProgress progress) async {
    final positionMs = progress.position.inMilliseconds;
    final durationMs = progress.duration.inMilliseconds;

    // Throttle saves to every 15 seconds
    final delta = (positionMs - _lastSavedPositionMs).abs();
    if (delta < saveIntervalSeconds * 1000) return;

    _lastSavedPositionMs = positionMs;
    await repository.saveProgress(episodeId, positionMs, durationMs);

    // Auto-complete check
    if (0 < durationMs) {
      final progress = positionMs / durationMs;
      if (completionThreshold <= progress) {
        await repository.markCompletedIfNot(episodeId);
      }
    }
  }
}
```

**Save triggers:**
- Every 15 seconds during playback
- On playback pause
- On app going to background
- On episode switch

**Play count logic:**
- Increment `playCount` only when starting from beginning (position < 5 seconds)
- Set `firstPlayedAt` on first progress update for an episode

## UI Design

### Episode List Tile Indicators

| State | Display |
|-------|---------|
| Unplayed | No indicator |
| In progress | "18 min left" text |
| Completed | Checkmark icon, dimmed appearance |

### Filter Controls

Chip row at top of podcast detail episode list:
- `All` | `Unplayed` | `In Progress`

### Manual Toggle

Long-press or swipe on episode tile reveals:
- "Mark as played" (for unplayed/in-progress episodes)
- "Mark as unplayed" (for completed episodes)

### Library "Continue Listening" Section

Horizontal scrolling list at top of Library screen:

```
┌─────────────────────────────────────────┐
│  Continue Listening                     │
├─────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐     │
│ │[Artwork]│ │[Artwork]│ │[Artwork]│ →   │
│ │ Ep name │ │ Ep name │ │ Ep name │     │
│ │ 18m left│ │ 6m left │ │ 32m left│     │
│ └─────────┘ └─────────┘ └─────────┘     │
└─────────────────────────────────────────┘
```

**Behavior:**
- Query: `positionMs > 0 AND completedAt IS NULL`
- Sort: `lastPlayedAt DESC`
- Max items: 10
- Tap: Start playback from saved position
- Hidden when empty

## Integration Points

### Feed Fetch Flow

1. User opens podcast detail
2. Feed fetched from RSS
3. Episodes upserted to `Episodes` table (match on `podcastId + guid`)
4. Existing episode IDs preserved for playback history references

### Playback Flow

1. User taps play on episode
2. `AudioPlayerController` starts playback
3. Progress stream emits updates
4. `PlaybackHistoryService.onProgressUpdate()` called
5. Progress saved (throttled), auto-completion checked

## File Locations

| Component | Path |
|-----------|------|
| Episodes table | `audiflow_domain/lib/src/features/feed/models/episode.dart` |
| PlaybackHistories table | `audiflow_domain/lib/src/features/player/models/playback_history.dart` |
| PlaybackHistoryRepository | `audiflow_domain/lib/src/features/player/repositories/playback_history_repository.dart` |
| PlaybackHistoryService | `audiflow_domain/lib/src/features/player/services/playback_history_service.dart` |
| EpisodeListTile (updated) | `audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart` |
| Continue Listening widget | `audiflow_app/lib/features/library/presentation/widgets/continue_listening_section.dart` |
| Episode filter chips | `audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_filter_chips.dart` |
