# Requirements Document

## Introduction

The `audiflow_ai` package provides unified on-device AI capabilities for the Audiflow podcast application. It migrates source code from the `flutter_local_ai` package (MIT licensed) and extends it with podcast-specific features including summarization and voice command parsing. By migrating rather than wrapping, we gain full control over the implementation for future extensibility. The package supports both Android (ML Kit GenAI/Gemini Nano) and iOS (Apple Foundation Models) platforms, enabling offline-first AI functionality on flagship devices.

Target devices:
- Android: Pixel 8+, Honor Magic 6+, Samsung Galaxy 25+
- iOS: iPhone 15 Pro+

Key capabilities:
- Device capability detection
- Text generation with custom prompts
- Content summarization (text and podcast episodes)
- Voice command parsing
- Platform-native integration via platform channels (migrated from flutter_local_ai)

Migration approach:
- Migrate Dart, Kotlin (Android), and Swift (iOS) source code from `flutter_local_ai`
- Refactor to Audiflow naming conventions and code style
- Extend with podcast-specific features (summarization, voice commands)
- Maintain MIT license attribution

## Requirements

### Requirement 1: Device Capability Detection

**Objective:** As a developer, I want to check if on-device AI is available and its capability level, so that I can provide appropriate features or fallback options to users.

#### Acceptance Criteria

1. When the application calls `checkCapability()`, the AudiflowAi shall return the current AI capability level (full, limited, unavailable, or needsSetup).
2. When the device is a supported Android device with AICore installed, the AudiflowAi shall return `AiCapability.full`.
3. When the device is a supported iOS device running iOS 26+, the AudiflowAi shall return `AiCapability.full`.
4. If the device is an Android device without AICore installed, the AudiflowAi shall return `AiCapability.needsSetup`.
5. If the device does not meet minimum requirements, the AudiflowAi shall return `AiCapability.unavailable`.
6. The AudiflowAi shall provide a method `promptAiCoreInstall()` that opens the Google Play Store to the AICore installation page on Android devices.

### Requirement 2: AI Engine Initialization

**Objective:** As a developer, I want to initialize the AI engine with optional configuration, so that I can prepare the system for text generation tasks.

#### Acceptance Criteria

1. When `initialize()` is called without parameters, the AudiflowAi shall initialize with default system instructions optimized for podcast content.
2. When `initialize()` is called with custom system instructions, the AudiflowAi shall configure the AI engine with those instructions.
3. If initialization fails due to missing platform support, the AudiflowAi shall throw an `AiNotAvailableException` with a descriptive error message.
4. If initialization fails due to AICore not being installed (Android), the AudiflowAi shall throw an `AiCoreRequiredException` with guidance for resolution.
5. While the AI engine is already initialized, when `initialize()` is called again, the AudiflowAi shall reinitialize with the new configuration.
6. The AudiflowAi shall expose an `isInitialized` property that returns true only after successful initialization.

### Requirement 3: Text Generation

**Objective:** As a developer, I want to generate text using custom prompts, so that I can implement various AI-powered features in the application.

#### Acceptance Criteria

1. When `generateText()` is called with a valid prompt, the AudiflowAi shall return an `AiResponse` containing the generated text.
2. When `generateText()` is called with a `GenerationConfig`, the AudiflowAi shall apply the specified temperature, max tokens, and other parameters.
3. If `generateText()` is called before initialization, the AudiflowAi shall throw an `AiNotInitializedException`.
4. If the prompt exceeds the model's context limit, the AudiflowAi shall throw a `PromptTooLongException` with the maximum allowed length.
5. If text generation fails due to a platform error, the AudiflowAi shall throw an `AiGenerationException` with the underlying error details.
6. The `AiResponse` shall include the generated text, token count, and generation duration metadata.

### Requirement 4: Text Summarization

**Objective:** As a developer, I want to summarize arbitrary text content, so that I can provide concise information to users.

#### Acceptance Criteria

1. When `summarize()` is called with text content, the AudiflowAi shall return a summarized version of the text.
2. When `summarize()` is called with a `SummarizationConfig` specifying `maxLength`, the AudiflowAi shall limit the summary to approximately that word count.
3. When `summarize()` is called with `SummarizationStyle.concise`, the AudiflowAi shall produce a brief summary focusing on key points.
4. When `summarize()` is called with `SummarizationStyle.detailed`, the AudiflowAi shall produce a comprehensive summary with supporting details.
5. When `summarize()` is called with `SummarizationStyle.bulletPoints`, the AudiflowAi shall produce the summary as a formatted bullet-point list.
6. When the input text exceeds the model's context limit, the AudiflowAi shall chunk the text, summarize each chunk, and combine the results.
7. If summarization fails, the AudiflowAi shall throw an `AiSummarizationException` with error details.

### Requirement 5: Podcast Episode Summarization

**Objective:** As a developer, I want to summarize podcast episode content with episode-specific context, so that users can quickly understand episode content.

#### Acceptance Criteria

1. When `summarizeEpisode()` is called with episode title and description, the AudiflowAi shall return an `EpisodeSummary` object.
2. When `summarizeEpisode()` is called with an optional transcript, the AudiflowAi shall use the transcript for more accurate summarization.
3. The `EpisodeSummary` shall include a brief summary, key topics list, and estimated listening time.
4. When the episode description contains HTML content, the AudiflowAi shall strip HTML tags before processing.
5. If `summarizeEpisode()` is called with insufficient content (empty title and description), the AudiflowAi shall throw an `InsufficientContentException`.
6. The AudiflowAi shall use podcast-optimized prompt templates that understand episode structure and terminology.

### Requirement 6: Voice Command Parsing

**Objective:** As a developer, I want to parse voice command transcriptions into structured commands, so that users can control the app with natural language.

#### Acceptance Criteria

1. When `parseVoiceCommand()` is called with a transcription, the AudiflowAi shall return a `VoiceCommand` object with parsed intent and parameters.
2. The AudiflowAi shall recognize playback intents including play, pause, stop, skip forward, skip backward, and seek.
3. The AudiflowAi shall recognize search intents with extracted search terms (podcast name, episode title, topic).
4. The AudiflowAi shall recognize navigation intents including go to library, go to queue, and open settings.
5. The AudiflowAi shall recognize queue management intents including add to queue, remove from queue, and clear queue.
6. If the transcription cannot be parsed into a known command, the AudiflowAi shall return a `VoiceCommand` with `intent: unknown` and the original transcription.
7. The `VoiceCommand` shall include a confidence score (0.0 to 1.0) indicating parsing certainty.

### Requirement 7: Android Native Layer (Platform Channel)

**Objective:** As a developer, I want platform channel integration for Android ML Kit GenAI APIs, so that the package can leverage Gemini Nano capabilities.

#### Acceptance Criteria

1. The audiflow_ai package shall migrate the Android native code (Kotlin) from `flutter_local_ai` into `android/src/main/kotlin/`.
2. The migrated Kotlin code shall be refactored to use `com.audiflow.ai` package namespace.
3. The Android native layer shall initialize and manage the ML Kit GenAI API lifecycle.
4. When the Flutter layer requests capability detection, the Android native layer shall query AICore availability and return the appropriate status.
5. When the Flutter layer requests text generation, the Android native layer shall invoke the ML Kit Prompt API and return the response.
6. When the Flutter layer requests summarization, the Android native layer shall use the ML Kit Summarization API if available, or fall back to Prompt API.
7. If ML Kit GenAI is unavailable (error code -101), the Android native layer shall return a specific error indicating AICore installation is required.
8. The Android native layer shall handle AICore lifecycle events (installation, updates, model availability changes).
9. The Android build configuration shall set `minSdkVersion` to 26 or higher.
10. The migrated code shall include MIT license attribution header referencing the original `flutter_local_ai` source.

### Requirement 8: iOS Native Layer (Platform Channel)

**Objective:** As a developer, I want platform channel integration for Apple Foundation Models framework, so that the package can leverage on-device AI on iOS.

#### Acceptance Criteria

1. The audiflow_ai package shall migrate the iOS native code (Swift) from `flutter_local_ai` into `ios/Classes/`.
2. The migrated Swift code shall be refactored to use `AudiflowAi` class naming convention.
3. The iOS native layer shall initialize and manage the Foundation Models framework lifecycle.
4. When the Flutter layer requests capability detection, the iOS native layer shall verify Foundation Models availability and return the appropriate status.
5. When the Flutter layer requests text generation, the iOS native layer shall invoke the Foundation Models API and return the response.
6. When the Flutter layer requests summarization, the iOS native layer shall use Foundation Models with summarization-optimized prompts.
7. If Foundation Models is unavailable (device or iOS version not supported), the iOS native layer shall return an error with device requirements.
8. The iOS deployment target shall be set to iOS 26.0 or higher in the Podspec.
9. The iOS native layer shall properly handle memory management for large text processing.
10. The migrated code shall include MIT license attribution header referencing the original `flutter_local_ai` source.

### Requirement 9: Model and Response Data Structures

**Objective:** As a developer, I want well-defined data structures for AI operations, so that I can work with consistent and type-safe objects.

#### Acceptance Criteria

1. The `AiCapability` enum shall define values: full, limited, unavailable, and needsSetup.
2. The `AiResponse` class shall contain: text (String), tokenCount (int), durationMs (int), and metadata (Map).
3. The `GenerationConfig` class shall support: temperature (double), maxTokens (int), and stopSequences (List of String).
4. The `SummarizationConfig` class shall support: maxLength (int), style (SummarizationStyle), and includeBulletPoints (bool).
5. The `EpisodeSummary` class shall contain: summary (String), keyTopics (List of String), and estimatedListeningMinutes (int nullable).
6. The `VoiceCommand` class shall contain: intent (VoiceIntent enum), parameters (Map), confidence (double), and rawTranscription (String).
7. All model classes shall be immutable and use the freezed package for code generation.

### Requirement 10: Error Handling

**Objective:** As a developer, I want comprehensive error types and handling, so that I can provide appropriate feedback and recovery options to users.

#### Acceptance Criteria

1. The audiflow_ai package shall define a base `AudiflowAiException` class that all AI exceptions extend.
2. The package shall provide `AiNotAvailableException` for unsupported devices.
3. The package shall provide `AiNotInitializedException` when methods are called before initialization.
4. The package shall provide `AiCoreRequiredException` (Android-specific) when AICore installation is needed.
5. The package shall provide `AiGenerationException` for text generation failures with the underlying cause.
6. The package shall provide `AiSummarizationException` for summarization failures.
7. The package shall provide `PromptTooLongException` with the maximum allowed token count.
8. The package shall provide `InsufficientContentException` when input content is too short or empty.
9. All exceptions shall include a descriptive message and optional underlying error.

### Requirement 11: Text Processing Utilities

**Objective:** As a developer, I want text processing utilities, so that I can handle long content and prepare text for AI processing.

#### Acceptance Criteria

1. The audiflow_ai package shall provide a `TextChunker` utility that splits long text into processable chunks.
2. When chunking text, the TextChunker shall respect sentence and paragraph boundaries where possible.
3. The TextChunker shall support configurable chunk size (default 2000 characters) and overlap (default 100 characters).
4. The audiflow_ai package shall provide an HTML stripping utility that removes HTML tags and decodes entities.
5. The audiflow_ai package shall provide a text normalization utility that handles whitespace, line breaks, and special characters.

### Requirement 12: Prompt Templates

**Objective:** As a developer, I want podcast-optimized prompt templates, so that AI responses are contextually appropriate for podcast content.

#### Acceptance Criteria

1. The audiflow_ai package shall include a `PromptTemplates` class with predefined templates for podcast use cases.
2. The templates shall include a summarization template optimized for podcast episode descriptions.
3. The templates shall include a voice command parsing template that understands podcast player terminology.
4. The templates shall include a topic extraction template for identifying key themes in podcast content.
5. The templates shall support variable substitution using a defined placeholder syntax.
6. The templates shall be configurable, allowing developers to override defaults with custom templates.

### Requirement 13: Source Code Migration from flutter_local_ai

**Objective:** As a developer, I want to migrate the `flutter_local_ai` package source code into audiflow_ai, so that we have full control over the implementation and can extend it freely.

#### Acceptance Criteria

1. The audiflow_ai package shall migrate the Dart source code from `flutter_local_ai` (MIT licensed) into the `lib/src/` directory.
2. The audiflow_ai package shall migrate the Android native code (Kotlin) from `flutter_local_ai` into `android/src/main/kotlin/`.
3. The audiflow_ai package shall migrate the iOS native code (Swift) from `flutter_local_ai` into `ios/Classes/`.
4. The migrated code shall be refactored to use audiflow naming conventions (e.g., `AudiflowAi` instead of `FlutterLocalAi`).
5. The migrated code shall be refactored to follow Audiflow code style and architecture patterns.
6. The package shall include the original MIT license attribution in the LICENSE file and relevant source files.
7. The package shall NOT depend on `flutter_local_ai` as an external dependency after migration.
8. The migrated platform channel names shall be updated to `com.audiflow/ai` for consistency.

### Requirement 14: Package Structure and Integration

**Objective:** As a developer, I want the package to follow Audiflow monorepo conventions, so that it integrates seamlessly with the existing codebase.

#### Acceptance Criteria

1. The audiflow_ai package shall be located at `packages/audiflow_ai/` in the monorepo.
2. The package shall export a single entry point at `lib/audiflow_ai.dart`.
3. The package shall depend only on `audiflow_core` from internal packages (no external AI package dependencies).
4. The package shall be added to the root `pubspec.yaml` workspace configuration.
5. The package shall be registered in `melos.yaml` for monorepo tooling support.
6. The package shall include comprehensive unit tests achieving at least 80% code coverage.
7. The package structure shall follow Flutter plugin conventions with `android/`, `ios/`, and `lib/` directories.

### Requirement 15: Performance and Resource Management

**Objective:** As a developer, I want efficient resource management, so that AI operations do not negatively impact app performance or battery life.

#### Acceptance Criteria

1. The AudiflowAi shall support disposing of resources via a `dispose()` method.
2. When `dispose()` is called, the AudiflowAi shall release all native platform resources.
3. The audiflow_ai package shall process text in background isolates for operations exceeding 100ms.
4. The AudiflowAi shall report resource usage metrics (memory, processing time) in response metadata.
5. While processing large content, the AudiflowAi shall provide progress callbacks for UI feedback.
6. The AudiflowAi shall implement request cancellation via CancellationToken for long-running operations.
