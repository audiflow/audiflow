import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../utils/group_sorting.dart';
import '../widgets/smart_playlist_episode_list_tile.dart';

/// Screen showing episodes within a single smart playlist.
class SmartPlaylistEpisodesScreen extends ConsumerStatefulWidget {
  const SmartPlaylistEpisodesScreen({
    super.key,
    required this.podcast,
    required this.smartPlaylist,
    required this.podcastTitle,
    required this.podcastArtworkUrl,
    this.feedImageUrl,
    this.lastRefreshedAt,
  });

  final Podcast podcast;
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
  ScrollController? _fallbackScrollController;

  ScrollController get _scrollController =>
      PrimaryScrollController.maybeOf(context) ??
      (_fallbackScrollController ??= ScrollController());

  late SortOrder _sortOrder;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final sp = widget.smartPlaylist;
    _sortOrder =
        sp.episodeSort?.order ??
        (sp.userSortable && sp.groupSort != null
            ? sp.groupSort!.order
            : SortOrder.descending);
  }

  @override
  void dispose() {
    _fallbackScrollController?.dispose();
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

    return Scaffold(
      appBar: SearchableAppBar(
        title: Text(widget.smartPlaylist.formattedDisplayName),
        onSearchChanged: (query) => setState(() => _searchQuery = query),
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
          ..._buildEpisodeList(context, theme),
        ],
      ),
    );
  }

  bool get _showSortToggle =>
      widget.smartPlaylist.userSortable ||
      widget.smartPlaylist.yearBinding != YearBinding.none;

  Widget _buildSortHeader(ThemeData theme, {int? countOverride}) {
    final colorScheme = theme.colorScheme;
    final isGroups =
        widget.smartPlaylist.playlistStructure == PlaylistStructure.grouped;
    final count =
        countOverride ??
        (isGroups
            ? widget.smartPlaylist.groups?.length ?? 0
            : widget.smartPlaylist.episodeCount);
    final l10n = AppLocalizations.of(context);
    final label = isGroups
        ? l10n.podcastDetailGroupCount(count)
        : l10n.podcastDetailEpisodeCount(count);

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
          if (_showSortToggle) ...[
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
        ],
      ),
    );
  }

  List<Widget> _buildEpisodeList(BuildContext context, ThemeData theme) {
    if (widget.smartPlaylist.playlistStructure == PlaylistStructure.grouped &&
        widget.smartPlaylist.groups != null) {
      return _buildGroupList(context, theme);
    }

    final episodesAsync = ref.watch(
      smartPlaylistEpisodesProvider(widget.smartPlaylist.episodeIds),
    );

    return episodesAsync.when(
      data: (episodes) {
        final displayEpisodes = filterBySearchQuery(
          items: episodes,
          query: _searchQuery,
          getTitle: (e) => e.episode.title,
          getDescription: (e) => e.episode.description,
        );

        final sortHeader = SliverToBoxAdapter(
          child: _buildSortHeader(theme, countOverride: displayEpisodes.length),
        );

        if (displayEpisodes.isEmpty) {
          if (2 <= _searchQuery.length) {
            return [
              sortHeader,
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).podcastDetailNoResults,
                  ),
                ),
              ),
            ];
          }
          return [SliverFillRemaining(child: _buildEmptyState(theme))];
        }

        if (widget.smartPlaylist.yearBinding != YearBinding.none) {
          return [
            sortHeader,
            ..._buildYearGroupedSlivers(displayEpisodes, theme),
          ];
        }

        final effectiveRule = widget.smartPlaylist.episodeSort != null
            ? EpisodeSortRule(
                field: widget.smartPlaylist.episodeSort!.field,
                order: _sortOrder,
              )
            : EpisodeSortRule(
                field: EpisodeSortField.publishedAt,
                order: _sortOrder,
              );
        final sorted = List.of(displayEpisodes);
        sortEpisodeData(sorted, effectiveRule);

        return [
          sortHeader,
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
                itunesId: widget.podcast.id,
                feedUrl: widget.podcast.feedUrl,
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
                    AppLocalizations.of(context).podcastDetailLoadError,
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
                    label: Text(AppLocalizations.of(context).commonRetry),
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
        itunesId: widget.podcast.id,
        feedUrl: widget.podcast.feedUrl,
      ),
      scrollController: _scrollController,
      yearGroupingEnabled: true,
      itemExtent: episodeCardExtent,
    );
  }

  List<Widget> _buildGroupList(BuildContext context, ThemeData theme) {
    final allGroups = widget.smartPlaylist.groups!;
    final groups = filterBySearchQuery(
      items: allGroups,
      query: _searchQuery,
      getTitle: (g) => g.displayName,
    );

    final sortHeader = SliverToBoxAdapter(
      child: _buildSortHeader(theme, countOverride: groups.length),
    );

    if (groups.isEmpty && 2 <= _searchQuery.length) {
      return [
        sortHeader,
        SliverFillRemaining(
          child: Center(
            child: Text(AppLocalizations.of(context).podcastDetailNoResults),
          ),
        ),
      ];
    }

    if (widget.smartPlaylist.yearBinding == YearBinding.none) {
      return [sortHeader, _buildFlatGroupSliver(groups, theme)];
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
        return [
          sortHeader,
          ..._buildYearGroupedGroupList(groups, episodeMap, theme),
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
      error: (e, _) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Center(
              child: Text(
                AppLocalizations.of(
                  context,
                ).podcastDetailFailedToLoad(e.toString()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlatGroupSliver(
    List<SmartPlaylistGroup> groups,
    ThemeData theme,
  ) {
    final sorted = sortGroupsBySort(
      groups,
      widget.smartPlaylist.groupSort,
      _sortOrder,
    );

    final l10n = AppLocalizations.of(context);

    return SliverList.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final group = sorted[index];
        return _SmartPlaylistGroupCard(
          group: group,
          prependSeasonNumber: widget.smartPlaylist.prependSeasonNumber,
          thumbnailUrl: group.thumbnailUrl,
          dateRange: group.showDateRange
              ? _formatDateRange(group.earliestDate, group.latestDate)
              : null,
          totalDuration: group.showDateRange
              ? _formatDuration(group.totalDurationMs, l10n)
              : null,
          l10n: l10n,
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
    final defaultMode = widget.smartPlaylist.yearBinding;

    // Check if any group has a per-group yearOverride that
    // differs from the playlist-level default.
    final hasMixedModes = groups.any(
      (g) => g.yearOverride != null && g.yearOverride != defaultMode,
    );

    if (!hasMixedModes) {
      // All groups use the same mode.
      if (defaultMode == YearBinding.pinToYear) {
        return _buildFirstEpisodeYearGroups(groups, episodeMap, theme);
      }
      return _buildPerEpisodeYearGroups(groups, episodeMap, theme);
    }

    // Mixed modes: partition groups by their effective
    // yearBinding and merge results.
    return _buildMixedYearGroups(groups, episodeMap, theme, defaultMode);
  }

  List<Widget> _buildMixedYearGroups(
    List<SmartPlaylistGroup> groups,
    Map<int, SmartPlaylistEpisodeData> episodeMap,
    ThemeData theme,
    YearBinding defaultMode,
  ) {
    // Build a year-keyed map of items, handling each group
    // according to its effective yearBinding.
    final byYear = <int, List<_YearFilteredGroup>>{};

    for (final group in groups) {
      final mode = group.yearOverride ?? defaultMode;

      if (mode == YearBinding.splitByYear) {
        // Split: group appears under each year it has
        // episodes in.
        final yearIds = <int, List<int>>{};
        for (final id in group.episodeIds) {
          final ep = episodeMap[id];
          final year = ep?.episode.publishedAt?.year ?? 0;
          yearIds.putIfAbsent(year, () => []).add(id);
        }
        for (final entry in yearIds.entries) {
          byYear
              .putIfAbsent(entry.key, () => [])
              .add(
                _YearFilteredGroup(
                  group: group,
                  filteredEpisodeIds: entry.value,
                ),
              );
        }
      } else {
        // pinToYear: group appears once under first
        // episode's year.
        var year = 0;
        if (group.episodeIds.isNotEmpty) {
          final firstId = group.episodeIds.first;
          final ep = episodeMap[firstId];
          year = ep?.episode.publishedAt?.year ?? 0;
        }
        byYear
            .putIfAbsent(year, () => [])
            .add(
              _YearFilteredGroup(
                group: group,
                filteredEpisodeIds: group.episodeIds,
              ),
            );
      }
    }

    final sortedYears = byYear.keys.toList()
      ..sort(
        _sortOrder == SortOrder.descending
            ? (a, b) => b.compareTo(a)
            : (a, b) => a.compareTo(b),
      );

    final l10n = AppLocalizations.of(context);

    return buildYearGroupedSlivers<_YearFilteredGroup>(
      itemsByYear: byYear,
      sortedYears: sortedYears,
      itemBuilder: (context, item) => _SmartPlaylistGroupCard(
        group: item.group,
        prependSeasonNumber: widget.smartPlaylist.prependSeasonNumber,
        thumbnailUrl: item.group.thumbnailUrl,
        episodeCount: item.filteredEpisodeIds.length,
        dateRange: item.group.showDateRange
            ? _formatDateRange(item.group.earliestDate, item.group.latestDate)
            : null,
        totalDuration: item.group.showDateRange
            ? _formatDuration(item.group.totalDurationMs, l10n)
            : null,
        l10n: l10n,
        onTap: () => _navigateToGroup(
          item.group,
          filteredEpisodeIds:
              item.filteredEpisodeIds.length != item.group.episodeIds.length
              ? item.filteredEpisodeIds
              : null,
        ),
      ),
      scrollController: _scrollController,
      yearGroupingEnabled: true,
      itemExtent: _groupCardExtent,
    );
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

    final l10n = AppLocalizations.of(context);

    return buildYearGroupedSlivers<SmartPlaylistGroup>(
      itemsByYear: itemsByYear,
      sortedYears: sortedYears,
      itemBuilder: (context, group) => _SmartPlaylistGroupCard(
        group: group,
        prependSeasonNumber: widget.smartPlaylist.prependSeasonNumber,
        thumbnailUrl: group.thumbnailUrl,
        dateRange: group.showDateRange
            ? _formatDateRange(group.earliestDate, group.latestDate)
            : null,
        totalDuration: group.showDateRange
            ? _formatDuration(group.totalDurationMs, l10n)
            : null,
        l10n: l10n,
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

    final l10n = AppLocalizations.of(context);

    return buildYearGroupedSlivers<_YearFilteredGroup>(
      itemsByYear: itemsByYear,
      sortedYears: sortedYears,
      itemBuilder: (context, item) => _SmartPlaylistGroupCard(
        group: item.group,
        prependSeasonNumber: widget.smartPlaylist.prependSeasonNumber,
        thumbnailUrl: item.group.thumbnailUrl,
        episodeCount: item.filteredEpisodeIds.length,
        dateRange: item.group.showDateRange
            ? _formatDateRange(item.group.earliestDate, item.group.latestDate)
            : null,
        totalDuration: item.group.showDateRange
            ? _formatDuration(item.group.totalDurationMs, l10n)
            : null,
        l10n: l10n,
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
        'podcast': widget.podcast,
        'group': group,
        'smartPlaylist': widget.smartPlaylist,
        'podcastTitle': widget.podcastTitle,
        'podcastArtworkUrl': widget.podcastArtworkUrl,
        'feedImageUrl': widget.feedImageUrl,
        'lastRefreshedAt': widget.lastRefreshedAt,
        'filteredEpisodeIds': filteredEpisodeIds,
        'itunesId': widget.podcast.id,
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
      return ExtendedImage.network(
        podcastArtworkUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        cache: true,
        loadStateChanged: (state) {
          if (state.extendedImageLoadState == LoadState.failed) {
            return _buildPlaceholder(colorScheme);
          }
          return null;
        },
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

/// Formats a date range in Apple Podcasts style.
///
/// Same year as now: compact "M/d" format (locale-aware).
/// Different year: full "yMMMd" format (locale-aware).
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
    this.prependSeasonNumber = false,
    this.thumbnailUrl,
    this.episodeCount,
    this.dateRange,
    this.totalDuration,
    this.l10n,
    this.onTap,
  });

  final SmartPlaylistGroup group;

  /// Whether to prepend "S{sortKey}" to the group title.
  final bool prependSeasonNumber;

  final String? thumbnailUrl;

  /// Override episode count (for perEpisode year mode).
  final int? episodeCount;

  /// Date range string (e.g. "10/30~12/18").
  final String? dateRange;

  /// Total duration string (e.g. "1h18m").
  final String? totalDuration;

  /// Localizations for episode count/duration formatting.
  final AppLocalizations? l10n;
  final VoidCallback? onTap;

  static const _thumbnailSize = 72.0;

  String _formatTitle() {
    return group.formattedDisplayName(prependSeasonNumber: prependSeasonNumber);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final count = episodeCount ?? group.episodeCount;
    final resolvedL10n = l10n ?? AppLocalizations.of(context);

    final metaLine = StringBuffer(resolvedL10n.groupEpisodeCount(count));
    if (totalDuration != null) {
      metaLine.write('  $totalDuration');
    }

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
                    _formatTitle(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                      dateRange!,
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
