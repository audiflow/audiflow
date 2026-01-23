# [COMPLETED] Player Feature Initialization

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Initialize the player feature module with basic audio playback capability.

**Architecture:** AudioPlayerService wraps just_audio with Riverpod state management. keepAlive providers ensure playback continues across navigation.

**Tech Stack:** Flutter, just_audio, audio_service, audio_session, Riverpod

**Status:** COMPLETED - Initial implementation done, extended in subsequent plans

---

## Feature Scope

This initialization covers:
1. AudioPlayer instance provider (keepAlive)
2. Basic play/pause/stop functionality
3. Playback state management
4. Integration with episode list

## Tasks

### Task 1: Create Player Directory Structure

```
packages/audiflow_domain/lib/src/features/player/
├── models/
│   └── playback_state.dart
└── services/
    └── audio_player_service.dart
```

### Task 2: Define PlaybackState Model

```dart
@freezed
sealed class PlaybackState with _$PlaybackState {
  const factory PlaybackState.idle() = PlaybackIdle;
  const factory PlaybackState.loading({required String episodeUrl}) = PlaybackLoading;
  const factory PlaybackState.playing({required String episodeUrl}) = PlaybackPlaying;
  const factory PlaybackState.paused({required String episodeUrl}) = PlaybackPaused;
  const factory PlaybackState.error({required String message}) = PlaybackError;
}
```

### Task 3: Create Audio Player Provider

```dart
@Riverpod(keepAlive: true)
AudioPlayer audioPlayer(Ref ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
}
```

### Task 4: Create Audio Player Controller

```dart
@Riverpod(keepAlive: true)
class AudioPlayerController extends _$AudioPlayerController {
  @override
  PlaybackState build() => const PlaybackState.idle();

  Future<void> play(String url) async { ... }
  Future<void> pause() async { ... }
  Future<void> resume() async { ... }
  Future<void> stop() async { ... }
  bool isPlaying(String url) { ... }
}
```

### Task 5: Export from Domain Package

Update `audiflow_domain.dart` to export:
- `playback_state.dart`
- `audio_player_service.dart`

### Task 6: Run Code Generation

```bash
cd packages/audiflow_domain
dart run build_runner build --delete-conflicting-outputs
```

## Verification

1. Play an episode from podcast detail
2. Audio starts playing
3. Tap pause - audio pauses
4. Tap play - audio resumes
5. Navigate away - audio continues
6. Return to screen - correct state shown

## Subsequent Extensions

This initialization was extended by:
- Mini Player (2025-01-19-mini-player.md)
- Seekbar and Skip Controls (2025-01-20-seekbar-and-skip-controls.md)
- Episode Tracking (2025-01-23-episode-tracking-*.md)
