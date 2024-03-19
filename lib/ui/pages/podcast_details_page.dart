// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:audiflow/services/settings/settings_service.dart';
import 'package:audiflow/ui/pages/app_bars/podcast_details_app_bar.dart';
import 'package:audiflow/ui/podcast/episode_list.dart';
import 'package:audiflow/ui/podcast/funding_menu.dart';
import 'package:audiflow/ui/podcast/season_list.dart';
import 'package:audiflow/ui/providers/episodes_list_event_provider.dart';
import 'package:audiflow/ui/providers/podcast_info_provider.dart';
import 'package:audiflow/ui/providers/podcast_seasons_provider.dart';
import 'package:audiflow/ui/providers/podcast_view_episodes_provider.dart';
import 'package:audiflow/ui/providers/podcast_view_info_provider.dart';
import 'package:audiflow/ui/widgets/fill_remaining_error.dart';
import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
import 'package:audiflow/ui/widgets/podcast_html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

/// This Widget takes a search result and builds a list of currently available
/// podcasts.
///
/// From here a user can option to subscribe/unsubscribe or play a podcast
/// directly from a search result.
class PodcastDetailsPage extends HookConsumerWidget {
  const PodcastDetailsPage({
    required this.metadata,
    required this.heroPrefix,
    required this.paletteGenerator,
    super.key,
  });

  final PodcastMetadata metadata;
  final String heroPrefix;
  final PaletteGenerator paletteGenerator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastState =
        ref.watch(podcastInfoProvider(metadata.guid, needsEpisodes: true));
    final podcast = podcastState.value?.podcast;
    final seasonsState = podcast == null
        ? const AsyncLoading<List<Season>>()
        : ref.watch(
            podcastSeasonsProvider(podcast),
          );

    final podcastViewState = ref.watch(podcastViewInfoProvider(metadata.guid));
    final viewMode =
        podcastViewState.valueOrNull?.viewMode ?? PodcastDetailViewMode.seasons;
    final ascend = podcastViewState.valueOrNull?.ascend ?? false;
    final podcastViewEpisodesState = podcast == null
        ? null
        : ref.watch(podcastViewEpisodesProvider(podcast.guid));

    final controller = useScrollController();
    return ProviderScope(
      overrides: [
        episodesListEventStreamProvider
            .overrideWith(EpisodesListEventStream.new),
      ],
      child: Semantics(
        header: false,
        label: L10n.of(context)!.semantics_podcast_details_header,
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
                    .loadPodcast(metadata, refresh: true);
              },
              child: CustomScrollView(
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  PodcastDetailsAppBar(
                    metadata: metadata,
                    heroPrefix: heroPrefix,
                    foregroundColor:
                        paletteGenerator.lightMutedColor?.titleTextColor,
                    backgroundColor: paletteGenerator.lightMutedColor?.color,
                  ),
                  if (podcastState.isLoading ||
                      seasonsState.isLoading ||
                      podcastViewState.isLoading ||
                      podcastViewEpisodesState == null ||
                      podcastViewEpisodesState.isLoading)
                    const FillRemainingLoading()
                  else if (podcastState.hasError || podcast == null)
                    FillRemainingError.podcastNoResults()
                  else ...[
                    _PodcastTitle(podcast),
                    _SwitchBar(
                      podcast: podcast,
                      seasons: seasonsState.value!,
                      viewMode: viewMode,
                      ascend: ascend,
                    ),
                    viewMode == PodcastDetailViewMode.seasons
                        ? SeasonList(podcast: podcast)
                        : EpisodeList(
                            episodeGroupKey: ValueKey(podcast.guid),
                            metadata: podcast.metadata,
                            episodes: podcastViewEpisodesState.requireValue,
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
    final settings = ref.watch(settingsServiceProvider);
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
            Text(
              podcast.copyright,
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
                    .read(podcastViewInfoProvider(podcast.guid).notifier)
                    .setViewMode(mode);
              },
              onSortOrderChanged: () {
                ref
                    .read(podcastViewInfoProvider(podcast.guid).notifier)
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
                (viewMode) =>
                    hasSeasons || viewMode != PodcastDetailViewMode.seasons,
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
                  L10n.of(context)!.viewSortOldestToNewest,
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
    final l10n = L10n.of(context)!;
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
