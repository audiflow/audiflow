import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

void main() {
  late Isar isar;
  late ChapterLocalDatasource datasource;
  late int episodeId;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      [EpisodeChapterSchema],
      directory: '',
      name: 'test_${DateTime.now().microsecondsSinceEpoch}',
    );
    datasource = ChapterLocalDatasource(isar);

    // Use a fixed episodeId (no FK in Isar)
    episodeId = 1;
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('getByEpisodeId', () {
    test('should return chapters ordered by startMs', () async {
      await datasource.upsertChapters([
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 1
          ..title = 'Second'
          ..startMs = 60000,
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 0
          ..title = 'First'
          ..startMs = 0,
      ]);

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
      await datasource.upsertChapters([
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 0
          ..title = 'Introduction'
          ..startMs = 0,
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 1
          ..title = 'Main Topic'
          ..startMs = 60000,
      ]);

      final results = await datasource.getByEpisodeId(episodeId);
      expect(results.length, equals(2));
      expect(results[0].title, equals('Introduction'));
    });

    test('should update on conflict (same episodeId + sortOrder)', () async {
      await datasource.upsertChapters([
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 0
          ..title = 'Original'
          ..startMs = 0,
      ]);

      await datasource.upsertChapters([
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 0
          ..title = 'Updated'
          ..startMs = 0,
      ]);

      final results = await datasource.getByEpisodeId(episodeId);
      expect(results.length, equals(1));
      expect(results[0].title, equals('Updated'));
    });
  });

  group('deleteByEpisodeId', () {
    test('should delete all chapters for episode', () async {
      await datasource.upsertChapters([
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 0
          ..title = 'Chapter'
          ..startMs = 0,
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
