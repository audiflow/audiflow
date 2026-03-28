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

    test('infers grouped structure from persisted groups '
        'even when entity field says split', () async {
      // Simulate stale DB entities where playlistStructure was
      // never written (defaults to 'split') but groups were
      // persisted correctly. This is the Drift→Isar migration
      // scenario that caused the grouping regression.
      final subscription = makeSubscription();
      final episodes = makeSeasonedEpisodes();

      final summary = PatternSummary(
        id: 'test-pattern',
        dataVersion: 1,
        displayName: 'Test Pattern',
        feedUrlHint: 'example.com',
        playlistCount: 1,
      );

      // Manually insert entity with wrong playlistStructure
      final entity = SmartPlaylistEntity()
        ..podcastId = 1
        ..playlistNumber = 0
        ..playlistId = 'regular'
        ..displayName = 'Regular'
        ..sortKey = 0
        ..resolverType = 'rss'
        ..playlistStructure =
            'split' // Wrong: should be 'grouped'
        ..yearHeaderMode = 'none'
        ..configVersion = 1;

      await isar.writeTxn(() async {
        await isar.smartPlaylistEntitys.put(entity);
      });

      // Persist groups for the playlist
      final groupEntity = SmartPlaylistGroupEntity()
        ..podcastId = 1
        ..playlistId = 'regular'
        ..groupId = 'season_1'
        ..displayName = 'Season 1'
        ..sortKey = 1
        ..episodeIds = '1,2';

      await datasource.upsertGroupsForPlaylist(1, 'regular', [groupEntity]);

      final container = makeContainer(
        subscription: subscription,
        episodes: episodes,
        configRepo: _FakeConfigRepository(summary: summary),
      );
      addTearDown(container.dispose);

      final grouping = await readSmartPlaylists(container, 1);

      expect(grouping, isNotNull);
      expect(grouping!.playlists, hasLength(1));

      final playlist = grouping.playlists.first;
      expect(
        playlist.playlistStructure,
        PlaylistStructure.grouped,
        reason: 'Should infer grouped from persisted groups',
      );
      expect(playlist.groups, isNotNull);
      expect(playlist.groups, hasLength(1));
      expect(playlist.groups!.first.displayName, 'Season 1');
    });

    test(
      'cache round-trip preserves year-resolved playlist episode IDs',
      () async {
        final episodes = [
          _episode(
            id: 10,
            guid: 'y-ep-1',
            title: 'Episode from 2024',
            publishedAt: DateTime(2024, 3),
          ),
          _episode(
            id: 11,
            guid: 'y-ep-2',
            title: 'Episode from 2024 later',
            publishedAt: DateTime(2024, 9),
          ),
          _episode(
            id: 12,
            guid: 'y-ep-3',
            title: 'Episode from 2025',
            publishedAt: DateTime(2025, 1),
          ),
        ];

        final summary = PatternSummary(
          id: 'year-pattern',
          dataVersion: 1,
          displayName: 'Year Pattern',
          feedUrlHint: 'example.com',
          playlistCount: 1,
        );

        // A single year definition; the resolver creates one playlist
        // per unique publication year found in episodes.
        final config = SmartPlaylistPatternConfig(
          id: 'year-pattern',
          feedUrls: ['https://example.com/feed.xml'],
          playlists: [
            SmartPlaylistDefinition(
              id: 'yearly',
              displayName: 'By Year',
              resolverType: 'year',
              playlistStructure: 'split',
            ),
          ],
        );

        final configRepo = _FakeConfigRepository(
          summary: summary,
          config: config,
        );

        final container = makeContainer(
          subscription: makeSubscription(),
          episodes: episodes,
          configRepo: configRepo,
        );
        addTearDown(container.dispose);

        // First call: resolves and persists
        final initial = await readSmartPlaylists(container, 1);
        expect(initial, isNotNull);
        expect(initial!.playlists, hasLength(2));

        final initial2024 = initial.playlists
            .where((p) => p.id == 'year_2024')
            .first;
        final initial2025 = initial.playlists
            .where((p) => p.id == 'year_2025')
            .first;
        expect(initial2024.episodeIds, containsAll([10, 11]));
        expect(initial2025.episodeIds, [12]);

        // Second call: reads from cache (no config fetch)
        container.invalidate(podcastSmartPlaylistsProvider(1));
        final cached = await readSmartPlaylists(container, 1);

        expect(cached, isNotNull);
        expect(cached!.playlists, hasLength(2));

        final cached2024 = cached.playlists
            .where((p) => p.id == 'year_2024')
            .first;
        final cached2025 = cached.playlists
            .where((p) => p.id == 'year_2025')
            .first;
        expect(cached2024.episodeIds, containsAll([10, 11]));
        expect(cached2025.episodeIds, [12]);
      },
    );
  });
}
