// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/app/navigation_helper.dart';
import 'package:audiflow/ui/providers/episode_info_provider.dart';
import 'package:audiflow/ui/widgets/tile_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// An EpisodeTitle is built with an ExpandedTile widget and displays the
/// episode's basic details, thumbnail and play button.
///
/// It can then be expanded to present addition information about the episode
/// and further controls.
///

class PlayerEpisodeTile extends ConsumerWidget {
  const PlayerEpisodeTile({
    super.key,
    required this.episode,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbImageUrl = episode.thumbImageUrl ?? '';
    final state = ref.watch(episodeInfoProvider(episode));
    return Material(
      child: InkWell(
        onTap: () {
          if (state.valueOrNull?.podcastMetadata != null) {
            NavigationHelper.pushEpisodeDetail(
              episode: episode,
              heroPrefix: 'episodeHero',
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TileImage(url: thumbImageUrl, size: 50),
              const SizedBox(width: 12),
              Expanded(child: _Content(episode)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content(this.episode);

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final episodeInfo = ref.watch(episodeInfoProvider(episode));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          episode.title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Text(
          episodeInfo.valueOrNull?.podcastMetadata.title ?? '',
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: theme.disabledColor),
        ),
      ],
    );
  }
}
