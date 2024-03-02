// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/core/types.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/episode_info_provider.dart';
import 'package:seasoning/ui/podcast/episode_date.dart';
import 'package:seasoning/ui/widgets/tile_image.dart';

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
        ? episodeInfo.value!.podcastPreview.thumbImageUrl
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
