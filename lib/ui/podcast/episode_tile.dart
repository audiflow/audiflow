// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:seasoning/core/types.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/ui/app/navigation_helper.dart';
import 'package:seasoning/ui/podcast/episode_date.dart';
import 'package:seasoning/ui/widgets/animated_play_button.dart';
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
    final thumbImageUrl = episode.thumbImageUrl ?? episode.imageUrl;
    final theme = Theme.of(context);
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        height: 140,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: showsThumbnail ? 90 : 20,
              right: 0,
              child: InkWell(
                onTap: () {
                  NavigationHelper.router.pushNamed(
                    'episode',
                    extra: (metadata, episode, 'episodeHero'),
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
                      showsThumbnail
                          ? TileImage(
                              url: thumbImageUrl!,
                              size: 60,
                            )
                          : const SizedBox(height: 60),
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
            // Column(
            //   children: [
            //     InkWell(
            //       onTap: () {
            //         PlayButtonTappedNotification(episode).dispatch(context);
            //       },
            //       child: Padding(
            //         padding: EdgeInsets.only(
            //             left: showsThumbnail ? 8 : 20, right: 4),
            //         child: _Content(metadata, episode),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.only(left: 20, right: 8),
            //       child: _Controls(episode),
            //     ),
            //   ],
            // ),
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

class _Controls extends StatelessWidget {
  const _Controls(this.episode);

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedPlayButton(episode),
        DownloadButton(episode),
        const SizedBox(width: 12),
        QueueButton(episode),
      ],
    );
  }
}

class EpisodeTransportControls extends StatelessWidget {
  const EpisodeTransportControls({
    super.key,
    required this.episode,
    required this.download,
    required this.play,
  });

  final Episode episode;
  final bool download;
  final bool play;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    if (download) {
      buttons.add(
        Semantics(
          container: true,
          // child: DownloadControl(
          //   episode: episode,
          // ),
        ),
      );
    }

    if (play) {
      buttons.add(
        Semantics(
          container: true,
          // child: PlayControl(
          //   episode: episode,
          // ),
        ),
      );
    }

    return SizedBox(
      width: buttons.length * 48.0,
      child: Row(
        children: <Widget>[...buttons],
      ),
    );
  }
}

class EpisodeSubtitle extends StatelessWidget {
  EpisodeSubtitle(this.episode, this.stats, {super.key})
      : date = episode.publicationDate == null
            ? ''
            : DateFormat('yyyy.MM.dd').format(episode.publicationDate!);
  final Episode episode;
  final EpisodeStats? stats;
  final String date;

  @override
  Widget build(BuildContext context) {
    var title = episode.duration == null
        ? date
        : episode.duration!.inSeconds < 60
            ? '$date - ${episode.duration!.inSeconds} sec'
            : '$date - ${episode.duration!.inMinutes} min';

    final timeRemaining = stats?.timeRemaining ?? Duration.zero;
    if (Duration.zero < timeRemaining) {
      title = timeRemaining.inSeconds < 60
          ? '$title / ${timeRemaining.inSeconds} sec left'
          : '$title / ${timeRemaining.inMinutes} min left';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
