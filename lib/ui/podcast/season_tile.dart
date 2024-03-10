// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/app/navigation_helper.dart';
import 'package:audiflow/ui/util/datetime.dart';
import 'package:audiflow/ui/widgets/tile_image.dart';
import 'package:flutter/material.dart';

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
                  const Spacer(),
                  _SeasonTitle(season),
                  const Spacer(flex: 2),
                  _SeasonSubtitle(season),
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

class _SeasonTitle extends StatelessWidget {
  const _SeasonTitle(this.season);

  final Season season;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context)!;
    return Text(
      season.title != null
          ? season.seasonNum != null
              ? '#${season.seasonNum} ${season.title}'
              : season.title!
          : season.seasonNum != null
              ? '${l10n.season} ${season.seasonNum}'
              : l10n.null_season,
      maxLines: 2,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
      ),
      style: theme.textTheme.titleSmall!.copyWith(height: 1.2),
    );
  }
}

class _SeasonSubtitle extends StatelessWidget {
  const _SeasonSubtitle(this.season);

  final Season season;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final l10n = L10n.of(context)!;
    final playedEpisodes = season.episodes.where((episode) => false).length;
    final firstDate =
        _dateString(context, season.episodes.first.publicationDate);
    final lastDate = _dateString(context, season.episodes.last.publicationDate);
    final duration = _durationString(context, season.totalDuration);
    final episodes =
        '$playedEpisodes/${l10n.nEpisodes(season.episodes.length)}';

    final firstLine = firstDate == null && lastDate == null
        ? null
        : firstDate == lastDate
            ? firstDate
            : (firstDate == null || lastDate == null)
                ? (firstDate ?? lastDate)
                : '$firstDate 〜 $lastDate';
    final secondLine = duration.isNotEmpty ? '$episodes $duration' : episodes;
    final title = firstLine != null ? '$firstLine\n$secondLine' : secondLine;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall!
            .copyWith(fontSize: 11, color: theme.hintColor, height: 1.1),
      ),
    );
  }

  String? _dateString(BuildContext context, DateTime? date) {
    if (date == null) {
      return null;
    }
    final elapsed = DateTime.now().difference(date);
    return 7 <= elapsed.inDays
        ? DateTimeString.formatDate(date)
        : DateTimeString.relativeDateTime(context, elapsed);
  }

  String _durationString(BuildContext context, Duration duration) {
    final length = season.totalDuration;
    if (length.inSeconds < 1) {
      return '';
    }

    final l10n = L10n.of(context)!;
    if (length.inSeconds < 60) {
      return '${length.inSeconds}${l10n.sec}';
    } else if (length.inMinutes < 120) {
      return '${length.inMinutes}${l10n.min}';
    } else {
      return '${length.inHours}${l10n.hour}'
          '${length.inMinutes.remainder(60)}${l10n.min}';
    }
  }
}
