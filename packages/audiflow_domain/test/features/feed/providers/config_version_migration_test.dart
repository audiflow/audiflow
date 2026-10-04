import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/isar_test_helper.dart';
import 'smart_playlist_provider_test_support.dart';

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

  group('config version migration', () {
    test(
      'config bump re-extracts stale episodes and persists new grouping',
      () async {
        // Episode 1 was ingested under config v1 (no extractor), so
        // its numbering was never derived from the title. Episode 2
        // arrived after config v2 reached the device and got the new
        // numbering at ingest.
        final episodes = [
          testEpisode(
            id: 1,
            title: '【5-1】Bangladesh 1',
            publishedAt: DateTime(2025),
          ),
          testEpisode(
            id: 2,
            title: '【5-2】Bangladesh 2',
            seasonNumber: 5,
            episodeNumber: 2,
            publishedAt: DateTime(2025, 2),
          ),
          testEpisode(
            id: 3,
            title: '【1-1】Regular',
            seasonNumber: 1,
            episodeNumber: 1,
            publishedAt: DateTime(2024),
          ),
        ];

        // Cached grouping persisted under config v1.
        final staleEntity = SmartPlaylistEntity()
          ..podcastId = 1
          ..playlistNumber = 0
          ..playlistId = 'regular'
          ..displayName = 'Regular Series'
          ..sortKey = 0
          ..resolverType = 'seasonNumber'
          ..playlistStructure = 'combined'
          ..yearHeaderMode = 'none'
          ..configVersion = 1;
        await datasource.upsertAllForPodcast(1, [staleEntity]);

        // A group row belonging to a playlist that no longer exists
        // in config v2; migration must not leave it behind.
        final orphanGroup = SmartPlaylistGroupEntity()
          ..podcastId = 1
          ..playlistId = 'removed-playlist'
          ..groupId = 'season_99'
          ..displayName = 'Removed'
          ..sortKey = 0
          ..episodeIds = '1';
        await datasource.upsertGroupsForPlaylist(1, 'removed-playlist', [
          orphanGroup,
        ]);

        final summary = PresetSummary(
          id: 'test-pattern',
          dataVersion: 2,
          displayName: 'Test Pattern',
          feedUrlHint: 'example.com',
          playlistCount: 1,
        );

        // Config v2 adds a numbering extractor.
        final config = PresetConfig(
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

        final episodeRepo = FakeEpisodeRepository(episodes);
        final container = ProviderContainer(
          overrides: [
            subscriptionRepositoryProvider.overrideWithValue(
              FakeSubscriptionRepository(testSubscription()),
            ),
            episodeRepositoryProvider.overrideWithValue(episodeRepo),
            smartPlaylistLocalDatasourceProvider.overrideWithValue(datasource),
            presetConfigRepositoryProvider.overrideWithValue(
              FakeConfigRepository(summary: summary, config: config),
            ),
          ],
        );
        addTearDown(container.dispose);

        final grouping = await readSmartPlaylists(container, 1);

        // The stale episode is re-extracted and grouped with its
        // sibling instead of being left ungrouped.
        expect(grouping, isNotNull);
        expect(grouping!.ungroupedEpisodeIds, isNot(contains(1)));
        final season5 = grouping.playlists
            .expand((p) => p.groups ?? const <SmartPlaylistGroup>[])
            .where((g) => g.episodeIds.contains(2))
            .toList();
        expect(season5, hasLength(1));
        expect(season5.first.episodeIds, containsAll([1, 2]));

        // Refreshed numbering is written back to storage.
        expect(
          episodeRepo.upserted.map((e) => e.id),
          contains(1),
          reason: 'Re-extracted episode must be persisted',
        );
        expect(episodes[0].seasonNumber, 5);

        // The persisted grouping advances to the new config version.
        final entities = await datasource.getByPodcastId(1);
        expect(entities, isNotEmpty);
        for (final entity in entities) {
          expect(entity.configVersion, 2);
        }

        // Group rows of playlists dropped by the new config are
        // cleaned up.
        final orphans = await datasource.getGroupsByPlaylist(
          1,
          'removed-playlist',
        );
        expect(orphans, isEmpty);
      },
    );
  });
}
