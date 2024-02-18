// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:seasoning/entities/episode.dart';

sealed class QueueEvent {}

class QueueAddEvent implements QueueEvent {
  const QueueAddEvent({
    required this.episode,
    this.position,
  });

  final Episode episode;
  final int? position;
}

class QueueRemoveEvent implements QueueEvent {
  const QueueRemoveEvent({
    required this.episode,
  });

  final Episode episode;
}

class QueueMoveEvent implements QueueEvent {
  QueueMoveEvent({
    required this.episode,
    required this.oldIndex,
    required this.newIndex,
  });

  final Episode episode;
  final int oldIndex;
  final int newIndex;
}

class QueueClearEvent implements QueueEvent {
  const QueueClearEvent();
}

class QueueConsumeEvent implements QueueEvent {
  const QueueConsumeEvent({
    required this.playing,
    required this.queue,
  });

  final Episode playing;
  final List<Episode> queue;
}
