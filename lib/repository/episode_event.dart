// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/episode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_event.g.dart';

sealed class EpisodeEvent {}

class EpisodeUpdatedEvent implements EpisodeEvent {
  const EpisodeUpdatedEvent(this.episode);

  final Episode episode;
}

class EpisodeDeletedEvent implements EpisodeEvent {
  const EpisodeDeletedEvent(this.episode);

  final Episode episode;
}

class EpisodeStatsUpdatedEvent implements EpisodeEvent {
  const EpisodeStatsUpdatedEvent(this.stats);

  final EpisodeStats stats;
}

@Riverpod(keepAlive: true)
class EpisodeEventStream extends _$EpisodeEventStream {
  @override
  Stream<EpisodeEvent> build() async* {}

  void add(EpisodeEvent event) {
    state = AsyncData(event);
  }
}
