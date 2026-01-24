# Optimize Episode List Rendering

## Problem

Opening a podcast with many episodes (300+) causes UI freeze. The freeze occurs because RSS parsing runs on the main thread, blocking the UI until all episodes are parsed and stored.

## Solution

Combine two optimizations:
1. **Isolate parsing** — Move XML parsing to a separate isolate (zero main thread blocking)
2. **Early stop** — Stop parsing when hitting a known episode GUID (reduce 500 episodes to 5-10 for subscribed podcasts)

## High-Level Flow

```
Open podcast → Check refresh window
  ├─ Within window OR offline → Query Drift → Display (instant)
  └─ Needs refresh → Query Drift → Display cached → Parse in isolate → Early stop at known GUID → Merge & update UI
```

**Refresh window rules:**
- Offline → no fetch, show cached
- Within 10 minutes of last fetch → no fetch, show cached
- Otherwise → show cached, refresh in background

## Architecture

### Isolate Parser (`audiflow_podcast`)

New `IsolateRssParser` runs XML parsing in a separate isolate:

```dart
class IsolateRssParser {
  static Stream<ParseProgress> parse({
    required String feedXml,
    required Set<String> knownGuids,
    int maxNewEpisodes = 100,
  });
}

sealed class ParseProgress {
  const ParseProgress();
}

class ParsedPodcastMeta extends ParseProgress {
  final PodcastFeed metadata;
}

class ParsedEpisode extends ParseProgress {
  final PodcastItem episode;
}

class ParseComplete extends ParseProgress {
  final int totalParsed;
  final bool stoppedEarly;
}
```

**Early stop logic:**
```dart
for await (final item in streamingParser.parseItems(xml)) {
  if (knownGuids.contains(item.guid)) {
    yield ParseComplete(totalParsed: count, stoppedEarly: true);
    return;
  }
  yield ParsedEpisode(item);
  count++;
  if (maxNewEpisodes <= count) break;
}
```

### Service Layer (`audiflow_domain`)

`FeedParserService` orchestrates parsing with batched upserts:

```dart
class FeedParserService {
  static const _upsertBatchSize = 20;

  Stream<FeedParseProgress> fetchAndParse({
    required String feedUrl,
    required int podcastId,
  }) async* {
    final knownGuids = await _episodeDatasource.getGuidsByPodcastId(podcastId);

    final response = await _httpClient.get(feedUrl);
    final xml = response.data as String;

    final buffer = <PodcastItem>[];
    var totalParsed = 0;

    await for (final progress in IsolateRssParser.parse(
      feedXml: xml,
      knownGuids: knownGuids,
    )) {
      switch (progress) {
        case ParsedPodcastMeta(:final metadata):
          yield FeedMetaReady(metadata);

        case ParsedEpisode(:final episode):
          buffer.add(episode);
          totalParsed++;

          if (_upsertBatchSize <= buffer.length) {
            await _episodeDatasource.upsertBatch(podcastId, buffer);
            yield EpisodesBatchStored(totalParsed);
            buffer.clear();
          }

        case ParseComplete(:final stoppedEarly):
          if (buffer.isNotEmpty) {
            await _episodeDatasource.upsertBatch(podcastId, buffer);
          }
          yield FeedParseComplete(totalParsed, stoppedEarly);
      }
    }
  }
}
```

**Progress events:**
```dart
sealed class FeedParseProgress {}
class FeedMetaReady extends FeedParseProgress { ... }
class EpisodesBatchStored extends FeedParseProgress {
  final int totalSoFar;
}
class FeedParseComplete extends FeedParseProgress {
  final int total;
  final bool stoppedEarly;
}
```

**New datasource methods:**
```dart
// EpisodeLocalDatasource
Future<Set<String>> getGuidsByPodcastId(int podcastId);
Future<void> upsertBatch(int podcastId, List<PodcastItem> items);
```

### Controller Layer (`audiflow_app`)

`PodcastDetailController` manages cached-first display with background refresh:

```dart
@riverpod
class PodcastDetailController extends _$PodcastDetailController {
  @override
  Future<PodcastDetailState> build(String feedUrl) async {
    final podcast = await ref.read(podcastRepositoryProvider).getByFeedUrl(feedUrl);
    final cachedEpisodes = await ref.read(episodeRepositoryProvider)
        .getByPodcastId(podcast.id);

    final isOnline = await ref.read(connectivityProvider).isConnected;
    final shouldRefresh = _shouldFetchRemote(podcast, isOnline);

    if (!shouldRefresh) {
      return PodcastDetailState.loaded(podcast, cachedEpisodes);
    }

    _refreshInBackground(podcast);
    return PodcastDetailState.loaded(
      podcast,
      cachedEpisodes,
      isRefreshing: true,
    );
  }
}
```

**Refresh window check:**
```dart
bool _shouldFetchRemote(Podcast podcast, bool isOnline) {
  if (!isOnline) return false;

  final lastFetched = podcast.lastFetchedAt;
  if (lastFetched == null) return true;

  const refreshWindow = Duration(minutes: 10);
  final elapsed = DateTime.now().difference(lastFetched);
  return refreshWindow <= elapsed;
}
```

**State model:**
```dart
@freezed
class PodcastDetailState with _$PodcastDetailState {
  const factory PodcastDetailState.loaded(
    Podcast podcast,
    List<Episode> episodes, {
    @Default(false) bool isRefreshing,
    int? refreshProgress,
    String? refreshError,
  }) = _Loaded;
}
```

### Error Handling

```dart
Future<void> _refreshInBackground(Podcast podcast) async {
  try {
    await for (final progress in service.fetchAndParse(...)) {
      // handle progress
    }
  } on NetworkException catch (e) {
    state = AsyncData(state.value!.copyWith(
      isRefreshing: false,
      refreshError: 'Could not refresh: ${e.message}',
    ));
  } on ParserException catch (e) {
    _logger.warning('Parse failed for ${podcast.feedUrl}: $e');
    state = AsyncData(state.value!.copyWith(isRefreshing: false));
  }
}
```

Cached episodes remain visible in all error cases.

## Files to Modify

| Package | File | Change |
|---------|------|--------|
| `audiflow_podcast` | `lib/src/parser/isolate_rss_parser.dart` | **New** — Isolate wrapper |
| `audiflow_podcast` | `lib/src/parser/streaming_xml_parser.dart` | Add early-stop support |
| `audiflow_domain` | `lib/src/features/feed/services/feed_parser_service.dart` | Add batched parse stream |
| `audiflow_domain` | `lib/src/features/feed/datasources/local/episode_local_datasource.dart` | Add `getGuidsByPodcastId`, `upsertBatch` |
| `audiflow_app` | `lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart` | Refresh window + background parse |
| `audiflow_app` | `lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart` | Progress indicator |

## Testing Strategy

- Unit test `IsolateRssParser` with mock XML (early-stop behavior)
- Unit test `FeedParserService` with mock datasource (batching)
- Widget test controller state transitions
- Integration test: subscribe → close → reopen (verify window logic)

## Performance Expectations

| Scenario | Before | After |
|----------|--------|-------|
| Fresh podcast (500 eps) | 3s freeze | No freeze, ~3s background |
| Subscribed (5 new eps) | 3s freeze | No freeze, ~200ms |
| Within refresh window | 3s freeze | Instant (~100ms) |
| Offline | 3s freeze | Instant (~100ms) |
