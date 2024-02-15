// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:seasoning/entities/episode.dart';

sealed class EpisodeEvent {}

class EpisodeInsertedEvent implements EpisodeEvent {
  const EpisodeInsertedEvent(this.episode);

  final Episode episode;
}

class EpisodeUpdatedEvent implements EpisodeEvent {
  const EpisodeUpdatedEvent(this.episode);

  final Episode episode;
}

class EpisodeDeletedEvent implements EpisodeEvent {
  const EpisodeDeletedEvent(this.episode);

  final Episode episode;
}
