import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:audio_session/audio_session.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

final _log = Logger(printer: PrefixPrinter(PrettyPrinter(methodCount: 0)));

/// Audio handler that bridges platform media controls to the app's
/// existing playback infrastructure.
///
/// Uses the official audio_service pattern: pipes just_audio's
/// [PlaybackEvent] stream directly into [playbackState] for reliable
/// platform media control sync (lock screen, control center).
///
/// Delegates all playback actions to [AudioPlayerController].
class AudiflowAudioHandler extends audio_service.BaseAudioHandler
    with audio_service.SeekHandler {
  AudiflowAudioHandler(this._ref) {
    _log.i('[AudioHandler] Initializing AudiflowAudioHandler');
    _player = _ref.read(audioPlayerProvider);
    _configureAudioSession();
    _pipePlaybackState();
  }

  final Ref _ref;
  late final AudioPlayer _player;

  AudioPlayerController get _controller =>
      _ref.read(audioPlayerControllerProvider.notifier);

  /// Pipes just_audio's playbackEventStream directly to audio_service's
  /// playbackState BehaviorSubject, matching the official pattern.
  void _pipePlaybackState() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  audio_service.PlaybackState _transformEvent(PlaybackEvent event) {
    return audio_service.PlaybackState(
      controls: [
        audio_service.MediaControl.skipToPrevious,
        audio_service.MediaControl.rewind,
        if (_player.playing)
          audio_service.MediaControl.pause
        else
          audio_service.MediaControl.play,
        audio_service.MediaControl.fastForward,
        audio_service.MediaControl.skipToNext,
        audio_service.MediaControl.stop,
      ],
      systemActions: const {
        audio_service.MediaAction.seek,
        audio_service.MediaAction.seekForward,
        audio_service.MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 2, 4],
      processingState: switch (_player.processingState) {
        ProcessingState.idle => audio_service.AudioProcessingState.idle,
        ProcessingState.loading => audio_service.AudioProcessingState.loading,
        ProcessingState.buffering =>
          audio_service.AudioProcessingState.buffering,
        ProcessingState.ready => audio_service.AudioProcessingState.ready,
        ProcessingState.completed =>
          audio_service.AudioProcessingState.completed,
      },
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    // Use playback category for podcast audio that continues in background.
    // speech() uses playAndRecord + voiceChat mode, which iOS may suspend.
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions:
            AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ),
    );

    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            pause();
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
          case AudioInterruptionType.pause:
            play();
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });

    session.becomingNoisyEventStream.listen((_) => pause());
  }

  /// Updates the platform media item (lock screen / notification metadata).
  void syncNowPlaying(NowPlayingInfo? info) {
    if (info == null) {
      _log.d('[AudioHandler] NowPlaying cleared');
      mediaItem.add(null);
      return;
    }

    _log.i(
      '[AudioHandler] NowPlaying: '
      '${info.episodeTitle} - ${info.podcastTitle}',
    );

    mediaItem.add(
      audio_service.MediaItem(
        id: info.episodeUrl,
        title: info.episodeTitle,
        artist: info.podcastTitle,
        artUri: info.artworkUrl != null ? Uri.parse(info.artworkUrl!) : null,
        duration: info.totalDuration,
      ),
    );
  }

  /// Updates the media item duration without changing other fields.
  void updateDuration(Duration duration) {
    final current = mediaItem.value;
    if (current != null && current.duration != duration) {
      mediaItem.add(current.copyWith(duration: duration));
    }
  }

  @override
  Future<void> play() async => _controller.resume();

  @override
  Future<void> pause() async => _controller.pause();

  @override
  Future<void> stop() async {
    await _controller.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async => _controller.seek(position);

  @override
  Future<void> skipToNext() async => _controller.skipForward();

  @override
  Future<void> skipToPrevious() async => _controller.skipBackward();

  @override
  Future<void> fastForward() async => _controller.skipForward();

  @override
  Future<void> rewind() async => _controller.skipBackward();
}
