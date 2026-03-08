import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
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
  late SortOrder _sortOrder;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final parent = widget.parentPlaylist;
    if (parent.userSortable && parent.groupSort != null) {
      _sortOrder = parent.groupSort!.order;
    } else {
      _sortOrder = SortOrder.descending;
    }
  }

  List<int> get _episodeIds =>
      widget.filteredEpisodeIds ?? widget.group.episodeIds;

  bool get _showYearHeaders =>
      widget.parentPlaylist.yearBinding != YearBinding.none;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatGroupTitle() {
    return widget.group.formattedDisplayName(
      prependSeasonNumber: widget.parentPlaylist.prependSeasonNumber,
    );
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
      appBar: SearchableAppBar(
        title: Text(_formatGroupTitle()),
        onSearchChanged: (query) => setState(() => _searchQuery = query),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Text(
                widget.podcastTitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          ..._buildEpisodeList(theme),
        ],
      ),
    );
  }

  Widget _buildSortHeader(
    ThemeData theme, {
    required bool showSortSwitch,
    int? episodeCount,
  }) {
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Text(
          l10n.podcastDetailEpisodeCount(episodeCount ?? _episodeIds.length),
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
    );
  }

  List<Widget> _buildEpisodeList(ThemeData theme) {
    final episodesAsync = ref.watch(smartPlaylistEpisodesProvider(_episodeIds));

    return episodesAsync.when(
      data: (episodes) {
        final displayEpisodes = filterBySearchQuery(
          items: episodes,
          query: _searchQuery,
          getTitle: (e) => e.episode.title,
          getDescription: (e) => e.episode.description,
        );

        final sortHeaderSliver = SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: _buildSortHeader(
              theme,
              showSortSwitch:
                  _showYearHeaders || widget.parentPlaylist.userSortable,
              episodeCount: displayEpisodes.length,
            ),
          ),
        );

        if (displayEpisodes.isEmpty) {
          if (2 <= _searchQuery.length) {
            return [
              sortHeaderSliver,
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

        if (_showYearHeaders) {
          return [
            sortHeaderSliver,
            ..._buildYearGroupedSlivers(displayEpisodes, theme),
          ];
        }

        final sorted = _sortOrder == SortOrder.descending
            ? displayEpisodes.reversed.toList()
            : displayEpisodes;

        return [
          sortHeaderSliver,
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
                AppLocalizations.of(context).podcastDetailLoadError,
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
            AppLocalizations.of(context).podcastDetailNoEpisodes,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
