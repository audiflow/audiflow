import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(int id, {int? seasonNumber, int? episodeNumber}) {
  return Episode(
    id: id,
    podcastId: 1,
    guid: 'guid-$id',
    title: 'Episode $id',
    audioUrl: 'https://example.com/$id.mp3',
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
    publishedAt: DateTime(2024, 1, id),
    description: null,
    durationMs: null,
    imageUrl: null,
  );
}

void main() {
  group('RssMetadataResolver', () {
    late RssMetadataResolver resolver;

    setUp(() {
      resolver = RssMetadataResolver();
    });

    test('type is "rss"', () {
      expect(resolver.type, 'rss');
    });

    test('returns null when no episodes have season numbers', () {
      final episodes = [_makeEpisode(1), _makeEpisode(2), _makeEpisode(3)];

      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });

    test('groups episodes by seasonNumber', () {
      final episodes = [
        _makeEpisode(1, seasonNumber: 1, episodeNumber: 1),
        _makeEpisode(2, seasonNumber: 1, episodeNumber: 2),
        _makeEpisode(3, seasonNumber: 2, episodeNumber: 1),
        _makeEpisode(4, seasonNumber: 2, episodeNumber: 2),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons.length, 2);
      expect(result.seasons[0].displayName, 'Season 1');
      expect(result.seasons[0].episodeIds, [1, 2]);
      expect(result.seasons[1].displayName, 'Season 2');
      expect(result.seasons[1].episodeIds, [3, 4]);
    });

    test('episodes without seasonNumber go to ungrouped', () {
      final episodes = [
        _makeEpisode(1, seasonNumber: 1),
        _makeEpisode(2), // No season
        _makeEpisode(3, seasonNumber: 1),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons.length, 1);
      expect(result.ungroupedEpisodeIds, [2]);
    });

    test('default sort is season number ascending', () {
      expect(resolver.defaultSort, isA<SimpleSeasonSort>());
      final sort = resolver.defaultSort as SimpleSeasonSort;
      expect(sort.field, SeasonSortField.seasonNumber);
      expect(sort.order, SortOrder.ascending);
    });
  });
}
