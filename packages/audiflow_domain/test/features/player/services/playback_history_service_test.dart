import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([PlaybackHistoryRepository])
import 'playback_history_service_test.mocks.dart';

void main() {
  late MockPlaybackHistoryRepository mockRepository;
  late PlaybackHistoryService service;

  setUp(() {
    mockRepository = MockPlaybackHistoryRepository();
    service = PlaybackHistoryService(
      mockRepository,
      log: Logger(level: Level.off),
      getCompletionThreshold: () => 0.95,
    );
  });

  group('onProgressUpdate', () {
    test('saves progress when interval exceeded', () async {
      const episodeId = 1;
      final progress = PlaybackProgress(
        position: const Duration(seconds: 20),
        duration: const Duration(minutes: 30),
        bufferedPosition: const Duration(seconds: 25),
      );

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);

      await service.onProgressUpdate(episodeId, progress);

      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 20000,
          durationMs: 1800000,
        ),
      ).called(1);
    });

    test('does not save progress when interval not exceeded', () async {
      const episodeId = 1;
      // First call at 6 seconds will save (delta from 0 is 6000 >= 5000)
      final progress1 = PlaybackProgress(
        position: const Duration(seconds: 6),
        duration: const Duration(minutes: 30),
        bufferedPosition: const Duration(seconds: 10),
      );
      // Second call at 9 seconds won't save (delta from 6 is 3000 < 5000)
      final progress2 = PlaybackProgress(
        position: const Duration(seconds: 9),
        duration: const Duration(minutes: 30),
        bufferedPosition: const Duration(seconds: 14),
      );

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);

      await service.onProgressUpdate(episodeId, progress1);
      await service.onProgressUpdate(episodeId, progress2);

      // Only first call should save (second is within 5 second interval)
      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 6000,
          durationMs: 1800000,
        ),
      ).called(1);
    });

    test('marks as completed when threshold reached', () async {
      const episodeId = 1;
      final progress = PlaybackProgress(
        position: const Duration(seconds: 570), // 95% of 10 minutes
        duration: const Duration(minutes: 10),
        bufferedPosition: const Duration(minutes: 10),
      );

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);
      when(mockRepository.markCompleted(any)).thenAnswer((_) async {});

      await service.onProgressUpdate(episodeId, progress);

      verify(mockRepository.markCompleted(episodeId)).called(1);
    });

    test('does not mark completed if already completed', () async {
      const episodeId = 1;
      final progress = PlaybackProgress(
        position: const Duration(seconds: 570),
        duration: const Duration(minutes: 10),
        bufferedPosition: const Duration(minutes: 10),
      );

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => true);

      await service.onProgressUpdate(episodeId, progress);

      verifyNever(mockRepository.markCompleted(any));
    });
  });

  group('onPlaybackStarted', () {
    test('increments play count when starting from beginning', () async {
      const episodeId = 1;
      const positionMs = 1000; // 1 second (under threshold)

      when(mockRepository.incrementPlayCount(any)).thenAnswer((_) async {});

      await service.onPlaybackStarted(episodeId, positionMs);

      verify(mockRepository.incrementPlayCount(episodeId)).called(1);
    });

    test('does not increment play count when resuming', () async {
      const episodeId = 1;
      const positionMs = 60000; // 1 minute (over threshold)

      await service.onPlaybackStarted(episodeId, positionMs);

      verifyNever(mockRepository.incrementPlayCount(any));
    });
  });

  group('onPlaybackPaused', () {
    test('immediately saves progress on pause', () async {
      const episodeId = 1;
      final progress = PlaybackProgress(
        position: const Duration(seconds: 30),
        duration: const Duration(minutes: 30),
        bufferedPosition: const Duration(seconds: 35),
      );

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
        ),
      ).thenAnswer((_) async {});

      await service.onPlaybackPaused(episodeId, progress);

      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 30000,
          durationMs: 1800000,
        ),
      ).called(1);
    });
  });

  group('onPlaybackStopped', () {
    test('saves progress and resets tracking state', () async {
      const episodeId = 1;
      final progress = PlaybackProgress(
        position: const Duration(seconds: 45),
        duration: const Duration(minutes: 30),
        bufferedPosition: const Duration(seconds: 50),
      );

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
        ),
      ).thenAnswer((_) async {});

      await service.onPlaybackStopped(episodeId, progress);

      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 45000,
          durationMs: 1800000,
        ),
      ).called(1);
    });
  });

  group('markCompleted', () {
    test('delegates to repository', () async {
      const episodeId = 1;

      when(mockRepository.markCompleted(any)).thenAnswer((_) async {});

      await service.markCompleted(episodeId);

      verify(mockRepository.markCompleted(episodeId)).called(1);
    });
  });

  group('markIncomplete', () {
    test('delegates to repository', () async {
      const episodeId = 1;

      when(mockRepository.markIncomplete(any)).thenAnswer((_) async {});

      await service.markIncomplete(episodeId);

      verify(mockRepository.markIncomplete(episodeId)).called(1);
    });
  });

  group('reset', () {
    test('resets tracking state allowing immediate save', () async {
      const episodeId = 1;
      // First call at 6 seconds will save (delta from 0 is 6000 >= 5000)
      final progress1 = PlaybackProgress(
        position: const Duration(seconds: 6),
        duration: const Duration(minutes: 30),
        bufferedPosition: const Duration(seconds: 10),
      );
      // After reset, _lastSavedPositionMs goes back to 0
      // So 6 seconds again will save (delta from 0 is 6000 >= 5000)
      final progress2 = PlaybackProgress(
        position: const Duration(seconds: 6),
        duration: const Duration(minutes: 30),
        bufferedPosition: const Duration(seconds: 10),
      );

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);

      // First update saves
      await service.onProgressUpdate(episodeId, progress1);

      // Reset state - _lastSavedPositionMs goes back to 0
      service.reset();

      // Second update should save because state was reset (delta from 0)
      await service.onProgressUpdate(episodeId, progress2);

      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 6000,
          durationMs: 1800000,
        ),
      ).called(2);
    });
  });
}
