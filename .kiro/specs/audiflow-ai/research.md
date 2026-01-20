# Research & Design Decisions: audiflow_ai Package

## Summary

- **Feature**: audiflow-ai
- **Discovery Scope**: Complex Integration (source code migration + platform channels)
- **Key Findings**:
  - flutter_local_ai uses MethodChannel with ML Kit GenAI (Android) and Foundation Models (iOS)
  - ML Kit GenAI Prompt API is in alpha (1.0.0-alpha1) but production-ready for supported devices
  - Foundation Models requires iOS 26+ and uses Swift-native async/await patterns

## Research Log

### flutter_local_ai Package Structure

- **Context**: Need to understand source structure for migration
- **Sources Consulted**:
  - [GitHub: kekko7072/flutter_local_ai](https://github.com/kekko7072/flutter_local_ai)
  - [pub.dev: flutter_local_ai](https://pub.dev/packages/flutter_local_ai)
- **Findings**:
  - Package version: 0.0.4 (published November 2025)
  - Directory structure: `/lib`, `/android`, `/darwin` (unified iOS/macOS)
  - Method channel name: `flutter_local_ai`
  - Key Dart exports: `FlutterLocalAi`, `AiResponse`, `GenerationConfig`, `LocalAiTool`
  - Key methods: `isAvailable()`, `initialize()`, `generateText()`, `openAICorePlayStore()`
  - MIT licensed
- **Implications**: Migration involves copying and refactoring three layers: Dart, Kotlin, Swift

### ML Kit GenAI API (Android)

- **Context**: Understand Android native implementation requirements
- **Sources Consulted**:
  - [ML Kit GenAI APIs Overview](https://developers.google.com/ml-kit/genai)
  - [ML Kit GenAI Prompt API Get Started](https://developers.google.com/ml-kit/genai/prompt/android/get-started)
  - [Android Developers Blog: On-device GenAI APIs](https://android-developers.googleblog.com/2025/05/on-device-gen-ai-apis-ml-kit-genai-apis.html)
  - [Android Developers Blog: ML Kit Prompt API Alpha](https://android-developers.googleblog.com/2025/10/ml-kit-genai-prompt-api-alpha-release.html)
- **Findings**:
  - Dependency: `com.google.mlkit:genai-prompt:1.0.0-alpha1`
  - Requires Android API 26+ (Android 8.0 Oreo)
  - Requires AICore system app (managed by Google Play Services)
  - Key classes: `Generation`, `GenerativeModel`, `FeatureStatus`, `DownloadStatus`
  - Capability check returns: `UNAVAILABLE`, `DOWNLOADABLE`, `DOWNLOADING`, `AVAILABLE`
  - Generation options: `temperature`, `seed`, `topK`, `candidateCount`, `maxOutputTokens`
  - Input limit: ~4000 tokens (~3000 English words)
  - Output limit: 256 tokens recommended for optimal performance
  - Streaming API available for long responses
  - Error code -101 indicates AICore not installed
- **Implications**: Must handle AICore installation flow; implement capability checking before operations

### Apple Foundation Models (iOS)

- **Context**: Understand iOS native implementation requirements
- **Sources Consulted**:
  - [Apple Foundation Models Documentation](https://developer.apple.com/documentation/FoundationModels)
  - [Create with Swift: Exploring Foundation Models](https://www.createwithswift.com/exploring-the-foundation-models-framework/)
  - [AppCoda: Getting Started with Foundation Models](https://www.appcoda.com/foundation-models/)
  - [Apple Newsroom: Foundation Models Framework](https://www.apple.com/newsroom/2025/09/apples-foundation-models-framework-unlocks-new-intelligent-app-experiences/)
- **Findings**:
  - Available iOS 26+, iPadOS 26+, macOS 26+
  - ~3B parameter model, 30 tokens/second on iPhone 15 Pro
  - Key classes: `SystemLanguageModel`, `LanguageModelSession`
  - Key methods: `respond(to:)`, `streamResponse()`
  - `@Generable` macro for structured output generation
  - `@Guide` macro for constrained generation
  - Tool calling support via `Tool` protocol
  - GenerationOptions: `sampling`, `temperature`, `maximumResponseTokens`
  - Availability check: `SystemLanguageModel.default.availability`
  - Languages: English, French, German, Italian, Portuguese, Spanish, Chinese, Japanese, Korean
- **Implications**: Requires iOS 26 deployment target; use async/await patterns in Swift

### Existing audiflow_ai Implementation

- **Context**: Understand current wrapper implementation
- **Sources Consulted**: Local codebase analysis
- **Findings**:
  - Already structured as a monorepo package at `packages/audiflow_ai/`
  - Currently wraps `flutter_local_ai: ^0.0.4`
  - Has Dart models: `AiCapability`, `AiResponse`, `GenerationConfig`, `SummarizationConfig`, `EpisodeSummary`, `VoiceCommand`
  - Has services: `TextGenerationService`, `SummarizationService`, `VoiceCommandService`
  - Has utilities: `PromptTemplates`, `TextChunker`
  - Test files exist for models and utilities
- **Implications**: Dart layer largely complete; need to replace flutter_local_ai dependency with direct platform channel implementation

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| Wrapper (current) | Depend on flutter_local_ai | Quick implementation, maintained by third party | No control over bugs/updates, extra dependency | Current state |
| Full Migration | Copy and refactor source | Full control, no external dependency, customizable | Higher initial effort, maintenance burden | Selected approach |
| Fork | Fork flutter_local_ai repository | Control with upstream sync option | Merge conflicts, still external repo | More complex git management |

**Selected**: Full Migration - provides complete ownership and aligns with project requirements.

## Design Decisions

### Decision: Source Code Migration Strategy

- **Context**: Requirements specify migration (not wrapping) of flutter_local_ai
- **Alternatives Considered**:
  1. Keep wrapper - minimal effort but no control
  2. Fork repository - control but complex maintenance
  3. Full migration - complete ownership
- **Selected Approach**: Full migration with three phases (structure, native, Dart)
- **Rationale**: Project requirements explicitly state migration; provides future extensibility and bug fix capability
- **Trade-offs**: Higher initial effort vs. long-term maintainability
- **Follow-up**: Verify MIT license compliance with attribution headers

### Decision: Platform Channel Namespace

- **Context**: Need consistent channel name across platforms
- **Alternatives Considered**:
  1. `flutter_local_ai` - keep original
  2. `com.audiflow.ai` - Audiflow convention
  3. `com.audiflow/ai` - URL-style (more common for channels)
- **Selected Approach**: `com.audiflow/ai`
- **Rationale**: Follows common Flutter plugin conventions; clear ownership identifier
- **Trade-offs**: Breaking change from original; requires coordinated update
- **Follow-up**: Update all platform channel registrations simultaneously

### Decision: Exception Hierarchy

- **Context**: Requirements 10.1-10.9 specify comprehensive error types
- **Alternatives Considered**:
  1. Single exception with error codes
  2. Flat hierarchy (all extend base)
  3. Hierarchical with categories
- **Selected Approach**: Flat hierarchy extending `AudiflowAiException` which extends `AppException`
- **Rationale**: Simple structure, easy to catch by type, integrates with existing audiflow_core patterns
- **Trade-offs**: Less granular catching vs. simpler API
- **Follow-up**: Verify AppException exists in audiflow_core

### Decision: Model Immutability Approach

- **Context**: Requirements 9.7 specifies freezed package
- **Alternatives Considered**:
  1. Plain Dart classes (current state)
  2. Full freezed for all models
  3. Selective freezed for complex models only
- **Selected Approach**: Selective - use freezed only for models with copyWith requirements
- **Rationale**: Most models are simple; freezed adds build complexity
- **Trade-offs**: Inconsistency vs. reduced code generation
- **Follow-up**: Consider migration to freezed if copyWith needed

## Risks & Mitigations

- **AICore not installed on Android** - Provide `promptAiCoreInstall()` method; detect error code -101
- **Foundation Models unavailable on older iOS** - Check availability before operations; return `AiCapability.unavailable`
- **ML Kit GenAI in alpha** - Abstract behind service layer; monitor for breaking changes
- **Token limits vary by platform** - Document limits; implement chunking for long content
- **flutter_local_ai updates** - No impact after migration; optionally monitor for improvements to port

## References

- [flutter_local_ai GitHub](https://github.com/kekko7072/flutter_local_ai) - Source for migration
- [ML Kit GenAI APIs](https://developers.google.com/ml-kit/genai) - Android implementation reference
- [ML Kit Prompt API Get Started](https://developers.google.com/ml-kit/genai/prompt/android/get-started) - Kotlin code examples
- [Apple Foundation Models](https://developer.apple.com/documentation/FoundationModels) - iOS implementation reference
- [Create with Swift: Foundation Models](https://www.createwithswift.com/exploring-the-foundation-models-framework/) - Swift code examples
- [Gemini Nano on Android](https://developer.android.com/ai/gemini-nano) - Device support information
