import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/common/ui/podcast_html.dart';
import 'package:audiflow/features/browser/episode/ui/episode_list.dart';
import 'package:audiflow/features/browser/episode/ui/episodes_list_event.dart';
import 'package:audiflow/features/browser/podcast/data/podcast_auto_loader.dart';
import 'package:audiflow/features/browser/podcast/data/podcast_stats_provider.dart';
import 'package:audiflow/features/browser/podcast/model/podcast_details_page_model.dart';
import 'package:audiflow/features/browser/podcast/ui/funding_menu.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_app_bar.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_filter_mode_switch.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_loading_page.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_page_controller.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_image_and_title.dart';
import 'package:audiflow/features/browser/season/data/podcast_seasons.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/preference/data/app_preference_repository.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
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

    // final viewMode = pageState.valueOrNull?.viewMode;
    // final ascend = pageState.valueOrNull?.ascend ?? false;
    // final podcastViewEpisodesState =
    //     ref.watch(podcastViewEpisodesProvider(podcast.id));
    final seasonsState = podcast == null
        ? null
        : ref.watch(podcastSeasonsProvider(podcast)).valueOrNull;

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
                      if (podcast != null && seasonsState?.isNotEmpty == true)
                        _ListingModeSwitchBar(podcast: podcast),
                      if (podcast != null)
                        PodcastDetailsFilterModeSwitch(podcast: podcast),
                    ],
                  ),
                  if (podcast != null &&
                      pageState != null &&
                      0 < (podcastStats?.totalEpisodes ?? 0))
                    EpisodeList(
                      podcast: podcast,
                      scrollController: scrollController,
                      filterMode: pageState.episodeFilterMode,
                      ascending: pageState.episodesAscending,
                    )
                  // _SwitchBar(
                  //   podcast: podcast,
                  //   seasons: const [], // seasonsState.value!,
                  //   viewMode: viewMode ?? PodcastDetailViewMode.episodes,
                  //   ascend: ascend,
                  // ),
                  // viewMode == PodcastDetailViewMode.seasons
                  //     ? SeasonList(podcast: podcast)
                  //     : EpisodeList(
                  //         episodeGroupKey: ValueKey(podcast.guid),
                  //         podcast: podcast,
                  //         episodes: podcastViewEpisodesState.requireValue,
                  //         scrollController: controller,
                  //       ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders the podcast or episode image.

/// Renders the podcast title, copyright, description, follow/unfollow and
/// overflow button.
///
/// If the episode description is fairly long, an overflow icon is also shown
/// and a portion of the episode description is shown. Tapping the overflow
/// icons allows the user to expand and collapse the text.
class _PodcastTitle extends HookConsumerWidget {
  const _PodcastTitle(this.podcast);

  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(appPreferenceRepositoryProvider);
    final descriptionKey = useState(GlobalKey()).value;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed(
          <Widget>[
            const SizedBox(height: 8),
            Text(
              podcast.title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (podcast.copyright != null)
              Text(
                podcast.copyright!,
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            _PodcastDescription(
              key: descriptionKey,
              content: PodcastHtml(
                content: podcast.description,
                fontSize: FontSize.medium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: <Widget>[
                  // FollowButton(podcast),
                  // PodcastContextMenu(podcast),
                  settings.showFunding
                      ? FundingMenu(podcast.funding)
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// This class wraps the description in an expandable box.
///
/// This handles the common case whereby the description is very long and,
/// without this constraint, would require the use to always scroll before
/// reaching the podcast episodes.
///
class _PodcastDescription extends StatelessWidget {
  const _PodcastDescription({
    super.key,
    required this.content,
  });

  final PodcastHtml content;
  static const maxHeight = 100.0;
  static const padding = 4.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _PodcastDescription.padding),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 150),
        curve: Curves.fastOutSlowIn,
        alignment: Alignment.topCenter,
        child: Container(
          constraints: BoxConstraints.loose(
            const Size(double.infinity, maxHeight - padding),
          ),
          child: ShaderMask(
            shaderCallback: LinearGradient(
              colors: [Colors.white, Colors.white.withAlpha(0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.9, 1],
            ).createShader,
            child: content,
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

// class _SwitchBar extends ConsumerWidget {
//   const _SwitchBar({
//     required this.podcast,
//     required this.seasons,
//     required this.viewMode,
//     required this.ascend,
//   });
//
//   final Podcast podcast;
//   final List<Season> seasons;
//   final EpisodeFilterMode viewMode;
//   final bool ascend;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);
//     return SliverToBoxAdapter(
//       child: Container(
//         color: theme.colorScheme.surfaceVariant,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _PodcastViewModeSwitch(
//               viewMode: viewMode,
//               ascend: ascend,
//               hasSeasons: seasons.isNotEmpty,
//               onViewModeChanged: (mode) {
//                 ref
//                     .read(
//                       podcastViewInfoControllerProvider(podcast.id).notifier,
//                     )
//                     .setViewMode(mode);
//               },
//               onSortOrderChanged: () {
//                 ref
//                     .read(
//                       podcastViewInfoControllerProvider(podcast.id).notifier,
//                     )
//                     .toggleAscend();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _PodcastViewModeSwitch extends StatelessWidget {
  const _PodcastViewModeSwitch({
    required this.viewMode,
    required this.ascend,
    required this.hasSeasons,
    required this.onViewModeChanged,
    required this.onSortOrderChanged,
  });

  final EpisodeFilterMode viewMode;
  final bool ascend;
  final bool hasSeasons;
  final ValueChanged<EpisodeFilterMode> onViewModeChanged;
  final VoidCallback onSortOrderChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<dynamic>(
      onSelected: (value) {
        if (value is EpisodeFilterMode) {
          onViewModeChanged(value);
        } else if (value is bool) {
          onSortOrderChanged();
        }
      },
      position: PopupMenuPosition.under,
      itemBuilder: (context) {
        return [
          ...EpisodeFilterMode.values.map(
            (mode) => PopupMenuItem(
              value: mode,
              height: 40,
              child: Row(
                children: [
                  mode == viewMode
                      ? Icon(
                          Symbols.check,
                          color: theme.colorScheme.onSecondaryContainer,
                          size: 18,
                        )
                      : const SizedBox(width: 18),
                  const SizedBox(width: 4),
                  Text(
                    mode.labelOf(L10n.of(context)),
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: ascend,
            height: 40,
            child: Row(
              children: [
                ascend
                    ? Icon(
                        Symbols.check,
                        color: theme.colorScheme.onSecondaryContainer,
                        size: 18,
                      )
                    : const SizedBox(width: 18),
                const SizedBox(width: 4),
                Text(
                  L10n.of(context).viewSortOldestToNewest,
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
      child: Row(
        children: [
          Text(
            viewMode.labelOf(L10n.of(context)),
            style: theme.textTheme.titleMedium!
                .copyWith(color: theme.colorScheme.onSecondaryContainer),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}
