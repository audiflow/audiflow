import 'dart:typed_data';
import 'package:audiflow_core/audiflow_core.dart';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
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

  Future<Episode> putEpisode(String guid) async {
    final sub =
        await isar.subscriptions.getByItunesId('it') ??
        (Subscription()
          ..itunesId = 'it'
          ..feedUrl = 'https://example.com/feed'
          ..title = 'Show'
          ..artistName = 'Artist'
          ..subscribedAt = DateTime(2026)
          ..podcastKey = 'pk');
    final episode = Episode()
      ..guid = guid
      ..title = guid
      ..audioUrl = 'https://example.com/$guid.mp3'
      ..episodeKey = 'ek-$guid';
    await isar.writeTxn(() async {
      await isar.subscriptions.put(sub);
      await isar.episodes.put(episode..podcastId = sub.id);
    });
    return episode;
  }

  Future<List<OutboxOp>> opsOf(String entity, String key) => isar.outboxOps
      .filter()
      .entityEqualTo(entity)
      .keyEqualTo(key)
      .sortByFieldId()
      .findAll();

  Object? valueOf(OutboxOp op) {
    final decoded = decodeEntity(op.entity, Uint8List.fromList(op.payload));
    return decoded.known[op.fieldId];
  }

  test('a state change and its ops commit together', () async {
    final episode = await putEpisode('a');
    final history = PlaybackHistoryLocalDatasource(isar);

    await history.updateProgress(episodeId: episode.id, positionMs: 1000);

    final ops = await opsOf('episode', 'ek-a');
    final position = ops.firstWhere((o) => o.fieldId == 3);
    check(valueOf(position)).equals(1000);
    final state = await isar.episodeUserStates.getByEpisodeKey('ek-a');
    check(position.hlc).equals(state!.positionHlc);
  });

  test('a failed write leaves neither state nor ops', () async {
    final store = UserStateStore(isar);

    await check(
      store.write((txn) async {
        final row = SyncedSetting()
          ..key = 'k'
          ..value = '1'
          ..hlc = txn.stamp.packed;
        await isar.syncedSettings.put(row);
        txn.touch(UserStateEntities.setting, row);
        throw StateError('boom');
      }),
    ).throws<StateError>();

    check(await isar.syncedSettings.count()).equals(0);
    check(await isar.outboxOps.count()).equals(0);
  });

  test('many position updates leave one op per field and episode', () async {
    final a = await putEpisode('a');
    final b = await putEpisode('b');
    final history = PlaybackHistoryLocalDatasource(isar);

    for (var i = 1; i <= 30; i++) {
      await history.updateProgress(episodeId: a.id, positionMs: i * 1000);
      await history.updateProgress(episodeId: b.id, positionMs: i * 500);
    }

    for (final (key, last) in [('ek-a', 30000), ('ek-b', 15000)]) {
      final positions = (await opsOf(
        'episode',
        key,
      )).where((o) => o.fieldId == 3).toList();
      check(positions).length.equals(1);
      check(valueOf(positions.single)).equals(last);
    }
  });

  test('only fields this write stamped get ops', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = AppSettingsRepositoryImpl(
      SharedPreferencesDataSource(prefs),
      isar: isar,
    );
    final station = await StationLocalDatasource(isar).insert(
      Station()
        ..name = 'S'
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026),
    );
    await isar.writeTxn(() => isar.outboxOps.clear());

    await StationLocalDatasource(isar).update(station..groupByPodcast = true);
    await repo.setVoiceBoost(true);

    final stationOps = await opsOf('station', station.stationId!);
    // groupByPodcast, plus createdAt, which has no clock and goes along.
    check(stationOps.map((o) => o.fieldId)).deepEquals([11, 14]);
    check(valueOf(stationOps.first)).equals(true);
    check(
      (await opsOf('setting', SettingsKeys.voiceBoost)).map(valueOf),
    ).deepEquals(['true', true]);
  });

  test('migration copies write no ops', () async {
    final episode = await putEpisode('a');
    await isar.writeTxn(
      () => isar.playbackHistorys.put(
        PlaybackHistory()
          ..episodeId = episode.id
          ..positionMs = 5000
          ..durationMs = 10000
          ..firstPlayedAt = DateTime(2026)
          ..lastPlayedAt = DateTime(2026),
      ),
    );

    await DataMigrationRunner(isar, steps: dataMigrationSteps).run();

    check(await isar.episodeUserStates.count()).equals(1);
    check(await isar.outboxOps.count()).equals(0);
  });

  test('the outbox drops its oldest ops past the cap', () async {
    final store = UserStateStore(isar, outboxCap: 5);

    for (var i = 0; i < 8; i++) {
      await store.write((txn) async {
        final row = SyncedSetting()
          ..key = 'k$i'
          ..value = '$i'
          ..hlc = txn.stamp.packed;
        await isar.syncedSettings.put(row);
        txn.touch(UserStateEntities.setting, row);
      });
    }

    // Two fields per setting; the newest five ops stay.
    final ops = await isar.outboxOps.where().sortByOpId().findAll();
    check(ops).length.equals(5);
    check(ops.map((o) => o.key).toSet()).deepEquals({'k5', 'k6', 'k7'});
  });
}
