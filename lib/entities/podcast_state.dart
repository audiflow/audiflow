// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'podcast_state.freezed.dart';

/// A class that represents an instance of a podcast.
///
/// When persisted to disk this represents a podcast that is being followed.
@freezed
class PodcastState with _$PodcastState {
  const factory PodcastState({
    /// Indicates whether the user wants to see the podcast as a list of seasons
    @Default(false) bool seasonView,
    @Default(false) bool newEpisodes,
    @Default(false) bool updatedEpisodes,
  }) = _PodcastState;
}
