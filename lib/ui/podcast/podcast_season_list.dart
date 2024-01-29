// Copyright 2020 Ben Hills and the project contributors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:seasoning/bloc/podcast/queue_bloc.dart';
import 'package:seasoning/entities/season.dart';
import 'package:seasoning/state/queue_event_state.dart';
import 'package:seasoning/ui/widgets/season_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PodcastSeasonList extends StatelessWidget {
  final List<Season?>? seasons;
  final IconData icon;
  final String emptyMessage;
  final bool play;
  final bool download;

  static const _defaultIcon = Icons.add_alert;

  const PodcastSeasonList({
    super.key,
    required this.seasons,
    required this.play,
    required this.download,
    this.icon = _defaultIcon,
    this.emptyMessage = '',
  });

  @override
  Widget build(BuildContext context) {
    if (seasons != null && seasons!.isNotEmpty) {
      var queueBloc = Provider.of<QueueBloc>(context);

      return StreamBuilder<QueueState>(
          stream: queueBloc.queue,
          builder: (context, snapshot) {
            return SliverSafeArea(
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  var queued = false;
                  var playing = false;
                  var season = seasons![index]!;

                  if (snapshot.hasData) {
                    var playingGuid = snapshot.data!.playing?.guid;

                    queued = snapshot.data!.queue
                        .any((element) => element.guid == season.guid);

                    playing = playingGuid == season.guid;
                  }

                  return SeasonTile(
                    season: season,
                    download: download,
                    play: play,
                    playing: playing,
                    queued: queued,
                  );
                },
                childCount: seasons!.length,
                addAutomaticKeepAlives: false,
              )),
            );
          });
    } else {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
