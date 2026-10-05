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

/// Emitted when a requested seek leaves the current chapter, forward or
/// backward.
final class SeekedOutOfChapterEvent extends SleepTimerPlayerEvent {
  const SeekedOutOfChapterEvent();
}

/// Pure decision produced by [SleepTimerService.evaluate].
sealed class SleepTimerDecision {
  const SleepTimerDecision();
}

final class KeepDecision extends SleepTimerDecision {
  const KeepDecision();
}

/// How the controller stops playback when the timer fires.
enum SleepTimerStop {
  /// Fade the volume out over several seconds, then pause.
  ///
  /// For triggers that fire mid-content (duration deadline), where a calm
  /// fade is gentler than an abrupt cut.
  fadeOut,

  /// Pause right away, without a fade.
  ///
  /// For the end-of-chapter boundary: the next chapter is already playing,
  /// so a fade would let its opening be heard while the volume drops.
  pauseNow,

  /// Audio already reached the end of the stream: keep it from advancing
  /// to the next episode instead of pausing.
  ///
  /// Fading or pausing here would only take effect against the
  /// auto-advanced next episode, which is the bug this mode prevents.
  holdAtEndOfStream,
}

final class FireDecision extends SleepTimerDecision {
  const FireDecision({this.stop = SleepTimerStop.fadeOut});

  final SleepTimerStop stop;
}

final class DecrementEpisodesDecision extends SleepTimerDecision {
  const DecrementEpisodesDecision();
}

/// The listener left the episode or chapter the timer refers to, so the
/// timer is turned off without pausing.
final class CancelDecision extends SleepTimerDecision {
  const CancelDecision();
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
        return switch (event) {
          EpisodeCompletedEvent() => const FireDecision(
            stop: SleepTimerStop.holdAtEndOfStream,
          ),
          ManualEpisodeSwitchedEvent() => const CancelDecision(),
          _ => const KeepDecision(),
        };
      case SleepTimerConfigEndOfChapter():
        return _evaluateEndOfChapter(event, currentEpisodeHasChapters);
      case SleepTimerConfigDuration(:final deadline):
        if (event is TickEvent && deadline.compareTo(event.now) <= 0) {
          return const FireDecision();
        }
        return const KeepDecision();
      case SleepTimerConfigEpisodes(:final remaining):
        if (event is EpisodeCompletedEvent) {
          if (remaining <= 1) {
            return const FireDecision(stop: SleepTimerStop.holdAtEndOfStream);
          }
          return const DecrementEpisodesDecision();
        }
        return const KeepDecision();
    }
  }

  // The timer refers to the chapter playing when it was armed: leaving it
  // cancels rather than retargets, because "the end of what I am listening
  // to now" no longer exists once the listener moves elsewhere.
  SleepTimerDecision _evaluateEndOfChapter(
    SleepTimerPlayerEvent event,
    bool currentEpisodeHasChapters,
  ) {
    // Checked before the chapter guard: leaving the episode ends the
    // timer even when its chapters are unavailable.
    if (event is ManualEpisodeSwitchedEvent) return const CancelDecision();
    if (!currentEpisodeHasChapters) return const KeepDecision();
    return switch (event) {
      ChapterChangedEvent() => const FireDecision(
        stop: SleepTimerStop.pauseNow,
      ),
      // The playing chapter ends with the episode when no later chapter
      // follows (the last chapter), so this is the same stop as the
      // end-of-episode timer, without a fade and without auto-advance.
      EpisodeCompletedEvent() => const FireDecision(
        stop: SleepTimerStop.holdAtEndOfStream,
      ),
      SeekedOutOfChapterEvent() => const CancelDecision(),
      _ => const KeepDecision(),
    };
  }
}
