# [COMPLETED] Audio Playback Feature Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a play/pause button to the podcast channel details page that plays episodes when tapped.

**Architecture:** AudioPlayerService wraps just_audio with Riverpod state management. PlaybackState sealed class represents idle/loading/playing/paused/error states. PodcastDetailScreen fetches episodes via FeedParserService.

**Tech Stack:** Flutter, just_audio, audio_service, Riverpod, Freezed

**Status:** COMPLETED

---

## Current State
- **Podcast detail page**: Placeholder at `app_router.dart:92-118`
- **Audio dependencies**: `just_audio`, `audio_service`, `audio_session` (declared but unused)
- **RSS parsing**: `FeedParserService` exists and works
- **Search model**: `Podcast` has `feedUrl` for fetching episodes

## Tasks

### Task 1: Audio Player Service (audiflow_domain)

**Create directory structure:**
```
packages/audiflow_domain/lib/src/features/player/
  models/
    playback_state.dart
  services/
    audio_player_service.dart
```

**playback_state.dart** - Minimal state for prototype:
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

**audio_player_service.dart** - Wraps `just_audio`:
- `audioPlayerProvider` - keepAlive, provides `AudioPlayer` instance
- `AudioPlayerController` - exposes `play(url)`, `pause()`, `resume()`, `togglePlayPause()`
- Streams player state changes to update `PlaybackState`

### Task 2: Podcast Detail Screen (audiflow_app)

**Create directory structure:**
```
packages/audiflow_app/lib/features/podcast_detail/
  presentation/
    controllers/
      podcast_detail_controller.dart
    screens/
      podcast_detail_screen.dart
    widgets/
      episode_list_tile.dart
```

**podcast_detail_controller.dart**:
- Fetches RSS feed using `FeedParserService`
- Returns `ParsedFeed` with episodes

**podcast_detail_screen.dart**:
- Receives `Podcast` via route extra
- Shows podcast info (artwork, name, artist)
- Fetches episodes from feedUrl
- Displays scrollable episode list

**episode_list_tile.dart**:
- Shows episode title, duration, publish date
- Play/pause button per episode
- Highlights currently playing episode
- Watches `audioPlayerControllerProvider` for state

### Task 3: Integration
- Update app_router.dart: Pass `Podcast` object via route extra
- Update search_screen.dart navigation: `context.push('${AppRoutes.podcastDetail}/${podcast.id}', extra: podcast)`

## Data Flow
```
Search → tap podcast → navigate with Podcast extra
                              ↓
PodcastDetailScreen receives Podcast
                              ↓
ref.watch(podcastDetailProvider(feedUrl)) → ParsedFeed
                              ↓
Display episode list with EpisodeListTile per episode
                              ↓
tap play on episode → audioPlayerController.play(enclosureUrl)
                              ↓
AudioPlayer plays → PlaybackState.playing(episodeUrl)
                              ↓
EpisodeListTile shows pause icon for playing episode
                              ↓
tap pause → audioPlayerController.pause()
```

## Verification
1. Search for a podcast (e.g., "lex fridman")
2. Tap on a search result
3. See podcast detail page with podcast info and a play button
4. Tap play → audio starts
5. Tap again → audio pauses
6. Tap again → audio resumes
