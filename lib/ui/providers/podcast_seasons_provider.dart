// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/podcast/podcast_season_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_seasons_provider.g.dart';

@riverpod
Future<List<Season>> podcastSeasons(
  PodcastSeasonsRef ref,
  Podcast podcast,
) async {
  return PodcastSeasonService().extractSeasons(podcast);
}
