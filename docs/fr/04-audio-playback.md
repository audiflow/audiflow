---
refs:
  id: fr:04-audio-playback
  kind: fr
  title: "Audio playback"
  related:
    - arch:playback-pipeline
    - fr:05-download-and-queue
    - fr:09-sleep-timer
  modules:
    - packages/audiflow_app/lib/features/player/
    - packages/audiflow_domain/lib/src/features/player/
    - packages/audiflow_ui/lib/src/widgets/player/
---
# FR 04: Audio playback

> Plays podcast episodes with background continuation, lock screen and notification controls, configurable interruption handling, and state-aware play affordances throughout the app.

## Purpose

Listening to episodes is the core activity of a podcast player, so playback must keep working
reliably while the listener does everything else a phone is for — locking the screen, switching
apps, taking a call, plugging in headphones. This feature gives the listener a single,
consistent playback engine that survives backgrounding, exposes the same controls on the lock
screen and notification shade as it does in the app, and behaves predictably when the operating
system interrupts it.

It exists so that no other part of the app has to think about audio. Every surface that can
start, pause, seek, or resume an episode — episode lists, the player screen, the mini player,
the queue, system media controls — funnels through one controller, so playback
state and resume position stay coherent no matter where the listener touches it.

## User-visible Behavior

- **Normal case**: The listener taps play on an episode. The mini player slides up from above
  the bottom navigation bar showing artwork, episode title, podcast name, a thin progress bar,
  and a play/pause button. Playback starts within a moment, and tapping the mini player opens
  the full player screen with artwork, a scrubbable seek bar, and skip controls. If the episode
  was partly played before, it resumes from the saved position; if it was within two seconds of
  the end, it replays from the start. Playback continues when the app is backgrounded or the
  screen is locked.
- **System controls**: While playing, the lock screen and notification shade show the episode
  title, podcast name, and podcast artwork with play/pause, skip-forward/back, seek, and stop
  controls. The artwork stays in place across backgrounding and episode changes. Operating
  these controls is identical to operating the in-app controls — they drive the same playback.
- **Interruption — short sound**: A brief sound such as a notification chime triggers the
  listener's configured interruption behavior. With "duck" selected, volume drops for the
  duration of the chime and returns to normal afterward. With "pause and rewind" selected,
  playback pauses, rewinds a few seconds so no content is missed, and resumes when the chime
  ends.
- **Interruption — phone call**: An incoming call pauses playback (after a short rewind) and
  resumes it when the call ends, including long calls where iOS no longer asks the app to
  resume — the app reactivates the audio session and resumes anyway, unless another app has
  taken over audio in the meantime.
- **Headphone removed**: Unplugging headphones or losing a Bluetooth connection pauses
  playback so audio does not suddenly play out of the phone speaker.
- **Resume after manual pause**: If the listener paused playback themselves, an interruption
  ending never auto-resumes — only auto-paused playback is auto-resumed.
- **End of episode**: When an episode finishes, the next queued episode starts automatically
  and the full player, if open, stays open showing the new episode. If the queue is empty,
  playback returns to idle, the mini player clears, and an open full player dismisses itself
  (together with any picker or dialog stacked on it) so the listener lands back on the screen
  underneath instead of a blank player. Stopping playback outright from the system controls
  clears the same state and dismisses the full player the same way.
- **Playback speed**: The full player's bottom action row has three slots: Audio, an output
  picker (hidden until that feature ships), and the sleep timer. The Audio button shows the
  current speed (e.g. `1.3x`) and opens the Audio sheet, which holds quick chips and a
  stepped slider. The slider has 21 positions — 0.5x to 2.0x in 0.1 steps, then 2.2x, 2.4x,
  2.6x, 2.8x, and 3.0x — with 0.5x, 1.0x, 2.0x, and 3.0x labelled under their ticks. It snaps
  to the positions, applies each step immediately, gives a light haptic per step, and shows
  the speed above the thumb while dragging. The slider commits the speed the listener meant:
  a step is only taken once the finger is well past a boundary, so resting on a boundary does
  not flicker between two speeds; a single-step change made just before lift-off, after the
  finger had rested on the previous step, is undone; and a tap uses the touch-down point
  rather than the lift-off point. The chips are "Normal" plus up to two recently used speeds
  other than 1.0x, shown in ascending speed order; tapping one applies it, and the chip that
  matches the current speed is highlighted. Only the speed the listener settles on (a chip tap
  or slider release) counts as recently used, not every step crossed while dragging.
- **Failure case**: If an episode cannot be loaded or played, playback enters an error state
  rather than appearing stuck; the listener can retry by tapping play again.

## Capabilities

- Loads and plays a single podcast episode from a remote stream URL or, transparently, from a
  completed local download when one exists — the listener never chooses the source.
- Exposes playback as a small set of states (idle, loading, playing, paused, error), each
  carrying the episode it refers to, so any surface can show the correct affordance for the
  episode it is displaying.
- Continues playback in the background and integrates with platform media controls — lock
  screen, notification shade, iOS Control Center — keeping their controls, position, and
  metadata in sync with in-app state.
- Provides play, pause, resume, toggle, stop, seek, and skip-forward / skip-back, with skip
  intervals taken from user settings; all seeks are clamped to valid bounds and are no-ops when
  nothing is loaded.
- Adjusts playback speed on a fixed step grid (`PlaybackSpeedScale`) and persists the chosen
  speed so it applies to future episodes. Stored speeds that predate the grid (0.75x, 1.25x,
  1.75x) are rounded to the nearest step, halves rounding up, when read. The controller keeps
  a newest-first list of the two most recent non-normal speeds for the Audio sheet's chips and
  emits `playback_speed_change` once per committed change; intermediate slider steps apply
  the speed in memory only, without persisting it, recording it, or emitting analytics.
- Resumes an episode from its last saved position, replaying from the start when the saved
  position is at the very end, and honors an explicit start position from timestamped share
  links over the saved position.
- Periodically saves playback progress so episodes can be resumed across app restarts, and
  records completed episodes to playback history. An episode is auto-marked completed once
  playback passes 95% of its duration (to tolerate trailing credits or silence), and the
  listener can manually toggle an episode played or unplayed, which overrides the auto-detected
  state.
- Auto-advances to the next queued episode on completion, deferring to the queue feature for
  what plays next.
- Handles audio-focus interruptions through a dedicated, configurable handler: transient
  duckable interruptions follow the user's `duck` vs `pause-and-rewind` preference; phone calls
  and noisy-output events (headphone unplug, Bluetooth disconnect) pause; and resume-on-end
  fires only for playback the handler itself paused.
- Fades volume out before pausing when requested, used by the sleep timer's end-of-countdown
  action.
- Drives the mini player and full player screen, including a slide-in/out animation for the
  mini player and flicker-free seeking that preserves the visual state during the brief
  buffering that follows a scrub.

### Play affordance refinements

- Episode rows present playback state through an outlined **play pill** rather than a bare
  icon. The pill conveys playback state and duration only; the publish date renders as a
  separate text element in the same row, never inside the pill.
- The pill has five mutually exclusive states resolved by precedence: loading (indeterminate
  spinner), completed (check icon, muted color, "Completed" label), playing (determinate
  progress ring around a pause icon, "{time} left" label), in-progress paused (progress ring
  around a play icon, same label), and not-played (filled play icon, total-duration label).
- The progress ring reflects the latest known progress fraction for in-progress episodes,
  clamped to a valid range; it is not animated and simply redraws as the row rebuilds on
  playback ticks.
- Durations on episode rows use a single compact format shared app-wide: `{minutes}m` at one
  minute or longer, `0:ss` below one minute. Pill state labels are localized for English and
  Japanese.

### Full player seek bar

- The full player uses a thumbless, rounded seek bar (`PlayerSeekBar` in `audiflow_ui`): a
  6 pt track that thickens to 10 pt while dragging, with the played part in the theme's
  primary color and the rest in the same color at 30% opacity.
- Scrubbing is delta-based: a horizontal drag moves the position by the finger's travel from
  the current position instead of jumping to the touch point, and a tap on the track never
  seeks. A light haptic fires when a drag begins.
- Fine scrubbing: once a drag has started, moving the finger vertically away from the track
  (up or down) scales how far horizontal travel moves the position: full speed within 50 pt,
  half speed from 50 pt, quarter speed from 100 pt, and one eighth from 150 pt. A light haptic
  fires each time the band changes, and a localized label ("Scrubbing (half speed)",
  "Scrubbing (quarter speed)", "Scrubbing (fine)") appears between the time labels while below
  full speed. The drag stays with the seek bar even when the finger leaves its bounds; a drag
  that starts vertically is not a scrub and still reaches the player sheet's swipe-to-dismiss.
- The left label shows elapsed time. The right label shows remaining time as `-mm:ss` (or
  `-h:mm:ss`) by default; tapping it toggles to the total duration. The choice persists as the
  `showRemainingTime` setting. Remaining time is media time and does not account for playback
  speed.
- While scrubbing, the play/pause button keeps the state it had when the drag began, so the
  brief buffering after the seek does not flicker the icon.
- When the duration is unknown, releasing a drag performs no seek. When no audio is loaded
  (e.g. after the app restores a session), the drag updates the saved resume position instead,
  so the next play starts there.
- Screen readers see a single slider whose value reads "elapsed of total"; increase/decrease
  actions seek by 5% of the episode, and the right-hand label is exposed as a button so the
  remaining/total toggle stays reachable.
- For episodes with chapters, the track is split into one segment per chapter with a 2 pt gap
  at each chapter start (an untitled lead-in segment when the first chapter starts after
  zero). While dragging, and only then, a tooltip above the bar shows the chapter under the
  scrub position and the position itself; episodes without chapters show the position only.
  The tooltip follows the finger but is kept within the bar at both edges. Chapter display is
  described in FR 08. Episodes without chapters keep a single unbroken track.
- The artwork above the episode info shrinks to make room for the text below it, down to a
  160 pt minimum; on screens too short for that the area above the seek bar scrolls instead.
- The mini player's thin progress bar is unchanged.

## Boundaries

- **Does not own the queue.** What plays after the current episode — manual queue, ad-hoc
  queue, priority, and reordering — belongs to FR 05 (download and queue). Playback only asks
  the queue for the next episode on completion and plays whatever it is given.
- **Does not own downloads.** Acquiring and storing local episode files is FR 05; playback only
  checks whether a completed download exists and prefers its file path when it does.
- **Does not own the sleep timer.** Countdown modes, end-of-episode / end-of-chapter triggers,
  and timer persistence belong to FR 09 (sleep timer). Playback only exposes the fade-out-and-
  pause action the timer invokes and the lifecycle events the timer observes.
- **Does not own transcripts or chapters.** Transcript and chapter display, including the
  chapter gaps and tooltip on the seek bar, is FR 08; playback only provides the position
  other features read.
- **Does not define play order for ad-hoc queues.** The group → playlist → podcast → global
  play-order cascade is a separate feature; playback consumes its result via the queue.
- **Does not perform discovery, subscription, or feed parsing.** Playback operates on episodes
  that already exist locally.

## Traceability

- **Source docs**:
  - `docs/architecture/playback-pipeline.md` (`arch:playback-pipeline`)
  - `docs/superpowers/specs/2026-05-08-play-button-content-design.md`
  - `docs/superpowers/plans/2026-05-09-episode-play-pill-redesign.md`
  - `packages/audiflow_app/lib/features/player/` (audio handler, interruption handler,
    mini player, player screen)
  - `packages/audiflow_domain/lib/src/features/player/` (audio player controller, now
    playing controller, playback models, playback history)
- **Related FR**: `05-download-and-queue.md`, `09-sleep-timer.md`
