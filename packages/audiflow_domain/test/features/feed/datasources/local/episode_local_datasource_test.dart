import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late EpisodeLocalDatasource datasource;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = EpisodeLocalDatasource(db);

    // Insert a test subscription for foreign key constraint
    await db
        .into(db.subscriptions)
        .insert(
          SubscriptionsCompanion.insert(
            itunesId: 'itunes-1',
            feedUrl: 'https://example.com/feed.xml',
            title: 'Test Podcast',
            artistName: 'Test Artist',
            subscribedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('getGuidsByPodcastId', () {
    test('returns empty set for podcast with no episodes', () async {
      final guids = await datasource.getGuidsByPodcastId(999);
      expect(guids, isEmpty);
    });

    test('returns all GUIDs for podcast', () async {
      // Insert test episodes
      await datasource.upsert(
        EpisodesCompanion.insert(
          podcastId: 1,
          guid: 'guid-1',
          title: 'Episode 1',
          audioUrl: 'https://example.com/ep1.mp3',
        ),
      );
      await datasource.upsert(
        EpisodesCompanion.insert(
          podcastId: 1,
          guid: 'guid-2',
          title: 'Episode 2',
          audioUrl: 'https://example.com/ep2.mp3',
        ),
      );

      // Insert another subscription for isolation test
      await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'itunes-2',
              feedUrl: 'https://example.com/feed2.xml',
              title: 'Test Podcast 2',
              artistName: 'Test Artist 2',
              subscribedAt: DateTime.now(),
            ),
          );
      await datasource.upsert(
        EpisodesCompanion.insert(
          podcastId: 2, // Different podcast
          guid: 'guid-3',
          title: 'Episode 3',
          audioUrl: 'https://example.com/ep3.mp3',
        ),
      );

      final guids = await datasource.getGuidsByPodcastId(1);

      expect(guids, hasLength(2));
      expect(guids, containsAll(['guid-1', 'guid-2']));
      expect(guids, isNot(contains('guid-3')));
    });
  });

  group('upsertAll', () {
    test('inserts multiple episodes in batch', () async {
      final companions = [
        EpisodesCompanion.insert(
          podcastId: 1,
          guid: 'batch-1',
          title: 'Batch Episode 1',
          audioUrl: 'https://example.com/batch1.mp3',
        ),
        EpisodesCompanion.insert(
          podcastId: 1,
          guid: 'batch-2',
          title: 'Batch Episode 2',
          audioUrl: 'https://example.com/batch2.mp3',
        ),
      ];

      await datasource.upsertAll(companions);

      final episodes = await datasource.getByPodcastId(1);
      expect(episodes, hasLength(2));
    });

    test('updates existing episodes on conflict', () async {
      // Insert initial episode
      await datasource.upsert(
        EpisodesCompanion.insert(
          podcastId: 1,
          guid: 'update-test',
          title: 'Original Title',
          audioUrl: 'https://example.com/update.mp3',
        ),
      );

      // Upsert with same guid but different title
      await datasource.upsertAll([
        EpisodesCompanion.insert(
          podcastId: 1,
          guid: 'update-test',
          title: 'Updated Title',
          audioUrl: 'https://example.com/update.mp3',
        ),
      ]);

      final episodes = await datasource.getByPodcastId(1);
      expect(episodes, hasLength(1));
      expect(episodes.first.title, 'Updated Title');
    });
  });
}
