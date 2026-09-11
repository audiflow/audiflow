import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/isar_test_helper.dart';

/// Records each writer the reset quiesces, in order, along with how many
/// subscriptions and whether the downloads directory existed at the time,
/// so the tests can assert every writer is stopped before the storage it
/// writes to is cleared.
class _WriterLog {
  _WriterLog(this._isar, this._downloadsDir);

  final Isar _isar;
  final Directory _downloadsDir;
  final List<(String, int, bool)> calls = [];

  Future<void> record(String writer) async {
    calls.add((
      writer,
      await _isar.subscriptions.count(),
      await _downloadsDir.exists(),
    ));
  }
}

class _FakePlaybackController implements AudioPlaybackController {
  _FakePlaybackController(this._log);

  final _WriterLog _log;

  @override
  Future<void> stop() => _log.record('playback');

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> skipBackward() async {}

  @override
  Future<void> skipForward() async {}
}

void main() {
  late Isar isar;
  late Directory downloadsDir;
  late SharedPreferencesDataSource preferences;
  late _WriterLog writers;
  late DataResetService service;

  DataResetService buildService({
    required DownloadsDirectoryResolver resolveDownloadsDirectory,
  }) {
    return DataResetService(
      isar: isar,
      preferences: preferences,
      playback: _FakePlaybackController(writers),
      cancelBackgroundTasks: () => writers.record('backgroundTasks'),
      cancelDownloads: () => writers.record('downloads'),
      cancelFeedSync: () => writers.record('feedSync'),
      resolveDownloadsDirectory: resolveDownloadsDirectory,
    );
  }

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar(isarSchemas);
    downloadsDir = await Directory.systemTemp.createTemp('audiflow_dl_');
    SharedPreferences.setMockInitialValues({
      'settings_theme_mode': 'dark',
      'analytics.install_id': 'abc',
    });
    preferences = SharedPreferencesDataSource(
      await SharedPreferences.getInstance(),
    );
    writers = _WriterLog(isar, downloadsDir);
    service = buildService(
      resolveDownloadsDirectory: () async => downloadsDir.path,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await downloadsDir.exists()) {
      await downloadsDir.delete(recursive: true);
    }
  });

  Future<Map<String, int>> countPerCollection() async {
    final counts = <String, int>{};
    for (final schema in isarSchemas) {
      // Name-based lookup is the only way to iterate isarSchemas without
      // enumerating typed getters, which would defeat the coverage guard.
      // ignore: invalid_use_of_protected_member
      final collection = isar.getCollectionByNameInternal(schema.name);
      counts[schema.name] = await collection!.count();
    }
    return counts;
  }

  group('DataResetService.resetAll', () {
    test('clears every Isar collection', () async {
      await seedEveryCollection(isar);
      // Coverage guard: a collection added to isarSchemas without a seed row
      // here fails before reset runs, rather than silently going untested.
      final before = await countPerCollection();
      check(before.values).every((count) => count.equals(1));

      await service.resetAll();

      final after = await countPerCollection();
      check(after.values).every((count) => count.equals(0));
    });

    test('stops every writer before clearing what it writes to', () async {
      await seedEveryCollection(isar);

      await service.resetAll();

      // Downloads are stopped while their files still exist; the feed sync
      // is cancelled last, right before the database clear.
      check(writers.calls).deepEquals([
        ('playback', 1, true),
        ('backgroundTasks', 1, true),
        ('downloads', 1, true),
        ('feedSync', 1, false),
      ]);
    });

    test('leaves the database untouched when file deletion fails', () async {
      await seedEveryCollection(isar);
      final blockedService = buildService(
        resolveDownloadsDirectory: () async =>
            throw const FileSystemException('boom'),
      );

      await check(blockedService.resetAll()).throws<FileSystemException>();

      check(await isar.subscriptions.count()).equals(1);
      check(preferences.getString('settings_theme_mode')).equals('dark');
    });

    test('deletes the downloads directory', () async {
      final file = File(p.join(downloadsDir.path, 'nested', '1_ep.mp3'));
      await file.create(recursive: true);

      await service.resetAll();

      check(await downloadsDir.exists()).isFalse();
    });

    test('succeeds when the downloads directory does not exist', () async {
      await downloadsDir.delete(recursive: true);

      await service.resetAll();

      check(await downloadsDir.exists()).isFalse();
    });

    test('clears every SharedPreferences key', () async {
      await service.resetAll();

      check(preferences.getString('settings_theme_mode')).isNull();
      check(preferences.getString('analytics.install_id')).isNull();
    });
  });
}

final _now = DateTime(2026, 1, 1);

/// Writes one row into every collection registered in [isarSchemas].
Future<void> seedEveryCollection(Isar isar) async {
  await isar.writeTxn(() async {
    await _seedLibrary(isar);
    await _seedSmartPlaylists(isar);
    await _seedPlayback(isar);
    await _seedTranscripts(isar);
    await _seedStations(isar);
    await _seedParentalControl(isar);
  });
}

Future<void> _seedLibrary(Isar isar) async {
  await isar.subscriptions.put(
    Subscription()
      ..itunesId = '1'
      ..feedUrl = 'https://example.com/feed.xml'
      ..title = 'Podcast'
      ..artistName = 'Artist'
      ..subscribedAt = _now,
  );
  await isar.episodes.put(
    Episode()
      ..podcastId = 1
      ..guid = 'guid'
      ..title = 'Episode'
      ..audioUrl = 'https://example.com/a.mp3',
  );
  await isar.downloadTasks.put(
    DownloadTask()
      ..episodeId = 1
      ..audioUrl = 'https://example.com/a.mp3'
      ..createdAt = _now,
  );
}

Future<void> _seedSmartPlaylists(Isar isar) async {
  await isar.smartPlaylistEntitys.put(
    SmartPlaylistEntity()
      ..podcastId = 1
      ..playlistNumber = 1
      ..displayName = 'Playlist'
      ..sortKey = 0
      ..resolverType = 'all',
  );
  await isar.smartPlaylistGroupEntitys.put(
    SmartPlaylistGroupEntity()
      ..podcastId = 1
      ..playlistId = 'p'
      ..groupId = 'g'
      ..displayName = 'Group'
      ..sortKey = 0
      ..episodeIds = '[]',
  );
  await isar.podcastViewPreferences.put(PodcastViewPreference()..podcastId = 1);
  await isar.smartPlaylistUserPreferences.put(
    SmartPlaylistUserPreference()
      ..podcastId = 1
      ..playlistId = 'p',
  );
  await isar.smartPlaylistGroupUserPreferences.put(
    SmartPlaylistGroupUserPreference()
      ..podcastId = 1
      ..playlistId = 'p'
      ..groupId = 'g',
  );
}

Future<void> _seedPlayback(Isar isar) async {
  await isar.playbackHistorys.put(PlaybackHistory()..episodeId = 1);
  await isar.queueItems.put(
    QueueItem()
      ..episodeId = 1
      ..position = 0
      ..addedAt = _now,
  );
}

Future<void> _seedTranscripts(Isar isar) async {
  await isar.episodeTranscripts.put(
    EpisodeTranscript()
      ..episodeId = 1
      ..url = 'https://example.com/t.srt'
      ..type = 'srt',
  );
  await isar.transcriptSegments.put(
    TranscriptSegment()
      ..transcriptId = 1
      ..startMs = 0
      ..endMs = 1
      ..body = 'hello',
  );
  await isar.episodeChapters.put(
    EpisodeChapter()
      ..episodeId = 1
      ..sortOrder = 0
      ..title = 'Chapter'
      ..startMs = 0,
  );
}

Future<void> _seedStations(Isar isar) async {
  await isar.stations.put(
    Station()
      ..name = 'Station'
      ..createdAt = _now
      ..updatedAt = _now,
  );
  await isar.stationPodcasts.put(
    StationPodcast()
      ..stationId = 1
      ..podcastId = 1
      ..addedAt = _now,
  );
  await isar.stationEpisodes.put(
    StationEpisode()
      ..stationId = 1
      ..episodeId = 1,
  );
}

Future<void> _seedParentalControl(Isar isar) async {
  await isar.parentalControlSettings.put(
    ParentalControlSettings()..restrictedModeEnabled = true,
  );
  await isar.podcastParentalFlags.put(PodcastParentalFlags()..itunesId = 1);
}
