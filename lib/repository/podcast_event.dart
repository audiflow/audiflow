// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_event.g.dart';

sealed class PodcastEvent {}

class PodcastSubscribedEvent implements PodcastEvent {
  const PodcastSubscribedEvent(this.podcast, this.stats);

  final Podcast podcast;
  final PodcastStats stats;
}

class PodcastUnsubscribedEvent implements PodcastEvent {
  const PodcastUnsubscribedEvent(this.podcast, this.stats);

  final Podcast podcast;
  final PodcastStats stats;
}

class PodcastUpdatedEvent implements PodcastEvent {
  const PodcastUpdatedEvent(this.podcast, {this.stats});

  final Podcast podcast;
  final PodcastStats? stats;
}

class PodcastStatsUpdatedEvent implements PodcastEvent {
  const PodcastStatsUpdatedEvent(this.stats);

  final PodcastStats stats;
}

@Riverpod(keepAlive: true)
class PodcastEventStream extends _$PodcastEventStream {
  @override
  Stream<PodcastEvent> build() async* {}

  void add(PodcastEvent event) {
    state = AsyncData(event);
  }
}
