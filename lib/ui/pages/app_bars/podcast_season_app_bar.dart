// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/ui/pages/app_bars/podcast_page_header_image.dart';
import 'package:seasoning/ui/widgets/placeholder_builder.dart';

class PodcastSeasonAppBar extends ConsumerWidget {
  const PodcastSeasonAppBar({
    super.key,
    required this.season,
    required this.heroPrefix,
  });

  final Season season;
  final String heroPrefix;

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
            child: Text(season.title ?? season.episodes.first.title),
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
                      'seasonHero:${season.imageUrl}:${season.guid}',
                    ),
                    tag: '$heroPrefix:${season.guid}',
                    child: ExcludeSemantics(
                      child: PodcastHeaderImage(
                        imageUrl: season.imageUrl!,
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
