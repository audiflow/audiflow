import '../../../common/database/app_database.dart';
import '../extensions/episode_extensions.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';
import '../models/season_title_extractor.dart';
import 'season_resolver.dart';

/// Resolver that groups by title pattern with season order by first appearance.
///
/// Useful for podcasts like:
/// - [Rome 1] First Steps
/// - [Rome 2] The Colosseum
/// - [Venezia 1] Arrival
///
/// Where "Rome" becomes season 1 (appeared first), "Venezia" becomes season 2.
///
/// When a titleExtractor is provided in the pattern, it uses that to extract
/// season names. Otherwise, falls back to the 'pattern' config with capture
/// group 1.
class TitleAppearanceOrderResolver implements SeasonResolver {
  @override
  String get type => 'title_appearance';

  @override
  SeasonSortSpec get defaultSort =>
      const SimpleSeasonSort(SeasonSortField.seasonNumber, SortOrder.ascending);

  @override
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern) {
    if (pattern == null) return null;

    final titleExtractor = pattern.titleExtractor;
    final patternStr = pattern.config['pattern'] as String?;

    // Need either a titleExtractor or a pattern config
    if (titleExtractor == null && patternStr == null) return null;

    // Sort episodes by publish date (oldest first) to determine appearance order
    final sorted = episodes.where((e) => e.publishedAt != null).toList()
      ..sort((a, b) => a.publishedAt!.compareTo(b.publishedAt!));

    final seasonOrder = <String>[];
    final grouped = <String, List<Episode>>{};
    final ungrouped = <int>[];

    // Also process episodes without publish date at the end
    final allEpisodes = [
      ...sorted,
      ...episodes.where((e) => e.publishedAt == null),
    ];

    for (final episode in allEpisodes) {
      final seasonName = _extractSeasonName(
        episode: episode,
        titleExtractor: titleExtractor,
        patternStr: patternStr,
      );

      if (seasonName != null) {
        if (!seasonOrder.contains(seasonName)) {
          seasonOrder.add(seasonName);
        }
        grouped.putIfAbsent(seasonName, () => []).add(episode);
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
      final seasonEpisodes = grouped[name]!;
      seasons.add(
        Season(
          id: 'season_${i + 1}',
          displayName: name,
          sortKey: i + 1,
          episodeIds: seasonEpisodes.map((e) => e.id).toList(),
        ),
      );
    }

    return SeasonGrouping(
      seasons: seasons,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  String? _extractSeasonName({
    required Episode episode,
    required SeasonTitleExtractor? titleExtractor,
    required String? patternStr,
  }) {
    // Try titleExtractor first if available
    if (titleExtractor != null) {
      return titleExtractor.extract(episode.toEpisodeData());
    }

    // Fall back to pattern config
    if (patternStr != null) {
      final regex = RegExp(patternStr);
      final match = regex.firstMatch(episode.title);
      if (match != null && 1 <= match.groupCount) {
        return match.group(1);
      }
    }

    return null;
  }
}
