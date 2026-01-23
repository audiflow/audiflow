# Player Feature Documentation

This document covers the audio playback and seek functionality in Audiflow.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        PlayerScreen                             │
│  ┌───────────────┐  ┌─────────────────┐  ┌──────────────────┐  │
│  │ _PlayerArtwork│  │ _PlayerProgressBar│  │ _PlayerControls │  │
│  └───────────────┘  └────────┬────────┘  └────────┬─────────┘  │
│                              │                     │            │
│         ┌────────────────────┴─────────────────────┘            │
│         │  UI State (isSeeking, wasPlayingBeforeSeek)           │
│         └────────────────────┬──────────────────────            │
└──────────────────────────────┼──────────────────────────────────┘
                               │
┌──────────────────────────────┼──────────────────────────────────┐
│                    audiflow_domain                              │
│  ┌───────────────────────────┴───────────────────────────────┐  │
│  │              AudioPlayerController (Riverpod)             │  │
│  │  - play(), pause(), resume(), stop()                      │  │
│  │  - seek(), skipForward(), skipBackward()                  │  │
│  │  - PlaybackState stream                                   │  │
│  └───────────────────────────┬───────────────────────────────┘  │
│                              │                                  │
│  ┌───────────────────────────┴───────────────────────────────┐  │
│  │              playbackProgressStream (Riverpod)            │  │
│  │  - position, duration, bufferedPosition                   │  │
│  └───────────────────────────┬───────────────────────────────┘  │
└──────────────────────────────┼──────────────────────────────────┘
                               │
                    ┌──────────┴──────────┐
                    │    just_audio       │
                    │    AudioPlayer      │
                    └─────────────────────┘
```

## Core Components

### AudioPlayerController

Location: `packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart`

A Riverpod controller that wraps `just_audio`'s `AudioPlayer` and exposes a simplified interface.

#### Providers

| Provider | Type | KeepAlive | Description |
|----------|------|-----------|-------------|
| `audioPlayerProvider` | `AudioPlayer` | Yes | Singleton AudioPlayer instance |
| `playbackProgressStreamProvider` | `Stream<PlaybackProgress>` | Yes | Combined position/duration/buffered stream |
| `playbackProgressProvider` | `PlaybackProgress?` | No | Current progress snapshot |
| `audioPlayerControllerProvider` | `PlaybackState` | Yes | Main controller with playback state |

#### PlaybackState

Sealed class representing current playback state:

```dart
sealed class PlaybackState {
  const factory PlaybackState.idle();
  const factory PlaybackState.loading({required String episodeUrl});
  const factory PlaybackState.playing({required String episodeUrl});
  const factory PlaybackState.paused({required String episodeUrl});
  const factory PlaybackState.error({required String message});
}
```

#### API Reference

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `play` | `String url`, `{NowPlayingInfo? metadata}` | `Future<void>` | Load and play audio from URL |
| `pause` | - | `Future<void>` | Pause current playback |
| `resume` | - | `Future<void>` | Resume paused playback |
| `togglePlayPause` | `[String? url]` | `Future<void>` | Toggle play/pause state |
| `stop` | - | `Future<void>` | Stop and clear audio source |
| `seek` | `Duration position` | `Future<void>` | Seek to position (clamped) |
| `skipForward` | `[Duration amount = 30s]` | `Future<void>` | Skip forward by amount |
| `skipBackward` | `[Duration amount = 30s]` | `Future<void>` | Skip backward by amount |

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `currentUrl` | `String?` | URL of currently loaded audio |
| `isPlaying(url)` | `bool` | Check if specific URL is playing |
| `isLoaded(url)` | `bool` | Check if specific URL is loaded |

### PlaybackProgress

Location: `packages/audiflow_domain/lib/src/features/player/models/playback_progress.dart`

```dart
class PlaybackProgress {
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;

  /// Progress as 0.0-1.0 ratio
  double get progress => duration.inMilliseconds == 0
      ? 0.0
      : position.inMilliseconds / duration.inMilliseconds;
}
```

## Seek Functionality

### Seeking via Seekbar

The seekbar uses local state tracking to prevent UI flicker during drag operations.

#### Problem

When dragging the seekbar while audio is playing:
1. User drags slider to new position
2. `playbackProgressStream` continues emitting current playback position
3. Slider value fights between drag position and playback position
4. Results in visual flicker/jitter

#### Solution: Local State Override

`_PlayerProgressBar` tracks local drag state:

```dart
class _PlayerProgressBarState extends ConsumerState<_PlayerProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  // Display drag value when dragging, otherwise actual progress
  final displayValue = _isDragging ? _dragValue : (progress?.progress ?? 0.0);
}
```

Slider callbacks:
- `onChangeStart`: Set `_isDragging = true`, capture initial value
- `onChanged`: Update `_dragValue` only (no seek during drag)
- `onChangeEnd`: Perform seek, wait for stabilization, set `_isDragging = false`

### Seeking via Skip Buttons

30-second skip forward/backward buttons use the same pattern.

```dart
Future<void> _handleSkip(
  Future<void> Function() skipAction,
  bool wasPlaying,
) async {
  setState(() {
    _isSeeking = true;
    _wasPlayingBeforeSeek = wasPlaying;
  });
  await skipAction();
  await Future<void>.delayed(const Duration(milliseconds: 150));
  if (!mounted) return;
  setState(() => _isSeeking = false);
}
```

## UI Flicker Prevention

### Problem

During seek/skip operations, `AudioPlayer` briefly enters buffering/loading state, causing:
1. `PlaybackState` to emit `loading` state
2. Play/pause button to show loading indicator
3. `isPlaying` to become `false` momentarily
4. Button icon to flicker between play/pause

### Solution: State Preservation

`PlayerScreen` tracks seeking state and preserves UI state during operations:

```dart
class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _isSeeking = false;
  bool _wasPlayingBeforeSeek = false;

  @override
  Widget build(BuildContext context) {
    final isPlaying = playbackState is PlaybackPlaying;
    final isLoading = playbackState is PlaybackLoading;

    // Preserve state during seeking
    final displayIsPlaying = _isSeeking ? _wasPlayingBeforeSeek : isPlaying;
    final displayIsLoading = _isSeeking ? false : isLoading;

    // Pass preserved state to controls
    _PlayerControls(
      isPlaying: displayIsPlaying,
      isLoading: displayIsLoading,
      // ...
    );
  }
}
```

#### State Flow

```
User taps skip button
        │
        ▼
┌───────────────────────────────┐
│ _isSeeking = true             │
│ _wasPlayingBeforeSeek = true  │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│ displayIsPlaying = true       │  ← Preserved from before seek
│ displayIsLoading = false      │  ← Suppressed during seek
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│ await skipAction()            │
│ await 150ms stabilization     │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│ _isSeeking = false            │
│ UI reflects actual state      │
└───────────────────────────────┘
```

#### Stabilization Delay

The 150ms delay after seek allows `AudioPlayer` to:
1. Complete the seek operation
2. Transition through buffering state
3. Return to playing/paused state

Without this delay, `onSeekEnd` fires while player is still buffering, causing flicker.

## Edge Case Handling

### Seek Operations

| Case | Behavior |
|------|----------|
| No audio loaded | Early return, no-op |
| Duration unknown | Early return, no-op |
| Seek past end | Clamped to duration |
| Seek before start | Clamped to zero |
| Skip forward at end | Stays at end (clamped) |
| Skip backward at start | Stays at start (clamped) |
| Widget unmounted during async | `mounted` check prevents setState |

### Position Clamping

```dart
Future<void> seek(Duration position) async {
  if (_currentUrl == null) return;
  final duration = _player.duration;
  if (duration == null) return;

  final clampedMs = position.inMilliseconds.clamp(0, duration.inMilliseconds);
  await _player.seek(Duration(milliseconds: clampedMs));
}
```

## File Locations

| Component | Path |
|-----------|------|
| AudioPlayerController | `packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart` |
| PlaybackState | `packages/audiflow_domain/lib/src/features/player/models/playback_state.dart` |
| PlaybackProgress | `packages/audiflow_domain/lib/src/features/player/models/playback_progress.dart` |
| NowPlayingInfo | `packages/audiflow_domain/lib/src/features/player/models/now_playing_info.dart` |
| PlayerScreen | `packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart` |

## Usage Examples

### Basic Playback

```dart
// Watch playback state
final state = ref.watch(audioPlayerControllerProvider);
final controller = ref.read(audioPlayerControllerProvider.notifier);

// Play episode
await controller.play(
  'https://example.com/episode.mp3',
  metadata: NowPlayingInfo(
    episodeUrl: url,
    episodeTitle: 'Episode Title',
    podcastTitle: 'Podcast Name',
    artworkUrl: 'https://example.com/artwork.jpg',
  ),
);

// Control playback
await controller.pause();
await controller.resume();
await controller.togglePlayPause();

// Seek
await controller.seek(Duration(minutes: 5));
await controller.skipForward();  // +30s
await controller.skipBackward(); // -30s
```

### Watch Progress

```dart
final progress = ref.watch(playbackProgressProvider);

if (progress != null) {
  print('Position: ${progress.position}');
  print('Duration: ${progress.duration}');
  print('Progress: ${(progress.progress * 100).toStringAsFixed(1)}%');
}
```

### Check State

```dart
final state = ref.watch(audioPlayerControllerProvider);

state.when(
  idle: () => print('No audio'),
  loading: (url) => print('Loading: $url'),
  playing: (url) => print('Playing: $url'),
  paused: (url) => print('Paused: $url'),
  error: (msg) => print('Error: $msg'),
);
```
