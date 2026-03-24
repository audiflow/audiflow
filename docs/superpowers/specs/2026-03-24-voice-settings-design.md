# Voice Settings Control Design

## Overview

Enable users to change any app preference setting via voice commands using the existing voice command infrastructure. The on-device AI interprets fuzzy natural language expressions and resolves them to concrete setting changes.

## Goals

- Users can change any setting by voice without knowing exact setting names
- Support both absolute ("1.5倍にして") and relative ("もうちょっと速くして") value changes
- Follow system locale for voice command language
- Auto-apply clear commands; only show UI for ambiguous or low-confidence cases
- In-app only (existing voice FAB); Siri integration deferred to follow-up
- Single setting change per command; batch support deferred to follow-up

## AI Call Strategy: Single-pass Classification + Resolution

The existing `VoiceCommandService` classifies transcriptions into intents. Rather than making two sequential AI calls (classify intent, then resolve setting), we extend the classification prompt to also extract setting details when the intent is `changeSettings`. This keeps latency equivalent to other voice commands.

The `VoiceCommandService` prompt is extended so that when the AI identifies a `changeSettings` intent, it also returns the setting key, proposed value, and confidence -- all in one response. The `SettingsIntentResolver` then validates and normalizes this output against the `SettingsMetadataRegistry` (no second AI call).

## Voice Command Flow

```
User taps voice FAB
  -> Listening overlay appears (existing)
  -> Speech-to-text transcription (existing)
  -> VoiceCommandService parses intent (single AI call)
      - prompt includes settings snapshot alongside other intent definitions
      - for `changeSettings` intent, response includes: setting key, value, confidence
  -> SettingsIntentResolver validates AI output against registry
      - verifies key exists, value is within constraints
      - for relative expressions: AI returns direction + magnitude,
        resolver computes exact value deterministically
  -> Resolution:
      1 match, confidence >= 0.8  -> auto-apply + undo toast
      1 match, confidence < 0.8   -> show confirmation in overlay
      multiple matches            -> show disambiguation choices in overlay
      0 matches                   -> restart listening with prompt
```

## Resolution Logic

| Condition | Action |
|-----------|--------|
| 1 match, confidence >= 0.8 | Auto-apply, show undo toast in overlay |
| 1 match, confidence < 0.8 | Show confirmation with confirm/cancel in overlay |
| Multiple matches | Show candidate cards, user taps one to apply |
| 0 matches | Restart listening with guidance prompt |

Confidence threshold starts at 0.8, tunable via testing.

**Multi-match filtering:** Matches with confidence < 0.4 are discarded from the candidate list. If only one match remains after filtering, it follows the single-match path.

## New Components

### SettingsIntentResolver (`audiflow_domain`)

Lives in `audiflow_domain` (not `audiflow_ai`) because it depends on `SettingsMetadataRegistry`. It does not make its own AI call -- it receives the already-parsed AI output from `VoiceCommandService` and validates/normalizes it against the registry.

**AI prompt input:**
```
Available settings:
- playbackSpeed: 1.0 (range: 0.5-3.0, step: 0.1)
- skipSilence: false (boolean)
- theme: system (options: light, dark, system)
- autoDownload: true (boolean)
- downloadQuality: high (options: low, medium, high)
- ... all settings with current values, types, and valid ranges
```

**AI output (structured):**
```json
{
  "matches": [
    { "key": "playbackSpeed", "value": 1.1, "confidence": 0.95 }
  ]
}
```

**Relative value handling:** The AI outputs a directional intent (e.g. `{"key": "playbackSpeed", "direction": "increase", "magnitude": "small", "confidence": 0.95}`) rather than computing the arithmetic. The `SettingsIntentResolver` then applies the step deterministically: `currentValue + step * multiplier`. This avoids LLM arithmetic unreliability.

**Timeout/cancellation:** The resolver reuses the existing `CancellationToken` pattern from `audiflow_ai`. If the AI call does not return within 5 seconds, it cancels and the overlay transitions to an error state.

### SettingsMetadataRegistry (`audiflow_domain`)

Describes every voice-controllable setting:

- `key: String` -- setting key (e.g. "playbackSpeed")
- `displayNameKey: String` -- l10n key (e.g. "settingsPlaybackSpeed"), resolved to localized string by the UI layer
- `type: SettingType` -- boolean, double, int, enum
- `constraints` -- range + step for numeric, options list for enum
- `synonyms: List<String>` -- AI hints (e.g. ["速度", "スピード", "speed", "pace"])

When a new setting is added to the app, a corresponding registry entry must be added. No registry entry = not voice-controllable.

### SettingsSnapshotService (`audiflow_domain`)

Reads all settings from `AppSettingsRepository`, combines with registry metadata, and serializes into the prompt-ready text format. Called once per voice command invocation.

## Changes to Existing Code

| File | Change |
|------|--------|
| `VoiceCommand` model (`audiflow_ai`) | Add `changeSettings` intent; add `SettingsChangePayload` sealed class for settings-specific data (absolute value, or direction + magnitude for relative). Carried alongside the existing `parameters` map, not crammed into it |
| `VoiceCommandService` (`audiflow_ai`) | Extended prompt includes settings snapshot; for `changeSettings` intent, parse `SettingsChangePayload` from AI response |
| `VoiceCommandExecutor` (`audiflow_domain`) | Handle `changeSettings` -- add `AppSettingsRepository` dependency; for playback-affecting settings (e.g. speed), also call `AudioPlayerController` imperatively (the executor already holds `_audioController`). Capture previous value before applying for undo support |
| `VoiceRecognitionState` (`audiflow_domain`) | Add `settingsAutoApplied`, `settingsDisambiguation`, `settingsLowConfidence` states (prefixed to clarify they are settings-specific). Trade-off acknowledged: these are feature-specific states in a shared model, but this keeps the overlay's exhaustive switch simple and the compiler enforces handling everywhere |
| `VoiceCommandController` (`audiflow_app`) | Handle new states, drive overlay transitions |
| `VoiceListeningOverlay` (`audiflow_app`) | Render three new confirmation states |

**Exhaustive switch impact:** Adding three states to the sealed `VoiceRecognitionState` class will break exhaustive switches. Affected sites:
- `VoiceListeningOverlay` -- add rendering for new states
- `VoiceCommandOrchestrator` -- new states are terminal (no orchestrator transition needed; treat as no-op in orchestrator switch)
- Any other switch on `VoiceRecognitionState` -- compile errors will surface all sites

## Voice Overlay Confirmation States

Three new states added to the existing `VoiceListeningOverlay`:

### Auto-applied state
- Brief toast-style message: setting name + old value -> new value
- Undo button
- Auto-dismisses after 3 seconds (aligned with existing `_resetToIdleAfterDelay`)
- **Undo mechanism:** The `VoiceCommandExecutor` captures the previous value before applying the change and holds it in memory. Tapping undo calls the same setter with the old value. The previous value is discarded when the overlay dismisses.

### Disambiguation state (multiple matches)
- 2-3 candidate settings as tappable cards
- Each card: setting display name + proposed change
- User taps one -> applies -> transitions to auto-applied state
- Cancel button dismisses

### Low confidence state
- AI's best guess with "did you mean this?" framing
- Confirm / Cancel buttons
- Confirm applies + transitions to auto-applied state

All states render within the existing overlay widget. No new screens or navigation.

## Testing Strategy

### Unit tests
- `SettingsIntentResolver` -- mock AI service, verify parsing for absolute values, relative values (direction + magnitude -> exact value), ambiguous inputs, unrecognizable inputs, timeout handling
- `SettingsMetadataRegistry` -- enumerate all keys from `SettingsKeys` constants and assert each has a registry entry; constraints valid; synonyms non-empty
- `SettingsSnapshotService` -- snapshot format matches expected AI prompt structure

### Integration tests
- Full flow: transcription -> VoiceCommandService -> SettingsIntentResolver -> VoiceCommandExecutor -> setting changed in repository
- Disambiguation: ambiguous input -> multiple matches -> correct candidates surfaced
- Undo: setting changed -> undo -> original value restored

### AI prompt quality tests
- Fixture-based: natural language inputs (Japanese + English) mapped to expected setting changes
- Cover: relative expressions, absolute values, synonyms, ambiguous phrases
- Serve as regression tests when prompt is tuned

### Widget tests
- Overlay renders auto-applied state with undo
- Overlay renders disambiguation cards
- Overlay renders low-confidence confirmation

## Playback-affecting Settings

Settings like `playbackSpeed` have immediate audible effects during active playback. When the `VoiceCommandExecutor` applies a playback-related setting, it must also notify the `AudioPlayerController` to apply the change in real time -- not just persist to the repository. The executor checks whether playback is active and coordinates accordingly.

## AI Requirement

Settings commands require the on-device AI to be available. There is no keyword-based fallback -- the existing `_parseSimpleCommand` fallback in the orchestrator does not handle `changeSettings`. If AI is unavailable, the voice command flow falls through to the existing error state ("voice commands unavailable").

## Not in Scope

- Siri / App Intents integration (follow-up)
- Batch setting changes from single utterance (follow-up)
- Voice settings preferences screen (separate feature)
- New settings -- this feature makes existing settings voice-controllable
