// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/ui/podcast/podcast_details.dart';
import 'package:seasoning/ui/widgets/tile_image.dart';

class PodcastGridTile extends StatelessWidget {
  const PodcastGridTile({
    super.key,
    required this.podcast,
  });

  final Podcast podcast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'podcastdetails'),
            builder: (context) => PodcastDetails(podcast),
          ),
        );
      },
      child: Semantics(
        label: podcast.title,
        child: GridTile(
          child: Hero(
            key: Key('tilehero${podcast.imageUrl}:${podcast.link}'),
            tag: '${podcast.imageUrl}:${podcast.link}',
            child: TileImage(
              url: podcast.imageUrl!,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class PodcastTitledGridTile extends StatelessWidget {
  const PodcastTitledGridTile({
    super.key,
    required this.podcast,
  });

  final Podcast podcast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: 'podcastdetails'),
            builder: (context) => PodcastDetails(podcast),
          ),
        );
      },
      child: GridTile(
        child: Hero(
          key: Key('tilehero${podcast.imageUrl}:${podcast.link}'),
          tag: '${podcast.imageUrl}:${podcast.link}',
          child: Column(
            children: [
              TileImage(
                url: podcast.imageUrl!,
                size: 128,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 4,
                ),
                child: Text(
                  podcast.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
