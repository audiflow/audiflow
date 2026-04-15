/// How the audio player should react when another app or the system
/// requests a transient, duckable audio focus loss (e.g. a short
/// notification chime).
enum DuckInterruptionBehavior {
  /// Lower the player's volume for the duration of the interruption
  /// (platform-conventional behavior). Playback does not stop.
  duck,

  /// Pause playback for the duration of the interruption and resume
  /// when the interruption ends. Before pausing, the player rewinds a
  /// short amount so the listener does not miss content.
  pause,
}
