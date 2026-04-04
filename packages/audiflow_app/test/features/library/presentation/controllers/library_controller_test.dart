import 'dart:async';

import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

/// Fake [EpisodeRepository] that returns canned newest episodes.
class _FakeEpisodeRepository implements EpisodeRepository {
  _FakeEpisodeRepository({this.newestEpisodes = const {}});

  /// Map of podcastId -> newest Episode.
  final Map<int, Episode> newestEpisodes;

  @override
  Future<Episode?> getNewestByPodcastId(int podcastId) async {
    return newestEpisodes[podcastId];
  }

  // -- Unused methods --

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) =>
      throw UnimplementedError();
  @override
  Stream<List<Episode>> watchByPodcastId(int podcastId) =>
      throw UnimplementedError();
  @override
  Future<Episode?> getById(int id) => throw UnimplementedError();
  @override
  Future<Episode?> getByAudioUrl(String audioUrl) => throw UnimplementedError();
  @override
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) =>
      throw UnimplementedError();
  @override
  Future<void> upsertEpisodes(List<Episode> episodes) =>
      throw UnimplementedError();
  @override
  Future<void> upsertFromFeedItems(
    int podcastId,
    List items, {
    SmartPlaylistEpisodeExtractor? extractor,
  }) => throw UnimplementedError();
  @override
  Future<void> upsertFromFeedItemsWithConfig(
    int podcastId,
    List items, {
    required SmartPlaylistPatternConfig config,
  }) => throw UnimplementedError();
  @override
  Future<List<Episode>> getByIds(List<int> ids) => throw UnimplementedError();
  @override
  Future<Set<String>> getGuidsByPodcastId(int podcastId) =>
      throw UnimplementedError();
  @override
  Future<void> storeTranscriptAndChapterDataFromParsed(
    int podcastId,
    List mediaMetas,
  ) => throw UnimplementedError();
  @override
  Future<List<Episode>> getSubsequentEpisodes({
    required int podcastId,
    required int? afterEpisodeNumber,
    required int limit,
  }) => throw UnimplementedError();
}

Subscription _sub(int id, String title, DateTime subscribedAt) {
  return Subscription()
    ..id = id
    ..itunesId = 'itunes_$id'
    ..feedUrl = 'https://example.com/$id'
    ..title = title
    ..artistName = 'Artist $id'
    ..subscribedAt = subscribedAt;
}

Episode _episode(int podcastId, DateTime publishedAt) {
  return Episode()
    ..id = podcastId * 100
    ..podcastId = podcastId
    ..guid = 'guid_$podcastId'
    ..title = 'Episode'
    ..audioUrl = 'https://example.com/$podcastId.mp3'
    ..publishedAt = publishedAt;
}

void main() {
  group('PodcastSortOrderController', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() => container.dispose());

    test('defaults to latestEpisode', () async {
      final order = await container.read(
        podcastSortOrderControllerProvider.future,
      );
      check(order).equals(PodcastSortOrder.latestEpisode);
    });

    test('persists and reads back sort order', () async {
      final notifier = container.read(
        podcastSortOrderControllerProvider.notifier,
      );
      await notifier.setSortOrder(PodcastSortOrder.alphabetical);

      final order = await container.read(
        podcastSortOrderControllerProvider.future,
      );
      check(order).equals(PodcastSortOrder.alphabetical);
    });
  });

  group('sortedSubscriptionsProvider', () {
    late ProviderContainer container;
    late StreamController<List<Subscription>> subsController;

    final now = DateTime(2026, 4, 1);
    final podcastA = _sub(1, 'Alpha Podcast', now);
    final podcastB = _sub(
      2,
      'Beta Podcast',
      now.subtract(const Duration(days: 1)),
    );
    final podcastC = _sub(
      3,
      'Charlie Podcast',
      now.subtract(const Duration(days: 2)),
    );

    // Episode dates: B has newest episode, then C, then A.
    final episodeA = _episode(1, DateTime(2026, 3, 1));
    final episodeB = _episode(2, DateTime(2026, 3, 30));
    final episodeC = _episode(3, DateTime(2026, 3, 15));

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      subsController = StreamController<List<Subscription>>();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          librarySubscriptionsProvider.overrideWith(
            (ref) => subsController.stream,
          ),
          episodeRepositoryProvider.overrideWithValue(
            _FakeEpisodeRepository(
              newestEpisodes: {1: episodeA, 2: episodeB, 3: episodeC},
            ),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      subsController.close();
    });

    test('sorts by latest episode pubDate (default)', () async {
      // Keep a persistent listener so auto-dispose does not tear down
      // the stream provider between reads.
      final sub = container.listen(sortedSubscriptionsProvider, (_, __) {});
      addTearDown(sub.close);

      subsController.add([podcastA, podcastB, podcastC]);

      final result = await container.read(sortedSubscriptionsProvider.future);
      check(result.map((s) => s.id).toList()).deepEquals([2, 3, 1]);
    });

    test('sorts by subscription date', () async {
      final sub = container.listen(sortedSubscriptionsProvider, (_, __) {});
      addTearDown(sub.close);

      final notifier = container.read(
        podcastSortOrderControllerProvider.notifier,
      );
      await notifier.setSortOrder(PodcastSortOrder.subscribedAt);

      subsController.add([podcastA, podcastB, podcastC]);

      final result = await container.read(sortedSubscriptionsProvider.future);
      // newest subscribedAt first: A (Apr 1), B (Mar 31), C (Mar 30)
      check(result.map((s) => s.id).toList()).deepEquals([1, 2, 3]);
    });

    test('sorts alphabetically', () async {
      final sub = container.listen(sortedSubscriptionsProvider, (_, __) {});
      addTearDown(sub.close);

      final notifier = container.read(
        podcastSortOrderControllerProvider.notifier,
      );
      await notifier.setSortOrder(PodcastSortOrder.alphabetical);

      subsController.add([podcastC, podcastA, podcastB]);

      final result = await container.read(sortedSubscriptionsProvider.future);
      check(result.map((s) => s.id).toList()).deepEquals([1, 2, 3]);
    });

    test('podcasts with no episodes sort last for latestEpisode', () async {
      final sub = container.listen(sortedSubscriptionsProvider, (_, __) {});
      addTearDown(sub.close);

      final podcastD = _sub(4, 'Delta Podcast', now);
      subsController.add([podcastD, podcastB]);

      final result = await container.read(sortedSubscriptionsProvider.future);
      // B has an episode, D does not -> B first, D last
      check(result.map((s) => s.id).toList()).deepEquals([2, 4]);
    });
  });
}
