import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/isar_test_helper.dart';

// -- Fakes --------------------------------------------------------

class _FakeSubscriptionRepository implements SubscriptionRepository {
  _FakeSubscriptionRepository(this._subscription);

  final Subscription _subscription;

  @override
  Future<Subscription?> getById(int id) async => _subscription;

  @override
  Future<Subscription?> getByFeedUrl(String feedUrl) async => _subscription;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeEpisodeRepository implements EpisodeRepository {
  _FakeEpisodeRepository(this._episodes);

  final List<Episode> _episodes;

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) async => _episodes;

  @override
  Future<List<Episode>> getByIds(List<int> ids) async =>
      _episodes.where((e) => ids.contains(e.id)).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConfigRepository implements SmartPlaylistConfigRepository {
  _FakeConfigRepository({this.summary, this.config});

  final PatternSummary? summary;
  final SmartPlaylistPatternConfig? config;

  @override
  PatternSummary? findMatchingPattern(String? podcastGuid, String feedUrl) =>
      summary;

  @override
  Future<SmartPlaylistPatternConfig> getConfig(PatternSummary summary) async =>
      config!;

  @override
  void setPatternSummaries(List<PatternSummary> summaries) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// -- Helpers -------------------------------------------------------

Episode _episode({
  required int id,
  int podcastId = 1,
  required String guid,
  required String title,
  int? seasonNumber,
  int? episodeNumber,
  DateTime? publishedAt,
  String? imageUrl,
}) => Episode()
  ..id = id
  ..podcastId = podcastId
  ..guid = guid
  ..title = title
  ..audioUrl = 'https://example.com/$guid.mp3'
  ..seasonNumber = seasonNumber
  ..episodeNumber = episodeNumber
  ..publishedAt = publishedAt
  ..imageUrl = imageUrl;

/// Reads [podcastSmartPlaylistsProvider] while keeping it alive
/// via [listen] so the Ref survives async gaps.
Future<SmartPlaylistGrouping?> readSmartPlaylists(
  ProviderContainer container,
  int podcastId,
) {
  final completer = Completer<SmartPlaylistGrouping?>();
  final sub = container.listen(podcastSmartPlaylistsProvider(podcastId), (
    _,
    next,
  ) {
    if (completer.isCompleted) return;
    next.when(
      data: completer.complete,
      error: completer.completeError,
      loading: () {},
    );
  }, fireImmediately: true);
  return completer.future.whenComplete(sub.close);
}

// -- Tests ---------------------------------------------------------

void main() {
  late Isar isar;
  late SmartPlaylistLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([
      SmartPlaylistEntitySchema,
      SmartPlaylistGroupEntitySchema,
    ]);
    datasource = SmartPlaylistLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Subscription makeSubscription() => Subscription()
    ..id = 1
    ..itunesId = 'itunes-1'
    ..feedUrl = 'https://example.com/feed.xml'
    ..title = 'Test Podcast'
    ..artistName = 'Test Artist'
    ..subscribedAt = DateTime(2025);

  List<Episode> makeSeasonedEpisodes() => [
    _episode(
      id: 1,
      guid: 'ep-1',
      title: 'S1E1',
      seasonNumber: 1,
      episodeNumber: 1,
      publishedAt: DateTime(2025),
    ),
    _episode(
      id: 2,
      guid: 'ep-2',
      title: 'S1E2',
      seasonNumber: 1,
      episodeNumber: 2,
      publishedAt: DateTime(2025, 2),
    ),
    _episode(
      id: 3,
      guid: 'ep-3',
      title: 'S2E1',
      seasonNumber: 2,
      episodeNumber: 1,
      publishedAt: DateTime(2025, 3),
    ),
  ];

  ProviderContainer makeContainer({
    required Subscription subscription,
    required List<Episode> episodes,
    _FakeConfigRepository? configRepo,
  }) {
    final container = ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(
          _FakeSubscriptionRepository(subscription),
        ),
        episodeRepositoryProvider.overrideWithValue(
          _FakeEpisodeRepository(episodes),
        ),
        smartPlaylistLocalDatasourceProvider.overrideWithValue(datasource),
        smartPlaylistConfigRepositoryProvider.overrideWithValue(
          configRepo ?? _FakeConfigRepository(),
        ),
      ],
    );
    return container;
  }

  group('playlistStructure persistence', () {
    test(
      'persists split structure for auto-detected season playlists',
      () async {
        final container = makeContainer(
          subscription: makeSubscription(),
          episodes: makeSeasonedEpisodes(),
        );
        addTearDown(container.dispose);

        final grouping = await readSmartPlaylists(container, 1);

        expect(grouping, isNotNull);
        expect(grouping!.playlists, isNotEmpty);

        // Verify persisted entities have correct playlistStructure
        final entities = await datasource.getByPodcastId(1);
        expect(entities, isNotEmpty);
        for (final entity in entities) {
          expect(entity.playlistStructure, 'split');
        }
      },
    );

    test('persists grouped structure when config specifies grouped', () async {
      final summary = PatternSummary(
        id: 'test-pattern',
        dataVersion: 1,
        displayName: 'Test Pattern',
        feedUrlHint: 'example.com',
        playlistCount: 1,
      );

      final config = SmartPlaylistPatternConfig(
        id: 'test-pattern',
        feedUrls: ['https://example.com/feed.xml'],
        playlists: [
          SmartPlaylistDefinition(
            id: 'regular',
            displayName: 'Regular Series',
            resolverType: 'rss',
            playlistStructure: 'grouped',
          ),
        ],
      );

      final container = makeContainer(
        subscription: makeSubscription(),
        episodes: makeSeasonedEpisodes(),
        configRepo: _FakeConfigRepository(summary: summary, config: config),
      );
      addTearDown(container.dispose);

      final grouping = await readSmartPlaylists(container, 1);

      expect(grouping, isNotNull);
      expect(grouping!.playlists, hasLength(1));

      final playlist = grouping.playlists.first;
      expect(playlist.playlistStructure, PlaylistStructure.grouped);
      expect(playlist.groups, isNotNull);
      expect(playlist.groups, isNotEmpty);

      // Verify persisted entity has 'grouped' playlistStructure
      final entities = await datasource.getByPodcastId(1);
      expect(entities, hasLength(1));
      expect(entities.first.playlistStructure, 'grouped');
    });

    test('cache round-trip preserves grouped playlistStructure', () async {
      final summary = PatternSummary(
        id: 'test-pattern',
        dataVersion: 1,
        displayName: 'Test Pattern',
        feedUrlHint: 'example.com',
        playlistCount: 1,
      );

      final config = SmartPlaylistPatternConfig(
        id: 'test-pattern',
        feedUrls: ['https://example.com/feed.xml'],
        playlists: [
          SmartPlaylistDefinition(
            id: 'regular',
            displayName: 'Regular Series',
            resolverType: 'rss',
            playlistStructure: 'grouped',
          ),
        ],
      );

      final configRepo = _FakeConfigRepository(
        summary: summary,
        config: config,
      );

      final container = makeContainer(
        subscription: makeSubscription(),
        episodes: makeSeasonedEpisodes(),
        configRepo: configRepo,
      );
      addTearDown(container.dispose);

      // First call: resolves and persists
      await readSmartPlaylists(container, 1);

      // Second call: reads from cache
      container.invalidate(podcastSmartPlaylistsProvider(1));
      final cached = await readSmartPlaylists(container, 1);

      expect(cached, isNotNull);
      expect(cached!.playlists, hasLength(1));
      expect(
        cached.playlists.first.playlistStructure,
        PlaylistStructure.grouped,
      );
    });
  });
}
