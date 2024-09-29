import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/features/feed/model/model.dart';
export 'package:audiflow/features/player/model/audio_state.dart';
export 'package:audiflow/features/player/model/player_phase.dart';
export 'package:audiflow/features/player/model/sleep.dart';

part 'audio_player_preference.freezed.dart';
part 'audio_player_preference.g.dart';

@Riverpod(keepAlive: true)
class AudioPlayerPreference extends _$AudioPlayerPreference {
  @override
  Future<AudioPlayerPreferenceState> build() async {
    return const AudioPlayerPreferenceState();
  }
}

@freezed
class AudioPlayerPreferenceState with _$AudioPlayerPreferenceState {
  const factory AudioPlayerPreferenceState({
    @Default(1.0) double speed,
    @Default(false) bool trimSilence,
    @Default(false) bool volumeBoost,
  }) = _AudioPlayerPreferenceState;
}
