# [COMPLETED] Unit Tests for Mini Player and Player Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Write comprehensive unit tests for the player feature covering both domain layer (audiflow_domain) and presentation layer (audiflow_app).

**Architecture:** Mock implementations for AudioPlayer and controllers. Provider override pattern for widget testing. Test coverage for PlaybackProgress, AudioPlayerController, NowPlayingController, PlayerScreen, MiniPlayer, and AnimatedMiniPlayer.

**Tech Stack:** Flutter, flutter_test, Riverpod, Mocktail

**Status:** COMPLETED

---

## Test Files to Create

### 1. `packages/audiflow_domain/test/features/player/models/playback_progress_test.dart`
Unit tests for PlaybackProgress model:
- `progress` getter returns 0.0 when duration is zero
- `progress` getter calculates correct ratio (position/duration)
- `progress` getter clamps to [0.0, 1.0] range
- `bufferedProgress` getter same edge cases

### 2. `packages/audiflow_domain/test/features/player/services/audio_player_controller_test.dart`
Unit tests for AudioPlayerController:
- **Initialization**: Builds with idle state
- **play()**: Sets loading state, updates now playing, handles errors
- **pause()/resume()**: Delegates to AudioPlayer
- **seek()**: Clamps position, early return on null URL/duration
- **skipForward()**: Adds 30s (default), clamps at end
- **skipBackward()**: Subtracts 30s (default), clamps at 0
- **isPlaying(url)**: Returns true only for matching URL in playing state
- **isLoaded(url)**: Returns true when URL matches currentUrl

### 3. `packages/audiflow_domain/test/features/player/services/now_playing_controller_test.dart`
Unit tests for NowPlayingController:
- **build()**: Returns null initially
- **setNowPlaying()**: Updates state with NowPlayingInfo
- **clear()**: Sets state to null
- **updateArtworkUrl()**: Uses copyWith to update artwork

### 4. `packages/audiflow_app/test/helpers/player_mocks.dart`
Mock implementations following existing patterns:
- `MockAudioPlayer` - Mock just_audio AudioPlayer
- `MockAudioPlayerController` - Mock controller with configurable state
- `MockNowPlayingController` - Mock now playing state

### 5. `packages/audiflow_app/test/features/player/presentation/screens/player_screen_test.dart`
Widget tests for PlayerScreen:
- Renders all components (artwork, progress bar, controls)
- Displays play/pause button based on playback state
- Shows loading indicator when loading
- Preserves play state during seek (_isSeeking, _wasPlayingBeforeSeek)
- Skip buttons trigger _handleSkip with correct state management
- Seekbar drag updates local state without immediate seek

### 6. `packages/audiflow_app/test/features/player/presentation/widgets/mini_player_test.dart`
Widget tests for MiniPlayer:
- Returns SizedBox.shrink when nowPlaying is null
- Displays episode title and podcast title
- Shows play/pause button based on state
- Progress bar reflects current progress
- onTap callback invoked when tapped

### 7. `packages/audiflow_app/test/features/player/presentation/widgets/animated_mini_player_test.dart`
Widget tests for AnimatedMiniPlayer:
- Animation controller initialized and disposed
- Slides up when nowPlaying becomes non-null
- Slides down when nowPlaying becomes null
- Visible during playing, paused, and loading states

## Implementation Details

### Mock Strategy
```dart
class MockAudioPlayer implements AudioPlayer {
  Duration position = Duration.zero;
  Duration? duration;
  bool playing = false;

  final positionController = StreamController<Duration>.broadcast();
  final durationController = StreamController<Duration?>.broadcast();

  @override
  Stream<Duration> get positionStream => positionController.stream;
}
```

### Provider Override Pattern
```dart
final container = ProviderContainer(
  overrides: [
    audioPlayerProvider.overrideWithValue(mockPlayer),
    audioPlayerControllerProvider.overrideWith(() => mockController),
    nowPlayingControllerProvider.overrideWith(() => mockNowPlaying),
    playbackProgressProvider.overrideWithValue(mockProgress),
  ],
);
addTearDown(container.dispose);
```

### Widget Test Pattern
```dart
Widget buildPlayerScreen({ProviderContainer? container}) {
  return UncontrolledProviderScope(
    container: container ?? createMockContainer(),
    child: const MaterialApp(home: PlayerScreen(episodeUrl: 'test-url')),
  );
}
```

## Test Cases Summary

| Component | Test Count | Focus Areas |
|-----------|------------|-------------|
| PlaybackProgress | 6 | Progress calculation, edge cases |
| AudioPlayerController | 12 | All methods, state transitions, clamping |
| NowPlayingController | 4 | State management |
| PlayerScreen | 8 | State preservation, UI rendering |
| MiniPlayer | 5 | Visibility, data binding |
| AnimatedMiniPlayer | 4 | Animation lifecycle |

**Total: ~39 tests**

## File Structure
```
packages/
├── audiflow_domain/test/
│   └── features/player/
│       ├── models/
│       │   └── playback_progress_test.dart
│       └── services/
│           ├── audio_player_controller_test.dart
│           └── now_playing_controller_test.dart
└── audiflow_app/test/
    ├── helpers/
    │   └── player_mocks.dart
    └── features/player/
        └── presentation/
            ├── screens/
            │   └── player_screen_test.dart
            └── widgets/
                ├── mini_player_test.dart
                └── animated_mini_player_test.dart
```

## Verification
1. Run tests: `melos run test --scope=audiflow_domain` and `melos run test --scope=audiflow_app`
2. Verify all tests pass
3. Check coverage for player feature files
