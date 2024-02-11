import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/events/transcript_event.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';

part 'audio_player_state.freezed.dart';

@freezed
class AudioPlayerState with _$AudioPlayerState {
  const factory AudioPlayerState.empty({
    required double speed,
    required bool trimSilence,
    required bool volumeBoost,
  }) = EmptyAudioPlayerState;

  const factory AudioPlayerState.ready({
    required double speed,
    required bool trimSilence,
    required bool volumeBoost,
    required Episode nowPlaying,
    required AudioState playingState,
    TranscriptState? transcript,
    @Default(0) double transitionPosition,
    @Default(0) int playbackError,
  }) = ReadyAudioPlayerState;
}
