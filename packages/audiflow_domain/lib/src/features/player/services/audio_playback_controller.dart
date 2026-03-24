/// Minimal interface for controlling audio playback.
///
/// Extracted from [AudioPlayerController] so that voice command execution
/// and other domain services can depend on a testable abstraction rather
/// than the concrete Riverpod notifier.
abstract class AudioPlaybackController {
  /// Pauses the current playback.
  Future<void> pause();

  /// Stops the current playback and clears the audio source.
  Future<void> stop();

  /// Skips forward by the user-configured duration.
  Future<void> skipForward();

  /// Skips backward by the user-configured duration.
  Future<void> skipBackward();

  /// Seeks to the specified absolute position.
  Future<void> seek(Duration position);

  /// Resumes playback if paused.
  Future<void> resume();

  /// Sets the playback speed and persists it to settings.
  Future<void> setSpeed(double speed);
}
