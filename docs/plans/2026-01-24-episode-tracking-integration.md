# Episode Tracking Integration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete the episode tracking feature by integrating the data layer with the UI and audio player.

**Context:** Tasks 1-15 from the original episode tracking plan are complete. This plan covers the 5 follow-up items needed to make the feature functional end-to-end.

---

## Task 1: Persist Episodes on Feed Fetch

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository_impl.dart`

**Step 1: Add method to convert PodcastItem to EpisodesCompanion**

Add to `episode_repository.dart` interface:
```dart
/// Upserts episodes from parsed RSS feed items.
Future<void> upsertFromFeedItems(int podcastId, List<PodcastItem> items);
```

**Step 2: Implement in EpisodeRepositoryImpl**

```dart
@override
Future<void> upsertFromFeedItems(int podcastId, List<PodcastItem> items) async {
  final companions = items
      .where((item) => item.guid != null && item.enclosureUrl != null)
      .map((item) => EpisodesCompanion.insert(
            podcastId: podcastId,
            guid: item.guid!,
            title: item.title,
            description: Value(item.description),
            audioUrl: item.enclosureUrl!,
            durationMs: Value(item.duration?.inMilliseconds),
            publishedAt: Value(item.publishDate),
            imageUrl: Value(item.primaryImage?.url),
            episodeNumber: Value(item.episodeNumber),
            seasonNumber: Value(item.seasonNumber),
          ))
      .toList();

  await _datasource.upsertAll(companions);
}
```

**Step 3: Add import to episode_repository_impl.dart**

```dart
import 'package:audiflow_podcast/audiflow_podcast.dart';
```

**Step 4: Add SubscriptionRepository method to get subscription by feedUrl**

Check if method exists in subscription repository. If not, add:
```dart
Future<Subscription?> getByFeedUrl(String feedUrl);
```

**Step 5: Update podcastDetailProvider to persist episodes**

```dart
@riverpod
Future<ParsedFeed> podcastDetail(Ref ref, String feedUrl) async {
  // ... existing fetch logic ...

  // After successful parse, persist episodes if subscribed
  final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
  final subscription = await subscriptionRepo.getByFeedUrl(feedUrl);

  if (subscription != null) {
    final episodeRepo = ref.read(episodeRepositoryProvider);
    await episodeRepo.upsertFromFeedItems(subscription.id, result.episodes);
  }

  return result;
}
```

**Step 6: Run code generation**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 7: Verify compilation**

```bash
melos run analyze
```

**Step 8: Commit**

```bash
git add -A && git commit -m "feat(domain): persist episodes on feed fetch"
```

---

## Task 2: Integrate AudioPlayerController with PlaybackHistoryService

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart`

**Step 1: Add episode tracking to AudioPlayerController**

Update the controller to track the current episode ID and integrate with PlaybackHistoryService:

```dart
@Riverpod(keepAlive: true)
class AudioPlayerController extends _$AudioPlayerController {
  late final AudioPlayer _player;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<PlaybackProgress>? _progressSubscription;
  String? _currentUrl;
  int? _currentEpisodeId;

  @override
  PlaybackState build() {
    _player = ref.watch(audioPlayerProvider);
    _listenToPlayerState();
    _listenToProgress();
    ref.onDispose(_cleanup);
    return const PlaybackState.idle();
  }

  void _listenToProgress() {
    final progressStream = ref.read(playbackProgressStreamProvider.stream);
    _progressSubscription = progressStream.listen((progress) async {
      if (_currentEpisodeId == null) return;

      final historyService = ref.read(playbackHistoryServiceProvider);
      await historyService.onProgressUpdate(_currentEpisodeId!, progress);
    });
  }

  // ... existing _listenToPlayerState with modifications ...

  void _listenToPlayerState() {
    _stateSubscription = _player.playerStateStream.listen(
      (playerState) async {
        final processingState = playerState.processingState;
        final playing = playerState.playing;

        if (_currentUrl == null) {
          state = const PlaybackState.idle();
          return;
        }

        final url = _currentUrl!;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          state = PlaybackState.loading(episodeUrl: url);
        } else if (playing) {
          state = PlaybackState.playing(episodeUrl: url);
        } else if (processingState == ProcessingState.completed) {
          // Save final progress before clearing
          if (_currentEpisodeId != null) {
            final progress = ref.read(playbackProgressProvider);
            if (progress != null) {
              final historyService = ref.read(playbackHistoryServiceProvider);
              await historyService.onPlaybackStopped(_currentEpisodeId!, progress);
            }
          }
          state = const PlaybackState.idle();
          _currentUrl = null;
          _currentEpisodeId = null;
        } else {
          state = PlaybackState.paused(episodeUrl: url);
        }
      },
      onError: (error) {
        state = PlaybackState.error(message: error.toString());
      },
    );
  }

  void _cleanup() {
    _stateSubscription?.cancel();
    _progressSubscription?.cancel();
  }

  Future<void> play(String url, {NowPlayingInfo? metadata}) async {
    try {
      // Look up episode ID from URL
      final episodeRepo = ref.read(episodeRepositoryProvider);
      final episode = await episodeRepo.getByAudioUrl(url);

      _currentUrl = url;
      _currentEpisodeId = episode?.id;
      state = PlaybackState.loading(episodeUrl: url);

      if (metadata != null) {
        ref.read(nowPlayingControllerProvider.notifier).setNowPlaying(metadata);
      }

      await _player.setUrl(url);

      // Notify history service of playback start
      if (_currentEpisodeId != null) {
        final historyService = ref.read(playbackHistoryServiceProvider);
        await historyService.onPlaybackStarted(
          _currentEpisodeId!,
          _player.position.inMilliseconds,
        );
      }

      await _player.play();
    } catch (e) {
      state = PlaybackState.error(message: 'Failed to play audio: $e');
    }
  }

  Future<void> pause() async {
    // Save progress on pause
    if (_currentEpisodeId != null) {
      final progress = ref.read(playbackProgressProvider);
      if (progress != null) {
        final historyService = ref.read(playbackHistoryServiceProvider);
        await historyService.onPlaybackPaused(_currentEpisodeId!, progress);
      }
    }
    await _player.pause();
  }

  Future<void> stop() async {
    // Save final progress before stopping
    if (_currentEpisodeId != null) {
      final progress = ref.read(playbackProgressProvider);
      if (progress != null) {
        final historyService = ref.read(playbackHistoryServiceProvider);
        await historyService.onPlaybackStopped(_currentEpisodeId!, progress);
      }
    }
    await _player.stop();
    _currentUrl = null;
    _currentEpisodeId = null;
    state = const PlaybackState.idle();
    ref.read(nowPlayingControllerProvider.notifier).clear();
  }

  // ... rest of existing methods ...
}
```

**Step 2: Add required imports**

```dart
import '../repositories/playback_history_repository_impl.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import 'playback_history_service.dart';
```

**Step 3: Run code generation**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 4: Verify compilation**

```bash
melos run analyze
```

**Step 5: Commit**

```bash
git add -A && git commit -m "feat(player): integrate AudioPlayerController with PlaybackHistoryService"
```

---

## Task 3: Update EpisodeListTile to Show Progress Indicators

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart`

**Step 1: Add provider for episode progress lookup**

Create a provider that watches playback history for an episode by audio URL:

```dart
@riverpod
Future<EpisodeWithProgress?> episodeProgress(Ref ref, String audioUrl) async {
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final historyRepo = ref.watch(playbackHistoryRepositoryProvider);

  final episode = await episodeRepo.getByAudioUrl(audioUrl);
  if (episode == null) return null;

  final history = await historyRepo.getByEpisodeId(episode.id);
  return EpisodeWithProgress(episode: episode, history: history);
}
```

**Step 2: Update EpisodeListTile subtitle to include progress**

```dart
Widget _buildSubtitle(ThemeData theme, EpisodeWithProgress? progress) {
  final parts = <String>[];

  // Show remaining time if in progress
  if (progress != null && progress.isInProgress && progress.remainingTimeFormatted != null) {
    parts.add(progress.remainingTimeFormatted!);
  } else if (episode.formattedDuration != null) {
    parts.add(episode.formattedDuration!);
  }

  if (episode.publishDate != null) {
    parts.add(DateFormat.yMMMd().format(episode.publishDate!));
  }

  // ... rest of existing logic ...

  return Row(
    children: [
      if (progress?.isCompleted == true) ...[
        EpisodeProgressIndicator(
          isCompleted: true,
          isInProgress: false,
        ),
        const SizedBox(width: Spacing.xs),
      ],
      Expanded(
        child: Text(
          parts.join(' - '),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}
```

**Step 3: Update build method to watch progress**

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final enclosureUrl = episode.enclosureUrl;
  final progressAsync = enclosureUrl != null
      ? ref.watch(episodeProgressProvider(enclosureUrl))
      : null;

  // ... rest of build with progress data ...
}
```

**Step 4: Add required imports**

```dart
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
```

**Step 5: Run code generation**

```bash
cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs
```

**Step 6: Verify compilation**

```bash
melos run analyze
```

**Step 7: Commit**

```bash
git add -A && git commit -m "feat(ui): show progress indicators in EpisodeListTile"
```

---

## Task 4: Add Episode Filter to Podcast Detail Screen

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart`

**Step 1: Add filter state provider**

```dart
@riverpod
class EpisodeFilterState extends _$EpisodeFilterState {
  @override
  EpisodeFilter build() => EpisodeFilter.all;

  void setFilter(EpisodeFilter filter) => state = filter;
}
```

**Step 2: Add filtered episodes provider**

```dart
@riverpod
Future<List<PodcastItem>> filteredEpisodes(
  Ref ref,
  String feedUrl,
  EpisodeFilter filter,
) async {
  final feed = await ref.watch(podcastDetailProvider(feedUrl).future);
  final episodes = feed.episodes;

  if (filter == EpisodeFilter.all) return episodes;

  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final historyRepo = ref.watch(playbackHistoryRepositoryProvider);

  final filtered = <PodcastItem>[];
  for (final item in episodes) {
    if (item.enclosureUrl == null) continue;

    final episode = await episodeRepo.getByAudioUrl(item.enclosureUrl!);
    if (episode == null) {
      // Episode not in DB = unplayed
      if (filter == EpisodeFilter.unplayed) filtered.add(item);
      continue;
    }

    final history = await historyRepo.getByEpisodeId(episode.id);
    final isCompleted = history?.completedAt != null;
    final isInProgress = history != null && 0 < history.positionMs && !isCompleted;

    if (filter == EpisodeFilter.unplayed && !isCompleted && !isInProgress) {
      filtered.add(item);
    } else if (filter == EpisodeFilter.inProgress && isInProgress) {
      filtered.add(item);
    }
  }

  return filtered;
}
```

**Step 3: Update PodcastDetailScreen to include filter chips**

```dart
Widget _buildContent(
  BuildContext context,
  WidgetRef ref,
  ThemeData theme,
  dynamic parsedFeed,
) {
  final filter = ref.watch(episodeFilterStateProvider);
  final feedUrl = podcast.feedUrl!;

  return CustomScrollView(
    slivers: [
      SliverToBoxAdapter(child: _buildHeader(context, ref, theme)),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: EpisodeFilterChips(
            selected: filter,
            onSelected: (f) => ref.read(episodeFilterStateProvider.notifier).setFilter(f),
          ),
        ),
      ),
      // Use filtered episodes
      _buildEpisodeList(ref, feedUrl, filter),
    ],
  );
}

Widget _buildEpisodeList(WidgetRef ref, String feedUrl, EpisodeFilter filter) {
  final episodesAsync = ref.watch(filteredEpisodesProvider(feedUrl, filter));

  return episodesAsync.when(
    data: (episodes) {
      if (episodes.isEmpty) {
        return SliverFillRemaining(child: _buildEmptyFilterState());
      }
      return SliverList.builder(
        itemCount: episodes.length,
        itemBuilder: (context, index) => EpisodeListTile(
          key: ValueKey(episodes[index].guid ?? index),
          episode: episodes[index],
          podcastTitle: podcast.name,
          artworkUrl: podcast.artworkUrl,
        ),
      );
    },
    loading: () => const SliverToBoxAdapter(
      child: Center(child: CircularProgressIndicator()),
    ),
    error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
  );
}
```

**Step 4: Add import for EpisodeFilterChips**

```dart
import '../widgets/episode_filter_chips.dart';
```

**Step 5: Run code generation**

```bash
cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs
```

**Step 6: Verify compilation**

```bash
melos run analyze
```

**Step 7: Commit**

```bash
git add -A && git commit -m "feat(ui): add episode filter chips to podcast detail screen"
```

---

## Task 5: Add Manual Mark Played/Unplayed UI

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart`

**Step 1: Wrap ListTile with GestureDetector for long-press**

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // ... existing code ...

  return GestureDetector(
    onLongPress: () => _showContextMenu(context, ref),
    child: ListTile(
      // ... existing ListTile properties ...
    ),
  );
}
```

**Step 2: Add context menu method**

```dart
void _showContextMenu(BuildContext context, WidgetRef ref) {
  final enclosureUrl = episode.enclosureUrl;
  if (enclosureUrl == null) return;

  final progressAsync = ref.read(episodeProgressProvider(enclosureUrl));
  final progress = progressAsync.value;
  final isCompleted = progress?.isCompleted ?? false;

  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(isCompleted ? Icons.replay : Icons.check_circle_outline),
            title: Text(isCompleted ? 'Mark as unplayed' : 'Mark as played'),
            onTap: () async {
              Navigator.pop(context);
              await _togglePlayedStatus(ref, enclosureUrl, isCompleted);
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> _togglePlayedStatus(
  WidgetRef ref,
  String audioUrl,
  bool isCurrentlyCompleted,
) async {
  final episodeRepo = ref.read(episodeRepositoryProvider);
  final episode = await episodeRepo.getByAudioUrl(audioUrl);
  if (episode == null) return;

  final historyService = ref.read(playbackHistoryServiceProvider);
  if (isCurrentlyCompleted) {
    await historyService.markIncomplete(episode.id);
  } else {
    await historyService.markCompleted(episode.id);
  }

  // Invalidate the progress provider to refresh UI
  ref.invalidate(episodeProgressProvider(audioUrl));
}
```

**Step 3: Verify compilation**

```bash
melos run analyze
```

**Step 4: Commit**

```bash
git add -A && git commit -m "feat(ui): add manual mark played/unplayed via long-press menu"
```

---

## Summary

This plan completes the episode tracking feature by:

1. **Task 1**: Persisting episodes to the database when feed is fetched
2. **Task 2**: Connecting AudioPlayerController to PlaybackHistoryService for automatic progress tracking
3. **Task 3**: Showing progress indicators in episode list tiles
4. **Task 4**: Adding filter chips for All/Unplayed/In Progress filtering
5. **Task 5**: Enabling manual mark played/unplayed via long-press menu

After completing all tasks, run full test suite:
```bash
melos run test
```
