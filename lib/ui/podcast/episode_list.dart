// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/ui/podcast/episode_tile.dart';
import 'package:seasoning/ui/podcast/types.dart';
import 'package:seasoning/ui/widgets/fill_remaining_error.dart';

class EpisodeList extends StatelessWidget {
  const EpisodeList({
    super.key,
    required this.summary,
    required this.episodes,
    this.thumbnailVisibility = ThumbnailVisibility.auto,
  });

  final PodcastSummary summary;
  final List<Episode> episodes;
  final ThumbnailVisibility thumbnailVisibility;

  @override
  Widget build(BuildContext context) {
    if (episodes.isEmpty) {
      return FillRemainingError.podcastNoResults();
    }

    return SliverSafeArea(
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final episode = episodes[index];

            final bool showsThumbnail;
            switch (thumbnailVisibility) {
              case ThumbnailVisibility.auto:
                showsThumbnail = episode.thumbImageUrl != summary.thumbImageUrl;
              case ThumbnailVisibility.visible:
                showsThumbnail = true;
              case ThumbnailVisibility.hidden:
                showsThumbnail = false;
            }

            return EpisodeTile(
              showsThumbnail: showsThumbnail,
              episode: episode,
            );
          },
          childCount: episodes.length,
          addAutomaticKeepAlives: false,
        ),
      ),
    );
  }
}
