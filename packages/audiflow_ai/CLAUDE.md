# audiflow_ai

Flutter plugin providing on-device AI capabilities for the audiflow podcast app. Communicates with native iOS/Android AI engines via platform channels.

## Ecosystem context

Depends only on audiflow_core. Consumed by audiflow_domain. Derived in part from flutter_local_ai (MIT). Requires Flutter 3.35+ and platform-specific AI runtime (Apple Intelligence on iOS, AICore on Android).

## Responsibilities

- Device AI capability detection (`AudiflowAi.checkCapability()` returning `AiCapability`: full/limited/needsSetup/unavailable)
- AI engine initialization with optional system instructions
- Text generation (`generateText()` returning `AiResponse` with `GenerationConfig`)
- Text summarization with chunked progress reporting (`summarize()`, `SummarizationConfig`)
- Episode summarization with podcast context (`summarizeEpisode()` returning `EpisodeSummary`)
- Voice command parsing from transcribed text (`VoiceCommandService.parseVoiceCommand` returning `VoiceCommand`)
- Voice command parsing from raw audio via on-device Gemma 4 (`GemmaVoiceCommandService.dispatch(audio, settingsSnapshot)`)
- Cancellation support via `CancellationToken`
- Platform channel abstraction (`AudiflowAiChannel`)
- Prompt template management (`PromptTemplates`)
- Text chunking for long content (`TextChunker`)

## Voice command pipelines

Two parser entry points produce a `VoiceCommand`:

| Entry point | Input | Backend |
|-------------|-------|---------|
| `VoiceCommandService.parseVoiceCommand` | transcribed text | `TextGenerationService` (Gemini / Apple Intelligence / AICore) |
| `GemmaVoiceCommandService.dispatch` | raw audio bytes + settings snapshot | on-device Gemma 4 via injected `GemmaInferenceSession` |

Gemma 4 path components:
- `GemmaModelVariant` (E2B / E4B) + `detectGemmaVoiceCapability()` for device tiering
- `GemmaPlugin` port + `GemmaModelManager` for download/install lifecycle (errors surface as `GemmaModelInstallException`)
- `GemmaInferenceSession` port + `GemmaVoiceCommandService` for inference
- `voice_tool_schema.dart` defining 14 tools (13 fixed + `changeSettings` discriminated-union)
- `voiceSystemPrompt` constraining the model to English reasoning + one function call
- `VoiceCommand.failureReason` distinguishes the four ways `VoiceIntent.unknown` can arise

`GemmaPlugin` and `GemmaInferenceSession` are interfaces; their `flutter_gemma`-backed implementations are wired host-side in audiflow_app so this package stays unit-testable without the native plugin.

## Non-responsibilities

- Speech-to-text / audio transcription (uses pre-existing transcript text)
- Cloud-based AI services
- UI for AI features (owned by audiflow_app)
- Podcast feed parsing

## Key entry points

- `lib/audiflow_ai.dart` -- barrel file
- `lib/src/audiflow_ai.dart` -- `AudiflowAi` singleton (abstract + `AudiflowAiImpl`)
- `lib/src/services/summarization_service.dart` -- `SummarizationService`
- `lib/src/services/voice_command_service.dart` -- `VoiceCommandService`

## Validation

```bash
cd packages/audiflow_ai && flutter test
flutter analyze .
```
