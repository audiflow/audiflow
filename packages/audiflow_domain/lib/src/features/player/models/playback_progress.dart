import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_progress.freezed.dart';

/// Playback progress information including position, duration, and buffered.
///
/// Provides a computed [progress] getter for easy progress bar rendering.
@freezed
sealed class PlaybackProgress with _$PlaybackProgress {
  const PlaybackProgress._();

  const factory PlaybackProgress({
    required Duration position,
    required Duration duration,
    required Duration bufferedPosition,
  }) = _PlaybackProgress;

  /// Returns the playback progress as a value from 0.0 to 1.0.
  ///
  /// Returns 0.0 if duration is zero to avoid division by zero.
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    final value = position.inMilliseconds / duration.inMilliseconds;
    return value.clamp(0.0, 1.0);
  }

  /// Returns the buffered progress as a value from 0.0 to 1.0.
  double get bufferedProgress {
    if (duration.inMilliseconds == 0) return 0.0;
    final value = bufferedPosition.inMilliseconds / duration.inMilliseconds;
    return value.clamp(0.0, 1.0);
  }
}
