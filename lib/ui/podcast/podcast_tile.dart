// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/navigation/navigation_helper.dart';
import 'package:seasoning/ui/widgets/tile_image.dart';

class PodcastTile extends StatelessWidget {
  const PodcastTile({
    super.key,
    required this.podcast,
  });

  final PodcastSummary podcast;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        NavigationHelper.router.push('/search/detail', extra: podcast.guid);
      },
      minVerticalPadding: 9,
      leading: ExcludeSemantics(
        child: Hero(
          key: Key('tileHero:${podcast.guid}'),
          tag: 'tileHero:${podcast.guid}',
          child: TileImage(
            url: podcast.thumbImageUrl,
            size: 60,
          ),
        ),
      ),
      title: Text(
        podcast.title,
        maxLines: 1,
      ),

      /// A ListTile's density changes depending upon whether we have 2 or more
      /// lines of text. We manually add a newline character here to ensure the
      /// density is consistent whether the podcast subtitle spans 1 or more
      /// lines. Bit of a hack, but a simple solution.
      subtitle: Text(
        '${podcast.copyright}\n',
        maxLines: 2,
      ),
    );
  }
}
