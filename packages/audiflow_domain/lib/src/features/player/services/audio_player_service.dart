import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import '../models/now_playing_info.dart';
import '../models/playback_progress.dart';
import '../models/playback_state.dart';
import 'now_playing_controller.dart';

part 'audio_player_service.g.dart';

/// Provides a singleton [AudioPlayer] instance.
///
/// This provider is kept alive for the app's lifetime to maintain audio state
/// across navigation and screen changes.
@Riverpod(keepAlive: true)
AudioPlayer audioPlayer(Ref ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
}

/// Provides a stream of playback progress updates.
///
/// Combines position, duration, and buffered position into a single stream.
/// Updates approximately every 200ms while playing.
@Riverpod(keepAlive: true)
Stream<PlaybackProgress> playbackProgressStream(Ref ref) {
  final player = ref.watch(audioPlayerProvider);

  return Rx.combineLatest3<Duration, Duration?, Duration, PlaybackProgress>(
    player.positionStream,
    player.durationStream,
    player.bufferedPositionStream,
    (position, duration, buffered) => PlaybackProgress(
      position: position,
      duration: duration ?? Duration.zero,
      bufferedPosition: buffered,
    ),
  );
}

/// Provides the current playback progress.
///
/// Returns null when no audio is loaded.
@riverpod
PlaybackProgress? playbackProgress(Ref ref) {
  final asyncProgress = ref.watch(playbackProgressStreamProvider);
  return asyncProgress.value;
}

/// Controller for managing audio playback.
///
/// Wraps [AudioPlayer] to provide a simplified interface and exposes
/// playback state as a reactive [PlaybackState] stream.
///
/// Usage:
/// ```dart
/// final state = ref.watch(audioPlayerControllerProvider);
/// final controller = ref.read(audioPlayerControllerProvider.notifier);
/// await controller.play('https://example.com/episode.mp3');
/// ```
@Riverpod(keepAlive: true)
class AudioPlayerController extends _$AudioPlayerController {
  late final AudioPlayer _player;
  StreamSubscription<PlayerState>? _subscription;
  String? _currentUrl;

  @override
  PlaybackState build() {
    _player = ref.watch(audioPlayerProvider);
    _listenToPlayerState();
    ref.onDispose(_cleanup);
    return const PlaybackState.idle();
  }

  void _listenToPlayerState() {
    _subscription = _player.playerStateStream.listen(
      (playerState) {
        final processingState = playerState.processingState;
        final playing = playerState.playing;

        if (_currentUrl == null) {
          state = const PlaybackState.idle();
          return;
        }

        final url = _currentUrl!;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          state = PlaybackState.loading(episodeUrl: url);
        } else if (playing) {
          state = PlaybackState.playing(episodeUrl: url);
        } else if (processingState == ProcessingState.completed) {
          state = const PlaybackState.idle();
          _currentUrl = null;
        } else {
          state = PlaybackState.paused(episodeUrl: url);
        }
      },
      onError: (error) {
        state = PlaybackState.error(message: error.toString());
      },
    );
  }

  void _cleanup() {
    _subscription?.cancel();
  }

  /// Plays audio from the specified URL.
  ///
  /// If audio is already playing from a different URL, it will stop the
  /// current playback and start the new audio.
  ///
  /// Optional [metadata] can be provided to display episode information
  /// in the mini player without needing to fetch it from the database.
  Future<void> play(String url, {NowPlayingInfo? metadata}) async {
    try {
      _currentUrl = url;
      state = PlaybackState.loading(episodeUrl: url);

      // Update now playing controller if metadata is provided
      if (metadata != null) {
        ref.read(nowPlayingControllerProvider.notifier).setNowPlaying(metadata);
      }

      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      state = PlaybackState.error(message: 'Failed to play audio: $e');
    }
  }

  /// Pauses the current playback.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resumes playback if paused.
  Future<void> resume() async {
    await _player.play();
  }

  /// Toggles between play and pause states.
  ///
  /// If audio is playing, it will pause. If paused, it will resume.
  /// If a URL is provided and no audio is loaded, it will start playing
  /// from that URL.
  Future<void> togglePlayPause([String? url]) async {
    if (_player.playing) {
      await pause();
    } else if (_currentUrl != null) {
      await resume();
    } else if (url != null) {
      await play(url);
    }
  }

  /// Stops playback and clears the current audio source.
  Future<void> stop() async {
    await _player.stop();
    _currentUrl = null;
    state = const PlaybackState.idle();
    ref.read(nowPlayingControllerProvider.notifier).clear();
  }

  /// Returns the URL of the currently loaded audio, if any.
  String? get currentUrl => _currentUrl;

  /// Returns true if the specified URL is currently playing.
  bool isPlaying(String url) {
    return state.maybeWhen(
      playing: (episodeUrl) => episodeUrl == url,
      orElse: () => false,
    );
  }

  /// Returns true if the specified URL is currently loaded (playing or paused).
  bool isLoaded(String url) {
    return _currentUrl == url;
  }
}
