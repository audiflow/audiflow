import 'package:audiflow_core/audiflow_core.dart' show AutoPlayOrder;
import 'package:audiflow_domain/audiflow_domain.dart'
    show
        EffectiveEpisodeTitle,
        EffectiveThumbnails,
        EpisodeSortField,
        EpisodeSortRule,
        SmartPlaylist,
        SmartPlaylistDefinition,
        SmartPlaylistEpisodeData,
        SmartPlaylistGroup,
        SortOrder,
        YearBinding,
        sortEpisodeData,
        smartPlaylistEpisodesProvider,
        presetByFeedUrlProvider;

import '../utils/smart_playlist_def_resolver.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
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
  String? itunesId,
  AutoPlayOrder? effectiveOrder,
  List<SmartPlaylistEpisodeData>? fallbackEpisodes,
}) {
  final episodesAsync = ref.watch(
    smartPlaylistEpisodesProvider(playlist.episodeIds),
  );

  final showEpisodeRowThumbnail = _resolveEpisodeRowThumbnail(
    ref: ref,
    feedUrl: feedUrl,
    playlistId: playlist.id,
  );
  final playlistDef = resolveSmartPlaylistDef(
    ref: ref,
    feedUrl: feedUrl,
    playlistId: playlist.id,
  );

  // Mirrors the fallback pattern in buildEpisodeListSlivers: when the
  // user just switched view mode (or playlist) the new provider key
  // starts as AsyncLoading, which would otherwise collapse the sliver
  // tree to a spinner and snap the scroll position. Render the cached
  // last-known list with a thin progress bar until the new key resolves.
  if (episodesAsync is AsyncLoading && fallbackEpisodes != null) {
    return [
      const _PlaylistListLoadingBar(),
      ..._buildPlaylistData(
        episodes: fallbackEpisodes,
        playlist: playlist,
        playlistDef: playlistDef,
        searchQuery: searchQuery,
        sortOrder: sortOrder,
        podcastTitle: podcastTitle,
        artworkUrl: artworkUrl,
        feedImageUrl: feedImageUrl,
        lastRefreshedAt: lastRefreshedAt,
        scrollController: scrollController,
        onToggleSortOrder: onToggleSortOrder,
        onNavigateToGroup: onNavigateToGroup,
        itunesId: itunesId,
        feedUrl: feedUrl,
        effectiveOrder: effectiveOrder,
        showEpisodeRowThumbnail: showEpisodeRowThumbnail,
      ),
    ];
  }

  return episodesAsync.when(
    data: (episodes) => _buildPlaylistData(
      episodes: episodes,
      playlist: playlist,
      playlistDef: playlistDef,
      searchQuery: searchQuery,
      sortOrder: sortOrder,
      podcastTitle: podcastTitle,
      artworkUrl: artworkUrl,
      feedImageUrl: feedImageUrl,
      lastRefreshedAt: lastRefreshedAt,
      scrollController: scrollController,
      onToggleSortOrder: onToggleSortOrder,
      onNavigateToGroup: onNavigateToGroup,
      itunesId: itunesId,
      feedUrl: feedUrl,
      effectiveOrder: effectiveOrder,
      showEpisodeRowThumbnail: showEpisodeRowThumbnail,
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

/// Resolves the effective `showThumbnail` flag for episode rows
/// rendered inline (no group context). Returns `true` when no smart
/// playlist config matches.
bool _resolveEpisodeRowThumbnail({
  required WidgetRef ref,
  required String? feedUrl,
  required String playlistId,
}) {
  if (feedUrl == null) return true;
  final config = ref.watch(presetByFeedUrlProvider(feedUrl)).value;
  if (config == null) return true;
  final playlistDef = config.findPlaylist(playlistId);
  if (playlistDef == null) return true;
  return EffectiveThumbnails.episodeRowInGroup(
    showEpisodeThumbnail: config.showEpisodeThumbnail,
    playlist: playlistDef,
  );
}

List<Widget> _buildPlaylistData({
  required List<SmartPlaylistEpisodeData> episodes,
  required SmartPlaylist playlist,
  required SmartPlaylistDefinition? playlistDef,
  required String searchQuery,
  required SortOrder sortOrder,
  required String podcastTitle,
  required String? artworkUrl,
  required String? feedImageUrl,
  required DateTime? lastRefreshedAt,
  required ScrollController scrollController,
  required VoidCallback onToggleSortOrder,
  required bool showEpisodeRowThumbnail,
  required void Function(
    SmartPlaylist playlist,
    SmartPlaylistGroup group, {
    List<int>? filteredEpisodeIds,
  })
  onNavigateToGroup,
  String? itunesId,
  String? feedUrl,
  AutoPlayOrder? effectiveOrder,
}) {
  if (episodes.isEmpty) {
    return [
      const SliverFillRemaining(child: PodcastDetailEmptyPlaylistState()),
    ];
  }

  if (!playlist.isSeparate &&
      playlist.groups != null &&
      playlist.groups!.isNotEmpty) {
    return _buildInlineGroupList(
      episodes: episodes,
      playlist: playlist,
      searchQuery: searchQuery,
      sortOrder: sortOrder,
      scrollController: scrollController,
      onToggleSortOrder: onToggleSortOrder,
      onNavigateToGroup: onNavigateToGroup,
      feedUrl: feedUrl,
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

  if (playlist.yearBinding != YearBinding.none) {
    return _buildYearGroupedPlaylistSlivers(
      episodes: displayEpisodes,
      playlist: playlist,
      playlistDef: playlistDef,
      sortOrder: sortOrder,
      podcastTitle: podcastTitle,
      artworkUrl: artworkUrl,
      feedImageUrl: feedImageUrl,
      lastRefreshedAt: lastRefreshedAt,
      scrollController: scrollController,
      itunesId: itunesId,
      feedUrl: feedUrl,
      effectiveOrder: effectiveOrder,
      showThumbnail: showEpisodeRowThumbnail,
    );
  }

  final effectiveRule = EpisodeSortRule(
    field: playlist.episodeSort?.field ?? EpisodeSortField.publishedAt,
    order: sortOrder,
  );
  final sorted = List.of(displayEpisodes);
  sortEpisodeData(sorted, effectiveRule);

  final siblingEpisodeIds = sorted.map((d) => d.episode.id).toList();

  return [
    if (playlist.userSortable)
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
          showThumbnail: showEpisodeRowThumbnail,
          progress: data.progress,
          siblingEpisodeIds: siblingEpisodeIds,
          effectiveOrder: effectiveOrder,
          itunesId: itunesId,
          feedUrl: feedUrl,
          displayTitle: EffectiveEpisodeTitle.forPlaylist(
            playlist: playlistDef,
            episode: data.episode,
          ),
          playlistId: playlist.id,
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
  required ScrollController scrollController,
  required VoidCallback onToggleSortOrder,
  required void Function(
    SmartPlaylist playlist,
    SmartPlaylistGroup group, {
    List<int>? filteredEpisodeIds,
  })
  onNavigateToGroup,
  String? feedUrl,
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

  if (playlist.yearBinding == YearBinding.none) {
    final sorted = sortGroupsBySort(
      displayGroups,
      playlist.groupSort,
      sortOrder,
    );

    return [
      if (playlist.userSortable)
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
            prependSeasonNumber: playlist.prependSeasonNumber,
            feedUrl: feedUrl,
            playlistId: playlist.id,
            onTap: () => onNavigateToGroup(playlist, group),
          );
        },
      ),
    ];
  }

  if (playlist.yearBinding == YearBinding.splitByYear &&
      !displayGroups.any(
        (g) =>
            g.yearOverride != null && g.yearOverride != YearBinding.splitByYear,
      )) {
    return _buildPerEpisodeInlineGroups(
      groups: displayGroups,
      episodeMap: episodeMap,
      playlist: playlist,
      sortOrder: sortOrder,
      scrollController: scrollController,
      onToggleSortOrder: onToggleSortOrder,
      onNavigateToGroup: onNavigateToGroup,
      feedUrl: feedUrl,
    );
  }

  return _buildMixedYearInlineGroups(
    groups: displayGroups,
    episodeMap: episodeMap,
    playlist: playlist,
    defaultMode: playlist.yearBinding,
    sortOrder: sortOrder,
    scrollController: scrollController,
    onToggleSortOrder: onToggleSortOrder,
    onNavigateToGroup: onNavigateToGroup,
    feedUrl: feedUrl,
  );
}

List<Widget> _buildPerEpisodeInlineGroups({
  required List<SmartPlaylistGroup> groups,
  required Map<int, SmartPlaylistEpisodeData> episodeMap,
  required SmartPlaylist playlist,
  required SortOrder sortOrder,
  required ScrollController scrollController,
  required VoidCallback onToggleSortOrder,
  required void Function(
    SmartPlaylist playlist,
    SmartPlaylistGroup group, {
    List<int>? filteredEpisodeIds,
  })
  onNavigateToGroup,
  String? feedUrl,
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
      final meta = _computeFilteredMeta(entry.value, episodeMap);
      byYear
          .putIfAbsent(entry.key, () => [])
          .add(
            YearFilteredInlineGroup(
              group: group,
              filteredEpisodeIds: entry.value,
              earliestDate: meta.$1,
              latestDate: meta.$2,
              totalDurationMs: meta.$3,
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

  for (final items in byYear.values) {
    sortFilteredGroupsInPlace(items, playlist.groupSort, sortOrder);
  }

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
        prependSeasonNumber: playlist.prependSeasonNumber,
        feedUrl: feedUrl,
        playlistId: playlist.id,
        episodeCountOverride: item.filteredEpisodeIds.length,
        earliestDateOverride: item.earliestDate,
        latestDateOverride: item.latestDate,
        totalDurationMsOverride: item.totalDurationMs,
        onTap: () => onNavigateToGroup(
          playlist,
          item.group,
          filteredEpisodeIds: item.filteredEpisodeIds,
        ),
      ),
      scrollController: scrollController,
      yearGroupingEnabled: true,
      itemExtent: null,
    ),
  ];
}

List<Widget> _buildYearGroupedPlaylistSlivers({
  required List<SmartPlaylistEpisodeData> episodes,
  required SmartPlaylist playlist,
  required SmartPlaylistDefinition? playlistDef,
  required SortOrder sortOrder,
  required String podcastTitle,
  required String? artworkUrl,
  required String? feedImageUrl,
  required DateTime? lastRefreshedAt,
  required ScrollController scrollController,
  required bool showThumbnail,
  String? itunesId,
  String? feedUrl,
  AutoPlayOrder? effectiveOrder,
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
      showThumbnail: showThumbnail,
      progress: data.progress,
      siblingEpisodeIds: siblingEpisodeIds,
      effectiveOrder: effectiveOrder,
      itunesId: itunesId,
      feedUrl: feedUrl,
      displayTitle: EffectiveEpisodeTitle.forPlaylist(
        playlist: playlistDef,
        episode: data.episode,
      ),
      playlistId: playlist.id,
    ),
    scrollController: scrollController,
    yearGroupingEnabled: true,
    itemExtent: episodeCardExtent,
  );
}

List<Widget> _buildMixedYearInlineGroups({
  required List<SmartPlaylistGroup> groups,
  required Map<int, SmartPlaylistEpisodeData> episodeMap,
  required SmartPlaylist playlist,
  required YearBinding defaultMode,
  required SortOrder sortOrder,
  required ScrollController scrollController,
  required VoidCallback onToggleSortOrder,
  required void Function(
    SmartPlaylist playlist,
    SmartPlaylistGroup group, {
    List<int>? filteredEpisodeIds,
  })
  onNavigateToGroup,
  String? feedUrl,
}) {
  final byYear = <int, List<YearFilteredInlineGroup>>{};

  for (final group in groups) {
    final mode = group.yearOverride ?? defaultMode;

    if (mode == YearBinding.splitByYear) {
      final yearIds = <int, List<int>>{};
      for (final id in group.episodeIds) {
        final ep = episodeMap[id];
        final year = ep?.episode.publishedAt?.year ?? 0;
        yearIds.putIfAbsent(year, () => []).add(id);
      }
      for (final entry in yearIds.entries) {
        final meta = _computeFilteredMeta(entry.value, episodeMap);
        byYear
            .putIfAbsent(entry.key, () => [])
            .add(
              YearFilteredInlineGroup(
                group: group,
                filteredEpisodeIds: entry.value,
                earliestDate: meta.$1,
                latestDate: meta.$2,
                totalDurationMs: meta.$3,
              ),
            );
      }
    } else {
      var year = 0;
      if (group.episodeIds.isNotEmpty) {
        final firstId = group.episodeIds.first;
        final ep = episodeMap[firstId];
        year = ep?.episode.publishedAt?.year ?? 0;
      }
      byYear
          .putIfAbsent(year, () => [])
          .add(
            YearFilteredInlineGroup(
              group: group,
              filteredEpisodeIds: group.episodeIds,
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

  for (final items in byYear.values) {
    sortFilteredGroupsInPlace(items, playlist.groupSort, sortOrder);
  }

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
        prependSeasonNumber: playlist.prependSeasonNumber,
        feedUrl: feedUrl,
        playlistId: playlist.id,
        episodeCountOverride: item.filteredEpisodeIds.length,
        earliestDateOverride: item.earliestDate,
        latestDateOverride: item.latestDate,
        totalDurationMsOverride: item.totalDurationMs,
        onTap: () => onNavigateToGroup(
          playlist,
          item.group,
          filteredEpisodeIds:
              item.filteredEpisodeIds.length != item.group.episodeIds.length
              ? item.filteredEpisodeIds
              : null,
        ),
      ),
      scrollController: scrollController,
      yearGroupingEnabled: true,
      itemExtent: null,
    ),
  ];
}

/// Computes (earliest, latest, totalDurationMs) for a
/// filtered subset of episode IDs.
(DateTime?, DateTime?, int?) _computeFilteredMeta(
  List<int> episodeIds,
  Map<int, SmartPlaylistEpisodeData> episodeMap,
) {
  DateTime? earliest;
  DateTime? latest;
  var totalMs = 0;
  var hasDuration = false;

  for (final id in episodeIds) {
    final ep = episodeMap[id]?.episode;
    if (ep == null) continue;
    final pub = ep.publishedAt;
    if (pub != null) {
      if (earliest == null || pub.isBefore(earliest)) {
        earliest = pub;
      }
      if (latest == null || pub.isAfter(latest)) {
        latest = pub;
      }
    }
    final dur = ep.durationMs;
    if (dur != null && 0 < dur) {
      totalMs += dur;
      hasDuration = true;
    }
  }

  return (earliest, latest, hasDuration ? totalMs : null);
}

/// Thin progress bar shown while a new smart playlist provider key is
/// being fetched and the cached previous list is still on screen.
class _PlaylistListLoadingBar extends StatelessWidget {
  const _PlaylistListLoadingBar();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: SizedBox(height: 2, child: LinearProgressIndicator(minHeight: 2)),
    );
  }
}
