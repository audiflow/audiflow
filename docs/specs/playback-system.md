# Playback System Specification

Status: Implemented

## Audio Player Architecture

### Core Abstraction

`AudioPlayerService` wraps `just_audio` with Riverpod state management. The service is the sole interface to the underlying `AudioPlayer` -- no other component touches `just_audio` directly.

```
PlayerScreen / MiniPlayer (audiflow_app)
        |
AudioPlayerController + NowPlayingController (audiflow_domain)
        |
    just_audio AudioPlayer
```

### Providers

| Provider | Type | KeepAlive | Purpose |
|----------|------|-----------|---------|
| `audioPlayerProvider` | `AudioPlayer` | Yes | Singleton AudioPlayer instance |
| `playbackProgressStreamProvider` | `Stream<PlaybackProgress>` | Yes | Combined position/duration/buffered stream |
| `playbackProgressProvider` | `PlaybackProgress?` | No | Current progress snapshot |
| `audioPlayerControllerProvider` | `PlaybackState` | Yes | Main controller with playback state |
| `nowPlayingControllerProvider` | `NowPlayingInfo?` | Yes | Current episode metadata |

### PlaybackState

`@freezed` sealed class with five states: `idle`, `loading(episodeUrl)`, `playing(episodeUrl)`, `paused(episodeUrl)`, `error(message)`. Each content state carries `episodeUrl` for identity matching.

### PlaybackProgress

Tracks `position`, `duration`, `bufferedPosition` with computed `progress` getter (0.0 to 1.0).

### NowPlayingInfo

`@freezed` model with `episodeUrl`, `episodeTitle`, `podcastTitle`, `artworkUrl`, and optional full `Episode` object.

### Playback Source Resolution

`play()` checks `DownloadRepository` for a completed local file before falling back to the remote URL. The UI is unaware of the source.

## Seek and Skip

All seek operations clamp position between zero and duration. Operations are no-ops when no audio is loaded or duration is unknown. Skip defaults to 30 seconds.

### UI Flicker Prevention

During seek/skip, `AudioPlayer` briefly enters buffering state. The UI preserves pre-seek visual state using local flags (`_isSeeking`, `_wasPlayingBeforeSeek`) with a 150ms stabilization delay after seek completion.

### Seekbar Drag

Local drag state (`_isDragging`, `_dragValue`) prevents the slider from fighting between drag position and real-time playback position. Actual seek is performed only on drag end.

## Mini Player

### Widget Hierarchy

```
ScaffoldWithNavBar
  bottomNavigationBar: Column
    AnimatedMiniPlayer        -- SlideTransition, 300ms, easeOutCubic
      MiniPlayer              -- 64px height, Material elevation 8
        MiniPlayerProgressBar -- 2px LinearProgressIndicator at top
        Row: Artwork, Title/Subtitle, Play/Pause button
    NavigationBar
```

Reusable sub-widgets (`MiniPlayerArtwork`, `MiniPlayerProgressBar`) in `audiflow_ui`; feature-specific assembly in `audiflow_app`.

## Play Queue

### Two Queue Types

- **Manual Queue**: User-curated via "Play Next" (front) and "Play Later" (end). No item limit. Higher playback priority.
- **Adhoc Queue**: Auto-generated when playing from an episode list. Maximum 100 episodes. Plays after manual queue is exhausted.

**Playback priority**: Now Playing -> Manual Queue -> Adhoc Queue.

### Data Model

**QueueItems** Drift table: `id`, `episodeId` (FK), `position` (sparse int: 0, 10, 20...), `isAdhoc`, `sourceContext`, `addedAt`.

**PlaybackQueue** (`@freezed`): In-memory state with `currentEpisode`, `manualItems`, `adhocItems`. Computed: `totalCount`, `hasItems`, `nextItem`.

### Key Behavioral Decisions

- Duplicate episodes allowed in queue
- Adhoc queue creation replaces entire queue (confirmation dialog only when manual items exist)
- On playback completion: auto-remove finished episode, load next (manual priority), start playback
- Full persistence across app restarts via Drift
- Reorder via sparse position values with midpoint calculation
- "Clear" uses double-tap confirmation (first tap shows "Confirm?", 3-second window)
- "Add to Queue" button: tap for Play Later, long-press for Play Next (haptic feedback)

### Auto-Play Next

On playback completion, `AudioPlayerController` calls `QueueService.getNextAndRemoveCurrent()`. If an episode is returned, playback starts automatically. If null, playback stops.

## Download System

### Three-Layer Architecture

1. **DownloadFileService**: Low-level HTTP via Dio with progress callbacks, cancel tokens, resume support via `Range` headers
2. **DownloadQueueService**: Sequential queue processor. One active download at a time. Smart retry with exponential backoff (5s, 15s, 45s, 135s, 405s; max 5 attempts)
3. **DownloadService**: High-level API (`downloadEpisode`, `downloadSeason`, `pause`, `resume`, `cancel`, `delete`, `validateDownloads`)

### Data Model

**DownloadTasks** Drift table: `id`, `episodeId` (unique FK), `audioUrl`, `localPath`, `totalBytes`, `downloadedBytes`, `status` (int enum 0-5), `wifiOnly`, `retryCount`, `lastError`, `createdAt`, `completedAt`.

**DownloadStatus** sealed class: `pending`, `downloading`, `paused`, `completed`, `failed`, `cancelled`.

### File Storage

Path: `{documents}/downloads/{episodeId}_{sanitized_title}.{ext}`. App-private directories (no storage permissions).

### Network Behavior

- WiFi-only setting respected per task
- On network restoration: resume interrupted downloads, retry failed tasks
- On WiFi after cellular: start eligible WiFi-only pending tasks

### Error Handling

Custom `DownloadException` with typed variants: `networkUnavailable`, `serverError`, `insufficientStorage`, `fileWriteError`, `cancelled`, `unknown`.

## File Locations

| Component | Path |
|-----------|------|
| AudioPlayerController | `audiflow_domain/.../player/services/audio_player_service.dart` |
| PlaybackState | `audiflow_domain/.../player/models/playback_state.dart` |
| PlaybackProgress | `audiflow_domain/.../player/models/playback_progress.dart` |
| NowPlayingInfo | `audiflow_domain/.../player/models/now_playing_info.dart` |
| QueueService | `audiflow_domain/.../queue/services/queue_service.dart` |
| DownloadService | `audiflow_domain/.../download/services/download_service.dart` |
| PlayerScreen | `audiflow_app/.../player/presentation/screens/player_screen.dart` |
| MiniPlayer | `audiflow_app/.../player/presentation/widgets/mini_player.dart` |
| QueueScreen | `audiflow_app/.../queue/presentation/screens/queue_screen.dart` |
