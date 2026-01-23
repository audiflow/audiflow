import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import '../../feed/repositories/episode_repository_impl.dart';
import '../models/now_playing_info.dart';
import '../models/playback_progress.dart';
import '../models/playback_state.dart';
import 'now_playing_controller.dart';
import 'playback_history_service.dart';

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
/// Integrates with [PlaybackHistoryService] to track playback progress
/// and auto-mark episodes as completed.
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
  StreamSubscription<PlayerState>? _stateSubscription;
  String? _currentUrl;
  int? _currentEpisodeId;

  @override
  PlaybackState build() {
    _player = ref.watch(audioPlayerProvider);
    _listenToPlayerState();
    _listenToProgress();
    ref.onDispose(_cleanup);
    return const PlaybackState.idle();
  }

  void _listenToProgress() {
    ref.listen<AsyncValue<PlaybackProgress>>(playbackProgressStreamProvider, (
      previous,
      next,
    ) {
      final progress = next.value;
      if (progress == null || _currentEpisodeId == null) return;

      final historyService = ref.read(playbackHistoryServiceProvider);
      historyService.onProgressUpdate(_currentEpisodeId!, progress);
    });
  }

  void _listenToPlayerState() {
    _stateSubscription = _player.playerStateStream.listen(
      (playerState) async {
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
          // Save final progress before clearing
          await _saveProgressOnStop();
          state = const PlaybackState.idle();
          _currentUrl = null;
          _currentEpisodeId = null;
        } else {
          state = PlaybackState.paused(episodeUrl: url);
        }
      },
      onError: (error) {
        state = PlaybackState.error(message: error.toString());
      },
    );
  }

  Future<void> _saveProgressOnStop() async {
    if (_currentEpisodeId == null) return;

    final progress = ref.read(playbackProgressProvider);
    if (progress == null) return;

    final historyService = ref.read(playbackHistoryServiceProvider);
    await historyService.onPlaybackStopped(_currentEpisodeId!, progress);
  }

  void _cleanup() {
    _stateSubscription?.cancel();
  }

  /// Plays audio from the specified URL.
  ///
  /// If audio is already playing from a different URL, it will stop the
  /// current playback and start the new audio.
  ///
  /// Optional [metadata] can be provided to display episode information
  /// in the mini player without needing to fetch it from the database.
  ///
  /// Integrates with [PlaybackHistoryService] to track playback progress.
  Future<void> play(String url, {NowPlayingInfo? metadata}) async {
    try {
      // Save progress of previous episode before switching
      if (_currentEpisodeId != null && _currentUrl != url) {
        await _saveProgressOnStop();
      }

      // Look up episode ID from URL
      final episodeRepo = ref.read(episodeRepositoryProvider);
      final episode = await episodeRepo.getByAudioUrl(url);

      _currentUrl = url;
      _currentEpisodeId = episode?.id;
      state = PlaybackState.loading(episodeUrl: url);

      // Update now playing controller if metadata is provided
      if (metadata != null) {
        ref.read(nowPlayingControllerProvider.notifier).setNowPlaying(metadata);
      }

      await _player.setUrl(url);

      // Notify history service of playback start
      if (_currentEpisodeId != null) {
        final historyService = ref.read(playbackHistoryServiceProvider);
        await historyService.onPlaybackStarted(
          _currentEpisodeId!,
          _player.position.inMilliseconds,
        );
      }

      await _player.play();
    } catch (e) {
      state = PlaybackState.error(message: 'Failed to play audio: $e');
    }
  }

  /// Pauses the current playback.
  ///
  /// Saves playback progress to history.
  Future<void> pause() async {
    // Save progress on pause
    if (_currentEpisodeId != null) {
      final progress = ref.read(playbackProgressProvider);
      if (progress != null) {
        final historyService = ref.read(playbackHistoryServiceProvider);
        await historyService.onPlaybackPaused(_currentEpisodeId!, progress);
      }
    }
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
  ///
  /// Saves final playback progress to history.
  Future<void> stop() async {
    // Save final progress before stopping
    await _saveProgressOnStop();

    await _player.stop();
    _currentUrl = null;
    _currentEpisodeId = null;
    state = const PlaybackState.idle();
    ref.read(nowPlayingControllerProvider.notifier).clear();
  }

  /// Returns the URL of the currently loaded audio, if any.
  String? get currentUrl => _currentUrl;

  /// Returns the episode ID of the currently loaded audio, if any.
  int? get currentEpisodeId => _currentEpisodeId;

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

  /// Seeks to the specified position.
  ///
  /// Clamps position between zero and duration to prevent invalid seeks.
  /// No-op if no audio is loaded or duration is unknown.
  Future<void> seek(Duration position) async {
    if (_currentUrl == null) return;
    final duration = _player.duration;
    if (duration == null) return;

    final clampedMs = position.inMilliseconds.clamp(0, duration.inMilliseconds);
    await _player.seek(Duration(milliseconds: clampedMs));
  }

  /// Skips forward by the specified duration (default 30s).
  ///
  /// Clamped to duration if near the end.
  Future<void> skipForward([
    Duration amount = const Duration(seconds: 30),
  ]) async {
    if (_currentUrl == null) return;
    await seek(_player.position + amount);
  }

  /// Skips backward by the specified duration (default 30s).
  ///
  /// Clamped to zero if near the start.
  Future<void> skipBackward([
    Duration amount = const Duration(seconds: 30),
  ]) async {
    if (_currentUrl == null) return;
    await seek(_player.position - amount);
  }
}
