// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/core/types.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/providers/podcast/podcast_info_provider.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:audiflow/ui/pages/app_bars/podcast_season_app_bar.dart';
import 'package:audiflow/ui/podcast/contextual_play_button.dart';
import 'package:audiflow/ui/podcast/episode_list.dart';
import 'package:audiflow/ui/podcast/types.dart';
import 'package:audiflow/ui/widgets/fill_remaining_error.dart';
import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
import 'package:audiflow/ui/widgets/sort_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final podcastDetailsState =
        ref.watch(podcastInfoProvider(podcast.metadata));
    final ascend =
        podcastDetailsState.valueOrNull?.stats?.ascendSeasonEpisodes ?? true;

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
                if (podcastDetailsState.isLoading)
                  const FillRemainingLoading()
                else if (podcastDetailsState.hasError)
                  FillRemainingError.podcastNoResults()
                else ...[
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        Align(
                          child: IntrinsicWidth(
                            child: ContextualPlayButton(
                              season.episodes,
                              episodeGroupKey: ValueKey(season.guid),
                              playOrder: PlayOrder.timeAscend,
                              isSeries: true,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          child: SortIconButton(
                            ascend: ascend,
                            onTap: () {
                              final metadata = podcast.metadata;
                              ref
                                  .read(podcastInfoProvider(metadata).notifier)
                                  .toggleAscendSeasonEpisode();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  EpisodeList(
                    episodeGroupKey: ValueKey(season.guid),
                    thumbnailVisibility: ThumbnailVisibility.hidden,
                    metadata: podcast.metadata,
                    episodes: ascend
                        ? season.episodes
                        : season.episodes.reversed.toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
