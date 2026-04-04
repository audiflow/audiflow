import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([PlaybackHistoryRepository])
import 'playback_history_service_test.mocks.dart';

void main() {
  late MockPlaybackHistoryRepository mockRepository;
  late PlaybackHistoryService service;
  late DateTime now;

  DateTime clock() => now;

  setUp(() {
    mockRepository = MockPlaybackHistoryRepository();
    now = DateTime(2026, 1, 1, 12, 0, 0);
    service = PlaybackHistoryService(
      mockRepository,
      getCompletionThreshold: () => 0.95,
      clock: clock,
    );
  });

  group('onProgressUpdate', () {
    test('skips save when duration is zero (source not loaded)', () async {
      const episodeId = 1;
      final progress = PlaybackProgress(
        position: const Duration(seconds: 20),
        duration: Duration.zero,
        bufferedPosition: Duration.zero,
      );

      await service.onProgressUpdate(episodeId, progress);

      verifyNever(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      );
      verifyNever(mockRepository.isCompleted(any));
      verifyNever(mockRepository.markCompleted(any));
    });

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
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);

      await service.onProgressUpdate(episodeId, progress);

      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 20000,
          durationMs: 1800000,
          listenedDeltaMs: 0,
          realtimeDeltaMs: 0,
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
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);

      await service.onProgressUpdate(episodeId, progress1);
      now = now.add(const Duration(seconds: 3));
      await service.onProgressUpdate(episodeId, progress2);

      // Only first call should save (second is within 5 second interval)
      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 6000,
          durationMs: 1800000,
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
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
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
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
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
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
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});

      await service.onPlaybackPaused(episodeId, progress);

      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 30000,
          durationMs: 1800000,
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
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
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});

      await service.onPlaybackStopped(episodeId, progress);

      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 45000,
          durationMs: 1800000,
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
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
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);

      // First update saves
      await service.onProgressUpdate(episodeId, progress1);

      // Reset state - _lastSavedPositionMs goes back to 0
      service.reset();

      now = now.add(const Duration(seconds: 10));

      // Second update should save because state was reset (delta from 0)
      await service.onProgressUpdate(episodeId, progress2);

      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 6000,
          durationMs: 1800000,
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).called(2);
    });
  });

  group('listen time accumulation', () {
    test('accumulates content and realtime at 1x speed', () async {
      const episodeId = 1;

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);
      when(mockRepository.incrementPlayCount(any)).thenAnswer((_) async {});

      // Start playback
      await service.onPlaybackStarted(episodeId, 0);

      // First save has no prior reference -> 0 deltas
      now = now.add(const Duration(seconds: 6));
      await service.onProgressUpdate(
        episodeId,
        PlaybackProgress(
          position: const Duration(seconds: 6),
          duration: const Duration(minutes: 30),
          bufferedPosition: const Duration(seconds: 10),
        ),
      );

      // Second save: 5s of wall-clock, 5s of content at 1x
      now = now.add(const Duration(seconds: 5));
      await service.onProgressUpdate(
        episodeId,
        PlaybackProgress(
          position: const Duration(seconds: 11),
          duration: const Duration(minutes: 30),
          bufferedPosition: const Duration(seconds: 15),
        ),
      );

      // Verify second save has deltas
      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 11000,
          durationMs: 1800000,
          listenedDeltaMs: 5000,
          realtimeDeltaMs: 5000,
        ),
      ).called(1);
    });

    test('accumulates content and realtime at 1.5x speed', () async {
      const episodeId = 1;

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);
      when(mockRepository.incrementPlayCount(any)).thenAnswer((_) async {});

      await service.onPlaybackStarted(episodeId, 0);

      // First save establishes baseline
      now = now.add(const Duration(seconds: 6));
      await service.onProgressUpdate(
        episodeId,
        PlaybackProgress(
          position: const Duration(seconds: 9), // 6s wall * 1.5x = 9s content
          duration: const Duration(minutes: 30),
          bufferedPosition: const Duration(seconds: 15),
        ),
        speed: 1.5,
      );

      // Second save: 5s wall, 7.5s content at 1.5x
      now = now.add(const Duration(seconds: 5));
      await service.onProgressUpdate(
        episodeId,
        PlaybackProgress(
          position: const Duration(milliseconds: 16500), // 9000 + 7500
          duration: const Duration(minutes: 30),
          bufferedPosition: const Duration(seconds: 20),
        ),
        speed: 1.5,
      );

      // Content delta = 16500 - 9000 = 7500
      // Realtime delta = 5000
      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 16500,
          durationMs: 1800000,
          listenedDeltaMs: 7500,
          realtimeDeltaMs: 5000,
        ),
      ).called(1);
    });

    test('does not accumulate on seek (large position jump)', () async {
      const episodeId = 1;

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);
      when(mockRepository.incrementPlayCount(any)).thenAnswer((_) async {});

      await service.onPlaybackStarted(episodeId, 0);

      // First save at 6s
      now = now.add(const Duration(seconds: 6));
      await service.onProgressUpdate(
        episodeId,
        PlaybackProgress(
          position: const Duration(seconds: 6),
          duration: const Duration(minutes: 30),
          bufferedPosition: const Duration(seconds: 10),
        ),
      );

      // Seek forward to 120s but only 5s of wall-clock passed
      now = now.add(const Duration(seconds: 5));
      await service.onProgressUpdate(
        episodeId,
        PlaybackProgress(
          position: const Duration(seconds: 120),
          duration: const Duration(minutes: 30),
          bufferedPosition: const Duration(seconds: 125),
        ),
      );

      // The 114s content delta is way more than 3x of (5s * 1.0) = 15s
      // So it should be detected as a seek with 0 deltas
      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 120000,
          durationMs: 1800000,
          listenedDeltaMs: 0,
          realtimeDeltaMs: 0,
        ),
      ).called(1);
    });

    test('does not accumulate on backward seek', () async {
      const episodeId = 1;

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);
      when(mockRepository.incrementPlayCount(any)).thenAnswer((_) async {});

      await service.onPlaybackStarted(episodeId, 60000);

      // First save at 66s
      now = now.add(const Duration(seconds: 6));
      await service.onProgressUpdate(
        episodeId,
        PlaybackProgress(
          position: const Duration(seconds: 66),
          duration: const Duration(minutes: 30),
          bufferedPosition: const Duration(seconds: 70),
        ),
      );

      // Seek backward to 10s
      now = now.add(const Duration(seconds: 5));
      await service.onProgressUpdate(
        episodeId,
        PlaybackProgress(
          position: const Duration(seconds: 10),
          duration: const Duration(minutes: 30),
          bufferedPosition: const Duration(seconds: 15),
        ),
      );

      // Negative content delta -> 0 deltas
      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 10000,
          durationMs: 1800000,
          listenedDeltaMs: 0,
          realtimeDeltaMs: 0,
        ),
      ).called(1);
    });

    test('accumulates on pause with speed', () async {
      const episodeId = 1;

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.incrementPlayCount(any)).thenAnswer((_) async {});

      await service.onPlaybackStarted(episodeId, 0);

      // 10s wall-clock, 20s content at 2x
      now = now.add(const Duration(seconds: 10));
      await service.onPlaybackPaused(
        episodeId,
        PlaybackProgress(
          position: const Duration(seconds: 20),
          duration: const Duration(minutes: 30),
          bufferedPosition: const Duration(seconds: 25),
        ),
        speed: 2.0,
      );

      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 20000,
          durationMs: 1800000,
          listenedDeltaMs: 20000,
          realtimeDeltaMs: 10000,
        ),
      ).called(1);
    });

    test('accumulates on stop with speed', () async {
      const episodeId = 1;

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.incrementPlayCount(any)).thenAnswer((_) async {});

      await service.onPlaybackStarted(episodeId, 0);

      now = now.add(const Duration(seconds: 8));
      await service.onPlaybackStopped(
        episodeId,
        PlaybackProgress(
          position: const Duration(seconds: 12), // 8s wall * 1.5x = 12s
          duration: const Duration(minutes: 30),
          bufferedPosition: const Duration(seconds: 15),
        ),
        speed: 1.5,
      );

      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 12000,
          durationMs: 1800000,
          listenedDeltaMs: 12000,
          realtimeDeltaMs: 8000,
        ),
      ).called(1);
    });

    test('first progress update after start has zero deltas', () async {
      const episodeId = 1;

      when(
        mockRepository.saveProgress(
          episodeId: anyNamed('episodeId'),
          positionMs: anyNamed('positionMs'),
          durationMs: anyNamed('durationMs'),
          listenedDeltaMs: anyNamed('listenedDeltaMs'),
          realtimeDeltaMs: anyNamed('realtimeDeltaMs'),
        ),
      ).thenAnswer((_) async {});
      when(mockRepository.isCompleted(any)).thenAnswer((_) async => false);
      when(mockRepository.incrementPlayCount(any)).thenAnswer((_) async {});

      await service.onPlaybackStarted(episodeId, 0);

      // 6s of content, 6s of wall — but this is the first save after start,
      // so _lastSaveTime was set during onPlaybackStarted
      now = now.add(const Duration(seconds: 6));
      await service.onProgressUpdate(
        episodeId,
        PlaybackProgress(
          position: const Duration(seconds: 6),
          duration: const Duration(minutes: 30),
          bufferedPosition: const Duration(seconds: 10),
        ),
      );

      // First save after onPlaybackStarted has valid deltas because
      // onPlaybackStarted sets _lastSaveTime
      verify(
        mockRepository.saveProgress(
          episodeId: episodeId,
          positionMs: 6000,
          durationMs: 1800000,
          listenedDeltaMs: 6000,
          realtimeDeltaMs: 6000,
        ),
      ).called(1);
    });
  });
}
