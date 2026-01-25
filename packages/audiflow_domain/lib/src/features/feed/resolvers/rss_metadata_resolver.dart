import 'dart:math';

import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';
import '../models/season_title_extractor.dart';
import 'season_resolver.dart';

/// Resolver that groups episodes using RSS metadata (seasonNumber field).
class RssMetadataResolver implements SeasonResolver {
  @override
  String get type => 'rss';

  @override
  SeasonSortSpec get defaultSort =>
      const SimpleSeasonSort(SeasonSortField.seasonNumber, SortOrder.ascending);

  @override
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern) {
    final grouped = <int, List<Episode>>{};
    final ungrouped = <int>[];

    // Check for groupNullSeasonAs config
    final groupNullAs = pattern?.config['groupNullSeasonAs'] as int?;

    for (final episode in episodes) {
      final seasonNum = episode.seasonNumber;

      if (seasonNum != null && 1 <= seasonNum) {
        // Positive season number - group normally
        grouped.putIfAbsent(seasonNum, () => []).add(episode);
      } else if (groupNullAs != null) {
        // Null/zero season number with groupNullSeasonAs config
        grouped.putIfAbsent(groupNullAs, () => []).add(episode);
      } else {
        // No config for grouping - mark as ungrouped
        ungrouped.add(episode.id);
      }
    }

    // Return null if no episodes have season numbers
    if (grouped.isEmpty) {
      return null;
    }

    final titleExtractor = pattern?.titleExtractor;

    final seasons = grouped.entries.map((entry) {
      final seasonEpisodes = entry.value;
      final displayName = _extractDisplayName(
        seasonNumber: entry.key,
        episodes: seasonEpisodes,
        titleExtractor: titleExtractor,
      );

      // Calculate sortKey from max episodeNumber
      final sortKey = _calculateSortKey(seasonEpisodes);

      return Season(
        id: 'season_${entry.key}',
        displayName: displayName,
        sortKey: sortKey,
        episodeIds: seasonEpisodes.map((e) => e.id).toList(),
      );
    }).toList()..sort((a, b) => a.sortKey.compareTo(b.sortKey));

    return SeasonGrouping(
      seasons: seasons,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  String _extractDisplayName({
    required int seasonNumber,
    required List<Episode> episodes,
    required SeasonTitleExtractor? titleExtractor,
  }) {
    if (titleExtractor == null || episodes.isEmpty) {
      return 'Season $seasonNumber';
    }

    final extracted = titleExtractor.extract(episodes.first);
    return extracted ?? 'Season $seasonNumber';
  }

  int _calculateSortKey(List<Episode> episodes) {
    if (episodes.isEmpty) return 0;

    return episodes.map((e) => e.episodeNumber ?? 0).reduce(max);
  }
}
