// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audio_service/audio_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/episode.dart';
import 'package:seasoning/entities/sleep.dart';
import 'package:seasoning/services/audio/audio_player_state.dart';

export 'package:seasoning/services/audio/audio_player_state.dart';

part 'audio_player_service.g.dart';

enum AudioState {
  /// There hasn't been any resource loaded yet.
  idle,

  /// Resource is being loaded.
  loading,

  /// Resource is being buffered.
  buffering,

  /// Resource is buffered enough and available for playback.
  ready,

  /// The end of resource was reached.
  completed,

  /// There was an error loading resource.
  error;

  static AudioState from(AudioProcessingState state) {
    switch (state) {
      case AudioProcessingState.idle:
        return AudioState.idle;
      case AudioProcessingState.loading:
        return AudioState.loading;
      case AudioProcessingState.buffering:
        return AudioState.buffering;
      case AudioProcessingState.ready:
        return AudioState.ready;
      case AudioProcessingState.completed:
        return AudioState.completed;
      case AudioProcessingState.error:
        return AudioState.error;
    }
  }
}

/// This class defines the audio playback options supported by Anytime.
///
/// The implementing classes will then handle the specifics for the platform we
/// are running on.
@Riverpod(keepAlive: true)
class AudioPlayerService extends _$AudioPlayerService {
  /// Initialize the service.
  AudioPlayerState? build() => null;

  Future<void> setup() => throw UnimplementedError();

  /// Play a new episode, optionally resume at last save point.
  Future<void> playEpisode({
    required Episode episode,
    required Duration position,
    bool resume = true,
  }) =>
      throw UnimplementedError();

  /// Resume playing of current episode
  Future<void> play() => throw UnimplementedError();

  /// Stop playing of current episode. Set update to false to stop
  /// playback without saving any episode or positional updates.
  Future<void> stop() => throw UnimplementedError();

  /// Pause the current episode.
  Future<void> pause() => throw UnimplementedError();

  /// Rewind the current episode by pre-set number of seconds.
  Future<void> rewind() => throw UnimplementedError();

  /// Fast forward the current episode by pre-set number of seconds.
  Future<void> fastForward() => throw UnimplementedError();

  /// Seek to the specified position within the current episode.
  Future<void> seek({required Duration position}) => throw UnimplementedError();

  /// Call to set the playback speed.
  Future<void> setPlaybackSpeed(double speed) => throw UnimplementedError();

  /// Call to toggle trim silence.
  Future<void> trimSilence({required bool trim}) => throw UnimplementedError();

  /// Call to toggle trim silence.
  Future<void> volumeBoost({required bool boost}) => throw UnimplementedError();

  /// Call when the app is about to be suspended.
  Future<void> suspend() => throw UnimplementedError();

  /// Call when the app is resumed to re-establish the audio service.
  Future<void> resume() => throw UnimplementedError();

  void sleep(Sleep sleep) => throw UnimplementedError();
}
