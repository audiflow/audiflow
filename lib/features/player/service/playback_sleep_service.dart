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

  @override
  PlaybackSleepState build() {
    _listen();
    return PlaybackSleepState(
      sleepMode: ref.read(preferenceRepositoryProvider).playbackSleep,
    );
  }

  void setSleepMode(SleepMode sleepMode) {
    state = state.copyWith(
      sleepMode: sleepMode,
      startedTime: sleepMode.type == SleepType.none ? null : DateTime.now(),
      remaining: sleepMode.type == SleepType.none
          ? null
          : sleepMode.type == SleepType.episode
              ? _getEpisodeRemaining()
              : sleepMode.duration,
      fulfilled: false,
    );
    _stopTimer();
    if (sleepMode.type == SleepType.time) {
      _startTimer();
    }
  }

  void clear() {
    setSleepMode(SleepMode.none);
  }

  void _listen() {
    ref
      ..listen(audioPlayerEventStreamProvider, (_, event) {
        if (event.valueOrNull
            case AudioPlayerActionEvent(action: final action)) {
          switch (action) {
            case AudioPlayerAction.play:
              break;
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

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      _onTimer,
    );
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
    ref.read(audioPlayerServiceProvider.notifier).pause();
  }

  Duration? _getEpisodeRemaining() {
    final audioPlayerState = ref.read(audioPlayerServiceProvider);
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
