import 'package:audiflow_domain/src/common/database/app_database.dart';
import 'package:audiflow_domain/src/features/transcript/datasources/local/transcript_local_datasource.dart';
import 'package:audiflow_domain/src/features/transcript/repositories/transcript_repository.dart';
import 'package:audiflow_domain/src/features/transcript/repositories/transcript_repository_impl.dart';
import 'package:audiflow_domain/src/features/transcript/services/transcript_service.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Dio])
import 'transcript_service_test.mocks.dart';

void main() {
  late AppDatabase db;
  late TranscriptRepository repository;
  late MockDio mockDio;
  late TranscriptService service;
  late int episodeId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final datasource = TranscriptLocalDatasource(db);
    repository = TranscriptRepositoryImpl(datasource: datasource);
    mockDio = MockDio();
    service = TranscriptService(
      repository: repository,
      dio: mockDio,
      logger: Logger(level: Level.off),
    );

    // Insert FK dependencies: subscription -> episode
    final subId = await db
        .into(db.subscriptions)
        .insert(
          SubscriptionsCompanion.insert(
            itunesId: 'test-1',
            feedUrl: 'https://example.com/feed.xml',
            title: 'Test Podcast',
            artistName: 'Test Artist',
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

  group('ensureContent', () {
    test('returns null when no transcript metadata exists', () async {
      final result = await service.ensureContent(episodeId);
      expect(result, isNull);
    });

    test('returns null when no supported types exist', () async {
      await repository.upsertMetas([
        EpisodeTranscriptsCompanion.insert(
          episodeId: episodeId,
          url: 'https://example.com/ep1.json',
          type: 'application/json',
        ),
      ]);

      final result = await service.ensureContent(episodeId);
      expect(result, isNull);
    });

    test('returns transcriptId when content already fetched', () async {
      final transcriptId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
              fetchedAt: Value(DateTime.now()),
            ),
          );

      final result = await service.ensureContent(episodeId);
      expect(result, equals(transcriptId));

      verifyNever(mockDio.get<String>(any));
    });

    test('fetches, parses, stores segments, and marks as fetched', () async {
      final transcriptId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
            ),
          );

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

      // Verify segments were stored
      final segments = await repository.getAllSegments(transcriptId);
      expect(segments.length, equals(2));
      expect(segments[0].body, equals('Hello world'));
      expect(segments[0].startMs, equals(1000));
      expect(segments[0].endMs, equals(5000));
      expect(segments[1].body, equals('Second line'));

      // Verify marked as fetched
      expect(await repository.isContentFetched(transcriptId), isTrue);
    });

    test('prefers VTT over SRT', () async {
      // Insert SRT first, then VTT
      await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.srt',
              type: 'application/srt',
            ),
          );
      final vttId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
            ),
          );

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

      // Verify the VTT URL was fetched, not the SRT
      verify(mockDio.get<String>('https://example.com/ep1.vtt')).called(1);
    });

    test('returns null on DioException', () async {
      await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
            ),
          );

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
      await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
            ),
          );

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
      await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
            ),
          );

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
      final transcriptId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
            ),
          );

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
      final srtId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.srt',
              type: 'application/srt',
            ),
          );

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
