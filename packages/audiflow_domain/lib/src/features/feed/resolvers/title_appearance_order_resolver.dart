import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';
import 'season_resolver.dart';

/// Resolver that groups by title pattern with season order by first appearance.
///
/// Useful for podcasts like:
/// - [Rome 1] First Steps
/// - [Rome 2] The Colosseum
/// - [Venezia 1] Arrival
///
/// Where "Rome" becomes season 1 (appeared first), "Venezia" becomes season 2.
class TitleAppearanceOrderResolver implements SeasonResolver {
  @override
  String get type => 'title_appearance';

  @override
  SeasonSortSpec get defaultSort =>
      const SimpleSeasonSort(SeasonSortField.seasonNumber, SortOrder.ascending);

  @override
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern) {
    if (pattern == null) return null;

    final patternStr = pattern.config['pattern'] as String?;
    if (patternStr == null) return null;

    final regex = RegExp(patternStr);

    // Sort episodes by publish date (oldest first) to determine appearance order
    final sorted = episodes.where((e) => e.publishedAt != null).toList()
      ..sort((a, b) => a.publishedAt!.compareTo(b.publishedAt!));

    final seasonOrder = <String>[];
    final grouped = <String, List<int>>{};
    final ungrouped = <int>[];

    // Also process episodes without publish date at the end
    final allEpisodes = [
      ...sorted,
      ...episodes.where((e) => e.publishedAt == null),
    ];

    for (final episode in allEpisodes) {
      final match = regex.firstMatch(episode.title);
      if (match != null && 1 <= match.groupCount) {
        final seasonName = match.group(1)!;
        if (!seasonOrder.contains(seasonName)) {
          seasonOrder.add(seasonName);
        }
        grouped.putIfAbsent(seasonName, () => []).add(episode.id);
      } else {
        ungrouped.add(episode.id);
      }
    }

    // Return null if no matches
    if (grouped.isEmpty) {
      return null;
    }

    final seasons = <Season>[];
    for (var i = 0; i < seasonOrder.length; i++) {
      final name = seasonOrder[i];
      seasons.add(
        Season(
          id: 'season_${i + 1}',
          displayName: name,
          sortKey: i + 1,
          episodeIds: grouped[name]!,
        ),
      );
    }

    return SeasonGrouping(
      seasons: seasons,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }
}
