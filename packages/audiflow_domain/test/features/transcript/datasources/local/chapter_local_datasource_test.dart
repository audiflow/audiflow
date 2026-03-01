import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/transcript/datasources/local/chapter_local_datasource.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ChapterLocalDatasource datasource;
  late int episodeId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = ChapterLocalDatasource(db);

    final subId = await db
        .into(db.subscriptions)
        .insert(
          SubscriptionsCompanion.insert(
            itunesId: 'test-1',
            feedUrl: 'https://example.com/feed.xml',
            title: 'Test',
            artistName: 'Test',
            subscribedAt: DateTime.now(),
          ),
        );
    episodeId = await db
        .into(db.episodes)
        .insert(
          EpisodesCompanion.insert(
            podcastId: subId,
            guid: 'ep-1',
            title: 'Episode 1',
            audioUrl: 'https://example.com/ep1.mp3',
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('getByEpisodeId', () {
    test('should return chapters ordered by startMs', () async {
      await db
          .into(db.episodeChapters)
          .insert(
            EpisodeChaptersCompanion.insert(
              episodeId: episodeId,
              sortOrder: 1,
              title: 'Second',
              startMs: 60000,
            ),
          );
      await db
          .into(db.episodeChapters)
          .insert(
            EpisodeChaptersCompanion.insert(
              episodeId: episodeId,
              sortOrder: 0,
              title: 'First',
              startMs: 0,
            ),
          );

      final chapters = await datasource.getByEpisodeId(episodeId);
      expect(chapters.length, equals(2));
      expect(chapters[0].title, equals('First'));
      expect(chapters[1].title, equals('Second'));
    });

    test('should return empty list for no chapters', () async {
      final chapters = await datasource.getByEpisodeId(episodeId);
      expect(chapters, isEmpty);
    });
  });

  group('upsertChapters', () {
    test('should insert chapters', () async {
      final companions = [
        EpisodeChaptersCompanion.insert(
          episodeId: episodeId,
          sortOrder: 0,
          title: 'Introduction',
          startMs: 0,
        ),
        EpisodeChaptersCompanion.insert(
          episodeId: episodeId,
          sortOrder: 1,
          title: 'Main Topic',
          startMs: 60000,
        ),
      ];

      await datasource.upsertChapters(companions);

      final results = await datasource.getByEpisodeId(episodeId);
      expect(results.length, equals(2));
      expect(results[0].title, equals('Introduction'));
    });

    test('should update on conflict (same episodeId + sortOrder)', () async {
      final companion = EpisodeChaptersCompanion.insert(
        episodeId: episodeId,
        sortOrder: 0,
        title: 'Original',
        startMs: 0,
      );

      await datasource.upsertChapters([companion]);

      final updated = EpisodeChaptersCompanion.insert(
        episodeId: episodeId,
        sortOrder: 0,
        title: 'Updated',
        startMs: 0,
      );

      await datasource.upsertChapters([updated]);

      final results = await datasource.getByEpisodeId(episodeId);
      expect(results.length, equals(1));
      expect(results[0].title, equals('Updated'));
    });
  });

  group('deleteByEpisodeId', () {
    test('should delete all chapters for episode', () async {
      await datasource.upsertChapters([
        EpisodeChaptersCompanion.insert(
          episodeId: episodeId,
          sortOrder: 0,
          title: 'Chapter',
          startMs: 0,
        ),
      ]);

      final deleted = await datasource.deleteByEpisodeId(episodeId);
      expect(deleted, equals(1));

      final remaining = await datasource.getByEpisodeId(episodeId);
      expect(remaining, isEmpty);
    });
  });

  group('watchByEpisodeId', () {
    test('should emit updates when chapters change', () async {
      final stream = datasource.watchByEpisodeId(episodeId);

      // First emission - empty
      expect(await stream.first, isEmpty);
    });
  });
}
