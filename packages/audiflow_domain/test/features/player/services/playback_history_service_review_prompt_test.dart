import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../review_prompt/fakes/fake_review_prompt_repository.dart';

class _FakePlaybackHistoryRepository implements PlaybackHistoryRepository {
  final List<({int episodeId, int listenedDeltaMs, int realtimeDeltaMs})>
  savedProgress = [];
  bool completed = false;

  @override
  Future<void> saveProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
    int listenedDeltaMs = 0,
    int realtimeDeltaMs = 0,
  }) async {
    savedProgress.add((
      episodeId: episodeId,
      listenedDeltaMs: listenedDeltaMs,
      realtimeDeltaMs: realtimeDeltaMs,
    ));
  }

  @override
  Future<bool> isCompleted(int episodeId) async => completed;

  @override
  Future<void> markCompleted(int episodeId) async {
    completed = true;
  }

  @override
  Future<void> markIncomplete(int episodeId) async {
    completed = false;
  }

  @override
  Future<void> incrementPlayCount(int episodeId) async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingTrigger implements ReviewPromptTrigger {
  int armCalls = 0;
  int cancelCalls = 0;

  @override
  void armForPlayback() => armCalls++;

  @override
  void cancel() => cancelCalls++;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakePlaybackHistoryRepository historyRepo;
  late FakeReviewPromptRepository reviewRepo;
  late _RecordingTrigger trigger;
  late PlaybackHistoryService service;
  late DateTime now;

  setUp(() {
    historyRepo = _FakePlaybackHistoryRepository();
    reviewRepo = FakeReviewPromptRepository();
    trigger = _RecordingTrigger();
    now = DateTime(2026, 1, 1, 12);
    service = PlaybackHistoryService(
      historyRepo,
      getCompletionThreshold: () => 0.95,
      reviewPromptRepository: reviewRepo,
      reviewPromptTrigger: trigger,
      clock: () => now,
    );
  });

  group('PlaybackHistoryService review-prompt wiring', () {
    test('onPlaybackStarted arms trigger once per call', () async {
      await service.onPlaybackStarted(1, 0);
      check(trigger.armCalls).equals(1);
      await service.onPlaybackStarted(2, 0);
      check(trigger.armCalls).equals(2);
    });

    test(
      'onPlaybackPaused cancels trigger and flushes listened delta',
      () async {
        await service.onPlaybackStarted(1, 0);
        check(trigger.armCalls).equals(1);

        now = now.add(const Duration(seconds: 10));
        await service.onPlaybackPaused(
          1,
          PlaybackProgress(
            position: const Duration(seconds: 10),
            duration: const Duration(minutes: 30),
            bufferedPosition: const Duration(seconds: 10),
          ),
        );

        check(trigger.cancelCalls).equals(1);
        check(reviewRepo.addListenedCalls).equals(1);
        check(reviewRepo.getStats().totalListened.inMilliseconds).equals(10000);
      },
    );

    test(
      'onPlaybackStopped cancels trigger and flushes listened delta',
      () async {
        await service.onPlaybackStarted(1, 0);
        now = now.add(const Duration(seconds: 8));
        await service.onPlaybackStopped(
          1,
          PlaybackProgress(
            position: const Duration(seconds: 8),
            duration: const Duration(minutes: 30),
            bufferedPosition: const Duration(seconds: 8),
          ),
        );
        check(trigger.cancelCalls).equals(1);
        check(reviewRepo.getStats().totalListened.inMilliseconds).equals(8000);
      },
    );

    test(
      'onProgressUpdate accumulates listen delta past throttle interval',
      () async {
        await service.onPlaybackStarted(1, 0);
        now = now.add(const Duration(seconds: 6));
        await service.onProgressUpdate(
          1,
          PlaybackProgress(
            position: const Duration(seconds: 6),
            duration: const Duration(minutes: 30),
            bufferedPosition: const Duration(seconds: 6),
          ),
        );
        check(reviewRepo.getStats().totalListened.inMilliseconds).equals(6000);
      },
    );

    test(
      'onProgressUpdate does not add listened time when delta is zero',
      () async {
        await service.onPlaybackStarted(1, 0);
        now = now.add(const Duration(seconds: 6));
        // Replay same position — listened delta will be 0.
        await service.onProgressUpdate(
          1,
          PlaybackProgress(
            position: Duration.zero,
            duration: const Duration(minutes: 30),
            bufferedPosition: Duration.zero,
          ),
        );
        check(reviewRepo.addListenedCalls).equals(0);
      },
    );

    test(
      'service works without review-prompt collaborators (nullable)',
      () async {
        final bareService = PlaybackHistoryService(
          historyRepo,
          getCompletionThreshold: () => 0.95,
          clock: () => now,
        );
        await bareService.onPlaybackStarted(1, 0);
        await bareService.onPlaybackPaused(
          1,
          PlaybackProgress(
            position: const Duration(seconds: 1),
            duration: const Duration(minutes: 30),
            bufferedPosition: const Duration(seconds: 1),
          ),
        );
        // No throw, no calls.
        check(trigger.armCalls).equals(0);
      },
    );
  });
}
