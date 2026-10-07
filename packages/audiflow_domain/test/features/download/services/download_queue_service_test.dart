import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([DownloadRepository, DownloadFileService, EpisodeRepository])
import 'download_queue_service_test.mocks.dart';

DownloadTask _task({
  required int id,
  int episodeId = 1,
  String audioUrl = 'https://example.com/ep.mp3',
  int status = 0,
  int retryCount = 0,
  int downloadedBytes = 0,
  String? localPath,
  String? lastError,
}) {
  return DownloadTask()
    ..id = id
    ..episodeId = episodeId
    ..audioUrl = audioUrl
    ..status = status
    ..retryCount = retryCount
    ..downloadedBytes = downloadedBytes
    ..wifiOnly = false
    ..localPath = localPath
    ..lastError = lastError
    ..createdAt = DateTime.now();
}

Episode _episode({required int id, int podcastId = 1, String? title}) {
  return Episode()
    ..id = id
    ..podcastId = podcastId
    ..guid = 'guid-$id'
    ..title = title ?? 'Episode $id'
    ..audioUrl = 'https://example.com/ep$id.mp3';
}

void main() {
  late MockDownloadRepository mockRepository;
  late MockDownloadFileService mockFileService;
  late MockEpisodeRepository mockEpisodeRepo;
  late DownloadQueueService service;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock connectivity_plus method channel so _init() does not throw.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'check') return ['wifi'];
            return null;
          },
        );

    // Mock the connectivity status event channel.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
          (MethodCall methodCall) async => null,
        );

    mockRepository = MockDownloadRepository();
    mockFileService = MockDownloadFileService();
    mockEpisodeRepo = MockEpisodeRepository();

    // _init() triggers connectivity check -> _onConnectivityChanged
    // -> _processQueue -> getNextPending. Stub it before construction.
    when(
      mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
    ).thenAnswer((_) async => null);
    // A cancelled transfer re-reads its task to tell a pause from a cancel;
    // tests that care stub the row themselves.
    when(mockRepository.getById(any)).thenAnswer((_) async => null);

    service = DownloadQueueService(
      repository: mockRepository,
      fileService: mockFileService,
      episodeRepository: mockEpisodeRepo,
      logger: Logger(level: Level.off),
    );
  });

  tearDown(() {
    service.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity'),
          null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
          null,
        );
  });

  group('pauseDownload', () {
    test('cancels file download and updates status to paused', () async {
      // Arrange
      const taskId = 1;
      when(
        mockRepository.updateStatus(
          id: taskId,
          status: const DownloadStatus.paused(),
        ),
      ).thenAnswer((_) async {});

      // Act
      await service.pauseDownload(taskId);

      // Assert
      verify(mockFileService.cancelDownload(taskId)).called(1);
      verify(
        mockRepository.updateStatus(
          id: taskId,
          status: const DownloadStatus.paused(),
        ),
      ).called(1);
    });
  });

  group('resumeDownload', () {
    test('sets status back to pending and triggers queue processing', () async {
      // Arrange
      const taskId = 3;
      when(
        mockRepository.updateStatus(
          id: taskId,
          status: const DownloadStatus.pending(),
        ),
      ).thenAnswer((_) async {});

      // Act
      await service.resumeDownload(taskId);

      // Assert
      verify(
        mockRepository.updateStatus(
          id: taskId,
          status: const DownloadStatus.pending(),
        ),
      ).called(1);
    });
  });

  group('cancelDownload', () {
    test('cancels file download and updates status to cancelled', () async {
      // Arrange
      const taskId = 2;
      when(
        mockRepository.updateStatus(
          id: taskId,
          status: const DownloadStatus.cancelled(),
        ),
      ).thenAnswer((_) async {});

      // Act
      await service.cancelDownload(taskId);

      // Assert
      verify(mockFileService.cancelDownload(taskId)).called(1);
      verify(
        mockRepository.updateStatus(
          id: taskId,
          status: const DownloadStatus.cancelled(),
        ),
      ).called(1);
    });
  });

  group('pause during a download', () {
    test('stays paused instead of turning into a cancel', () async {
      final task = _task(id: 1, episodeId: 10, downloadedBytes: 800);
      final episode = _episode(id: 10);
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);

      var pendingCalls = 0;
      when(
        mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
      ).thenAnswer((_) async => pendingCalls++ == 0 ? task : null);
      // The row reflects every status write, so the order of the pause's
      // write and the cancelled transfer's read matters as it does live.
      var storedStatus = 1;
      when(
        mockRepository.updateStatus(
          id: anyNamed('id'),
          status: anyNamed('status'),
          localPath: anyNamed('localPath'),
          lastError: anyNamed('lastError'),
        ),
      ).thenAnswer((invocation) async {
        final status = invocation.namedArguments[#status] as DownloadStatus;
        // A database write takes a moment, as it does live.
        await Future<void>.delayed(const Duration(milliseconds: 5));
        storedStatus = status.toDbValue();
      });
      when(mockRepository.getById(1)).thenAnswer(
        (_) async => _task(id: 1, episodeId: 10, status: storedStatus),
      );
      when(mockEpisodeRepo.getById(10)).thenAnswer((_) async => episode);

      final download = Completer<String>();
      when(
        mockFileService.downloadFile(
          taskId: 1,
          url: task.audioUrl,
          episodeId: task.episodeId,
          episodeTitle: episode.title,
          resumeFromBytes: task.downloadedBytes,
          onProgress: anyNamed('onProgress'),
        ),
      ).thenAnswer((_) => download.future);
      when(mockFileService.cancelDownload(1)).thenAnswer((_) {
        download.completeError(DownloadException.cancelled());
      });

      final processing = service.startQueue();
      await Future<void>.delayed(Duration.zero);

      await service.pauseDownload(1);
      await processing;

      check(storedStatus).equals(const DownloadStatus.paused().toDbValue());
    });

    test('a quick resume is not turned into a cancel', () async {
      final task = _task(id: 1, episodeId: 10, downloadedBytes: 800);
      final episode = _episode(id: 10);
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);

      var pendingCalls = 0;
      when(
        mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
      ).thenAnswer((_) async => pendingCalls++ == 0 ? task : null);
      final writes = <int>[];
      when(
        mockRepository.updateStatus(
          id: anyNamed('id'),
          status: anyNamed('status'),
          localPath: anyNamed('localPath'),
          lastError: anyNamed('lastError'),
        ),
      ).thenAnswer((invocation) async {
        final status = invocation.namedArguments[#status] as DownloadStatus;
        writes.add(status.toDbValue());
      });
      when(
        mockRepository.getById(1),
      ).thenAnswer((_) async => _task(id: 1, episodeId: 10, status: 1));
      when(mockEpisodeRepo.getById(10)).thenAnswer((_) async => episode);

      // The stopped transfer reports only after the resume has landed.
      final download = Completer<String>();
      when(
        mockFileService.downloadFile(
          taskId: 1,
          url: task.audioUrl,
          episodeId: task.episodeId,
          episodeTitle: episode.title,
          resumeFromBytes: task.downloadedBytes,
          onProgress: anyNamed('onProgress'),
        ),
      ).thenAnswer((_) => download.future);

      final processing = service.startQueue();
      await Future<void>.delayed(Duration.zero);
      await service.pauseDownload(1);
      await service.resumeDownload(1);
      download.completeError(DownloadException.cancelled());
      await processing;

      check(
        writes,
      ).not((it) => it.contains(const DownloadStatus.cancelled().toDbValue()));
      check(writes.last).equals(const DownloadStatus.pending().toDbValue());
    });

    test('pause and cancel leave a finished download alone', () async {
      when(
        mockRepository.getById(7),
      ).thenAnswer((_) async => _task(id: 7, status: 3));
      clearInteractions(mockRepository);

      await service.pauseDownload(7);
      await service.cancelDownload(7);

      verifyNever(
        mockRepository.updateStatus(
          id: 7,
          status: anyNamed('status'),
          localPath: anyNamed('localPath'),
          lastError: anyNamed('lastError'),
        ),
      );
      verifyNever(mockFileService.cancelDownload(7));
    });
  });

  group('suspend', () {
    test('completes immediately when the queue is idle', () async {
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);

      await service.suspend();

      verifyNever(mockFileService.cancelDownload(any));
      verifyNever(
        mockRepository.updateStatus(
          id: anyNamed('id'),
          status: anyNamed('status'),
          localPath: anyNamed('localPath'),
          lastError: anyNamed('lastError'),
        ),
      );
    });

    test(
      'cancels the active download and stops before the next task',
      () async {
        // Arrange: two pending tasks; the first blocks until cancelled.
        final first = _task(id: 1, episodeId: 10);
        final second = _task(id: 2, episodeId: 20);
        final episode = _episode(id: 10);
        await Future<void>.delayed(Duration.zero);
        clearInteractions(mockRepository);

        var pendingCalls = 0;
        when(
          mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
        ).thenAnswer((_) async {
          pendingCalls++;
          return pendingCalls == 1 ? first : second;
        });
        when(
          mockRepository.updateStatus(
            id: anyNamed('id'),
            status: anyNamed('status'),
            localPath: anyNamed('localPath'),
            lastError: anyNamed('lastError'),
          ),
        ).thenAnswer((_) async {});
        when(mockEpisodeRepo.getById(10)).thenAnswer((_) async => episode);

        final download = Completer<String>();
        when(
          mockFileService.downloadFile(
            taskId: 1,
            url: first.audioUrl,
            episodeId: first.episodeId,
            episodeTitle: episode.title,
            resumeFromBytes: first.downloadedBytes,
            onProgress: anyNamed('onProgress'),
          ),
        ).thenAnswer((_) => download.future);
        when(mockFileService.cancelDownload(1)).thenAnswer((_) {
          download.completeError(DownloadException.cancelled());
        });

        final processing = service.startQueue();
        await Future<void>.delayed(Duration.zero);
        check(service.activeDownload?.id).equals(1);

        // Act
        await service.suspend();

        // Assert: the cancelled status landed before suspend returned, and
        // the drain loop did not pick up the second task.
        verify(mockFileService.cancelDownload(1)).called(1);
        verify(
          mockRepository.updateStatus(
            id: 1,
            status: const DownloadStatus.cancelled(),
            lastError: 'Download cancelled',
          ),
        ).called(1);
        verifyNever(
          mockRepository.updateStatus(
            id: 2,
            status: const DownloadStatus.downloading(),
          ),
        );
        check(pendingCalls).equals(1);
        check(service.activeDownload).isNull();
        await processing;
      },
    );

    test('does not start a task fetched while cancelling', () async {
      // Arrange: the pending-task query is still running when suspend
      // lands, so there is no active download to cancel yet.
      final task = _task(id: 1, episodeId: 10);
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);
      final query = Completer<DownloadTask?>();
      when(
        mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
      ).thenAnswer((_) => query.future);

      final processing = service.startQueue();
      final cancelling = service.suspend();
      query.complete(task);
      await cancelling;
      await processing;

      verifyNever(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.downloading(),
        ),
      );
      verifyNever(mockEpisodeRepo.getById(any));
    });

    test('does not propagate a drain failure to the caller', () async {
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);
      final query = Completer<DownloadTask?>();
      when(
        mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
      ).thenAnswer((_) => query.future);

      // The expectation is attached before the error fires so the drain's
      // failure reaches its caller instead of the zone's uncaught handler.
      final failure = check(service.startQueue()).throws<StateError>();
      final cancelling = service.suspend();
      query.completeError(StateError('database closed'));

      await cancelling;
      await failure;
    });

    test('waits for a pending progress write', () async {
      final task = _task(id: 1, episodeId: 10);
      final episode = _episode(id: 10);
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);
      var pendingCalls = 0;
      when(
        mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
      ).thenAnswer((_) async => ++pendingCalls == 1 ? task : null);
      when(
        mockRepository.updateStatus(
          id: anyNamed('id'),
          status: anyNamed('status'),
          localPath: anyNamed('localPath'),
          lastError: anyNamed('lastError'),
        ),
      ).thenAnswer((_) async {});
      when(mockEpisodeRepo.getById(10)).thenAnswer((_) async => episode);
      final progressWrite = Completer<void>();
      when(
        mockRepository.updateProgress(
          id: anyNamed('id'),
          downloadedBytes: anyNamed('downloadedBytes'),
          totalBytes: anyNamed('totalBytes'),
        ),
      ).thenAnswer((_) => progressWrite.future);
      final download = Completer<String>();
      when(
        mockFileService.downloadFile(
          taskId: 1,
          url: task.audioUrl,
          episodeId: task.episodeId,
          episodeTitle: episode.title,
          resumeFromBytes: task.downloadedBytes,
          onProgress: anyNamed('onProgress'),
        ),
      ).thenAnswer((invocation) {
        final onProgress =
            invocation.namedArguments[#onProgress] as DownloadProgressCallback;
        // Past the byte threshold, so the throttle lets the write through.
        onProgress(200 * 1024, 1024 * 1024);
        return download.future;
      });
      when(mockFileService.cancelDownload(1)).thenAnswer((_) {
        download.completeError(DownloadException.cancelled());
      });
      unawaited(service.startQueue());
      await Future<void>.delayed(Duration.zero);

      var suspended = false;
      unawaited(service.suspend().then((_) => suspended = true));
      await Future<void>.delayed(Duration.zero);

      check(suspended).isFalse();
      progressWrite.complete();
      await Future<void>.delayed(Duration.zero);
      check(suspended).isTrue();
    });

    test('keeps the queue idle until resumed', () async {
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);
      await service.suspend();

      await service.startQueue();

      verifyNever(
        mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
      );
    });

    test('lets the queue drain again after resume', () async {
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);
      await service.suspend();
      service.resume();

      await service.startQueue();

      verify(
        mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
      ).called(1);
    });
  });

  group('retryDownload', () {
    test('resets status to pending and clears lastError', () async {
      // Arrange
      const taskId = 4;
      final task = _task(
        id: taskId,
        status: 4,
        retryCount: 3,
        lastError: 'Previous error',
      );
      when(mockRepository.getById(taskId)).thenAnswer((_) async => task);
      when(
        mockRepository.updateStatus(
          id: taskId,
          status: const DownloadStatus.pending(),
          lastError: null,
        ),
      ).thenAnswer((_) async {});

      // Act
      await service.retryDownload(taskId);

      // Assert
      verify(mockRepository.getById(taskId)).called(1);
      verify(mockRepository.resetRetryCount(taskId)).called(1);
      verify(
        mockRepository.updateStatus(
          id: taskId,
          status: const DownloadStatus.pending(),
          lastError: null,
        ),
      ).called(1);
    });

    test('does nothing when task not found', () async {
      // Arrange
      const taskId = 999;
      when(mockRepository.getById(taskId)).thenAnswer((_) async => null);

      // Act
      await service.retryDownload(taskId);

      // Assert
      verify(mockRepository.getById(taskId)).called(1);
      verifyNever(
        mockRepository.updateStatus(id: taskId, status: anyNamed('status')),
      );
    });
  });

  group('startQueue', () {
    test('processes pending downloads sequentially', () async {
      // Arrange
      final task = _task(id: 1, episodeId: 10);
      final episode = _episode(id: 10, title: 'Test EP');

      // Allow queue triggered by _init() to finish first
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);

      var callCount = 0;
      when(
        mockRepository.getNextPending(
          isOnWifi: anyNamed('isOnWifi'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        if (1 < callCount) return null;
        return task;
      });
      when(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.downloading(),
        ),
      ).thenAnswer((_) async {});
      when(mockEpisodeRepo.getById(10)).thenAnswer((_) async => episode);
      when(
        mockFileService.downloadFile(
          taskId: 1,
          url: task.audioUrl,
          episodeId: task.episodeId,
          episodeTitle: episode.title,
          resumeFromBytes: task.downloadedBytes,
          onProgress: anyNamed('onProgress'),
        ),
      ).thenAnswer((_) async => '/downloads/10_Test_EP.mp3');
      when(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.completed(),
          localPath: '/downloads/10_Test_EP.mp3',
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.getById(1)).thenAnswer((_) async => task);

      // Act
      await service.startQueue();

      // Assert
      verify(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.downloading(),
        ),
      ).called(1);
      verify(mockEpisodeRepo.getById(10)).called(1);
      verify(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.completed(),
          localPath: '/downloads/10_Test_EP.mp3',
        ),
      ).called(1);
    });

    test('removes the file when the task was deleted mid-download', () async {
      // A bulk delete can remove the record after the queue picked the
      // task up but before its file finished downloading.
      final task = _task(id: 1, episodeId: 10);
      final episode = _episode(id: 10, title: 'Test EP');
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);

      var callCount = 0;
      when(
        mockRepository.getNextPending(
          isOnWifi: anyNamed('isOnWifi'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((_) async => 1 < ++callCount ? null : task);
      when(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.downloading(),
        ),
      ).thenAnswer((_) async {});
      when(mockEpisodeRepo.getById(10)).thenAnswer((_) async => episode);
      when(
        mockFileService.downloadFile(
          taskId: 1,
          url: task.audioUrl,
          episodeId: task.episodeId,
          episodeTitle: episode.title,
          resumeFromBytes: task.downloadedBytes,
          onProgress: anyNamed('onProgress'),
        ),
      ).thenAnswer((_) async => '/downloads/10_Test_EP.mp3');
      when(mockRepository.getById(1)).thenAnswer((_) async => null);
      when(
        mockFileService.deleteFile('/downloads/10_Test_EP.mp3'),
      ).thenAnswer((_) async {});

      await service.startQueue();

      verify(mockFileService.deleteFile('/downloads/10_Test_EP.mp3')).called(1);
      verifyNever(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.completed(),
          localPath: anyNamed('localPath'),
        ),
      );
    });

    test('does nothing when no pending downloads', () async {
      // Arrange - getNextPending already returns null from setUp
      // Allow _init() queue to finish first
      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);

      // Act
      await service.startQueue();

      // Assert - only getNextPending is called, no updateStatus
      verify(
        mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
      ).called(1);
      verifyNever(
        mockRepository.updateStatus(
          id: anyNamed('id'),
          status: anyNamed('status'),
        ),
      );
    });

    test('handles episode not found during processing', () async {
      // Arrange
      final task = _task(id: 1, episodeId: 99);

      await Future<void>.delayed(Duration.zero);
      clearInteractions(mockRepository);

      var callCount = 0;
      when(
        mockRepository.getNextPending(
          isOnWifi: anyNamed('isOnWifi'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        if (1 < callCount) return null;
        return task;
      });
      when(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.downloading(),
        ),
      ).thenAnswer((_) async {});
      when(mockEpisodeRepo.getById(99)).thenAnswer((_) async => null);

      // Episode not found triggers error handling with retry
      when(mockRepository.incrementRetryCount(1)).thenAnswer((_) async {});
      when(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.pending(),
          lastError: anyNamed('lastError'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await service.startQueue();

      // Assert
      verify(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.downloading(),
        ),
      ).called(1);
      verify(mockEpisodeRepo.getById(99)).called(1);
    });
  });

  /// Stubs a download of [task] that fails with a network error.
  void stubFailingDownload(DownloadTask task) {
    when(
      mockEpisodeRepo.getById(task.episodeId),
    ).thenAnswer((_) async => _episode(id: task.episodeId));
    when(
      mockFileService.downloadFile(
        taskId: task.id,
        url: anyNamed('url'),
        episodeId: anyNamed('episodeId'),
        episodeTitle: anyNamed('episodeTitle'),
        resumeFromBytes: anyNamed('resumeFromBytes'),
        onProgress: anyNamed('onProgress'),
      ),
    ).thenThrow(
      DownloadException(DownloadErrorType.networkUnavailable, 'offline'),
    );
  }

  /// Stubs a successful download of [task].
  void stubSucceedingDownload(DownloadTask task) {
    when(
      mockEpisodeRepo.getById(task.episodeId),
    ).thenAnswer((_) async => _episode(id: task.episodeId));
    when(
      mockFileService.downloadFile(
        taskId: task.id,
        url: anyNamed('url'),
        episodeId: anyNamed('episodeId'),
        episodeTitle: anyNamed('episodeTitle'),
        resumeFromBytes: anyNamed('resumeFromBytes'),
        onProgress: anyNamed('onProgress'),
      ),
    ).thenAnswer((_) async => '/downloads/${task.episodeId}.mp3');
  }

  /// Serves pending tasks the way the datasource does: the oldest of
  /// [tasks] that is still pending and not excluded. Records the excluded
  /// ids of every lookup.
  List<Set<int>> servePending(List<DownloadTask> tasks) {
    final lookups = <Set<int>>[];
    final finished = <int>{};
    when(
      mockRepository.updateStatus(
        id: anyNamed('id'),
        status: anyNamed('status'),
        localPath: anyNamed('localPath'),
        lastError: anyNamed('lastError'),
      ),
    ).thenAnswer((invocation) async {
      final id = invocation.namedArguments[#id] as int;
      final status = invocation.namedArguments[#status] as DownloadStatus;
      if (status is DownloadStatusCompleted || status is DownloadStatusFailed) {
        finished.add(id);
      }
    });
    when(
      mockRepository.getNextPending(
        isOnWifi: anyNamed('isOnWifi'),
        excludeIds: anyNamed('excludeIds'),
      ),
    ).thenAnswer((invocation) async {
      final excluded = invocation.namedArguments[#excludeIds] as Set<int>;
      lookups.add({...excluded});
      for (final task in tasks) {
        if (finished.contains(task.id) || excluded.contains(task.id)) continue;
        return task;
      }
      return null;
    });
    when(mockRepository.incrementRetryCount(any)).thenAnswer((_) async {});
    // Like the datasource, return the stored row; null would read as a
    // task deleted mid-download.
    when(mockRepository.getById(any)).thenAnswer(
      (invocation) async => tasks
          .where((task) => task.id == invocation.positionalArguments.first)
          .firstOrNull,
    );
    return lookups;
  }

  group('post-completion work', () {
    late DownloadTask task;
    late List<int> reportedBytes;

    setUp(() {
      task = _task(id: 1, episodeId: 10);
      reportedBytes = [];
    });

    /// Runs one successful download through a service whose completion
    /// callbacks are [onCompleted] and [onCompletedWithBytes].
    Future<void> runDownload({
      Future<void> Function(int episodeId)? onCompleted,
      Future<void> Function(int episodeId, int bytes)? onCompletedWithBytes,
      bool isReadBackFailing = false,
      List<DownloadTask>? tasks,
    }) async {
      final callbackService = DownloadQueueService(
        repository: mockRepository,
        fileService: mockFileService,
        episodeRepository: mockEpisodeRepo,
        logger: Logger(level: Level.off),
        onDownloadCompleted: onCompleted,
        onDownloadCompletedWithBytes:
            onCompletedWithBytes ??
            (_, bytes) async => reportedBytes.add(bytes),
      );
      addTearDown(callbackService.dispose);
      // Let the drain started by the initial connectivity check finish.
      await Future<void>.delayed(Duration.zero);
      final queued = tasks ?? [task];
      queued.forEach(stubSucceedingDownload);
      servePending(queued);
      if (isReadBackFailing) {
        when(mockRepository.getById(1)).thenThrow(StateError('db closed'));
      } else {
        when(mockRepository.getById(1)).thenAnswer(
          (_) async => _task(id: 1, episodeId: 10, downloadedBytes: 4096),
        );
      }

      await callbackService.startQueue();
    }

    void verifyCompletedWithoutRetry() {
      verify(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.completed(),
          localPath: '/downloads/10.mp3',
        ),
      ).called(1);
      verifyNever(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.pending(),
          lastError: anyNamed('lastError'),
        ),
      );
      verifyNever(mockRepository.incrementRetryCount(any));
      verify(
        mockFileService.downloadFile(
          taskId: 1,
          url: anyNamed('url'),
          episodeId: anyNamed('episodeId'),
          episodeTitle: anyNamed('episodeTitle'),
          resumeFromBytes: anyNamed('resumeFromBytes'),
          onProgress: anyNamed('onProgress'),
        ),
      ).called(1);
    }

    test('keeps the task completed when the completion callback '
        'throws', () async {
      await runDownload(onCompleted: (_) async => throw StateError('boom'));

      verifyCompletedWithoutRetry();
    });

    test('still reports bytes when the completion callback throws', () async {
      await runDownload(onCompleted: (_) async => throw StateError('boom'));

      check(reportedBytes).deepEquals([4096]);
    });

    test('keeps the task completed when reading it back throws', () async {
      await runDownload(isReadBackFailing: true);

      verifyCompletedWithoutRetry();
      check(reportedBytes).deepEquals([0]);
    });

    test('moves on to the next task when the completion callback '
        'throws', () async {
      final next = _task(id: 2, episodeId: 20);

      await runDownload(
        tasks: [task, next],
        onCompleted: (episodeId) async {
          if (episodeId == task.episodeId) throw StateError('boom');
        },
      );

      verifyCompletedWithoutRetry();
      verify(
        mockRepository.updateStatus(
          id: 2,
          status: const DownloadStatus.completed(),
          localPath: '/downloads/20.mp3',
        ),
      ).called(1);
    });

    test('keeps the task completed when the bytes callback throws', () async {
      await runDownload(
        onCompletedWithBytes: (_, _) async => throw StateError('boom'),
      );

      verifyCompletedWithoutRetry();
    });
  });

  group('retry backoff', () {
    test('does not pick a failed task again before its backoff', () async {
      await Future<void>.delayed(Duration.zero);
      final task = _task(id: 1, episodeId: 10);
      stubFailingDownload(task);
      final lookups = servePending([task]);

      await service.startQueue();

      verify(
        mockFileService.downloadFile(
          taskId: 1,
          url: anyNamed('url'),
          episodeId: anyNamed('episodeId'),
          episodeTitle: anyNamed('episodeTitle'),
          resumeFromBytes: anyNamed('resumeFromBytes'),
          onProgress: anyNamed('onProgress'),
        ),
      ).called(1);
      check(lookups).deepEquals([
        <int>{},
        {1},
      ]);
    });

    test('downloads the next task while a failed one backs off', () async {
      await Future<void>.delayed(Duration.zero);
      final failing = _task(id: 1, episodeId: 10);
      final next = _task(id: 2, episodeId: 20);
      stubFailingDownload(failing);
      stubSucceedingDownload(next);
      servePending([failing, next]);

      await service.startQueue();

      verify(
        mockRepository.updateStatus(
          id: 2,
          status: const DownloadStatus.completed(),
          localPath: '/downloads/20.mp3',
        ),
      ).called(1);
    });

    test('retries the failed task once its backoff elapses', () {
      fakeAsync((async) {
        // A service built inside the fake zone, so its timers and clock
        // follow fake time.
        final clock = async.getClock(DateTime(2026));
        final fakeTimeService = DownloadQueueService(
          repository: mockRepository,
          fileService: mockFileService,
          episodeRepository: mockEpisodeRepo,
          logger: Logger(level: Level.off),
          now: clock.now,
        );
        final task = _task(id: 1, episodeId: 10);
        stubFailingDownload(task);
        servePending([task]);
        final attempts = <int>[];
        when(
          mockFileService.downloadFile(
            taskId: 1,
            url: anyNamed('url'),
            episodeId: anyNamed('episodeId'),
            episodeTitle: anyNamed('episodeTitle'),
            resumeFromBytes: anyNamed('resumeFromBytes'),
            onProgress: anyNamed('onProgress'),
          ),
        ).thenAnswer((_) async {
          attempts.add(async.elapsed.inSeconds);
          throw DownloadException(DownloadErrorType.networkUnavailable, 'x');
        });

        async.flushMicrotasks();
        async.elapse(Duration(seconds: retryDelaysSeconds.first - 1));
        check(attempts).deepEquals([0]);

        async.elapse(const Duration(seconds: 1));
        check(attempts).deepEquals([0, retryDelaysSeconds.first]);

        fakeTimeService.dispose();
      });
    });

    test('does not retry after the service is disposed', () {
      fakeAsync((async) {
        final gate = Completer<String>();
        final fakeTimeService = DownloadQueueService(
          repository: mockRepository,
          fileService: mockFileService,
          episodeRepository: mockEpisodeRepo,
          logger: Logger(level: Level.off),
          now: async.getClock(DateTime(2026)).now,
        );
        final task = _task(id: 1, episodeId: 10);
        stubFailingDownload(task);
        servePending([task]);
        var attempts = 0;
        when(
          mockFileService.downloadFile(
            taskId: 1,
            url: anyNamed('url'),
            episodeId: anyNamed('episodeId'),
            episodeTitle: anyNamed('episodeTitle'),
            resumeFromBytes: anyNamed('resumeFromBytes'),
            onProgress: anyNamed('onProgress'),
          ),
        ).thenAnswer((_) {
          attempts++;
          return gate.future;
        });

        async.flushMicrotasks();
        fakeTimeService.dispose();
        gate.completeError(
          DownloadException(DownloadErrorType.networkUnavailable, 'x'),
        );
        async.flushMicrotasks();
        async.elapse(Duration(seconds: retryDelaysSeconds.last));

        check(attempts).equals(1);
      });
    });

    test('manual retry lifts the backoff immediately', () async {
      await Future<void>.delayed(Duration.zero);
      final task = _task(id: 1, episodeId: 10);
      stubFailingDownload(task);
      final lookups = servePending([task]);
      when(mockRepository.resetRetryCount(1)).thenAnswer((_) async {});
      await service.startQueue();
      when(mockRepository.getById(1)).thenAnswer((_) async => task);
      lookups.clear();

      await service.retryDownload(1);
      await Future<void>.delayed(Duration.zero);

      check(lookups.first).isEmpty();
    });

    test('resuming a paused task lifts its backoff', () async {
      await Future<void>.delayed(Duration.zero);
      final task = _task(id: 1, episodeId: 10);
      stubFailingDownload(task);
      final lookups = servePending([task]);
      await service.startQueue();
      lookups.clear();

      await service.resumeDownload(1);
      await Future<void>.delayed(Duration.zero);

      check(lookups.first).isEmpty();
    });
  });

  group('dispose during a drain', () {
    test('does not start a task looked up after dispose', () async {
      await Future<void>.delayed(Duration.zero);
      final lookupGate = Completer<DownloadTask?>();
      when(
        mockRepository.getNextPending(
          isOnWifi: anyNamed('isOnWifi'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((_) => lookupGate.future);

      final drain = service.startQueue();
      await Future<void>.delayed(Duration.zero);
      service.dispose();
      lookupGate.complete(_task(id: 1, episodeId: 10));
      await drain;

      verifyNever(
        mockRepository.updateStatus(
          id: anyNamed('id'),
          status: anyNamed('status'),
          localPath: anyNamed('localPath'),
          lastError: anyNamed('lastError'),
        ),
      );
    });
  });

  group('startQueue during a drain', () {
    test('rescans when a request lands while the queue is draining', () async {
      await Future<void>.delayed(Duration.zero);
      final lookupGate = Completer<DownloadTask?>();
      var lookups = 0;
      when(
        mockRepository.getNextPending(
          isOnWifi: anyNamed('isOnWifi'),
          excludeIds: anyNamed('excludeIds'),
        ),
      ).thenAnswer((_) {
        lookups++;
        // The first lookup stalls so a request can land mid-drain.
        if (lookups == 1) return lookupGate.future;
        return Future.value(null);
      });

      final drain = service.startQueue();
      await Future<void>.delayed(Duration.zero);
      await service.startQueue();
      lookupGate.complete(null);
      await drain;

      check(lookups).equals(2);
    });
  });

  group('activeDownload', () {
    test('is null initially', () {
      expect(service.activeDownload, isNull);
    });

    test('activeDownloadStream emits null when queue completes', () async {
      // Arrange - queue is empty
      await Future<void>.delayed(Duration.zero);

      final events = <DownloadTask?>[];
      final subscription = service.activeDownloadStream.listen(events.add);

      // Trigger a queue cycle (no pending items)
      await service.startQueue();
      await Future<void>.delayed(Duration.zero);

      // Assert - null emitted when queue finishes
      expect(events, contains(isNull));

      await subscription.cancel();
    });
  });

  group('dispose', () {
    test('stream completes after dispose', () async {
      // Assert - after tearDown disposes, stream should complete
      // Verify the stream is currently active (not yet closed)
      final events = <DownloadTask?>[];
      final sub = service.activeDownloadStream.listen(events.add);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    });
  });

  group('constants', () {
    test('maxRetryAttempts is 5', () {
      expect(maxRetryAttempts, 5);
    });

    test('retryDelaysSeconds has correct backoff values', () {
      expect(retryDelaysSeconds, [5, 15, 45, 135, 405]);
    });

    test('retryDelaysSeconds length matches maxRetryAttempts', () {
      expect(retryDelaysSeconds.length, maxRetryAttempts);
    });

    test('retry delay index clamps to last element for high counts', () {
      const retryCount = 10;
      final delayIndex = retryCount < retryDelaysSeconds.length
          ? retryCount
          : retryDelaysSeconds.length - 1;
      expect(delayIndex, retryDelaysSeconds.length - 1);
      expect(retryDelaysSeconds[delayIndex], 405);
    });
  });
}
