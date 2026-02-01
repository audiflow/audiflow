import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../widgets/smart_playlist_episode_list_tile.dart';

/// Screen showing episodes within a single smart playlist.
class SmartPlaylistEpisodesScreen extends ConsumerStatefulWidget {
  const SmartPlaylistEpisodesScreen({
    super.key,
    required this.smartPlaylist,
    required this.podcastTitle,
    required this.podcastArtworkUrl,
    this.feedImageUrl,
    this.lastRefreshedAt,
  });

  final SmartPlaylist smartPlaylist;
  final String podcastTitle;
  final String? podcastArtworkUrl;
  final String? feedImageUrl;
  final DateTime? lastRefreshedAt;

  @override
  ConsumerState<SmartPlaylistEpisodesScreen> createState() =>
      _SmartPlaylistEpisodesScreenState();
}

class _SmartPlaylistEpisodesScreenState
    extends ConsumerState<SmartPlaylistEpisodesScreen> {
  final _scrollController = ScrollController();
  final _subCategoryExpanded = <String, bool>{};
  SortOrder _sortOrder = SortOrder.descending;

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
      appBar: AppBar(
        title: Text(widget.smartPlaylist.displayName),
        actions: [
          IconButton(
            icon: Icon(
              _sortOrder == SortOrder.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            tooltip: _sortOrder == SortOrder.ascending
                ? 'Oldest first'
                : 'Newest first',
            onPressed: _toggleSortOrder,
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _SmartPlaylistHeader(
              smartPlaylist: widget.smartPlaylist,
              podcastTitle: widget.podcastTitle,
              podcastArtworkUrl: widget.podcastArtworkUrl,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Text(
                widget.smartPlaylist.contentType ==
                        SmartPlaylistContentType.groups
                    ? '${widget.smartPlaylist.groups?.length ?? 0}'
                          ' groups'
                    : '${widget.smartPlaylist.episodeCount}'
                          ' episodes',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          ..._buildEpisodeList(context, theme),
        ],
      ),
    );
  }

  List<Widget> _buildEpisodeList(BuildContext context, ThemeData theme) {
    if (widget.smartPlaylist.contentType == SmartPlaylistContentType.groups &&
        widget.smartPlaylist.groups != null) {
      return _buildGroupList(context, theme);
    }

    final episodesAsync = ref.watch(
      smartPlaylistEpisodesProvider(widget.smartPlaylist.episodeIds),
    );

    return episodesAsync.when(
      data: (episodes) {
        if (episodes.isEmpty) {
          return [SliverFillRemaining(child: _buildEmptyState(theme))];
        }

        if (widget.smartPlaylist.yearHeaderMode != YearHeaderMode.none) {
          return _buildYearGroupedSlivers(episodes, theme);
        }

        if (widget.smartPlaylist.groups != null &&
            widget.smartPlaylist.groups!.isNotEmpty) {
          return _buildSubCategorySlivers(episodes);
        }

        final sorted = _sortOrder == SortOrder.ascending
            ? episodes.reversed.toList()
            : episodes;

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
                siblingEpisodeIds: widget.smartPlaylist.episodeIds,
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
                      smartPlaylistEpisodesProvider(
                        widget.smartPlaylist.episodeIds,
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
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
    // Provider returns episodes sorted by episode number (asc) or publish
    // date (newest first). When displaying years descending, episodes within
    // each year should also be newest-first (reversed from number-asc order).
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
        siblingEpisodeIds: widget.smartPlaylist.episodeIds,
      ),
      scrollController: _scrollController,
      yearGroupingEnabled: true,
      itemExtent: episodeCardExtent,
    );
  }

  List<Widget> _buildSubCategorySlivers(
    List<SmartPlaylistEpisodeData> episodes,
  ) {
    final episodeById = <int, SmartPlaylistEpisodeData>{};
    for (final data in episodes) {
      episodeById[data.episode.id] = data;
    }

    final subCategoryData = <SubCategoryData<SmartPlaylistEpisodeData>>[];
    for (final sub in widget.smartPlaylist.groups!) {
      var items = [
        for (final id in sub.episodeIds)
          if (episodeById.containsKey(id))
            episodeById[id]!.withSiblingEpisodeIds(sub.episodeIds),
      ];
      if (_sortOrder == SortOrder.ascending) {
        items = items.reversed.toList();
      }

      Map<int, List<SmartPlaylistEpisodeData>>? byYear;
      List<int>? sortedYears;
      final isYearGrouped = sub.yearOverride != null;
      if (isYearGrouped) {
        byYear = <int, List<SmartPlaylistEpisodeData>>{};
        for (final data in items) {
          final year = data.episode.publishedAt?.year ?? 0;
          byYear.putIfAbsent(year, () => []).add(data);
        }
        sortedYears = byYear.keys.toList()
          ..sort(
            _sortOrder == SortOrder.descending
                ? (a, b) => b.compareTo(a)
                : (a, b) => a.compareTo(b),
          );
      }

      subCategoryData.add(
        SubCategoryData(
          id: sub.id,
          displayName: sub.displayName,
          items: items,
          yearGrouped: isYearGrouped,
          itemsByYear: byYear,
          sortedYears: sortedYears,
        ),
      );
    }

    return buildSubCategorySlivers<SmartPlaylistEpisodeData>(
      subCategories: subCategoryData,
      itemBuilder: (context, data) => SmartPlaylistEpisodeListTile(
        key: ValueKey(data.episode.id),
        episode: data.episode,
        podcastTitle: widget.podcastTitle,
        artworkUrl: widget.podcastArtworkUrl,
        feedImageUrl: widget.feedImageUrl,
        progress: data.progress,
        siblingEpisodeIds: data.siblingEpisodeIds,
      ),
      expandedState: _subCategoryExpanded,
      onToggle: (id) => setState(() {
        _subCategoryExpanded[id] = !(_subCategoryExpanded[id] ?? false);
      }),
      itemExtent: episodeCardExtent,
    );
  }

  List<Widget> _buildGroupList(BuildContext context, ThemeData theme) {
    final groups = widget.smartPlaylist.groups!;

    if (widget.smartPlaylist.yearHeaderMode == YearHeaderMode.none) {
      return [_buildFlatGroupSliver(groups, theme)];
    }

    // Need episodes to determine years for groups.
    final episodesAsync = ref.watch(
      smartPlaylistEpisodesProvider(widget.smartPlaylist.episodeIds),
    );

    return episodesAsync.when(
      data: (episodes) {
        final episodeMap = <int, SmartPlaylistEpisodeData>{};
        for (final ep in episodes) {
          episodeMap[ep.episode.id] = ep;
        }
        return _buildYearGroupedGroupList(groups, episodeMap, theme);
      },
      loading: () => [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
      error: (e, _) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Center(child: Text('Failed to load: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildFlatGroupSliver(
    List<SmartPlaylistGroup> groups,
    ThemeData theme,
  ) {
    final sorted = _sortOrder == SortOrder.ascending
        ? groups.reversed.toList()
        : groups;

    return SliverList.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final group = sorted[index];
        return _SmartPlaylistGroupCard(
          group: group,
          thumbnailUrl: group.thumbnailUrl,
          onTap: () => _navigateToGroup(group),
        );
      },
    );
  }

  List<Widget> _buildYearGroupedGroupList(
    List<SmartPlaylistGroup> groups,
    Map<int, SmartPlaylistEpisodeData> episodeMap,
    ThemeData theme,
  ) {
    final mode = widget.smartPlaylist.yearHeaderMode;

    if (mode == YearHeaderMode.firstEpisode) {
      return _buildFirstEpisodeYearGroups(groups, episodeMap, theme);
    }

    // perEpisode mode
    return _buildPerEpisodeYearGroups(groups, episodeMap, theme);
  }

  List<Widget> _buildFirstEpisodeYearGroups(
    List<SmartPlaylistGroup> groups,
    Map<int, SmartPlaylistEpisodeData> episodeMap,
    ThemeData theme,
  ) {
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

    final itemsByYear = <int, List<SmartPlaylistGroup>>{};
    for (final year in sortedYears) {
      itemsByYear[year] = byYear[year]!;
    }

    return buildYearGroupedSlivers<SmartPlaylistGroup>(
      itemsByYear: itemsByYear,
      sortedYears: sortedYears,
      itemBuilder: (context, group) => _SmartPlaylistGroupCard(
        group: group,
        thumbnailUrl: group.thumbnailUrl,
        onTap: () => _navigateToGroup(group),
      ),
      scrollController: _scrollController,
      yearGroupingEnabled: true,
      itemExtent: _groupCardExtent,
    );
  }

  List<Widget> _buildPerEpisodeYearGroups(
    List<SmartPlaylistGroup> groups,
    Map<int, SmartPlaylistEpisodeData> episodeMap,
    ThemeData theme,
  ) {
    final byYear = <int, List<(SmartPlaylistGroup, List<int>)>>{};
    for (final group in groups) {
      final yearIds = <int, List<int>>{};
      for (final id in group.episodeIds) {
        final ep = episodeMap[id];
        final year = ep?.episode.publishedAt?.year ?? 0;
        yearIds.putIfAbsent(year, () => []).add(id);
      }
      for (final entry in yearIds.entries) {
        byYear.putIfAbsent(entry.key, () => []).add((group, entry.value));
      }
    }

    final sortedYears = byYear.keys.toList()
      ..sort(
        _sortOrder == SortOrder.descending
            ? (a, b) => b.compareTo(a)
            : (a, b) => a.compareTo(b),
      );

    // Flatten into year-keyed group cards.
    final itemsByYear = <int, List<_YearFilteredGroup>>{};
    for (final year in sortedYears) {
      itemsByYear[year] = byYear[year]!
          .map(
            (pair) =>
                _YearFilteredGroup(group: pair.$1, filteredEpisodeIds: pair.$2),
          )
          .toList();
    }

    return buildYearGroupedSlivers<_YearFilteredGroup>(
      itemsByYear: itemsByYear,
      sortedYears: sortedYears,
      itemBuilder: (context, item) => _SmartPlaylistGroupCard(
        group: item.group,
        thumbnailUrl: item.group.thumbnailUrl,
        episodeCount: item.filteredEpisodeIds.length,
        onTap: () => _navigateToGroup(
          item.group,
          filteredEpisodeIds: item.filteredEpisodeIds,
        ),
      ),
      scrollController: _scrollController,
      yearGroupingEnabled: true,
      itemExtent: _groupCardExtent,
    );
  }

  void _navigateToGroup(
    SmartPlaylistGroup group, {
    List<int>? filteredEpisodeIds,
  }) {
    final uri = GoRouterState.of(context).uri;
    context.go(
      '$uri/${AppRoutes.smartPlaylistGroupEpisodesPath}'.replaceFirst(
        ':groupId',
        group.id,
      ),
      extra: <String, dynamic>{
        'group': group,
        'smartPlaylist': widget.smartPlaylist,
        'podcastTitle': widget.podcastTitle,
        'podcastArtworkUrl': widget.podcastArtworkUrl,
        'feedImageUrl': widget.feedImageUrl,
        'lastRefreshedAt': widget.lastRefreshedAt,
        'filteredEpisodeIds': filteredEpisodeIds,
      },
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

/// Height of a group card for fixed-extent lists.
const double _groupCardExtent = 96.0;

/// Helper for perEpisode year mode to carry filtered IDs.
class _YearFilteredGroup {
  const _YearFilteredGroup({
    required this.group,
    required this.filteredEpisodeIds,
  });

  final SmartPlaylistGroup group;
  final List<int> filteredEpisodeIds;
}

/// Card displaying a smart playlist group.
class _SmartPlaylistGroupCard extends StatelessWidget {
  const _SmartPlaylistGroupCard({
    required this.group,
    this.thumbnailUrl,
    this.episodeCount,
    this.onTap,
  });

  final SmartPlaylistGroup group;
  final String? thumbnailUrl;

  /// Override episode count (for perEpisode year mode).
  final int? episodeCount;
  final VoidCallback? onTap;

  static const _thumbnailSize = 72.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final count = episodeCount ?? group.episodeCount;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            _buildThumbnail(colorScheme),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    group.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    '$count episodes',
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
    );
  }

  Widget _buildThumbnail(ColorScheme colorScheme) {
    if (thumbnailUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ExtendedImage.network(
          thumbnailUrl!,
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
        size: 32,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
