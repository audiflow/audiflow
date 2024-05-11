import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:audiflow/core/types.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:audiflow/ui/pages/app_bars/podcast_season_app_bar.dart';
import 'package:audiflow/ui/podcast/contextual_play_button.dart';
import 'package:audiflow/ui/podcast/episode_list.dart';
import 'package:audiflow/ui/podcast/types.dart';
import 'package:audiflow/ui/providers/podcast_view_info_provider.dart';
import 'package:audiflow/ui/widgets/fill_remaining_error.dart';
import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
import 'package:audiflow/ui/widgets/sort_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

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
    final podcastViewState = ref.watch(podcastViewInfoProvider(podcast.guid));
    final ascend = podcastViewState.valueOrNull?.ascendSeasonEpisodes ?? true;

    final controller = useScrollController();
    return Semantics(
      header: false,
      label: L10n.of(context)!.semantics_podcast_details_header,
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: ScrollsToTop(
          onScrollsToTop: (event) async {
            await controller.animateTo(
              event.to,
              duration: event.duration,
              curve: event.curve,
            );
          },
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
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  PodcastSeasonAppBar(season: season, heroPrefix: heroPrefix),
                  if (podcastViewState.isLoading)
                    const FillRemainingLoading()
                  else if (podcastViewState.hasError)
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
                                ref
                                    .read(
                                      podcastViewInfoProvider(podcast.guid)
                                          .notifier,
                                    )
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
                      scrollController: controller,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
