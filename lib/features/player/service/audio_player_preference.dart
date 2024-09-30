import 'package:audiflow/constants/audio_player.dart';
import 'package:audiflow/features/preference/data/app_preference_repository.dart';
import 'package:audiflow/features/preference/model/app_preference.dart';
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
  AppPreference get _appPreference => ref.read(appPreferenceRepositoryProvider);

  AppPreferenceRepository get _appPreferenceRepository =>
      ref.read(appPreferenceRepositoryProvider.notifier);

  @override
  Future<AudioPlayerPreferenceState> build() async {
    return AudioPlayerPreferenceState(
      speed: _appPreference.playbackSpeed,
      trimSilence: _appPreference.trimSilence,
      volumeBoost: _appPreference.volumeBoost,
    );
  }

  Future<void> changeSpeed() async {
    if (!state.hasValue) {
      return;
    }

    final i = playbackSpeeds.indexOf(state.requireValue.speed);
    final nextSpeed = playbackSpeeds[(i + 1) % playbackSpeeds.length];
    await _appPreferenceRepository.setPlaybackSpeed(nextSpeed);
    state = AsyncData(state.requireValue.copyWith(speed: nextSpeed));
  }
}

@freezed
class AudioPlayerPreferenceState with _$AudioPlayerPreferenceState {
  const factory AudioPlayerPreferenceState({
    @Default(defaultPlaybackSpeed) double speed,
    @Default(false) bool trimSilence,
    @Default(false) bool volumeBoost,
  }) = _AudioPlayerPreferenceState;
}
