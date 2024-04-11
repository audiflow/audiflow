// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:isar/isar.dart';

part 'playing_episode.g.dart';

@collection
class PlayingEpisode {
  PlayingEpisode({
    required this.eid,
  });

  final Id id = 1;
  final int? eid;
}
