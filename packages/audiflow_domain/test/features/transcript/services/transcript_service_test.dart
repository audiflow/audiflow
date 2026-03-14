import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Dio])
import 'transcript_service_test.mocks.dart';

void main() {
  late Isar isar;
  late TranscriptRepository repository;
  late MockDio mockDio;
  late TranscriptService service;
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
    final datasource = TranscriptLocalDatasource(isar);
    repository = TranscriptRepositoryImpl(datasource: datasource);
    mockDio = MockDio();
    service = TranscriptService(
      repository: repository,
      dio: mockDio,
      logger: Logger(level: Level.off),
    );

    // Use a fixed episodeId (no FK constraints in Isar)
    episodeId = 1;
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('ensureContent', () {
    test('returns null when no transcript metadata exists', () async {
      final result = await service.ensureContent(episodeId);
      expect(result, isNull);
    });

    test('returns null when no supported types exist', () async {
      await repository.upsertMetas([
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.json'
          ..type = 'application/json',
      ]);

      final result = await service.ensureContent(episodeId);
      expect(result, isNull);
    });

    test('returns transcriptId when content already fetched', () async {
      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt'
        ..fetchedAt = DateTime.now();
      await repository.upsertMetas([transcript]);

      final metas = await repository.getMetasByEpisodeId(episodeId);
      final transcriptId = metas.first.id;

      final result = await service.ensureContent(episodeId);
      expect(result, equals(transcriptId));

      verifyNever(mockDio.get<String>(any));
    });

    test('fetches, parses, stores segments, and marks as fetched', () async {
      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';
      await repository.upsertMetas([transcript]);
      final metas = await repository.getMetasByEpisodeId(episodeId);
      final transcriptId = metas.first.id;

      const vttContent =
          'WEBVTT\n'
          '\n'
          '00:00:01.000 --> 00:00:05.000\n'
          'Hello world\n'
          '\n'
          '00:00:05.000 --> 00:00:10.000\n'
          'Second line\n';

      when(mockDio.get<String>(any)).thenAnswer(
        (_) async => Response(
          data: vttContent,
          statusCode: 200,
          requestOptions: RequestOptions(path: 'https://example.com/ep1.vtt'),
        ),
      );

      final result = await service.ensureContent(episodeId);
      expect(result, equals(transcriptId));

      final segments = await repository.getAllSegments(transcriptId);
      expect(segments.length, equals(2));
      expect(segments[0].body, equals('Hello world'));
      expect(segments[0].startMs, equals(1000));
      expect(segments[0].endMs, equals(5000));
      expect(segments[1].body, equals('Second line'));

      expect(await repository.isContentFetched(transcriptId), isTrue);
    });

    test('prefers VTT over SRT', () async {
      await repository.upsertMetas([
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.srt'
          ..type = 'application/srt',
      ]);
      await repository.upsertMetas([
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.vtt'
          ..type = 'text/vtt',
      ]);

      final metas = await repository.getMetasByEpisodeId(episodeId);
      final vttId = metas.firstWhere((m) => m.type == 'text/vtt').id;

      const vttContent =
          'WEBVTT\n'
          '\n'
          '00:00:01.000 --> 00:00:05.000\n'
          'Hello\n';

      when(mockDio.get<String>(any)).thenAnswer(
        (_) async => Response(
          data: vttContent,
          statusCode: 200,
          requestOptions: RequestOptions(path: 'https://example.com/ep1.vtt'),
        ),
      );

      final result = await service.ensureContent(episodeId);
      expect(result, equals(vttId));

      verify(mockDio.get<String>('https://example.com/ep1.vtt')).called(1);
    });

    test('returns null on DioException', () async {
      await repository.upsertMetas([
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.vtt'
          ..type = 'text/vtt',
      ]);

      when(mockDio.get<String>(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'https://example.com/ep1.vtt'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await service.ensureContent(episodeId);
      expect(result, isNull);
    });

    test('returns null when fetch returns empty content', () async {
      await repository.upsertMetas([
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.vtt'
          ..type = 'text/vtt',
      ]);

      when(mockDio.get<String>(any)).thenAnswer(
        (_) async => Response(
          data: '',
          statusCode: 200,
          requestOptions: RequestOptions(path: 'https://example.com/ep1.vtt'),
        ),
      );

      final result = await service.ensureContent(episodeId);
      expect(result, isNull);
    });

    test('returns null when fetch returns null data', () async {
      await repository.upsertMetas([
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.vtt'
          ..type = 'text/vtt',
      ]);

      when(mockDio.get<String>(any)).thenAnswer(
        (_) async => Response<String>(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: 'https://example.com/ep1.vtt'),
        ),
      );

      final result = await service.ensureContent(episodeId);
      expect(result, isNull);
    });

    test('stores speaker information from VTT', () async {
      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';
      await repository.upsertMetas([transcript]);
      final metas = await repository.getMetasByEpisodeId(episodeId);
      final transcriptId = metas.first.id;

      const vttContent =
          'WEBVTT\n'
          '\n'
          '00:00:01.000 --> 00:00:05.000\n'
          '<v Alice>Hello from Alice\n';

      when(mockDio.get<String>(any)).thenAnswer(
        (_) async => Response(
          data: vttContent,
          statusCode: 200,
          requestOptions: RequestOptions(path: 'https://example.com/ep1.vtt'),
        ),
      );

      await service.ensureContent(episodeId);

      final segments = await repository.getAllSegments(transcriptId);
      expect(segments.length, equals(1));
      expect(segments[0].speaker, equals('Alice'));
      expect(segments[0].body, equals('Hello from Alice'));
    });

    test('falls back to SRT when VTT not available', () async {
      await repository.upsertMetas([
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.srt'
          ..type = 'application/srt',
      ]);
      final metas = await repository.getMetasByEpisodeId(episodeId);
      final srtId = metas.first.id;

      const srtContent =
          '1\n'
          '00:00:01,000 --> 00:00:05,000\n'
          'Hello from SRT\n';

      when(mockDio.get<String>(any)).thenAnswer(
        (_) async => Response(
          data: srtContent,
          statusCode: 200,
          requestOptions: RequestOptions(path: 'https://example.com/ep1.srt'),
        ),
      );

      final result = await service.ensureContent(episodeId);
      expect(result, equals(srtId));

      final segments = await repository.getAllSegments(srtId);
      expect(segments.length, equals(1));
      expect(segments[0].body, equals('Hello from SRT'));
    });
  });
}
