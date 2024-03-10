// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:seasoning/core/l10n.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/podcast_info_provider.dart';
import 'package:seasoning/providers/podcast/podcast_seasons_provider.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';
import 'package:seasoning/services/settings/settings_service.dart';
import 'package:seasoning/ui/pages/app_bars/podcast_details_app_bar.dart';
import 'package:seasoning/ui/podcast/episode_list.dart';
import 'package:seasoning/ui/podcast/funding_menu.dart';
import 'package:seasoning/ui/podcast/season_list.dart';
import 'package:seasoning/ui/widgets/fill_remaining_error.dart';
import 'package:seasoning/ui/widgets/fill_remaining_loading.dart';
import 'package:seasoning/ui/widgets/podcast_html.dart';
import 'package:seasoning/ui/widgets/sort_icon_button.dart';

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
    final scaffoldMessengerKey =
        useState(GlobalKey<ScaffoldMessengerState>()).value;
    final podcastDetailsState = ref.watch(podcastInfoProvider(metadata));
    final podcast = podcastDetailsState.value?.podcast;
    final stats = podcastDetailsState.value?.stats;
    final seasonsState = podcast == null
        ? const AsyncLoading<List<Season>>()
        : ref.watch(podcastSeasonsProvider(podcast.metadata));

    var viewMode = stats?.viewMode ?? PodcastDetailViewMode.seasons;
    if (seasonsState.valueOrNull?.isEmpty == true &&
        viewMode == PodcastDetailViewMode.seasons) {
      viewMode = PodcastDetailViewMode.episodes;
    }

    final ascend = stats?.ascend ?? false;

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
                  .loadPodcast(metadata, refresh: true);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                PodcastDetailsAppBar(
                  metadata: metadata,
                  heroPrefix: heroPrefix,
                  foregroundColor:
                      paletteGenerator.lightMutedColor?.titleTextColor,
                  backgroundColor: paletteGenerator.lightMutedColor?.color,
                ),
                if (podcastDetailsState.isLoading || seasonsState.isLoading)
                  const FillRemainingLoading()
                else if (podcastDetailsState.hasError || podcast == null)
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
                          episodes: ascend
                              ? podcast.episodes.reversed.toList()
                              : podcast.episodes,
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
    final showOverflowState = useState(false);
    final descriptionKey = useState(GlobalKey()).value;
    final expandedState = useState(false);

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: showOverflowState.value,
                  child: SizedBox(
                    height: 48,
                    width: 48,
                    child: expandedState.value
                        ? TextButton(
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Icon(
                              Icons.expand_less,
                              semanticLabel: L10n.of(context)!
                                  .semantics_collapse_podcast_description,
                            ),
                            onPressed: () {
                              expandedState.value = false;
                            },
                          )
                        : TextButton(
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Icon(
                              Icons.expand_more,
                              semanticLabel: L10n.of(context)!
                                  .semantics_expand_podcast_description,
                            ),
                            onPressed: () {
                              expandedState.value = true;
                            },
                          ),
                  ),
                ),
              ],
            ),
            _PodcastDescription(
              key: descriptionKey,
              content: PodcastHtml(
                content: podcast.description,
                fontSize: FontSize.medium,
              ),
              isExpanded: expandedState.value,
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
    required this.isExpanded,
  });

  final PodcastHtml content;
  final bool isExpanded;
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
          constraints: isExpanded
              ? const BoxConstraints()
              : BoxConstraints.loose(
                  const Size(double.infinity, maxHeight - padding),
                ),
          child: isExpanded
              ? content
              : ShaderMask(
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
        color: theme.colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PodcastViewModeSwitch(
              viewMode: viewMode,
              hasSeasons: seasons.isNotEmpty,
              onChanged: (mode) {
                ref
                    .read(podcastInfoProvider(podcast.metadata).notifier)
                    .setViewMode(mode);
              },
            ),
            SortIconButton(
              ascend: ascend,
              onTap: () {
                ref
                    .read(podcastInfoProvider(podcast.metadata).notifier)
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
    required this.hasSeasons,
    required this.onChanged,
  });

  final PodcastDetailViewMode viewMode;
  final bool hasSeasons;
  final ValueChanged<PodcastDetailViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<PodcastDetailViewMode>(
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      itemBuilder: (context) {
        return PodcastDetailViewMode.values
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
            )
            .toList();
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
        return l10n.view_mode_episodes;
      case PodcastDetailViewMode.seasons:
        return l10n.view_mode_seasons;
      case PodcastDetailViewMode.played:
        return l10n.view_mode_played;
      case PodcastDetailViewMode.unplayed:
        return l10n.view_mode_unplayed;
      case PodcastDetailViewMode.downloaded:
        return l10n.view_mode_downloaded;
    }
  }
}
