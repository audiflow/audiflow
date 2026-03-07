import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late int podcastId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    podcastId = await db
        .into(db.subscriptions)
        .insert(
          SubscriptionsCompanion.insert(
            itunesId: 'sp-test',
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

  group('SmartPlaylists table', () {
    test('insert and read smart playlist', () async {
      await db
          .into(db.smartPlaylists)
          .insert(
            SmartPlaylistsCompanion.insert(
              podcastId: podcastId,
              playlistNumber: 1,
              displayName: 'Season 1',
              sortKey: 10,
              resolverType: 'rss',
            ),
          );

      final results = await (db.select(
        db.smartPlaylists,
      )..where((t) => t.podcastId.equals(podcastId))).get();

      expect(results.length, equals(1));
      final playlist = results.first;
      expect(playlist.podcastId, equals(podcastId));
      expect(playlist.playlistNumber, equals(1));
      expect(playlist.displayName, equals('Season 1'));
      expect(playlist.sortKey, equals(10));
      expect(playlist.resolverType, equals('rss'));
    });

    test('insert with all optional fields', () async {
      await db
          .into(db.smartPlaylists)
          .insert(
            SmartPlaylistsCompanion.insert(
              podcastId: podcastId,
              playlistNumber: 2,
              displayName: 'Season 2',
              sortKey: 20,
              resolverType: 'category',
              thumbnailUrl: const Value('https://example.com/thumb.jpg'),
              yearGrouped: const Value(true),
              contentType: const Value('groups'),
              yearHeaderMode: const Value('firstEpisode'),
              episodeYearHeaders: const Value(true),
            ),
          );

      final playlist =
          await (db.select(db.smartPlaylists)..where(
                (t) =>
                    t.podcastId.equals(podcastId) & t.playlistNumber.equals(2),
              ))
              .getSingle();

      expect(playlist.thumbnailUrl, equals('https://example.com/thumb.jpg'));
      expect(playlist.yearGrouped, isTrue);
      expect(playlist.contentType, equals('groups'));
      expect(playlist.yearHeaderMode, equals('firstEpisode'));
      expect(playlist.episodeYearHeaders, isTrue);
    });

    test('default values for optional columns', () async {
      await db
          .into(db.smartPlaylists)
          .insert(
            SmartPlaylistsCompanion.insert(
              podcastId: podcastId,
              playlistNumber: 3,
              displayName: 'Defaults',
              sortKey: 30,
              resolverType: 'rss',
            ),
          );

      final playlist =
          await (db.select(db.smartPlaylists)..where(
                (t) =>
                    t.podcastId.equals(podcastId) & t.playlistNumber.equals(3),
              ))
              .getSingle();

      expect(playlist.thumbnailUrl, isNull);
      expect(playlist.yearGrouped, isFalse);
      expect(playlist.contentType, equals('episodes'));
      expect(playlist.yearHeaderMode, equals('none'));
      expect(playlist.episodeYearHeaders, isFalse);
    });

    test('composite primary key enforces uniqueness', () async {
      await db
          .into(db.smartPlaylists)
          .insert(
            SmartPlaylistsCompanion.insert(
              podcastId: podcastId,
              playlistNumber: 1,
              displayName: 'First',
              sortKey: 10,
              resolverType: 'rss',
            ),
          );

      expect(
        () => db
            .into(db.smartPlaylists)
            .insert(
              SmartPlaylistsCompanion.insert(
                podcastId: podcastId,
                playlistNumber: 1,
                displayName: 'Duplicate',
                sortKey: 20,
                resolverType: 'rss',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('allows same playlistNumber for different podcasts', () async {
      final secondPodcastId = await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'sp-test-2',
              feedUrl: 'https://example.com/feed2.xml',
              title: 'Second Podcast',
              artistName: 'Artist 2',
              subscribedAt: DateTime.now(),
            ),
          );

      await db
          .into(db.smartPlaylists)
          .insert(
            SmartPlaylistsCompanion.insert(
              podcastId: podcastId,
              playlistNumber: 1,
              displayName: 'Podcast 1 Season 1',
              sortKey: 10,
              resolverType: 'rss',
            ),
          );

      await db
          .into(db.smartPlaylists)
          .insert(
            SmartPlaylistsCompanion.insert(
              podcastId: secondPodcastId,
              playlistNumber: 1,
              displayName: 'Podcast 2 Season 1',
              sortKey: 10,
              resolverType: 'category',
            ),
          );

      final all = await db.select(db.smartPlaylists).get();
      expect(all.length, equals(2));
    });

    test('update smart playlist fields', () async {
      await db
          .into(db.smartPlaylists)
          .insert(
            SmartPlaylistsCompanion.insert(
              podcastId: podcastId,
              playlistNumber: 1,
              displayName: 'Old Name',
              sortKey: 10,
              resolverType: 'rss',
            ),
          );

      await (db.update(db.smartPlaylists)..where(
            (t) => t.podcastId.equals(podcastId) & t.playlistNumber.equals(1),
          ))
          .write(
            const SmartPlaylistsCompanion(
              displayName: Value('New Name'),
              sortKey: Value(99),
              thumbnailUrl: Value('https://example.com/new.jpg'),
            ),
          );

      final updated =
          await (db.select(db.smartPlaylists)..where(
                (t) =>
                    t.podcastId.equals(podcastId) & t.playlistNumber.equals(1),
              ))
              .getSingle();

      expect(updated.displayName, equals('New Name'));
      expect(updated.sortKey, equals(99));
      expect(updated.thumbnailUrl, equals('https://example.com/new.jpg'));
    });

    test('delete smart playlist', () async {
      await db
          .into(db.smartPlaylists)
          .insert(
            SmartPlaylistsCompanion.insert(
              podcastId: podcastId,
              playlistNumber: 1,
              displayName: 'Delete Me',
              sortKey: 10,
              resolverType: 'rss',
            ),
          );

      final deleted =
          await (db.delete(db.smartPlaylists)..where(
                (t) =>
                    t.podcastId.equals(podcastId) & t.playlistNumber.equals(1),
              ))
              .go();

      expect(deleted, equals(1));

      final remaining = await (db.select(
        db.smartPlaylists,
      )..where((t) => t.podcastId.equals(podcastId))).get();
      expect(remaining, isEmpty);
    });

    test('table name is "seasons" for legacy compatibility', () {
      expect(db.smartPlaylists.actualTableName, equals('seasons'));
    });

    test('insert with playlistNumber 0 for extras', () async {
      await db
          .into(db.smartPlaylists)
          .insert(
            SmartPlaylistsCompanion.insert(
              podcastId: podcastId,
              playlistNumber: 0,
              displayName: 'Extras',
              sortKey: 0,
              resolverType: 'rss',
            ),
          );

      final playlist =
          await (db.select(db.smartPlaylists)..where(
                (t) =>
                    t.podcastId.equals(podcastId) & t.playlistNumber.equals(0),
              ))
              .getSingle();

      expect(playlist.displayName, equals('Extras'));
    });
  });
}
