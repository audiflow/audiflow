# [COMPLETED] Mini Player Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement a persistent mini player (like Apple Podcasts) that appears at the bottom of the screen above the NavigationBar when audio is playing/paused.

**Architecture:** NowPlayingController manages current episode metadata. PlaybackProgress model tracks position/duration. AnimatedMiniPlayer slides in/out based on playback state. Integration via ScaffoldWithNavBar.

**Tech Stack:** Flutter, Riverpod, Freezed, just_audio, AnimationController

**Status:** COMPLETED

---

## Features

- Displays: episode artwork, title, podcast name, play/pause button, progress bar
- Slides in/out with animation based on playback state
- Taps to expand to full player screen (placeholder for now)
- Shows real-time playback progress

## Tasks

### Task 1: State Management (audiflow_domain)

**New Files:**

1. `packages/audiflow_domain/lib/src/features/player/models/now_playing_info.dart`
   - Freezed model with: episodeUrl, episodeTitle, podcastTitle, artworkUrl, totalDuration

2. `packages/audiflow_domain/lib/src/features/player/models/playback_progress.dart`
   - Freezed model with: position, duration, bufferedPosition
   - Computed `progress` getter (0.0 to 1.0)

3. `packages/audiflow_domain/lib/src/features/player/services/now_playing_controller.dart`
   - `@Riverpod(keepAlive: true)` controller managing `NowPlayingInfo?`
   - Methods: `setNowPlaying()`, `clear()`

**Modify Files:**

1. `packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart`
   - Add position/duration/buffered stream providers from AudioPlayer
   - Add combined `playbackProgressStreamProvider`
   - Update `play()` to accept optional metadata and update NowPlayingController

### Task 2: Reusable UI Widgets (audiflow_ui)

**New Files:**

1. `packages/audiflow_ui/lib/src/widgets/player/mini_player_progress_bar.dart`
   - Thin LinearProgressIndicator showing playback position

2. `packages/audiflow_ui/lib/src/widgets/player/mini_player_artwork.dart`
   - ClipRRect artwork with placeholder fallback

### Task 3: Mini Player Widget (audiflow_app)

**New Files:**

1. `packages/audiflow_app/lib/features/player/presentation/widgets/mini_player.dart`
   - Main widget: Row with artwork, title/subtitle column, play/pause button
   - Progress bar at top (2px height)
   - Height: 64px, Material elevation: 8

2. `packages/audiflow_app/lib/features/player/presentation/widgets/animated_mini_player.dart`
   - SlideTransition wrapper with AnimationController
   - Slides up/down based on playback state
   - Duration: 300ms, Curve: easeOutCubic

3. `packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart`
   - Placeholder full player screen for navigation target

### Task 4: Integration

**Modify Files:**

1. `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart`
   - Wrap NavigationBar in Column with AnimatedMiniPlayer above it
   - Add `_onMiniPlayerTap()` handler for navigation

2. `packages/audiflow_app/lib/routing/app_router.dart`
   - Add `/player` route for full player screen

3. `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart`
   - Update `_onPlayPausePressed()` to pass episode metadata (title, podcast name, artwork)

## Widget Hierarchy

```
ScaffoldWithNavBar
  Stack
    Scaffold
      body: navigationShell
      bottomNavigationBar: Column
        AnimatedMiniPlayer
          MiniPlayer
            Column
              MiniPlayerProgressBar
              Row
                MiniPlayerArtwork
                Column (title, podcast)
                IconButton (play/pause)
        NavigationBar
    VoiceListeningOverlay (conditional)
```

## Verification

1. Play an episode from podcast detail screen
2. Verify mini player slides up with correct metadata
3. Verify progress bar updates in real-time
4. Verify play/pause button works
5. Pause episode, verify mini player remains visible
6. Stop playback, verify mini player slides down
7. Tap mini player, verify navigation to player screen
8. Run tests: `melos run test`
9. Run analyzer: `melos run analyze`
