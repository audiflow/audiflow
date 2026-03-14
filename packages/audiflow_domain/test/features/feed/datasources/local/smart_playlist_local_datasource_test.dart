import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

void main() {
  late Isar isar;
  late SmartPlaylistLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      [SmartPlaylistEntitySchema, SmartPlaylistGroupEntitySchema],
      directory: '',
      name: 'test_${DateTime.now().microsecondsSinceEpoch}',
    );
    datasource = SmartPlaylistLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  SmartPlaylistEntity makeEntity({
    int podcastId = 1,
    required int playlistNumber,
    String? displayName,
    int? sortKey,
    String resolverType = 'rss',
  }) {
    return SmartPlaylistEntity()
      ..podcastId = podcastId
      ..playlistNumber = playlistNumber
      ..displayName = displayName ?? 'Playlist $playlistNumber'
      ..sortKey = sortKey ?? playlistNumber
      ..resolverType = resolverType;
  }

  group('upsert', () {
    test('inserts a new smart playlist', () async {
      await datasource.upsert(makeEntity(playlistNumber: 1));

      final results = await datasource.getByPodcastId(1);
      expect(results, hasLength(1));
      expect(results.first.playlistNumber, 1);
      expect(results.first.displayName, 'Playlist 1');
    });

    test('updates existing smart playlist on conflict', () async {
      await datasource.upsert(makeEntity(playlistNumber: 1));
      await datasource.upsert(
        makeEntity(playlistNumber: 1, displayName: 'Updated Name', sortKey: 99),
      );

      final results = await datasource.getByPodcastId(1);
      expect(results, hasLength(1));
      expect(results.first.displayName, 'Updated Name');
      expect(results.first.sortKey, 99);
    });
  });

  group('upsertAllForPodcast', () {
    test('replaces all playlists for a podcast atomically', () async {
      await datasource.upsert(makeEntity(playlistNumber: 1));
      await datasource.upsert(makeEntity(playlistNumber: 2));

      await datasource.upsertAllForPodcast(1, [
        makeEntity(playlistNumber: 10, displayName: 'New Playlist A'),
        makeEntity(playlistNumber: 20, displayName: 'New Playlist B'),
        makeEntity(playlistNumber: 30, displayName: 'New Playlist C'),
      ]);

      final results = await datasource.getByPodcastId(1);
      expect(results, hasLength(3));
      expect(results[0].playlistNumber, 10);
      expect(results[1].playlistNumber, 20);
      expect(results[2].playlistNumber, 30);
    });

    test('deletes all when empty list', () async {
      await datasource.upsert(makeEntity(playlistNumber: 1));
      await datasource.upsert(makeEntity(playlistNumber: 2));

      await datasource.upsertAllForPodcast(1, []);

      final results = await datasource.getByPodcastId(1);
      expect(results, isEmpty);
    });

    test('does not affect other podcasts', () async {
      await datasource.upsert(makeEntity(podcastId: 1, playlistNumber: 1));
      await datasource.upsert(makeEntity(podcastId: 2, playlistNumber: 1));

      await datasource.upsertAllForPodcast(1, [makeEntity(playlistNumber: 99)]);

      final podcast1 = await datasource.getByPodcastId(1);
      final podcast2 = await datasource.getByPodcastId(2);
      expect(podcast1, hasLength(1));
      expect(podcast1.first.playlistNumber, 99);
      expect(podcast2, hasLength(1));
      expect(podcast2.first.playlistNumber, 1);
    });
  });

  group('getByPodcastId', () {
    test('returns empty list for non-existent podcast', () async {
      final results = await datasource.getByPodcastId(999);
      expect(results, isEmpty);
    });

    test('returns playlists ordered by sortKey', () async {
      await datasource.upsert(makeEntity(playlistNumber: 3, sortKey: 30));
      await datasource.upsert(makeEntity(playlistNumber: 1, sortKey: 10));
      await datasource.upsert(makeEntity(playlistNumber: 2, sortKey: 20));

      final results = await datasource.getByPodcastId(1);
      expect(results, hasLength(3));
      expect(results[0].sortKey, 10);
      expect(results[1].sortKey, 20);
      expect(results[2].sortKey, 30);
    });
  });

  group('watchByPodcastId', () {
    test('emits initial state', () async {
      await datasource.upsert(makeEntity(playlistNumber: 1));

      final result = await datasource.watchByPodcastId(1).first;
      expect(result, hasLength(1));
      expect(result.first.playlistNumber, 1);
    });
  });

  group('getByPodcastIdAndPlaylistNumber', () {
    test('returns matching playlist', () async {
      await datasource.upsert(makeEntity(playlistNumber: 5));

      final result = await datasource.getByPodcastIdAndPlaylistNumber(1, 5);
      expect(result, isNotNull);
      expect(result!.playlistNumber, 5);
    });

    test('returns null for non-existent playlist', () async {
      final result = await datasource.getByPodcastIdAndPlaylistNumber(1, 999);
      expect(result, isNull);
    });

    test('returns null for wrong podcast', () async {
      await datasource.upsert(makeEntity(playlistNumber: 1));

      final result = await datasource.getByPodcastIdAndPlaylistNumber(999, 1);
      expect(result, isNull);
    });
  });

  group('deleteByPodcastId', () {
    test('deletes all playlists for a podcast', () async {
      await datasource.upsert(makeEntity(playlistNumber: 1));
      await datasource.upsert(makeEntity(playlistNumber: 2));

      final deleted = await datasource.deleteByPodcastId(1);
      expect(deleted, 2);

      final results = await datasource.getByPodcastId(1);
      expect(results, isEmpty);
    });

    test('returns 0 when no playlists exist', () async {
      final deleted = await datasource.deleteByPodcastId(999);
      expect(deleted, 0);
    });
  });

  group('countByPodcastId', () {
    test('returns 0 for empty podcast', () async {
      final count = await datasource.countByPodcastId(1);
      expect(count, 0);
    });

    test('returns correct count', () async {
      await datasource.upsert(makeEntity(playlistNumber: 1));
      await datasource.upsert(makeEntity(playlistNumber: 2));
      await datasource.upsert(makeEntity(playlistNumber: 3));

      final count = await datasource.countByPodcastId(1);
      expect(count, 3);
    });
  });

  group('getGroupsByPlaylist', () {
    test('returns empty list when no groups', () async {
      final groups = await datasource.getGroupsByPlaylist(1, 'playlist-1');
      expect(groups, isEmpty);
    });

    test('returns groups ordered by sortKey', () async {
      await datasource.upsertGroupsForPlaylist(1, 'playlist-1', [
        SmartPlaylistGroupEntity()
          ..podcastId = 1
          ..playlistId = 'playlist-1'
          ..groupId = 'group-c'
          ..displayName = 'Group C'
          ..sortKey = 30
          ..episodeIds = '1,2',
        SmartPlaylistGroupEntity()
          ..podcastId = 1
          ..playlistId = 'playlist-1'
          ..groupId = 'group-a'
          ..displayName = 'Group A'
          ..sortKey = 10
          ..episodeIds = '3,4',
        SmartPlaylistGroupEntity()
          ..podcastId = 1
          ..playlistId = 'playlist-1'
          ..groupId = 'group-b'
          ..displayName = 'Group B'
          ..sortKey = 20
          ..episodeIds = '5',
      ]);

      final groups = await datasource.getGroupsByPlaylist(1, 'playlist-1');
      expect(groups, hasLength(3));
      expect(groups[0].sortKey, 10);
      expect(groups[1].sortKey, 20);
      expect(groups[2].sortKey, 30);
    });
  });

  group('upsertGroupsForPlaylist', () {
    test('replaces groups for a playlist', () async {
      await datasource.upsertGroupsForPlaylist(1, 'playlist-1', [
        SmartPlaylistGroupEntity()
          ..podcastId = 1
          ..playlistId = 'playlist-1'
          ..groupId = 'old-group'
          ..displayName = 'Old Group'
          ..sortKey = 1
          ..episodeIds = '1',
      ]);

      await datasource.upsertGroupsForPlaylist(1, 'playlist-1', [
        SmartPlaylistGroupEntity()
          ..podcastId = 1
          ..playlistId = 'playlist-1'
          ..groupId = 'new-group-1'
          ..displayName = 'New Group 1'
          ..sortKey = 1
          ..episodeIds = '10,11',
        SmartPlaylistGroupEntity()
          ..podcastId = 1
          ..playlistId = 'playlist-1'
          ..groupId = 'new-group-2'
          ..displayName = 'New Group 2'
          ..sortKey = 2
          ..episodeIds = '12',
      ]);

      final groups = await datasource.getGroupsByPlaylist(1, 'playlist-1');
      expect(groups, hasLength(2));
      expect(groups[0].groupId, 'new-group-1');
      expect(groups[1].groupId, 'new-group-2');
    });

    test('handles empty list by deleting all', () async {
      await datasource.upsertGroupsForPlaylist(1, 'playlist-1', [
        SmartPlaylistGroupEntity()
          ..podcastId = 1
          ..playlistId = 'playlist-1'
          ..groupId = 'group-1'
          ..displayName = 'Group 1'
          ..sortKey = 1
          ..episodeIds = '1',
      ]);

      await datasource.upsertGroupsForPlaylist(1, 'playlist-1', []);

      final groups = await datasource.getGroupsByPlaylist(1, 'playlist-1');
      expect(groups, isEmpty);
    });

    test('does not affect groups of other playlists', () async {
      await datasource.upsertGroupsForPlaylist(1, 'playlist-1', [
        SmartPlaylistGroupEntity()
          ..podcastId = 1
          ..playlistId = 'playlist-1'
          ..groupId = 'group-a'
          ..displayName = 'Group A'
          ..sortKey = 1
          ..episodeIds = '1',
      ]);
      await datasource.upsertGroupsForPlaylist(1, 'playlist-2', [
        SmartPlaylistGroupEntity()
          ..podcastId = 1
          ..playlistId = 'playlist-2'
          ..groupId = 'group-b'
          ..displayName = 'Group B'
          ..sortKey = 1
          ..episodeIds = '2',
      ]);

      await datasource.upsertGroupsForPlaylist(1, 'playlist-1', [
        SmartPlaylistGroupEntity()
          ..podcastId = 1
          ..playlistId = 'playlist-1'
          ..groupId = 'group-new'
          ..displayName = 'Group New'
          ..sortKey = 1
          ..episodeIds = '3',
      ]);

      final groups1 = await datasource.getGroupsByPlaylist(1, 'playlist-1');
      final groups2 = await datasource.getGroupsByPlaylist(1, 'playlist-2');
      expect(groups1, hasLength(1));
      expect(groups1.first.groupId, 'group-new');
      expect(groups2, hasLength(1));
      expect(groups2.first.groupId, 'group-b');
    });
  });
}
