import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = SleepTimerService();
  final t0 = DateTime.utc(2026, 4, 14, 12);

  group('SleepTimerService.evaluate — off', () {
    test('off always keeps', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.off(),
          event: const EpisodeCompletedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
      expect(
        service.evaluate(
          config: const SleepTimerConfig.off(),
          event: TickEvent(t0),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });
  });

  group('SleepTimerService.evaluate — endOfEpisode', () {
    test('fires on EpisodeCompletedEvent holding at end of stream', () {
      final decision = service.evaluate(
        config: const SleepTimerConfig.endOfEpisode(),
        event: const EpisodeCompletedEvent(),
        currentEpisodeHasChapters: false,
      );
      expect(decision, isA<FireDecision>());
      expect((decision as FireDecision).stop, SleepTimerStop.holdAtEndOfStream);
    });

    test('cancels on ManualEpisodeSwitchedEvent', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfEpisode(),
          event: const ManualEpisodeSwitchedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<CancelDecision>(),
      );
    });

    test('keeps when a seek leaves a chapter of the episode', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfEpisode(),
          event: const SeekedOutOfChapterEvent(),
          currentEpisodeHasChapters: true,
        ),
        isA<KeepDecision>(),
      );
    });

    test('keeps on tick', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfEpisode(),
          event: TickEvent(t0),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });
  });

  group('SleepTimerService.evaluate — endOfChapter', () {
    test('pauses at once without a fade on ChapterChangedEvent', () {
      final decision = service.evaluate(
        config: const SleepTimerConfig.endOfChapter(),
        event: const ChapterChangedEvent(),
        currentEpisodeHasChapters: true,
      );
      expect(decision, isA<FireDecision>());
      expect((decision as FireDecision).stop, SleepTimerStop.pauseNow);
    });

    test('cancels on SeekedOutOfChapterEvent', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfChapter(),
          event: const SeekedOutOfChapterEvent(),
          currentEpisodeHasChapters: true,
        ),
        isA<CancelDecision>(),
      );
    });

    test('fires without a fade when the episode completes', () {
      final decision = service.evaluate(
        config: const SleepTimerConfig.endOfChapter(),
        event: const EpisodeCompletedEvent(),
        currentEpisodeHasChapters: true,
      );
      expect(decision, isA<FireDecision>());
      expect((decision as FireDecision).stop, SleepTimerStop.holdAtEndOfStream);
    });

    test('cancels on a manual episode switch, with or without chapters', () {
      for (final hasChapters in [true, false]) {
        expect(
          service.evaluate(
            config: const SleepTimerConfig.endOfChapter(),
            event: const ManualEpisodeSwitchedEvent(),
            currentEpisodeHasChapters: hasChapters,
          ),
          isA<CancelDecision>(),
        );
      }
    });

    test('keeps on episode completion when chapters are unavailable', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfChapter(),
          event: const EpisodeCompletedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });

    test('keeps when chapters unavailable (controller will reset to off)', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfChapter(),
          event: const ChapterChangedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });
  });

  group('SleepTimerService.evaluate — duration', () {
    test('fires when deadline <= now (exact match)', () {
      final cfg = SleepTimerConfig.duration(
        total: const Duration(minutes: 30),
        deadline: t0,
      );
      expect(
        service.evaluate(
          config: cfg,
          event: TickEvent(t0),
          currentEpisodeHasChapters: false,
        ),
        isA<FireDecision>(),
      );
    });

    test('fires when deadline strictly before now', () {
      final cfg = SleepTimerConfig.duration(
        total: const Duration(minutes: 30),
        deadline: t0,
      );
      expect(
        service.evaluate(
          config: cfg,
          event: TickEvent(t0.add(const Duration(seconds: 1))),
          currentEpisodeHasChapters: false,
        ),
        isA<FireDecision>(),
      );
    });

    test('keeps when now is before deadline', () {
      final cfg = SleepTimerConfig.duration(
        total: const Duration(minutes: 30),
        deadline: t0.add(const Duration(minutes: 30)),
      );
      expect(
        service.evaluate(
          config: cfg,
          event: TickEvent(t0),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });
  });

  group('SleepTimerService.evaluate — episodes', () {
    test('fires when remaining == 1 and episode completes (end of stream)', () {
      final decision = service.evaluate(
        config: const SleepTimerConfig.episodes(total: 3, remaining: 1),
        event: const EpisodeCompletedEvent(),
        currentEpisodeHasChapters: false,
      );
      expect(decision, isA<FireDecision>());
      expect((decision as FireDecision).stop, SleepTimerStop.holdAtEndOfStream);
    });

    test('duration fires fade out', () {
      final duration = service.evaluate(
        config: SleepTimerConfig.duration(
          total: const Duration(minutes: 30),
          deadline: t0,
        ),
        event: TickEvent(t0),
        currentEpisodeHasChapters: false,
      );
      expect((duration as FireDecision).stop, SleepTimerStop.fadeOut);
    });

    test('decrements when remaining > 1 and episode completes', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.episodes(total: 3, remaining: 2),
          event: const EpisodeCompletedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<DecrementEpisodesDecision>(),
      );
    });

    test('keeps on manual episode switch (does NOT decrement)', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.episodes(total: 3, remaining: 2),
          event: const ManualEpisodeSwitchedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });
  });
}
