// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/util/datetime.dart';
import 'package:flutter/material.dart';

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
