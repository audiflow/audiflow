import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

void main() {
  late Isar isar;
  late ChapterRepository repository;
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
    final datasource = ChapterLocalDatasource(isar);
    repository = ChapterRepositoryImpl(datasource: datasource);
    episodeId = 1;
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('getByEpisodeId', () {
    test('should return chapters ordered by startMs', () async {
      await repository.upsertChapters([
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

      final chapters = await repository.getByEpisodeId(episodeId);
      expect(chapters.length, equals(2));
      expect(chapters[0].title, equals('First'));
      expect(chapters[1].title, equals('Second'));
    });

    test('should return empty list when no chapters exist', () async {
      final chapters = await repository.getByEpisodeId(episodeId);
      expect(chapters, isEmpty);
    });
  });

  group('watchByEpisodeId', () {
    test('should emit current chapters', () async {
      final stream = repository.watchByEpisodeId(episodeId);

      expect(await stream.first, isEmpty);
    });

    test('should emit updates when chapters change', () async {
      final emissions = <List<EpisodeChapter>>[];
      final subscription = repository
          .watchByEpisodeId(episodeId)
          .listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      await repository.upsertChapters([
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 0
          ..title = 'Chapter 1'
          ..startMs = 0,
      ]);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      await subscription.cancel();

      expect(emissions.length, equals(2));
      expect(emissions[0], isEmpty);
      expect(emissions[1].length, equals(1));
      expect(emissions[1][0].title, equals('Chapter 1'));
    });
  });

  group('upsertChapters', () {
    test('should insert new chapters', () async {
      await repository.upsertChapters([
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

      final results = await repository.getByEpisodeId(episodeId);
      expect(results.length, equals(2));
      expect(results[0].title, equals('Introduction'));
      expect(results[1].title, equals('Main Topic'));
    });

    test('should update on conflict', () async {
      await repository.upsertChapters([
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 0
          ..title = 'Original'
          ..startMs = 0,
      ]);

      await repository.upsertChapters([
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 0
          ..title = 'Updated'
          ..startMs = 0,
      ]);

      final results = await repository.getByEpisodeId(episodeId);
      expect(results.length, equals(1));
      expect(results[0].title, equals('Updated'));
    });
  });

  group('deleteByEpisodeId', () {
    test('should delete all chapters for episode', () async {
      await repository.upsertChapters([
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 0
          ..title = 'Chapter 1'
          ..startMs = 0,
        EpisodeChapter()
          ..episodeId = episodeId
          ..sortOrder = 1
          ..title = 'Chapter 2'
          ..startMs = 60000,
      ]);

      final deleted = await repository.deleteByEpisodeId(episodeId);
      expect(deleted, equals(2));

      final remaining = await repository.getByEpisodeId(episodeId);
      expect(remaining, isEmpty);
    });

    test('should return zero when no chapters exist', () async {
      final deleted = await repository.deleteByEpisodeId(episodeId);
      expect(deleted, equals(0));
    });
  });
}
