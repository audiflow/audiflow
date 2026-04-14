import '../models/sleep_timer_config.dart';

/// Player-side events that may influence sleep-timer state.
sealed class SleepTimerPlayerEvent {
  const SleepTimerPlayerEvent();
}

/// Periodic tick driven by the controller while a duration timer is active.
final class TickEvent extends SleepTimerPlayerEvent {
  const TickEvent(this.now);
  final DateTime now;
}

/// Emitted when an episode completes naturally (end of audio).
final class EpisodeCompletedEvent extends SleepTimerPlayerEvent {
  const EpisodeCompletedEvent();
}

/// Emitted when the user manually switches the playing episode
/// (tapping a queue item, playing a different episode explicitly, etc.).
final class ManualEpisodeSwitchedEvent extends SleepTimerPlayerEvent {
  const ManualEpisodeSwitchedEvent();
}

/// Emitted when the current chapter boundary is reached during natural playback.
final class ChapterChangedEvent extends SleepTimerPlayerEvent {
  const ChapterChangedEvent();
}

/// Emitted when the user seeks past the current chapter's end.
final class SeekedPastChapterEvent extends SleepTimerPlayerEvent {
  const SeekedPastChapterEvent();
}

/// Pure decision produced by [SleepTimerService.evaluate].
sealed class SleepTimerDecision {
  const SleepTimerDecision();
}

final class KeepDecision extends SleepTimerDecision {
  const KeepDecision();
}

final class FireDecision extends SleepTimerDecision {
  const FireDecision();
}

final class DecrementEpisodesDecision extends SleepTimerDecision {
  const DecrementEpisodesDecision();
}

final class RetargetChapterDecision extends SleepTimerDecision {
  const RetargetChapterDecision();
}

/// Pure decision evaluator for the sleep timer.
///
/// Owns no state and no side effects. The controller translates decisions
/// into player actions (fade, pause, snackbar) and state updates.
class SleepTimerService {
  const SleepTimerService();

  SleepTimerDecision evaluate({
    required SleepTimerConfig config,
    required SleepTimerPlayerEvent event,
    required bool currentEpisodeHasChapters,
  }) {
    switch (config) {
      case SleepTimerConfigOff():
        return const KeepDecision();
      case SleepTimerConfigEndOfEpisode():
        if (event is EpisodeCompletedEvent) return const FireDecision();
        return const KeepDecision();
      case SleepTimerConfigEndOfChapter():
        if (!currentEpisodeHasChapters) return const KeepDecision();
        if (event is ChapterChangedEvent) return const FireDecision();
        if (event is SeekedPastChapterEvent) {
          return const RetargetChapterDecision();
        }
        return const KeepDecision();
      case SleepTimerConfigDuration(:final deadline):
        if (event is TickEvent && deadline.compareTo(event.now) <= 0) {
          return const FireDecision();
        }
        return const KeepDecision();
      case SleepTimerConfigEpisodes(:final remaining):
        if (event is EpisodeCompletedEvent) {
          if (remaining <= 1) return const FireDecision();
          return const DecrementEpisodesDecision();
        }
        return const KeepDecision();
    }
  }
}
