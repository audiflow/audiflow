import 'dart:async';

import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake [EpisodeRepository] that returns canned episodes via streams.
class _FakeEpisodeRepository implements EpisodeRepository {
  _FakeEpisodeRepository({
    this.newestEpisodes = const {},
    this.episodeLists = const {},
  });

  /// Map of podcastId -> newest Episode (single-episode shorthand).
  final Map<int, Episode> newestEpisodes;

  /// Map of podcastId -> full episode list (takes precedence over
  /// [newestEpisodes] when present).
  final Map<int, List<Episode>> episodeLists;

  /// Per-podcast episode stream controllers, created on demand.
  ///
  /// Non-broadcast so the initial value is buffered until listened to.
  final Map<int, StreamController<List<Episode>>> _controllers = {};

  @override
  Stream<List<Episode>> watchByPodcastId(int podcastId) {
    final controller = _controllers.putIfAbsent(podcastId, () {
      final sc = StreamController<List<Episode>>();
      final list = episodeLists[podcastId];
      if (list != null) {
        sc.add(list);
      } else {
        final episode = newestEpisodes[podcastId];
        sc.add(episode != null ? [episode] : []);
      }
      return sc;
    });
    return controller.stream;
  }

  /// Pushes updated episodes to the stream for [podcastId].
  void emitEpisodes(int podcastId, List<Episode> episodes) {
    _controllers[podcastId]?.add(episodes);
  }

  @override
  Future<Episode?> getNewestByPodcastId(int podcastId) async {
    return newestEpisodes[podcastId];
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
  }

  // -- Unused methods --

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) =>
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
    NumberingExtractor? extractor,
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
  @override
  Future<int> deleteByPodcastIdAndGuids(
    int podcastId,
    Set<String> guids, {
    Set<String> protectedGuids = const {},
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

Episode _episode(
  int podcastId,
  DateTime? publishedAt, {
  int? id,
  String? guid,
}) {
  return Episode()
    ..id = id ?? podcastId * 100
    ..podcastId = podcastId
    ..guid = guid ?? 'guid_$podcastId'
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
    late _FakeEpisodeRepository fakeEpisodeRepo;

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
      fakeEpisodeRepo = _FakeEpisodeRepository(
        newestEpisodes: {1: episodeA, 2: episodeB, 3: episodeC},
      );

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          librarySubscriptionsProvider.overrideWith(
            (ref) => subsController.stream,
          ),
          episodeRepositoryProvider.overrideWithValue(fakeEpisodeRepo),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await subsController.close();
      fakeEpisodeRepo.dispose();
    });

    test('sorts by latest episode pubDate (default)', () async {
      // Keep a persistent listener so auto-dispose does not tear down
      // the stream provider between reads.
      final sub = container.listen(sortedSubscriptionsProvider, (_, _) {});
      addTearDown(sub.close);

      subsController.add([podcastA, podcastB, podcastC]);

      final result = await container.read(sortedSubscriptionsProvider.future);
      check(result.map((s) => s.id).toList()).deepEquals([2, 3, 1]);
    });

    test('sorts by subscription date', () async {
      final sub = container.listen(sortedSubscriptionsProvider, (_, _) {});
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
      final sub = container.listen(sortedSubscriptionsProvider, (_, _) {});
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
      final sub = container.listen(sortedSubscriptionsProvider, (_, _) {});
      addTearDown(sub.close);

      final podcastD = _sub(4, 'Delta Podcast', now);
      subsController.add([podcastD, podcastB]);

      final result = await container.read(sortedSubscriptionsProvider.future);
      // B has an episode, D does not -> B first, D last
      check(result.map((s) => s.id).toList()).deepEquals([2, 4]);
    });
  });

  group('newestEpisodeDate max computation', () {
    test(
      'picks max publishedAt from multi-episode out-of-order list',
      () async {
        final now = DateTime(2026, 4, 1);

        // Podcast 5 has multiple episodes with out-of-order and null dates.
        // The newest publishedAt is March 25.
        final multiEpisodes = [
          _episode(5, DateTime(2026, 3, 10), id: 501, guid: 'g1'),
          _episode(5, null, id: 502, guid: 'g2'),
          _episode(5, DateTime(2026, 3, 25), id: 503, guid: 'g3'),
          _episode(5, DateTime(2026, 3, 5), id: 504, guid: 'g4'),
        ];

        // Podcast 6 has a single episode on March 20.
        final singleEpisode = [
          _episode(6, DateTime(2026, 3, 20), id: 601, guid: 'g5'),
        ];

        final podcastE = _sub(5, 'Echo Podcast', now);
        final podcastF = _sub(6, 'Foxtrot Podcast', now);

        final subsController = StreamController<List<Subscription>>();
        final multiRepo = _FakeEpisodeRepository(
          episodeLists: {5: multiEpisodes, 6: singleEpisode},
        );

        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            librarySubscriptionsProvider.overrideWith(
              (ref) => subsController.stream,
            ),
            episodeRepositoryProvider.overrideWithValue(multiRepo),
          ],
        );

        final sub = container.listen(sortedSubscriptionsProvider, (_, _) {});
        addTearDown(sub.close);

        subsController.add([podcastF, podcastE]);

        final result = await container.read(sortedSubscriptionsProvider.future);
        // E (max March 25) before F (March 20)
        check(result.map((s) => s.id).toList()).deepEquals([5, 6]);

        container.dispose();
        await subsController.close();
        multiRepo.dispose();
      },
    );
  });
}
