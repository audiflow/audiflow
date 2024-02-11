// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seasoning/bloc/podcast/queue_bloc.dart';
import 'package:seasoning/entities/episode.dart';
import 'package:seasoning/ui/widgets/episode_tile.dart';

class PodcastEpisodeList extends StatelessWidget {

  const PodcastEpisodeList({
    super.key,
    required this.episodes,
    required this.play,
    required this.download,
    this.icon = _defaultIcon,
    this.emptyMessage = '',
  });
  final List<Episode?>? episodes;
  final IconData icon;
  final String emptyMessage;
  final bool play;
  final bool download;

  static const _defaultIcon = Icons.add_alert;

  @override
  Widget build(BuildContext context) {
    if (episodes != null && episodes!.isNotEmpty) {
      final queueBloc = Provider.of<QueueBloc>(context);

      return StreamBuilder<QueueState>(
          stream: queueBloc.queue,
          builder: (context, snapshot) {
            return SliverSafeArea(
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  var queued = false;
                  var playing = false;
                  final episode = episodes![index]!;

                  if (snapshot.hasData) {
                    final playingGuid = snapshot.data!.playing?.guid;

                    queued = snapshot.data!.queue
                        .any((element) => element.guid == episode.guid);

                    playing = playingGuid == episode.guid;
                  }

                  return EpisodeTile(
                    episode: episode,
                    download: download,
                    play: play,
                    playing: playing,
                    queued: queued,
                  );
                },
                childCount: episodes!.length,
                addAutomaticKeepAlives: false,
              ),),
            );
          },);
    } else {
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
                emptyMessage,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
