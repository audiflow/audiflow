import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  SnapshotBody sampleBody() => SnapshotBody({
    'setting': [
      SnapshotRow(
        'settings_playback_speed',
        (ProtoWriter()..writeBytes(1, encodeValue('1.5', hlc: 42))).takeBytes(),
      ),
    ],
  });

  Uint8List sampleFile({SnapshotBody? body}) => encodeSnapshotFile(
    body: body ?? sampleBody(),
    createdAt: DateTime.utc(2026, 11, 15, 10),
    historyId: 'h1',
    appVersion: '2.3.0',
    platform: 'ios',
    counts: const SnapshotCounts(
      podcasts: 1,
      episodes: 2,
      queue: 3,
      stations: 4,
    ),
  );

  group('file', () {
    test('round trips header and body', () {
      final file = readSnapshotFile(sampleFile());

      check(file.header.formatVersion).equals(1);
      check(file.header.createdAt).equals(DateTime.utc(2026, 11, 15, 10));
      check(file.header.historyId).equals('h1');
      check(file.header.platform).equals('ios');
      check(file.header.counts.stations).equals(4);
      final row = file.body.sections['setting']!.single;
      check(row.key).equals('settings_playback_speed');
      final decoded = decodeEntity('setting', row.fields);
      check(decoded.known).deepEquals({1: '1.5'});
      check(decoded.hlcs).deepEquals({1: 42});
    });

    test('the header reads without the body', () {
      final bytes = sampleFile();
      final newline = bytes.indexOf(0x0a);
      // Only the header line and a broken body.
      final headerOnly = Uint8List.fromList([
        ...bytes.sublist(0, newline + 1),
        1,
        2,
        3,
      ]);

      check(readSnapshotHeader(headerOnly).counts.queue).equals(3);
      check(() => readSnapshotFile(headerOnly))
          .throws<DamagedSnapshot>()
          .has((e) => e.location, 'location')
          .equals('payload checksum');
    });

    test('rejects a file that is not a backup', () {
      for (final bytes in [
        Uint8List(0),
        utf8.encode('<opml version="2.0"></opml>\n'),
        utf8.encode('{"format":"something-else","formatVersion":1}\n'),
        Uint8List.fromList(gzip.encode(utf8.encode('hello'))),
      ]) {
        check(
          () => readSnapshotFile(Uint8List.fromList(bytes)),
        ).throws<NotASnapshot>();
      }
    });

    test('rejects a newer format', () {
      final header = jsonEncode({
        'format': snapshotFormat,
        'formatVersion': 99,
      });
      check(
        () => readSnapshotHeader(utf8.encode('$header\n')),
      ).throws<SnapshotTooNew>().has((e) => e.formatVersion, 'v').equals(99);
    });

    test('rejects a header missing a field', () {
      final bytes = sampleFile();
      final newline = bytes.indexOf(0x0a);
      final json =
          jsonDecode(utf8.decode(bytes.sublist(0, newline)))
                as Map<String, Object?>
            ..remove('historyId');
      final broken = Uint8List.fromList([
        ...utf8.encode(jsonEncode(json)),
        ...bytes.sublist(newline),
      ]);
      check(() => readSnapshotFile(broken))
          .throws<DamagedSnapshot>()
          .has((e) => e.location, 'location')
          .equals('header.historyId');
    });

    test('rejects a truncated or altered body', () {
      final bytes = sampleFile();
      check(
        () =>
            readSnapshotFile(Uint8List.sublistView(bytes, 0, bytes.length - 3)),
      ).throws<DamagedSnapshot>();
      final altered = Uint8List.fromList(bytes)..last ^= 0xff;
      check(() => readSnapshotFile(altered)).throws<DamagedSnapshot>();
    });

    test('rejects a body that is valid gzip but not a snapshot', () {
      final payload = Uint8List.fromList(gzip.encode([0x0f, 0xff]));
      final bytes = sampleFile();
      final newline = bytes.indexOf(0x0a);
      final json =
          jsonDecode(utf8.decode(bytes.sublist(0, newline)))
                as Map<String, Object?>
            ..['payloadSha256'] = sha256Hex(payload);
      final broken = Uint8List.fromList([
        ...utf8.encode(jsonEncode(json)),
        0x0a,
        ...payload,
      ]);
      check(() => readSnapshotFile(broken))
          .throws<DamagedSnapshot>()
          .has((e) => e.location, 'location')
          .equals('payload contents');
    });
  });

  group('exporter', () {
    late Isar isar;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await openTestIsar(isarSchemas);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('exports every user state row with its clocks', () async {
      await isar.writeTxn(() async {
        await isar.syncMetas.put(SyncMeta()..historyId = 'h1');
        await isar.subscriptions.put(
          Subscription()
            ..itunesId = 'it'
            ..feedUrl = 'https://example.com/feed'
            ..title = 'Show'
            ..artistName = 'Artist'
            ..subscribedAt = DateTime(2026)
            ..podcastKey = 'pk',
        );
        await isar.podcastUserStates.put(
          PodcastUserState()
            ..podcastKey = 'pk'
            ..subscribed = true
            ..subscribedHlc = 7
            ..playOrders = [
              PlayOrderEntry()
                ..playlistId = 'pl'
                ..order = 'oldestFirst'
                ..hlc = 8,
            ],
        );
        await isar.episodeUserStates.put(
          EpisodeUserState()
            ..episodeKey = 'ek'
            ..podcastKey = 'pk'
            ..positionMs = 1200
            ..positionHlc = 9
            ..counters = [
              EpisodePlayCounters()
                ..deviceId = 'd1'
                ..playCount = 2,
            ],
        );
        await isar.queueEntrys.putAll([
          QueueEntry()
            ..entryId = 'q1'
            ..episodeKey = 'ek',
          QueueEntry()
            ..entryId = 'q2'
            ..episodeKey = 'ek'
            ..deleted = true
            ..deletedHlc = 10,
        ]);
        await isar.stationStates.put(StationState()..stationId = 's1');
        await isar.stationMembers.put(
          StationMember()
            ..stationId = 's1'
            ..podcastKey = 'pk',
        );
        await isar.syncedSettings.put(
          SyncedSetting()
            ..key = 'k'
            ..value = '1'
            ..hlc = 11,
        );
        await isar.opaqueFields.putAll([
          OpaqueField()
            ..entity = 'episode'
            ..key = 'ek'
            ..fieldId = 99
            ..payload = (ProtoWriter()..writeBytes(99, encodeValue('x')))
                .takeBytes(),
          OpaqueField()
            ..entity = 'podcastNote'
            ..key = 'pk'
            ..fieldId = 1
            ..payload = (ProtoWriter()..writeBytes(1, encodeValue('n')))
                .takeBytes(),
        ]);
      });

      final exported = await SnapshotExporter(isar).export();
      // Through a file and back, as a restore reads it.
      final file = readSnapshotFile(
        encodeSnapshotFile(
          body: exported.body,
          createdAt: DateTime.utc(2026),
          historyId: exported.historyId,
          appVersion: '2.3.0',
          platform: 'android',
          counts: exported.counts,
        ),
      );
      final sections = file.body.sections;
      DecodedEntity only(String entity) =>
          decodeEntity(entity, sections[entity]!.single.fields);

      check(exported.historyId).equals('h1');
      check(
        file.header.counts.toJson(),
      ).deepEquals({'podcasts': 1, 'episodes': 1, 'queue': 1, 'stations': 1});
      check(only('podcast').known[1]).equals(true);
      check(only('podcast').hlcs[1]).equals(7);
      check(only('playOrder').known[1]).equals('oldestFirst');
      check(only('podcastInfo').known[1]).equals('Show');
      final episode = only('episode');
      check(episode.known[3]).equals(1200);
      check(episode.hlcs[3]).equals(9);
      check(episode.unknown.single.fieldNumber).equals(99);
      check(only('episodeCounter').known[1]).equals(2);
      check(sections['queueEntry']!.map((r) => r.key)).deepEquals(['q1', 'q2']);
      check(only('station').known.keys).contains(1);
      check(only('stationMember').known.keys).contains(4);
      check(only('setting').hlcs[1]).equals(11);
      check(
        decodeEntity(
          'podcastNote',
          sections['podcastNote']!.single.fields,
        ).unknown.single.fieldNumber,
      ).equals(1);
    });
  });
}

String sha256Hex(List<int> bytes) => crypto.sha256.convert(bytes).toString();
