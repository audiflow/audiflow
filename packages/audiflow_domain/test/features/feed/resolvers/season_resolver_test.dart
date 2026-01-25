import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

// Test implementation
class TestSeasonResolver implements SeasonResolver {
  @override
  String get type => 'test';

  @override
  SeasonSortSpec get defaultSort =>
      const SimpleSeasonSort(SeasonSortField.seasonNumber, SortOrder.ascending);

  @override
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern) {
    if (episodes.isEmpty) return null;
    return SeasonGrouping(
      seasons: [
        Season(
          id: 'test_season',
          displayName: 'Test',
          sortKey: 1,
          episodeIds: episodes.map((e) => e.id).toList(),
        ),
      ],
      ungroupedEpisodeIds: [],
      resolverType: type,
    );
  }
}

void main() {
  group('SeasonResolver', () {
    test('resolver has type identifier', () {
      final resolver = TestSeasonResolver();
      expect(resolver.type, 'test');
    });

    test('resolver has default sort', () {
      final resolver = TestSeasonResolver();
      expect(resolver.defaultSort, isA<SimpleSeasonSort>());
    });

    test('resolver can return null when no grouping possible', () {
      final resolver = TestSeasonResolver();
      final result = resolver.resolve([], null);
      expect(result, isNull);
    });
  });
}
