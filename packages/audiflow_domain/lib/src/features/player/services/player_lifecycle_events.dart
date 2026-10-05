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
/// playback. [SeekLifecycle] follows once the position has moved, or
/// [SeekFailedLifecycle] when the player rejects the seek; both carry the
/// same [seekId] so a late report cannot close a newer seek.
final class SeekStartedLifecycle extends PlayerLifecycleEvent {
  const SeekStartedLifecycle(
    this.target, {
    required this.seekId,
    this.automatic = false,
  });
  final Duration target;

  /// Identifies this seek among overlapping ones.
  final int seekId;

  /// True when the player moves the position on its own rather than
  /// because the listener asked to go there: resuming the saved position
  /// of the episode it loads, or rewinding a little after an audio
  /// interruption. Such a seek does not leave the chapter the listener was
  /// in, so it never cancels a sleep timer.
  final bool automatic;
}

/// The position moved to a new absolute position on request, as announced
/// by the [SeekStartedLifecycle] with the same [seekId].
final class SeekLifecycle extends PlayerLifecycleEvent {
  const SeekLifecycle(this.position, {required this.seekId});
  final Duration position;
  final int seekId;
}

/// The seek announced by the [SeekStartedLifecycle] with the same [seekId]
/// failed; the player stayed at [position] instead of moving to the target.
final class SeekFailedLifecycle extends PlayerLifecycleEvent {
  const SeekFailedLifecycle(this.position, {required this.seekId});
  final Duration position;
  final int seekId;
}
