# Voice Debug Overlay

## Purpose

Add a debug panel that shows the internal state of the voice command pipeline during voice interactions. Visible only on dev/stg builds so developers can diagnose voice recognition issues on physical devices without relying on console logs.

## Behavior

- Appears when `VoiceRecognitionState` leaves `idle`; disappears when it returns to `idle`
- Same lifecycle as `VoiceCommandPanel`
- Only rendered when `FlavorConfig.current.flavor != Flavor.prod`
- Positioned bottom-left, above the navigation bar

## Fields

| Field | Source | Example |
|-------|--------|---------|
| State | `VoiceRecognitionState` variant name | `LISTENING`, `PROCESSING`, `SUCCESS` |
| Transcript | Partial or final transcription | `"play the news"` |
| Parser | Which parser matched the transcription | `simple (pattern)`, `platform NLU`, `on-device AI` |
| Intent | `VoiceIntent` enum value | `play`, `skipForward`, `changeSettings` |
| Confidence | Score from matched `VoiceCommand` | `0.90` |
| Params | Command parameters map | `podcastName: "the news"` |
| AI status | `AudiflowAi.instance.isInitialized` | `ready` / `not initialized` / `failed` |

## Architecture

### New: `VoiceDebugInfo` provider (audiflow_domain)

A lightweight `@Riverpod(keepAlive: true)` notifier that the orchestrator populates with debug metadata not present in the main state (specifically: which parser matched). Separate from production state so it has zero impact on prod builds.

```
// In audiflow_domain/src/features/voice/models/voice_debug_info.dart
@freezed
sealed class VoiceDebugInfo with _$VoiceDebugInfo {
  const factory VoiceDebugInfo({
    @Default(VoiceParserSource.none) VoiceParserSource parserSource,
    VoiceCommand? lastCommand,
  }) = _VoiceDebugInfo;
}

enum VoiceParserSource { none, simplePattern, platformNlu, onDeviceAi }
```

```
// In audiflow_domain/src/features/voice/services/voice_debug_info_notifier.dart
@Riverpod(keepAlive: true)
class VoiceDebugInfoNotifier extends _$VoiceDebugInfoNotifier {
  @override
  VoiceDebugInfo build() => const VoiceDebugInfo();

  void setParserSource(VoiceParserSource source) {
    state = state.copyWith(parserSource: source);
  }

  void setLastCommand(VoiceCommand command) {
    state = state.copyWith(lastCommand: command);
  }

  void reset() {
    state = const VoiceDebugInfo();
  }
}
```

### Modified: `VoiceCommandOrchestrator` (audiflow_domain)

Update `_processTranscription` to call `voiceDebugInfoNotifierProvider.notifier` at each parser match point:
- After simple parser match: `setParserSource(VoiceParserSource.simplePattern)`
- After platform NLU match: `setParserSource(VoiceParserSource.platformNlu)`
- After on-device AI match: `setParserSource(VoiceParserSource.onDeviceAi)`
- In `_executeCommand`: `setLastCommand(command)` so intent/confidence/params survive into `VoiceSuccess`/`VoiceError` states
- On `cancelVoiceCommand` / `resetToIdle`: call `reset()`

### New: `VoiceDebugPanel` widget (audiflow_app)

`lib/features/voice/presentation/widgets/voice_debug_panel.dart`

- `ConsumerWidget` watching `voiceCommandOrchestratorProvider` and `voiceDebugInfoNotifierProvider`
- Dark semi-transparent background (`Color.fromRGBO(0, 0, 0, 0.85)`), monospace font, 10px text
- Purple accent border (`Color.fromRGBO(124, 58, 237, 0.4)`)
- Header row: "VOICE DEBUG" label (left) + AI status indicator (right)
- Body rows: State, Transcript, Parser, Intent, Confidence, Params
- Reads `lastCommand` from `voiceDebugInfoNotifierProvider` for intent/confidence/params (persists across state transitions until reset)
- Fade in/out animation matching `VoiceCommandPanel` timing

### Modified: `ScaffoldWithNavBar` (audiflow_app)

Add `VoiceDebugPanel` to the existing `Stack`, guarded by flavor check:

```dart
if (voiceEnabled && FlavorConfig.current.flavor != Flavor.prod)
  Positioned(
    bottom: bottomNavHeight + 8,
    left: 8,
    child: const VoiceDebugPanel(),
  ),
```

The `bottomNavHeight` varies by form factor:
- Phone: `80 + MediaQuery.viewPaddingOf(context).bottom`
- Tablet portrait: `8` (no bottom nav)
- Tablet landscape: `8` (no bottom nav)

## Testing

### Unit test: `VoiceDebugInfoNotifier`
- `setParserSource` updates state
- `reset` returns to default

### Widget test: `VoiceDebugPanel`
- Renders nothing when state is `VoiceIdle`
- Shows state name, transcript when `VoiceListening`
- Shows parser, intent, confidence, params when `VoiceExecuting`
- Shows AI status from `AudiflowAi.instance.isInitialized`

### Widget test: `ScaffoldWithNavBar` (update existing)
- Debug panel present when flavor is `dev` and voice active
- Debug panel absent when flavor is `prod`

## Files changed

| File | Change |
|------|--------|
| `audiflow_domain/.../voice/models/voice_debug_info.dart` | New -- `VoiceDebugInfo` freezed class + `VoiceParserSource` enum |
| `audiflow_domain/.../voice/services/voice_debug_info_notifier.dart` | New -- Riverpod notifier |
| `audiflow_domain/lib/audiflow_domain.dart` | Export new files |
| `audiflow_domain/.../voice/services/voice_command_orchestrator.dart` | Set parser source at each match point, reset on cancel/idle |
| `audiflow_app/.../voice/presentation/widgets/voice_debug_panel.dart` | New -- debug overlay widget |
| `audiflow_app/lib/routing/scaffold_with_nav_bar.dart` | Add `VoiceDebugPanel` to `Stack` with flavor guard |
| Tests for above | New + updated |
