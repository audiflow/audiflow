import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Season', () {
    test('Season holds episode list and metadata', () {
      final season = Season(
        id: 'season_1',
        displayName: 'Season 1',
        sortKey: 1,
        episodeIds: [1, 2, 3],
      );

      expect(season.id, 'season_1');
      expect(season.displayName, 'Season 1');
      expect(season.sortKey, 1);
      expect(season.episodeIds, [1, 2, 3]);
    });

    test('Season.episodeCount returns correct count', () {
      final season = Season(
        id: 'season_2',
        displayName: 'Season 2',
        sortKey: 2,
        episodeIds: [4, 5, 6, 7, 8],
      );

      expect(season.episodeCount, 5);
    });
  });

  group('SeasonGrouping', () {
    test('SeasonGrouping holds seasons and ungrouped episodes', () {
      final grouping = SeasonGrouping(
        seasons: [
          Season(id: 's1', displayName: 'S1', sortKey: 1, episodeIds: [1, 2]),
        ],
        ungroupedEpisodeIds: [10, 11],
        resolverType: 'rss',
      );

      expect(grouping.seasons.length, 1);
      expect(grouping.ungroupedEpisodeIds, [10, 11]);
      expect(grouping.resolverType, 'rss');
    });

    test('SeasonGrouping.hasUngrouped returns true when ungrouped exist', () {
      final withUngrouped = SeasonGrouping(
        seasons: [],
        ungroupedEpisodeIds: [1],
        resolverType: 'rss',
      );
      final withoutUngrouped = SeasonGrouping(
        seasons: [],
        ungroupedEpisodeIds: [],
        resolverType: 'rss',
      );

      expect(withUngrouped.hasUngrouped, isTrue);
      expect(withoutUngrouped.hasUngrouped, isFalse);
    });
  });
}
