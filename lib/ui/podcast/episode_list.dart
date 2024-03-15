// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/types.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/providers/podcast/episodes_group_provider.dart';
import 'package:audiflow/ui/podcast/episode_tile.dart';
import 'package:audiflow/ui/podcast/types.dart';
import 'package:audiflow/ui/widgets/fill_remaining_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EpisodeList extends HookConsumerWidget {
  const EpisodeList({
    super.key,
    required this.episodeGroupKey,
    required this.metadata,
    required this.episodes,
    this.thumbnailVisibility = ThumbnailVisibility.auto,
  });

  final Key episodeGroupKey;
  final PodcastMetadata metadata;
  final List<Episode> episodes;
  final ThumbnailVisibility thumbnailVisibility;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (episodes.isEmpty) {
      return FillRemainingError.podcastNoResults();
    }

    final episodesGroup =
        ref.watch(episodesGroupProvider(episodeGroupKey).notifier);
    useEffect(
      () {
        episodesGroup.setup(episodes);
        return null;
      },
      [],
    );

    return NotificationListener<PlayButtonTappedNotification>(
      onNotification: (notification) {
        episodesGroup.togglePlayState(episode: notification.episode);
        return false;
      },
      child: SliverSafeArea(
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final episode = episodes[index];

              final bool showsThumbnail;
              switch (thumbnailVisibility) {
                case ThumbnailVisibility.auto:
                  showsThumbnail =
                      episode.thumbImageUrl != metadata.thumbImageUrl;
                case ThumbnailVisibility.visible:
                  showsThumbnail = true;
                case ThumbnailVisibility.hidden:
                  showsThumbnail = false;
              }

              return EpisodeTile(
                showsThumbnail: showsThumbnail,
                metadata: metadata,
                episode: episode,
              );
            },
            childCount: episodes.length,
            addAutomaticKeepAlives: false,
          ),
        ),
      ),
    );
  }
}
