// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/podcast_info_provider.dart';
import 'package:seasoning/ui/app/navigation_helper.dart';
import 'package:seasoning/ui/widgets/tile_image.dart';

class PodcastListHorz extends ConsumerWidget {
  const PodcastListHorz({
    super.key,
    required this.metadataList,
  });

  final List<PodcastMetadata> metadataList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (metadataList.isEmpty) {
      return const SizedBox.shrink();
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 240,
        width: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          itemBuilder: (context, index) {
            return _ListTile(
              key: ValueKey(metadataList[index].guid),
              metadata: metadataList[index],
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(width: 20);
          },
          itemCount: metadataList.length,
        ),
      ),
    );
  }
}

class _ListTile extends ConsumerWidget {
  const _ListTile({
    super.key,
    required this.metadata,
  });

  final PodcastMetadata metadata;
  static const heroPrefix = 'subscription:';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastState = ref.watch(podcastInfoProvider(metadata));
    if (!podcastState.hasValue) {
      return const SizedBox.shrink();
    }

    final podcast = podcastState.value!.podcast;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        NavigationHelper.pushPodcastDetail(
          metadata: metadata,
          heroPrefix: heroPrefix,
        );
      },
      child: GridTile(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          width: 200,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Hero(
                key: Key('tilehero${podcast.imageUrl}:${podcast.guid}'),
                tag: '$heroPrefix:${podcast.guid}',
                child: TileImage(
                  url: podcast.imageUrl,
                  size: 150,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                podcast.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: theme.textTheme.titleSmall!
                    .copyWith(color: theme.colorScheme.onSecondaryContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
