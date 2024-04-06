// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/audio/audio_player_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_player_state.freezed.dart';

@freezed
class AudioPlayerSetting with _$AudioPlayerSetting {
  const factory AudioPlayerSetting({
    @Default(1.0) double speed,
    @Default(false) bool trimSilence,
    @Default(false) bool volumeBoost,
  }) = _AudioPlayerSetting;
}

enum PlayerPhase {
  stop,
  play,
  pause,
}

@freezed
class AudioPlayerState with _$AudioPlayerState {
  const factory AudioPlayerState({
    required Episode episode,
    required Duration position,
    required PlayerPhase phase,
    required AudioState audioState,
    @Default(false) bool interrupted,
    @Default(0) int playbackError,
  }) = _AudioPlayerState;
}

extension AudioPlayerStateExt on AudioPlayerState {
  double get percentagePlayed => episode.duration == null
      ? 0.0
      : position.inMilliseconds / episode.duration!.inMilliseconds;
}
