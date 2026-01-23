# [ACTIVE] Voice Command Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable voice command "Play the latest episode of 'The Daily'" by integrating `audiflow_ai` with speech recognition.

**Architecture:** SpeechRecognitionRepository wraps speech_to_text package. VoiceCommandOrchestrator manages state machine. PlayPodcastByNameService coordinates search, feed parsing, and playback.

**Tech Stack:** Flutter, speech_to_text, audiflow_ai, Riverpod, Freezed

**Status:** ACTIVE - Awaiting audiflow_ai package implementation

---

## Overview

The `audiflow_ai` package already provides `parseVoiceCommand(transcription)` for NLU but not speech-to-text. This plan adds:
1. Speech recognition via `speech_to_text` package
2. Voice command orchestration service
3. UI integration with FAB and overlay

## Architecture

```
User speaks → speech_to_text → transcription
                                    ↓
                        AudiflowAi.parseVoiceCommand()
                                    ↓
                        VoiceCommand { intent: play, parameters: {podcastName: "The Daily"} }
                                    ↓
                        VoiceCommandExecutor.execute()
                                    ↓
            ┌───────────────────────┴───────────────────────┐
            ↓                                               ↓
    PodcastSearchService.search()                   AudioPlayerController
            ↓                                               ↑
    FeedParserService.parseFromUrl()                        │
            ↓                                               │
    Find latest episode by publishDate ─────────────────────┘
```

## Tasks

### Task 1: Dependencies & Platform Config

**1.1 Add dependencies**
- `audiflow_domain/pubspec.yaml`: Add `speech_to_text: ^7.3.0`
- `audiflow_app/pubspec.yaml`: Add dependency on `audiflow_ai`

**1.2 Platform permissions**
- `ios/Runner/Info.plist`:
  ```xml
  <key>NSSpeechRecognitionUsageDescription</key>
  <string>Voice commands for hands-free podcast control</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>Microphone access for voice commands</string>
  ```
- `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.RECORD_AUDIO"/>
  <queries>
    <intent>
      <action android:name="android.speech.RecognitionService"/>
    </intent>
  </queries>
  ```

### Task 2: Domain Layer (audiflow_domain)

**2.1 Create voice feature directory structure**
```
packages/audiflow_domain/lib/src/features/voice/
├── models/
│   └── voice_recognition_state.dart
├── repositories/
│   ├── speech_recognition_repository.dart
│   └── speech_recognition_repository_impl.dart
└── services/
    ├── voice_command_orchestrator.dart
    └── play_podcast_by_name_service.dart
```

**2.2 VoiceRecognitionState model**
```dart
@freezed
sealed class VoiceRecognitionState with _$VoiceRecognitionState {
  const factory VoiceRecognitionState.idle() = VoiceIdle;
  const factory VoiceRecognitionState.listening({String? partialTranscript}) = VoiceListening;
  const factory VoiceRecognitionState.processing({required String transcription}) = VoiceProcessing;
  const factory VoiceRecognitionState.executing({required VoiceCommand command}) = VoiceExecuting;
  const factory VoiceRecognitionState.success({required String message}) = VoiceSuccess;
  const factory VoiceRecognitionState.error({required String message}) = VoiceError;
}
```

**2.3 SpeechRecognitionRepository interface & impl**
- Interface: `initialize()`, `isAvailable`, `startListening()`, `stopListening()`, `dispose()`
- Implementation: Wraps `speech_to_text` package

**2.4 VoiceCommandOrchestrator service**
- Riverpod `@riverpod` notifier managing `VoiceRecognitionState`
- Methods: `startVoiceCommand()`, `cancelVoiceCommand()`
- Flow: Start listening → Get transcription → Call `AudiflowAi.parseVoiceCommand()` → Route to executor

**2.5 PlayPodcastByNameService**
```dart
Future<void> playLatestEpisode(String podcastName) async {
  // 1. Search for podcast via PodcastSearchService
  // 2. Get feedUrl from first result
  // 3. Parse feed via FeedParserService
  // 4. Find latest episode (sort by publishDate)
  // 5. Play via AudioPlayerController.play(enclosureUrl)
}
```

### Task 3: Presentation Layer (audiflow_app)

**3.1 Create voice feature directory**
```
packages/audiflow_app/lib/features/voice/
└── presentation/
    ├── controllers/
    │   └── voice_command_controller.dart
    └── widgets/
        ├── voice_command_fab.dart
        └── voice_listening_overlay.dart
```

**3.2 VoiceCommandController**
- Thin wrapper calling `VoiceCommandOrchestrator` from domain
- Handles UI-specific feedback (snackbars, navigation)

**3.3 VoiceCommandFab widget**
- Microphone FAB button
- Shows pulsing animation when listening
- Triggers `startVoiceCommand()`

**3.4 VoiceListeningOverlay widget**
- Semi-transparent overlay shown during listening/processing
- Displays partial transcription in real-time
- Cancel button

**3.5 Integrate into ScaffoldWithNavBar**
- Convert to `ConsumerWidget`
- Add `VoiceCommandFab` as `floatingActionButton`
- Show `VoiceListeningOverlay` in Stack when listening

### Task 4: Export & Code Generation
- `audiflow_domain/lib/audiflow_domain.dart`: Export voice feature
- Run `dart run build_runner build --delete-conflicting-outputs`

## Critical Files to Modify

| File | Change |
|------|--------|
| `packages/audiflow_domain/pubspec.yaml` | Add `speech_to_text` |
| `packages/audiflow_app/pubspec.yaml` | Add `audiflow_ai` dependency |
| `packages/audiflow_app/ios/Runner/Info.plist` | Add speech/mic permissions |
| `packages/audiflow_app/android/app/src/main/AndroidManifest.xml` | Add RECORD_AUDIO permission |
| `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart` | Add FAB + overlay integration |
| `packages/audiflow_domain/lib/audiflow_domain.dart` | Export voice feature |

## Verification

1. **Unit tests**: Test `PlayPodcastByNameService` with mocked search/feed services
2. **Manual testing**:
   - Launch app on physical device (simulator has limited speech support)
   - Tap FAB → speak "Play the latest episode of The Daily"
   - Verify: overlay appears, transcription shows, podcast plays
3. **Edge cases**:
   - Podcast not found → show error snackbar
   - No episodes → show error snackbar
   - Low confidence → ask for confirmation
   - Cancel mid-listening → return to idle state

## Dependencies

Blocked by: `audiflow_ai` package implementation (see 2025-01-20-ai-engine-feasibility.md)

## Branch Name
`feat/voice-command-integration`
