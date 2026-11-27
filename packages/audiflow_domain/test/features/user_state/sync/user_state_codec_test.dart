import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  group('values', () {
    final samples = <Object?>[
      null,
      0,
      1,
      -1,
      300,
      -9007199254740991,
      9007199254740991,
      1.5,
      -0.25,
      '',
      'Morning',
      'Japanese: 日本語, emoji: 🎧',
      true,
      false,
      DateTime.utc(2026, 11, 16, 12, 34, 56, 789, 123),
    ];

    for (final sample in samples) {
      test('round trips $sample', () {
        check(decodeValue(encodeValue(sample))).equals(sample);
      });
    }

    test('a local DateTime comes back as the same moment in UTC', () {
      final local = DateTime(2026, 3, 1, 8);
      final decoded = decodeValue(encodeValue(local))! as DateTime;
      check(decoded.isAtSameMomentAs(local)).isTrue();
      check(decoded.isUtc).isTrue();
    });

    test('rejects values with no wire form', () {
      check(() => encodeValue(const [1])).throws<ArgumentError>();
    });

    test('rejects a value with the wrong wire type', () {
      // Field 2 (double) sent as a varint.
      check(
        () => decodeValue(Uint8List.fromList([0x10, 0x00])),
      ).throws<FormatException>();
      // Field 3 (string) sent as a varint.
      check(
        () => decodeValue(Uint8List.fromList([0x18, 0x01])),
      ).throws<FormatException>();
    });

    test('the last occurrence of a repeated value wins', () {
      check(
        decodeValue(Uint8List.fromList([0x08, 0x02, 0x08, 0x04])),
      ).equals(2);
    });

    test('rejects truncated input', () {
      final bytes = encodeValue('Morning');
      check(
        () => decodeValue(Uint8List.sublistView(bytes, 0, bytes.length - 2)),
      ).throws<FormatException>();
    });
  });

  group('fields', () {
    test('an entity message names its field, null included', () {
      final state = EpisodeUserState()
        ..episodeKey = 'ek'
        ..podcastKey = 'pk';
      final field = UserStateEntities.episode.field(4)!;

      final decoded = decodeEntity('episode', encodeField(field, state));

      check(decoded.known.keys).deepEquals([4]);
      check(decoded.known[4]).isNull();
      check(decoded.unknown).isEmpty();
    });

    test('unknown fields are kept in wire form and stored', () async {
      await Isar.initializeIsarCore(download: true);
      final isar = await openTestIsar(isarSchemas);
      addTearDown(() => isar.close(deleteFromDisk: true));
      // A message from a newer version: a known field and two new ones.
      final w = ProtoWriter()
        ..writeBytes(3, encodeValue(1200))
        ..writeBytes(99, encodeValue('future'))
        ..writeInt(100, 7);
      final bytes = w.takeBytes();

      final decoded = decodeEntity('episode', bytes);
      check(decoded.known).deepEquals({3: 1200});
      check(decoded.unknown.map((f) => f.fieldNumber)).deepEquals([99, 100]);

      await isar.writeTxn(
        () => keepUnknownFields(
          isar,
          entity: 'episode',
          key: 'ek',
          hlc: 5,
          fields: decoded.unknown,
        ),
      );
      // An older change of the same field does not replace it.
      await isar.writeTxn(
        () => keepUnknownFields(
          isar,
          entity: 'episode',
          key: 'ek',
          hlc: 4,
          fields: [
            ProtoField(99, WireType.lengthDelimited, encodeValue('old')),
          ],
        ),
      );

      final kept = await isar.opaqueFields.where().sortByFieldId().findAll();
      check(kept.map((f) => f.fieldId)).deepEquals([99, 100]);
      // Written back, the fields are what arrived.
      final rebuilt = ProtoWriter();
      for (final f in kept) {
        rebuilt.writeRaw(f.payload);
      }
      final again = readMessage(rebuilt.takeBytes());
      check(decodeValue(again[0].raw)).equals('future');
      check(again[1].asInt).equals(7);
    });

    test('a value of a type this version does not know is kept', () {
      // A later Value type (field 9) inside a registered field.
      final future = ProtoWriter()..writeInt(9, 1);
      final w = ProtoWriter()
        ..writeBytes(3, future.takeBytes())
        ..writeBytes(4, encodeValue(null));
      final decoded = decodeEntity('episode', w.takeBytes());

      check(decoded.known).deepEquals({4: null});
      check(decoded.unknown.map((f) => f.fieldNumber)).deepEquals([3]);
    });

    test('an entity this version does not know is all unknown', () {
      final w = ProtoWriter()..writeBytes(1, encodeValue('x'));
      final decoded = decodeEntity('podcastNote', w.takeBytes());
      check(decoded.known).isEmpty();
      check(decoded.unknown).length.equals(1);
    });
  });

  group('registry', () {
    test('ids and names are unique within each entity', () {
      for (final MapEntry(key: entity, value: ids)
          in UserStateEntities.declaredIds.entries) {
        check(because: entity, ids.toSet()).length.equals(ids.length);
      }
      for (final MapEntry(key: entity, value: fields)
          in UserStateEntities.registry.entries) {
        check(
          because: entity,
          fields.values.toSet(),
        ).length.equals(fields.length);
      }
    });

    test('composite keys cannot collide', () {
      final keys = [
        compositeKey(['pk', 'a|b', 'c']),
        compositeKey(['pk', 'a', 'b|c']),
        compositeKey(['pk', 'a', null]),
        compositeKey(['pk', 'a', '']),
        compositeKey(['pk', 'a', '~']),
        compositeKey(['pk', '1:a', null]),
      ];
      check(keys.toSet()).length.equals(keys.length);
    });

    test('composite keys split back into their parts', () {
      for (final parts in [
        ['pk', 'a|b', 'c'],
        ['pk', '', null],
        ['pk', '~', '1:a'],
        [null, 'x', ''],
      ]) {
        check(
          splitCompositeKey(compositeKey(parts), parts.length),
        ).deepEquals(parts);
      }
      for (final bad in [
        '',
        'pk',
        '2:pk',
        '2:pk|',
        '9:a|1:b',
        '1:a1:b',
        '-1:a|1:b',
        '+1:a|1:b',
      ]) {
        check(() => splitCompositeKey(bad, 2)).throws<FormatException>();
      }
    });

    // Pins every fieldId. Adding a field adds a line here; changing or
    // removing one breaks older apps and peers, so a fieldId is retired,
    // never reused: keep its line and comment it as retired instead.
    test('fieldIds never change', () {
      check(UserStateEntities.registry).deepEquals({
        'podcast': {
          1: 'subscribed',
          2: 'subscribedAt',
          3: 'feedUrl',
          4: 'itunesId',
          5: 'autoDownload',
          6: 'autoDownloadKeepCount',
          7: 'hasView',
          8: 'viewMode',
          9: 'episodeFilter',
          10: 'episodeSortOrder',
          11: 'seasonSortField',
          12: 'seasonSortOrder',
          13: 'selectedPlaylistId',
          14: 'autoPlayOrder',
          15: 'hasAudio',
          16: 'speed',
          17: 'skipSilence',
          18: 'voiceBoost',
          19: 'hasParental',
          20: 'hideExplicitEpisodes',
        },
        'playOrder': {1: 'order'},
        'episode': {
          1: 'podcastKey',
          2: 'hasPlayback',
          3: 'positionMs',
          4: 'durationMs',
          5: 'completedAt',
          6: 'isReplaying',
          7: 'isReplayFromStart',
          8: 'firstPlayedAt',
          9: 'lastPlayedAt',
          10: 'favoritedAt',
          11: 'locatorGuid',
          12: 'locatorAudioUrl',
          13: 'locatorPublishedAt',
        },
        'episodeCounter': {
          1: 'playCount',
          2: 'completedCount',
          3: 'listenedMs',
          4: 'realtimeMs',
        },
        'queueEntry': {
          1: 'episodeKey',
          2: 'rank',
          3: 'isAdhoc',
          4: 'sourceContext',
          5: 'addedAt',
          6: 'deleted',
        },
        'station': {
          1: 'name',
          2: 'sortOrder',
          3: 'episodeSortType',
          4: 'hideCompleted',
          5: 'filterDownloaded',
          6: 'filterFavorited',
          7: 'durationOperator',
          8: 'durationMinutes',
          9: 'publishedWithinDays',
          10: 'defaultEpisodeLimit',
          11: 'groupByPodcast',
          12: 'podcastSortType',
          13: 'lastPlayedAt',
          14: 'createdAt',
          15: 'deleted',
        },
        'stationMember': {
          1: 'episodeLimit',
          2: 'sortOrder',
          3: 'addedAt',
          4: 'deleted',
        },
        'setting': {1: 'value', 2: 'present'},
        'podcastInfo': {1: 'title', 2: 'artistName', 3: 'artworkUrl'},
      });
    });
  });
}
