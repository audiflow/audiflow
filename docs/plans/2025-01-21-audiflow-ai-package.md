# [ACTIVE] Audiflow AI Package Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create the `audiflow_ai` package for on-device AI capabilities including NLU for voice commands and content summarization.

**Architecture:** Wrapper package around `flutter_local_ai` providing podcast-specific AI features. Uses platform-native on-device AI (ML Kit GenAI for Android, Apple Foundation Models for iOS).

**Tech Stack:** Flutter, flutter_local_ai, Gemini Nano (Android), Apple Foundation Models (iOS)

**Status:** ACTIVE - Requirements and design complete, awaiting implementation

---

## Requirements (EARS Format)

### FR-1: Voice Command Parsing
WHEN a voice transcription is provided,
the system SHALL parse it using on-device NLU
WHERE parsing identifies intent (play, pause, search) and extracts parameters (podcast name, episode number)

### FR-2: Content Summarization
WHEN episode description or transcript is provided,
the system SHALL generate a concise summary using on-device AI
WHERE summary highlights key topics and takeaways

### FR-3: Capability Detection
WHEN the package initializes,
the system SHALL detect device AI capability level
WHERE levels include: full, limited, unavailable, needsSetup

### FR-4: Graceful Degradation
IF device AI is unavailable,
THEN the system SHALL provide clear feedback
WHERE fallback options are presented to user

---

## Technical Design

### Package Structure

```
packages/audiflow_ai/
├── pubspec.yaml
├── lib/
│   ├── audiflow_ai.dart           # Public API
│   └── src/
│       ├── core/
│       │   ├── ai_capability.dart
│       │   ├── ai_config.dart
│       │   └── ai_exceptions.dart
│       ├── nlu/
│       │   ├── voice_command.dart
│       │   ├── voice_command_parser.dart
│       │   └── intent_types.dart
│       ├── summarization/
│       │   ├── summarizer.dart
│       │   ├── episode_summarizer.dart
│       │   └── summarization_config.dart
│       └── platform/
│           ├── ai_platform.dart
│           ├── android_ai.dart
│           └── ios_ai.dart
└── test/
```

### Public API

```dart
class AudiflowAi {
  /// Check device AI capability
  static Future<AiCapability> checkCapability();

  /// Initialize the AI engine
  static Future<void> initialize({String? systemInstructions});

  /// Parse voice command from transcription
  static Future<VoiceCommand> parseVoiceCommand(String transcription);

  /// Summarize text content
  static Future<String> summarize(String text, {SummarizationConfig? config});

  /// Summarize podcast episode
  static Future<EpisodeSummary> summarizeEpisode({
    required String title,
    required String description,
    String? transcript,
  });

  /// Prompt to install AI Core (Android only)
  static Future<void> promptAiCoreInstall();

  /// Dispose resources
  static Future<void> dispose();
}
```

### Models

```dart
/// Device AI capability levels
enum AiCapability {
  full,           // All features available
  limited,        // Basic features only
  unavailable,    // Device not supported
  needsSetup,     // Needs AICore install (Android)
}

/// Parsed voice command
@freezed
class VoiceCommand with _$VoiceCommand {
  const factory VoiceCommand({
    required VoiceIntent intent,
    required Map<String, dynamic> parameters,
    required double confidence,
  }) = _VoiceCommand;
}

/// Voice command intent types
enum VoiceIntent {
  play,
  pause,
  resume,
  stop,
  search,
  skipForward,
  skipBackward,
  playLatestEpisode,
  unknown,
}

/// Episode summary result
@freezed
class EpisodeSummary with _$EpisodeSummary {
  const factory EpisodeSummary({
    required String summary,
    required List<String> keyTopics,
    String? recommendation,
  }) = _EpisodeSummary;
}
```

---

## Tasks

### Task 1: Create Package Structure

**Files:**
- Create: `packages/audiflow_ai/pubspec.yaml`
- Create: `packages/audiflow_ai/lib/audiflow_ai.dart`

**Step 1:** Create pubspec.yaml
```yaml
name: audiflow_ai
description: On-device AI capabilities for Audiflow
version: 0.1.0
publish_to: none

environment:
  sdk: '>=3.10.0 <4.0.0'
  flutter: '>=3.38.0'

dependencies:
  flutter:
    sdk: flutter
  audiflow_core:
    path: ../audiflow_core
  flutter_local_ai: ^0.0.6
  freezed_annotation: ^3.0.0
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.0
  freezed: ^3.0.0
  json_serializable: ^6.9.0
```

**Step 2:** Register in root pubspec.yaml workspace

### Task 2: Create Core Models

**Files:**
- Create: `packages/audiflow_ai/lib/src/core/ai_capability.dart`
- Create: `packages/audiflow_ai/lib/src/core/ai_exceptions.dart`
- Create: `packages/audiflow_ai/lib/src/nlu/voice_command.dart`
- Create: `packages/audiflow_ai/lib/src/nlu/intent_types.dart`
- Create: `packages/audiflow_ai/lib/src/summarization/episode_summary.dart`

### Task 3: Create Voice Command Parser

**Files:**
- Create: `packages/audiflow_ai/lib/src/nlu/voice_command_parser.dart`

```dart
class VoiceCommandParser {
  static const _playPatterns = [
    r'play\s+(.+)',
    r'start\s+(.+)',
    r'listen\s+to\s+(.+)',
  ];

  static const _latestEpisodePatterns = [
    r'play\s+(?:the\s+)?latest\s+(?:episode\s+(?:of\s+)?)?(.+)',
    r'latest\s+(?:episode\s+(?:of\s+)?)?(.+)',
  ];

  Future<VoiceCommand> parse(String transcription) async {
    final normalized = transcription.toLowerCase().trim();

    // Check for latest episode intent
    for (final pattern in _latestEpisodePatterns) {
      final match = RegExp(pattern).firstMatch(normalized);
      if (match != null) {
        return VoiceCommand(
          intent: VoiceIntent.playLatestEpisode,
          parameters: {'podcastName': match.group(1)?.trim()},
          confidence: 0.9,
        );
      }
    }

    // Check for play intent
    for (final pattern in _playPatterns) {
      final match = RegExp(pattern).firstMatch(normalized);
      if (match != null) {
        return VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {'query': match.group(1)?.trim()},
          confidence: 0.85,
        );
      }
    }

    // Simple commands
    if (normalized.contains('pause')) {
      return const VoiceCommand(
        intent: VoiceIntent.pause,
        parameters: {},
        confidence: 0.95,
      );
    }

    return const VoiceCommand(
      intent: VoiceIntent.unknown,
      parameters: {},
      confidence: 0.0,
    );
  }
}
```

### Task 4: Create Summarization Service

**Files:**
- Create: `packages/audiflow_ai/lib/src/summarization/summarizer.dart`
- Create: `packages/audiflow_ai/lib/src/summarization/episode_summarizer.dart`

### Task 5: Create Main API Class

**Files:**
- Create: `packages/audiflow_ai/lib/src/audiflow_ai_impl.dart`

```dart
class AudiflowAiImpl {
  static AudiflowAiImpl? _instance;
  static AiCapability? _capability;
  static bool _initialized = false;

  static Future<AiCapability> checkCapability() async {
    if (_capability != null) return _capability!;

    final isAvailable = await LocalAi.isAvailable();
    if (!isAvailable) {
      _capability = AiCapability.unavailable;
      return _capability!;
    }

    // Check for AICore on Android
    // ...

    _capability = AiCapability.full;
    return _capability!;
  }

  static Future<void> initialize({String? systemInstructions}) async {
    if (_initialized) return;

    final instructions = systemInstructions ?? '''
You are an AI assistant for Audiflow, a podcast player app.
Help users with podcast-related tasks like playing episodes,
searching for podcasts, and summarizing content.
''';

    await LocalAi.init(systemInstructions: instructions);
    _initialized = true;
  }

  static Future<VoiceCommand> parseVoiceCommand(String transcription) async {
    // Use AI for complex parsing, regex for simple commands
    final parser = VoiceCommandParser();
    return parser.parse(transcription);
  }

  // ... other methods
}
```

### Task 6: Write Tests

**Files:**
- Create: `packages/audiflow_ai/test/nlu/voice_command_parser_test.dart`
- Create: `packages/audiflow_ai/test/summarization/episode_summarizer_test.dart`

### Task 7: Export and Document

**Files:**
- Modify: `packages/audiflow_ai/lib/audiflow_ai.dart`

---

## Device Requirements

| Platform | Minimum | AI Capability | Notes |
|----------|---------|---------------|-------|
| **Android** | Pixel 9 series | Full | Default enabled |
| **Android** | Pixel 8 Pro | Full | Default enabled |
| **Android** | Pixel 8, 8a | Full | Requires developer option |
| **iOS** | iPhone 15 Pro+ | Full | iOS 26+ required |
| **Others** | Any | Unavailable | No on-device AI |

---

## Verification

1. **Unit Tests**: Run `melos run test --scope=audiflow_ai`
2. **Manual Testing**:
   - Test capability detection on various devices
   - Test voice command parsing with sample transcriptions
   - Test summarization with episode descriptions
3. **Build Verification**: `melos bootstrap && melos run analyze`

---

## Dependencies

This package enables:
- Voice Command Integration (2025-01-20-voice-command-integration.md)
- Future: Episode summarization feature
- Future: Smart recommendations
