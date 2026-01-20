import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_state.freezed.dart';

/// Represents the current state of audio playback.
///
/// This sealed class provides type-safe state management for the audio player,
/// allowing the UI to react appropriately to different playback conditions.
@freezed
sealed class PlaybackState with _$PlaybackState {
  /// Player is idle with no audio loaded.
  const factory PlaybackState.idle() = PlaybackIdle;

  /// Audio is loading from the specified URL.
  const factory PlaybackState.loading({required String episodeUrl}) =
      PlaybackLoading;

  /// Audio is actively playing.
  const factory PlaybackState.playing({required String episodeUrl}) =
      PlaybackPlaying;

  /// Audio is paused.
  const factory PlaybackState.paused({required String episodeUrl}) =
      PlaybackPaused;

  /// An error occurred during playback.
  const factory PlaybackState.error({required String message}) = PlaybackError;
}
