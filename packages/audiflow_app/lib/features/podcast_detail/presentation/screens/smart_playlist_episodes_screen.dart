import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/smart_playlist_episode_list_tile.dart';

/// Screen showing episodes within a single smart playlist.
class SmartPlaylistEpisodesScreen extends ConsumerWidget {
  const SmartPlaylistEpisodesScreen({
    super.key,
    required this.smartPlaylist,
    required this.podcastTitle,
    required this.podcastArtworkUrl,
  });

  final SmartPlaylist smartPlaylist;
  final String podcastTitle;
  final String? podcastArtworkUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(smartPlaylist.displayName)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _SmartPlaylistHeader(
              smartPlaylist: smartPlaylist,
              podcastTitle: podcastTitle,
              podcastArtworkUrl: podcastArtworkUrl,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Text(
                '${smartPlaylist.episodeCount} episodes',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          _buildEpisodeList(context, ref, theme),
        ],
      ),
    );
  }

  Widget _buildEpisodeList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final episodesAsync = ref.watch(
      smartPlaylistEpisodesProvider(smartPlaylist.episodeIds),
    );

    return episodesAsync.when(
      data: (episodes) {
        if (episodes.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyState(theme));
        }

        if (smartPlaylist.yearGrouped) {
          return _buildYearGroupedList(episodes, theme);
        }

        if (smartPlaylist.subCategories != null &&
            smartPlaylist.subCategories!.isNotEmpty) {
          return _buildSubCategoryList(ref, episodes, theme);
        }

        return SliverList.builder(
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            final data = episodes[index];
            return SmartPlaylistEpisodeListTile(
              key: ValueKey(data.episode.id),
              episode: data.episode,
              podcastTitle: podcastTitle,
              artworkUrl: podcastArtworkUrl,
              progress: data.progress,
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
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error.withValues(alpha: 0.7),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'Failed to load episodes',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.md),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(
                    smartPlaylistEpisodesProvider(smartPlaylist.episodeIds),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearGroupedList(
    List<SmartPlaylistEpisodeData> episodes,
    ThemeData theme,
  ) {
    final byYear = <int, List<SmartPlaylistEpisodeData>>{};
    for (final data in episodes) {
      final year = data.episode.publishedAt?.year ?? 0;
      byYear.putIfAbsent(year, () => []).add(data);
    }
    final sortedYears = byYear.keys.toList()..sort((a, b) => b.compareTo(a));
    final currentYear = DateTime.now().year;

    return SliverList(
      delegate: SliverChildListDelegate([
        for (final year in sortedYears)
          ExpansionTile(
            key: PageStorageKey('year_$year'),
            title: Text(
              year == 0 ? 'Unknown' : '$year',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            initiallyExpanded: year == currentYear,
            children: [
              for (final data in byYear[year]!)
                SmartPlaylistEpisodeListTile(
                  key: ValueKey(data.episode.id),
                  episode: data.episode,
                  podcastTitle: podcastTitle,
                  artworkUrl: podcastArtworkUrl,
                  progress: data.progress,
                ),
            ],
          ),
      ]),
    );
  }

  Widget _buildSubCategoryList(
    WidgetRef ref,
    List<SmartPlaylistEpisodeData> episodes,
    ThemeData theme,
  ) {
    final subCategories = smartPlaylist.subCategories!;
    final episodeById = <int, SmartPlaylistEpisodeData>{};
    for (final data in episodes) {
      episodeById[data.episode.id] = data;
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        for (final subCategory in subCategories)
          ExpansionTile(
            key: PageStorageKey('sub_${subCategory.id}'),
            title: Text(
              subCategory.displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${subCategory.episodeIds.length} episodes',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            initiallyExpanded: true,
            children: [
              for (final id in subCategory.episodeIds)
                if (episodeById.containsKey(id))
                  SmartPlaylistEpisodeListTile(
                    key: ValueKey(id),
                    episode: episodeById[id]!.episode,
                    podcastTitle: podcastTitle,
                    artworkUrl: podcastArtworkUrl,
                    progress: episodeById[id]!.progress,
                  ),
            ],
          ),
      ]),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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

class _SmartPlaylistHeader extends StatelessWidget {
  const _SmartPlaylistHeader({
    required this.smartPlaylist,
    required this.podcastTitle,
    required this.podcastArtworkUrl,
  });

  final SmartPlaylist smartPlaylist;
  final String podcastTitle;
  final String? podcastArtworkUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
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
                  smartPlaylist.displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  podcastTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(ColorScheme colorScheme) {
    if (podcastArtworkUrl != null) {
      return Image.network(
        podcastArtworkUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(colorScheme),
      );
    }
    return _buildPlaceholder(colorScheme);
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: 80,
      height: 80,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.folder_outlined,
        size: 40,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
