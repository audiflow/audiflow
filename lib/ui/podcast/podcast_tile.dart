// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/ui/app/navigation_helper.dart';
import 'package:seasoning/ui/widgets/tile_image.dart';

class PodcastTile extends StatelessWidget {
  const PodcastTile({
    super.key,
    required this.metadata,
  });

  final PodcastMetadata metadata;
  static const heroPrefix = 'tileHero';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        NavigationHelper.pushPodcastDetail(
          metadata: metadata,
          heroPrefix: heroPrefix,
        );
      },
      child: Container(
        height: 77,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: Hero(
                  key: Key('tileHero:${metadata.imageUrl}:${metadata.guid}'),
                  tag: '$heroPrefix:${metadata.guid}',
                  child: TileImage(
                    url: metadata.thumbImageUrl,
                    size: 60,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metadata.title,
                    maxLines: 2,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                    ),
                    style: theme.textTheme.titleSmall!.copyWith(height: 1.3),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metadata.copyright,
                    maxLines: 1,
                    style: theme.textTheme.bodySmall!
                        .copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
