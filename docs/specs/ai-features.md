# AI Features Specification

Status: DRAFT -- Not yet implemented

## Platform-Native AI Strategy

**Decision: On-device, platform-native AI over cloud or cross-platform alternatives.**

| Option | Verdict | Reason |
|--------|---------|--------|
| Platform-native on-device (ML Kit GenAI + Apple Foundation Models) | **Selected** | Production-ready, offline, system-managed models, free, privacy-focused |
| Cloud-based (`firebase_ai` / Gemini API) | Rejected | Requires network, pay-per-use, breaks offline-first requirement |
| Cross-platform on-device (`ai_edge` / Gemma) | Rejected | Experimental, requires 2-4GB model downloads |

### Device Requirements (Flagship Only)

| Platform | Requirement | Capability |
|----------|-------------|------------|
| Android | Pixel 8 Pro / Pixel 9 series | Full (default enabled) |
| Android | Pixel 8 / 8a | Full (requires developer option) |
| iOS | iPhone 15 Pro+ | Full (iOS 26+ required) |
| Others | Any | Unavailable (graceful degradation) |

### Known Constraints

- `flutter_local_ai` (v0.0.4+) wraps both platforms but is early-stage -- abstracted behind a repository for swappability
- Streaming not yet available; UI designed for full-response pattern
- Tool calling is iOS/macOS only
- AICore may need separate installation on some Android devices (error -101)

## audiflow_ai Package Design

### Position in Dependency Graph

```
audiflow_app -> audiflow_domain -> audiflow_ai -> audiflow_core
```

Same level as `audiflow_podcast` -- a utility package depending only on `audiflow_core`.

### Public API

```dart
class AudiflowAi {
  static Future<AiCapability> checkCapability();
  static Future<void> initialize({String? systemInstructions});
  static Future<VoiceCommand> parseVoiceCommand(String transcription);
  static Future<String> summarize(String text, {SummarizationConfig? config});
  static Future<EpisodeSummary> summarizeEpisode({...});
  static Future<void> promptAiCoreInstall();  // Android only
  static Future<void> dispose();
}
```

### Capability Levels

```dart
enum AiCapability {
  full,           // All features available
  limited,        // Basic features only
  unavailable,    // Device not supported
  needsSetup,     // Needs AICore install (Android)
}
```

### Models

- **VoiceCommand** (`@freezed`): `intent` (enum), `parameters` (Map), `confidence` (double)
- **VoiceIntent** enum: `play`, `pause`, `resume`, `stop`, `search`, `skipForward`, `skipBackward`, `playLatestEpisode`, `unknown`
- **EpisodeSummary** (`@freezed`): `summary`, `keyTopics` (List), `recommendation` (optional)

### Internal Structure

```
audiflow_ai/lib/src/
  core/       -- capability detection, config, exceptions
  nlu/        -- voice command models, parser (regex + LLM hybrid)
  summarization/ -- generic and episode-specific summarizers
  platform/   -- android_ai, ios_ai abstraction
```

## Voice Command Architecture

### Three-Stage Pipeline

```
speech_to_text -> transcription -> AudiflowAi.parseVoiceCommand() -> VoiceCommand -> VoiceCommandExecutor
```

| Responsibility | Package | Component |
|---|---|---|
| Speech-to-text | audiflow_domain | `SpeechRecognitionRepository` (wraps `speech_to_text`) |
| NLU | audiflow_ai | `VoiceCommandParser` |
| Command execution | audiflow_domain | `VoiceCommandOrchestrator` + feature services |
| UI | audiflow_app | `VoiceCommandFab`, `VoiceListeningOverlay` |

### State Machine

```
idle -> listening (partial transcript) -> processing -> executing -> success | error -> idle
```

`VoiceRecognitionState` is a `@freezed` sealed class with six states, managed by a Riverpod notifier.

### NLU Strategy (Hybrid)

- Simple commands (pause, resume): regex with high confidence (0.95)
- Complex commands (play latest episode of X): regex first, on-device LLM fallback for ambiguous input
- Confidence threshold for user confirmation

### Example Flow: "Play the latest episode of The Daily"

1. Search podcast by name via `PodcastSearchService`
2. Get `feedUrl` from first result
3. Parse feed via `FeedParserService`
4. Find latest episode by `publishDate`
5. Play via `AudioPlayerController`

## Phased Rollout

1. Package structure + capability detection
2. Summarization features
3. Domain integration with Drift caching
4. Voice command pipeline (blocked on phases 1-3)

## Risk Mitigations

| Risk | Mitigation |
|------|------------|
| `flutter_local_ai` early-stage | Repository interface for backend swapping |
| AICore not installed (Android) | Capability check + Play Store link prompt |
| Device not supported | `isAvailable()` guard; features hidden on unsupported devices |
| No streaming support | UI designed for complete-response pattern |
