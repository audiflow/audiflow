import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/smart_playlist_episode_list_tile.dart';

/// Screen showing episodes within a smart playlist group.
class SmartPlaylistGroupEpisodesScreen extends ConsumerStatefulWidget {
  const SmartPlaylistGroupEpisodesScreen({
    super.key,
    required this.group,
    required this.parentPlaylist,
    required this.podcastTitle,
    required this.podcastArtworkUrl,
    this.feedImageUrl,
    this.lastRefreshedAt,
    this.filteredEpisodeIds,
  });

  final SmartPlaylistGroup group;
  final SmartPlaylist parentPlaylist;
  final String podcastTitle;
  final String? podcastArtworkUrl;
  final String? feedImageUrl;
  final DateTime? lastRefreshedAt;

  /// When perEpisode year mode, only these IDs shown.
  final List<int>? filteredEpisodeIds;

  @override
  ConsumerState<SmartPlaylistGroupEpisodesScreen> createState() =>
      _SmartPlaylistGroupEpisodesScreenState();
}

class _SmartPlaylistGroupEpisodesScreenState
    extends ConsumerState<SmartPlaylistGroupEpisodesScreen> {
  final _scrollController = ScrollController();
  SortOrder _sortOrder = SortOrder.descending;

  List<int> get _episodeIds =>
      widget.filteredEpisodeIds ?? widget.group.episodeIds;

  bool get _showYearHeaders =>
      widget.group.episodeYearHeaders ??
      widget.parentPlaylist.episodeYearHeaders;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == SortOrder.descending
          ? SortOrder.ascending
          : SortOrder.descending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.group.displayName)),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.podcastTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  _buildSortHeader(theme, showSortSwitch: _showYearHeaders),
                ],
              ),
            ),
          ),
          ..._buildEpisodeList(theme),
        ],
      ),
    );
  }

  Widget _buildSortHeader(ThemeData theme, {required bool showSortSwitch}) {
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Text(
          '${_episodeIds.length} episodes',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (showSortSwitch) ...[
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
                    _sortOrder == SortOrder.ascending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortOrder == SortOrder.ascending
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
      ],
    );
  }

  List<Widget> _buildEpisodeList(ThemeData theme) {
    final episodesAsync = ref.watch(smartPlaylistEpisodesProvider(_episodeIds));

    return episodesAsync.when(
      data: (episodes) {
        if (episodes.isEmpty) {
          return [SliverFillRemaining(child: _buildEmptyState(theme))];
        }

        if (_showYearHeaders) {
          return _buildYearGroupedSlivers(episodes, theme);
        }

        // No year headers: always ascending (oldest first)
        final sorted = episodes;

        return [
          SliverList.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final data = sorted[index];
              return SmartPlaylistEpisodeListTile(
                key: ValueKey(data.episode.id),
                episode: data.episode,
                podcastTitle: widget.podcastTitle,
                artworkUrl: widget.podcastArtworkUrl,
                feedImageUrl: widget.feedImageUrl,
                lastRefreshedAt: widget.lastRefreshedAt,
                progress: data.progress,
                siblingEpisodeIds: _episodeIds,
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
                'Failed to load episodes',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildYearGroupedSlivers(
    List<SmartPlaylistEpisodeData> episodes,
    ThemeData theme,
  ) {
    final byYear = <int, List<SmartPlaylistEpisodeData>>{};
    for (final data in episodes) {
      final year = data.episode.publishedAt?.year ?? 0;
      byYear.putIfAbsent(year, () => []).add(data);
    }

    if (_sortOrder == SortOrder.descending) {
      for (final key in byYear.keys) {
        byYear[key] = byYear[key]!.reversed.toList();
      }
    }

    final sortedYears = byYear.keys.toList()
      ..sort(
        _sortOrder == SortOrder.descending
            ? (a, b) => b.compareTo(a)
            : (a, b) => a.compareTo(b),
      );

    return buildYearGroupedSlivers<SmartPlaylistEpisodeData>(
      itemsByYear: byYear,
      sortedYears: sortedYears,
      itemBuilder: (context, data) => SmartPlaylistEpisodeListTile(
        key: ValueKey(data.episode.id),
        episode: data.episode,
        podcastTitle: widget.podcastTitle,
        artworkUrl: widget.podcastArtworkUrl,
        feedImageUrl: widget.feedImageUrl,
        progress: data.progress,
        siblingEpisodeIds: _episodeIds,
      ),
      scrollController: _scrollController,
      yearGroupingEnabled: true,
      itemExtent: episodeCardExtent,
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
        ],
      ),
    );
  }
}
