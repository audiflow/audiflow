// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/pages/app_bars/podcast_page_header_image.dart';
import 'package:audiflow/ui/widgets/placeholder_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        return SliverAppBar(
          expandedHeight: 350,
          pinned: true,
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
            background: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 46),
                Expanded(
                  child: Hero(
                    key: Key(
                      'episodeHero:${metadata.artworkUrl}:${metadata.guid}',
                    ),
                    tag: '$heroPrefix:${metadata.guid}',
                    child: ExcludeSemantics(
                      child: PodcastHeaderImage(
                        imageUrl: episode.imageUrl ??
                            episode.thumbnailUrl ??
                            metadata.artworkUrl,
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
