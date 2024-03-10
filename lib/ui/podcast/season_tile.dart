// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/ui/app/navigation_helper.dart';
import 'package:seasoning/ui/widgets/tile_image.dart';

class SeasonTile extends StatelessWidget {
  const SeasonTile({
    super.key,
    required this.podcast,
    required this.season,
  });

  final Podcast podcast;
  final Season season;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      key: Key('PT${season.guid}'),
      onTap: () {
        NavigationHelper.router
            .pushNamed('season', extra: (podcast, season, 'season'));
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
                  key: Key('seasonhero${season.guid}'),
                  tag: season.guid,
                  child: TileImage(
                    url: season.thumbImageUrl ?? season.imageUrl!,
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
                    season.title != null
                        ? season.seasonNum != null
                            ? '#${season.seasonNum} ${season.title}'
                            : season.title!
                        : 'Season ${season.seasonNum}',
                    maxLines: 2,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                    ),
                    style: theme.textTheme.titleSmall!.copyWith(height: 1.3),
                  ),
                  const SizedBox(height: 2),
                  SeasonSubtitle(season),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class SeasonSubtitle extends StatelessWidget {
  SeasonSubtitle(this.season, {super.key})
      : date = season.publicationDate == null
            ? ''
            : DateFormat('yyyy.MM.dd').format(season.publicationDate!),
        length = season.totalDuration;
  final Season season;
  final String date;
  final Duration length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final playedEpisodes = season.episodes.where((episode) => false).length;
    final episodes = '$playedEpisodes/${season.episodes.length} episodes';

    var duration = '';
    if (0 < length.inSeconds) {
      if (length.inSeconds < 60) {
        duration = ' - ${length.inSeconds} sec';
      } else if (length.inMinutes < 120) {
        duration = ' - ${length.inMinutes} min';
      } else {
        duration =
            ' - ${length.inHours} hr ${length.inMinutes.remainder(60)} min';
      }
    }

    final title = '$date - $episodes$duration';

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall!.copyWith(color: theme.hintColor),
      ),
    );
  }
}
