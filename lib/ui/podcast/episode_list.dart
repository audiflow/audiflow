// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/types.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/podcast/episode_tile.dart';
import 'package:audiflow/ui/podcast/types.dart';
import 'package:audiflow/ui/providers/episodes_group_provider.dart';
import 'package:audiflow/ui/providers/episodes_list_event_provider.dart';
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
    required this.scrollController,
    this.thumbnailVisibility = ThumbnailVisibility.auto,
  });

  final Key episodeGroupKey;
  final PodcastMetadata metadata;
  final List<Episode> episodes;
  final ThumbnailVisibility thumbnailVisibility;
  final ScrollController scrollController;

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

    ref.listen(episodesListEventStreamProvider, (_, next) {
      next.whenData((event) async {
        if (event is MenuScrollToEpisodeEvent) {
          final guid = await episodesGroup.getLastListenedEpisode();
          if (guid == null) {
            return;
          }
          final i = episodes.indexWhere((episode) => episode.guid == guid);
          if (i == -1) {
            return;
          }

          final offset = _ScrollOffsetCalculator.calcOffset(
            metadata,
            episodes.sublist(0, i + 1),
            guid,
          );
          await scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    });

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

class _ScrollOffsetCalculator {
  _ScrollOffsetCalculator._();

  static const pageHeaderOffset = 200.0;
  static const episodeTileWithThumbnailHeight = 140.0;
  static const episodeTileNotThumbnailHeight = 124.0;

  static double calcOffset(
    PodcastMetadata metadata,
    List<Episode> episodes,
    String guid,
  ) {
    var offset = pageHeaderOffset;
    for (final episode in episodes) {
      if (episode.guid == guid) {
        break;
      }
      final showsThumbnail = episode.thumbImageUrl != metadata.thumbImageUrl;
      offset += (showsThumbnail
          ? episodeTileWithThumbnailHeight
          : episodeTileNotThumbnailHeight);
    }
    return offset;
  }
}
