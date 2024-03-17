// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/types.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/podcast/episode_date.dart';
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

class EpisodeBriefTile extends HookConsumerWidget {
  const EpisodeBriefTile({
    super.key,
    required this.episode,
    this.sortableIndex,
    this.backgroundColor,
  });

  final Episode episode;
  final int? sortableIndex;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeInfo = ref.watch(episodeInfoProvider(episode));
    final thumbImageUrl = episodeInfo.hasValue
        ? episodeInfo.value!.podcastMetadata.thumbImageUrl
        : '';

    return Material(
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          color: backgroundColor,
          height: 70,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              PlayButtonTappedNotification(episode, index: sortableIndex)
                  .dispatch(context);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TileImage(url: thumbImageUrl, size: 50),
                const SizedBox(width: 12),
                Expanded(child: _Content(episode)),
                if (sortableIndex != null)
                  ReorderableDragStartListener(
                    index: sortableIndex!,
                    child: const Icon(
                      Icons.drag_handle,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content(this.episode);

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        EpisodeDate(episode, color: theme.disabledColor),
      ],
    );
  }
}
