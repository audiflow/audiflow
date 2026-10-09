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

- **Normal case**: The listener taps play on an episode. The mini player, a floating card,
  slides up from above the bottom navigation bar showing artwork, episode title, podcast name,
  skip-forward and play/pause buttons, and a thin progress line along its bottom edge once
  playback has started. Playback starts within a moment, and tapping the mini player opens
  the full player screen with artwork, a scrubbable seek bar, and skip controls. The full
  player sits on a dark ground taken from the episode artwork (muted and darkened so white
  controls stay readable; a default navy until the artwork is sampled), with white controls.
  Its header shows a close chevron, "Playing from" with the queue's source (or the podcast),
  and an overflow menu with the transcript page (when available), episode details, the
  podcast, and sharing the episode (when it has a link to share). The menu opens just below
  its button, as the other screens' overflow menus do. If the episode
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
- **Playback speed**: The full player's bottom action row, on a translucent strip, has three slots: Audio, an output
  picker (see Audio output below), and the sleep timer. The Audio button shows the
  current speed (e.g. `1.3x`) and opens the Audio sheet, which holds quick chips and a
  stepped slider. The slider has 21 positions — 0.5x to 2.0x in 0.1 steps, then 2.2x, 2.4x,
  2.6x, 2.8x, and 3.0x — with 0.5x, 1.0x, 2.0x, and 3.0x labelled under their ticks. It snaps
  to the positions, applies each step immediately, and shows the speed above the thumb while
  dragging; it gives no haptic per step, only a single detent haptic when a drag reaches or
  passes 1.0x. The slider commits the speed the listener meant:
  a step is only taken once the finger is well past a boundary, so resting on a boundary does
  not flicker between two speeds; a single-step change made just before lift-off, after the
  finger had rested on the previous step, is undone; and a tap uses the touch-down point
  rather than the lift-off point. The chips are "Normal" plus up to two recently used speeds
  other than 1.0x, shown in ascending speed order; tapping one applies it, and the chip that
  matches the current speed is highlighted. Tapping a chip other than the current speed plays
  a light selection haptic. Only the speed the listener settles on (a chip tap
  or slider release) counts as recently used, not every step crossed while dragging.
- **Per-podcast audio settings**: A "Custom for this podcast" switch sits at the top of the
  Audio sheet. Off, the controls edit the global settings and the caption reads "Applies to
  all podcasts"; on, they edit an override for the now-playing podcast and the caption reads
  "This podcast only". The controls are never greyed out either way. Turning the switch on
  copies the current global values into the new override, so nothing audibly changes;
  turning it off deletes the override and the player returns to the global values at once.
  Editing with the switch off never creates an override. Whenever the now-playing episode's
  podcast changes, the player re-resolves override -> global and applies the result, so
  playing podcast A (override 1.5x) and then podcast B (no override, global 1.0x) switches
  between the two speeds automatically. The Audio button's label shows the speed in effect.
  The override is edited only here, while one of the podcast's episodes is playing. The
  recent-speed chips are one shared history: a speed
  committed under an override is recorded there too, so it is one tap away for any podcast.
  The speed and both effects below follow the switch.
- **Silence skipping and voice boost (Android only)**: On Android the Audio sheet has an
  Effects section below the speed with two switches. "Shorten silences" skips quiet gaps so a
  talk episode finishes sooner. "Voice boost" raises loudness with a fixed target gain (6 dB to
  start, to be tuned on devices) so quiet speech is easier to hear. Both are off by default,
  take effect at once, and follow the per-podcast switch like the speed does. On iOS the
  section is not shown and any stored values are ignored, because the audio engine implements
  neither effect there.
- **Audio output**: The center slot of the action row opens the operating system's own audio
  output picker; the app does not draw a device list. On iOS it is the system route picker
  (speaker, Bluetooth, AirPlay), and choosing a route moves playback there. On Android 11 and
  later it is the system output switcher (speaker, wired, Bluetooth); if the device cannot
  show it, the button opens Bluetooth settings instead, and a short message appears if neither
  opens. Android 8-10 have no output switcher,
  so the button is hidden there and the row shows only Audio and the sleep timer. Cast
  devices are not offered. The button does not show the current output's name.
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
- Keeps per-podcast audio settings overrides (`PodcastAudioPreference`, behind
  `PodcastAudioPreferenceRepository`). Every speed write names its
  `AudioSettingsScope` (global or one podcast), and the player is only changed when that
  scope is the one the now-playing podcast resolves to. `effectiveAudioSettingsApplier`
  re-applies the resolved settings when the now-playing podcast or its override changes, and
  `play()` resolves the episode's podcast from the same state before playback starts.
- On Android, applies silence skipping (`AudioPlayer.setSkipSilenceEnabled`) and voice boost
  (an `AndroidLoudnessEnhancer` attached when the player is constructed) through the same
  serialized engine path as the speed. Effect writes name their scope the same way as speed
  writes. Elsewhere `audioEffectsSupportedProvider` is false and effects never reach the
  engine.
- Resumes an episode from its last saved position, replaying from the start when the saved
  position is at the very end, and honors an explicit start position from timestamped share
  links over the saved position.
- Periodically saves playback progress so episodes can be resumed across app restarts, and
  records completed episodes to playback history. An episode is auto-marked completed once
  playback passes 95% of its duration (to tolerate trailing credits or silence), and the
  listener can manually toggle an episode played or unplayed, which overrides the auto-detected
  state.
- Separates the played status from the current listen, so a played episode can be replayed
  without losing its status (see "Replay and listen sessions" below).
- Auto-advances to the next queued episode on completion, deferring to the queue feature for
  what plays next.
- Handles audio-focus interruptions through a dedicated, configurable handler: transient
  duckable interruptions follow the user's `duck` vs `pause-and-rewind` preference; phone calls
  and noisy-output events (headphone unplug, Bluetooth disconnect) pause; and resume-on-end
  fires only for playback the handler itself paused.
- Opens the system audio output picker through the `audiflow/audio_route` channel on Android
  (androidx.mediarouter `SystemOutputSwitcherDialogController`) and a transparent embedded
  `AVRoutePickerView` on iOS; the platform moves playback to the chosen output, so the player
  needs no routing code of its own.
- Fades volume out before pausing when requested, used by the sleep timer's end-of-countdown
  action (the end-of-chapter timer instead pauses at once and returns to the chapter boundary).
- Drives the mini player and full player screen, including a slide-in/out animation for the
  mini player and flicker-free seeking that preserves the visual state during the brief
  buffering that follows a scrub.

### Play affordance refinements

- Episode rows present playback state through a filled, fully rounded **play pill** rather
  than a bare icon. The pill conveys playback state and duration only; the publish date
  renders as a separate text element in the same row, never inside the pill. The pill is
  32 pt tall with a 44 pt touch target.
- The pill has four mutually exclusive states resolved by precedence: loading (indeterminate
  spinner), completed (check glyph in a muted color, "Completed" label), playing (pause glyph,
  accent-colored label on a tinted accent fill, "{time} left" label), and idle (play glyph on a
  neutral fill; "{time} left" when partially played, total duration otherwise). A played
  episode takes the completed state only while it is neither playing nor being replayed; a
  replay shows the playing or idle state with its remaining time and a partial progress line.
- The pill never changes shape to show progress. A row whose playback has started instead
  shows a 3 pt progress line along its bottom edge (accent fill on a hairline track),
  reflecting the latest known progress fraction clamped to a valid range. Completed episodes
  show the line full; unplayed episodes show none. The line is not animated and simply
  redraws as the row rebuilds on playback ticks.
- Durations on episode rows use a single compact format shared app-wide: `{minutes}m` at one
  minute or longer, `0:ss` below one minute. Pill state labels are localized for English and
  Japanese.

### Full player seek bar

- The full player uses a thumbless, rounded seek bar (`PlayerSeekBar` in `audiflow_ui`): a
  6 pt track that thickens to 10 pt while dragging, with the played part in the theme's
  primary color and the rest in the same color at 30% opacity.
- Scrubbing is delta-based: a horizontal drag moves the position by the finger's travel from
  the current position instead of jumping to the touch point, and a tap on the track never
  seeks. The seek bar gives no haptic while scrubbing except a single detent haptic each time
  the drag crosses a chapter boundary (episodes with chapters only).
- Fine scrubbing: once a drag has started, moving the finger vertically away from the track
  (up or down) scales how far horizontal travel moves the position: full speed within 50 pt,
  half speed from 50 pt, quarter speed from 100 pt, and one eighth from 150 pt. A localized label ("Scrubbing (half speed)",
  "Scrubbing (quarter speed)", "Scrubbing (fine)") appears between the time labels while below
  full speed. The drag stays with the seek bar even when the finger leaves its bounds; a drag
  that starts vertically is not a scrub and still reaches the player sheet's swipe-to-dismiss.
- Lift-off settling: as a finger leaves the glass the contact point rolls by a few points,
  which would nudge the seek away from where the user stopped. If the position had held still
  (within 2 pt of track) for at least 150 ms and then moved only within the last 60 ms before
  lift-off, by no more than 12 pt under the finger, the drag commits the settled position
  instead. A drag still moving at lift-off, a flick, or a larger final push commits the final
  position, and a cancelled drag commits its position as it stands; a second touch on the bar
  does not change how the dragging finger's release is judged. Stillness is judged on the
  position after fine-scrub scaling (what the bar shows), while the late move is measured
  under the finger, so a deliberate final push while fine scrubbing is kept. The rule uses
  pointer event timestamps; the displayed time and the seek both use the committed position. The thresholds are initial values to be tuned on a device.
- The left label shows elapsed time. The right label shows remaining time as `-mm:ss` (or
  `-h:mm:ss`) by default; tapping it toggles to the total duration. The choice persists as the
  `showRemainingTime` setting. Remaining time is media time and does not account for playback
  speed.
- While a sleep timer is armed, the right label instead shows a sleep glyph (zZ) and the time
  until the timer stops playback, in the same clock format (see FR 09 for how that time is
  computed). Tapping it switches between this sleep countdown and the regular time label
  (remaining or total, whichever was last chosen) without changing the `showRemainingTime`
  setting; arming a new timer brings the countdown back. While scrubbing, the right label shows
  the regular time label for position feedback and returns to the countdown on release. Screen
  readers hear the countdown as a sleep status ("Sleep timer, 12 minutes left").
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

### Go back after a jump

- After a deliberate jump on the full player — releasing a seek bar drag or picking a chapter
  from the chapter list — a "Go back" pill appears at the bottom center of the artwork, with a
  close button beside it. Any jump distance counts.
- Tapping "Go back" returns playback to where it was just before the jump, plays a light tap
  haptic, and hides the pill.
  The close button hides it without seeking. Otherwise it fades out 10 seconds after the
  latest jump.
- A further jump while the pill is showing keeps the original position, so "Go back" undoes
  the whole run of jumps, and restarts the 10-second countdown.
- The skip-forward / skip-back buttons, the lock screen, and other system controls never
  show the pill. Neither does tapping a transcript segment: the Transcript tab hides the
  artwork, so the pill would not be seen.
- Changing episode discards the pill and its position.
- A jump the player rejects shows no pill, and a rejected return brings the pill back so the
  listener can retry.
- The pill works before audio has loaded too (a restored session): the jump and the return
  both move the saved resume position, as the seek bar does.
- Implemented by `SeekUndoController` (`seekWithUndo`, `goBack`, `dismiss`), a thin layer
  over `AudioPlayerController.seekNowPlaying`, and the `SeekUndoOverlay` widget.

### Replay and listen sessions

An episode's history carries two separate facts: whether the episode is **played**, and
whether its current **listen** is open or finished.

- An episode is **played** once a listen reaches the completion threshold (or the listener
  marks it played). It stays played until the listener marks it unplayed; replaying never
  clears it. Played episodes offer "Mark as unplayed", stay out of the Unplayed filter, count
  toward series played counts, and stay hidden in stations that hide played episodes.
- A **listen** is open from the moment playback starts until it reaches the completion
  threshold or the listener marks the episode played; a finished listen may keep playing its
  tail without reopening. An episode is **in progress** when it has a saved position past zero
  and its listen is open, and only then is it resumable: it shows in Continue listening, is
  restored at launch, matches the In Progress filter, and rows and the episode detail show its
  remaining time and progress line instead of the played check.
- A finished listen is taken up again as a new listen, a **replay**, in exactly three cases, all
  explicit acts of the listener and all judged against the completion threshold:
  - playback of the episode **starts** at a position below the threshold (from the start, from a
    saved position, from a chapter or a timestamped link, or after a restart);
  - the listener **resumes** the paused episode below the threshold (after marking it played
    while paused);
  - the listener **seeks backward** to a position below the threshold while the episode plays.
  Starting or resuming at or past the threshold continues the finished listen, so playing out
  the tail of a finished episode does not count another completion; seeks and resumes the
  player makes on its own (interruption rewinds and resumes, the end-of-chapter sleep timer)
  never reopen a listen; and
  neither does playing on or skipping forward after "Mark as played".
- A replay is a listen like any other: it is in progress while open, finishes at the threshold
  or when the listener marks the episode played, and the episode stays played throughout.
- Only a replay **from the beginning** counts another completion when it reaches the threshold:
  one that starts from the beginning, or that the listener seeks back to the beginning. A
  replay reopened by rewinding part of the episode finishes without counting one, and so does
  marking a replay played. A finished listen the player rewinds on its own stays finished, so
  passing the threshold again counts nothing. Marking an episode unplayed clears the played status and leaves its
  position in place, so a partly played episode is in progress again.
- Marking any other episode played or unplayed, in a single action or in bulk, never changes the
  playing episode's listen.
- A played-download auto-delete waits while the episode's listen is open and restarts its grace
  period when the listen finishes (FR 05).

## Boundaries

- **Does not own the queue.** What plays after the current episode — manual queue, ad-hoc
  queue, priority, and reordering — belongs to FR 05 (download and queue). Playback only asks
  the queue for the next episode on completion and plays whatever it is given.
- **Does not own downloads.** Acquiring and storing local episode files is FR 05; playback only
  checks whether a completed download exists and prefers its file path when it does.
- **Does not own the sleep timer.** Countdown modes, end-of-episode / end-of-chapter triggers,
  and timer persistence belong to FR 09 (sleep timer). Playback only exposes the pause-at-position and
  fade-out-and-pause actions the timer invokes and the lifecycle events the timer observes.
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
