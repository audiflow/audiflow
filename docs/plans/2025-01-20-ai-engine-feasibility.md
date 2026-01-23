# [ACTIVE] AI Engine Feasibility Study

> **For Claude:** This is a research/feasibility document. Use superpowers:brainstorming before implementation.

**Goal:** Research and design on-device AI capabilities for voice communication and content summarization in Audiflow.

**Architecture:** Platform-native on-device AI (ML Kit GenAI for Android, Apple Foundation Models for iOS) with custom `audiflow_ai` wrapper package.

**Tech Stack:** flutter_local_ai, ML Kit GenAI APIs, Apple Foundation Models, speech_to_text

**Status:** ACTIVE - Research complete, awaiting implementation

---

## Executive Summary

**Target:** Flagship devices only (Pixel 8+, iPhone 15+)
**Offline:** Essential requirement

**Recommendation:** Platform-native on-device AI

| Platform | Solution | Status |
|----------|----------|--------|
| **Android** | ML Kit GenAI APIs (Gemini Nano) | Production-ready |
| **iOS** | Apple Foundation Models framework | Production-ready (WWDC 2025) |

Both are system-managed (no model download by app), privacy-focused, and free.

---

## Option Comparison

| Aspect | Platform-Native On-Device | `firebase_ai` (Cloud) | Cross-Platform On-Device |
|--------|--------------------------|----------------------|-------------------------|
| **Android** | ML Kit GenAI (Gemini Nano) | Gemini API | `ai_edge` / Gemma |
| **iOS** | Foundation Models | Gemini API | `ai_edge` / Gemma |
| **Status** | Production-ready | Production-ready | Experimental |
| **Offline** | Yes | No | Yes |
| **Model management** | System-managed | N/A | App downloads 2-4GB |
| **Cost** | Free | Pay-per-use | Free |
| **Flutter integration** | Platform channels | `firebase_ai` package | `ai_edge` package |

---

## Recommended Implementation: Custom `audiflow_ai` Package

### Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                   audiflow_app                          │
│  ┌─────────────────┐  ┌─────────────────────────────┐  │
│  │ Voice Feature   │  │ Summarization Feature       │  │
│  │ - Voice Input   │  │ - Episode Summary           │  │
│  │ - Voice Commands│  │ - Show Notes Generation     │  │
│  └────────┬────────┘  └──────────────┬──────────────┘  │
└───────────┼──────────────────────────┼──────────────────┘
            │                          │
┌───────────┴──────────────────────────┴──────────────────┐
│                   audiflow_domain                        │
│  ┌─────────────────────────────────────────────────────┐│
│  │              AI Service                             ││
│  │  - Uses audiflow_ai package                         ││
│  │  - Response caching (Drift)                         ││
│  └─────────────────────────────────────────────────────┘│
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────┴──────────────────────────────┐
│            audiflow_ai (NEW PACKAGE)                     │
│  ┌─────────────────────────────────────────────────────┐│
│  │  AudiflowAi                                         ││
│  │  - isAvailable()                                    ││
│  │  - initialize()                                     ││
│  │  - generateText()                                   ││
│  │  - summarize()          ← Extended feature          ││
│  │  - summarizeEpisode()   ← Extended feature          ││
│  └─────────────────────────────────────────────────────┘│
│                          │                               │
│  ┌───────────────────────┴───────────────────────────┐  │
│  │           flutter_local_ai (dependency)           │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                     │
┌───────┴───────┐                    ┌────────┴────────┐
│    Android    │                    │      iOS        │
│   ML Kit      │                    │   Foundation    │
│   GenAI API   │                    │     Models      │
└───────────────┘                    └─────────────────┘
```

### Package API Design

```dart
/// Main entry point for Audiflow AI capabilities
class AudiflowAi {
  /// Check if on-device AI is available
  static Future<AiCapability> checkCapability();

  /// Initialize the AI engine
  static Future<void> initialize({String? systemInstructions});

  /// Generate text with custom prompt
  static Future<AiResponse> generateText({
    required String prompt,
    GenerationConfig? config,
  });

  /// Summarize text (extended feature)
  static Future<String> summarize({
    required String text,
    SummarizationConfig? config,
  });

  /// Summarize podcast episode (extended feature)
  static Future<EpisodeSummary> summarizeEpisode({
    required String title,
    required String description,
    String? transcript,
    SummarizationConfig? config,
  });

  /// Parse voice command (extended feature)
  static Future<VoiceCommand> parseVoiceCommand({
    required String transcription,
  });

  /// Prompt user to install AICore (Android only)
  static Future<void> promptAiCoreInstall();
}

/// Device AI capability levels
enum AiCapability {
  full,           // All features available
  limited,        // Basic features only
  unavailable,    // Device not supported
  needsSetup,     // Needs AICore install (Android)
}
```

### Implementation Phases

#### Phase 1: Create `audiflow_ai` Package
1. Create package structure in `packages/audiflow_ai/`
2. Add `flutter_local_ai` as dependency
3. Implement base wrapper: `AudiflowAi` class
4. Add capability detection and initialization
5. Write unit tests

#### Phase 2: Implement Summarization
1. Create `SummarizationService` with prompt templates
2. Implement text chunking for long content
3. Add `SummarizationConfig` options
4. Create `summarizeEpisode()` with podcast-specific prompts
5. Write tests with sample podcast content

#### Phase 3: Integrate into Domain
1. Add `audiflow_ai` dependency to `audiflow_domain`
2. Create `AIService` that uses `AudiflowAi`
3. Implement caching layer (Drift)
4. Add to episode detail feature

#### Phase 4: Voice Communication
1. Add voice command parsing to `audiflow_ai`
2. Integrate `speech_to_text` in `audiflow_app`
3. Create `VoiceService` coordinating STT + AI
4. UI: voice button with real-time feedback

### Device Requirements

| Platform | Minimum | AI Capability | Notes |
|----------|---------|---------------|-------|
| **Android** | Pixel 9 series | Full ML Kit GenAI | Default enabled |
| **Android** | Pixel 8 Pro | Full ML Kit GenAI | Default enabled |
| **Android** | Pixel 8, 8a | ML Kit GenAI | Requires developer option |
| **iOS** | iPhone 15 Pro+ | Full Foundation Models | iOS 26+ required |
| **Others** | Any | Fallback to firebase_ai | Optional cloud fallback |

### Known Limitations (flutter_local_ai)

- **Streaming:** Not yet implemented (full response only)
- **Android AICore:** May require separate installation (error -101)
- **Tool calling:** iOS/macOS only
- **Package maturity:** Version 0.0.4, actively developed

### Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Package early stage | Monitor releases, abstract behind repository |
| AICore not installed | Prompt user with `openAICorePlayStore()` |
| Device not supported | `isAvailable()` check + graceful fallback |
| Inconsistent quality | Unified prompts, test on both platforms |
| Streaming not available | Design UI for full response pattern |

---

## Sources

### Recommended Package
- [flutter_local_ai](https://pub.dev/packages/flutter_local_ai) - Unified cross-platform on-device AI
- [GitHub: flutter_local_ai](https://github.com/kekko7072/flutter_local_ai) - Source code

### Platform-Native APIs

**Android - ML Kit GenAI:**
- [ML Kit GenAI APIs Overview](https://developers.google.com/ml-kit/genai) - Official docs
- [Gemini Nano on Android](https://developer.android.com/ai/gemini-nano) - Developer guide

**iOS - Apple Foundation Models:**
- [Apple Foundation Models 2025](https://machinelearning.apple.com/research/apple-foundation-models-2025-updates) - Technical report
- [Foundation Models Framework](https://www.macrumors.com/2025/06/09/foundation-models-framework/) - WWDC 2025
