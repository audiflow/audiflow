import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/isar_test_helper.dart';
import 'smart_playlist_provider_test_support.dart';

const _summary = PresetSummary(
  id: 'test-pattern',
  dataVersion: 1,
  displayName: 'Test Pattern',
  feedUrlHint: 'example.com',
  playlistCount: 1,
);

final _config = PresetConfig(
  id: 'test-pattern',
  feedUrls: ['https://example.com/feed.xml'],
  playlists: [
    const SmartPlaylistDefinition(
      id: 'regular',
      displayName: 'Regular Series',
      grouping: GroupingConfig(
        by: 'seasonNumber',
        numberingExtractor: NumberingExtractor(
          source: 'title',
          pattern: r'【(\d+)-(\d+)】',
        ),
      ),
      priority: 0,
    ),
  ],
);

Episode _seriesEpisode(int id, int season, int number, {String? title}) =>
    testEpisode(
      id: id,
      title: title ?? '【$season-$number】Series $season part $number',
      seasonNumber: season,
      episodeNumber: number,
      publishedAt: DateTime(2026, season, number),
    );

List<SmartPlaylistGroup> _allGroups(SmartPlaylistGrouping grouping) => grouping
    .playlists
    .expand((p) => p.groups ?? const <SmartPlaylistGroup>[])
    .toList();

SmartPlaylistGroup? _groupOf(SmartPlaylistGrouping grouping, int episodeId) {
  for (final group in _allGroups(grouping)) {
    if (group.episodeIds.contains(episodeId)) return group;
  }
  return null;
}

List<int>? _groupMates(SmartPlaylistGrouping grouping, int episodeId) =>
    _groupOf(grouping, episodeId)?.episodeIds;

void main() {
  late Isar isar;
  late SmartPlaylistLocalDatasource datasource;
  late FakeEpisodeRepository episodeRepo;
  late FakeConfigRepository configRepo;
  late ProviderContainer container;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([
      SmartPlaylistEntitySchema,
      SmartPlaylistGroupEntitySchema,
    ]);
    datasource = SmartPlaylistLocalDatasource(isar);
    episodeRepo = FakeEpisodeRepository([
      _seriesEpisode(1, 1, 1),
      _seriesEpisode(2, 1, 2),
    ]);
    configRepo = FakeConfigRepository(summary: _summary, config: _config);
    container = ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(
          FakeSubscriptionRepository(testSubscription()),
        ),
        episodeRepositoryProvider.overrideWithValue(episodeRepo),
        smartPlaylistLocalDatasourceProvider.overrideWithValue(datasource),
        presetConfigRepositoryProvider.overrideWithValue(configRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await isar.close(deleteFromDisk: true);
  });

  /// Simulates a feed sync: episodes changed, provider invalidated.
  Future<SmartPlaylistGrouping> reread() async {
    final provider = podcastSmartPlaylistsProvider(1);
    container.invalidate(provider);
    // Await the rebuilt future; the shared reader would accept the
    // previous value that Riverpod keeps visible while refreshing.
    final sub = container.listen(provider.future, (_, _) {});
    try {
      return (await sub.read())!;
    } finally {
      sub.close();
    }
  }

  group('episode fingerprint cache invalidation', () {
    test('episodes of a new series published after caching get their own '
        'group instead of falling into ungrouped', () async {
      await readSmartPlaylists(container, 1);

      episodeRepo.episodes.addAll([
        _seriesEpisode(3, 2, 1),
        _seriesEpisode(4, 2, 2),
      ]);
      final grouping = await reread();

      check(grouping.ungroupedEpisodeIds).isEmpty();
      check(_groupMates(grouping, 3)).isNotNull().unorderedEquals([3, 4]);
      check(_allGroups(grouping)).length.equals(2);
    });

    test('a new episode of an existing series joins that group', () async {
      await readSmartPlaylists(container, 1);

      episodeRepo.episodes.add(_seriesEpisode(3, 1, 3));
      final grouping = await reread();

      check(_groupMates(grouping, 3)).isNotNull().unorderedEquals([1, 2, 3]);
      check(_groupOf(grouping, 3)?.latestDate).equals(DateTime(2026, 1, 3));
    });

    test('a removed episode disappears from its group', () async {
      await readSmartPlaylists(container, 1);

      episodeRepo.episodes.removeWhere((e) => e.id == 2);
      final grouping = await reread();

      check(_groupOf(grouping, 2)).isNull();
      check(_groupMates(grouping, 1)).isNotNull().deepEquals([1]);
    });

    test('an episode whose numbering changed moves to its new group', () async {
      await readSmartPlaylists(container, 1);

      episodeRepo.episodes
        ..removeWhere((e) => e.id == 2)
        ..add(_seriesEpisode(2, 3, 1));
      final grouping = await reread();

      check(_groupMates(grouping, 1)).isNotNull().deepEquals([1]);
      check(_groupMates(grouping, 2)).isNotNull().deepEquals([2]);
    });

    test(
      'unchanged episodes reuse the cache even when some stay ungrouped',
      () async {
        // No season number: legitimately ungrouped on every resolve.
        episodeRepo.episodes.add(testEpisode(id: 9, title: 'Bonus'));
        final first = await readSmartPlaylists(container, 1);
        check(first)
            .isNotNull()
            .has((g) => g.ungroupedEpisodeIds, 'ungrouped')
            .deepEquals([9]);
        final callsAfterFirstResolve = configRepo.getConfigCalls;

        final second = await reread();

        check(second.ungroupedEpisodeIds).deepEquals([9]);
        check(
          because: 'a cache hit must not re-resolve',
          configRepo.getConfigCalls,
        ).equals(callsAfterFirstResolve);
      },
    );

    test('a cache persisted before fingerprints existed is re-resolved '
        'once on upgrade', () async {
      // Shape of a cache written by v2.0.1: right config version,
      // no fingerprint, groups missing a newer series.
      final legacyEntity = SmartPlaylistEntity()
        ..podcastId = 1
        ..playlistNumber = 0
        ..playlistId = 'regular'
        ..displayName = 'Regular Series'
        ..sortKey = 0
        ..resolverType = 'seasonNumber'
        ..playlistStructure = 'combined'
        ..yearHeaderMode = 'none'
        ..configVersion = 1;
      await datasource.upsertAllForPodcast(1, [legacyEntity]);
      final legacyGroup = SmartPlaylistGroupEntity()
        ..podcastId = 1
        ..playlistId = 'regular'
        ..groupId = 'season_1'
        ..displayName = 'Series 1'
        ..sortKey = 1
        ..episodeIds = '1,2';
      await datasource.upsertGroupsForPlaylist(1, 'regular', [legacyGroup]);
      episodeRepo.episodes.add(_seriesEpisode(3, 2, 1));

      final grouping = (await readSmartPlaylists(container, 1))!;

      check(grouping.ungroupedEpisodeIds).isEmpty();
      check(_groupOf(grouping, 3)?.id).equals('season_2');
      final entities = await datasource.getByPodcastId(1);
      check(entities.first.episodeFingerprint).isNotNull();
    });

    test('keeps the cached grouping while the preset cannot load, then '
        're-resolves once it does', () async {
      await readSmartPlaylists(container, 1);
      episodeRepo.episodes.add(_seriesEpisode(3, 2, 1));

      configRepo.failGetConfig = true;
      final offline = await reread();

      check(_groupMates(offline, 1)).isNotNull().unorderedEquals([1, 2]);
      final cachedGroups = await datasource.getGroupsByPlaylist(1, 'regular');
      check(cachedGroups.map((g) => g.groupId)).deepEquals(['season_1']);

      configRepo.failGetConfig = false;
      final online = await reread();

      check(_groupOf(online, 3)?.id).equals('season_2');
    });

    test('a preset-less fallback is never persisted under the preset '
        'version', () async {
      configRepo.failGetConfig = true;

      await readSmartPlaylists(container, 1);

      check(await datasource.getByPodcastId(1)).isEmpty();
    });
  });
}
