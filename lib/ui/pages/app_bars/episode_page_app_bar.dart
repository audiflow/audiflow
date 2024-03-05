// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/episode_info_provider.dart';
import 'package:seasoning/ui/pages/app_bars/podcast_page_header_image.dart';
import 'package:seasoning/ui/widgets/placeholder_builder.dart';

class EpisodePageAppBar extends ConsumerWidget {
  const EpisodePageAppBar({
    super.key,
    required this.metadata,
    required this.episode,
    required this.heroPrefix,
    this.backgroundColor = Colors.transparent,
  });

  final PodcastMetadata metadata;
  final Episode episode;
  final String heroPrefix;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholderBuilder = PlaceholderBuilder.of(context);
    final episodeState = ref.watch(episodeInfoProvider(episode));

    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        return SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          backgroundColor: backgroundColor,
          title: AnimatedOpacity(
            opacity: 300 < constraints.scrollOffset ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(episode.title),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 46),
                Expanded(
                  child: Hero(
                    key: Key(
                      'episodeHero:${metadata.imageUrl}:${metadata.guid}',
                    ),
                    tag: '$heroPrefix:${metadata.guid}',
                    child: ExcludeSemantics(
                      child: PodcastHeaderImage(
                        imageUrl: episode.imageUrl ??
                            episode.thumbImageUrl ??
                            metadata.imageUrl ??
                            '',
                        placeholderBuilder: placeholderBuilder,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
