import 'package:audiflow/features/browser/common/ui/expandable_text_block.dart';
import 'package:audiflow/features/browser/episode/ui/episode_list.dart';
import 'package:audiflow/features/browser/episode/ui/episodes_list_event.dart';
import 'package:audiflow/features/browser/podcast/data/podcast_auto_loader.dart';
import 'package:audiflow/features/browser/podcast/data/podcast_stats_provider.dart';
import 'package:audiflow/features/browser/podcast/model/podcast_details_page_model.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_app_bar.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_filter_mode_switch.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_loading_page.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_page_controller.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_episodes_controller.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_image_and_title.dart';
import 'package:audiflow/features/browser/season/data/podcast_seasons_and_stats.dart';
import 'package:audiflow/features/browser/season/ui/season_list.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

/// This Widget takes a search result and builds a list of currently available
/// podcasts.
///
/// From here a user can option to subscribe/unsubscribe or play a podcast
/// directly from a search result.
class PodcastDetailsPage extends HookConsumerWidget {
  const PodcastDetailsPage({
    required this.collectionId,
    required this.feedUrl,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    super.key,
  });

  final int? collectionId;
  final String? feedUrl;
  final String? title;
  final String? author;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastState = ref.watch(
      podcastAutoLoaderProvider(
        feedUrl: feedUrl,
        collectionId: collectionId,
      ),
    );
    logger.d('podcastState: $podcastState');
    return podcastState is AsyncLoading
        ? PodcastDetailsLoadingPage(
            title: title,
            author: author,
            thumbnailUrl: thumbnailUrl,
          )
        : _PodcastDetailsPage(
            podcast: podcastState.valueOrNull,
            title: title,
            author: author,
            thumbnailUrl: thumbnailUrl,
          );
  }
}

class _PodcastDetailsPage extends HookConsumerWidget {
  const _PodcastDetailsPage({
    required this.podcast,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
  });

  final Podcast? podcast;
  final String? title;
  final String? author;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcast = this.podcast;
    final pageState = podcast == null
        ? null
        : ref
            .watch(podcastDetailsPageControllerProvider(podcast.id))
            .valueOrNull;

    final podcastStats = podcast == null
        ? null
        : ref.watch(podcastStatsProvider(podcast.id)).valueOrNull;

    final seasons = podcast == null
        ? null
        : ref.watch(podcastSeasonsAndStatsProvider(podcast.id)).valueOrNull;
    final supportsSeasons = seasons?.isNotEmpty == true;
    final viewMode =
        pageState?.viewMode == PodcastDetailsPageViewMode.episodes ||
                !supportsSeasons
            ? PodcastDetailsPageViewMode.episodes
            : PodcastDetailsPageViewMode.seasons;

    final podcastEpisodesState = pageState == null
        ? null
        : ref.watch(
            podcastEpisodesControllerProvider(
              pid: podcast!.id,
              filterMode: pageState.episodeFilterMode,
              ascending: pageState.episodesAscending,
            ),
          );

    final scrollController = useScrollController();
    return ProviderScope(
      overrides: [
        episodesListEventStreamProvider
            .overrideWith(EpisodesListEventStream.new),
      ],
      child: Semantics(
        header: false,
        label: L10n.of(context).semantics_podcast_details_header,
        child: ScrollsToTop(
          onScrollsToTop: (event) async {
            await scrollController.animateTo(
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
                //   await ref
                //       .read(podcastServiceProvider)
                //       .loadPodcast(metadata, refresh: true);
              },
              child: CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  PodcastDetailsAppBar(
                    podcast: podcast,
                    stats: podcastStats,
                  ),
                  SliverList.list(
                    children: [
                      PodcastImageAndTitle(
                        title: podcast?.title ?? title ?? '',
                        author: podcast?.author ?? author,
                        thumbnailUrl: thumbnailUrl,
                        imageUrl: podcast?.image,
                      ),
                      if (podcast?.description.isNotEmpty == true)
                        ExpandableTextBlock(text: podcast!.description),
                      if (pageState != null && supportsSeasons)
                        _ListingModeSwitchBar(podcast: podcast!),
                      if (pageState != null)
                        if (viewMode == PodcastDetailsPageViewMode.episodes)
                          PodcastDetailsEpisodesFilterModeSwitch(
                            podcast: podcast!,
                          )
                        else if (viewMode == PodcastDetailsPageViewMode.seasons)
                          PodcastDetailsSeasonsFilterModeSwitch(
                            podcast: podcast!,
                          ),
                    ],
                  ),
                  if (pageState != null &&
                      0 < (podcastStats?.totalEpisodes ?? 0))
                    if (viewMode == PodcastDetailsPageViewMode.episodes)
                      EpisodeList(
                        getEpisodeAt: (index) async {
                          return ref
                              .read(
                                podcastEpisodesControllerProvider(
                                  pid: podcast!.id,
                                  filterMode: pageState.episodeFilterMode,
                                  ascending: pageState.episodesAscending,
                                ).notifier,
                              )
                              .getEpisodeAt(index);
                        },
                        scrollController: scrollController,
                        episodeCount:
                            podcastEpisodesState!.valueOrNull?.loadedCount ?? 0,
                        parentThumbnailUrl: podcast?.image,
                      )
                    else if (viewMode == PodcastDetailsPageViewMode.seasons)
                      SeasonList(podcast: podcast!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListingModeSwitchBar extends HookConsumerWidget {
  const _ListingModeSwitchBar({
    required this.podcast,
  });

  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref
        .watch(podcastDetailsPageControllerProvider(podcast.id))
        .requireValue;
    final controller = useTabController(
      initialLength: 2,
      initialIndex:
          PodcastDetailsPageViewMode.values.indexOf(pageState.viewMode),
    );
    final l10n = L10n.of(context);
    return TabBar.secondary(
      controller: controller,
      dividerColor: Colors.transparent,
      onTap: (index) {
        final viewMode = PodcastDetailsPageViewMode.values[index];
        ref
            .watch(podcastDetailsPageControllerProvider(podcast.id).notifier)
            .setViewMode(viewMode);
      },
      tabs: <Widget>[
        Tab(text: l10n.episodes),
        Tab(text: l10n.seasons),
      ],
    );
  }
}
