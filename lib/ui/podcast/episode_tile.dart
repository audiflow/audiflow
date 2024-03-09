// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/core/types.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/ui/app/navigation_helper.dart';
import 'package:seasoning/ui/podcast/episode_date.dart';
import 'package:seasoning/ui/widgets/download_button.dart';
import 'package:seasoning/ui/widgets/queue_button.dart';
import 'package:seasoning/ui/widgets/small_play_button.dart';
import 'package:seasoning/ui/widgets/tile_image.dart';

/// An EpisodeTitle is built with an ExpandedTile widget and displays the
/// episode's basic details, thumbnail and play button.
///
/// It can then be expanded to present addition information about the episode
/// and further controls.
///

class EpisodeTile extends HookConsumerWidget {
  const EpisodeTile({
    super.key,
    required this.showsThumbnail,
    required this.metadata,
    required this.episode,
  });

  final bool showsThumbnail;
  final PodcastMetadata metadata;
  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showsThumbnail = this.showsThumbnail && episode.thumbImageUrl != null;
    return showsThumbnail
        ? _EpisodeTileWithThumbnail(metadata, episode)
        : _EpisodeTileNoThumbnail(metadata, episode);
  }
}

class _EpisodeTileWithThumbnail extends HookConsumerWidget {
  const _EpisodeTileWithThumbnail(
    this.metadata,
    this.episode,
  );

  final PodcastMetadata metadata;
  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbImageUrl = episode.thumbImageUrl ?? episode.imageUrl;
    final theme = Theme.of(context);
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor,
              width: 0.5,
            ),
          ),
        ),
        height: 140,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 90,
              right: 0,
              child: InkWell(
                onTap: () {
                  NavigationHelper.pushEpisodeDetail(
                    metadata: metadata,
                    episode: episode,
                    heroPrefix: 'episodeHero',
                  );
                },
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.only(right: 8),
                  child: _Content(metadata, episode),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: InkWell(
                onTap: () {
                  PlayButtonTappedNotification(episode).dispatch(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TileImage(
                        url: thumbImageUrl!,
                        size: 60,
                      ),
                      const SizedBox(height: 6),
                      EpisodeDate(episode, color: theme.hintColor),
                      SmallPlayButton(
                        episode: episode,
                        onPressed: () {
                          PlayButtonTappedNotification(episode)
                              .dispatch(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: -6,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    DownloadButton(episode),
                    const SizedBox(width: 6),
                    QueueButton(episode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeTileNoThumbnail extends HookConsumerWidget {
  const _EpisodeTileNoThumbnail(
    this.metadata,
    this.episode,
  );

  final PodcastMetadata metadata;
  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                NavigationHelper.pushEpisodeDetail(
                  metadata: metadata,
                  episode: episode,
                  heroPrefix: 'episodeHero',
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Content(metadata, episode),
                    const SizedBox(height: 4),
                    EpisodeDate(episode, color: theme.hintColor),
                  ],
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: SmallPlayButton(
                    episode: episode,
                    onPressed: () {
                      PlayButtonTappedNotification(episode).dispatch(context);
                    },
                  ),
                ),
                const Spacer(),
                DownloadButton(episode),
                const SizedBox(width: 6),
                QueueButton(episode),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content(this.metadata, this.episode);

  final PodcastMetadata metadata;
  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => NavigationHelper.router
              .pushNamed('episode', extra: (metadata, episode, 'episodeHero')),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              episode.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              softWrap: false,
              style: textTheme.titleSmall,
            ),
          ),
        ),
      ],
    );
  }
}
