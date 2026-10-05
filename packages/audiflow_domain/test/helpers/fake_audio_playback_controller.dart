import 'package:audiflow_domain/audiflow_domain.dart';

/// Fake implementation of [AudioPlaybackController] for use in tests.
class FakeAudioPlaybackController implements AudioPlaybackController {
  bool resumeCalled = false;
  bool pauseCalled = false;
  bool stopCalled = false;
  bool skipForwardCalled = false;
  bool skipBackwardCalled = false;
  Duration? lastSeekPosition;

  @override
  Future<void> resume() async => resumeCalled = true;

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
}
