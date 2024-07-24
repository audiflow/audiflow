import 'package:audio_service/audio_service.dart';

enum AudioState {
  /// There hasn't been any resource loaded yet.
  idle,

  /// Resource is being loaded.
  loading,

  /// Resource is being buffered.
  buffering,

  /// Resource is buffered enough and available for playback.
  ready,

  /// The end of resource was reached.
  completed,

  /// There was an error loading resource.
  error;

  static AudioState from(AudioProcessingState state) {
    switch (state) {
      case AudioProcessingState.idle:
        return AudioState.idle;
      case AudioProcessingState.loading:
        return AudioState.loading;
      case AudioProcessingState.buffering:
        return AudioState.buffering;
      case AudioProcessingState.ready:
        return AudioState.ready;
      case AudioProcessingState.completed:
        return AudioState.completed;
      case AudioProcessingState.error:
        return AudioState.error;
    }
  }
}
