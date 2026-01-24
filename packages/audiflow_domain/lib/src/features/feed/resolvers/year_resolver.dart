import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';
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
    final grouped = <int, List<int>>{};
    final ungrouped = <int>[];

    for (final episode in episodes) {
      final pubDate = episode.publishedAt;
      if (pubDate != null) {
        grouped.putIfAbsent(pubDate.year, () => []).add(episode.id);
      } else {
        ungrouped.add(episode.id);
      }
    }

    // Return null if no episodes have publish dates
    if (grouped.isEmpty) {
      return null;
    }

    final seasons = grouped.entries.map((entry) {
      return Season(
        id: 'year_${entry.key}',
        displayName: '${entry.key}',
        sortKey: entry.key,
        episodeIds: entry.value,
      );
    }).toList()..sort((a, b) => b.sortKey.compareTo(a.sortKey)); // Descending

    return SeasonGrouping(
      seasons: seasons,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }
}
