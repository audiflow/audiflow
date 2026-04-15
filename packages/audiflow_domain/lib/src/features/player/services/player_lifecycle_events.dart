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

/// The user seeked to a new absolute position.
final class SeekLifecycle extends PlayerLifecycleEvent {
  const SeekLifecycle(this.position);
  final Duration position;
}
