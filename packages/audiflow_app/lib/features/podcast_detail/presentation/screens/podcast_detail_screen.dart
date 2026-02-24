import 'package:audiflow_domain/audiflow_domain.dart'
    show
        EpisodeFilter,
        PodcastItem,
        PodcastViewMode,
        SmartPlaylist,
        SmartPlaylistContentType,
        SmartPlaylistEpisodeData,
        SmartPlaylistGroup,
        SmartPlaylistSortCondition,
        SmartPlaylistSortField,
        SmartPlaylistSortSpec,
        SortKeyGreaterThan,
        SortOrder,
        YearHeaderMode,
        podcastViewPreferenceControllerProvider,
        smartPlaylistEpisodesProvider,
        smartPlaylistPatternByFeedUrlProvider,
        subscriptionByFeedUrlProvider;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:extended_image/extended_image.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import '../controllers/podcast_detail_controller.dart';
import '../widgets/episode_filter_chips.dart';
import '../widgets/episode_list_tile.dart';
import '../widgets/smart_playlist_episode_list_tile.dart';
import '../widgets/smart_playlist_view_toggle.dart';

/// Displays podcast details and episode list with
/// playback controls.
class PodcastDetailScreen extends ConsumerStatefulWidget {
  const PodcastDetailScreen({super.key, required this.podcast});

  final Podcast podcast;

  @override
  ConsumerState<PodcastDetailScreen> createState() =>
      _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends ConsumerState<PodcastDetailScreen> {
  final _scrollController = ScrollController();

  String _searchQuery = '';

  /// Local view mode for non-subscribed podcasts.
  PodcastViewMode _localViewMode = PodcastViewMode.episodes;

  /// Local selected playlist ID for non-subscribed podcasts.
  String? _localSelectedPlaylistId;

  Podcast get podcast => widget.podcast;

  /// RSS feed-level image URL for thumbnail deduplication.
  String? _feedImageUrl;

  /// Subscription's last refresh timestamp for "new" badge logic.
  DateTime? _lastRefreshedAt;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: SearchableAppBar(
        title: Text(podcast.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        onSearchChanged: (query) => setState(() => _searchQuery = query),
      ),
      body: _buildBody(context, ref, theme, colorScheme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final feedUrl = podcast.feedUrl;

    if (feedUrl == null) {
      return _buildNoFeedUrlState(theme, colorScheme);
    }

    final feedAsync = ref.watch(podcastDetailProvider(feedUrl));

    return feedAsync.when(
      data: (_) => _buildContent(context, ref, theme, feedUrl),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(
        theme,
        colorScheme,
        error.toString(),
        () => ref.invalidate(podcastDetailProvider(feedUrl)),
      ),
    );
  }

  Widget _buildNoFeedUrlState(ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rss_feed_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              l10n.podcastDetailFeedUrlMissing,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.podcastDetailFeedUrlMissingSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    ThemeData theme,
    ColorScheme colorScheme,
    String error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              AppLocalizations.of(context).podcastDetailLoadError,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).commonRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    String feedUrl,
  ) {
    _feedImageUrl = ref
        .watch(podcastDetailProvider(feedUrl))
        .value
        ?.podcast
        .primaryImage
        ?.url;

    final subscriptionAsync = ref.watch(subscriptionByFeedUrlProvider(feedUrl));
    final subscription = subscriptionAsync.value;
    _lastRefreshedAt = subscription?.lastRefreshedAt;

    final prefsAsync = subscription != null
        ? ref.watch(podcastViewPreferenceControllerProvider(subscription.id))
        : null;
    final prefs = prefsAsync?.value;

    final viewMode = prefs?.viewMode ?? _localViewMode;
    final filter = prefs?.episodeFilter ?? EpisodeFilter.all;
    final selectedPlaylistId =
        prefs?.selectedPlaylistId ?? _localSelectedPlaylistId;

    final sortOrder = prefs?.episodeSortOrder ?? SortOrder.descending;

    final filteredAsync = ref.watch(
      filteredSortedEpisodesProvider(feedUrl, filter, sortOrder),
    );

    final progressMapAsync = ref.watch(podcastEpisodeProgressProvider(feedUrl));

    // Fetch playlists for toggle
    final playlistsAsync = ref.watch(
      sortedPodcastSmartPlaylistsProvider(feedUrl, podcast.id),
    );
    final grouping = playlistsAsync.value;
    final allPlaylists = grouping?.playlists ?? [];

    // Build ungrouped playlist if needed
    final displayPlaylists = <SmartPlaylist>[
      ...allPlaylists,
      if (grouping != null && grouping.hasUngrouped)
        SmartPlaylist(
          id: 'ungrouped',
          displayName: AppLocalizations.of(context).podcastDetailUngrouped,
          sortKey: 999999,
          episodeIds: grouping.ungroupedEpisodeIds,
        ),
    ];

    // Resolve selected playlist for inline display
    SmartPlaylist? activePlaylist;
    if (viewMode == PodcastViewMode.smartPlaylists &&
        displayPlaylists.isNotEmpty) {
      activePlaylist =
          displayPlaylists
              .where((p) => p.id == selectedPlaylistId)
              .firstOrNull ??
          displayPlaylists.first;
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(podcastDetailProvider(feedUrl));
        ref.invalidate(podcastEpisodeProgressProvider(feedUrl));
        await ref.read(podcastDetailProvider(feedUrl).future);
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, ref, theme)),
          // View mode toggle
          if (displayPlaylists.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                child: SmartPlaylistViewToggle(
                  playlists: displayPlaylists,
                  selectedMode: viewMode,
                  selectedPlaylistId: activePlaylist?.id ?? selectedPlaylistId,
                  onEpisodesSelected: () {
                    if (subscription != null) {
                      ref
                          .read(
                            podcastViewPreferenceControllerProvider(
                              subscription.id,
                            ).notifier,
                          )
                          .setViewMode(PodcastViewMode.episodes);
                    } else {
                      setState(() {
                        _localViewMode = PodcastViewMode.episodes;
                      });
                    }
                  },
                  onPlaylistSelected: (playlist) {
                    if (subscription != null) {
                      ref
                          .read(
                            podcastViewPreferenceControllerProvider(
                              subscription.id,
                            ).notifier,
                          )
                          .selectPlaylist(playlist.id);
                    } else {
                      setState(() {
                        _localViewMode = PodcastViewMode.smartPlaylists;
                        _localSelectedPlaylistId = playlist.id;
                      });
                    }
                  },
                ),
              ),
            ),
          // Filter chips only in episodes view
          if (viewMode == PodcastViewMode.episodes)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: EpisodeFilterChips(
                  selected: filter,
                  onSelected: (f) {
                    if (subscription != null) {
                      ref
                          .read(
                            podcastViewPreferenceControllerProvider(
                              subscription.id,
                            ).notifier,
                          )
                          .setEpisodeFilter(f);
                    }
                  },
                ),
              ),
            ),
          // Content
          if (viewMode == PodcastViewMode.episodes)
            ..._buildEpisodeList(
              ref,
              feedUrl,
              filteredAsync,
              progressMapAsync,
              theme,
              sortOrder,
            )
          else if (activePlaylist != null)
            ..._buildInlinePlaylistEpisodes(
              ref,
              activePlaylist,
              theme,
              sortOrder,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildInlinePlaylistEpisodes(
    WidgetRef ref,
    SmartPlaylist playlist,
    ThemeData theme,
    SortOrder sortOrder,
  ) {
    final hasFeedIds =
        playlist.episodeIds.isNotEmpty && playlist.episodeIds.first < 0;
    final feedUrl = podcast.feedUrl;

    final episodesAsync = hasFeedIds && feedUrl != null
        ? ref.watch(
            feedSmartPlaylistEpisodesProvider(feedUrl, playlist.episodeIds),
          )
        : ref.watch(smartPlaylistEpisodesProvider(playlist.episodeIds));

    return episodesAsync.when(
      data: (episodes) {
        if (episodes.isEmpty) {
          return [SliverFillRemaining(child: _buildEmptyPlaylistState(theme))];
        }

        // Groups-based playlists show group cards, not episodes.
        if (playlist.contentType == SmartPlaylistContentType.groups &&
            playlist.groups != null &&
            playlist.groups!.isNotEmpty) {
          return _buildInlineGroupList(episodes, playlist, theme, sortOrder);
        }

        final displayEpisodes = filterBySearchQuery(
          items: episodes,
          query: _searchQuery,
          getTitle: (e) => e.episode.title,
          getDescription: (e) => e.episode.description,
        );

        if (displayEpisodes.isEmpty && 2 <= _searchQuery.length) {
          return [_buildSearchEmptyState(theme)];
        }

        if (playlist.yearHeaderMode != YearHeaderMode.none) {
          return _buildYearGroupedPlaylistSlivers(
            displayEpisodes,
            playlist,
            theme,
            sortOrder,
          );
        }

        final sorted = sortOrder == SortOrder.ascending
            ? displayEpisodes.reversed.toList()
            : displayEpisodes;

        return [
          if (playlist.showSortOrderToggle)
            SliverToBoxAdapter(
              child: _buildSortHeader(
                theme,
                AppLocalizations.of(
                  context,
                ).podcastDetailEpisodeCount(sorted.length),
                sortOrder,
              ),
            ),
          SliverList.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final data = sorted[index];
              return SmartPlaylistEpisodeListTile(
                lastRefreshedAt: _lastRefreshedAt,
                key: ValueKey(data.episode.id),
                episode: data.episode,
                podcastTitle: podcast.name,
                artworkUrl: podcast.artworkUrl,
                feedImageUrl: _feedImageUrl,
                progress: data.progress,
                siblingEpisodeIds: playlist.episodeIds,
              );
            },
          ),
        ];
      },
      loading: () => [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
      error: (error, _) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Center(
              child: Text(
                AppLocalizations.of(
                  context,
                ).podcastDetailEpisodeLoadError(error.toString()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildYearGroupedPlaylistSlivers(
    List<SmartPlaylistEpisodeData> episodes,
    SmartPlaylist playlist,
    ThemeData theme,
    SortOrder sortOrder,
  ) {
    final byYear = <int, List<SmartPlaylistEpisodeData>>{};
    for (final data in episodes) {
      final year = data.episode.publishedAt?.year ?? 0;
      byYear.putIfAbsent(year, () => []).add(data);
    }
    if (sortOrder == SortOrder.descending) {
      for (final key in byYear.keys) {
        byYear[key] = byYear[key]!.reversed.toList();
      }
    }
    final sortedYears = byYear.keys.toList()
      ..sort(
        sortOrder == SortOrder.descending
            ? (a, b) => b.compareTo(a)
            : (a, b) => a.compareTo(b),
      );

    return buildYearGroupedSlivers<SmartPlaylistEpisodeData>(
      itemsByYear: byYear,
      sortedYears: sortedYears,
      itemBuilder: (context, data) => SmartPlaylistEpisodeListTile(
        key: ValueKey(data.episode.id),
        episode: data.episode,
        podcastTitle: podcast.name,
        artworkUrl: podcast.artworkUrl,
        feedImageUrl: _feedImageUrl,
        progress: data.progress,
        siblingEpisodeIds: playlist.episodeIds,
      ),
      scrollController: _scrollController,
      yearGroupingEnabled: true,
      itemExtent: episodeCardExtent,
    );
  }

  Widget _buildSortHeader(ThemeData theme, String label, SortOrder sortOrder) {
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _toggleSortOrder,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xxs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    sortOrder == SortOrder.ascending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sortOrder == SortOrder.ascending
                        ? l10n.podcastDetailOldestFirst
                        : l10n.podcastDetailNewestFirst,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSortOrder() {
    final feedUrl = podcast.feedUrl;
    if (feedUrl == null) return;
    final subscriptionAsync = ref.read(subscriptionByFeedUrlProvider(feedUrl));
    final subscription = subscriptionAsync.value;
    if (subscription == null) return;
    final prefsAsync = ref.read(
      podcastViewPreferenceControllerProvider(subscription.id),
    );
    final current = prefsAsync.value?.episodeSortOrder ?? SortOrder.descending;
    final next = current == SortOrder.descending
        ? SortOrder.ascending
        : SortOrder.descending;
    ref
        .read(podcastViewPreferenceControllerProvider(subscription.id).notifier)
        .setEpisodeSortOrder(next);
  }

  List<Widget> _buildInlineGroupList(
    List<SmartPlaylistEpisodeData> episodes,
    SmartPlaylist playlist,
    ThemeData theme,
    SortOrder sortOrder,
  ) {
    final groups = playlist.groups!;
    final displayGroups = filterBySearchQuery(
      items: groups,
      query: _searchQuery,
      getTitle: (g) => g.displayName,
    );

    if (displayGroups.isEmpty && 2 <= _searchQuery.length) {
      return [_buildSearchEmptyState(theme)];
    }

    final episodeMap = <int, SmartPlaylistEpisodeData>{};
    for (final ep in episodes) {
      episodeMap[ep.episode.id] = ep;
    }

    if (playlist.yearHeaderMode == YearHeaderMode.none) {
      final sorted = _sortGroupsByCustomSort(
        displayGroups,
        playlist.customSort,
        sortOrder,
      );

      return [
        if (playlist.showSortOrderToggle)
          SliverToBoxAdapter(
            child: _buildSortHeader(
              theme,
              AppLocalizations.of(
                context,
              ).podcastDetailGroupCount(sorted.length),
              sortOrder,
            ),
          ),
        SliverList.builder(
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final group = sorted[index];
            return _InlineGroupCard(
              group: group,
              podcastArtworkUrl: podcast.artworkUrl,
              onTap: () => _navigateToGroupEpisodes(playlist, group),
            );
          },
        ),
      ];
    }

    // Year-grouped display: determine year per group from
    // first episode's publishedAt.
    final byYear = <int, List<SmartPlaylistGroup>>{};
    for (final group in displayGroups) {
      var year = 0;
      if (group.episodeIds.isNotEmpty) {
        final firstId = group.episodeIds.first;
        final ep = episodeMap[firstId];
        year = ep?.episode.publishedAt?.year ?? 0;
      }
      byYear.putIfAbsent(year, () => []).add(group);
    }

    if (sortOrder == SortOrder.descending) {
      for (final key in byYear.keys) {
        byYear[key] = byYear[key]!.reversed.toList();
      }
    }

    final sortedYears = byYear.keys.toList()
      ..sort(
        sortOrder == SortOrder.descending
            ? (a, b) => b.compareTo(a)
            : (a, b) => a.compareTo(b),
      );

    return [
      SliverToBoxAdapter(
        child: _buildSortHeader(
          theme,
          AppLocalizations.of(
            context,
          ).podcastDetailGroupCount(displayGroups.length),
          sortOrder,
        ),
      ),
      ...buildYearGroupedSlivers<SmartPlaylistGroup>(
        itemsByYear: {for (final y in sortedYears) y: byYear[y]!},
        sortedYears: sortedYears,
        itemBuilder: (context, group) => _InlineGroupCard(
          group: group,
          podcastArtworkUrl: podcast.artworkUrl,
          onTap: () => _navigateToGroupEpisodes(playlist, group),
        ),
        scrollController: _scrollController,
        yearGroupingEnabled: true,
        itemExtent: 84,
      ),
    ];
  }

  void _navigateToGroupEpisodes(
    SmartPlaylist playlist,
    SmartPlaylistGroup group,
  ) {
    final uri = GoRouterState.of(context).uri;
    final directGroupPath = AppRoutes.smartPlaylistDirectGroup
        .replaceFirst(':playlistId', playlist.id)
        .replaceFirst(':groupId', group.id);
    context.push(
      '$uri/$directGroupPath',
      extra: <String, dynamic>{
        'podcast': podcast,
        'group': group,
        'smartPlaylist': playlist,
        'podcastTitle': podcast.name,
        'podcastArtworkUrl': podcast.artworkUrl,
        'feedImageUrl': _feedImageUrl,
        'lastRefreshedAt': _lastRefreshedAt,
      },
    );
  }

  List<Widget> _buildEpisodeList(
    WidgetRef ref,
    String feedUrl,
    AsyncValue<List<PodcastItem>> episodesAsync,
    AsyncValue<EpisodeProgressMap> progressMapAsync,
    ThemeData theme,
    SortOrder sortOrder,
  ) {
    final patternAsync = ref.watch(
      smartPlaylistPatternByFeedUrlProvider(feedUrl),
    );
    final yearGrouped = patternAsync.value?.yearGroupedEpisodes ?? false;

    return episodesAsync.when(
      data: (episodes) {
        final displayEpisodes = filterBySearchQuery(
          items: episodes,
          query: _searchQuery,
          getTitle: (e) => e.title,
          getDescription: (e) => e.description,
        );

        if (displayEpisodes.isEmpty) {
          if (2 <= _searchQuery.length) {
            return [_buildSearchEmptyState(theme)];
          }
          return [SliverFillRemaining(child: _buildEmptyFilterState(theme))];
        }

        final progressMap = progressMapAsync.value ?? {};
        final sortHeader = SliverToBoxAdapter(
          child: _buildSortHeader(
            theme,
            AppLocalizations.of(
              context,
            ).podcastDetailEpisodeCount(displayEpisodes.length),
            sortOrder,
          ),
        );

        if (yearGrouped) {
          return [
            sortHeader,
            ..._buildYearGroupedEpisodeSlivers(
              displayEpisodes,
              progressMap,
              theme,
              sortOrder,
            ),
          ];
        }

        return [
          sortHeader,
          SliverList.builder(
            itemCount: displayEpisodes.length,
            itemBuilder: (context, index) {
              final episode = displayEpisodes[index];
              final progress = episode.enclosureUrl != null
                  ? progressMap[episode.enclosureUrl]
                  : null;

              return EpisodeListTile(
                lastRefreshedAt: _lastRefreshedAt,
                key: ValueKey(episode.guid ?? index),
                episode: episode,
                podcastTitle: podcast.name,
                artworkUrl: podcast.artworkUrl,
                feedImageUrl: _feedImageUrl,
                progress: progress,
              );
            },
          ),
        ];
      },
      loading: () => [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
      error: (error, _) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Text(
              AppLocalizations.of(
                context,
              ).podcastDetailEpisodeLoadError(error.toString()),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildYearGroupedEpisodeSlivers(
    List<PodcastItem> episodes,
    EpisodeProgressMap progressMap,
    ThemeData theme,
    SortOrder sortOrder,
  ) {
    final byYear = <int, List<PodcastItem>>{};
    for (final episode in episodes) {
      final dbEpisode = episode.enclosureUrl != null
          ? progressMap[episode.enclosureUrl]?.episode
          : null;
      final year =
          dbEpisode?.publishedAt?.year ?? episode.publishDate?.year ?? 0;
      byYear.putIfAbsent(year, () => []).add(episode);
    }
    // The provider already returns episodes in the requested sort order,
    // so no per-year reversal is needed.
    final sortedYears = byYear.keys.toList()
      ..sort(
        sortOrder == SortOrder.descending
            ? (a, b) => b.compareTo(a)
            : (a, b) => a.compareTo(b),
      );

    return buildYearGroupedSlivers<PodcastItem>(
      itemsByYear: byYear,
      sortedYears: sortedYears,
      itemBuilder: (context, episode) {
        final progress = episode.enclosureUrl != null
            ? progressMap[episode.enclosureUrl]
            : null;
        return EpisodeListTile(
          lastRefreshedAt: _lastRefreshedAt,
          key: ValueKey(episode.guid ?? episode.title),
          episode: episode,
          podcastTitle: podcast.name,
          artworkUrl: podcast.artworkUrl,
          feedImageUrl: _feedImageUrl,
          progress: progress,
        );
      },
      scrollController: _scrollController,
      yearGroupingEnabled: true,
      itemExtent: episodeCardExtent,
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildArtwork(colorScheme),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      podcast.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      podcast.artistName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (podcast.genres.isNotEmpty) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        podcast.genres.join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          _buildSubscribeButton(context, ref, theme),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    final subscriptionState = ref.watch(
      subscriptionControllerProvider(podcast.id),
    );

    return subscriptionState.when(
      data: (isSubscribed) {
        final l10n = AppLocalizations.of(context);
        if (isSubscribed) {
          return OutlinedButton.icon(
            onPressed: () => _toggleSubscription(ref),
            icon: const Icon(Icons.check),
            label: Text(l10n.podcastDetailSubscribed),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
            ),
          );
        }

        return FilledButton.icon(
          onPressed: podcast.feedUrl != null
              ? () => _toggleSubscription(ref)
              : null,
          icon: const Icon(Icons.add),
          label: Text(l10n.podcastDetailSubscribe),
        );
      },
      loading: () => FilledButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text(AppLocalizations.of(context).commonLoading),
      ),
      error: (error, stack) => FilledButton.icon(
        onPressed: () => _toggleSubscription(ref),
        icon: const Icon(Icons.refresh),
        label: Text(AppLocalizations.of(context).commonRetry),
      ),
    );
  }

  void _toggleSubscription(WidgetRef ref) {
    ref
        .read(subscriptionControllerProvider(podcast.id).notifier)
        .toggleSubscription(podcast);
  }

  Widget _buildArtwork(ColorScheme colorScheme) {
    final artworkUrl = podcast.artworkUrl;

    if (artworkUrl == null) {
      return Container(
        width: 100,
        height: 100,
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.podcasts,
          size: 48,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Image.network(
      artworkUrl,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: 100,
          height: 100,
          color: colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        width: 100,
        height: 100,
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.broken_image,
          size: 48,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return SliverFillRemaining(
      child: Center(
        child: Text(
          AppLocalizations.of(context).podcastDetailNoResults,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            l10n.podcastDetailNoMatchingEpisodes,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.podcastDetailTryDifferentFilter,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaylistState(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            l10n.podcastDetailNoEpisodes,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.podcastDetailPlaylistEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats a date range in Apple Podcasts style.
String? _formatDateRange(DateTime? earliest, DateTime? latest) {
  if (earliest == null || latest == null) return null;
  final now = DateTime.now();
  final bothCurrentYear = earliest.year == now.year && latest.year == now.year;
  final fmt = bothCurrentYear ? DateFormat('M/d') : DateFormat.yMMMd();
  if (earliest == latest) return fmt.format(earliest);
  return '${fmt.format(earliest)}\u301c${fmt.format(latest)}';
}

/// Formats duration in ms using localized strings.
String? _formatDuration(int? totalMs, AppLocalizations l10n) {
  if (totalMs == null || totalMs == 0) return null;
  final minutes = totalMs ~/ 60000;
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (0 < hours) {
    return l10n.groupDurationHoursMinutes(hours, remainingMinutes);
  }
  return l10n.groupDurationMinutes(minutes);
}

/// Sorts groups using the playlist's [customSort] rules and
/// the user's [sortOrder] toggle.
List<SmartPlaylistGroup> _sortGroupsByCustomSort(
  List<SmartPlaylistGroup> groups,
  SmartPlaylistSortSpec? customSort,
  SortOrder sortOrder,
) {
  final sorted = List<SmartPlaylistGroup>.from(groups);

  if (customSort == null || customSort.rules.isEmpty) {
    sorted.sort((a, b) {
      final cmp = a.sortKey.compareTo(b.sortKey);
      return sortOrder == SortOrder.ascending ? cmp : -cmp;
    });
    return sorted;
  }

  // When sortOrder matches the first rule's order, use rules as written.
  // Otherwise invert.
  final invert = sortOrder != customSort.rules.first.order;

  sorted.sort((a, b) {
    for (final rule in customSort.rules) {
      if (rule.condition != null) {
        final bothMatch =
            _matchesGroupCondition(a, rule.condition!) &&
            _matchesGroupCondition(b, rule.condition!);
        if (!bothMatch) continue;
      }

      final cmp = _compareGroupsByField(a, b, rule.field);
      if (cmp != 0) {
        final directed = rule.order == SortOrder.ascending ? cmp : -cmp;
        return invert ? -directed : directed;
      }
    }
    return 0;
  });
  return sorted;
}

int _compareGroupsByField(
  SmartPlaylistGroup a,
  SmartPlaylistGroup b,
  SmartPlaylistSortField field,
) {
  return switch (field) {
    SmartPlaylistSortField.playlistNumber => a.sortKey.compareTo(b.sortKey),
    SmartPlaylistSortField.newestEpisodeDate => _compareNullableDates(
      a.latestDate,
      b.latestDate,
    ),
    SmartPlaylistSortField.alphabetical => a.displayName.compareTo(
      b.displayName,
    ),
    SmartPlaylistSortField.progress => a.sortKey.compareTo(b.sortKey),
  };
}

int _compareNullableDates(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

bool _matchesGroupCondition(
  SmartPlaylistGroup group,
  SmartPlaylistSortCondition condition,
) {
  return switch (condition) {
    SortKeyGreaterThan(:final value) => value < group.sortKey,
  };
}

/// Card widget for displaying a smart playlist group inline.
class _InlineGroupCard extends StatelessWidget {
  const _InlineGroupCard({
    required this.group,
    required this.onTap,
    this.podcastArtworkUrl,
  });

  final SmartPlaylistGroup group;
  final VoidCallback onTap;
  final String? podcastArtworkUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final dateRange = group.showDateRange
        ? _formatDateRange(group.earliestDate, group.latestDate)
        : null;
    final duration = group.showDateRange
        ? _formatDuration(group.totalDurationMs, l10n)
        : null;

    final metaLine = StringBuffer(
      l10n.groupEpisodeCount(group.episodeIds.length),
    );
    if (duration != null) {
      metaLine.write('  $duration');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xxs,
      ),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                _buildThumbnail(colorScheme),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.displayName,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        metaLine.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (dateRange != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          dateRange,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _thumbnailSize = 56.0;

  Widget _buildThumbnail(ColorScheme colorScheme) {
    final url = group.thumbnailUrl ?? podcastArtworkUrl;
    if (url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ExtendedImage.network(
          url,
          width: _thumbnailSize,
          height: _thumbnailSize,
          fit: BoxFit.cover,
          cache: true,
          loadStateChanged: (state) {
            if (state.extendedImageLoadState == LoadState.failed) {
              return _buildPlaceholder(colorScheme);
            }
            return null;
          },
        ),
      );
    }
    return _buildPlaceholder(colorScheme);
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: _thumbnailSize,
      height: _thumbnailSize,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.folder_outlined,
        size: 24,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
