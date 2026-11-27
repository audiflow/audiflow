import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart' show duplicateGuidKey;
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

final _published = DateTime.utc(2026, 11, 1);
final _dup = duplicateGuidKey('g1', 'https://example.com/old.mp3');

Episode _episode(
  String guid, {
  String audioUrl = 'https://example.com/a.mp3',
  DateTime? publishedAt,
  String? key,
}) => Episode()
  ..podcastId = 1
  ..guid = guid
  ..title = 'Episode'
  ..audioUrl = audioUrl
  ..publishedAt = publishedAt
  ..episodeKey = key;

EpisodeUserState _state(
  String key, {
  String podcastKey = 'pk',
  String? guid = 'g1',
  String? audioUrl = 'https://example.com/a.mp3',
  DateTime? publishedAt,
}) => EpisodeUserState()
  ..episodeKey = key
  ..podcastKey = podcastKey
  ..locatorGuid = guid
  ..locatorAudioUrl = audioUrl
  ..locatorPublishedAt = publishedAt;

void main() {
  group('locateEpisode', () {
    test('the same enclosure URL wins', () {
      final match = locateEpisode([
        _episode('g1', audioUrl: 'https://example.com/other.mp3', key: 'x'),
        _episode('g9', key: 'y'),
      ], _state('f'));

      check(match?.episodeKey).equals('y');
    });

    test('a moved enclosure is found by guid and date', () {
      final match = locateEpisode([
        _episode(
          _dup,
          audioUrl: 'https://cdn.example.com/1.mp3',
          publishedAt: DateTime.utc(2026),
          key: 'old',
        ),
        _episode(
          'g1',
          audioUrl: 'https://cdn.example.com/2.mp3',
          publishedAt: _published,
          key: 'same',
        ),
      ], _state('f', guid: _dup, publishedAt: _published));

      check(match?.episodeKey).equals('same');
    });

    test('undated, the same storage guid comes first', () {
      final match = locateEpisode([
        _episode('g1', audioUrl: 'https://cdn.example.com/1.mp3', key: 'a'),
        _episode(_dup, audioUrl: 'https://cdn.example.com/2.mp3', key: 'b'),
      ], _state('f', guid: _dup));

      check(match?.episodeKey).equals('b');
    });

    test('a different date is not the same episode', () {
      final match = locateEpisode([
        _episode(
          'g1',
          audioUrl: 'https://cdn.example.com/1.mp3',
          publishedAt: DateTime.utc(2026),
          key: 'a',
        ),
      ], _state('f', publishedAt: _published));

      check(match).isNull();
    });
  });

  group('KeyReconciler', () {
    late Isar isar;
    late KeyReconciler reconciler;
    late int podcastId;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await openTestIsar(isarSchemas);
      reconciler = KeyReconciler(isar);
      await isar.writeTxn(
        () => isar.syncMetas.put(SyncMeta()..historyId = 'h'),
      );
      podcastId = await isar.writeTxn(
        () => isar.subscriptions.put(
          Subscription()
            ..itunesId = 'it1'
            ..feedUrl = 'https://example.com/show.xml'
            ..title = 'Show'
            ..artistName = 'Host'
            ..subscribedAt = DateTime.utc(2026)
            ..podcastKey = 'pk',
        ),
      );
      await isar.writeTxn(
        () => isar.episodes.put(
          _episode('g1', key: 'local')..podcastId = podcastId,
        ),
      );
    });

    tearDown(() => isar.close(deleteFromDisk: true));

    Future<void> put(EpisodeUserState state) =>
        isar.writeTxn(() => isar.episodeUserStates.put(state));

    test('merges both rows field by field, counters by maximum', () async {
      await put(
        _state('local')
          ..positionMs = 100
          ..positionHlc = 10
          ..favoritedAt = DateTime.utc(2026, 2)
          ..favoritedAtHlc = 30
          ..counters = [
            EpisodePlayCounters()
              ..deviceId = 'd1'
              ..listenedMs = 500,
          ],
      );
      await put(
        _state('foreign')
          ..positionMs = 900
          ..positionHlc = 20
          ..favoritedAt = DateTime.utc(2026)
          ..favoritedAtHlc = 5
          ..counters = [
            EpisodePlayCounters()
              ..deviceId = 'd1'
              ..listenedMs = 300,
            EpisodePlayCounters()
              ..deviceId = 'd2'
              ..listenedMs = 700,
          ],
      );

      final result = await reconciler.reconcile();

      check(result.episodeKeys).deepEquals({'local'});
      check(await isar.episodeUserStates.count()).equals(1);
      final joined = (await isar.episodeUserStates.getByEpisodeKey('local'))!;
      check(joined.positionMs).equals(900);
      check(joined.favoritedAt?.toUtc()).equals(DateTime.utc(2026, 2));
      check({
        for (final c in joined.counters) c.deviceId: c.listenedMs,
      }).deepEquals({'d1': 500, 'd2': 700});
    });

    test('moves queue entries and records the alias', () async {
      await put(_state('foreign')..positionMs = 1);
      await isar.writeTxn(
        () => isar.queueEntrys.put(
          QueueEntry()
            ..entryId = 'q1'
            ..episodeKey = 'foreign'
            ..rank = 'a'
            ..addedAt = DateTime.utc(2026),
        ),
      );

      final result = await reconciler.reconcile();

      check(result.queueChanged).isTrue();
      // Kept until the queue is projected again, in case that fails.
      check(
        (await isar.syncMetas.get(
          SyncMeta.singletonId,
        ))?.queueProjectionPending,
      ).equals(true);
      check(
        (await isar.queueEntrys.getByEntryId('q1'))?.episodeKey,
      ).equals('local');
      check(
        (await isar.syncKeyAlias.getByKindForeignKey(
          SyncKeyAlias.episode,
          'foreign',
        ))?.localKey,
      ).equals('local');
    });

    test('a later queue entry under the old key is moved too', () async {
      await put(_state('foreign'));
      await reconciler.reconcile();
      await isar.writeTxn(
        () => isar.queueEntrys.put(
          QueueEntry()
            ..entryId = 'q2'
            ..episodeKey = 'foreign'
            ..rank = 'b'
            ..addedAt = DateTime.utc(2026),
        ),
      );

      await reconciler.reconcile(episodeKeys: {});

      check(
        (await isar.queueEntrys.getByEntryId('q2'))?.episodeKey,
      ).equals('local');
    });

    test('leaves a row whose episode is not in the catalog', () async {
      await put(_state('unknown', guid: 'g9', audioUrl: 'https://x/9.mp3'));

      final result = await reconciler.reconcile();

      check(result.isEmpty).isTrue();
      check(
        await isar.episodeUserStates.getByEpisodeKey('unknown'),
      ).isNotNull();
    });

    test('joins a show by feed URL with its station members', () async {
      await isar.writeTxn(() async {
        await isar.podcastUserStates.put(
          PodcastUserState()
            ..podcastKey = 'pk-other'
            ..subscribed = true
            ..subscribedHlc = 50
            ..feedUrl = 'http://EXAMPLE.com/show.xml/'
            ..feedUrlHlc = 50,
        );
        await isar.stationMembers.put(
          StationMember()
            ..stationId = 's1'
            ..podcastKey = 'pk-other',
        );
      });
      await put(_state('foreign', podcastKey: 'pk-other'));

      final result = await reconciler.reconcile();

      check(result.podcastsJoined).isTrue();
      check(
        await isar.podcastUserStates.getByPodcastKey('pk'),
      ).isNotNull().has((s) => s.subscribed, 'subscribed').isTrue();
      check(await isar.podcastUserStates.getByPodcastKey('pk-other')).isNull();
      check(
        await isar.stationMembers.getByStationIdPodcastKey('s1', 'pk'),
      ).isNotNull();
      // The episode of the other key followed the show, then its locator.
      check(
        await isar.episodeUserStates.getByEpisodeKey('local'),
      ).isNotNull().has((s) => s.podcastKey, 'podcastKey').equals('pk');
    });

    test('translate renames keys this device knows otherwise', () async {
      await isar.writeTxn(
        () => isar.syncKeyAlias.putAll([
          SyncKeyAlias()
            ..kind = SyncKeyAlias.podcast
            ..foreignKey = 'pk-other'
            ..localKey = 'pk',
          SyncKeyAlias()
            ..kind = SyncKeyAlias.episode
            ..foreignKey = 'foreign'
            ..localKey = 'local',
        ]),
      );
      final bytes = Uint8List(0);

      final sections = await reconciler.translate({
        'podcast': [SnapshotRow('pk-other', bytes)],
        'episode': [SnapshotRow('foreign', bytes), SnapshotRow('other', bytes)],
        'episodeCounter': [
          SnapshotRow(compositeKey(['foreign', 'd1']), bytes),
        ],
        'stationMember': [
          SnapshotRow(compositeKey(['s1', 'pk-other']), bytes),
        ],
      });

      check([
        for (final rows in sections.values) ...rows.map((r) => r.key),
      ]).deepEquals([
        'pk',
        'local',
        'other',
        compositeKey(['local', 'd1']),
        compositeKey(['s1', 'pk']),
      ]);
    });
  });
}
