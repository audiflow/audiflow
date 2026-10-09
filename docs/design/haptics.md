---
refs:
  id: design:haptics
  kind: design
  title: "Haptic feedback design system"
  related:
    - design:redesign
    - fr:04-audio-playback
    - fr:05-download-and-queue
    - fr:07-stations
    - fr:09-sleep-timer
    - fr:14-settings
    - fr:18-parental-control
  modules:
    - packages/audiflow_ui/lib/src/haptics/
    - packages/audiflow_ui/lib/src/widgets/
    - packages/audiflow_app/lib/app/haptics/
---
# Haptic feedback design system

> The catalog of haptic tokens the app may play, what each one means, how it is realized on iOS and Android, and which interactions use it. Features request haptics by meaning (a token), never by calling a platform haptic API directly.

Status: **catalog approved (issue #611); foundation implemented (#612).** Applying tokens to screens, and the settings row for the user level, are tracked under #610. Functional Requirements under `docs/fr/` describe current behavior and are updated in the PR that ships each change.

## 1. Principles

These are the rules every haptic in the app follows. Each one is stated by more than one of the sources in section 8.

1. **One meaning, one feel.** A token is played only for its documented meaning. Opposite outcomes (success and error, on and off) never share a feel.
2. **Restraint.** Plain taps and navigation get no haptic. Haptics mark moments the user would otherwise miss: an outcome, a gesture becoming armed, an object being picked up.
3. **Frequent means faint.** The more often a haptic can fire, the weaker it is. Continuous gestures (scrubbing, slider drags) do not tick on every step; on-device testing already removed the per-band seek-bar haptic and the per-step speed-slider haptic because they read as noise.
4. **Short and crisp.** Every token is a single transient or a short platform pattern. No long buzzes; on Android, no one-shot or waveform vibrations for touch feedback.
5. **In sync with the visual.** A haptic fires in the same frame as the visual change it confirms, never after an async round trip completes unless the token is an outcome (`success`, `error`).
6. **Never the only signal.** Every haptic accompanies a visible change. iPad, the iOS Simulator, and devices with haptics turned off get no haptics at all.
7. **The user can turn it down.** The app offers On / Reduced / Off (section 5), on top of the OS-level settings.

## 2. Token catalog

Tokens are named by meaning. The platform columns give the realization; section 4 covers older Android versions.

| Token | Meaning | iOS | Android (API 34+) | Reduced mode |
|---|---|---|---|---|
| `selection` | One discrete option became selected | `UISelectionFeedbackGenerator` | `SEGMENT_TICK` | off |
| `toggleOn` | A switch turned on | `UIImpactFeedbackGenerator(.light)`, intensity 0.5 | `TOGGLE_ON` | off |
| `toggleOff` | A switch turned off | `UIImpactFeedbackGenerator(.soft)`, intensity 0.4 | `TOGGLE_OFF` | off |
| `tap` | A low-key action was accepted, where the result is not otherwise felt | `UIImpactFeedbackGenerator(.light)` | `VIRTUAL_KEY` | off |
| `longPress` | A long press reached its activation time | `UIImpactFeedbackGenerator(.medium)` | `LONG_PRESS` | off |
| `thresholdCross` | A drag passed the point where releasing triggers an action | `UIImpactFeedbackGenerator(.medium)` | `GESTURE_THRESHOLD_ACTIVATE` | on |
| `thresholdRelease` | A drag moved back below that point, cancelling the action | `UIImpactFeedbackGenerator(.light)`, intensity 0.5 | `GESTURE_THRESHOLD_DEACTIVATE` | on |
| `dragPickUp` | A reorderable item was picked up | `UIImpactFeedbackGenerator(.medium)` | `DRAG_START` | on |
| `dragStep` | A dragged item moved past a neighbor | `UISelectionFeedbackGenerator` | `SEGMENT_FREQUENT_TICK` | off |
| `dragDrop` | A dragged item was put down | `UIImpactFeedbackGenerator(.light)` | `GESTURE_END` | off |
| `detent` | A continuous gesture passed a meaningful mark | `UIImpactFeedbackGenerator(.rigid)`, intensity 0.5 | `SEGMENT_TICK` | off |
| `success` | A user-initiated task completed | `UINotificationFeedbackGenerator(.success)` | `CONFIRM` | on |
| `warning` | A confirmation for an irreversible action appeared | `UINotificationFeedbackGenerator(.warning)` | none (see note) | on |
| `error` | A user-initiated task failed | `UINotificationFeedbackGenerator(.error)` | `REJECT` | on |

`none` is not played; it is a documented decision that an interaction gets no haptic (section 3).

Notes:

- **`warning` on Android plays nothing.** Android has no warning constant. The candidates are already taken: `CONFIRM` is `success`, `REJECT` is `error`, and `LONG_PRESS` is `longPress`. A composed pattern would need the `VIBRATE` permission. `warning` only appears with a confirmation dialog, which is visible, so silence is preferred over a discordant substitute.
- **`selection` and `detent` feel the same on Android.** Both map to `SEGMENT_TICK`. They never fire in the same gesture, and neither has an opposite, so sharing a feel does not break principle 1.
- **`tap` is rare on purpose.** Play/pause and skip do not use it (section 3). It is reserved for low-key actions whose result is not otherwise felt.

## 3. Interaction mapping

**`selection` rule.** `selection` plays whenever a persistent choice changes: which items are shown, in what order, or in what mode. It applies whatever the control looks like (segmented control, chip, picker menu, sort sheet, sort toggle button) and only when the value actually changes. It does not apply to action menus (do something once) or to navigation (tabs, the year jump picker). A new choice control follows this rule without a new table row.

**`selection` rule.** `selection` plays whenever a persistent choice changes: which items are shown, in what order, or in what mode. It applies whatever the control looks like (segmented control, chip, picker menu, sort sheet, sort toggle button) and only when the value actually changes. It does not apply to action menus (do something once) or to navigation (tabs, the year jump picker). A new choice control follows this rule without a new table row.

Every interaction that was considered is listed here, including those that deliberately get no haptic. When a new interaction is added, it gets a row in this table.

| Screen / interaction | Token |
|---|---|
| Play / pause (full player, mini player) | `none` |
| Skip back / forward | `none` |
| Seek bar drag and speed-band changes | `none` (removed after on-device testing) |
| Seek bar crosses a chapter boundary | `detent` |
| Speed slider, per step | `none` (removed after on-device testing) |
| Speed slider crosses 1.0x | `detent` |
| Speed preset chip | `selection` |
| Sleep timer option chosen | `selection` |
| Sleep timer long press opens the keypad | `longPress` |
| Sleep timer keypad digits | `none` (custom keypad buttons deliberately stay silent) |
| Sleep timer fired / cancelled | `none` (the app is usually in the background; see section 6) |
| Queue row swipe (remove, download) crosses / un-crosses its threshold | `thresholdCross` / `thresholdRelease` |
| Queue and station reorder: pick up / move / drop | `dragPickUp` / `dragStep` / `dragDrop` |
| Add-to-queue long press (Play Next) | `longPress` |
| Episode and queue long-press menus, and long-press to copy a playback record value | `longPress` |
| Subscribe | `success` |
| Unsubscribe | `tap` |
| Pull-to-refresh crosses / un-crosses its threshold | `thresholdCross` / `thresholdRelease` |
| Refresh or download failure not started by the user | `none` |
| Download start | `none` (the snackbar is enough) |
| Bottom tabs and screen navigation | `none` |
| Segmented controls and filter chips | `selection` |
| Podcast detail filter menu, playlist selector, and newest/oldest toggle | `selection` |
| Episode, smart playlist, and play order sort sheets; library sort menu; search country picker | `selection` |
| Podcast detail filter menu, playlist selector, and newest/oldest toggle | `selection` |
| Episode, smart playlist, and play order sort sheets; library sort menu; search country picker | `selection` |
| Settings switches (and the other preference switches: audio sheet, station filters) | `toggleOn` / `toggleOff` |
| Clear-queue and bulk-delete confirmation | `warning` |
| Wrong PIN and PIN lockout | `error` |
| Full player open / close | `none` |
| Seek undo | `tap` |

## 4. Platform realization

### 4.1 iOS

- Tokens play through UIKit feedback generators. Core Haptics is not used.
- The foundation keeps one impact generator per style used by the catalog (`.light`, `.soft`, `.medium`, `.rigid`), one selection generator, and one notification generator. The impact style is fixed when a generator is created, so styles cannot share one generator. It calls `prepare()` on the relevant generators when a gesture that may fire a token begins (drag start, long-press down). Calling `prepare()` immediately before firing does not reduce latency.
- Intensities in the catalog use `impactOccurred(intensity:)`.
- The OS System Haptics switch silences everything. The app cannot read it, so the in-app setting is independent.

### 4.2 Android

- Tokens play through `View.performHapticFeedback` with `HapticFeedbackConstants`. This needs no `VIBRATE` permission and follows the user's touch-feedback setting. `Vibrator` and `VibrationEffect` are not used.
- When a constant is newer than the running OS, the foundation substitutes the nearest older constant, following the AndroidX `HapticFeedbackConstantsCompat` approach:

| Constant | Since | Substitute on older OS |
|---|---|---|
| `TOGGLE_ON` | 34 | `CLOCK_TICK` |
| `TOGGLE_OFF` | 34 | `CLOCK_TICK` |
| `DRAG_START` | 34 | `LONG_PRESS` |
| `SEGMENT_TICK` | 34 | `CLOCK_TICK` |
| `SEGMENT_FREQUENT_TICK` | 34 | `CLOCK_TICK` |
| `GESTURE_THRESHOLD_ACTIVATE` | 34 | `CONTEXT_CLICK` |
| `GESTURE_THRESHOLD_DEACTIVATE` | 34 | `CLOCK_TICK` |
| `CONFIRM` | 30 | `VIRTUAL_KEY` |
| `REJECT` | 30 | `VIRTUAL_KEY`, played twice 200 ms apart |
| `GESTURE_END` | 30 | `CLOCK_TICK` |

  The substitutes below API 30 are provisional until checked on a device (section 7). On Android 8 to 10 the old constants play waveforms that each manufacturer defines, so their relative strength is not guaranteed (on a tested Huawei device, `VIRTUAL_KEY` felt stronger than `LONG_PRESS`). `error` is therefore told apart from `success` by rhythm, two taps against one, rather than by strength, mirroring `REJECT`'s double click. `success` feels like `tap` there, which is accepted because the two do not have opposite meanings.

### 4.3 Why not Flutter's `HapticFeedback`

Flutter's built-in API (as of Flutter 3.47.6) cannot express this catalog:

- On Android, `heavyImpact` maps to `CONTEXT_CLICK`. In current AOSP source that constant plays `EFFECT_TICK`, which is lighter than the click that `lightImpact` plays, so the impact scale can come out inverted. Android does not define a strength for `CONTEXT_CLICK`, and manufacturers can retune it, so this is a source-level observation still to be confirmed on devices (section 7).
- The notification methods (`successNotification` and the others) play nothing below Android 11.
- It does not reach the API 34 constants, rigid/soft impacts, or impact intensity.
- On iOS, it creates a new generator for each call and never calls `prepare()`.

The foundation therefore uses a thin platform channel of its own (#612).

### 4.4 Framework feedback

Flutter's Material widgets can play their own feedback. With `enableFeedback` left at its default, `InkWell`, `InkResponse`, and the button widgets call `Feedback.forLongPress` on a long press, which plays a haptic on both platforms (`vibrate` on Android, `heavyImpact` on iOS). `Feedback.forTap` plays only a click sound on Android and nothing on iOS.

A widget that plays a catalog token on long press must set `enableFeedback: false`, or the token plays alongside the framework's haptic. The existing add-to-queue button is such a widget. If the widget still needs the Android tap sound, it calls `Feedback.forTap` itself in its tap handler.

### 4.5 Code map

| Piece | Location |
|---|---|
| Tokens, `HapticPlayer`, level gating, `HapticsScope` | `packages/audiflow_ui/lib/src/haptics/` |
| Channel player, level controller, providers | `packages/audiflow_app/lib/app/haptics/` |
| iOS mapping | `packages/audiflow_app/ios/Runner/HapticsChannel.swift` |
| Android mapping | `packages/audiflow_app/android/app/src/main/kotlin/com/reedom/audiflow_app/HapticsChannel.kt` |
| Persisted level | `SettingsKeys.hapticFeedbackLevel`, `AppSettingsRepository.getHapticFeedbackLevel` |

The channel is `audiflow/haptics`, with methods `play` and `prepare` that take a token name. A token the native side does not know plays nothing.

## 5. User setting

A single preference with three values:

| Value | Behavior |
|---|---|
| On | All tokens play. |
| Reduced (default) | Only tokens marked "on" in the Reduced column of section 2 play: outcomes (`success`, `warning`, `error`), gesture thresholds, and drag pick-up. |
| Off | Nothing plays. |

Reduced mode drops tokens whose effect is already obvious on screen (selection, toggles, long press, drop, detents) and keeps those that confirm something the user cannot see well while their finger covers it, or that report an outcome.

## 6. Out of scope

- **Cues while the app is not in the foreground** (for example, before the sleep timer ends). Touch haptics are blocked in the background on both platforms. If wanted later, these belong to notification vibration, not to this catalog.
- **Custom patterns** (Core Haptics, Android compositions and envelopes). Add one only when a semantic token cannot be expressed with platform patterns, and document its fallback.
- **Audio-synchronized haptics.**

## 7. To verify on device

Outside production, Settings > Developer > Haptics catalog plays every token on tap, with a selector for the On / Reduced / Off level.

- iOS: whether Flutter's `Switch`, `CupertinoSwitch`, and `RefreshIndicator` already play a haptic, to avoid double feedback.
- Android: whether `heavyImpact` (`CONTEXT_CLICK`) really feels lighter than `lightImpact` on target devices.
- Android: how manufacturer tuning (Pixel, Galaxy) changes each constant, and how the pre-API-30 substitutes feel.
- Both: that `thresholdCross` and `thresholdRelease` are distinguishable, and that `dragStep` stays faint during a long reorder.

## 8. Sources

- Apple HIG, Playing haptics: https://developer.apple.com/design/human-interface-guidelines/playing-haptics
- `UIFeedbackGenerator.prepare()`: https://developer.apple.com/documentation/uikit/uifeedbackgenerator/prepare()
- WWDC21 "Practice audio haptic design": https://developer.apple.com/videos/play/wwdc2021/10278/
- Android haptics design principles: https://developer.android.com/develop/ui/views/haptics/haptics-principles
- Android, Add haptic feedback to events: https://developer.android.com/develop/ui/views/haptics/haptic-feedback
- AOSP haptics UX design: https://source.android.com/docs/core/interaction/haptics/haptics-ux-design
- AndroidX `HapticFeedbackConstantsCompat`: https://developer.android.com/reference/kotlin/androidx/core/view/HapticFeedbackConstantsCompat
- Meta Quest System Haptics: https://developers.meta.com/horizon/design/haptics-system/
- Pocket Casts iOS `HapticsHelper.swift`: https://github.com/Automattic/pocket-casts-ios
