import 'dart:async';

import 'package:audiflow/events/audio_player_event.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/preference/data/preference_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'playback_sleep_service.freezed.dart';
part 'playback_sleep_service.g.dart';

@Riverpod(keepAlive: true)
class PlaybackSleepService extends _$PlaybackSleepService {
  Timer? _timer;

  Preference get _preference => ref.read(preferenceRepositoryProvider);

  PreferenceRepository get _preferenceRepositoryProvider =>
      ref.read(preferenceRepositoryProvider.notifier);

  AudioPlayerService get _audioPlayerService =>
      ref.read(audioPlayerServiceProvider.notifier);

  AudioPlayerState? get _audioPlayerState =>
      ref.read(audioPlayerServiceProvider);

  @override
  PlaybackSleepState build() {
    _listen();
    return _newState(_preference.playbackSleep);
  }

  void setSleepMode(SleepMode sleepMode) {
    state = _newState(sleepMode);
    _stopTimer();
    _mayStartTimer();
  }

  void clear() {
    setSleepMode(SleepMode.none);
  }

  PlaybackSleepState _newState(SleepMode sleepMode) {
    return PlaybackSleepState(
      sleepMode: sleepMode,
      startedTime: sleepMode.type == SleepType.none ? null : DateTime.now(),
      remaining: sleepMode.type == SleepType.none
          ? null
          : sleepMode.type == SleepType.episode
              ? _getEpisodeRemaining()
              : sleepMode.duration,
    );
  }

  void _listen() {
    ref
      ..listen(audioPlayerEventStreamProvider, (_, event) {
        if (event.valueOrNull
            case AudioPlayerActionEvent(action: final action)) {
          switch (action) {
            case AudioPlayerAction.play:
              _mayStartTimer();
            case AudioPlayerAction.completed:
              if (state.sleepMode.type == SleepType.episode) {
                _pausePlayback();
                state = state.copyWith(fulfilled: true);
              }
          }
        }
      })
      ..listen(audioPlayerServiceProvider.select((state) => state?.position),
          (_, position) {
        if (position != null &&
            state.sleepMode.type == SleepType.episode &&
            !state.fulfilled) {
          state = state.copyWith(remaining: _getEpisodeRemaining());
        }
      });
  }

  void _mayStartTimer() {
    if (_timer == null &&
        state.sleepMode.type == SleepType.time &&
        _audioPlayerState?.phase == PlayerPhase.play) {
      state = _newState(state.sleepMode);
      _timer = Timer.periodic(
        const Duration(milliseconds: 500),
        _onTimer,
      );
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTimer(Timer timer) {
    final remaining = state.sleepMode.duration -
        DateTime.now().difference(state.startedTime!);
    if (Duration.zero < remaining) {
      state = state.copyWith(
        remaining: remaining,
        fulfilled: remaining == Duration.zero,
      );
      return;
    }

    _stopTimer();
    _pausePlayback();
    clear();
  }

  void _pausePlayback() {
    _audioPlayerService.pause();
  }

  Duration? _getEpisodeRemaining() {
    final audioPlayerState = _audioPlayerState;
    if (audioPlayerState == null) {
      return null;
    }
    final remaining = audioPlayerState.duration - audioPlayerState.position;
    return remaining.isNegative ? null : remaining;
  }
}

@freezed
class PlaybackSleepState with _$PlaybackSleepState {
  factory PlaybackSleepState({
    required SleepMode sleepMode,
    DateTime? startedTime,
    Duration? remaining,
    @Default(false) bool fulfilled,
  }) = _PlaybackSleepState;
}
