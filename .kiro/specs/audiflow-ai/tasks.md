# Implementation Plan

## Phase 1: Package Structure & Skeleton

- [x] 1. Create Flutter plugin package structure
- [x] 1.1 Initialize package scaffolding with plugin template
  - Create `packages/audiflow_ai/` directory with Flutter plugin structure
  - Configure pubspec.yaml with plugin platforms (android, ios)
  - Set up android/src/main/kotlin directory with package namespace `com.audiflow.ai`
  - Set up ios/Classes directory for Swift implementation
  - Configure build.gradle with minSdkVersion 26 and ML Kit GenAI dependency
  - Configure Podspec with iOS 26.0 deployment target
  - Add package to root pubspec.yaml workspace and melos.yaml
  - _Requirements: 14.1, 14.4, 14.5, 14.7_

- [x] 1.2 (P) Create Dart API skeleton with stub implementations
  - Define AudiflowAi abstract class with all method signatures from design
  - Create AudiflowAiImpl with stub implementations returning errors
  - Set up singleton pattern with setInstance/resetInstance for testing
  - Define MethodChannel constant `com.audiflow/ai`
  - Create main export file at lib/audiflow_ai.dart
  - _Requirements: 14.2, 14.3_

- [x] 1.3 (P) Create Android native plugin skeleton
  - Implement AudiflowAiPlugin.kt with method channel registration
  - Create stub handlers for checkCapability, initialize, generateText, dispose
  - Return appropriate error responses from stubs
  - Add MIT license attribution header referencing flutter_local_ai
  - _Requirements: 7.1, 7.2, 7.10, 13.2, 13.6_

- [x] 1.4 (P) Create iOS native plugin skeleton
  - Implement SwiftAudiflowAiPlugin.swift with method channel registration
  - Create stub handlers for checkCapability, initialize, generateText, dispose
  - Return appropriate error responses from stubs
  - Add MIT license attribution header referencing flutter_local_ai
  - _Requirements: 8.1, 8.2, 8.10, 13.3, 13.6_

- [x] 1.5 Verify platform channel communication
  - Write integration test that invokes each method channel call
  - Verify stub responses are correctly received in Dart layer
  - Confirm error codes propagate through channel boundary
  - Run tests on both Android emulator and iOS simulator
  - _Requirements: 13.8_

## Phase 2: Core Implementation

### Data Models & Exceptions

- [x] 2. Implement data models and exception hierarchy
- [x] 2.1 (P) Create enum and config models
  - Implement AiCapability enum with full, limited, unavailable, needsSetup values
  - Add extension methods for isUsable, requiresAction, description
  - Implement GenerationConfig with temperature, maxOutputTokens, stopSequences
  - Implement SummarizationConfig with maxLength, style, includeBulletPoints
  - Implement SummarizationStyle enum (concise, detailed, bulletPoints)
  - Write unit tests for enum behavior and config defaults
  - _Requirements: 9.1, 9.3, 9.4_

- [x] 2.2 (P) Create response and command models
  - Implement AiResponse with text, tokenCount, durationMs, metadata fields
  - Implement EpisodeSummary with summary, keyTopics, estimatedListeningMinutes
  - Implement VoiceCommand with intent, parameters, confidence, rawTranscription
  - Implement VoiceIntent enum with all playback, search, navigation, queue intents
  - Use @freezed annotation for models requiring copyWith functionality
  - Write unit tests for model equality, hash code, and serialization
  - _Requirements: 9.2, 9.5, 9.6, 9.7_

- [x] 2.3 (P) Create exception hierarchy
  - Implement AudiflowAiException extending AppException from audiflow_core
  - Create AiNotAvailableException for unsupported devices
  - Create AiNotInitializedException for pre-initialization calls
  - Create AiCoreRequiredException for Android AICore installation
  - Create AiGenerationException with cause parameter
  - Create AiSummarizationException with cause parameter
  - Create PromptTooLongException with maxTokens parameter
  - Create InsufficientContentException for empty/short content
  - Write unit tests for exception messages and error codes
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 10.9_

### Text Processing Utilities

- [x] 3. Implement text processing utilities
- [x] 3.1 (P) Create TextChunker utility
  - Implement chunking algorithm that respects sentence boundaries
  - Support paragraph boundary detection for cleaner splits
  - Make chunk size configurable (default 2000 characters)
  - Make overlap configurable (default 100 characters)
  - Handle edge cases: empty text, text shorter than chunk size
  - Write unit tests for boundary detection and overlap behavior
  - _Requirements: 11.1, 11.2, 11.3_

- [x] 3.2 (P) Create HTML and text processing utilities
  - Implement HTML tag stripping function
  - Implement HTML entity decoding
  - Create text normalization for whitespace, line breaks, special characters
  - Handle malformed HTML gracefully
  - Write unit tests for various HTML input scenarios
  - _Requirements: 11.4, 11.5_

- [x] 3.3 (P) Create prompt template system
  - Implement PromptTemplates class with predefined templates
  - Create summarization template with style options (concise, detailed, bullet points)
  - Create voice command parsing template with podcast player terminology
  - Create topic extraction template for podcast content themes
  - Implement variable substitution using {placeholder} syntax
  - Allow template overrides via static setter
  - Write unit tests for template rendering and substitution
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6_

### Android Native Implementation

- [x] 4. Implement Android native layer with ML Kit GenAI
- [x] 4.1 Implement capability detection for Android
  - Query AICore availability using ML Kit FeatureStatus API
  - Map FeatureStatus values to AiCapability enum
  - Detect error code -101 and return needsSetup status
  - Implement promptAiCoreInstall to open Play Store
  - Handle AICore lifecycle events (installation, updates)
  - Write instrumentation tests for capability detection
  - _Requirements: 1.2, 1.4, 1.5, 1.6, 7.4, 7.8_

- [x] 4.2 Implement initialization and lifecycle for Android
  - Initialize ML Kit GenerativeModel with system instructions
  - Handle initialization failure with appropriate exceptions
  - Support reinitialization with new configuration
  - Implement dispose to release model resources
  - Track initialization state
  - Write instrumentation tests for initialization scenarios
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 7.3, 7.9_

- [x] 4.3 Implement text generation for Android
  - Invoke ML Kit Prompt API with prompt and config
  - Map GenerationConfig to ML Kit generation options
  - Return generated text with token count and duration
  - Handle prompt too long errors with specific exception
  - Handle generation failures with error details
  - Check ML Kit Summarization API availability and use if available
  - Write instrumentation tests for generation scenarios
  - _Requirements: 3.1, 3.2, 3.5, 7.5, 7.6, 7.7_

### iOS Native Implementation

- [x] 5. Implement iOS native layer with Foundation Models
- [x] 5.1 Implement capability detection for iOS
  - Check SystemLanguageModel.default.availability
  - Map availability status to AiCapability enum
  - Return unavailable for iOS versions below 26
  - Return unavailable for devices without Apple Intelligence
  - Write unit tests for capability detection logic
  - _Requirements: 1.3, 1.5, 8.4, 8.7_

- [x] 5.2 Implement initialization and lifecycle for iOS
  - Create LanguageModelSession with system instructions
  - Handle initialization failure for unsupported devices
  - Support reinitialization with new configuration
  - Implement dispose to release session resources
  - Manage memory for large text processing
  - Write unit tests for initialization scenarios
  - _Requirements: 2.1, 2.2, 2.3, 2.5, 2.6, 8.3, 8.8, 8.9_

- [x] 5.3 Implement text generation for iOS
  - Invoke LanguageModelSession.respond(to:) with prompt
  - Map GenerationConfig to Foundation Models GenerationOptions
  - Return generated text with available metadata
  - Handle generation failures with error details
  - Use summarization-optimized prompts when appropriate
  - Write unit tests for generation scenarios
  - _Requirements: 3.1, 3.2, 3.5, 8.5, 8.6_

### Dart Service Layer

- [ ] 6. Implement Dart service layer
- [ ] 6.1 Implement TextGenerationService
  - Create service with MethodChannel dependency
  - Implement isAvailable check using platform channel
  - Implement initialize with system instructions forwarding
  - Implement generateText with config mapping
  - Map platform responses to AiResponse model
  - Throw appropriate exceptions for error conditions
  - Write unit tests with mocked platform channel
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [ ] 6.2 Implement SummarizationService
  - Create service with TextGenerationService dependency
  - Implement text summarization with style application
  - Strip HTML from input before processing
  - Chunk long text using TextChunker
  - Generate summary for each chunk and combine results
  - Implement progress callback at chunk boundaries
  - Throw AiSummarizationException for failures
  - Write unit tests with mocked TextGenerationService
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_

- [ ] 6.3 Implement episode summarization
  - Create summarizeEpisode method in SummarizationService
  - Accept title, description, and optional transcript
  - Validate content is sufficient (non-empty title or description)
  - Use podcast-optimized prompt templates
  - Extract key topics from content
  - Return EpisodeSummary with summary, topics, duration estimate
  - Implement progress callback for long transcripts
  - Write unit tests for episode summarization scenarios
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [ ] 6.4 Implement VoiceCommandService
  - Create service with TextGenerationService dependency
  - Use voice command parsing prompt template
  - Parse transcription into VoiceCommand structure
  - Recognize playback intents (play, pause, stop, skip, seek)
  - Recognize search intents with extracted terms
  - Recognize navigation intents (library, queue, settings)
  - Recognize queue management intents (add, remove, clear)
  - Return unknown intent for unparseable commands
  - Calculate and return confidence score
  - Write unit tests for each intent category
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_

### Main API Facade

- [ ] 7. Implement AudiflowAi facade and resource management
- [ ] 7.1 Implement AudiflowAi facade
  - Implement AudiflowAiImpl with all service dependencies
  - Coordinate checkCapability through platform channel
  - Implement initialize/reinitialize with state tracking
  - Expose isInitialized property
  - Delegate text generation to TextGenerationService
  - Delegate summarization to SummarizationService
  - Delegate voice commands to VoiceCommandService
  - Implement promptAiCoreInstall for Android
  - Throw AiNotInitializedException when methods called before init
  - Write unit tests for facade coordination
  - _Requirements: 1.1, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2, 3.3, 3.4, 4.1, 5.1, 6.1_

- [ ] 7.2 Implement resource management
  - Implement dispose method to release native resources
  - Forward dispose to all services and platform channel
  - Use background isolates for text preprocessing over 100ms
  - Report resource usage metrics in response metadata
  - Implement CancellationToken for long-running operations
  - Write unit tests for disposal and cancellation
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_

## Phase 3: Integration & Validation

- [ ] 8. Integration tests and cross-layer verification
- [ ] 8.1 Verify capability detection end-to-end
  - Test checkCapability returns correct status on supported Android devices
  - Test checkCapability returns correct status on supported iOS devices
  - Test needsSetup detection when AICore not installed
  - Test unavailable detection on unsupported devices
  - Verify singleton instance returns consistent results
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 8.2 Verify text generation end-to-end
  - Test generation with simple prompts on both platforms
  - Test generation with custom config parameters
  - Test error handling for initialization failures
  - Test error handling for prompt too long
  - Verify response includes metadata (token count, duration)
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [ ] 8.3 Verify summarization flows end-to-end
  - Test text summarization with different styles
  - Test episode summarization with title and description
  - Test episode summarization with transcript
  - Test chunking behavior for long content
  - Verify progress callbacks fire at expected intervals
  - Test HTML stripping works correctly
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 5.1, 5.2, 5.3, 5.4_

- [ ] 8.4 Verify voice command parsing
  - Test parsing of playback commands (play, pause, skip)
  - Test parsing of search commands with extracted terms
  - Test parsing of navigation commands
  - Test parsing of queue management commands
  - Test unknown intent handling for unrecognized commands
  - Verify confidence scores are reasonable
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_

- [ ] 9. Finalize package and validate coverage
- [ ] 9.1 Verify package structure and exports
  - Confirm all public APIs exported from audiflow_ai.dart
  - Verify no flutter_local_ai dependency remains
  - Check MIT license attribution in LICENSE file
  - Verify all source files have license headers where required
  - Run melos bootstrap to confirm package integration
  - _Requirements: 13.1, 13.4, 13.5, 13.6, 13.7, 14.2, 14.3_

- [ ] 9.2 Validate test coverage and quality
  - Run test coverage analysis across package
  - Verify 80% code coverage for Dart layer
  - Ensure all exception paths are tested
  - Verify all requirements have corresponding tests
  - Run static analysis with zero issues
  - _Requirements: 14.6_
