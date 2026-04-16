# Playback Pipeline

## Definitions

- **AudioPlayer**: `just_audio` player instance, singleton for app lifetime
- **AudioService**: `audio_service` framework for background playback and system media controls
- **AudioSession**: `audio_session` for audio focus and interruption handling
- **NowPlayingInfo**: Freezed model holding current episode metadata for UI display

## Pipeline components

### Layer 1: Audio engine (just_audio)

`audioPlayerProvider` (keepAlive) provides a singleton `AudioPlayer` instance with `handleInterruptions: false` (delegated to audio_service).

Responsibilities:
- Load audio source from URL or local file path
- Play, pause, seek, stop
- Emit streams: position, duration, buffered position, speed, processing state

### Layer 2: Background service (audio_service)

Wraps the AudioPlayer to provide:
- Background playback continuation when app is backgrounded
- Lock screen / notification media controls (play, pause, skip, seek)
- Remote command center integration (iOS Control Center, Android notification)
- Audio focus management and phone call interruption handling

### Layer 3: State management (Riverpod)

| Provider | Type | Purpose |
|----------|------|---------|
| `audioPlayerProvider` | keepAlive sync | Singleton AudioPlayer |
| `audioPlayerControllerProvider` | keepAlive Notifier | Play/pause/seek/stop/setSpeed commands, fade-out-and-pause |
| `playbackProgressStreamProvider` | keepAlive Stream | Combined position + duration + buffered |
| `playbackSpeedProvider` | keepAlive Stream | Current speed from player |
| `nowPlayingControllerProvider` | keepAlive Notifier | Episode metadata for mini player and player screen |
| `playbackHistoryServiceProvider` | keepAlive | Records completed episodes |
| `sleepTimerControllerProvider` | keepAlive Notifier | Sleep timer state, countdown, and episode/chapter tracking |

### Layer 4: Presentation (audiflow_app + audiflow_ui)

- `MiniPlayer` (audiflow_app): Compact player in bottom navigation area
- `AnimatedMiniPlayer` (audiflow_app): Slide animation wrapper for mini player
- `PlayerScreen` (audiflow_app): Full-screen player with artwork, controls, progress
- `MiniPlayerArtwork` (audiflow_ui): Episode artwork with placeholder fallback
- `MiniPlayerProgressBar` (audiflow_ui): Thin progress indicator bar
- Sleep timer widgets (audiflow_app): `SleepTimerSheet`, `SleepTimerChip`, `SleepTimerIconButton`, `SleepTimerStatusLabel`, `SleepTimerNumericPanel`

## Playback flow

1. User taps play on an episode
2. `AudioPlayerController.play(episode)` is called
3. Controller sets `NowPlayingInfo` with episode metadata
4. Controller sets audio source (remote URL or local downloaded file path)
5. `AudioPlayer` begins loading -> `PlaybackState.loading`
6. Audio starts -> `PlaybackState.playing`
7. `playbackProgressStreamProvider` emits `PlaybackProgress(position, duration, buffered)`
8. UI rebuilds: mini player shows progress, player screen shows seek bar
9. Position is periodically saved to Isar for resume capability
10. On completion: history recorded, queue advanced (if queue has next item)

## Downloaded episode handling

When an episode has been downloaded:
- `DownloadService` provides the local file path
- `AudioPlayerController` checks download status before setting source
- If downloaded: uses local file path (faster start, works offline)
- If not downloaded: uses remote URL with streaming

## Queue integration

- `QueueService` manages the playback queue (Isar-backed)
- On episode completion, `AudioPlayerController` checks queue for next item
- If queue has next: auto-plays next episode
- If queue empty and "stop at end" setting: returns to idle
- Queue reordering triggers re-evaluation of next-up
- Play order for ad-hoc queues is resolved via `PlayOrderPreferenceRepository` cascade (group -> playlist -> podcast -> global)

## Audio focus and interruptions

Handled by `AudioInterruptionHandler` (pure-logic, callback-based for testability):

- **Transient/duckable interruptions** (e.g. notification chimes): Behavior is user-configurable via `DuckInterruptionBehavior` setting:
  - `duck`: Lower volume for the duration of the interruption
  - `pause`: Pause playback with a short rewind so the listener does not miss content, resume when interruption ends
- **Phone call**: Pause playback, resume when call ends
- **Bluetooth disconnect / headphone unplug**: Pause playback
- Resume-on-end only triggers when the handler itself paused playback, never when the user had already paused manually

## Sleep timer

Managed by `SleepTimerController` (keepAlive Notifier, separate from `AudioPlayerController`):

- **Modes**: Off, duration (minutes countdown), end of episode, end of chapter, episode count
- Duration mode: 1-second tick timer counts down to a deadline; fires when expired
- Episode mode: Decrements remaining count on episode completion
- End-of-episode / end-of-chapter: Fires on the corresponding lifecycle event
- **Fire action**: Fades out audio volume then pauses (`AudioPlayerController.fadeOutAndPause`)
- Timer pauses when playback pauses, resumes when playback resumes
- Remembers last-used minutes and episode count across sessions (persisted via `SleepTimerPreferencesDatasource`)
- Decision logic is encapsulated in `SleepTimerService` (pure, stateless, testable)
- Emits `SleepTimerEvent` stream for UI notifications (e.g. `SleepTimerFired`)

## When to update

Update when: audio playback flow changes, new player features added (e.g., chapters, skip silence), queue behavior modified, background service configuration changes, sleep timer modes or fire behavior changes, audio interruption handling logic changes.
