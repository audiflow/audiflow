# Voice UI Redesign

## Summary

Replace the current full-screen overlay + center-docked nav button voice interface with a sophisticated, compact floating panel anchored to an app bar trigger. Use a CustomPainter-based audio waveform visualization with audiflow brand colors for a podcast-native aesthetic.

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Visual style | Audio waveform (frequency bars) | Podcast-native, brand-aligned |
| Overlay type | Compact floating panel | Non-intrusive, quick interactions |
| Trigger location | Inline app bar icon (all form factors) | Cleaner layout, no center-docked nav button |
| Settings interactions | Inside floating panel | Consistent interaction model |
| Animation engine | CustomPainter | Full control, 60fps, zero dependencies |
| Panel width | Fixed (240pt) | No horizontal resizing; vertical expansion OK for content like disambiguation lists |

## Current Architecture

The voice trigger button (`_VoiceNavButton`) lives inside `scaffold_with_nav_bar.dart` as a private widget:
- **Phone**: center-docked in bottom nav bar (raised 8pt, circular, 48x48)
- **Tablet portrait**: `AppBar.actions`
- **Tablet landscape**: `NavigationRail.leading`

The full-screen overlay (`VoiceListeningOverlay`) is stacked on top of the shell in the same file (line 106).

`VoiceCommandFab` exists as a standalone file but is **unused** in the main navigation flow.

## Files Changed

| File | Action | Purpose |
|------|--------|---------|
| `voice_command_fab.dart` | Delete | Unused, superseded by `_VoiceNavButton` |
| `voice_listening_overlay.dart` | Rewrite to `voice_command_panel.dart` | Compact floating panel with all states |
| `scaffold_with_nav_bar.dart` | Modify | Remove `_VoiceNavButton`, remove center nav button slot, replace overlay with panel, add `VoiceTriggerButton` to app bar across all form factors |
| (new) `voice_trigger_button.dart` | Create | App bar mic icon with state-aware styling |
| (new) `waveform_painter.dart` | Create | CustomPainter for animated frequency bars |

### Unchanged

- `voice_command_controller.dart` — thin wrapper, still valid
- All domain layer code (orchestrator, executor, resolver, state model)
- `VoiceRecognitionState` sealed type — all 8 variants remain

## Component 1: WaveformPainter

CustomPainter rendering animated audio frequency bars.

### Visual spec

- Bar count: 12
- Bar width: 3pt, rounded caps (`StrokeCap.round`)
- Bar spacing: 3pt gap
- Bar height: sinusoidal animation with per-bar phase offset
- Gradient per bar: `#0D47A1` (bottom) to `#FFC107` (top) — brand primary to accent
- Glow: subtle shadow beneath bars using the gradient midpoint color

### Animation modes

| State | Speed | Amplitude | Color |
|-------|-------|-----------|-------|
| Listening | 800ms cycle | Full (min 4pt, max 40pt) | Full gradient `#0D47A1` to `#FFC107` |
| Processing | 2000ms cycle | Reduced (min 4pt, max 16pt) | Muted — `#0D47A1` to `#1976D2` |
| Other | N/A | Collapsed (all bars at 4pt) | Muted |

### Implementation

- Extends `CustomPainter` with `Animation<double>` as repaint trigger
- `AnimationController` drives a single 0.0-1.0 loop
- Bar heights computed as: `minHeight + amplitude * sin(animation.value * 2pi + barIndex * phaseOffset)`
- Phase offset per bar: `barIndex * 0.5` for organic wave motion
- Gradient painted per bar via `Paint..shader` with `LinearGradient`

## Component 2: VoiceCommandPanel

Compact floating card rendering all voice states.

### Layout

- Fixed width: 240pt (never changes regardless of content)
- Height: adapts to content (vertical expansion OK for disambiguation lists, etc.)
- Anchored: top-right, directly below the app bar trigger button
- Corner radius: 16pt
- Background: dark glassmorphic — `BackdropFilter` with `ImageFilter.blur(sigmaX: 20, sigmaY: 20)`, semi-transparent dark surface (`colorScheme.surface` at 0.92 opacity)
- Border: 1px `colorScheme.outlineVariant` at 0.15 opacity
- Shadow: multi-layered per project theming rules
  - Layer 1: `offset(0, 8), blur(32), black at 0.4`
  - Layer 2: `offset(0, 2), blur(8), black at 0.2`

### Transitions

- Appear: `FadeTransition` (0.0 to 1.0, 200ms, `Curves.easeOut`) + `ScaleTransition` (0.95 to 1.0, same curve)
- Disappear: reverse of appear (150ms, `Curves.easeIn`)
- Content state changes: crossfade within fixed-width bounds via `AnimatedSwitcher`
- Height changes between states: `AnimatedSize` for smooth vertical transition

### Content per state

**VoiceIdle**: Panel hidden (SizedBox.shrink)

**VoiceListening**:
- WaveformPainter (listening mode) — height: 48pt
- Status text: "Listening..." (body medium, on-surface)
- Partial transcript: italic, on-surface-variant, max 2 lines with ellipsis
- Cancel text button

**VoiceProcessing**:
- WaveformPainter (processing mode) — height: 48pt
- Status text: "Processing..." (body medium, on-surface)
- Full transcript in quotes (body small, on-surface-variant)

**VoiceExecuting**:
- Same as Processing but status text shows intent name

**VoiceSuccess**:
- Check icon in circular tinted container (tertiary color)
- Success message (body medium, tertiary)
- Auto-dismiss after 2s, tap to dismiss immediately

**VoiceError**:
- Error icon in circular tinted container (error color)
- Error message (body medium, error)
- "Tap mic to try again" hint (body small, on-surface-variant)
- Auto-dismiss after 2s, tap to dismiss immediately

**VoiceSettingsAutoApplied**:
- Check icon (tertiary)
- Setting name + old value arrow new value
- Undo text button

**VoiceSettingsDisambiguation**:
- "Which setting?" header (body medium)
- Candidate list (renders all candidates, panel height adapts)
- Each candidate: setting name, new value, confidence badge
- Highest confidence candidate highlighted with primary tint
- Cancel text button

**VoiceSettingsLowConfidence**:
- Help icon (tertiary)
- Setting name + old value arrow new value with question mark
- Row: Cancel text button + Confirm filled button (compact sizing)

### Constraint: Fixed width, flexible height

The panel width is always 240pt. Height adapts to content:
- Text: truncates with ellipsis (max lines enforced)
- Disambiguation list: all candidates shown, panel grows vertically
- Buttons: use compact sizing to fit within padding
- Max height capped at 70% of screen height with internal scroll if exceeded

## Component 3: VoiceTriggerButton

Inline app bar action replacing the center-docked nav button.

### Visual spec

- Container: 36x36pt, rounded rectangle (corner radius: 10pt)
- Background tint: `colorScheme.primary` at varying opacity per state
- Icon: Material Symbols `mic` / `mic` filled, 20pt

### State mapping

| State | Background | Icon color | Icon fill | Extra |
|-------|-----------|------------|-----------|-------|
| Idle | primary at 0.1 | primary | 0 (outline) | None |
| Listening | primary at 0.25 | accent `#FFC107` | 1 (filled) | Outer glow shadow (primary at 0.4, blur 12) |
| Processing | primary at 0.15 | primary | 0 | Subtle opacity pulse (0.7 to 1.0, 1200ms) |
| Executing | primary at 0.15 | primary | 0 | Same as processing |
| Success | tertiary at 0.15 | tertiary | 0 | None |
| Error | error at 0.15 | error | 0 | None |
| Settings states | secondary at 0.15 | secondary | 0 | None |

### Behavior

- Tap in Idle: starts voice command
- Tap while Listening: cancels voice command
- Tap while Processing/Executing: disabled
- Tap while Success/Error: resets to idle
- All transitions use `AnimatedContainer` (200ms, `Curves.easeInOut`)

## Integration

### scaffold_with_nav_bar.dart changes

**Phone layout (`_PhoneShell` / `_CustomNavBar`)**:
- Remove the center `SizedBox(width: 72)` placeholder from the nav bar `Row`
- Remove the `Positioned(top: -8, child: _VoiceNavButton())` from the nav bar `Stack`
- The phone shell currently uses no AppBar. Add a `SliverAppBar` or wrap in a `Scaffold` with an `AppBar` that includes `VoiceTriggerButton` in `actions`. Alternatively, the individual screens already have their own app bars — in that case, each tab screen's app bar gains the `VoiceTriggerButton` in its `actions`. The approach depends on existing screen app bar patterns — the implementer should check each tab screen and add `VoiceTriggerButton` to existing `AppBar.actions` arrays.

**Tablet portrait (`_TabletPortraitShell`)**:
- Replace `_VoiceNavButton()` in `AppBar.actions` with `VoiceTriggerButton()`

**Tablet landscape (`_TabletLandscapeShell`)**:
- Replace `_VoiceNavButton()` in `NavigationRail.leading` with `VoiceTriggerButton()`

**Overlay replacement**:
- Remove `VoiceListeningOverlay` from the `Stack` in `ScaffoldWithNavBar.build()`
- Add `VoiceCommandPanel` in the same `Stack`, positioned with `Positioned(top:, right:)` to align below the app bar

### Removing old code

- Delete `voice_command_fab.dart` (unused file)
- Delete `_VoiceNavButton` private class from `scaffold_with_nav_bar.dart`
- Remove `voice_listening_overlay.dart` import from `scaffold_with_nav_bar.dart`

## Testing

- Widget tests for `VoiceTriggerButton`: verify icon/color per state, tap behavior
- Widget tests for `VoiceCommandPanel`: verify content per state, fixed width constraint (240pt), vertical growth for disambiguation, dismiss behavior
- Golden tests for waveform painter: snapshot at key animation frames
- Existing domain layer tests: unchanged, no modifications needed

## Out of scope

- Audio-reactive waveform (responding to actual microphone input levels) — uses deterministic sinusoidal animation
- Haptic feedback on state transitions
- Custom transition between panel content states beyond AnimatedSwitcher crossfade
