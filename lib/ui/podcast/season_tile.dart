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
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      key: Key('PT${season.guid}'),
      onTap: () {
        NavigationHelper.router
            .pushNamed('season', extra: (podcast, season, 'season'));
      },
      leading: ExcludeSemantics(
        child: Stack(
          alignment: Alignment.bottomLeft,
          fit: StackFit.passthrough,
          children: <Widget>[
            Opacity(
              opacity: 1, // season.played ? 0.5 : 1.0,
              child: Hero(
                key: Key('seasonhero${season.guid}'),
                tag: season.guid,
                child: TileImage(
                  url: season.thumbImageUrl ?? season.imageUrl!,
                  size: 56,
                ),
              ),
            ),
            SizedBox(
              height: 5,
              width: 56.0 * 0, // (season.percentagePlayed / 100),
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
      subtitle: Opacity(
        opacity: 1, // season.played ? 0.5 : 1.0,
        child: SeasonSubtitle(season),
      ),
      title: Opacity(
        opacity: 1, // season.played ? 0.5 : 1.0,
        child: Text(
          season.seasonNum != null
              ? '#${season.seasonNum} ${season.title}'
              : 'Extra',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          softWrap: false,
          style: textTheme.bodyMedium,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
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
    final textTheme = Theme.of(context).textTheme;
    final timeRemaining = season.totalDuration; //season.timeRemaining;

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
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: textTheme.bodySmall,
      ),
    );
  }
}
