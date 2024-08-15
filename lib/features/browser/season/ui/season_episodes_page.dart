import 'package:audiflow/common/ui/fill_remaining_error.dart';
import 'package:audiflow/common/ui/fill_remaining_loading.dart';
import 'package:audiflow/constants/types.dart';
import 'package:audiflow/events/play_button_notification.dart';
import 'package:audiflow/features/browser/episode/ui/episode_list.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_filter_mode_switch.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/browser/season/ui/podcast_season_app_bar.dart';
import 'package:audiflow/features/browser/season/ui/season_episodes_page_controller.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

class SeasonEpisodesPage extends HookConsumerWidget {
  const SeasonEpisodesPage({
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
    final pageState = ref.watch(seasonEpisodesPageControllerProvider(season));
    final pageController =
        ref.watch(seasonEpisodesPageControllerProvider(season).notifier);

    final controller = useScrollController();
    return Semantics(
      header: false,
      label: L10n.of(context).semantics_podcast_details_header,
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
            // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: RefreshIndicator(
              displacement: 60,
              onRefresh: () async {
                // await ref
                //     .read(podcastServiceProvider)
                //     .loadPodcast(podcast.metadata, refresh: true);
              },
              child: CustomScrollView(
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  PodcastSeasonAppBar(season: season, heroPrefix: heroPrefix),
                  if (pageState.isLoading)
                    const FillRemainingLoading()
                  else if (pageState.hasError)
                    FillRemainingError.podcastNoResults()
                  else ...[
                    // SliverToBoxAdapter(
                    //   child: Stack(
                    //     children: [
                    //       Align(
                    //         child: IntrinsicWidth(
                    //           child: ContextualPlayButton(
                    //             seasonEpisodesState.requireValue.episodes,
                    //             episodeGroupKey: ValueKey(season.guid),
                    //             playOrder: PlayOrder.timeAscend,
                    //             isSeries: true,
                    //           ),
                    //         ),
                    //       ),
                    //       Positioned(
                    //         right: 8,
                    //         child: SortIconButton(
                    //           ascend: ascend,
                    //           onTap: () {
                    //             ref
                    //                 .read(
                    //                   podcastViewInfoProvider(podcast.guid)
                    //                       .notifier,
                    //                 )
                    //                 .toggleAscendSeasonEpisode();
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SliverToBoxAdapter(
                      child: PodcastDetailsEpisodesFilterModeSwitch(
                        filterMode: pageState.requireValue.filterMode,
                        onFilterModeChanged: pageController.setFilterMode,
                        onToggleAscending: pageController.toggleAscending,
                      ),
                    ),
                    NotificationListener<PlayButtonTappedNotification>(
                      onNotification: (notification) {
                        pageController
                            .togglePlayState(notification.episode);
                        return false;
                      },
                      child: EpisodeList.fixed(
                        episodes: pageState.requireValue.episodes,
                        scrollController: controller,
                        thumbnailVisibility: ThumbnailVisibility.hidden,
                      ),
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
