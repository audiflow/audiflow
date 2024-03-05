// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/providers/podcast/podcast_info_provider.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';
import 'package:seasoning/ui/pages/app_bars/podcast_page_header_image.dart';
import 'package:seasoning/ui/widgets/placeholder_builder.dart';

class PodcastDetailsAppBar extends ConsumerWidget {
  const PodcastDetailsAppBar({
    super.key,
    required this.metadata,
    required this.heroPrefix,
  });

  final PodcastMetadata metadata;
  final String heroPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholderBuilder = PlaceholderBuilder.of(context);
    final podcastState = ref.watch(podcastInfoProvider(metadata));
    final subscribed = podcastState.value?.stats?.subscribed;

    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        return SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          title: AnimatedOpacity(
            opacity: 300 < constraints.scrollOffset ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(metadata.title),
          ),
          actions: [
            Opacity(
              opacity: podcastState.hasValue ? 1.0 : 0.0,
              child: subscribed == true
                  ? IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        ref
                            .read(podcastServiceProvider)
                            .unsubscribe(podcastState.value!.podcast);
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.bookmark_add),
                      onPressed: () {
                        ref
                            .read(podcastServiceProvider)
                            .subscribe(podcastState.value!.podcast);
                      },
                    ),
            ),
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
                      'detailHero:${metadata.imageUrl}:${metadata.guid}',
                    ),
                    tag: '$heroPrefix:${metadata.guid}',
                    child: ExcludeSemantics(
                      child: PodcastHeaderImage(
                        imageUrl: metadata.imageUrl,
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
