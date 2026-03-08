import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  DownloadRepository,
  DownloadQueueService,
  DownloadFileService,
  EpisodeRepository,
])
import 'download_service_test.mocks.dart';

DownloadTask _task({
  required int id,
  int episodeId = 1,
  String audioUrl = 'https://example.com/ep.mp3',
  int status = 0, // pending
  int retryCount = 0,
  int downloadedBytes = 0,
  String? localPath,
  bool wifiOnly = false,
}) {
  return DownloadTask(
    id: id,
    episodeId: episodeId,
    audioUrl: audioUrl,
    status: status,
    retryCount: retryCount,
    downloadedBytes: downloadedBytes,
    wifiOnly: wifiOnly,
    localPath: localPath,
    createdAt: DateTime.now(),
  );
}

Episode _episode({
  required int id,
  int podcastId = 1,
  String? title,
  int? seasonNumber,
}) {
  return Episode(
    id: id,
    podcastId: podcastId,
    guid: 'guid-$id',
    title: title ?? 'Episode $id',
    audioUrl: 'https://example.com/ep$id.mp3',
    seasonNumber: seasonNumber,
  );
}

void main() {
  late MockDownloadRepository mockRepository;
  late MockDownloadQueueService mockQueueService;
  late MockDownloadFileService mockFileService;
  late MockEpisodeRepository mockEpisodeRepo;
  late DownloadService service;
  late bool wifiOnly;
  late bool autoDeletePlayed;

  setUp(() {
    mockRepository = MockDownloadRepository();
    mockQueueService = MockDownloadQueueService();
    mockFileService = MockDownloadFileService();
    mockEpisodeRepo = MockEpisodeRepository();
    wifiOnly = false;
    autoDeletePlayed = false;

    service = DownloadService(
      repository: mockRepository,
      queueService: mockQueueService,
      fileService: mockFileService,
      episodeRepository: mockEpisodeRepo,
      logger: Logger(level: Level.off),
      getWifiOnly: () => wifiOnly,
      getAutoDeletePlayed: () => autoDeletePlayed,
    );
  });

  group('downloadEpisode', () {
    test('creates download and starts queue', () async {
      // Arrange
      final episode = _episode(id: 1);
      final task = _task(id: 10, episodeId: 1);

      when(mockEpisodeRepo.getById(1)).thenAnswer((_) async => episode);
      when(
        mockRepository.createDownload(
          episodeId: 1,
          audioUrl: episode.audioUrl,
          wifiOnly: false,
        ),
      ).thenAnswer((_) async => task);
      when(mockQueueService.startQueue()).thenAnswer((_) async {});

      // Act
      final result = await service.downloadEpisode(1);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 10);
      verify(mockQueueService.startQueue()).called(1);
    });

    test('returns null when episode not found', () async {
      // Arrange
      when(mockEpisodeRepo.getById(99)).thenAnswer((_) async => null);

      // Act
      final result = await service.downloadEpisode(99);

      // Assert
      expect(result, isNull);
      verifyNever(
        mockRepository.createDownload(
          episodeId: anyNamed('episodeId'),
          audioUrl: anyNamed('audioUrl'),
          wifiOnly: anyNamed('wifiOnly'),
        ),
      );
    });

    test('returns null and does not start queue '
        'when download already exists', () async {
      // Arrange
      final episode = _episode(id: 1);
      when(mockEpisodeRepo.getById(1)).thenAnswer((_) async => episode);
      when(
        mockRepository.createDownload(
          episodeId: 1,
          audioUrl: episode.audioUrl,
          wifiOnly: false,
        ),
      ).thenAnswer((_) async => null);

      // Act
      final result = await service.downloadEpisode(1);

      // Assert
      expect(result, isNull);
      verifyNever(mockQueueService.startQueue());
    });

    test('uses global wifiOnly setting by default', () async {
      // Arrange
      wifiOnly = true;
      final episode = _episode(id: 1);
      when(mockEpisodeRepo.getById(1)).thenAnswer((_) async => episode);
      when(
        mockRepository.createDownload(
          episodeId: 1,
          audioUrl: episode.audioUrl,
          wifiOnly: true,
        ),
      ).thenAnswer((_) async => _task(id: 10, wifiOnly: true));
      when(mockQueueService.startQueue()).thenAnswer((_) async {});

      // Act
      await service.downloadEpisode(1);

      // Assert
      verify(
        mockRepository.createDownload(
          episodeId: 1,
          audioUrl: episode.audioUrl,
          wifiOnly: true,
        ),
      ).called(1);
    });

    test('overrides wifiOnly when explicitly specified', () async {
      // Arrange
      wifiOnly = true;
      final episode = _episode(id: 1);
      when(mockEpisodeRepo.getById(1)).thenAnswer((_) async => episode);
      when(
        mockRepository.createDownload(
          episodeId: 1,
          audioUrl: episode.audioUrl,
          wifiOnly: false,
        ),
      ).thenAnswer((_) async => _task(id: 10));
      when(mockQueueService.startQueue()).thenAnswer((_) async {});

      // Act
      await service.downloadEpisode(1, wifiOnly: false);

      // Assert
      verify(
        mockRepository.createDownload(
          episodeId: 1,
          audioUrl: episode.audioUrl,
          wifiOnly: false,
        ),
      ).called(1);
    });
  });

  group('downloadSeason', () {
    test('queues downloads for all episodes in season', () async {
      // Arrange
      final episodes = [
        _episode(id: 1, podcastId: 10, seasonNumber: 2),
        _episode(id: 2, podcastId: 10, seasonNumber: 2),
        _episode(id: 3, podcastId: 10, seasonNumber: 1),
      ];

      when(
        mockEpisodeRepo.getByPodcastId(10),
      ).thenAnswer((_) async => episodes);

      // Season 2 episodes: id 1 and 2
      for (final ep in episodes.where((e) => e.seasonNumber == 2)) {
        when(mockEpisodeRepo.getById(ep.id)).thenAnswer((_) async => ep);
        when(
          mockRepository.createDownload(
            episodeId: ep.id,
            audioUrl: ep.audioUrl,
            wifiOnly: false,
          ),
        ).thenAnswer((_) async => _task(id: ep.id + 100, episodeId: ep.id));
      }
      when(mockQueueService.startQueue()).thenAnswer((_) async {});

      // Act
      final queued = await service.downloadSeason(10, 2);

      // Assert
      expect(queued, 2);
    });

    test('returns zero when no episodes in season', () async {
      // Arrange
      final episodes = [_episode(id: 1, podcastId: 10, seasonNumber: 1)];
      when(
        mockEpisodeRepo.getByPodcastId(10),
      ).thenAnswer((_) async => episodes);

      // Act
      final queued = await service.downloadSeason(10, 5);

      // Assert
      expect(queued, 0);
    });

    test('counts only newly queued downloads', () async {
      // Arrange
      final episodes = [
        _episode(id: 1, podcastId: 10, seasonNumber: 2),
        _episode(id: 2, podcastId: 10, seasonNumber: 2),
      ];

      when(
        mockEpisodeRepo.getByPodcastId(10),
      ).thenAnswer((_) async => episodes);

      // First episode creates task, second already exists
      when(mockEpisodeRepo.getById(1)).thenAnswer((_) async => episodes[0]);
      when(
        mockRepository.createDownload(
          episodeId: 1,
          audioUrl: episodes[0].audioUrl,
          wifiOnly: false,
        ),
      ).thenAnswer((_) async => _task(id: 101, episodeId: 1));
      when(mockQueueService.startQueue()).thenAnswer((_) async {});

      when(mockEpisodeRepo.getById(2)).thenAnswer((_) async => episodes[1]);
      when(
        mockRepository.createDownload(
          episodeId: 2,
          audioUrl: episodes[1].audioUrl,
          wifiOnly: false,
        ),
      ).thenAnswer((_) async => null); // already exists

      // Act
      final queued = await service.downloadSeason(10, 2);

      // Assert
      expect(queued, 1);
    });
  });

  group('pause', () {
    test('delegates to queue service', () async {
      // Arrange
      when(mockQueueService.pauseDownload(5)).thenAnswer((_) async {});

      // Act
      await service.pause(5);

      // Assert
      verify(mockQueueService.pauseDownload(5)).called(1);
    });
  });

  group('resume', () {
    test('delegates to queue service', () async {
      // Arrange
      when(mockQueueService.resumeDownload(5)).thenAnswer((_) async {});

      // Act
      await service.resume(5);

      // Assert
      verify(mockQueueService.resumeDownload(5)).called(1);
    });
  });

  group('cancel', () {
    test('delegates to queue service', () async {
      // Arrange
      when(mockQueueService.cancelDownload(5)).thenAnswer((_) async {});

      // Act
      await service.cancel(5);

      // Assert
      verify(mockQueueService.cancelDownload(5)).called(1);
    });
  });

  group('retry', () {
    test('delegates to queue service', () async {
      // Arrange
      when(mockQueueService.retryDownload(5)).thenAnswer((_) async {});

      // Act
      await service.retry(5);

      // Assert
      verify(mockQueueService.retryDownload(5)).called(1);
    });
  });

  group('delete', () {
    test('does nothing when task not found', () async {
      // Arrange
      when(mockRepository.getById(99)).thenAnswer((_) async => null);

      // Act
      await service.delete(99);

      // Assert
      verifyNever(mockQueueService.cancelDownload(any));
      verifyNever(mockFileService.deleteFile(any));
      verifyNever(mockRepository.delete(any));
    });

    test('cancels active download, deletes file, '
        'and removes record', () async {
      // Arrange
      // status=1 is downloading (active)
      final task = _task(id: 1, status: 1, localPath: '/downloads/ep.mp3');
      when(mockRepository.getById(1)).thenAnswer((_) async => task);
      when(mockQueueService.cancelDownload(1)).thenAnswer((_) async {});
      when(
        mockFileService.deleteFile('/downloads/ep.mp3'),
      ).thenAnswer((_) async {});
      when(mockRepository.delete(1)).thenAnswer((_) async {});

      // Act
      await service.delete(1);

      // Assert
      verify(mockQueueService.cancelDownload(1)).called(1);
      verify(mockFileService.deleteFile('/downloads/ep.mp3')).called(1);
      verify(mockRepository.delete(1)).called(1);
    });

    test('does not cancel when download is not active', () async {
      // Arrange
      // status=3 is completed (not active)
      final task = _task(id: 1, status: 3, localPath: '/downloads/ep.mp3');
      when(mockRepository.getById(1)).thenAnswer((_) async => task);
      when(
        mockFileService.deleteFile('/downloads/ep.mp3'),
      ).thenAnswer((_) async {});
      when(mockRepository.delete(1)).thenAnswer((_) async {});

      // Act
      await service.delete(1);

      // Assert
      verifyNever(mockQueueService.cancelDownload(any));
      verify(mockFileService.deleteFile('/downloads/ep.mp3')).called(1);
      verify(mockRepository.delete(1)).called(1);
    });

    test('skips file deletion when localPath is null', () async {
      // Arrange
      // status=5 is cancelled (not active), no local path
      final task = _task(id: 1, status: 5);
      when(mockRepository.getById(1)).thenAnswer((_) async => task);
      when(mockRepository.delete(1)).thenAnswer((_) async {});

      // Act
      await service.delete(1);

      // Assert
      verifyNever(mockFileService.deleteFile(any));
      verify(mockRepository.delete(1)).called(1);
    });
  });

  group('deleteAllCompleted', () {
    test('deletes files and records for all completed downloads', () async {
      // Arrange
      final completed = [
        _task(id: 1, localPath: '/downloads/ep1.mp3', status: 3),
        _task(id: 2, localPath: '/downloads/ep2.mp3', status: 3),
      ];
      when(
        mockRepository.getByStatus(const DownloadStatus.completed()),
      ).thenAnswer((_) async => completed);
      when(mockFileService.deleteFile(any)).thenAnswer((_) async {});
      when(mockRepository.deleteAllCompleted()).thenAnswer((_) async => 2);

      // Act
      await service.deleteAllCompleted();

      // Assert
      verify(mockFileService.deleteFile('/downloads/ep1.mp3')).called(1);
      verify(mockFileService.deleteFile('/downloads/ep2.mp3')).called(1);
      verify(mockRepository.deleteAllCompleted()).called(1);
    });

    test('skips file deletion when localPath is null', () async {
      // Arrange
      final completed = [
        _task(id: 1, status: 3), // no localPath
      ];
      when(
        mockRepository.getByStatus(const DownloadStatus.completed()),
      ).thenAnswer((_) async => completed);
      when(mockRepository.deleteAllCompleted()).thenAnswer((_) async => 1);

      // Act
      await service.deleteAllCompleted();

      // Assert
      verifyNever(mockFileService.deleteFile(any));
      verify(mockRepository.deleteAllCompleted()).called(1);
    });

    test('handles empty completed list', () async {
      // Arrange
      when(
        mockRepository.getByStatus(const DownloadStatus.completed()),
      ).thenAnswer((_) async => []);
      when(mockRepository.deleteAllCompleted()).thenAnswer((_) async => 0);

      // Act
      await service.deleteAllCompleted();

      // Assert
      verifyNever(mockFileService.deleteFile(any));
      verify(mockRepository.deleteAllCompleted()).called(1);
    });
  });

  group('getLocalPath', () {
    test(
      'returns local path when download completed and file exists',
      () async {
        // Arrange
        final task = _task(
          id: 1,
          episodeId: 10,
          localPath: '/downloads/ep10.mp3',
          status: 3,
        );
        when(
          mockRepository.getCompletedForEpisode(10),
        ).thenAnswer((_) async => task);
        when(
          mockFileService.fileExists('/downloads/ep10.mp3'),
        ).thenAnswer((_) async => true);

        // Act
        final result = await service.getLocalPath(10);

        // Assert
        expect(result, '/downloads/ep10.mp3');
      },
    );

    test('returns null when no completed download', () async {
      // Arrange
      when(
        mockRepository.getCompletedForEpisode(10),
      ).thenAnswer((_) async => null);

      // Act
      final result = await service.getLocalPath(10);

      // Assert
      expect(result, isNull);
    });

    test('returns null and marks failed when file is missing', () async {
      // Arrange
      final task = _task(
        id: 1,
        episodeId: 10,
        localPath: '/downloads/ep10.mp3',
        status: 3,
      );
      when(
        mockRepository.getCompletedForEpisode(10),
      ).thenAnswer((_) async => task);
      when(
        mockFileService.fileExists('/downloads/ep10.mp3'),
      ).thenAnswer((_) async => false);
      when(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.failed(),
          lastError: 'File not found',
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await service.getLocalPath(10);

      // Assert
      expect(result, isNull);
      verify(
        mockRepository.updateStatus(
          id: 1,
          status: const DownloadStatus.failed(),
          lastError: 'File not found',
        ),
      ).called(1);
    });

    test('returns null when localPath is null', () async {
      // Arrange
      final task = _task(id: 1, episodeId: 10, status: 3);
      when(
        mockRepository.getCompletedForEpisode(10),
      ).thenAnswer((_) async => task);

      // Act
      final result = await service.getLocalPath(10);

      // Assert
      expect(result, isNull);
    });
  });

  group('validateDownloads', () {
    test('removes orphaned completed downloads', () async {
      // Arrange
      final completed = [
        _task(id: 1, localPath: '/downloads/exists.mp3', status: 3),
        _task(id: 2, localPath: '/downloads/missing.mp3', status: 3),
      ];
      when(
        mockRepository.getByStatus(const DownloadStatus.completed()),
      ).thenAnswer((_) async => completed);
      when(
        mockFileService.fileExists('/downloads/exists.mp3'),
      ).thenAnswer((_) async => true);
      when(
        mockFileService.fileExists('/downloads/missing.mp3'),
      ).thenAnswer((_) async => false);
      when(mockRepository.delete(2)).thenAnswer((_) async {});
      when(
        mockRepository.getByStatus(const DownloadStatus.downloading()),
      ).thenAnswer((_) async => []);

      // Act
      await service.validateDownloads();

      // Assert
      verifyNever(mockRepository.delete(1));
      verify(mockRepository.delete(2)).called(1);
    });

    test('removes completed downloads with null localPath', () async {
      // Arrange
      final completed = [
        _task(id: 1, status: 3), // null localPath
      ];
      when(
        mockRepository.getByStatus(const DownloadStatus.completed()),
      ).thenAnswer((_) async => completed);
      when(mockRepository.delete(1)).thenAnswer((_) async {});
      when(
        mockRepository.getByStatus(const DownloadStatus.downloading()),
      ).thenAnswer((_) async => []);

      // Act
      await service.validateDownloads();

      // Assert
      verify(mockRepository.delete(1)).called(1);
    });

    test('resets interrupted downloads to pending and starts queue', () async {
      // Arrange
      when(
        mockRepository.getByStatus(const DownloadStatus.completed()),
      ).thenAnswer((_) async => []);

      final downloading = [_task(id: 3, status: 1), _task(id: 4, status: 1)];
      when(
        mockRepository.getByStatus(const DownloadStatus.downloading()),
      ).thenAnswer((_) async => downloading);
      when(
        mockRepository.updateStatus(
          id: anyNamed('id'),
          status: const DownloadStatus.pending(),
        ),
      ).thenAnswer((_) async {});
      when(mockQueueService.startQueue()).thenAnswer((_) async {});

      // Act
      await service.validateDownloads();

      // Assert
      verify(
        mockRepository.updateStatus(
          id: 3,
          status: const DownloadStatus.pending(),
        ),
      ).called(1);
      verify(
        mockRepository.updateStatus(
          id: 4,
          status: const DownloadStatus.pending(),
        ),
      ).called(1);
      verify(mockQueueService.startQueue()).called(1);
    });

    test('does not start queue when no interrupted downloads', () async {
      // Arrange
      when(
        mockRepository.getByStatus(const DownloadStatus.completed()),
      ).thenAnswer((_) async => []);
      when(
        mockRepository.getByStatus(const DownloadStatus.downloading()),
      ).thenAnswer((_) async => []);

      // Act
      await service.validateDownloads();

      // Assert
      verifyNever(mockQueueService.startQueue());
    });
  });

  group('onEpisodeCompleted', () {
    test('does nothing when autoDeletePlayed is false', () async {
      // Arrange
      autoDeletePlayed = false;

      // Act
      await service.onEpisodeCompleted(1);

      // Assert
      verifyNever(mockRepository.getByEpisodeId(any));
    });

    test('does nothing when no download task exists', () async {
      // Arrange
      autoDeletePlayed = true;
      when(mockRepository.getByEpisodeId(1)).thenAnswer((_) async => null);

      // Act
      await service.onEpisodeCompleted(1);

      // Assert
      verify(mockRepository.getByEpisodeId(1)).called(1);
      verifyNever(mockRepository.getById(any));
    });

    test('deletes completed download when autoDeletePlayed is true', () async {
      // Arrange
      autoDeletePlayed = true;
      // status=3 is DownloadStatusCompleted
      final task = _task(
        id: 5,
        episodeId: 1,
        status: 3,
        localPath: '/downloads/ep1.mp3',
      );
      when(mockRepository.getByEpisodeId(1)).thenAnswer((_) async => task);
      // delete() calls getById, cancelDownload, deleteFile, delete
      when(mockRepository.getById(5)).thenAnswer((_) async => task);
      when(
        mockFileService.deleteFile('/downloads/ep1.mp3'),
      ).thenAnswer((_) async {});
      when(mockRepository.delete(5)).thenAnswer((_) async {});

      // Act
      await service.onEpisodeCompleted(1);

      // Assert
      verify(mockRepository.getByEpisodeId(1)).called(1);
      verify(mockRepository.delete(5)).called(1);
    });

    test('does not delete non-completed download', () async {
      // Arrange
      autoDeletePlayed = true;
      // status=0 is pending, not completed
      final task = _task(id: 5, episodeId: 1, status: 0);
      when(mockRepository.getByEpisodeId(1)).thenAnswer((_) async => task);

      // Act
      await service.onEpisodeCompleted(1);

      // Assert
      verify(mockRepository.getByEpisodeId(1)).called(1);
      verifyNever(mockRepository.getById(any));
    });
  });

  group('getTotalStorageUsed', () {
    test('delegates to repository', () async {
      // Arrange
      when(
        mockRepository.getTotalStorageUsed(),
      ).thenAnswer((_) async => 1024000);

      // Act
      final result = await service.getTotalStorageUsed();

      // Assert
      expect(result, 1024000);
      verify(mockRepository.getTotalStorageUsed()).called(1);
    });
  });

  group('dispose', () {
    test('can be called without error', () {
      // Act & Assert - should not throw
      service.dispose();
    });
  });
}
