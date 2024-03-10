// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/podcast/episode_brief_tile.dart';
import 'package:audiflow/ui/widgets/fill_remaining_error.dart';
import 'package:flutter/material.dart';

class EpisodeBriefList extends StatelessWidget {
  const EpisodeBriefList({
    super.key,
    required this.episodes,
  });

  final List<Episode> episodes;

  @override
  Widget build(BuildContext context) {
    if (episodes.isEmpty) {
      return FillRemainingError.podcastNoResults();
    }

    return SliverSafeArea(
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return EpisodeBriefTile(episode: episodes[index]);
          },
          childCount: episodes.length,
          addAutomaticKeepAlives: false,
        ),
      ),
    );
  }
}
