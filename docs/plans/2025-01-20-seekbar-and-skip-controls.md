# [COMPLETED] Seekbar and Skip Controls Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add functional seekbar and 30-second skip forward/backward buttons to the player screen.

**Architecture:** Extend AudioPlayerController with `seek()`, `skipForward()`, `skipBackward()` methods. Wire PlayerScreen UI controls to call these methods with proper position clamping.

**Tech Stack:** Flutter, just_audio, Riverpod

**Status:** COMPLETED

---

## Summary

Add functional seekbar and 30-second skip forward/backward buttons to the player screen by:
1. Adding `seek()`, `skipForward()`, `skipBackward()` methods to `AudioPlayerController`
2. Wiring UI controls to call these methods

## Tasks

### Task 1: Add Seek Methods to AudioPlayerController

**File:** `packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart`

Add three methods to `AudioPlayerController`:

```dart
/// Seeks to the specified position.
/// Clamps position between zero and duration to prevent invalid seeks.
Future<void> seek(Duration position) async {
  if (_currentUrl == null) return;
  final duration = _player.duration;
  if (duration == null) return;

  final clampedMs = position.inMilliseconds.clamp(0, duration.inMilliseconds);
  await _player.seek(Duration(milliseconds: clampedMs));
}

/// Skips forward by the specified duration (default 30s).
Future<void> skipForward([Duration amount = const Duration(seconds: 30)]) async {
  if (_currentUrl == null) return;
  await seek(_player.position + amount);
}

/// Skips backward by the specified duration (default 30s).
Future<void> skipBackward([Duration amount = const Duration(seconds: 30)]) async {
  if (_currentUrl == null) return;
  await seek(_player.position - amount);
}
```

### Task 2: Update Player Screen UI

**File:** `packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart`

**Change `_PlayerProgressBar`** from `StatelessWidget` to `ConsumerWidget`:

```dart
class _PlayerProgressBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Slider(
      value: progress?.progress ?? 0.0,
      onChanged: (value) {
        final duration = progress?.duration ?? Duration.zero;
        final seekPosition = Duration(
          milliseconds: (duration.inMilliseconds * value).round(),
        );
        ref.read(audioPlayerControllerProvider.notifier).seek(seekPosition);
      },
    ),
  }
}
```

**Update `_PlayerControls`** button callbacks:

```dart
// Rewind button
onPressed: () {
  ref.read(audioPlayerControllerProvider.notifier).skipBackward();
},

// Forward button
onPressed: () {
  ref.read(audioPlayerControllerProvider.notifier).skipForward();
},
```

## Edge Case Handling

| Case | Behavior |
|------|----------|
| No audio loaded | Early return, no-op |
| Duration unknown | Early return, no-op |
| Seek past end | Clamp to duration |
| Seek before start | Clamp to zero |
| Skip forward at end | Stay at end |
| Skip backward at start | Stay at start |

## Verification

1. **Manual testing:**
   - Launch app and play an episode
   - Drag seekbar slider - position should update
   - Tap rewind button - should jump back 30s
   - Tap forward button - should jump forward 30s
   - Test edge cases: skip at start/end of episode

2. **Automated verification:**
   - Run `melos run analyze` - must pass with no errors
   - Run tests in player package (if existing)
