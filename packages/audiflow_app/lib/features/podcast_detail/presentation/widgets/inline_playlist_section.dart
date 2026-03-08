import 'package:audiflow_domain/audiflow_domain.dart'
    show
        SmartPlaylist,
        SmartPlaylistContentType,
        SmartPlaylistEpisodeData,
        SmartPlaylistGroup,
        SortOrder,
        YearHeaderMode,
        smartPlaylistEpisodesProvider;
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/podcast_detail_controller.dart';
import '../utils/group_sorting.dart';
import 'episode_list_section.dart';
import 'inline_group_card.dart';
import 'podcast_detail_empty_states.dart';
import 'smart_playlist_episode_list_tile.dart';

/// Builds inline playlist episode slivers.
List<Widget> buildInlinePlaylistSlivers({
  required WidgetRef ref,
  required SmartPlaylist playlist,
  required String? feedUrl,
  required String searchQuery,
  required SortOrder sortOrder,
  required String podcastTitle,
  required String? artworkUrl,
  required String? feedImageUrl,
  required DateTime? lastRefreshedAt,
  required ScrollController scrollController,
  required VoidCallback onToggleSortOrder,
  required void Function(
    SmartPlaylist playlist,
    SmartPlaylistGroup group, {
    List<int>? filteredEpisodeIds,
  })
  onNavigateToGroup,
}) {
  final hasFeedIds =
      playlist.episodeIds.isNotEmpty && playlist.episodeIds.first < 0;

  final episodesAsync = hasFeedIds && feedUrl != null
      ? ref.watch(
          feedSmartPlaylistEpisodesProvider(feedUrl, playlist.episodeIds),
        )
      : ref.watch(smartPlaylistEpisodesProvider(playlist.episodeIds));

  return episodesAsync.when(
    data: (episodes) => _buildPlaylistData(
      episodes: episodes,
      playlist: playlist,
      searchQuery: searchQuery,
      sortOrder: sortOrder,
      podcastTitle: podcastTitle,
      artworkUrl: artworkUrl,
      feedImageUrl: feedImageUrl,
      lastRefreshedAt: lastRefreshedAt,
      scrollController: scrollController,
      onToggleSortOrder: onToggleSortOrder,
      onNavigateToGroup: onNavigateToGroup,
    ),
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
        child: Builder(
          builder: (context) => Padding(
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
      ),
    ],
  );
}

List<Widget> _buildPlaylistData({
  required List<SmartPlaylistEpisodeData> episodes,
  required SmartPlaylist playlist,
  required String searchQuery,
  required SortOrder sortOrder,
  required String podcastTitle,
  required String? artworkUrl,
  required String? feedImageUrl,
  required DateTime? lastRefreshedAt,
  required ScrollController scrollController,
  required VoidCallback onToggleSortOrder,
  required void Function(
    SmartPlaylist playlist,
    SmartPlaylistGroup group, {
    List<int>? filteredEpisodeIds,
  })
  onNavigateToGroup,
}) {
  if (episodes.isEmpty) {
    return [
      const SliverFillRemaining(child: PodcastDetailEmptyPlaylistState()),
    ];
  }

  if (playlist.contentType == SmartPlaylistContentType.groups &&
      playlist.groups != null &&
      playlist.groups!.isNotEmpty) {
    return _buildInlineGroupList(
      episodes: episodes,
      playlist: playlist,
      searchQuery: searchQuery,
      sortOrder: sortOrder,
      artworkUrl: artworkUrl,
      scrollController: scrollController,
      onToggleSortOrder: onToggleSortOrder,
      onNavigateToGroup: onNavigateToGroup,
    );
  }

  final displayEpisodes = filterBySearchQuery(
    items: episodes,
    query: searchQuery,
    getTitle: (e) => e.episode.title,
    getDescription: (e) => e.episode.description,
  );

  if (displayEpisodes.isEmpty && 2 <= searchQuery.length) {
    return [const PodcastDetailSearchEmptyState()];
  }

  if (playlist.yearHeaderMode != YearHeaderMode.none) {
    return _buildYearGroupedPlaylistSlivers(
      episodes: displayEpisodes,
      playlist: playlist,
      sortOrder: sortOrder,
      podcastTitle: podcastTitle,
      artworkUrl: artworkUrl,
      feedImageUrl: feedImageUrl,
      lastRefreshedAt: lastRefreshedAt,
      scrollController: scrollController,
    );
  }

  final sorted = sortOrder == SortOrder.descending
      ? displayEpisodes.reversed.toList()
      : displayEpisodes;

  final siblingEpisodeIds = sorted.map((d) => d.episode.id).toList();

  return [
    if (playlist.showSortOrderToggle)
      SliverToBoxAdapter(
        child: Builder(
          builder: (context) => SortHeader(
            label: AppLocalizations.of(
              context,
            ).podcastDetailEpisodeCount(sorted.length),
            sortOrder: sortOrder,
            onToggleSortOrder: onToggleSortOrder,
          ),
        ),
      ),
    SliverList.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final data = sorted[index];
        return SmartPlaylistEpisodeListTile(
          lastRefreshedAt: lastRefreshedAt,
          key: ValueKey(data.episode.id),
          episode: data.episode,
          podcastTitle: podcastTitle,
          artworkUrl: artworkUrl,
          feedImageUrl: feedImageUrl,
          progress: data.progress,
          siblingEpisodeIds: siblingEpisodeIds,
        );
      },
    ),
  ];
}

List<Widget> _buildInlineGroupList({
  required List<SmartPlaylistEpisodeData> episodes,
  required SmartPlaylist playlist,
  required String searchQuery,
  required SortOrder sortOrder,
  required String? artworkUrl,
  required ScrollController scrollController,
  required VoidCallback onToggleSortOrder,
  required void Function(
    SmartPlaylist playlist,
    SmartPlaylistGroup group, {
    List<int>? filteredEpisodeIds,
  })
  onNavigateToGroup,
}) {
  final groups = playlist.groups!;
  final displayGroups = filterBySearchQuery(
    items: groups,
    query: searchQuery,
    getTitle: (g) => g.displayName,
  );

  if (displayGroups.isEmpty && 2 <= searchQuery.length) {
    return [const PodcastDetailSearchEmptyState()];
  }

  final episodeMap = <int, SmartPlaylistEpisodeData>{};
  for (final ep in episodes) {
    episodeMap[ep.episode.id] = ep;
  }

  if (playlist.yearHeaderMode == YearHeaderMode.none) {
    final sorted = sortGroupsByCustomSort(
      displayGroups,
      playlist.customSort,
      sortOrder,
    );

    return [
      if (playlist.showSortOrderToggle)
        SliverToBoxAdapter(
          child: Builder(
            builder: (context) => SortHeader(
              label: AppLocalizations.of(
                context,
              ).podcastDetailGroupCount(sorted.length),
              sortOrder: sortOrder,
              onToggleSortOrder: onToggleSortOrder,
            ),
          ),
        ),
      SliverList.builder(
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final group = sorted[index];
          return InlineGroupCard(
            group: group,
            showSeasonNumber: playlist.showSeasonNumber,
            podcastArtworkUrl: artworkUrl,
            onTap: () => onNavigateToGroup(playlist, group),
          );
        },
      ),
    ];
  }

  if (playlist.yearHeaderMode == YearHeaderMode.perEpisode) {
    return _buildPerEpisodeInlineGroups(
      groups: displayGroups,
      episodeMap: episodeMap,
      playlist: playlist,
      sortOrder: sortOrder,
      artworkUrl: artworkUrl,
      scrollController: scrollController,
      onToggleSortOrder: onToggleSortOrder,
      onNavigateToGroup: onNavigateToGroup,
    );
  }

  // firstEpisode mode
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
      child: Builder(
        builder: (context) => SortHeader(
          label: AppLocalizations.of(
            context,
          ).podcastDetailGroupCount(displayGroups.length),
          sortOrder: sortOrder,
          onToggleSortOrder: onToggleSortOrder,
        ),
      ),
    ),
    ...buildYearGroupedSlivers<SmartPlaylistGroup>(
      itemsByYear: {for (final y in sortedYears) y: byYear[y]!},
      sortedYears: sortedYears,
      itemBuilder: (context, group) => InlineGroupCard(
        group: group,
        showSeasonNumber: playlist.showSeasonNumber,
        podcastArtworkUrl: artworkUrl,
        onTap: () => onNavigateToGroup(playlist, group),
      ),
      scrollController: scrollController,
      yearGroupingEnabled: true,
      itemExtent: 88,
    ),
  ];
}

List<Widget> _buildPerEpisodeInlineGroups({
  required List<SmartPlaylistGroup> groups,
  required Map<int, SmartPlaylistEpisodeData> episodeMap,
  required SmartPlaylist playlist,
  required SortOrder sortOrder,
  required String? artworkUrl,
  required ScrollController scrollController,
  required VoidCallback onToggleSortOrder,
  required void Function(
    SmartPlaylist playlist,
    SmartPlaylistGroup group, {
    List<int>? filteredEpisodeIds,
  })
  onNavigateToGroup,
}) {
  final byYear = <int, List<YearFilteredInlineGroup>>{};
  for (final group in groups) {
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
            YearFilteredInlineGroup(
              group: group,
              filteredEpisodeIds: entry.value,
            ),
          );
    }
  }

  final sortedYears = byYear.keys.toList()
    ..sort(
      sortOrder == SortOrder.descending
          ? (a, b) => b.compareTo(a)
          : (a, b) => a.compareTo(b),
    );

  var totalCards = 0;
  for (final items in byYear.values) {
    totalCards += items.length;
  }

  return [
    SliverToBoxAdapter(
      child: Builder(
        builder: (context) => SortHeader(
          label: AppLocalizations.of(
            context,
          ).podcastDetailGroupCount(totalCards),
          sortOrder: sortOrder,
          onToggleSortOrder: onToggleSortOrder,
        ),
      ),
    ),
    ...buildYearGroupedSlivers<YearFilteredInlineGroup>(
      itemsByYear: {for (final y in sortedYears) y: byYear[y]!},
      sortedYears: sortedYears,
      itemBuilder: (context, item) => InlineGroupCard(
        group: item.group,
        showSeasonNumber: playlist.showSeasonNumber,
        podcastArtworkUrl: artworkUrl,
        episodeCountOverride: item.filteredEpisodeIds.length,
        onTap: () => onNavigateToGroup(
          playlist,
          item.group,
          filteredEpisodeIds: item.filteredEpisodeIds,
        ),
      ),
      scrollController: scrollController,
      yearGroupingEnabled: true,
      itemExtent: 88,
    ),
  ];
}

List<Widget> _buildYearGroupedPlaylistSlivers({
  required List<SmartPlaylistEpisodeData> episodes,
  required SmartPlaylist playlist,
  required SortOrder sortOrder,
  required String podcastTitle,
  required String? artworkUrl,
  required String? feedImageUrl,
  required DateTime? lastRefreshedAt,
  required ScrollController scrollController,
}) {
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

  // Build flattened sibling IDs from displayed (year-sorted)
  // episodes to avoid passing negative placeholder IDs.
  final siblingEpisodeIds = sortedYears
      .expand((y) => byYear[y]!)
      .map((d) => d.episode.id)
      .toList();

  return buildYearGroupedSlivers<SmartPlaylistEpisodeData>(
    itemsByYear: byYear,
    sortedYears: sortedYears,
    itemBuilder: (context, data) => SmartPlaylistEpisodeListTile(
      lastRefreshedAt: lastRefreshedAt,
      key: ValueKey(data.episode.id),
      episode: data.episode,
      podcastTitle: podcastTitle,
      artworkUrl: artworkUrl,
      feedImageUrl: feedImageUrl,
      progress: data.progress,
      siblingEpisodeIds: siblingEpisodeIds,
    ),
    scrollController: scrollController,
    yearGroupingEnabled: true,
    itemExtent: episodeCardExtent,
  );
}
