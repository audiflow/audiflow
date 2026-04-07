import 'dart:io';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeDownloadRepository implements DownloadRepository {
  final List<DownloadTask> pending = [];
  final List<
    ({int id, DownloadStatus status, String? localPath, String? lastError})
  >
  statusUpdates = [];
  final List<int> incrementedRetryIds = [];

  @override
  Future<DownloadTask?> getNextPending({required bool isOnWifi}) async {
    final idx = pending.indexWhere(
      (t) => t.downloadStatus is DownloadStatusPending,
    );
    if (0 <= idx) return pending[idx];
    return null;
  }

  @override
  Future<void> updateStatus({
    required int id,
    required DownloadStatus status,
    String? localPath,
    String? lastError,
  }) async {
    statusUpdates.add((
      id: id,
      status: status,
      localPath: localPath,
      lastError: lastError,
    ));
    for (final t in pending) {
      if (t.id == id) {
        t.status = status.toDbValue();
        t.localPath = localPath ?? t.localPath;
        t.lastError = lastError ?? t.lastError;
      }
    }
  }

  @override
  Future<void> incrementRetryCount(int id) async {
    incrementedRetryIds.add(id);
    for (final t in pending) {
      if (t.id == id) t.retryCount++;
    }
  }

  @override
  Future<void> updateProgress({
    required int id,
    required int downloadedBytes,
    int? totalBytes,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeEpisodeRepository implements EpisodeRepository {
  final Map<int, Episode> episodes = {};

  @override
  Future<Episode?> getById(int id) async => episodes[id];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DownloadTask _task({
  required int id,
  int episodeId = 1,
  String audioUrl = 'https://example.com/ep.mp3',
  int retryCount = 0,
}) {
  return DownloadTask()
    ..id = id
    ..episodeId = episodeId
    ..audioUrl = audioUrl
    ..status = 0
    ..retryCount = retryCount
    ..wifiOnly = false
    ..downloadedBytes = 0
    ..createdAt = DateTime.now();
}

Episode _episode({required int id, String title = 'Episode'}) {
  return Episode()
    ..id = id
    ..podcastId = 1
    ..guid = 'guid-$id'
    ..title = title
    ..audioUrl = 'https://example.com/ep$id.mp3';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late _FakeDownloadRepository downloadRepo;
  late _FakeEpisodeRepository episodeRepo;
  late String downloadsDir;

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    downloadRepo = _FakeDownloadRepository();
    episodeRepo = _FakeEpisodeRepository();
    downloadsDir = Directory.systemTemp
        .createTempSync('audiflow_test_downloads_')
        .path;
  });

  tearDown(() {
    final dir = Directory(downloadsDir);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  BackgroundDownloadService createService({
    Duration timeBudget = const Duration(minutes: 5),
    bool isOnWifi = false,
  }) {
    return BackgroundDownloadService(
      downloadRepo: downloadRepo,
      episodeRepo: episodeRepo,
      dio: dio,
      downloadsDir: downloadsDir,
      timeBudget: timeBudget,
      isOnWifi: isOnWifi,
    );
  }

  group('BackgroundDownloadService', () {
    test('returns 0 when no pending tasks', () async {
      final service = createService();
      final count = await service.execute();
      check(count).equals(0);
    });

    test('downloads pending task and marks completed', () async {
      downloadRepo.pending.add(_task(id: 1, episodeId: 10));
      episodeRepo.episodes[10] = _episode(id: 10, title: 'Test Episode');

      dioAdapter.onGet(
        'https://example.com/ep.mp3',
        (server) => server.reply(200, ''),
      );

      final service = createService();
      final count = await service.execute();

      check(count).equals(1);

      // Status should transition: downloading -> completed
      check(downloadRepo.statusUpdates.length).equals(2);
      check(
        downloadRepo.statusUpdates[0].status,
      ).isA<DownloadStatusDownloading>();
      check(
        downloadRepo.statusUpdates[1].status,
      ).isA<DownloadStatusCompleted>();
      check(downloadRepo.statusUpdates[1].localPath).isNotNull();
    });

    test('processes multiple pending tasks', () async {
      downloadRepo.pending.addAll([
        _task(id: 1, episodeId: 10, audioUrl: 'https://example.com/a.mp3'),
        _task(id: 2, episodeId: 20, audioUrl: 'https://example.com/b.mp3'),
      ]);
      episodeRepo.episodes[10] = _episode(id: 10, title: 'Ep A');
      episodeRepo.episodes[20] = _episode(id: 20, title: 'Ep B');

      dioAdapter
        ..onGet('https://example.com/a.mp3', (server) => server.reply(200, ''))
        ..onGet('https://example.com/b.mp3', (server) => server.reply(200, ''));

      final service = createService();
      final count = await service.execute();

      check(count).equals(2);
      // Each task: downloading + completed = 2 updates
      check(downloadRepo.statusUpdates.length).equals(4);
    });

    test('handles missing episode by setting error and continuing', () async {
      downloadRepo.pending.add(_task(id: 1, episodeId: 99));
      // No episode in episodeRepo for id 99

      final service = createService();
      final count = await service.execute();

      check(count).equals(0);
      // downloading + error handling (pending with lastError or failed)
      final errorUpdates = downloadRepo.statusUpdates
          .where(
            (u) =>
                u.status is DownloadStatusPending ||
                u.status is DownloadStatusFailed,
          )
          .toList();
      check(errorUpdates).isNotEmpty();
    });

    test('increments retry count on error and breaks', () async {
      downloadRepo.pending.add(_task(id: 1, episodeId: 10, retryCount: 0));
      episodeRepo.episodes[10] = _episode(id: 10);

      dioAdapter.onGet(
        'https://example.com/ep.mp3',
        (server) => server.throws(
          0,
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: ''),
            message: 'No connection',
          ),
        ),
      );

      final service = createService();
      final count = await service.execute();

      check(count).equals(0);
      check(downloadRepo.incrementedRetryIds).contains(1);
      // Service breaks after first failure to avoid tight retry loop.
      // Task stays pending for the next background run.
      check(downloadRepo.incrementedRetryIds.length).equals(1);
      final lastStatus = downloadRepo.statusUpdates.last;
      check(lastStatus.status).isA<DownloadStatusPending>();
      check(lastStatus.lastError).isNotNull();
    });

    test('marks failed after max retries exhausted', () async {
      downloadRepo.pending.add(_task(id: 1, episodeId: 10, retryCount: 5));
      episodeRepo.episodes[10] = _episode(id: 10);

      dioAdapter.onGet(
        'https://example.com/ep.mp3',
        (server) => server.throws(
          0,
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: ''),
            message: 'No connection',
          ),
        ),
      );

      final service = createService();
      await service.execute();

      // Should be marked as failed (retryCount 5 >= _maxRetryAttempts 5)
      final lastStatus = downloadRepo.statusUpdates.last;
      check(lastStatus.status).isA<DownloadStatusFailed>();
    });

    test('respects time budget and stops early', () async {
      downloadRepo.pending.add(_task(id: 1, episodeId: 10));
      episodeRepo.episodes[10] = _episode(id: 10);

      final service = createService(timeBudget: Duration.zero);
      final count = await service.execute();

      check(count).equals(0);
      check(downloadRepo.statusUpdates).isEmpty();
    });

    test(
      'builds local path with sanitized filename and correct extension',
      () async {
        downloadRepo.pending.add(
          _task(
            id: 1,
            episodeId: 10,
            audioUrl: 'https://example.com/audio/episode.m4a',
          ),
        );
        episodeRepo.episodes[10] = _episode(
          id: 10,
          title: 'My Episode: "Special" Edition!',
        );

        dioAdapter.onGet(
          'https://example.com/audio/episode.m4a',
          (server) => server.reply(200, ''),
        );

        final service = createService();
        await service.execute();

        final completedUpdate = downloadRepo.statusUpdates
            .where((u) => u.status is DownloadStatusCompleted)
            .first;
        final path = completedUpdate.localPath!;

        check(path).endsWith('.m4a');
        check(path).not((it) => it.contains('"'));
        check(path).contains('10_');
      },
    );
  });
}
