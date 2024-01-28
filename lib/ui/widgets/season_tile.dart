// Copyright 2020 Ben Hills and the project contributors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:coten_player/entities/season.dart';
import 'package:coten_player/ui/widgets/tile_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

/// An SeasonTitle is built with an [ExpandedTile] widget and displays the season's
/// basic details, thumbnail and play button.
///
/// It can then be expanded to present addition information about the season and further
/// controls.
///
/// TODO: Replace [Opacity] with [Container] with a transparent colour.
class SeasonTile extends StatefulWidget {
  final Season season;
  final bool download;
  final bool play;
  final bool playing;
  final bool queued;

  const SeasonTile({
    super.key,
    required this.season,
    required this.download,
    required this.play,
    this.playing = false,
    this.queued = false,
  });

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
      leading: ExcludeSemantics(
        child: Stack(
          alignment: Alignment.bottomLeft,
          fit: StackFit.passthrough,
          children: <Widget>[
            Opacity(
              opacity: widget.season.played ? 0.5 : 1.0,
              child: TileImage(
                url: widget.season.thumbImageUrl ?? widget.season.imageUrl!,
                size: 56.0,
              ),
            ),
            SizedBox(
              height: 5.0,
              width: 56.0 * (widget.season.percentagePlayed / 100),
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
      subtitle: Opacity(
        opacity: widget.season.played ? 0.5 : 1.0,
        child: SeasonSubtitle(widget.season),
      ),
      title: Opacity(
        opacity: widget.season.played ? 0.5 : 1.0,
        child: Text(
          0 < widget.season.seasonNum
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
  final Season season;
  final String date;
  final Duration length;

  SeasonSubtitle(this.season, {super.key})
      : date = season.publicationDate == null
            ? ''
            : DateFormat(season.publicationDate!.year == DateTime.now().year
                    ? 'd MMM'
                    : 'd MMM yy')
                .format(season.publicationDate!),
        length = Duration(seconds: season.duration);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var timeRemaining = season.timeRemaining;

    String title;

    if (length.inSeconds > 0) {
      if (length.inSeconds < 60) {
        title = '$date - ${length.inSeconds} sec';
      } else {
        title = '$date - ${length.inMinutes} min';
      }
    } else {
      title = date;
    }

    if (timeRemaining.inSeconds > 0) {
      if (timeRemaining.inSeconds < 60) {
        title = '$title / ${timeRemaining.inSeconds} sec left';
      } else {
        title = '$title / ${timeRemaining.inMinutes} min left';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: textTheme.bodySmall,
      ),
    );
  }
}
