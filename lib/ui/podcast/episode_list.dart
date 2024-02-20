// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/ui/podcast/episode_tile.dart';

class EpisodeList extends StatelessWidget {
  const EpisodeList({
    super.key,
    required this.summary,
    required this.episodes,
    required this.play,
    required this.download,
    this.icon = _defaultIcon,
    this.emptyMessage = '',
  });

  final PodcastSummary summary;
  final List<Episode> episodes;
  final IconData icon;
  final String emptyMessage;
  final bool play;
  final bool download;

  static const _defaultIcon = Icons.add_alert;

  @override
  Widget build(BuildContext context) {
    if (episodes.isEmpty) {
      return _EmptyEpisodeList(
        icon: icon,
        message: emptyMessage,
      );
    }

    return SliverSafeArea(
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final episode = episodes[index];
            return EpisodeTile(
              summary: summary,
              episode: episode,
              download: download,
              play: play,
            );
          },
          childCount: episodes.length,
          addAutomaticKeepAlives: false,
        ),
      ),
    );
  }
}

class _EmptyEpisodeList extends StatelessWidget {
  const _EmptyEpisodeList({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 75,
              color: Theme.of(context).primaryColor,
            ),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
