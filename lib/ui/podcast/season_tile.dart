// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:seasoning/entities/season.dart';
// import 'package:seasoning/ui/podcast/season_episodes.dart';
import 'package:seasoning/ui/widgets/tile_image.dart';

class SeasonTile extends StatefulWidget {
  const SeasonTile({
    super.key,
    required this.season,
  });

  final Season season;

  @override
  State<SeasonTile> createState() => _SeasonTileState();
}

class _SeasonTileState extends State<SeasonTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      key: Key('PT${widget.season.guid}'),
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute<void>(
        //     settings: const RouteSettings(name: 'podcastdetails'),
        //     builder: (context) => SeasonEpisodes(widget.season),
        //   ),
        // );
      },
      leading: ExcludeSemantics(
        child: Stack(
          alignment: Alignment.bottomLeft,
          fit: StackFit.passthrough,
          children: <Widget>[
            Opacity(
              opacity: 1, // widget.season.played ? 0.5 : 1.0,
              child: Hero(
                key: Key('seasonhero${widget.season.guid}'),
                tag: widget.season.guid,
                child: TileImage(
                  url: widget.season.thumbImageUrl ?? widget.season.imageUrl!,
                  size: 56,
                ),
              ),
            ),
            SizedBox(
              height: 5,
              width: 56.0 * 0, // (widget.season.percentagePlayed / 100),
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
      subtitle: Opacity(
        opacity: 1, // widget.season.played ? 0.5 : 1.0,
        child: SeasonSubtitle(widget.season),
      ),
      title: Opacity(
        opacity: 1, // widget.season.played ? 0.5 : 1.0,
        child: Text(
          widget.season.seasonNum != null
              ? '#${widget.season.seasonNum} ${widget.season.title}'
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
            : DateFormat(
                season.publicationDate!.year == DateTime.now().year
                    ? 'yyyy.MM'
                    : 'yyyy.MM.dd',
              ).format(season.publicationDate!),
        length = season.totalDuration;
  final Season season;
  final String date;
  final Duration length;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final timeRemaining = season.totalDuration; //season.timeRemaining;

    final playedEpisodes =
        season.episodes.where((episode) => false).length;
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
