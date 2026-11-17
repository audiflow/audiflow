import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar source;
  late Isar isar;
  late Directory dir;
  late List<String> log;
  final now = DateTime.utc(2026, 11, 17);

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    source = await openTestIsar(isarSchemas);
    isar = await openTestIsar(isarSchemas);
    dir = await Directory.systemTemp.createTemp('audiflow_detect_');
    log = [];
  });

  tearDown(() async {
    await source.close(deleteFromDisk: true);
    await isar.close(deleteFromDisk: true);
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  File snapshot() => File(p.join(dir.path, continuitySnapshotFileName));

  RestoreDetector detector() => RestoreDetector(
    isar: isar,
    resolveSnapshotPath: () async => snapshot().path,
    restoreService: BackupRestoreService(
      isar: isar,
      stopPlayback: () async => log.add('stop'),
      cancelBackgroundTasks: () async {},
      writers: const [],
      syncFeeds: (urls) async => log.add('sync'),
      onStationChanged: (_) async {},
      logger: Logger(level: Level.off),
      nowMillis: () => now.millisecondsSinceEpoch,
    ),
    logger: Logger(level: Level.off),
  );

  Future<void> writeSnapshotOfOnePodcast() async {
    const hlc = 1 << 20;
    await source.writeTxn(() async {
      await source.syncMetas.put(SyncMeta()..historyId = 'old-device');
      await source.podcastUserStates.put(
        PodcastUserState()
          ..podcastKey = 'pk'
          ..subscribed = true
          ..subscribedHlc = hlc
          ..feedUrl = 'https://example.com/feed.xml'
          ..feedUrlHlc = hlc,
      );
    });
    final backup = await buildBackupFile(
      source,
      now: now,
      appVersion: '2.3.0',
      platform: 'ios',
    );
    await snapshot().writeAsBytes(backup.bytes);
  }

  Future<void> seedLaunchState() async {
    // Launch always creates SyncMeta and copies synced settings out of
    // preferences, which the OS restores, so neither counts as user data.
    await isar.writeTxn(() async {
      await isar.syncMetas.put(SyncMeta()..historyId = 'new-device');
      await isar.syncedSettings.put(
        SyncedSetting()
          ..key = 'playback_speed'
          ..value = '1.5',
      );
    });
  }

  test('restores the snapshot into an empty database', () async {
    await seedLaunchState();
    await writeSnapshotOfOnePodcast();

    final restored = await detector().restoreIfEmpty();

    check(restored).isTrue();
    check(await isar.podcastUserStates.count()).equals(1);
    final meta = await isar.syncMetas.get(SyncMeta.singletonId);
    check(meta!.historyId).equals('old-device');
    check(log.first).equals('stop');
  });

  test('does nothing when the database holds user data', () async {
    await writeSnapshotOfOnePodcast();
    await isar.writeTxn(
      () => isar.episodeUserStates.put(
        EpisodeUserState()
          ..episodeKey = 'ek'
          ..podcastKey = 'pk',
      ),
    );

    check(await detector().restoreIfEmpty()).isFalse();
    check(await isar.podcastUserStates.count()).equals(0);
    check(log).isEmpty();
  });

  test('a subscription not yet keyed counts as user data', () async {
    // Subscribed from search, feed not parsed yet: no PodcastUserState.
    await writeSnapshotOfOnePodcast();
    await isar.writeTxn(
      () => isar.subscriptions.put(
        Subscription()
          ..itunesId = '1'
          ..feedUrl = 'https://example.com/other.xml'
          ..title = 'Other'
          ..artistName = 'Artist'
          ..subscribedAt = now,
      ),
    );

    check(await detector().restoreIfEmpty()).isFalse();
    check(await isar.podcastUserStates.count()).equals(0);
  });

  test('a cached podcast does not count as user data', () async {
    await writeSnapshotOfOnePodcast();
    await isar.writeTxn(
      () => isar.subscriptions.put(
        Subscription()
          ..itunesId = '1'
          ..feedUrl = 'https://example.com/browsed.xml'
          ..title = 'Browsed'
          ..artistName = 'Artist'
          ..subscribedAt = now
          ..isCached = true,
      ),
    );

    check(await detector().restoreIfEmpty()).isTrue();
  });

  test('ignores a damaged file and keeps it', () async {
    await seedLaunchState();
    await snapshot().writeAsString('not a snapshot');

    check(await detector().restoreIfEmpty()).isFalse();
    check(await snapshot().exists()).isTrue();
    check(log).isEmpty();
  });

  test('does nothing without a snapshot file', () async {
    await seedLaunchState();

    check(await detector().restoreIfEmpty()).isFalse();
    check(log).isEmpty();
  });

  test('skips a snapshot that holds nothing to carry over', () async {
    await source.writeTxn(
      () => source.syncMetas.put(SyncMeta()..historyId = 'old-device'),
    );
    final backup = await buildBackupFile(
      source,
      now: now,
      appVersion: '2.3.0',
      platform: 'ios',
    );
    await snapshot().writeAsBytes(backup.bytes);

    check(await detector().restoreIfEmpty()).isFalse();
    check(log).isEmpty();
  });

  test('never throws when the path cannot be resolved', () async {
    final failing = RestoreDetector(
      isar: isar,
      resolveSnapshotPath: () async =>
          throw const FileSystemException('no support dir'),
      restoreService: detector().restoreService,
      logger: Logger(level: Level.off),
    );

    check(await failing.restoreIfEmpty()).isFalse();
  });

  group('ContinuityRestoreNotice', () {
    test('is shown once', () {
      final notice = ContinuityRestoreNotice();
      check(notice.consume()).isFalse();

      notice.raise();

      check(notice.consume()).isTrue();
      check(notice.consume()).isFalse();
    });
  });
}
