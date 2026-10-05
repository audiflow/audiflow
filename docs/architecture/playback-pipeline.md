---
refs:
  id: arch:playback-pipeline
  kind: architecture
  title: "Playback pipeline"
  modules:
    - packages/audiflow_app/lib/features/player/
    - packages/audiflow_domain/lib/src/features/player/
---
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

#### Now-playing metadata and artwork

`NowPlayingMediaItemSync` (audiflow_app) turns `NowPlayingInfo` into the
`MediaItem` that audio_service publishes to the platform. The metadata goes
out immediately with no artwork; `NowPlayingArtworkPreparer` then fetches the
artwork (UI image cache first, network on a miss), downscales it to a
512 px PNG under `<app cache>/now_playing_artwork/`, and the item is re-published
with a `file:` `artUri`. Later updates (duration, etc.) copy that URI along.
That directory keeps the 32 most recently written files; older ones are
deleted after each write and prepared again on demand.

Why a local file: audio_service passes a `file:` URI to the platform on every
update, but downloads a remote URL asynchronously and drops the follow-up
update whenever another media item lands first. The iOS plugin also decodes
the file at native size, and very large `MPMediaItemArtwork` images fail to
render on the lock screen (#453). The Android plugin still applies its own
`artDownscale*` setting on top (#451); it is set to the same 512 px so the
prepared file decodes whole, because the plugin's power-of-two sample size
would otherwise halve it to 256 px (#455). When preparation fails the remote
URL is published as a fallback, which is the pre-#453 behavior.

### Layer 3: State management (Riverpod)

| Provider | Type | Purpose |
|----------|------|---------|
| `audioEffectsSupportedProvider` | keepAlive sync | True on Android only; gates the effects UI and every effect engine call |
| `voiceBoostEffectProvider` | keepAlive sync | The `AndroidLoudnessEnhancer` (target gain `voiceBoostTargetGainDb`) attached to the player, null where effects are unsupported |
| `audioPlayerProvider` | keepAlive sync | Singleton AudioPlayer, constructed with an `AudioPipeline` holding the voice boost effect on Android |
| `audioPlayerControllerProvider` | keepAlive Notifier | Play/pause/seek/stop commands, `setSpeed(speed, scope:)` and `setEffect(effect, enabled:, scope:)` (persist to a scope), `applySpeed` and `applyAudioSettings` (player only), fade-out-and-pause |
| `playbackProgressStreamProvider` | keepAlive Stream | Combined position + duration + buffered |
| `playbackSpeedProvider` | keepAlive Stream | Current speed from player |
| `playbackSpeedSettingsControllerProvider` | keepAlive Notifier | Persisted global speed and the shared recent speeds |
| `playbackEffectsSettingsControllerProvider` | keepAlive Notifier | Persisted global silence skipping and voice boost |
| `podcastAudioOverrideControllerProvider(podcastId)` | keepAlive AsyncNotifier | A podcast's audio settings override, null when it has none |
| `effectiveAudioSettingsProvider(podcastId)` | keepAlive | Override -> global resolution with the scope it came from; null while the override loads |
| `nowPlayingAudioSettingsProvider` | keepAlive | `effectiveAudioSettingsProvider` for the now-playing podcast |
| `effectiveAudioSettingsApplierProvider` | keepAlive | Applies `nowPlayingAudioSettingsProvider` to the player on change; listened from `main.dart` |
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

## Audio settings scope

Speed and the effects (silence skipping, voice boost) are stored globally
(`AppSettingsRepository`) and optionally per podcast (`PodcastAudioPreference`
in Isar). Each write names an `AudioSettingsScope`:

- `GlobalAudioSettingsScope`: the Playback settings screen, and the Audio sheet
  while its per-podcast switch is off.
- `PodcastAudioSettingsScope(podcastId)`: the Audio sheet while the switch is on.
  A write to a podcast with no override is dropped, so an override is only ever
  created by switching it on (which copies the global values).

`AudioPlayerController.setSpeed` and `setEffect` persist to the named scope
and apply the value only when that scope is the one
`nowPlayingAudioSettingsProvider` resolves to, so a global edit never
overrides a podcast override on the player. `effectiveAudioSettingsApplierProvider`
covers changes that do not go through them: the now-playing podcast changing,
or an override being switched off (the player returns to the global values).
`play()` resolves the episode's podcast through the same in-memory override
state (awaiting its load) before playback starts, so it never disagrees with
what the UI shows. All these paths go through `applySpeed` or
`applyAudioSettings`, which share one engine drain: it is idempotent (a value
equal to the applied or pending one is a no-op) and serialized (one engine
call at a time, whether speed, `setSkipSilenceEnabled`, or the loudness
effect; requests made meanwhile collapse into the latest). The applier only
reads providers and writes the engine, so applying a value cannot feed back
into the resolution it listens to.

Effects reach the engine only where `audioEffectsSupportedProvider` is true
(Android): just_audio 0.10.x implements silence skipping and audio effects
only there. The loudness effect can only be attached when the `AudioPlayer`
is constructed, so `audioPlayerProvider` always attaches it on Android and
voice boost toggles its `enabled` flag; while disabled the effect is
bypassed. Silence skipping and the effect state are player-level, so they
carry across episodes and are re-resolved on each `play()`.
The Audio sheet pins its podcast when it opens, so a queue advance mid-drag
cannot send the rest of the drag to another podcast's settings.

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

## Pause / resume triggers

All the places that initiate a pause, resume, or new play, grouped by the
state the iOS audio session is in when the call arrives. Only the
interruption paths (rows 8–9) operate while iOS has deactivated the
session, which is why fixes for the interruption bug must be scoped to
`AudiflowAudioHandler`'s interruption wiring and must not be pushed into
`AudioPlayerController` (that would regress the common paths).

| # | Trigger | Entry point | Calls | Session state | Interruption-special |
|---|---|---|---|---|---|
| 1 | Mini-player button | `audiflow_app` `mini_player.dart` | `controller.pause` / `togglePlayPause` | active | No |
| 2 | Full-player button | `audiflow_app` `player_screen.dart` | `controller.pause` / `resume` / `play` | active | No |
| 3 | Episode tile toggle | `episode_list_tile.dart`, `smart_playlist_episode_list_tile.dart`, `episode_detail_screen.dart` | `controller.pause` / `resume` / `play` | active | No |
| 4 | Queue tap | `queue_controller.dart` | `controller.play` | active | No |
| 5 | Lock screen / Control Center | `audiflow_audio_handler.dart` `audio_service` overrides | `_controller.resume` / `pause` | active | No |
| 6 | Headphone unplug (`becomingNoisy`) | `audiflow_audio_handler.dart` | `pause()` | active | No |
| 7 | Sleep-timer fade | `sleep_timer_controller.dart` | `player.fadeOutAndPause` → `_player.pause` (bypasses controller history-save) | active | No |
| 7b | Sleep-timer end of chapter | `sleep_timer_controller.dart` | `player.pause` (saves history like a user pause) | active | No |
| 8 | Interruption begin (call / notification / Siri) | `audio_interruption_handler.dart` via wired `pause:` callback | `_controller.pause` | **deactivated by iOS** | **Yes — state-desync** |
| 9 | Interruption end | `audio_interruption_handler.dart` via wired `resume:` callback → `_reactivateAndResume` | `session.setActive(true)` + `play()` → `_controller.resume` | **reactivation + re-prime needed** | **Yes — silent-resume** |

(A former "Voice command" trigger row was removed: voice commands are not implemented — the feature was dropped from the codebase and `voice_command_executor.dart` / `voice_command_orchestrator.dart` no longer exist.)

### Known interruption-path pitfalls (iOS)

- With `handleInterruptions: false`, `just_audio`'s internal `playing`
  flag can stay `true` across an OS-initiated pause, so
  `playerStateStream` does not emit a transition when the handler calls
  `_player.pause()`. The UI's `PlaybackState` then stays `playing`
  (progress bar keeps advancing, play/pause button stays "pause").
- After `session.setActive(true)` + `play()`, AVPlayer's output
  pipeline may remain torn down from the interruption — `_player.play()`
  returns without producing audible sound. A position-neutral seek
  (`_player.seek(_player.position)`) before `play()` rebuilds the
  pipeline.

## Sleep timer

Managed by `SleepTimerController` (keepAlive Notifier, separate from `AudioPlayerController`):

- **Modes**: Off, duration (minutes countdown), end of episode, end of chapter, episode count
- Duration mode: 1-second tick timer counts down to a deadline; fires when expired
- Episode mode: Decrements remaining count on episode completion
- End-of-episode: Fires on the episode-completed lifecycle event; a manual episode switch cancels it
- End-of-chapter: `ChapterCrossingTracker` follows `currentChapterProvider` and fires when playback moves forward into the next chapter, pausing at once (`AudioPlayerController.pause`, no fade) so the next chapter's opening is not heard. The player emits `SeekStartedLifecycle` before every requested position change (seek, resume at a saved or explicit position, seek on a restored episode), so a seek that leaves the chapter yields `SeekedOutOfChapterEvent`, which cancels the timer (`SleepTimerCancelled`, shown as a snackbar) instead of firing. Seeks the player makes on its own are tagged `automatic` and never cancel: a resume at the saved position moves the baseline to the target (the freshly loaded source may report zero first), and the interruption rewind (`AudioPlayerController.seekAutomatically`) keeps the baseline until playback returns to it. A seek the player rejects emits `SeekFailedLifecycle` and the baseline returns to the chapter still playing; the cancellation stands. Natural episode completion fires an armed end-of-chapter timer through the end-of-episode path (`suppressNextAutoAdvance`), which covers a target in the last chapter. A manual episode switch cancels both end-of-episode and end-of-chapter timers; `play()` also reports a switch away from a restored episode whose audio was never loaded. Each report carries the id of the seek it closes, so a late report cannot end a newer seek's settle window. Chapter lists that load or change under the listener only move the baseline. Listened from `main.dart` so the tracking does not pause while no sleep-timer widget is on screen
- **Fire action**: chosen by `FireDecision.stop` (`SleepTimerStop`): `fadeOut` fades the volume then pauses (`AudioPlayerController.fadeOutAndPause`, duration timer); `pauseNow` pauses without a fade (`AudioPlayerController.pause`, end-of-chapter boundary); `holdAtEndOfStream` keeps the finished episode from auto-advancing (`suppressNextAutoAdvance`, end-of-episode, last episode of an episode-count timer, end-of-chapter on the last chapter)
- Timer pauses when playback pauses, resumes when playback resumes
- Remembers last-used minutes and episode count across sessions (persisted via `SleepTimerPreferencesDatasource`)
- Decision logic is encapsulated in `SleepTimerService` (pure, stateless, testable)
- Emits `SleepTimerEvent` stream for UI notifications: `SleepTimerFired`, and `SleepTimerCancelled` when leaving the target cancels a timer (not when the listener turns it off)

## When to update

Update when: audio playback flow changes, new player features added (e.g., chapters, skip silence), queue behavior modified, background service configuration changes, sleep timer modes or fire behavior changes, audio interruption handling logic changes, new pause/resume entry points added (keep the trigger matrix current).
