# Sleep Timer — Design

Status: approved (brainstorming) — 2026-04-14
Scope: audiflow Flutter app

## Goal

Let users end playback after a chosen condition — matching Apple Podcasts / Pocket Casts ergonomics with a compact, opinionated menu:

1. **Off** (always visible)
2. **End of episode**
3. **End of chapter** (shown only when the current episode has chapter data)
4. **Set minutes** / remembered value (e.g. "30 minutes")
5. **Set episodes** / remembered value (e.g. "3 episodes")

Remembered values persist globally across app restarts. Active timer state is session-only and dies with the process.

## User experience

### Entry points

- **Sleep icon** in the full-player action row (`nights_stay`, existing row alongside speed / queue / etc.). Tint changes to primary color when a timer is active.
- **Status chip** rendered above the mini-player bar (between mini-player and bottom nav) when a timer is active. Hidden otherwise.
  - `End of episode` → "Sleep · Episode end"
  - `End of chapter` → "Sleep · Chapter end"
  - `Duration` → "Sleep · 12:34" (mm:ss < 1h, h:mm:ss ≥ 1h; updates every second)
  - `N episodes` → "Sleep · 3 eps left"
- Tapping the chip opens the sleep timer sheet directly, regardless of current route. No navigation.
- Tapping the sleep icon on the full player opens the same sheet.

### Bottom sheet

Single modal sheet surface. Content swaps between the **menu panel** and the **numeric input panel** — no nested sheets.

**Menu panel entries (always in this order):**

| # | Label | Visibility | Active-state marker |
|---|-------|-----------|---------------------|
| 1 | Off | Always | Muted when no timer is active; destructive accent when active |
| 2 | End of episode | Always | ✓ when active |
| 3 | End of chapter | Only when `currentEpisode.chapters` is non-empty | ✓ when active |
| 4 | Set minutes / "30 minutes" | Always | ✓ when active; pencil edit icon when a value is remembered |
| 5 | Set episodes / "3 episodes" | Always | ✓ when active; pencil edit icon when a value is remembered |

Short-tap vs long-press on entries 4 and 5:

- First time (no remembered value, label is "Set minutes" / "Set episodes") → short-tap opens the numeric input panel.
- Remembered value present (label is e.g. "30 minutes" with edit icon) → short-tap **starts the timer immediately** with the remembered value; long-press opens the numeric input panel pre-filled with that value.
- Tapping the already-active entry is a no-op. Cancel only through "Off" (one-way cancel).

### Numeric input panel

Top bar: back arrow · "Minutes" or "Episodes" · close ✕
Large numeric readout (current value, starts at remembered value or empty).
Number pad: 0–9, backspace.
Full-width primary "Start" button at the bottom.

Bounds:
- Minutes: 1–999 (clamp on Start, disable Start when value is 0)
- Episodes: 1–99

On Start: persist the value globally, commit the corresponding `SleepTimerConfig`, dismiss the sheet.

### Behavior when timer fires

1. 8-second linear fade-out from the current volume to 0.
2. `pause()`.
3. Volume restored to original for the next playback session.
4. Controller emits a one-shot `SleepTimerFired` event.
5. If the app is foregrounded, the player/mini-player host shows a "Sleep timer ended" snackbar. If backgrounded, no notification is posted.
6. Config resets to `off()`. Remembered minutes/episodes are unaffected.

### Edge cases (AABB)

| Scenario | Behavior |
|---|---|
| "End of episode" active, user manually switches episode | Timer transfers to the new current episode |
| "N episodes" active, user manually skips to next | Skip does **not** decrement; only natural completion decrements |
| "End of chapter" active, user seeks past the chapter boundary | Retarget to the new current chapter |
| App killed / force-quit | Timer dies (session-only); remembered minutes/episodes survive |
| Duration timer fires while paused | Fires anyway (wall-clock based) |
| `N=1` and episode completes naturally | Fires at completion, before auto-advance |
| User toggles off mid-fade | Fade cancels, volume restores |
| Episode changes to one without chapters while `endOfChapter` active | Config falls back to `off()` |

## Architecture

Approach 3 from brainstorming: pure service + Riverpod controller glue. Matches the existing `audiflow_domain/src/features/player/` layout.

### Files

```
packages/audiflow_domain/lib/src/features/player/
├── models/
│   ├── sleep_timer_config.dart               # @freezed sealed
│   ├── sleep_timer_config.freezed.dart
│   ├── sleep_timer_state.dart                # @freezed
│   ├── sleep_timer_state.freezed.dart
│   └── sleep_timer_event.dart                # one-shot events
├── services/
│   └── sleep_timer_service.dart              # pure Dart
├── datasources/local/
│   └── sleep_timer_preferences_datasource.dart
└── controllers/
    ├── sleep_timer_controller.dart           # @Riverpod(keepAlive: true)
    └── sleep_timer_controller.g.dart
```

App-side presentation:

```
packages/audiflow_app/lib/features/player/presentation/
├── widgets/
│   ├── sleep_timer_chip.dart
│   ├── sleep_timer_icon_button.dart
│   ├── sleep_timer_sheet.dart                # menu + numeric-input content swap
│   └── sleep_timer_numeric_panel.dart
└── controllers/
    └── sleep_timer_ui_controller.dart        # snackbar wiring, open-sheet-from-chip
```

### Domain models

```dart
@freezed
sealed class SleepTimerConfig with _$SleepTimerConfig {
  const factory SleepTimerConfig.off() = _SleepTimerOff;
  const factory SleepTimerConfig.endOfEpisode() = _SleepTimerEndOfEpisode;
  const factory SleepTimerConfig.endOfChapter() = _SleepTimerEndOfChapter;
  const factory SleepTimerConfig.duration({
    required Duration total,
    required DateTime deadline,
  }) = _SleepTimerDuration;
  const factory SleepTimerConfig.episodes({
    required int total,
    required int remaining,
  }) = _SleepTimerEpisodes;
}

@freezed
class SleepTimerState with _$SleepTimerState {
  const factory SleepTimerState({
    required SleepTimerConfig config,
    required int lastMinutes,   // 0 when never set
    required int lastEpisodes,  // 0 when never set
  }) = _SleepTimerState;
}

sealed class SleepTimerEvent {
  const SleepTimerEvent();
}
final class SleepTimerFired extends SleepTimerEvent {
  const SleepTimerFired();
}
```

### Service (pure logic)

```dart
sealed class SleepTimerPlayerEvent {
  const SleepTimerPlayerEvent();
}
final class TickEvent extends SleepTimerPlayerEvent {
  const TickEvent(this.now);
  final DateTime now;
}
final class EpisodeCompletedEvent extends SleepTimerPlayerEvent {
  const EpisodeCompletedEvent();
}
final class ManualEpisodeSwitchedEvent extends SleepTimerPlayerEvent {
  const ManualEpisodeSwitchedEvent();
}
final class ChapterChangedEvent extends SleepTimerPlayerEvent {
  const ChapterChangedEvent();
}
final class SeekedPastChapterEvent extends SleepTimerPlayerEvent {
  const SeekedPastChapterEvent();
}

sealed class SleepTimerDecision {
  const SleepTimerDecision();
}
final class KeepDecision extends SleepTimerDecision {
  const KeepDecision();
}
final class FireDecision extends SleepTimerDecision {
  const FireDecision();
}
final class DecrementEpisodesDecision extends SleepTimerDecision {
  const DecrementEpisodesDecision();
}
final class RetargetChapterDecision extends SleepTimerDecision {
  const RetargetChapterDecision();
}

class SleepTimerService {
  const SleepTimerService();

  SleepTimerDecision evaluate({
    required SleepTimerConfig config,
    required SleepTimerPlayerEvent event,
    required bool currentEpisodeHasChapters,
  });
}
```

Decision rules:

| Config | Event | Decision |
|---|---|---|
| `off` | any | `KeepDecision` |
| `endOfEpisode` | `EpisodeCompletedEvent` | `FireDecision` |
| `endOfEpisode` | `ManualEpisodeSwitchedEvent` | `KeepDecision` (transfers implicitly) |
| `endOfChapter` | `ChapterChangedEvent` | `FireDecision` (chapter rolled over while timer waited) |
| `endOfChapter` | `SeekedPastChapterEvent` | `RetargetChapterDecision` |
| `duration(total, deadline)` | `TickEvent(now)` when `deadline <= now` | `FireDecision` |
| `episodes(n, remaining=1)` | `EpisodeCompletedEvent` | `FireDecision` |
| `episodes(n, remaining>1)` | `EpisodeCompletedEvent` | `DecrementEpisodesDecision` |
| `episodes(_)` | `ManualEpisodeSwitchedEvent` | `KeepDecision` |

Timestamp comparison uses `deadline <= now` rather than `now >= deadline`, per project number-rules.

### Preferences datasource

Uses the existing `SharedPreferencesDatasource` from `audiflow_domain/common/datasources`.

Keys (both `int`):

- `sleep_timer.last_minutes`
- `sleep_timer.last_episodes`

Read on `SleepTimerController.build()`; write on `setDuration(d)` and `setEpisodes(n)`. Config is not persisted.

### Controller

`@Riverpod(keepAlive: true) class SleepTimerController extends _$SleepTimerController`.

Responsibilities:

- Build state from preferences snapshot.
- Expose mutation methods: `setOff()`, `setEndOfEpisode()`, `setEndOfChapter()`, `setDuration(Duration total)`, `setEpisodes(int total)`.
- Start/stop a `Timer.periodic(Duration(seconds: 1))` only while `config` is `duration(...)`. Each tick dispatches a `TickEvent`; also drives the chip countdown.
- Subscribe to player streams (`audioPlayerController` position/completion/episode change, and a derived chapter-change signal) and dispatch the matching service events.
- Translate service decisions into side effects:
  - `FireDecision` → invoke fade-out helper, emit `SleepTimerFired` event, reset config to `off()`.
  - `DecrementEpisodesDecision` → update `config = episodes(total, remaining-1)` and emit new state.
  - `RetargetChapterDecision` → keep config; chapter index comes from player.
  - `KeepDecision` → no-op.
- Guard fallback: when `currentEpisodeHasChapters` becomes false while `config` is `endOfChapter`, reset to `off()`.
- Expose a `Stream<SleepTimerEvent>` (broadcast controller) for one-shot UI events (snackbar, optional haptics).
- Expose `Duration? remaining()` / a derived stream for the chip — computed from the current `config`.

### Fade-out

Implemented as a helper on `AudioPlayerController`:

```dart
Future<void> fadeOutAndPause({Duration total = const Duration(seconds: 8)});
```

Linear fade: read current volume, step down to 0 over `total`, `await pause()`, restore original volume. Cancellable via a cancel token so `setOff()` mid-fade aborts the fade and restores volume.

The audio handler is unchanged; it continues to pipe `just_audio` events into `playbackState`, so the lock screen sees a normal pause once the fade completes.

### Event plumbing for chapter signals

`audiflow_podcast` already extracts chapters. Current player infrastructure does not expose a chapter-change stream. Two options, resolved in the plan:

1. Derive chapter index from the position stream + current episode chapters inside the controller (simplest — no new stream needed).
2. Add a `currentChapterIndex` stream on `audioPlayerController`.

Plan will go with option 1 first; move to option 2 only if the controller grows too heavy.

## Localization

Add the following keys to `packages/audiflow_app/lib/l10n/app_en.arb` and `app_ja.arb`, then run `flutter gen-l10n`.

| Key | English | Japanese |
|---|---|---|
| `sleepTimerTitle` | Sleep Timer | スリープタイマー |
| `sleepTimerOff` | Off | オフ |
| `sleepTimerEndOfEpisode` | End of episode | エピソードの終わり |
| `sleepTimerEndOfChapter` | End of chapter | チャプターの終わり |
| `sleepTimerSetMinutes` | Set minutes | 分数を設定 |
| `sleepTimerSetEpisodes` | Set episodes | エピソード数を設定 |
| `sleepTimerMinutesLabel` | `{count, plural, one{{count} minute} other{{count} minutes}}` | `{count}分` |
| `sleepTimerEpisodesLabel` | `{count, plural, one{{count} episode} other{{count} episodes}}` | `{count}エピソード` |
| `sleepTimerChipEpisodeEnd` | Sleep · Episode end | スリープ · エピソード末 |
| `sleepTimerChipChapterEnd` | Sleep · Chapter end | スリープ · チャプター末 |
| `sleepTimerChipEpisodesLeft` | `Sleep · {count} eps left` | `スリープ · 残り{count}本` |
| `sleepTimerChipDurationPrefix` | Sleep · | スリープ · |
| `sleepTimerFiredSnackbar` | Sleep timer ended | スリープタイマーが終了しました |
| `sleepTimerNumericMinutesTitle` | Minutes | 分 |
| `sleepTimerNumericEpisodesTitle` | Episodes | エピソード |
| `sleepTimerStart` | Start | 開始 |

## Testing

### Unit tests

- `sleep_timer_service_test.dart` — every row of the decision table, including boundary `deadline == now`, `remaining == 1` transition, and `off` config with every event type.
- `sleep_timer_preferences_datasource_test.dart` — read/write bounds, defaults when keys absent.
- `sleep_timer_controller_test.dart` — `ProviderContainer` with fake `audioPlayerController` (hand-written fake per project rule) and fake preferences datasource. Covers: setting each config, persistence side effects, decrement flow, fire flow, fade-out cancellation on `setOff`, chapter-disappears fallback.
- Use `fake_async` for all tests involving timers.

### Widget tests

- `sleep_timer_sheet_test.dart` — menu entries in each state (no timer, duration active, episodes active, endOfEpisode active, endOfChapter available/unavailable), short-tap vs long-press behavior on remembered entries, content swap to numeric panel, clamp bounds on Start.
- `sleep_timer_chip_test.dart` — visibility matrix by config, label formatting, tap routes to sheet.
- `sleep_timer_icon_button_test.dart` — tint change when active.

### Out of scope for testing

- No integration tests for fade timing (covered by unit tests with `fake_async`).
- No tests for lock-screen / notification rendering (delegated to `audio_service`).

## Out of scope for this design

- Shake-to-extend / "add 5 minutes" gesture.
- Background snackbar / system notification when app is not foregrounded.
- Lock-screen sleep timer control.
- Per-podcast sleep-timer defaults.

These can be added as follow-ups without breaking the model.
