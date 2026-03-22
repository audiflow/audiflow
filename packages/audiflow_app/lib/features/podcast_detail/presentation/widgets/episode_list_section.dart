import 'package:audiflow_domain/audiflow_domain.dart'
    show PodcastItem, SortOrder, smartPlaylistPatternByFeedUrlProvider;
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/podcast_detail_controller.dart';
import 'episode_list_tile.dart';
import 'podcast_detail_empty_states.dart';

/// Sort header row with episode count and sort toggle.
class SortHeader extends StatelessWidget {
  const SortHeader({
    super.key,
    required this.label,
    required this.sortOrder,
    required this.onToggleSortOrder,
  });

  final String label;
  final SortOrder sortOrder;
  final VoidCallback onToggleSortOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

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
            onTap: onToggleSortOrder,
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
      ),
    );
  }
}

/// Builds episode list slivers for the episodes view mode.
List<Widget> buildEpisodeListSlivers({
  required WidgetRef ref,
  required String feedUrl,
  required AsyncValue<List<PodcastItem>> episodesAsync,
  required AsyncValue<EpisodeProgressMap> progressMapAsync,
  required SortOrder sortOrder,
  required String searchQuery,
  required String podcastTitle,
  required String? artworkUrl,
  required String? feedImageUrl,
  required DateTime? lastRefreshedAt,
  required ScrollController scrollController,
  required VoidCallback onToggleSortOrder,
  String? itunesId,
}) {
  final patternAsync = ref.watch(
    smartPlaylistPatternByFeedUrlProvider(feedUrl),
  );
  final yearGrouped = patternAsync.value?.yearGroupedEpisodes ?? false;

  return episodesAsync.when(
    data: (episodes) => _buildEpisodeData(
      episodes: episodes,
      progressMapAsync: progressMapAsync,
      sortOrder: sortOrder,
      searchQuery: searchQuery,
      podcastTitle: podcastTitle,
      artworkUrl: artworkUrl,
      feedImageUrl: feedImageUrl,
      lastRefreshedAt: lastRefreshedAt,
      scrollController: scrollController,
      onToggleSortOrder: onToggleSortOrder,
      yearGrouped: yearGrouped,
      itunesId: itunesId,
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
            child: Text(
              AppLocalizations.of(
                context,
              ).podcastDetailEpisodeLoadError(error.toString()),
            ),
          ),
        ),
      ),
    ],
  );
}

List<Widget> _buildEpisodeData({
  required List<PodcastItem> episodes,
  required AsyncValue<EpisodeProgressMap> progressMapAsync,
  required SortOrder sortOrder,
  required String searchQuery,
  required String podcastTitle,
  required String? artworkUrl,
  required String? feedImageUrl,
  required DateTime? lastRefreshedAt,
  required ScrollController scrollController,
  required VoidCallback onToggleSortOrder,
  required bool yearGrouped,
  String? itunesId,
}) {
  final displayEpisodes = filterBySearchQuery(
    items: episodes,
    query: searchQuery,
    getTitle: (e) => e.title,
    getDescription: (e) => e.description,
  );

  if (displayEpisodes.isEmpty) {
    if (2 <= searchQuery.length) {
      return [const PodcastDetailSearchEmptyState()];
    }
    return [const SliverFillRemaining(child: PodcastDetailEmptyFilterState())];
  }

  final progressMap = progressMapAsync.value ?? {};

  final siblingEpisodeIds = displayEpisodes
      .where((ep) => ep.enclosureUrl != null)
      .map((ep) => progressMap[ep.enclosureUrl]?.episode.id)
      .whereType<int>()
      .toList();

  final sortHeader = SliverToBoxAdapter(
    child: Builder(
      builder: (context) => SortHeader(
        label: AppLocalizations.of(
          context,
        ).podcastDetailEpisodeCount(displayEpisodes.length),
        sortOrder: sortOrder,
        onToggleSortOrder: onToggleSortOrder,
      ),
    ),
  );

  if (yearGrouped) {
    return [
      sortHeader,
      ..._buildYearGroupedEpisodeSlivers(
        episodes: displayEpisodes,
        progressMap: progressMap,
        siblingEpisodeIds: siblingEpisodeIds,
        sortOrder: sortOrder,
        podcastTitle: podcastTitle,
        artworkUrl: artworkUrl,
        feedImageUrl: feedImageUrl,
        lastRefreshedAt: lastRefreshedAt,
        scrollController: scrollController,
        itunesId: itunesId,
      ),
    ];
  }

  return [
    sortHeader,
    SliverList.builder(
      itemCount: displayEpisodes.length,
      itemBuilder: (context, index) {
        final episode = displayEpisodes[index];
        final progress = episode.enclosureUrl != null
            ? progressMap[episode.enclosureUrl]
            : null;

        return EpisodeListTile(
          lastRefreshedAt: lastRefreshedAt,
          key: ValueKey(episode.guid ?? index),
          episode: episode,
          podcastTitle: podcastTitle,
          artworkUrl: artworkUrl,
          feedImageUrl: feedImageUrl,
          progress: progress,
          siblingEpisodeIds: siblingEpisodeIds,
          itunesId: itunesId,
        );
      },
    ),
  ];
}

List<Widget> _buildYearGroupedEpisodeSlivers({
  required List<PodcastItem> episodes,
  required EpisodeProgressMap progressMap,
  required List<int> siblingEpisodeIds,
  required SortOrder sortOrder,
  required String podcastTitle,
  required String? artworkUrl,
  required String? feedImageUrl,
  required DateTime? lastRefreshedAt,
  required ScrollController scrollController,
  String? itunesId,
}) {
  final byYear = <int, List<PodcastItem>>{};
  for (final episode in episodes) {
    final dbEpisode = episode.enclosureUrl != null
        ? progressMap[episode.enclosureUrl]?.episode
        : null;
    final year = dbEpisode?.publishedAt?.year ?? episode.publishDate?.year ?? 0;
    byYear.putIfAbsent(year, () => []).add(episode);
  }

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
        lastRefreshedAt: lastRefreshedAt,
        key: ValueKey(episode.guid ?? episode.title),
        episode: episode,
        podcastTitle: podcastTitle,
        artworkUrl: artworkUrl,
        feedImageUrl: feedImageUrl,
        progress: progress,
        siblingEpisodeIds: siblingEpisodeIds,
        itunesId: itunesId,
      );
    },
    scrollController: scrollController,
    yearGroupingEnabled: true,
    itemExtent: episodeCardExtent,
  );
}
