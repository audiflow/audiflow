import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/player/model/audio_state.dart';
import 'package:audiflow/features/player/model/player_phase.dart';
import 'package:audiflow/features/player/model/sleep.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/features/feed/model/model.dart';
export 'package:audiflow/features/player/model/audio_state.dart';
export 'package:audiflow/features/player/model/player_phase.dart';
export 'package:audiflow/features/player/model/sleep.dart';

part 'audio_player_service.freezed.dart';
part 'audio_player_service.g.dart';

/// This class defines the audio playback options supported by Anytime.
///
/// The implementing classes will then handle the specifics for the platform we
/// are running on.
@Riverpod(keepAlive: true)
class AudioPlayerService extends _$AudioPlayerService {
  /// Initialize the service.
  @override
  AudioPlayerState? build() => null;

  Future<void> ensureInitialized() => throw UnimplementedError();

  /// Load a new episode, and play if [autoPlay] is true.
  Future<void> loadEpisode({
    required Episode episode,
    required Duration position,
    required bool autoPlay,
  }) =>
      throw UnimplementedError();

  /// Resume playing of current episode
  FutureOr<void> play() => throw UnimplementedError();

  /// Stop playing of current episode. Set update to false to stop
  /// playback without saving any episode or positional updates.
  Future<void> stop() => throw UnimplementedError();

  /// Pause the current episode.
  Future<void> pause() => throw UnimplementedError();

  Future<void> togglePlayPause() => throw UnimplementedError();

  /// Rewind the current episode by pre-set number of seconds.
  Future<void> rewind() => throw UnimplementedError();

  /// Fast forward the current episode by pre-set number of seconds.
  Future<void> fastForward() => throw UnimplementedError();

  /// Seek to the specified position within the current episode.
  Future<void> seek({required Duration position}) => throw UnimplementedError();

  /// Call to set the playback speed.
  Future<void> setPlaybackSpeed(double speed) => throw UnimplementedError();

  /// Call to toggle trim silence.
  Future<void> trimSilence({required bool trim}) => throw UnimplementedError();

  /// Call to toggle trim silence.
  Future<void> volumeBoost({required bool boost}) => throw UnimplementedError();

  /// Call when the app is about to be suspended.
  Future<void> suspend() => throw UnimplementedError();

  /// Call when the app is resumed to re-establish the audio service.
  Future<void> resume() => throw UnimplementedError();

  void sleep(Sleep sleep) => throw UnimplementedError();
}

@freezed
class AudioPlayerState with _$AudioPlayerState {
  const factory AudioPlayerState({
    required Episode episode,
    required Duration position,
    required PlayerPhase phase,
    required AudioState audioState,
    @Default(false) bool interrupted,
    @Default(0) int playbackError,
  }) = _AudioPlayerState;
}

extension AudioPlayerStateExt on AudioPlayerState {
  double get percentagePlayed => episode.duration == null
      ? 0.0
      : position.inMilliseconds / episode.duration!.inMilliseconds;
}

@freezed
class AudioPlayerSetting with _$AudioPlayerSetting {
  const factory AudioPlayerSetting({
    @Default(1.0) double speed,
    @Default(false) bool trimSilence,
    @Default(false) bool volumeBoost,
  }) = _AudioPlayerSetting;
}
