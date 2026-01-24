import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';
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
    final grouped = <int, List<int>>{};
    final ungrouped = <int>[];

    for (final episode in episodes) {
      final seasonNum = episode.seasonNumber;
      if (seasonNum != null) {
        grouped.putIfAbsent(seasonNum, () => []).add(episode.id);
      } else {
        ungrouped.add(episode.id);
      }
    }

    // Return null if no episodes have season numbers
    if (grouped.isEmpty) {
      return null;
    }

    final seasons = grouped.entries.map((entry) {
      return Season(
        id: 'season_${entry.key}',
        displayName: 'Season ${entry.key}',
        sortKey: entry.key,
        episodeIds: entry.value,
      );
    }).toList()..sort((a, b) => a.sortKey.compareTo(b.sortKey));

    return SeasonGrouping(
      seasons: seasons,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }
}
