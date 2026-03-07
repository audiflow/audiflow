import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/common/database/app_database.dart'
    show SmartPlaylistGroupEntity, SmartPlaylistGroupsCompanion;
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
            itunesId: 'spg-test',
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

  group('SmartPlaylistGroups table', () {
    test('insert and read group', () async {
      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-1',
              groupId: 'group-1',
              displayName: 'Group 1',
              sortKey: 1,
              episodeIds: '[1, 2, 3]',
            ),
          );

      final results = await (db.select(
        db.smartPlaylistGroups,
      )..where((t) => t.podcastId.equals(podcastId))).get();

      expect(results.length, equals(1));
      final group = results.first;
      expect(group.podcastId, equals(podcastId));
      expect(group.playlistId, equals('playlist-1'));
      expect(group.groupId, equals('group-1'));
      expect(group.displayName, equals('Group 1'));
      expect(group.sortKey, equals(1));
      expect(group.episodeIds, equals('[1, 2, 3]'));
    });

    test('insert with all optional fields', () async {
      final earliest = DateTime(2023, 1, 1);
      final latest = DateTime(2023, 12, 31);

      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-2',
              groupId: 'group-2',
              displayName: 'Full Group',
              sortKey: 2,
              episodeIds: '[4, 5]',
              thumbnailUrl: const Value('https://example.com/thumb.jpg'),
              yearOverride: const Value('2023'),
              earliestDate: Value(earliest),
              latestDate: Value(latest),
              totalDurationMs: const Value(7200000),
              episodeYearHeaders: const Value(true),
            ),
          );

      final group =
          await (db.select(db.smartPlaylistGroups)..where(
                (t) =>
                    t.podcastId.equals(podcastId) & t.groupId.equals('group-2'),
              ))
              .getSingle();

      expect(group.thumbnailUrl, equals('https://example.com/thumb.jpg'));
      expect(group.yearOverride, equals('2023'));
      expect(group.earliestDate, equals(earliest));
      expect(group.latestDate, equals(latest));
      expect(group.totalDurationMs, equals(7200000));
      expect(group.episodeYearHeaders, isTrue);
    });

    test('nullable fields default to null', () async {
      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-3',
              groupId: 'group-3',
              displayName: 'Minimal',
              sortKey: 3,
              episodeIds: '[]',
            ),
          );

      final group =
          await (db.select(db.smartPlaylistGroups)..where(
                (t) =>
                    t.podcastId.equals(podcastId) & t.groupId.equals('group-3'),
              ))
              .getSingle();

      expect(group.thumbnailUrl, isNull);
      expect(group.yearOverride, isNull);
      expect(group.earliestDate, isNull);
      expect(group.latestDate, isNull);
      expect(group.totalDurationMs, isNull);
      expect(group.episodeYearHeaders, isNull);
    });

    test('composite primary key enforces uniqueness', () async {
      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-1',
              groupId: 'group-1',
              displayName: 'First',
              sortKey: 1,
              episodeIds: '[1]',
            ),
          );

      expect(
        () => db
            .into(db.smartPlaylistGroups)
            .insert(
              SmartPlaylistGroupsCompanion.insert(
                podcastId: podcastId,
                playlistId: 'playlist-1',
                groupId: 'group-1',
                displayName: 'Duplicate',
                sortKey: 2,
                episodeIds: '[2]',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('allows same groupId across different playlists', () async {
      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-a',
              groupId: 'shared-group',
              displayName: 'Group A',
              sortKey: 1,
              episodeIds: '[1]',
            ),
          );

      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-b',
              groupId: 'shared-group',
              displayName: 'Group B',
              sortKey: 1,
              episodeIds: '[2]',
            ),
          );

      final all = await (db.select(
        db.smartPlaylistGroups,
      )..where((t) => t.podcastId.equals(podcastId))).get();
      expect(all.length, equals(2));
    });

    test('allows same groupId across different podcasts', () async {
      final secondPodcastId = await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'spg-test-2',
              feedUrl: 'https://example.com/feed2.xml',
              title: 'Second Podcast',
              artistName: 'Artist 2',
              subscribedAt: DateTime.now(),
            ),
          );

      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-1',
              groupId: 'group-1',
              displayName: 'Podcast 1 Group',
              sortKey: 1,
              episodeIds: '[1]',
            ),
          );

      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: secondPodcastId,
              playlistId: 'playlist-1',
              groupId: 'group-1',
              displayName: 'Podcast 2 Group',
              sortKey: 1,
              episodeIds: '[2]',
            ),
          );

      final all = await db.select(db.smartPlaylistGroups).get();
      expect(all.length, equals(2));
    });

    test('update group fields', () async {
      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-1',
              groupId: 'group-1',
              displayName: 'Old Name',
              sortKey: 1,
              episodeIds: '[1]',
            ),
          );

      await (db.update(db.smartPlaylistGroups)..where(
            (t) =>
                t.podcastId.equals(podcastId) &
                t.playlistId.equals('playlist-1') &
                t.groupId.equals('group-1'),
          ))
          .write(
            const SmartPlaylistGroupsCompanion(
              displayName: Value('Updated Name'),
              sortKey: Value(99),
              totalDurationMs: Value(5000),
            ),
          );

      final updated =
          await (db.select(db.smartPlaylistGroups)..where(
                (t) =>
                    t.podcastId.equals(podcastId) & t.groupId.equals('group-1'),
              ))
              .getSingle();

      expect(updated.displayName, equals('Updated Name'));
      expect(updated.sortKey, equals(99));
      expect(updated.totalDurationMs, equals(5000));
    });

    test('delete group', () async {
      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-1',
              groupId: 'group-1',
              displayName: 'Delete Me',
              sortKey: 1,
              episodeIds: '[]',
            ),
          );

      final deleted =
          await (db.delete(db.smartPlaylistGroups)..where(
                (t) =>
                    t.podcastId.equals(podcastId) & t.groupId.equals('group-1'),
              ))
              .go();

      expect(deleted, equals(1));

      final remaining = await (db.select(
        db.smartPlaylistGroups,
      )..where((t) => t.podcastId.equals(podcastId))).get();
      expect(remaining, isEmpty);
    });

    test('delete all groups for a podcast', () async {
      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-1',
              groupId: 'group-1',
              displayName: 'Group 1',
              sortKey: 1,
              episodeIds: '[1]',
            ),
          );
      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-1',
              groupId: 'group-2',
              displayName: 'Group 2',
              sortKey: 2,
              episodeIds: '[2]',
            ),
          );
      await db
          .into(db.smartPlaylistGroups)
          .insert(
            SmartPlaylistGroupsCompanion.insert(
              podcastId: podcastId,
              playlistId: 'playlist-1',
              groupId: 'group-3',
              displayName: 'Group 3',
              sortKey: 3,
              episodeIds: '[3]',
            ),
          );

      final deleted = await (db.delete(
        db.smartPlaylistGroups,
      )..where((t) => t.podcastId.equals(podcastId))).go();

      expect(deleted, equals(3));
    });
  });
}
