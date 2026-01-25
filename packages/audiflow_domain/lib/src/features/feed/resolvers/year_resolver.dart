import '../../../common/database/app_database.dart';
import '../extensions/episode_extensions.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';
import '../models/season_title_extractor.dart';
import 'season_resolver.dart';

/// Resolver that groups episodes by publication year.
class YearResolver implements SeasonResolver {
  @override
  String get type => 'year';

  @override
  SeasonSortSpec get defaultSort => const SimpleSeasonSort(
    SeasonSortField.seasonNumber,
    SortOrder.descending, // Newest years first
  );

  @override
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern) {
    final grouped = <int, List<Episode>>{};
    final ungrouped = <int>[];

    for (final episode in episodes) {
      final pubDate = episode.publishedAt;
      if (pubDate != null) {
        grouped.putIfAbsent(pubDate.year, () => []).add(episode);
      } else {
        ungrouped.add(episode.id);
      }
    }

    // Return null if no episodes have publish dates
    if (grouped.isEmpty) {
      return null;
    }

    final titleExtractor = pattern?.titleExtractor;

    final seasons = grouped.entries.map((entry) {
      final seasonEpisodes = entry.value;
      final displayName = _extractDisplayName(
        year: entry.key,
        episodes: seasonEpisodes,
        titleExtractor: titleExtractor,
      );

      return Season(
        id: 'year_${entry.key}',
        displayName: displayName,
        sortKey: entry.key,
        episodeIds: seasonEpisodes.map((e) => e.id).toList(),
      );
    }).toList()..sort((a, b) => b.sortKey.compareTo(a.sortKey)); // Descending

    return SeasonGrouping(
      seasons: seasons,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  String _extractDisplayName({
    required int year,
    required List<Episode> episodes,
    required SeasonTitleExtractor? titleExtractor,
  }) {
    if (titleExtractor == null || episodes.isEmpty) {
      return '$year';
    }

    // Try to extract title from first episode
    final extracted = titleExtractor.extract(episodes.first.toEpisodeData());
    return extracted ?? '$year';
  }
}
