import 'package:audiflow_domain/audiflow_domain.dart'
    show
        EpisodeFilter,
        PodcastItem,
        PodcastViewMode,
        SmartPlaylist,
        SmartPlaylistContentType,
        SmartPlaylistEpisodeData,
        SmartPlaylistGroup,
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
      appBar: AppBar(
        title: Text(podcast.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: const [],
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
              'Feed URL not available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'This podcast does not have a feed URL',
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
              'Failed to load episodes',
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
              label: const Text('Retry'),
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
          displayName: 'Ungrouped',
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

        if (playlist.yearHeaderMode != YearHeaderMode.none) {
          return _buildYearGroupedPlaylistSlivers(
            episodes,
            playlist,
            theme,
            sortOrder,
          );
        }

        final sorted = sortOrder == SortOrder.ascending
            ? episodes.reversed.toList()
            : episodes;

        return [
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
            child: Center(child: Text('Error loading episodes: $error')),
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
                        ? 'Oldest first'
                        : 'Newest first',
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
    final episodeMap = <int, SmartPlaylistEpisodeData>{};
    for (final ep in episodes) {
      episodeMap[ep.episode.id] = ep;
    }

    if (playlist.yearHeaderMode == YearHeaderMode.none) {
      return [
        SliverList.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
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
    for (final group in groups) {
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
        child: _buildSortHeader(theme, '${groups.length} groups', sortOrder),
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
    final pattern = ref.watch(smartPlaylistPatternByFeedUrlProvider(feedUrl));
    final yearGrouped = pattern?.yearGroupedEpisodes ?? false;

    return episodesAsync.when(
      data: (episodes) {
        if (episodes.isEmpty) {
          return [SliverFillRemaining(child: _buildEmptyFilterState(theme))];
        }

        final progressMap = progressMapAsync.value ?? {};
        final sortHeader = SliverToBoxAdapter(
          child: _buildSortHeader(
            theme,
            '${episodes.length} episodes',
            sortOrder,
          ),
        );

        if (yearGrouped) {
          return [
            sortHeader,
            ..._buildYearGroupedEpisodeSlivers(
              episodes,
              progressMap,
              theme,
              sortOrder,
            ),
          ];
        }

        return [
          sortHeader,
          SliverList.builder(
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
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
            child: Text('Error loading episodes: $error'),
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
        if (isSubscribed) {
          return OutlinedButton.icon(
            onPressed: () => _toggleSubscription(ref),
            icon: const Icon(Icons.check),
            label: const Text('Subscribed'),
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
          label: const Text('Subscribe'),
        );
      },
      loading: () => FilledButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: const Text('Loading...'),
      ),
      error: (error, stack) => FilledButton.icon(
        onPressed: () => _toggleSubscription(ref),
        icon: const Icon(Icons.refresh),
        label: const Text('Retry'),
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

  Widget _buildEmptyFilterState(ThemeData theme) {
    final colorScheme = theme.colorScheme;

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
            'No matching episodes',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Try a different filter',
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
            'No episodes found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'This playlist has no episodes',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats a date range as "YYYY.M.D 〜 YYYY.M.D".
String? _formatDateRange(DateTime? earliest, DateTime? latest) {
  if (earliest == null || latest == null) return null;
  String fmt(DateTime d) => '${d.year}.${d.month}.${d.day}';
  if (earliest == latest) return fmt(earliest);
  return '${fmt(earliest)} 〜 ${fmt(latest)}';
}

/// Formats duration in ms to "Xh Ym" or "Xm".
String? _formatDuration(int? totalMs) {
  if (totalMs == null || totalMs == 0) return null;
  final minutes = totalMs ~/ 60000;
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (0 < hours) return '${hours}h${remainingMinutes}m';
  return '${minutes}m';
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
    final dateRange = _formatDateRange(group.earliestDate, group.latestDate);
    final duration = _formatDuration(group.totalDurationMs);

    final metaLine = StringBuffer('${group.episodeIds.length} episodes');
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
                      if (dateRange != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          dateRange,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        metaLine.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
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
