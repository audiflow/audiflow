# Pluggable Voice Intent Resolution Design

## Overview

Replace the unreliable on-device AI for settings voice commands with native platform NLU (Siri App Intents on iOS, Google App Actions on Android) behind a pluggable platform channel interface. The simple parser continues to handle playback commands (play, pause, skip, navigate, search) where dynamic vocabulary (podcast/episode titles) makes native assistants impractical.

## Goals

- Settings voice commands resolved by platform-native NLU (Siri / Google Assistant)
- Single Dart-side interface via platform channel — platform handles NLU, Dart handles business logic
- In-app voice button and out-of-app assistant ("Hey Siri" / "OK Google") both supported
- On-device AI no longer used for settings resolution
- Playback commands unchanged (simple parser)
- Cloud LLM deferred to a future feature

## Platform Requirements

- iOS 26+ (already the minimum — uses Foundation Models framework)
- Android 8.0+ (API 26+)

## Voice Command Flow

### In-app (voice button tap)

```
User taps voice button
  -> Speech-to-text (existing, on-device)
  -> Simple parser tries first (play, pause, skip, navigate, search)
  -> Match? -> Execute immediately (existing flow)
  -> No match? -> Send transcription to platform channel:
      resolveSettingsIntent(transcription, settingsSchema)
  -> iOS: App Intents NLU resolves -> returns structured result
  -> Android: App Actions resolver -> returns structured result
  -> Dart receives SettingsChangePayload -> SettingsIntentResolver validates
  -> Resolution flow (auto-apply / confirm / disambiguate)
```

### Out-of-app ("Hey Siri" / "OK Google")

```
User says "Hey Siri, audiflowのテーマをダークに"
  -> Siri handles speech + NLU natively
  -> App Intent perform() fires
  -> Platform side calls into Dart via platform channel (reverse direction)
  -> onSettingsIntentPerformed callback
  -> Same SettingsIntentResolver validates and applies
```

## Platform Channel Interface

### resolveSettingsIntent (Dart -> Platform)

Used for in-app voice flow.

```
Input:
  - transcription: String (raw speech-to-text output)
  - settingsSchema: String (JSON -- keys, types, constraints, current values, synonyms)

Output:
  - action: "absolute" | "relative" | "ambiguous" | "not_found"
  - key: String? (settings key)
  - value: String? (for absolute)
  - direction: "increase" | "decrease" (for relative)
  - magnitude: "small" | "medium" | "large" (for relative)
  - candidates: List<{key, value, confidence}> (for ambiguous)
  - confidence: double
```

The Dart side serializes `SettingsMetadataRegistry` + current values into `settingsSchema` JSON. The platform side uses this schema to configure intent parameter resolution.

### onSettingsIntentPerformed (Platform -> Dart)

Used for out-of-app assistant invocation. Registered during app startup.

```
Input: same structured result as resolveSettingsIntent output
```

Allows Siri/Google Assistant-triggered intents to reach the Dart orchestrator.

### Out-of-app callback lifecycle

When the app is in background or suspended:
- iOS: App Intents can launch the app in the background to execute `perform()`. Flutter engine may need to be started. The platform side applies the setting directly via `AppSettingsRepository` (SharedPreferences) without going through the Dart orchestrator. No overlay is shown.
- Android: App Actions similarly launch the app. Same direct-apply approach.
- If the app was terminated: the intent launches it, platform side applies directly, Dart orchestrator is not involved.

This means the out-of-app path is simpler: platform resolves + applies + responds to assistant. No Dart callback needed for background execution. The `onSettingsIntentPerformed` callback is only used when the app is already in foreground.

### Error handling

Platform channel errors:

| Error | Action |
|-------|--------|
| `not_found` | Show error state: "Could not match a setting" |
| Platform exception / timeout | Show error state: "Voice settings unavailable" |
| Invalid value (out of range) | Dart-side `SettingsIntentResolver` rejects, show error |

No fallback to on-device AI for settings resolution specifically. If the platform resolver returns `not_found` or fails for a settings intent, the user sees an error and can retry. However, the orchestrator's top-level fallback chain does use AI for non-settings intents: when the platform resolver returns `not_found`, the AI is invoked to classify the command as a different intent type (play, pause, search, etc.).

### Settings schema JSON format

```json
{
  "settings": [
    {
      "key": "settings_playback_speed",
      "displayName": "Playback Speed",
      "type": "double",
      "currentValue": "1.0",
      "constraints": { "type": "range", "min": 0.5, "max": 3.0, "step": 0.1 },
      "synonyms": ["speed", "playback speed", "速度", "再生速度", "倍速"]
    },
    {
      "key": "settings_theme_mode",
      "displayName": "Theme",
      "type": "enum",
      "currentValue": "system",
      "constraints": { "type": "options", "values": ["light", "dark", "system"] },
      "synonyms": ["theme", "テーマ", "ダークモード", "ライトモード"]
    },
    {
      "key": "settings_continuous_playback",
      "displayName": "Continuous Playback",
      "type": "boolean",
      "currentValue": "true",
      "constraints": { "type": "boolean" },
      "synonyms": ["continuous playback", "連続再生", "自動再生"]
    }
  ]
}
```

Schema is passed on each `resolveSettingsIntent` call (not cached), so current values are always fresh. For the out-of-app path, the platform side reads settings directly from SharedPreferences.

### Magnitude computation

The platform side determines magnitude from the user's phrasing:
- Siri/Google can extract intensity from natural language ("ちょっと" = small, "かなり" = large)
- If the platform cannot determine magnitude, it defaults to `small` (1 step)
- The Dart-side `SettingsIntentResolver` does the actual arithmetic (step * multiplier, clamping)

## iOS Implementation (App Intents)

### Intent definitions

One `AppIntent` per settings action type:

- `SetSettingIntent` -- absolute value change ("テーマをダークに", "set speed to 1.5")
- `AdjustSettingIntent` -- relative change ("速度を上げて", "make it faster")

Each intent has:
- `@Parameter` for the setting name (uses `DynamicOptionsProvider` fed from the settings schema)
- `@Parameter` for the value/direction
- `perform()` sends the resolved result back to Dart via platform channel

### AppShortcutsProvider

Registers phrase patterns so Siri can match variations:

```swift
AppShortcut(
    intent: SetSettingIntent(),
    phrases: [
        "\(.applicationName)の\(\.$settingName)を\(\.$value)にして",
        "Set \(.applicationName) \(\.$settingName) to \(\.$value)",
    ]
)
```

Siri matches variations of these phrases and fills the parameters automatically. The `DynamicOptionsProvider` supplies valid setting names and values from the schema JSON passed via platform channel at startup.

### In-app flow

The Swift side receives the transcription via platform channel, creates the matching intent, and uses the same resolution logic as Siri's path -- triggered programmatically rather than by voice.

## Android Implementation (App Actions)

### shortcuts.xml

Defines custom intents for Google Assistant:

```xml
<capability android:name="custom.actions.intent.CHANGE_SETTING">
    <intent android:action="audiflow.CHANGE_SETTING">
        <parameter android:name="settingName" android:key="settingName" />
        <parameter android:name="value" android:key="value" />
    </intent>
</capability>
```

### Hybrid approach

Google App Actions has more limited custom vocabulary compared to Siri. The Android side uses:
- App Actions for Google Assistant out-of-app invocation
- Kotlin-side intent resolver for in-app voice flow that maps transcription against the settings schema (similar logic to Siri's parameter resolution but without the App Actions framework)

Platform channel handler in Kotlin receives `resolveSettingsIntent`, runs the local matcher, returns the same structured result as iOS.

### "OK Google" path

App Actions callback sends the resolved intent to Dart via `onSettingsIntentPerformed` channel.

## Changes to Existing Code

### Remove

- On-device AI usage for settings (`AudiflowAi.parseVoiceCommand` with settings snapshot injection)
- `_parseSettingsPayload` in `VoiceCommandService`
- Settings snapshot injection into the voice command prompt template (`{settingsSnapshot}` block)
- `resolveFromTranscription` keyword matcher in `SettingsIntentResolver`
- `_payloadFromParameters` fallback in orchestrator

### Keep as-is

- `SettingsChangePayload` model -- Dart-side contract
- `SettingsIntentResolver.resolve()` -- validates and computes relative values
- `SettingsMetadataRegistry` -- serialized to JSON for the platform side
- `VoiceCommandExecutor.applySetting()` -- applies changes
- `VoiceRecognitionState` settings variants -- drives the overlay UI
- Simple parser for playback commands
- Voice command prompt template for non-settings AI parsing

### Modify

- `VoiceCommandOrchestrator._processTranscription` -- after simple parser miss, call platform channel instead of on-device AI
- `SettingsMetadataRegistry` -- add `toJson()` for platform channel serialization
- `AudiflowAiChannel` -- add `resolveSettingsIntent` and `onSettingsIntentPerformed` methods
- `audiflow_ai` iOS native code -- add App Intents implementations
- `audiflow_ai` Android native code -- add App Actions and Kotlin intent resolver

## Testing Strategy

### Unit tests (Dart)

- `SettingsMetadataRegistry.toJson()` serialization roundtrip
- Platform channel mock: verify `resolveSettingsIntent` is called with correct schema
- Orchestrator routes to platform channel when simple parser has no match
- `SettingsIntentResolver.resolve()` -- existing tests remain valid

### Platform tests (Swift / Kotlin)

- iOS: `SetSettingIntent` and `AdjustSettingIntent` resolve correct parameters from test phrases
- Android: Kotlin intent resolver matches test transcriptions against schema

### Integration tests

- Full flow: transcription -> platform channel -> resolved payload -> setting applied
- "Hey Siri" path: intent performed -> Dart callback -> setting applied
- Graceful fallback: platform resolver returns `not_found` -> error state shown

### Not testing

- Siri's NLU accuracy (Apple's responsibility)
- Google Assistant's NLU accuracy (Google's responsibility)

## Not in Scope

- Cloud LLM fallback (deferred to future feature)
- Voice commands for playback with dynamic podcast/episode titles (stays with simple parser)
- Custom Siri UI (uses default Siri experience)
