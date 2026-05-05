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
    test('fires on EpisodeCompletedEvent with immediate=true', () {
      final decision = service.evaluate(
        config: const SleepTimerConfig.endOfEpisode(),
        event: const EpisodeCompletedEvent(),
        currentEpisodeHasChapters: false,
      );
      expect(decision, isA<FireDecision>());
      expect((decision as FireDecision).immediate, isTrue);
    });

    test('keeps on ManualEpisodeSwitchedEvent (transfers implicitly)', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfEpisode(),
          event: const ManualEpisodeSwitchedEvent(),
          currentEpisodeHasChapters: false,
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
    test('fires on ChapterChangedEvent', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfChapter(),
          event: const ChapterChangedEvent(),
          currentEpisodeHasChapters: true,
        ),
        isA<FireDecision>(),
      );
    });

    test('retargets on SeekedPastChapterEvent', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfChapter(),
          event: const SeekedPastChapterEvent(),
          currentEpisodeHasChapters: true,
        ),
        isA<RetargetChapterDecision>(),
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
    test('fires when remaining == 1 and episode completes (immediate)', () {
      final decision = service.evaluate(
        config: const SleepTimerConfig.episodes(total: 3, remaining: 1),
        event: const EpisodeCompletedEvent(),
        currentEpisodeHasChapters: false,
      );
      expect(decision, isA<FireDecision>());
      expect((decision as FireDecision).immediate, isTrue);
    });

    test('chapter and duration fires use fade (immediate=false)', () {
      final chapter = service.evaluate(
        config: const SleepTimerConfig.endOfChapter(),
        event: const ChapterChangedEvent(),
        currentEpisodeHasChapters: true,
      );
      expect((chapter as FireDecision).immediate, isFalse);

      final duration = service.evaluate(
        config: SleepTimerConfig.duration(
          total: const Duration(minutes: 30),
          deadline: t0,
        ),
        event: TickEvent(t0),
        currentEpisodeHasChapters: false,
      );
      expect((duration as FireDecision).immediate, isFalse);
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
