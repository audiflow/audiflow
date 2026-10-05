import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late ChapterLocalDatasource datasource;
  late int episodeId;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([EpisodeChapterSchema]);
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

  group('replaceChapters', () {
    EpisodeChapter chapter(int sortOrder, String title, {int? id}) =>
        EpisodeChapter()
          ..episodeId = id ?? episodeId
          ..sortOrder = sortOrder
          ..title = title
          ..startMs = sortOrder * 1000;

    Future<List<String>> titles() async => (await datasource.getByEpisodeId(
      episodeId,
    )).map((c) => c.title).toList();

    // Rows written before `source` existed rely on the generated reader's
    // fallback to podlove (episode_chapter.g.dart), not on this default.
    test('chapters built in code default to the podlove source', () {
      expect(EpisodeChapter().source, ChapterSource.podlove);
    });

    test('stores chapters with the given source', () async {
      final replaced = await datasource.replaceChapters({
        episodeId: [chapter(0, 'A'), chapter(1, 'B')],
      }, source: ChapterSource.podcastChaptersJson);

      expect(replaced, {episodeId});
      expect(await titles(), ['A', 'B']);
      final stored = await datasource.getByEpisodeId(episodeId);
      expect(
        stored.map((c) => c.source),
        everyElement(ChapterSource.podcastChaptersJson),
      );
    });

    test('drops stale rows when the new list is shorter', () async {
      await datasource.upsertChapters([chapter(0, 'A'), chapter(1, 'B')]);

      await datasource.replaceChapters({
        episodeId: [chapter(0, 'Only')],
      }, source: ChapterSource.podlove);

      expect(await titles(), ['Only']);
    });

    test('lower priority never replaces higher priority', () async {
      await datasource.replaceChapters({
        episodeId: [chapter(0, 'Json')],
      }, source: ChapterSource.podcastChaptersJson);

      final fromPodlove = await datasource.replaceChapters({
        episodeId: [chapter(0, 'Psc')],
      }, source: ChapterSource.podlove);
      final fromDescription = await datasource.replaceChapters({
        episodeId: [chapter(0, 'Desc')],
      }, source: ChapterSource.description);

      expect(fromPodlove, isEmpty);
      expect(fromDescription, isEmpty);
      expect(await titles(), ['Json']);
    });

    group('JSON chapters whose link changed', () {
      const linkA = 'https://example.com/a.json';
      Future<void> storeJsonFromA() => datasource.replaceChapters({
        episodeId: [chapter(0, 'Json')..sourceUrl = linkA],
      }, source: ChapterSource.podcastChaptersJson);

      test('keep their rank while the episode still links them', () async {
        await storeJsonFromA();

        final replaced = await datasource.replaceChapters(
          {
            episodeId: [chapter(0, 'Psc')],
          },
          source: ChapterSource.podlove,
          linkedJsonUrls: {episodeId: linkA},
        );

        expect(replaced, isEmpty);
        expect(await titles(), ['Json']);
      });

      test('lose their rank once the link is removed', () async {
        await storeJsonFromA();

        final replaced = await datasource.replaceChapters(
          {
            episodeId: [chapter(0, 'Psc')],
          },
          source: ChapterSource.podlove,
          linkedJsonUrls: {episodeId: null},
        );

        expect(replaced, {episodeId});
        expect(await titles(), ['Psc']);
      });

      test('lose their rank once the link points elsewhere', () async {
        await storeJsonFromA();

        await datasource.replaceChapters(
          {
            episodeId: [chapter(0, 'Psc')],
          },
          source: ChapterSource.podlove,
          linkedJsonUrls: {episodeId: 'https://example.com/b.json'},
        );

        expect(await titles(), ['Psc']);
      });
    });

    test('higher priority replaces lower priority', () async {
      await datasource.replaceChapters({
        episodeId: [chapter(0, 'Desc'), chapter(1, 'Desc 2')],
      }, source: ChapterSource.description);

      await datasource.replaceChapters({
        episodeId: [chapter(0, 'Psc')],
      }, source: ChapterSource.podlove);

      expect(await titles(), ['Psc']);
      final stored = await datasource.getByEpisodeId(episodeId);
      expect(stored.single.source, ChapterSource.podlove);
    });

    test('leaves other episodes untouched', () async {
      await datasource.upsertChapters([chapter(0, 'Other', id: 2)]);

      await datasource.replaceChapters({
        episodeId: [chapter(0, 'Mine')],
      }, source: ChapterSource.podlove);

      final other = await datasource.getByEpisodeId(2);
      expect(other.single.title, 'Other');
    });
  });
}
