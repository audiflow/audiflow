import 'package:flutter/material.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/ui/util/datetime.dart';

class EpisodeDate extends StatelessWidget {
  const EpisodeDate(this.episode, {super.key, this.color});

  final Episode episode;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      dateString(context),
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
    );
  }

  String dateString(BuildContext context) {
    if (episode.publicationDate == null) {
      return '';
    }

    final elapsed = DateTime.now().difference(episode.publicationDate!);
    return 7 <= elapsed.inDays
        ? DateTimeString.formatDate(episode.publicationDate!)
        : DateTimeString.relativeDateTime(context, elapsed);
  }
}
