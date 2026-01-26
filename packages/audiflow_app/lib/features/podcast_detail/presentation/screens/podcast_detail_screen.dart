import 'package:audiflow_domain/audiflow_domain.dart' show Season;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import '../controllers/podcast_detail_controller.dart';
import '../controllers/podcast_view_mode_controller.dart';
import '../controllers/season_sort_controller.dart';
import '../widgets/episode_filter_chips.dart';
import '../widgets/episode_list_tile.dart';
import '../widgets/season_grid.dart';
import '../widgets/season_sort_sheet.dart';
import '../widgets/season_view_toggle.dart';

/// Displays podcast details and episode list with playback controls.
///
/// Receives a [Podcast] via route extra and fetches episodes from its feedUrl.
/// Shows podcast artwork, name, artist, and subscribe button at the top,
/// followed by filter chips and a scrollable list of episodes with play/pause
/// buttons.
class PodcastDetailScreen extends ConsumerWidget {
  const PodcastDetailScreen({super.key, required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get view mode to determine if sort button should be shown
    final viewMode = ref.watch(podcastViewModeControllerProvider(podcast.id));
    final showSortButton = viewMode == PodcastViewMode.seasons;

    return Scaffold(
      appBar: AppBar(
        title: Text(podcast.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (showSortButton)
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort seasons',
              onPressed: () => _showSortSheet(context, ref),
            ),
        ],
      ),
      body: _buildBody(context, ref, theme, colorScheme),
    );
  }

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    final sortConfig = ref.read(seasonSortControllerProvider(podcast.id));
    showSeasonSortSheet(
      context: context,
      currentConfig: sortConfig,
      onSortSelected: (field, order) {
        ref
            .read(seasonSortControllerProvider(podcast.id).notifier)
            .setSort(field, order);
      },
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
    final filter = ref.watch(episodeFilterStateProvider);
    final filteredAsync = ref.watch(filteredEpisodesProvider(feedUrl, filter));

    // Batch-fetch all episode progress in a single query
    final progressMapAsync = ref.watch(podcastEpisodeProgressProvider(feedUrl));

    // View mode state
    final viewMode = ref.watch(podcastViewModeControllerProvider(podcast.id));

    // Check if season view is available for this podcast
    // Uses hasSeasonViewAfterLoadProvider to ensure episodes are persisted first
    final hasSeasonsAsync = ref.watch(hasSeasonViewAfterLoadProvider(feedUrl));
    final hasSeasons = hasSeasonsAsync.value ?? false;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(podcastDetailProvider(feedUrl));
        ref.invalidate(podcastEpisodeProgressProvider(feedUrl));
        await ref.read(podcastDetailProvider(feedUrl).future);
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, ref, theme)),
          // Show view mode toggle only when seasons are available
          if (hasSeasons)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                child: SeasonViewToggle(
                  selected: viewMode,
                  onChanged: (mode) => ref
                      .read(
                        podcastViewModeControllerProvider(podcast.id).notifier,
                      )
                      .toggle(),
                ),
              ),
            ),
          // Show filter chips only in episodes view
          if (viewMode == PodcastViewMode.episodes)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: EpisodeFilterChips(
                  selected: filter,
                  onSelected: (f) => ref
                      .read(episodeFilterStateProvider.notifier)
                      .setFilter(f),
                ),
              ),
            ),
          // Content based on view mode
          if (viewMode == PodcastViewMode.episodes)
            _buildEpisodeList(filteredAsync, progressMapAsync, theme)
          else
            _buildSeasonView(context, ref, feedUrl),
        ],
      ),
    );
  }

  Widget _buildSeasonView(BuildContext context, WidgetRef ref, String feedUrl) {
    final seasonsAsync = ref.watch(
      sortedPodcastSeasonsProvider(feedUrl, podcast.id),
    );

    return seasonsAsync.when(
      data: (grouping) {
        if (grouping == null) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Spacing.lg),
              child: Center(child: Text('No seasons available')),
            ),
          );
        }

        return SeasonGrid(
          seasons: grouping.seasons,
          ungroupedEpisodeIds: grouping.ungroupedEpisodeIds,
          onSeasonTap: (season) => _navigateToSeasonEpisodes(context, season),
          onUngroupedTap: () => _navigateToSeasonEpisodes(
            context,
            Season(
              id: 'ungrouped',
              displayName: 'Ungrouped',
              sortKey: 999999,
              episodeIds: grouping.ungroupedEpisodeIds,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(Spacing.lg),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Center(child: Text('Error loading seasons: $error')),
        ),
      ),
    );
  }

  void _navigateToSeasonEpisodes(BuildContext context, Season season) {
    final currentPath = GoRouterState.of(context).uri.path;
    context.push(
      '$currentPath/${AppRoutes.seasonEpisodes}'.replaceAll(
        ':seasonId',
        season.id,
      ),
      extra: {
        'season': season,
        'podcastTitle': podcast.name,
        'podcastArtworkUrl': podcast.artworkUrl,
      },
    );
  }

  Widget _buildEpisodeList(
    AsyncValue<List<dynamic>> episodesAsync,
    AsyncValue<EpisodeProgressMap> progressMapAsync,
    ThemeData theme,
  ) {
    return episodesAsync.when(
      data: (episodes) {
        if (episodes.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyFilterState(theme));
        }

        // Use progress map if available, otherwise empty map
        final progressMap = progressMapAsync.value ?? {};

        return SliverList.builder(
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            final episode = episodes[index];
            // Look up pre-fetched progress by audioUrl
            final progress = episode.enclosureUrl != null
                ? progressMap[episode.enclosureUrl]
                : null;

            return EpisodeListTile(
              key: ValueKey(episode.guid ?? index),
              episode: episode,
              podcastTitle: podcast.name,
              artworkUrl: podcast.artworkUrl,
              progress: progress,
            );
          },
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(Spacing.lg),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Text('Error loading episodes: $error'),
        ),
      ),
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
}
