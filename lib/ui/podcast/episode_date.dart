import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seasoning/entities/entities.dart';

class EpisodeDate extends StatelessWidget {
  const EpisodeDate(this.episode, {super.key, this.color});

  final Episode episode;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      dateString,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
    );
  }

  String get dateString {
    if (episode.publicationDate == null) {
      return '';
    }

    final elapsed = DateTime.now().difference(episode.publicationDate!);

    if (7 <= elapsed.inDays) {
      return DateFormat('yyyy.MM.dd').format(episode.publicationDate!);
    }

    if (1 <= elapsed.inDays) {
      return '${elapsed.inDays} DAY${1 < elapsed.inDays ? 'S' : ''} AGO';
    } else if (1 <= elapsed.inHours) {
      return '${elapsed.inHours} HOUR${1 < elapsed.inHours ? 'S' : ''} AGO';
    } else {
      return '${elapsed.inMinutes} MINUTE${1 < elapsed.inMinutes ? 'S' : ''}'
          ' AGO';
    }
  }
}
