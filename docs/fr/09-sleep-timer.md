---
refs:
  id: fr:09-sleep-timer
  kind: fr
  title: "Sleep timer"
  related:
    - fr:04-audio-playback
  modules:
    - packages/audiflow_domain/lib/src/features/player/models/sleep_timer_config.dart
    - packages/audiflow_domain/lib/src/features/player/models/sleep_timer_state.dart
    - packages/audiflow_domain/lib/src/features/player/models/sleep_timer_event.dart
    - packages/audiflow_domain/lib/src/features/player/services/sleep_timer_service.dart
    - packages/audiflow_domain/lib/src/features/player/services/chapter_crossing_tracker.dart
    - packages/audiflow_domain/lib/src/features/player/datasources/local/sleep_timer_preferences_datasource.dart
    - packages/audiflow_domain/lib/src/features/player/controllers/sleep_timer_controller.dart
    - packages/audiflow_domain/lib/src/features/player/providers/sleep_timer_providers.dart
    - packages/audiflow_app/lib/features/player/presentation/controllers/sleep_timer_ui_controller.dart
    - packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_sheet.dart
    - packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_sheet_status_line.dart
    - packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_numeric_panel.dart
    - packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_chip.dart
    - packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_icon_button.dart
    - packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_status_label.dart
    - packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_label_format.dart
---
# FR 09: Sleep timer

> An opinionated sleep timer that ends playback after a chosen condition — a fixed duration, a number of episodes, the end of the current episode, or the end of the current chapter — with a gentle fade-out when it fires.

## Purpose

People listen to podcasts to fall asleep, and they do not want the audio to keep playing for hours after they have drifted off — draining the battery, burning through data, and losing their place in episodes they never heard. The sleep timer lets a listener decide in advance when playback should stop, then trust the app to honour that decision without further interaction.

Audiflow keeps the timer deliberately compact and opinionated rather than exposing every conceivable option. It offers four ways to express "stop here": a wall-clock duration ("in 30 minutes"), an episode count ("after 3 episodes"), the natural end of the current episode, and the natural end of the current chapter. The most recently used minute and episode values are remembered globally so that a returning listener can re-arm a familiar timer with a single tap. When a timer fires, playback fades out smoothly over several seconds instead of cutting off abruptly, so the transition into silence is calm enough not to wake a half-asleep listener.

## User-visible Behavior

- **Arming a timer**: A sleep (moon) icon in the full-player action row opens a single bottom sheet. The sheet groups its options into two rounded cards. The "Stop on" card holds End of episode and End of chapter; "End of chapter" is shown only when the currently playing episode actually has chapter data. The "Stop after" card holds a minutes entry and an episodes entry, which show "Set minutes" / "Set episodes" the first time; once a value has been used, they instead show the remembered value (e.g. "30 minutes") with a trailing "Edit" control. While a timer is armed, a status line under the sheet title describes it ("Stopping in mm:ss (at HH:MM)", "Stops at end of episode", "Stops at end of chapter", or "N episodes left", with the countdown refreshing once per second), the active option is highlighted with a check mark inside its card, and a Cancel button below the cards turns the timer off. When no timer is armed, neither the status line nor the Cancel button is shown.
- **Numeric entry**: Choosing the minutes or episodes entry for the first time swaps the same sheet to a numeric input panel — a large readout, a number pad, and a Start button — with no nested sheets. Minutes are bounded to 1–999, episodes to 1–99. When a value is already remembered, a short tap on the entry starts the timer immediately with that value, while a long press or the "Edit" control opens the numeric panel pre-filled for editing.
- **Active-timer feedback**: While a timer is armed, the sleep icon is tinted with the primary color, and a status chip appears above the mini player. The chip reads "Sleep · Episode end", "Sleep · Chapter end", "Sleep · N eps left", or a live "Sleep · mm:ss" countdown for duration timers (switching to h:mm:ss past an hour), refreshing once per second. Tapping the chip opens the same sleep sheet from anywhere in the app without navigating away; a delete control on the chip cancels the timer directly.
- **When the timer fires**: Playback fades from the current volume down to silence over roughly eight seconds and then pauses; the original volume is restored so the next session starts at the listener's preferred level. The timer config resets to Off, and if the app is in the foreground a brief "Sleep timer ended" snackbar is shown. Remembered minute and episode values are left untouched.
- **End-of-episode and end-of-chapter cases**: These two timers refer to the episode or chapter that was playing when the timer was armed, and only to it.
  - *End of episode*: fires when that episode finishes naturally, pausing at its end without a fade and without auto-advancing the queue. Seeking anywhere within the episode keeps the timer. Manually switching to another episode (episode list, queue, next button) cancels it.
  - *End of chapter*: fires with a fade when playback crosses from the target chapter into the next one on its own. When the target is the last chapter, the chapter ends with the episode, so the timer stops playback at episode completion exactly like the end-of-episode timer (no fade, no auto-advance). A seek that stays within the target chapter keeps the timer. A seek that leaves it, forward or backward (seek bar, skip buttons, chapter list, transcript, lock screen), cancels it, and so does a manual switch to another episode. A seek the player then fails to perform still cancels: the listener asked to leave. Returning to the saved position when an episode's audio loads is not a seek away, so it keeps the timer. Armed during an untitled lead-in before the first chapter, the timer targets the first chapter: playing or seeking into it keeps the timer, and it fires at that chapter's end. Chapters that finish loading, or are replaced, while the timer is armed neither fire nor cancel it; the chapter at the current position in the new list becomes the target. If the episode's chapters are unavailable, the timer stays armed but inactive.
  - *Cancellation message*: when leaving the target cancels a timer, a brief "Sleep timer cancelled" snackbar is shown if the app is in the foreground. Turning the timer off through the sheet or the chip shows no message.
  - *Why cancel*: "the end of episode" or "the end of chapter" means the end of what the listener is hearing now. Once they move elsewhere, carrying the timer over or retargeting it to wherever they landed would stop playback at a point they never chose, so the timer is dropped instead, and the message keeps that from going unnoticed.
- **Episode-count case**: An "after N episodes" timer decrements only when an episode completes on its own. Manually skipping to the next episode neither consumes a count nor cancels the timer. When the last counted episode completes, the timer fires before the queue auto-advances.
- **Cancelling and edge cases**: The listener turns a timer off through the sheet's Cancel button or the chip's delete control; there is no toggle-off on an already-active entry. Apart from that, only leaving the target of an end-of-episode or end-of-chapter timer cancels it (see above). Cancelling mid fade-out aborts the fade and restores volume. A duration timer is wall-clock based, so it still fires even if playback was paused when the deadline passed. The active timer is session-only: force-quitting the app clears it, though the remembered minute and episode values survive a restart.

## Capabilities

- Offers four mutually exclusive timer modes — fixed duration, episode count, end of current episode, end of current chapter — plus an explicit Off state, surfaced through one compact bottom sheet.
- Remembers the listener's most recent minute and episode selections persistently across app restarts, while keeping the active timer itself session-only.
- Evaluates timer progress against player lifecycle signals (episode completion, manual episode switch, seeks), chapter boundaries crossed during playback, and a one-second tick for duration timers, deciding via pure, side-effect-free logic whether to keep, fire, decrement, or cancel.
- Distinguishes natural episode completion from manual skips so episode-count timers only decrement on genuine listening progress, while end-of-episode and end-of-chapter timers are cancelled when the listener leaves their target episode or chapter.
- Fades audio out smoothly before pausing when a timer fires, restoring the pre-fade volume afterwards, and cancels an in-flight fade cleanly if the timer is turned off.
- Surfaces timer state continuously through a tinted player icon and an above-mini-player status chip with a live countdown, and emits one-shot events that drive foreground "ended" and "cancelled" snackbars.
- Hides the end-of-chapter option when the current episode carries no chapter data, keeping the menu honest about what is possible, and keeps an armed end-of-chapter timer inactive while chapters are unavailable.
- Reports each armed timer to analytics (mode and, where relevant, the chosen value) for product insight.

## Boundaries

- This FR covers only the sleep timer. General playback control — play/pause, seeking, speed, queue advance, background audio, lock-screen controls — belongs to FR 04 (Audio playback). The sleep timer observes playback lifecycle events and asks the player to fade and pause, but does not own playback itself.
- Chapter detection and transcript display are not defined here; the timer only consumes a "does the current episode have chapters" signal and a chapter-boundary signal derived from existing chapter data.
- No timer state is persisted across app restarts or surfaced to the lock screen; only the remembered minute/episode values are stored. There is no system notification when a timer fires while the app is backgrounded.
- The feature does not provide shake-to-extend or "add 5 minutes" gestures, per-podcast sleep-timer defaults, or any lock-screen sleep-timer control. These are explicitly deferred.

## Traceability

- **Source docs**:
  - `docs/superpowers/specs/2026-04-14-sleep-timer-design.md`
  - `docs/superpowers/plans/2026-04-14-sleep-timer.md`
- **Source files**:
  - `packages/audiflow_domain/lib/src/features/player/models/sleep_timer_config.dart`
  - `packages/audiflow_domain/lib/src/features/player/models/sleep_timer_state.dart`
  - `packages/audiflow_domain/lib/src/features/player/models/sleep_timer_event.dart`
  - `packages/audiflow_domain/lib/src/features/player/services/sleep_timer_service.dart`
  - `packages/audiflow_domain/lib/src/features/player/services/chapter_crossing_tracker.dart`
  - `packages/audiflow_domain/lib/src/features/player/datasources/local/sleep_timer_preferences_datasource.dart`
  - `packages/audiflow_domain/lib/src/features/player/controllers/sleep_timer_controller.dart`
  - `packages/audiflow_domain/lib/src/features/player/providers/sleep_timer_providers.dart`
  - `packages/audiflow_app/lib/features/player/presentation/controllers/sleep_timer_ui_controller.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_sheet.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_sheet_status_line.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_numeric_panel.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_chip.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_icon_button.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_status_label.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_label_format.dart`
- **Related FR**: `04-audio-playback.md`
