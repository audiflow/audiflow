import 'package:audiflow/common/ui/fill_remaining_loading.dart';
import 'package:audiflow/common/ui/placeholder_builder.dart';
import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/browser/common/ui/podcast_html.dart';
import 'package:audiflow/features/browser/episode/ui/episodes_list_event.dart';
import 'package:audiflow/features/browser/podcast/data/podcast_info.dart';
import 'package:audiflow/features/browser/podcast/ui/funding_menu.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_app_bar.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_page_header_image.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_view_episodes.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_view_info_controller.dart';
import 'package:audiflow/features/browser/season/data/podcast_seasons.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/preference/data/app_preference_repository.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:audiflow/localization/string_hardcoded.dart';
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
    final podcastInfoState = ref.watch(
      podcastInfoProvider(
        feedUrl: feedUrl,
        collectionId: collectionId,
      ),
    );
    logger.d(() => 'podcastInfoState: $podcastInfoState');

    final podcast = podcastInfoState.valueOrNull?.podcast;
    return podcast == null
        ? _PodcastDetailsLoadingPage(
            title: title,
            author: author,
            thumbnailUrl: thumbnailUrl,
          )
        : _PodcastDetailsPage(
            podcast: podcast,
            stats: podcastInfoState.valueOrNull?.stats,
          );
  }
}

class _PodcastDetailsLoadingPage extends HookConsumerWidget {
  const _PodcastDetailsLoadingPage({
    required this.title,
    required this.author,
    required this.thumbnailUrl,
  });

  final String? title;
  final String? author;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      header: false,
      label: L10n.of(context).semantics_podcast_details_header,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: <Widget>[
            PodcastDetailsAppBar(title: title),
            _PodcastImageAndTitle(
              title: title ?? '',
              author: author,
              thumbnailUrl: thumbnailUrl,
            ),
            const FillRemainingLoading()
          ],
        ),
      ),
    );
  }
}

class _PodcastDetailsPage extends HookConsumerWidget {
  const _PodcastDetailsPage({
    required this.podcast,
    required this.stats,
  });

  final Podcast podcast;
  final PodcastStats? stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastViewState =
        ref.watch(podcastViewInfoControllerProvider(podcast.id));
    final viewMode = podcastViewState.valueOrNull?.viewMode;
    final ascend = podcastViewState.valueOrNull?.ascend ?? false;
    final podcastViewEpisodesState =
        ref.watch(podcastViewEpisodesProvider(podcast.id));
    final seasonsState = ref.watch(podcastSeasonsProvider(podcast));

    final controller = useScrollController();
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
                //   await ref
                //       .read(podcastServiceProvider)
                //       .loadPodcast(metadata, refresh: true);
              },
              child: CustomScrollView(
                controller: controller,
                slivers: <Widget>[
                  PodcastDetailsAppBar(
                    podcast: podcast,
                    stats: stats,
                  ),
                  SliverList.list(
                    children: [
                      _PodcastImageAndTitle(
                        title: podcast.title,
                        author: podcast.author,
                        thumbnailUrl: podcast.image,
                      ),
                      _SwitchTabBar(),
                    ],
                  ),
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

class _PodcastImageAndTitle extends StatelessWidget {
  const _PodcastImageAndTitle({
    required this.title,
    required this.author,
    required this.thumbnailUrl,
  });

  final String title;
  final String? author;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final placeholderBuilder = PlaceholderBuilder.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PodcastHeaderImage.small(
            imageUrl: thumbnailUrl ?? '',
            placeholderBuilder: placeholderBuilder,
          ),
          gapW8,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.left,
                ),
                gapH12,
                if (author != null)
                  Text(
                    author!,
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.left,
                  ),
              ],
            ),
          ),
        ],
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

class _SwitchTabBar extends HookConsumerWidget {
  const _SwitchTabBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTabController(initialLength: 2);
    return TabBar.secondary(
      controller: controller,
      dividerColor: Colors.transparent,
      tabs: <Widget>[
        Tab(text: 'Episodes'.hardcoded),
        Tab(text: 'Seasons'.hardcoded),
      ],
    );
  }
}

class _SwitchBar extends ConsumerWidget {
  const _SwitchBar({
    required this.podcast,
    required this.seasons,
    required this.viewMode,
    required this.ascend,
  });

  final Podcast podcast;
  final List<Season> seasons;
  final PodcastDetailViewMode viewMode;
  final bool ascend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Container(
        color: theme.colorScheme.surfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PodcastViewModeSwitch(
              viewMode: viewMode,
              ascend: ascend,
              hasSeasons: seasons.isNotEmpty,
              onViewModeChanged: (mode) {
                ref
                    .read(
                      podcastViewInfoControllerProvider(podcast.id).notifier,
                    )
                    .setViewMode(mode);
              },
              onSortOrderChanged: () {
                ref
                    .read(
                      podcastViewInfoControllerProvider(podcast.id).notifier,
                    )
                    .toggleAscend();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PodcastViewModeSwitch extends StatelessWidget {
  const _PodcastViewModeSwitch({
    required this.viewMode,
    required this.ascend,
    required this.hasSeasons,
    required this.onViewModeChanged,
    required this.onSortOrderChanged,
  });

  final PodcastDetailViewMode viewMode;
  final bool ascend;
  final bool hasSeasons;
  final ValueChanged<PodcastDetailViewMode> onViewModeChanged;
  final VoidCallback onSortOrderChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<dynamic>(
      onSelected: (value) {
        if (value is PodcastDetailViewMode) {
          onViewModeChanged(value);
        } else if (value is bool) {
          onSortOrderChanged();
        }
      },
      position: PopupMenuPosition.under,
      itemBuilder: (context) {
        return [
          ...PodcastDetailViewMode.values
              .where(
                (viewMode) => viewMode != PodcastDetailViewMode.seasons,
              )
              .map(
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
                        _labelOf(context, mode),
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
            _labelOf(context, viewMode),
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

  String _labelOf(BuildContext context, PodcastDetailViewMode viewMode) {
    final l10n = L10n.of(context);
    switch (viewMode) {
      case PodcastDetailViewMode.episodes:
        return l10n.viewModeEpisodes;
      case PodcastDetailViewMode.seasons:
        return l10n.viewModeSeasons;
      case PodcastDetailViewMode.played:
        return l10n.viewModePlayed;
      case PodcastDetailViewMode.unplayed:
        return l10n.viewModeUnplayed;
      case PodcastDetailViewMode.downloaded:
        return l10n.viewModeDownloaded;
    }
  }
}
