import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';

part 'audio_player_state.freezed.dart';

@freezed
class AudioPlayerSetting with _$AudioPlayerSetting {
  const factory AudioPlayerSetting({
    @Default(1.0) double speed,
    @Default(false) bool trimSilence,
    @Default(false) bool volumeBoost,
  }) = _AudioPlayerSetting;
}

enum PlayerPhase {
  stop,
  play,
  pause,
}

@freezed
class AudioPlayerState with _$AudioPlayerState {
  const factory AudioPlayerState({
    required Episode episode,
    required Duration position,
    required PlayerPhase phase,
    required AudioState audioState,
    @Default(0) int playbackError,
  }) = _AudioPlayerState;
}

extension AudioPlayerStateExt on AudioPlayerState {
  double get percentagePlayed => episode.duration == null
      ? 0.0
      : position.inMilliseconds / episode.duration!.inMilliseconds;
}
