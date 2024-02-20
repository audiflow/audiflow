// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/ui/podcast/episode_tile.dart';
import 'package:seasoning/ui/podcast/types.dart';

class SeasonEpisodeList extends StatelessWidget {
  const SeasonEpisodeList({
    super.key,
    required this.summary,
    required this.episodes,
    this.thumbnailVisibility = ThumbnailVisibility.auto,
    this.icon = _defaultIcon,
    this.emptyMessage = '',
  });

  final PodcastSummary summary;
  final List<Episode> episodes;
  final ThumbnailVisibility thumbnailVisibility;
  final IconData icon;
  final String emptyMessage;

  static const _defaultIcon = Icons.add_alert;

  @override
  Widget build(BuildContext context) {
    return SliverSafeArea(
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final episode = episodes[index];

            final bool showsThumbnail;
            switch (thumbnailVisibility) {
              case ThumbnailVisibility.auto:
                showsThumbnail =
                    episode.thumbImageUrl != episodes.first.thumbImageUrl;
              case ThumbnailVisibility.visible:
                showsThumbnail = true;
              case ThumbnailVisibility.hidden:
                showsThumbnail = false;
            }

            return EpisodeTile(
              showsThumbnail: showsThumbnail,
              episode: episode,
              download: true,
              play: true,
            );
          },
          childCount: episodes.length,
          addAutomaticKeepAlives: false,
        ),
      ),
    );
  }
}
