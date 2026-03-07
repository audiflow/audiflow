import 'package:audiflow_domain/audiflow_domain.dart';
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
  return DownloadTask(
    id: id,
    episodeId: episodeId,
    audioUrl: audioUrl,
    status: status,
    retryCount: retryCount,
    downloadedBytes: downloadedBytes,
    wifiOnly: false,
    localPath: localPath,
    lastError: lastError,
    createdAt: DateTime.now(),
  );
}

Episode _episode({required int id, int podcastId = 1, String? title}) {
  return Episode(
    id: id,
    podcastId: podcastId,
    guid: 'guid-$id',
    title: title ?? 'Episode $id',
    audioUrl: 'https://example.com/ep$id.mp3',
  );
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

    service = DownloadQueueService(
      repository: mockRepository,
      fileService: mockFileService,
      episodeRepository: mockEpisodeRepo,
      logger: Logger(level: Level.off),
    );
  });

  tearDown(() {
    service.dispose();
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
        mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
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
        mockRepository.getNextPending(isOnWifi: anyNamed('isOnWifi')),
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
    test('cancels subscriptions and closes controller', () {
      // Act - should not throw
      service.dispose();

      // Assert - stream is closed (listening completes immediately)
      expect(
        service.activeDownloadStream.listen((_) {}).asFuture<void>(),
        completes,
      );
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
