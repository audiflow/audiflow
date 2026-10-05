/// Coarse-grained player lifecycle events used by listeners that care
/// about "what just happened" (e.g. sleep timer).
sealed class PlayerLifecycleEvent {
  const PlayerLifecycleEvent();
}

/// The currently-loaded episode finished playing naturally
/// (`ProcessingState.completed`).
final class EpisodeCompletedLifecycle extends PlayerLifecycleEvent {
  const EpisodeCompletedLifecycle();
}

/// The user explicitly switched to a different episode while another
/// was loaded (call to `AudioPlayerController.play` with a new URL).
final class EpisodeSwitchedLifecycle extends PlayerLifecycleEvent {
  const EpisodeSwitchedLifecycle();
}

/// The player is about to move the position to [target] on request (a
/// seek, a resume at a saved or explicit position, or a seek on a restored
/// episode before audio loads).
///
/// Emitted before the position changes so listeners that follow position
/// continuity (the end-of-chapter sleep timer) can tell a jump from
/// playback. [SeekLifecycle] follows only when `AudioPlayerController.seek`
/// commits.
final class SeekStartedLifecycle extends PlayerLifecycleEvent {
  const SeekStartedLifecycle(this.target);
  final Duration target;
}

/// The user seeked to a new absolute position.
final class SeekLifecycle extends PlayerLifecycleEvent {
  const SeekLifecycle(this.position);
  final Duration position;
}
