# Play Queue Feature Design

## Overview

A play queue feature for Audiflow, inspired by Apple Podcasts. Users can manually curate their listening queue and automatically generate queues by playing from episode lists.

## Core Concepts

### Two Queue Types

**Manual Queue**
- User-curated via "Play Next" and "Play Later" actions
- No item limit
- Higher playback priority than adhoc queue

**Adhoc Queue**
- Auto-generated when playing from an episode list
- Maximum 100 episodes
- Episodes ordered by episode number ascending (toward latest), regardless of screen sort order
- Plays after manual queue is exhausted

### Playback Priority

```
1. Now Playing (current episode)
2. Manual Queue Items
3. Adhoc Queue Items
```

## Behaviors

### Adding to Manual Queue

| Action | Behavior |
|--------|----------|
| Tap "Add to Queue" | Play Later - insert at end of manual queue |
| Long-press "Add to Queue" | Play Next - insert at position 0 |

- Available on episode list items (overflow menu) and episode detail screens
- Duplicate episodes allowed
- Brief toast confirmation: "Added to queue" or "Playing next"

### Adhoc Queue Creation

When user taps play on an episode in a list view:

1. If manual queue has items → show confirmation dialog: "Replace your queue?"
2. If no manual queue → proceed silently
3. On proceed:
   - Clear entire queue (manual + adhoc)
   - Start playing tapped episode
   - Auto-queue subsequent episodes by episode number ascending
   - Maximum 100 adhoc items
   - Store source context (e.g., "Season 2") for display

### Playback Completion

1. Remove finished episode from queue automatically
2. Load next item (manual queue first, then adhoc)
3. Start playback automatically (continuous listening)
4. If no more items → stop playback, clear Now Playing

### Queue Persistence

- Full persistence across app restarts
- Queue items stored in Drift database
- Playback position saved in PlaybackHistories table (existing)
- On app launch, queue restored and ready for playback

## User Interface

### Queue Access

Dedicated bottom navigation tab - always one tap away.

### Queue Screen Layout

```
┌─────────────────────────────────┐
│ Queue                    Clear  │  Header with Clear button
├─────────────────────────────────┤
│ NOW PLAYING                     │
│ ┌─────────────────────────────┐ │
│ │  Episode Title              │ │  Visually distinct card
│ │  Podcast Name               │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ UP NEXT                         │  Section (if items exist)
│ ┌─────────────────────────────┐ │
│ │ ≡ Episode Title             │ │  Drag handle left
│ │   Podcast • 45 min          │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ ≡ Episode Title         ◦   │ │  ◦ = subtle adhoc indicator
│ │   Podcast • 32 min          │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### Interactions

| Gesture | Action |
|---------|--------|
| Long press + drag | Reorder item |
| Swipe left | Remove from queue |
| Tap item | Start playing that episode (skips ahead) |
| Tap Clear | Confirmation appears in same spot for double-tap |

### Visual Indicators

- **Now Playing**: Distinct card at top, separated from queue list
- **Manual items**: Standard appearance
- **Adhoc items**: Subtle indicator (small badge or dimmer style)

### Empty State

Centered message: "Your queue is empty" with subtle guidance text.

### Clear Queue Confirmation

- "Clear" button in header
- Confirmation button appears in same position
- Enables quick double-tap to clear when intentional
- Single tap + wait requires deliberate second tap

## Data Model

### QueueItems Table (Drift)

```sql
CREATE TABLE queue_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  episode_id INTEGER NOT NULL REFERENCES episodes(id),
  position INTEGER NOT NULL,
  is_adhoc INTEGER NOT NULL DEFAULT 0,
  source_context TEXT,
  added_at INTEGER NOT NULL
);

CREATE INDEX idx_queue_items_position ON queue_items(position);
```

| Column | Type | Description |
|--------|------|-------------|
| id | int | Primary key |
| episode_id | int | FK to Episodes table |
| position | int | Ordering (sparse: 0, 10, 20...) |
| is_adhoc | bool | true = adhoc, false = manual |
| source_context | String? | e.g., "Season 2" for adhoc items |
| added_at | DateTime | When added to queue |

### PlaybackQueue (@freezed)

```dart
@freezed
class PlaybackQueue with _$PlaybackQueue {
  const factory PlaybackQueue({
    Episode? currentEpisode,
    @Default([]) List<QueueItemWithEpisode> manualItems,
    @Default([]) List<QueueItemWithEpisode> adhocItems,
    String? adhocSourceContext,
  }) = _PlaybackQueue;
}
```

## Package Structure

### audiflow_domain

```
lib/src/features/queue/
├── models/
│   ├── queue_item.dart              # Drift Table definition
│   └── playback_queue.dart          # @freezed in-memory state
├── repositories/
│   ├── queue_repository.dart        # Interface
│   └── queue_repository_impl.dart   # Implementation
├── datasources/
│   └── local/
│       └── queue_local_datasource.dart
├── services/
│   └── queue_service.dart           # @riverpod high-level API
└── providers/
    └── queue_providers.dart         # Stream providers
```

### audiflow_app

```
lib/features/queue/
└── presentation/
    ├── controllers/
    │   └── queue_controller.dart
    ├── screens/
    │   └── queue_screen.dart
    └── widgets/
        ├── queue_list_tile.dart
        ├── now_playing_card.dart
        └── clear_queue_button.dart
```

### audiflow_ui

```
lib/src/widgets/queue/
└── add_to_queue_button.dart
```

## Integration Points

### Player Integration

```dart
// In AudioPlayerController
void onPlaybackComplete() {
  final nextEpisode = queueService.getNextAndRemoveCurrent();
  if (nextEpisode != null) {
    loadAndPlay(nextEpisode);
  } else {
    stop();
    nowPlayingController.clear();
  }
}
```

### Bottom Navigation

Add Queue tab to existing navigation:
- Search | Library | **Queue** | Settings
- Or: Search | **Queue** | Library | Settings (based on priority)

### Episode List Integration

Detect play action from list context to trigger adhoc queue creation.

## Decision Summary

| Aspect | Decision |
|--------|----------|
| Queue types | Manual (unlimited) + Adhoc (max 100) |
| Play Next / Play Later | Both via tap and long-press |
| Auto-play | Yes, continuous playback |
| After completion | Auto-remove from queue |
| Persistence | Full persistence across restarts |
| Reorder | Drag and drop |
| Remove | Swipe left |
| Access | Dedicated bottom navigation tab |
| Add from | Episode lists + detail screens |
| Duplicates | Allowed |
| Clear queue | Confirmation with double-tap positioning |
| Adhoc trigger | Play from episode list replaces queue |
| Adhoc confirmation | Only when manual queue exists |
| Adhoc order | Episode# ascending (toward latest) |
| Visual distinction | Now Playing distinct, adhoc has subtle indicator |
