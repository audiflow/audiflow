import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  const now = 1800000000000;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar(isarSchemas);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  int hlc(int millis) => Hlc(millis, 0).packed;

  Future<SnapshotFile> exportFrom(Isar source) async {
    final exported = await SnapshotExporter(source).export();
    return readSnapshotFile(
      encodeSnapshotFile(
        body: exported.body,
        createdAt: DateTime.utc(2026),
        historyId: exported.historyId,
        appVersion: '2.3.0',
        platform: 'ios',
        counts: exported.counts,
      ),
    );
  }

  SnapshotFile fileOf(
    Map<String, List<SnapshotRow>> sections, {
    String historyId = 'other',
  }) => SnapshotFile(
    SnapshotHeader(
      formatVersion: 1,
      createdAt: DateTime.utc(2026),
      historyId: historyId,
      appVersion: '2.3.0',
      platform: 'android',
      counts: const SnapshotCounts(
        podcasts: 0,
        episodes: 0,
        queue: 0,
        stations: 0,
      ),
      payloadSha256: '',
    ),
    SnapshotBody(sections),
  );

  SnapshotRow rowOf(String key, Map<int, (Object?, int?)> fields) {
    final w = ProtoWriter();
    for (final MapEntry(key: id, value: (value, h)) in fields.entries) {
      w.writeBytes(id, encodeValue(value, hlc: h));
    }
    return SnapshotRow(key, w.takeBytes());
  }

  SnapshotMerger merger([Isar? target]) =>
      SnapshotMerger(target ?? isar, nowMillis: () => now);

  Future<void> seed(Isar target) => target.writeTxn(() async {
    await target.syncMetas.put(SyncMeta()..historyId = 'h1');
    await target.podcastUserStates.put(
      PodcastUserState()
        ..podcastKey = 'pk'
        ..subscribed = true
        ..subscribedHlc = hlc(100)
        ..feedUrl = 'https://example.com/feed'
        ..feedUrlHlc = hlc(100)
        ..speed = 1.5
        ..hasAudio = true
        ..hasAudioHlc = hlc(101)
        ..speedHlc = hlc(101)
        ..playOrders = [
          PlayOrderEntry()
            ..playlistId = 'pl'
            ..order = 'oldestFirst'
            ..hlc = hlc(102),
        ],
    );
    await target.episodeUserStates.put(
      EpisodeUserState()
        ..episodeKey = 'ek'
        ..podcastKey = 'pk'
        ..hasPlayback = true
        ..hasPlaybackHlc = hlc(103)
        ..positionMs = 1200
        ..positionHlc = hlc(103)
        ..favoritedAt = DateTime.utc(2026, 1, 2)
        ..favoritedAtHlc = hlc(104)
        ..counters = [
          EpisodePlayCounters()
            ..deviceId = 'd1'
            ..playCount = 3
            ..listenedMs = 5000,
        ],
    );
    await target.queueEntrys.putAll([
      QueueEntry()
        ..entryId = 'q1'
        ..episodeKey = 'ek'
        ..rank = 'a'
        ..rankHlc = hlc(105),
      QueueEntry()
        ..entryId = 'q2'
        ..episodeKey = 'ek'
        ..deleted = true
        ..deletedHlc = hlc(106),
    ]);
    await target.stationStates.put(
      StationState()
        ..stationId = 's1'
        ..name = 'Morning'
        ..nameHlc = hlc(107),
    );
    await target.stationMembers.put(
      StationMember()
        ..stationId = 's1'
        ..podcastKey = 'pk'
        ..episodeLimit = 3
        ..episodeLimitHlc = hlc(108),
    );
    await target.syncedSettings.put(
      SyncedSetting()
        ..key = 'settings_playback_speed'
        ..value = '1.25'
        ..hlc = hlc(109),
    );
  });

  test('round trips into an empty database', () async {
    final source = await openTestIsar(isarSchemas);
    addTearDown(() => source.close(deleteFromDisk: true));
    await seed(source);

    final result = await merger().merge(await exportFrom(source));

    check(result.sameHistory).isTrue();
    check(
      (await isar.syncMetas.get(SyncMeta.singletonId))!.historyId,
    ).equals('h1');
    final podcast = (await isar.podcastUserStates.getByPodcastKey('pk'))!;
    check(podcast.subscribed).isTrue();
    check(podcast.speed).equals(1.5);
    check(podcast.speedHlc).equals(hlc(101));
    check(podcast.playOrders.single.order).equals('oldestFirst');
    final episode = (await isar.episodeUserStates.getByEpisodeKey('ek'))!;
    check(episode.podcastKey).equals('pk');
    check(episode.positionMs).equals(1200);
    check(episode.favoritedAt!.toUtc()).equals(DateTime.utc(2026, 1, 2));
    check(episode.counters.single.playCount).equals(3);
    check((await isar.queueEntrys.getByEntryId('q2'))!.deleted).isTrue();
    check(
      (await isar.stationStates.getByStationId('s1'))!.name,
    ).equals('Morning');
    check(
      (await isar.stationMembers.getByStationIdPodcastKey(
        's1',
        'pk',
      ))!.episodeLimit,
    ).equals(3);
    check(
      (await isar.syncedSettings.getByKey('settings_playback_speed'))!.value,
    ).equals('1.25');

    // Exporting again gives the same rows: nothing was lost on the way.
    final again = await SnapshotExporter(isar).export();
    final original = await SnapshotExporter(source).export();
    for (final name in original.body.sections.keys) {
      check(
        again.body.sections[name]!.map((r) => r.key).toList(),
        because: name,
      ).unorderedEquals(original.body.sections[name]!.map((r) => r.key));
    }
  });

  // Written by the first version of the format. It must keep reading, and
  // keep meaning the same, in every later version: never regenerate it.
  test('the v1 fixture file still restores', () async {
    final bytes = File(
      'test/fixtures/snapshot/v1.audiflow-backup',
    ).readAsBytesSync();
    final file = readSnapshotFile(bytes);
    check(file.header.historyId).equals('fixture-history');

    final result = await merger().merge(file);

    check(result.podcastInfo['pk1']!.title).equals('Example Show');
    final podcast = (await isar.podcastUserStates.getByPodcastKey('pk1'))!;
    check(podcast.subscribed).isTrue();
    check(podcast.speed).equals(1.5);
    final episode = (await isar.episodeUserStates.getByEpisodeKey('ek1'))!;
    check(episode.positionMs).equals(61000);
    check(episode.counters.single.deviceId).equals('device-a');
    check(episode.counters.single.listenedMs).equals(120000);
    check(
      (await isar.queueEntrys.getByEntryId('q1'))!.episodeKey,
    ).equals('ek1');
    check(
      (await isar.stationStates.getByStationId('s1'))!.name,
    ).equals('Morning');
    check(
      (await isar.stationMembers.getByStationIdPodcastKey(
        's1',
        'pk1',
      ))!.episodeLimit,
    ).equals(3);
    check(
      (await isar.syncedSettings.getByKey('settings_playback_speed'))!.value,
    ).equals('1.25');
  });

  test('a second merge of the same snapshot changes nothing', () async {
    final source = await openTestIsar(isarSchemas);
    addTearDown(() => source.close(deleteFromDisk: true));
    await seed(source);
    final file = await exportFrom(source);

    check((await merger().merge(file)).changedRows).isGreaterThan(0);
    check((await merger().merge(file)).changedRows).equals(0);
  });

  test('newer local values stay; newer incoming ones win', () async {
    await seed(isar);
    final file = fileOf({
      'episode': [
        rowOf('ek', {
          1: ('pk', null),
          3: (300, hlc(50)), // older than local 103
          10: (null, hlc(200)), // unfavorite, newer than local 104
        }),
      ],
      'episodeCounter': [
        rowOf(compositeKey(['ek', 'd1']), {1: (2, null), 3: (9000, null)}),
      ],
    }, historyId: 'h1');

    await merger().merge(file);

    final episode = (await isar.episodeUserStates.getByEpisodeKey('ek'))!;
    check(episode.positionMs).equals(1200);
    check(episode.favoritedAt).isNull();
    check(episode.favoritedAtHlc).equals(hlc(200));
    // Counters take the maximum per device.
    check(episode.counters.single.playCount).equals(3);
    check(episode.counters.single.listenedMs).equals(9000);
  });

  test('merged fields land in the outbox with their own clocks', () async {
    await seed(isar);
    await isar.writeTxn(() => isar.outboxOps.clear());

    await merger().merge(
      fileOf({
        'setting': [
          rowOf('settings_playback_speed', {1: ('2.0', hlc(300))}),
        ],
      }, historyId: 'h1'),
    );

    final op = (await isar.outboxOps.where().findAll()).single;
    check(op.entity).equals('setting');
    check(op.fieldId).equals(1);
    check(op.hlc).equals(hlc(300));
  });

  test('the clock moves past what it merged', () async {
    await seed(isar);
    await merger().merge(
      fileOf({
        'setting': [
          rowOf('k', {1: ('1', hlc(now + 1000))}),
        ],
      }),
    );
    final meta = (await isar.syncMetas.get(SyncMeta.singletonId))!;
    check(hlc(now + 1000) < meta.hlc).isTrue();
  });

  test('a clock far in the future is clamped', () async {
    await merger().merge(
      fileOf({
        'setting': [
          rowOf('k', {
            1: ('1', hlc(now + const Duration(days: 30).inMilliseconds)),
          }),
        ],
      }),
    );
    final row = (await isar.syncedSettings.getByKey('k'))!;
    check(row.hlc).equals(hlc(now + Hlc.maxDrift.inMilliseconds));
  });

  group('tombstone horizon', () {
    Future<void> setHorizon(int horizon) => isar.writeTxn(() async {
      final meta = (await isar.syncMetas.get(SyncMeta.singletonId))!
        ..tombstoneHorizon = horizon;
      await isar.syncMetas.put(meta);
    });

    final oldEntry = {
      'queueEntry': [
        rowOf('gone', {1: ('ek', null), 2: ('b', hlc(40))}),
      ],
    };

    test('same history: an unknown element before it stays deleted', () async {
      await seed(isar);
      await setHorizon(hlc(60));

      await merger().merge(fileOf(oldEntry, historyId: 'h1'));

      check(await isar.queueEntrys.getByEntryId('gone')).isNull();
    });

    test('another history: the element is kept', () async {
      await seed(isar);
      await setHorizon(hlc(60));

      final result = await merger().merge(fileOf(oldEntry));

      check(result.sameHistory).isFalse();
      check(await isar.queueEntrys.getByEntryId('gone')).isNotNull();
      check(
        (await isar.syncMetas.get(SyncMeta.singletonId))!.historyId,
      ).equals('h1');
    });
  });

  test('a wrong value type rolls the whole merge back', () async {
    await seed(isar);
    final file = fileOf({
      'setting': [
        rowOf('settings_playback_speed', {1: ('3.0', hlc(500))}),
      ],
      'episode': [
        rowOf('ek', {3: ('not a number', hlc(500))}),
      ],
    }, historyId: 'h1');

    await check(merger().merge(file)).throws<DamagedSnapshot>();

    check(
      (await isar.syncedSettings.getByKey('settings_playback_speed'))!.value,
    ).equals('1.25');
    check(
      (await isar.episodeUserStates.getByEpisodeKey('ek'))!.positionMs,
    ).equals(1200);
  });

  test('a wrong type is damaged even where the local value wins', () async {
    await seed(isar);
    final file = fileOf({
      'setting': [
        rowOf('settings_playback_speed', {1: ('3.0', hlc(500))}),
      ],
      // podcastKey has no clock and the episode exists, so it never applies.
      'episode': [
        rowOf('ek', {1: (42, null)}),
      ],
    }, historyId: 'h1');

    await check(merger().merge(file)).throws<DamagedSnapshot>();
    check(
      (await isar.syncedSettings.getByKey('settings_playback_speed'))!.value,
    ).equals('1.25');
  });

  test('a key with a missing required part is damaged', () async {
    for (final file in [
      fileOf({
        'stationMember': [
          rowOf(compositeKey(['s1', null]), {1: (3, hlc(10))}),
        ],
      }),
      fileOf({
        'playOrder': [
          rowOf(compositeKey(['pk', null, null]), {1: ('x', hlc(10))}),
        ],
      }),
    ]) {
      await check(merger().merge(file)).throws<DamagedSnapshot>();
    }
  });

  group('unknown fields', () {
    SnapshotFile withUnknown(String value, int clock) => fileOf({
      'setting': [
        SnapshotRow(
          'k',
          (ProtoWriter()..writeBytes(99, encodeValue(value, hlc: clock)))
              .takeBytes(),
        ),
      ],
    });

    test('converge on equal clocks whichever merges first', () async {
      final a = withUnknown('a', hlc(70));
      final b = withUnknown('b', hlc(70));
      final other = await openTestIsar(isarSchemas);
      addTearDown(() => other.close(deleteFromDisk: true));

      await merger().merge(a);
      await merger().merge(b);
      await merger(other).merge(b);
      await merger(other).merge(a);

      final here = (await isar.opaqueFields.where().findAll()).single;
      final there = (await other.opaqueFields.where().findAll()).single;
      check(here.payload).deepEquals(there.payload);
    });

    test('land in the outbox', () async {
      await merger().merge(withUnknown('a', hlc(70)));

      final op = (await isar.outboxOps.where().findAll()).single;
      check(op.entity).equals('setting');
      check(op.fieldId).equals(99);
      check(op.hlc).equals(hlc(70));
    });

    test('have their clocks clamped and observed', () async {
      final future = now + const Duration(days: 30).inMilliseconds;
      await merger().merge(withUnknown('a', hlc(future)));

      final field = (await isar.opaqueFields.where().findAll()).single;
      final limit = hlc(now + Hlc.maxDrift.inMilliseconds);
      check(field.hlc).equals(limit);
      final meta = (await isar.syncMetas.get(SyncMeta.singletonId))!;
      check(limit < meta.hlc).isTrue();
    });
  });

  test('a new row missing a required field is damaged', () async {
    final file = fileOf({
      'queueEntry': [
        rowOf('q9', {2: ('a', hlc(10))}),
      ],
    });
    await check(merger().merge(file)).throws<DamagedSnapshot>();
    check(await isar.queueEntrys.count()).equals(0);
  });

  test('unknown fields and entities survive export and restore', () async {
    final unknownField =
        (ProtoWriter()..writeBytes(99, encodeValue('future', hlc: hlc(70))))
            .takeBytes();
    final file = fileOf({
      'setting': [
        SnapshotRow(
          'k',
          Uint8List.fromList([
            ...(ProtoWriter()..writeBytes(1, encodeValue('1', hlc: hlc(70))))
                .takeBytes(),
            ...unknownField,
          ]),
        ),
      ],
      'podcastNote': [
        rowOf('pk', {1: ('note', hlc(71))}),
      ],
    });

    await merger().merge(file);
    final exported = await SnapshotExporter(isar).export();

    final setting = decodeEntity(
      'setting',
      exported.body.sections['setting']!.single.fields,
    );
    check(setting.unknown.single.fieldNumber).equals(99);
    final note = exported.body.sections['podcastNote']!.single;
    check(note.key).equals('pk');
    final noteField = decodeEntity('podcastNote', note.fields).unknown.single;
    check(decodeValue(noteField.raw)).equals('note');
    check(decodeHlc(noteField.raw)).equals(hlc(71));
  });

  test('podcast info comes back for display', () async {
    final result = await merger().merge(
      fileOf({
        'podcastInfo': [
          rowOf('pk', {1: ('Show', null), 3: ('https://a/b.jpg', null)}),
        ],
      }),
    );
    check(result.podcastInfo['pk']!.title).equals('Show');
    check(result.podcastInfo['pk']!.artworkUrl).equals('https://a/b.jpg');
  });

  test('two states converge whichever merges first', () async {
    final random = Random(7);
    for (var round = 0; round < 25; round++) {
      Map<String, List<SnapshotRow>> randomState() => {
        'setting': [
          for (final key in ['a', 'b', 'c'])
            rowOf(key, {
              1: ('${random.nextInt(5)}', hlc(random.nextInt(4) + 1)),
            }),
        ],
        'episode': [
          rowOf('ek', {
            1: ('pk', null),
            3: (random.nextInt(1000), hlc(random.nextInt(4) + 1)),
            10: (
              random.nextBool()
                  ? DateTime.utc(2026, 1, random.nextInt(9) + 1)
                  : null,
              hlc(random.nextInt(4) + 1),
            ),
          }),
        ],
        'episodeCounter': [
          rowOf(compositeKey(['ek', 'd${random.nextInt(2)}']), {
            1: (random.nextInt(9), null),
          }),
        ],
      };
      final a = fileOf(randomState());
      final b = fileOf(randomState());

      final ab = await openTestIsar(isarSchemas);
      final ba = await openTestIsar(isarSchemas);
      await merger(ab).merge(a);
      await merger(ab).merge(b);
      await merger(ba).merge(b);
      await merger(ba).merge(a);

      Future<List<String>> state(Isar db) async {
        final exported = await SnapshotExporter(db).export();
        return [
          for (final name in exported.body.sections.keys.toList()..sort())
            for (final row
                in exported.body.sections[name]!.toList()
                  ..sort((x, y) => x.key.compareTo(y.key)))
              '$name ${row.key} ${row.fields}',
        ];
      }

      check(
        await state(ab),
        because: 'round $round',
      ).deepEquals(await state(ba));
      await ab.close(deleteFromDisk: true);
      await ba.close(deleteFromDisk: true);
    }
  });
}
