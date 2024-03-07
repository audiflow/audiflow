// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/core/l10n.dart';
import 'package:seasoning/core/types.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/episodes_group_provider.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';
import 'package:seasoning/ui/pages/app_bars/podcast_season_app_bar.dart';
import 'package:seasoning/ui/podcast/episode_list.dart';
import 'package:seasoning/ui/podcast/types.dart';
import 'package:seasoning/ui/widgets/rounded_stadium_button.dart';

class PodcastSeasonPage extends HookConsumerWidget {
  const PodcastSeasonPage({
    required this.podcast,
    required this.season,
    required this.heroPrefix,
    super.key,
  });

  final Podcast podcast;
  final Season season;
  final String heroPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldMessengerKey =
        useState(GlobalKey<ScaffoldMessengerState>()).value;
    return Semantics(
      header: false,
      label: L10n.of(context)!.semantics_podcast_details_header,
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: RefreshIndicator(
            displacement: 60,
            onRefresh: () async {
              await ref
                  .read(podcastServiceProvider)
                  .loadPodcast(podcast.metadata, refresh: true);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                PodcastSeasonAppBar(season: season, heroPrefix: heroPrefix),
                SliverToBoxAdapter(
                  child: ContextualPlayButton(
                    season.episodes,
                    episodeGroupKey: ValueKey(season.guid),
                    playOrder: PlayOrder.timeAscend,
                    isSeries: true,
                  ),
                ),
                EpisodeList(
                  episodeGroupKey: ValueKey(season.guid),
                  thumbnailVisibility: ThumbnailVisibility.hidden,
                  metadata: podcast.metadata,
                  episodes: season.episodes,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContextualPlayButton extends ConsumerWidget {
  const ContextualPlayButton(
    this.episodes, {
    required this.episodeGroupKey,
    required this.playOrder,
    required this.isSeries,
    super.key,
  });

  final Key episodeGroupKey;
  final List<Episode> episodes;
  final PlayOrder playOrder;
  final bool isSeries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesState = ref.watch(episodesGroupProvider(episodeGroupKey));
    final buttonState = episodesState.valueOrNull
        ?.nextEpisodeToPlay(playOrder: playOrder, isSeries: isSeries);
    return RoundedStadiumButton.md(
      caption: AnimatedOpacity(
        opacity: episodesState.hasValue ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(buttonState?.$2.label(context) ?? ''),
      ),
      onPressed: buttonState?.$1 == null
          ? null
          : () {
              final episode = buttonState!.$1!;
              ref
                  .read(episodesGroupProvider(episodeGroupKey).notifier)
                  .togglePlayState(episode: episode);
            },
    );
  }
}

extension ConditionalPlayButtonStateExt on ConditionalPlayButtonState {
  String label(BuildContext context) {
    switch (this) {
      case ConditionalPlayButtonState.fromStart:
        return 'Play from start';
      case ConditionalPlayButtonState.latest:
        return 'Play latest';
      case ConditionalPlayButtonState.latestAgain:
        return 'Play again';
      case ConditionalPlayButtonState.resume:
        return 'Resume';
    }
  }
}
