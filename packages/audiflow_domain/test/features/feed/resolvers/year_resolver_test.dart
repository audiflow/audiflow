import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(int id, {DateTime? publishedAt}) {
  return Episode(
    id: id,
    podcastId: 1,
    guid: 'guid-$id',
    title: 'Episode $id',
    audioUrl: 'https://example.com/$id.mp3',
    publishedAt: publishedAt,
    description: null,
    durationMs: null,
    imageUrl: null,
    seasonNumber: null,
    episodeNumber: null,
  );
}

void main() {
  group('YearResolver', () {
    late YearResolver resolver;

    setUp(() {
      resolver = YearResolver();
    });

    test('type is "year"', () {
      expect(resolver.type, 'year');
    });

    test('returns null when no episodes have publish dates', () {
      final episodes = [_makeEpisode(1), _makeEpisode(2)];

      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });

    test('groups episodes by publish year', () {
      final episodes = [
        _makeEpisode(1, publishedAt: DateTime(2023, 3, 15)),
        _makeEpisode(2, publishedAt: DateTime(2023, 8, 20)),
        _makeEpisode(3, publishedAt: DateTime(2024, 1, 10)),
        _makeEpisode(4, publishedAt: DateTime(2024, 6, 5)),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons.length, 2);
      expect(result.seasons[0].displayName, '2024');
      expect(result.seasons[0].episodeIds, [3, 4]);
      expect(result.seasons[1].displayName, '2023');
      expect(result.seasons[1].episodeIds, [1, 2]);
    });

    test('episodes without publishedAt go to ungrouped', () {
      final episodes = [
        _makeEpisode(1, publishedAt: DateTime(2024, 1, 1)),
        _makeEpisode(2), // No date
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.ungroupedEpisodeIds, [2]);
    });

    test('default sort is year descending (newest first)', () {
      expect(resolver.defaultSort, isA<SimpleSeasonSort>());
      final sort = resolver.defaultSort as SimpleSeasonSort;
      expect(sort.field, SeasonSortField.seasonNumber);
      expect(sort.order, SortOrder.descending);
    });
  });
}
