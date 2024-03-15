// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';

import 'jp/jp1450522865.dart';
import 'jp/jp1567192930.dart';
import 'podcast_season_extractor.dart';

class PodcastSeasonService {
  factory PodcastSeasonService() {
    return _instance;
  }

  PodcastSeasonService._() {
    final extractors = [
      JP1450522865(),
      JP1567192930(),
    ];

    for (final extractor in extractors) {
      _extractors[extractor.guid] = extractor;
    }
  }

  static final _instance = PodcastSeasonService._();

  final _extractors = <String, PodcastSeasonExtractor>{};

  List<Season> extractSeasons(Podcast podcast) {
    final extractor =
        _extractors[podcast.guid] ?? DefaultPodcastSeasonExtractor();
    return extractor.extractSeasons(podcast);
  }
}
