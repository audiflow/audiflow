import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/audio/audio_player_state.dart';
import 'package:seasoning/providers/audio_player_service_provider.dart';
import 'package:seasoning/providers/settings_service_provider.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';

part 'audio_player_provider.g.dart';

enum TransitionState {
  play,
  pause,
  stop,
  fastForward,
  rewind,
}

enum LifecycleState {
  pause,
  resume,
  detach,
}

@riverpod
class AudioPlayer extends _$AudioPlayer {
  AudioPlayer() {
    _handlePlayingStateTransitions();
    _handlePlayingState();
  }

  final log = Logger('AudioController');
  final PublishSubject<TransitionState> _transitionPlayingState =
      PublishSubject<TransitionState>();

  AudioPlayerService get audioPlayerService =>
      ref.read(audioPlayerServiceProvider);

  @override
  AudioPlayerState build() {
    final settings = ref.read(settingsServiceProvider);
    return AudioPlayerState.empty(
        speed: settings.playbackSpeed,
        trimSilence: settings.trimSilence,
        volumeBoost: settings.volumeBoost,);
  }

  void play(Episode episode, {bool resume = true}) {
    log.fine('Audio lifecycle playEpisode');
    audioPlayerService.playEpisode(episode: episode, resume: resume);
  }

  void pause() {
    log.fine('Audio lifecycle pause');
    audioPlayerService.suspend();
  }

  void resume() {
    log.fine('Audio lifecycle resume');

    if (state is! ReadyAudioPlayerState) {
      log.fine('Resuming without an episode');
      return;
    }

    audioPlayerService.resume();
  }

  /// Transition the state from connecting, to play, pause, stop etc.
  void Function(TransitionState) get transitionState =>
      _transitionPlayingState.add;

  void _handlePlayingStateTransitions() {
    _transitionPlayingState
        .asyncMap(Future.value)
        .listen((state) async {
      switch (state) {
        case TransitionState.play:
          await audioPlayerService.play();
        case TransitionState.pause:
          await audioPlayerService.pause();
        case TransitionState.fastForward:
          await audioPlayerService.fastForward();
        case TransitionState.rewind:
          await audioPlayerService.rewind();
        case TransitionState.stop:
          await audioPlayerService.stop();
      }
    });

    ref.onDispose(_transitionPlayingState.close);
  }

  void _handlePlayingState() {
    final s1 = Rx.combineLatest2<AudioState, Episode?, void>(
        audioPlayerService.playingState!, audioPlayerService.episodeEvent!,
        (playingState, nowPlaying) {
      if (playingState == AudioState.none) {
        state = AudioPlayerState.empty(
          speed: state.speed,
          trimSilence: state.trimSilence,
          volumeBoost: state.volumeBoost,
        );
        return;
      } else if (nowPlaying != null) {
        state = AudioPlayerState.ready(
          speed: state.speed,
          trimSilence: state.trimSilence,
          volumeBoost: state.volumeBoost,
          nowPlaying: nowPlaying,
          playingState: playingState,
        );
      }
    }).listen((event) {});
    ref.onDispose(s1.cancel);
  }
}
