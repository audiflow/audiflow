import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

void main() {
  late Isar isar;
  late TranscriptLocalDatasource datasource;
  late TranscriptRepository repository;
  late int episodeId;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      [EpisodeTranscriptSchema, TranscriptSegmentSchema],
      directory: '',
      name: 'test_${DateTime.now().microsecondsSinceEpoch}',
    );
    datasource = TranscriptLocalDatasource(isar);
    repository = TranscriptRepositoryImpl(datasource: datasource);
    episodeId = 1;
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('getMetasByEpisodeId', () {
    test('returns empty list when no transcripts exist', () async {
      final results = await repository.getMetasByEpisodeId(episodeId);
      expect(results, isEmpty);
    });

    test('returns transcript metadata for an episode', () async {
      await repository.upsertMetas([
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.vtt'
          ..type = 'text/vtt'
          ..language = 'en'
          ..rel = 'captions',
      ]);

      final results = await repository.getMetasByEpisodeId(episodeId);
      expect(results.length, equals(1));
      expect(results.first.url, equals('https://example.com/ep1.vtt'));
      expect(results.first.type, equals('text/vtt'));
      expect(results.first.language, equals('en'));
    });
  });

  group('upsertMetas', () {
    test('inserts new transcript metadata', () async {
      await repository.upsertMetas([
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.srt'
          ..type = 'application/x-subrip',
      ]);

      final results = await repository.getMetasByEpisodeId(episodeId);
      expect(results.length, equals(1));
      expect(results.first.type, equals('application/x-subrip'));
    });

    test('updates on conflict (same episodeId + url)', () async {
      final meta = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';

      await repository.upsertMetas([meta]);
      await repository.upsertMetas([
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.vtt'
          ..type = 'text/vtt',
      ]);

      final results = await repository.getMetasByEpisodeId(episodeId);
      expect(results.length, equals(1));
    });
  });

  group('insertSegments / getAllSegments', () {
    late int transcriptId;

    setUp(() async {
      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';
      await repository.upsertMetas([transcript]);
      final metas = await repository.getMetasByEpisodeId(episodeId);
      transcriptId = metas.first.id;
    });

    test('inserts and retrieves all segments ordered by startMs', () async {
      await repository.insertSegments([
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 10000
          ..endMs = 15000
          ..body = 'Second',
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 0
          ..endMs = 5000
          ..body = 'First',
      ]);

      final results = await repository.getAllSegments(transcriptId);
      expect(results.length, equals(2));
      expect(results[0].body, equals('First'));
      expect(results[1].body, equals('Second'));
    });

    test('returns empty list when no segments exist', () async {
      final results = await repository.getAllSegments(transcriptId);
      expect(results, isEmpty);
    });
  });

  group('getSegments', () {
    late int transcriptId;

    setUp(() async {
      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';
      await repository.upsertMetas([transcript]);
      final metas = await repository.getMetasByEpisodeId(episodeId);
      transcriptId = metas.first.id;

      await repository.insertSegments([
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 0
          ..endMs = 5000
          ..body = 'First segment',
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 5000
          ..endMs = 10000
          ..body = 'Second segment',
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 10000
          ..endMs = 15000
          ..body = 'Third segment',
      ]);
    });

    test('returns segments overlapping time range', () async {
      final results = await repository.getSegments(
        transcriptId,
        startMs: 4000,
        endMs: 10000,
      );

      expect(results.length, equals(2));
      expect(results[0].body, equals('First segment'));
      expect(results[1].body, equals('Second segment'));
    });

    test('returns empty when range has no overlap', () async {
      final results = await repository.getSegments(
        transcriptId,
        startMs: 20000,
        endMs: 25000,
      );

      expect(results, isEmpty);
    });
  });

  group('markAsFetched / isContentFetched', () {
    late int transcriptId;

    setUp(() async {
      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';
      await repository.upsertMetas([transcript]);
      final metas = await repository.getMetasByEpisodeId(episodeId);
      transcriptId = metas.first.id;
    });

    test('returns false when not yet fetched', () async {
      expect(await repository.isContentFetched(transcriptId), isFalse);
    });

    test('returns true after marking as fetched', () async {
      await repository.markAsFetched(transcriptId);
      expect(await repository.isContentFetched(transcriptId), isTrue);
    });
  });

  group('deleteSegments', () {
    late int transcriptId;

    setUp(() async {
      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';
      await repository.upsertMetas([transcript]);
      final metas = await repository.getMetasByEpisodeId(episodeId);
      transcriptId = metas.first.id;
    });

    test('deletes all segments and returns count', () async {
      await repository.insertSegments([
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 0
          ..endMs = 5000
          ..body = 'Segment 1',
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 5000
          ..endMs = 10000
          ..body = 'Segment 2',
      ]);

      final deleted = await repository.deleteSegments(transcriptId);
      expect(deleted, equals(2));

      final remaining = await repository.getAllSegments(transcriptId);
      expect(remaining, isEmpty);
    });

    test('returns zero when no segments to delete', () async {
      final deleted = await repository.deleteSegments(transcriptId);
      expect(deleted, equals(0));
    });
  });
}
