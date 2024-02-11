// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seasoning/entities/episode.dart';

part 'episode_event.freezed.dart';

@freezed
class EpisodeEvent with _$EpisodeEvent {
  const factory EpisodeEvent.update({
    required Episode episode,
  }) = EpisodeUpdateEvent;

  const factory EpisodeEvent.delete({
    required Episode episode,
  }) = EpisodeDeleteEvent;
}
