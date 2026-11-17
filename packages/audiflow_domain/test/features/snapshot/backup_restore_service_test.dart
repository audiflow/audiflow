import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../helpers/isar_test_helper.dart';

class _Writer implements SuspendableWriter {
  _Writer(this.log, this.name);

  final List<String> log;
  final String name;

  @override
  Future<void> suspend() async => log.add('suspend $name');

  @override
  void resume() => log.add('resume $name');
}

void main() {
  late Isar source;
  late Isar isar;
  late List<String> log;
  final now = DateTime.utc(2026, 11, 17);

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    source = await openTestIsar(isarSchemas);
    isar = await openTestIsar(isarSchemas);
    log = [];
  });

  tearDown(() async {
    await source.close(deleteFromDisk: true);
    await isar.close(deleteFromDisk: true);
  });

  BackupRestoreService service({
    Future<void> Function(List<String>)? syncFeeds,
  }) => BackupRestoreService(
    isar: isar,
    stopPlayback: () async => log.add('stop'),
    cancelBackgroundTasks: () async => log.add('cancel'),
    writers: [_Writer(log, 'downloads'), _Writer(log, 'feeds')],
    syncFeeds: syncFeeds ?? (urls) async => log.add('sync ${urls.join(',')}'),
    onStationChanged: (id) async => log.add('station $id'),
    logger: Logger(level: Level.off),
    nowMillis: () => now.millisecondsSinceEpoch,
  );

  Future<Uint8List> backupWithOnePodcast() async {
    const hlc = 1 << 20;
    await source.writeTxn(() async {
      await source.syncMetas.put(SyncMeta()..historyId = 'h');
      await source.podcastUserStates.put(
        PodcastUserState()
          ..podcastKey = 'pk'
          ..subscribed = true
          ..subscribedHlc = hlc
          ..subscribedAt = DateTime.utc(2026)
          ..feedUrl = 'https://example.com/feed.xml'
          ..feedUrlHlc = hlc,
      );
      await source.stationStates.put(
        StationState()
          ..stationId = 's1'
          ..name = 'Morning'
          ..nameHlc = hlc,
      );
    });
    return (await buildBackupFile(
      source,
      now: now,
      appVersion: '2.3.0',
      platform: 'ios',
    )).bytes;
  }

  test('reading a broken file fails before anything is written', () async {
    check(
      () => service().read(Uint8List.fromList([1, 2, 3])),
    ).throws<NotASnapshot>();
    check(log).isEmpty();
    check(await isar.podcastUserStates.count()).equals(0);
  });

  test('merges with playback stopped and writers suspended', () async {
    final file = service().read(await backupWithOnePodcast());

    final result = await service().restore(file);

    check(log.take(6)).deepEquals([
      'stop',
      'cancel',
      'suspend downloads',
      'suspend feeds',
      'resume feeds',
      'resume downloads',
    ]);
    check(0 < result.changedRows).isTrue();
    final sub = await isar.subscriptions
        .filter()
        .podcastKeyEqualTo('pk')
        .findFirst();
    check(sub).isNotNull().has((s) => s.isCached, 'isCached').isFalse();
  });

  test(
    'fetches feeds and reconciles stations after the writers resume',
    () async {
      final file = service().read(await backupWithOnePodcast());

      final result = await service().restore(file);
      await result.postProcessing;

      final station = await isar.stations
          .filter()
          .stationIdEqualTo('s1')
          .findFirst();
      check(log.skip(6)).deepEquals([
        'sync https://example.com/feed.xml',
        'station ${station!.id}',
      ]);
    },
  );

  test('a failed feed fetch still counts as restored', () async {
    final file = service().read(await backupWithOnePodcast());

    final result = await service(
      syncFeeds: (_) async => throw Exception('offline'),
    ).restore(file);

    await check(result.postProcessing).completes();
    check(await isar.subscriptions.count()).equals(1);
  });

  test('writers resume even when the merge fails', () async {
    final file = service().read(await backupWithOnePodcast());
    await isar.close();

    await check(service().restore(file)).throws<Object>();
    check(log).contains('resume downloads');
    isar = await openTestIsar(isarSchemas);
  });
}
