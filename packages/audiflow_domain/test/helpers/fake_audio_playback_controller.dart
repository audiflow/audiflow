import 'package:audiflow_domain/audiflow_domain.dart';

/// Fake implementation of [AudioPlaybackController] for use in tests.
///
/// Records the last speed set via [setSpeed] so tests can assert
/// the executor notified the audio layer.
class FakeAudioPlaybackController implements AudioPlaybackController {
  double? lastSetSpeed;
  bool pauseCalled = false;
  bool stopCalled = false;
  bool skipForwardCalled = false;
  bool skipBackwardCalled = false;
  Duration? lastSeekPosition;

  @override
  Future<void> pause() async => pauseCalled = true;

  @override
  Future<void> stop() async => stopCalled = true;

  @override
  Future<void> skipForward() async => skipForwardCalled = true;

  @override
  Future<void> skipBackward() async => skipBackwardCalled = true;

  @override
  Future<void> seek(Duration position) async => lastSeekPosition = position;

  @override
  Future<void> setSpeed(double speed) async => lastSetSpeed = speed;
}
