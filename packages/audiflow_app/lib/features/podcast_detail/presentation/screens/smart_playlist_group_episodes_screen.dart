import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../download/presentation/helpers/batch_download_action_helper.dart';
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
    this.itunesId,
    this.feedUrl,
  });

  final SmartPlaylistGroup group;
  final SmartPlaylist parentPlaylist;
  final String podcastTitle;
  final String? podcastArtworkUrl;
  final String? feedImageUrl;
  final DateTime? lastRefreshedAt;

  /// When perEpisode year mode, only these IDs shown.
  final List<int>? filteredEpisodeIds;

  /// iTunes ID for building universal share links.
  final String? itunesId;

  /// Feed URL for invalidating batch progress after changes.
  final String? feedUrl;

  @override
  ConsumerState<SmartPlaylistGroupEpisodesScreen> createState() =>
      _SmartPlaylistGroupEpisodesScreenState();
}

class _SmartPlaylistGroupEpisodesScreenState
    extends ConsumerState<SmartPlaylistGroupEpisodesScreen> {
  ScrollController? _fallbackScrollController;

  ScrollController get _scrollController =>
      PrimaryScrollController.maybeOf(context) ??
      (_fallbackScrollController ??= ScrollController());

  late SortOrder _sortOrder;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    final groupSort =
        widget.group.episodeSort ?? widget.parentPlaylist.episodeSort;
    _sortOrder =
        groupSort?.order ??
        (widget.parentPlaylist.userSortable &&
                widget.parentPlaylist.groupSort != null
            ? widget.parentPlaylist.groupSort!.order
            : SortOrder.descending);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _fallbackScrollController?.dispose();
    super.dispose();
  }

  List<int> get _episodeIds =>
      widget.filteredEpisodeIds ?? widget.group.episodeIds;

  /// Effective year binding for this group.
  ///
  /// Per-group yearOverride takes precedence over the parent playlist's
  /// yearBinding. Used to decide whether year headers should be shown.
  YearBinding get _yearBinding =>
      widget.group.yearOverride ?? widget.parentPlaylist.yearBinding;

  bool get _showYearHeaders {
    // If yearBinding is active, year headers are implied.
    if (_yearBinding != YearBinding.none) return true;
    // Per-group showYearHeaders override takes precedence, then fall
    // back to the parent playlist's definition-level setting.
    final groupOverride = widget.group.showYearHeaders;
    if (groupOverride != null) return groupOverride;
    return widget.parentPlaylist.showYearHeaders;
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

  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() => _searchQuery = text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final allTasksAsync = ref.watch(allDownloadsProvider);

    final dlState = computeBatchDownloadState(
      episodeIds: _episodeIds,
      allTasks: allTasksAsync.value ?? [],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatGroupTitle()),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'download_all':
                  if (dlState.hasDownloadable) {
                    unawaited(
                      handleBatchDownload(
                        context: context,
                        ref: ref,
                        episodeIds: _episodeIds,
                      ),
                    );
                  }
                case 'cancel_all':
                  unawaited(
                    handleBatchCancel(
                      context: context,
                      ref: ref,
                      episodeIds: _episodeIds,
                    ),
                  );
                case 'resume_all':
                  unawaited(
                    handleBatchResume(
                      context: context,
                      ref: ref,
                      episodeIds: _episodeIds,
                    ),
                  );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: dlState.hasDownloadable,
                value: 'download_all',
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(l10n.downloadAllEpisodes),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (dlState.hasActive)
                PopupMenuItem(
                  value: 'cancel_all',
                  child: ListTile(
                    leading: const Icon(Icons.cancel_outlined),
                    title: Text(l10n.downloadCancelAll),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (dlState.hasPaused)
                PopupMenuItem(
                  value: 'resume_all',
                  child: ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: Text(l10n.downloadResumeAll),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: _buildBody(theme),
      ),
    );
  }

  List<Widget> _buildBody(ThemeData theme) {
    final episodesAsync = ref.watch(smartPlaylistEpisodesProvider(_episodeIds));

    // Resolve shared thumbnail from episodes. Non-null when the group
    // has a single episode, or when the first two episodes share the
    // same image (indicating ALL episodes likely use the same thumbnail).
    final sharedThumbnailUrl = episodesAsync
        .whenData(_resolveSharedThumbnail)
        .value;

    // Header shows group.thumbnailUrl or the shared thumbnail.
    final headerThumbnailUrl = widget.group.thumbnailUrl ?? sharedThumbnailUrl;

    // Dedup only uses the shared thumbnail (never group.thumbnailUrl,
    // which may match only one episode and hide just that one).
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: MaterialLocalizations.of(context).searchFieldLabel,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, child) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _searchDebounce?.cancel();
                      setState(() => _searchQuery = '');
                    },
                  );
                },
              ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: _GroupHeader(
          title: _formatGroupTitle(),
          podcastTitle: widget.podcastTitle,
          thumbnailUrl: headerThumbnailUrl,
        ),
      ),
      ..._buildEpisodeList(theme, headerThumbnailUrl: sharedThumbnailUrl),
    ];
  }

  /// Returns the first episode's imageUrl when the group has a single
  /// episode or when it matches the second episode's (indicating a shared
  /// series thumbnail). Returns null when images differ to avoid hiding
  /// only the first episode's thumbnail.
  String? _resolveSharedThumbnail(List<SmartPlaylistEpisodeData> episodes) {
    if (episodes.isEmpty) return null;
    final firstUrl = episodes.first.episode.imageUrl;
    if (firstUrl == null) return null;
    if (episodes.length < 2) return firstUrl;
    return firstUrl == episodes[1].episode.imageUrl ? firstUrl : null;
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

  List<Widget> _buildEpisodeList(
    ThemeData theme, {
    String? headerThumbnailUrl,
  }) {
    final episodesAsync = ref.watch(smartPlaylistEpisodesProvider(_episodeIds));

    final effectiveFeedImageUrl = headerThumbnailUrl ?? widget.feedImageUrl;

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
            ..._buildYearGroupedSlivers(
              displayEpisodes,
              theme,
              feedImageUrl: effectiveFeedImageUrl,
            ),
          ];
        }

        final effectiveSort =
            widget.group.episodeSort ?? widget.parentPlaylist.episodeSort;
        final effectiveRule = EpisodeSortRule(
          field: effectiveSort?.field ?? EpisodeSortField.publishedAt,
          order: _sortOrder,
        );
        final sorted = List.of(displayEpisodes);
        sortEpisodeData(sorted, effectiveRule);

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
                feedImageUrl: effectiveFeedImageUrl,
                lastRefreshedAt: widget.lastRefreshedAt,
                progress: data.progress,
                siblingEpisodeIds: _episodeIds,
                itunesId: widget.itunesId,
                feedUrl: widget.feedUrl,
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
    ThemeData theme, {
    String? feedImageUrl,
  }) {
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
        feedImageUrl: feedImageUrl,
        progress: data.progress,
        siblingEpisodeIds: _episodeIds,
        itunesId: widget.itunesId,
        feedUrl: widget.feedUrl,
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

/// Header with artwork + title, mirroring podcast detail layout.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.title,
    required this.podcastTitle,
    this.thumbnailUrl,
  });

  final String title;
  final String podcastTitle;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
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
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  podcastTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _size = 100.0;

  Widget _buildArtwork(ColorScheme colorScheme) {
    if (thumbnailUrl == null) {
      return Container(
        width: _size,
        height: _size,
        alignment: Alignment.center,
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.folder_outlined,
          size: 48,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return ExtendedImage.network(
      thumbnailUrl!,
      width: _size,
      height: _size,
      fit: BoxFit.cover,
      cache: true,
      loadStateChanged: (state) {
        if (state.extendedImageLoadState == LoadState.failed) {
          return Container(
            width: _size,
            height: _size,
            alignment: Alignment.center,
            color: colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          );
        }
        return null;
      },
    );
  }
}
