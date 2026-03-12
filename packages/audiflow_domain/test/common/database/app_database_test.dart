import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('database creation', () {
    test('schema version is 19', () {
      expect(db.schemaVersion, equals(19));
    });

    test('all tables are accessible', () {
      // Verify table accessors do not throw
      expect(db.subscriptions, isNotNull);
      expect(db.episodes, isNotNull);
      expect(db.playbackHistories, isNotNull);
      expect(db.smartPlaylists, isNotNull);
      expect(db.smartPlaylistGroups, isNotNull);
      expect(db.podcastViewPreferences, isNotNull);
      expect(db.downloadTasks, isNotNull);
      expect(db.queueItems, isNotNull);
      expect(db.episodeTranscripts, isNotNull);
      expect(db.transcriptSegments, isNotNull);
      expect(db.episodeChapters, isNotNull);
    });
  });

  group('subscriptions CRUD', () {
    test('insert and read subscription', () async {
      final now = DateTime.now();
      final id = await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'itunes-1',
              feedUrl: 'https://example.com/feed.xml',
              title: 'My Podcast',
              artistName: 'Artist',
              subscribedAt: now,
            ),
          );

      expect(0 < id, isTrue);

      final result = await (db.select(
        db.subscriptions,
      )..where((t) => t.id.equals(id))).getSingle();

      expect(result.itunesId, equals('itunes-1'));
      expect(result.feedUrl, equals('https://example.com/feed.xml'));
      expect(result.title, equals('My Podcast'));
      expect(result.artistName, equals('Artist'));
    });

    test('update subscription', () async {
      final id = await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'itunes-2',
              feedUrl: 'https://example.com/feed2.xml',
              title: 'Old Title',
              artistName: 'Artist',
              subscribedAt: DateTime.now(),
            ),
          );

      await (db.update(db.subscriptions)..where((t) => t.id.equals(id))).write(
        const SubscriptionsCompanion(title: Value('New Title')),
      );

      final updated = await (db.select(
        db.subscriptions,
      )..where((t) => t.id.equals(id))).getSingle();

      expect(updated.title, equals('New Title'));
    });

    test('delete subscription', () async {
      final id = await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'itunes-3',
              feedUrl: 'https://example.com/feed3.xml',
              title: 'Delete Me',
              artistName: 'Artist',
              subscribedAt: DateTime.now(),
            ),
          );

      final deleted = await (db.delete(
        db.subscriptions,
      )..where((t) => t.id.equals(id))).go();
      expect(deleted, equals(1));

      final result = await (db.select(
        db.subscriptions,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      expect(result, isNull);
    });

    test('enforces unique itunesId', () async {
      await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'unique-id',
              feedUrl: 'https://example.com/feed.xml',
              title: 'First',
              artistName: 'Artist',
              subscribedAt: DateTime.now(),
            ),
          );

      expect(
        () => db
            .into(db.subscriptions)
            .insert(
              SubscriptionsCompanion.insert(
                itunesId: 'unique-id',
                feedUrl: 'https://example.com/other.xml',
                title: 'Second',
                artistName: 'Artist',
                subscribedAt: DateTime.now(),
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('episodes CRUD', () {
    late int podcastId;

    setUp(() async {
      podcastId = await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'ep-test',
              feedUrl: 'https://example.com/feed.xml',
              title: 'Podcast',
              artistName: 'Artist',
              subscribedAt: DateTime.now(),
            ),
          );
    });

    test('insert and read episode', () async {
      final id = await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: podcastId,
              guid: 'guid-1',
              title: 'Episode 1',
              audioUrl: 'https://example.com/ep1.mp3',
            ),
          );

      final result = await (db.select(
        db.episodes,
      )..where((t) => t.id.equals(id))).getSingle();

      expect(result.podcastId, equals(podcastId));
      expect(result.guid, equals('guid-1'));
      expect(result.title, equals('Episode 1'));
      expect(result.audioUrl, equals('https://example.com/ep1.mp3'));
    });

    test('insert episode with all optional fields', () async {
      final publishDate = DateTime(2024, 1, 15);
      final id = await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: podcastId,
              guid: 'guid-full',
              title: 'Full Episode',
              audioUrl: 'https://example.com/full.mp3',
              description: const Value('A great episode'),
              durationMs: const Value(3600000),
              publishedAt: Value(publishDate),
              imageUrl: const Value('https://example.com/art.jpg'),
              episodeNumber: const Value(5),
              seasonNumber: const Value(2),
            ),
          );

      final result = await (db.select(
        db.episodes,
      )..where((t) => t.id.equals(id))).getSingle();

      expect(result.description, equals('A great episode'));
      expect(result.durationMs, equals(3600000));
      expect(result.publishedAt, equals(publishDate));
      expect(result.imageUrl, equals('https://example.com/art.jpg'));
      expect(result.episodeNumber, equals(5));
      expect(result.seasonNumber, equals(2));
    });

    test('enforces unique key on podcastId and guid', () async {
      await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: podcastId,
              guid: 'dup-guid',
              title: 'First',
              audioUrl: 'https://example.com/first.mp3',
            ),
          );

      expect(
        () => db
            .into(db.episodes)
            .insert(
              EpisodesCompanion.insert(
                podcastId: podcastId,
                guid: 'dup-guid',
                title: 'Second',
                audioUrl: 'https://example.com/second.mp3',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('delete episode', () async {
      final id = await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: podcastId,
              guid: 'del-guid',
              title: 'Delete Me',
              audioUrl: 'https://example.com/del.mp3',
            ),
          );

      final deleted = await (db.delete(
        db.episodes,
      )..where((t) => t.id.equals(id))).go();
      expect(deleted, equals(1));
    });
  });

  group('DownloadTaskStatusX extension', () {
    late int episodeId;

    setUp(() async {
      final subId = await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'ext-test',
              feedUrl: 'https://example.com/feed.xml',
              title: 'Podcast',
              artistName: 'Artist',
              subscribedAt: DateTime.now(),
            ),
          );
      episodeId = await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: subId,
              guid: 'ext-ep',
              title: 'Episode',
              audioUrl: 'https://example.com/ep.mp3',
            ),
          );
    });

    test('downloadStatus returns typed enum from int value', () async {
      final id = await db
          .into(db.downloadTasks)
          .insert(
            DownloadTasksCompanion.insert(
              episodeId: episodeId,
              audioUrl: 'https://example.com/ep.mp3',
              createdAt: DateTime.now(),
            ),
          );

      final task = await (db.select(
        db.downloadTasks,
      )..where((t) => t.id.equals(id))).getSingle();

      expect(task.downloadStatus, isA<DownloadStatusPending>());
    });

    test('progress returns null when totalBytes is null', () async {
      final id = await db
          .into(db.downloadTasks)
          .insert(
            DownloadTasksCompanion.insert(
              episodeId: episodeId,
              audioUrl: 'https://example.com/ep.mp3',
              createdAt: DateTime.now(),
            ),
          );

      final task = await (db.select(
        db.downloadTasks,
      )..where((t) => t.id.equals(id))).getSingle();

      expect(task.progress, isNull);
    });

    test('progress returns null when totalBytes is zero', () async {
      final id = await db
          .into(db.downloadTasks)
          .insert(
            DownloadTasksCompanion.insert(
              episodeId: episodeId,
              audioUrl: 'https://example.com/ep.mp3',
              createdAt: DateTime.now(),
            ),
          );

      await (db.update(db.downloadTasks)..where((t) => t.id.equals(id))).write(
        const DownloadTasksCompanion(totalBytes: Value(0)),
      );

      final task = await (db.select(
        db.downloadTasks,
      )..where((t) => t.id.equals(id))).getSingle();

      expect(task.progress, isNull);
    });

    test('progress returns correct ratio', () async {
      final id = await db
          .into(db.downloadTasks)
          .insert(
            DownloadTasksCompanion.insert(
              episodeId: episodeId,
              audioUrl: 'https://example.com/ep.mp3',
              createdAt: DateTime.now(),
            ),
          );

      await (db.update(db.downloadTasks)..where((t) => t.id.equals(id))).write(
        const DownloadTasksCompanion(
          downloadedBytes: Value(2500),
          totalBytes: Value(10000),
        ),
      );

      final task = await (db.select(
        db.downloadTasks,
      )..where((t) => t.id.equals(id))).getSingle();

      expect(task.progress, equals(0.25));
    });
  });

  group('FTS5 transcript search', () {
    late int transcriptId;

    setUp(() async {
      final subId = await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'fts-test',
              feedUrl: 'https://example.com/feed.xml',
              title: 'Podcast',
              artistName: 'Artist',
              subscribedAt: DateTime.now(),
            ),
          );
      final episodeId = await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: subId,
              guid: 'fts-ep',
              title: 'Episode',
              audioUrl: 'https://example.com/ep.mp3',
            ),
          );
      transcriptId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep.vtt',
              type: 'text/vtt',
            ),
          );
    });

    test('FTS5 table is populated via trigger on insert', () async {
      await db
          .into(db.transcriptSegments)
          .insert(
            TranscriptSegmentsCompanion.insert(
              transcriptId: transcriptId,
              startMs: 0,
              endMs: 5000,
              body: 'Hello world testing FTS',
            ),
          );

      final results = await db
          .customSelect(
            "SELECT rowid, body FROM transcript_segments_fts WHERE transcript_segments_fts MATCH 'Hello'",
          )
          .get();

      expect(results.length, equals(1));
      expect(results.first.read<String>('body'), contains('Hello'));
    });

    test('FTS5 table removes entry on segment delete', () async {
      final segId = await db
          .into(db.transcriptSegments)
          .insert(
            TranscriptSegmentsCompanion.insert(
              transcriptId: transcriptId,
              startMs: 0,
              endMs: 5000,
              body: 'Delete me from FTS',
            ),
          );

      // Delete the segment
      await (db.delete(
        db.transcriptSegments,
      )..where((t) => t.id.equals(segId))).go();

      final results = await db
          .customSelect(
            "SELECT rowid, body FROM transcript_segments_fts WHERE transcript_segments_fts MATCH 'Delete'",
          )
          .get();

      expect(results, isEmpty);
    });
  });
}
