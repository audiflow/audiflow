import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode({
  required int id,
  required String title,
  int? seasonNumber,
  int? episodeNumber,
}) {
  return Episode(
    id: id,
    podcastId: 1,
    guid: 'guid-$id',
    title: title,
    audioUrl: 'https://example.com/$id.mp3',
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
    publishedAt: DateTime(2024, 1, 1),
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
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1'),
        _makeEpisode(id: 2, title: 'Ep2'),
        _makeEpisode(id: 3, title: 'Ep3'),
      ];

      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });

    test('groups episodes by seasonNumber', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1, episodeNumber: 1),
        _makeEpisode(id: 2, title: 'Ep2', seasonNumber: 1, episodeNumber: 2),
        _makeEpisode(id: 3, title: 'Ep3', seasonNumber: 2, episodeNumber: 1),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons, hasLength(2));

      final season1 = result.seasons.firstWhere((s) => s.id == 'season_1');
      final season2 = result.seasons.firstWhere((s) => s.id == 'season_2');
      expect(season1.episodeIds, [1, 2]);
      expect(season2.episodeIds, [3]);
    });

    test('treats null seasonNumber as ungrouped by default', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1, episodeNumber: 1),
        _makeEpisode(
          id: 2,
          title: 'Ep2',
          seasonNumber: null,
          episodeNumber: 100,
        ),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons, hasLength(1));
      expect(result.ungroupedEpisodeIds, [2]);
    });

    test(
      'groups null/zero seasonNumber when groupNullSeasonAs is configured',
      () {
        final pattern = SeasonPattern(
          id: 'test',
          resolverType: 'rss',
          config: {'groupNullSeasonAs': 0},
        );
        final episodes = [
          _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 62, episodeNumber: 1),
          _makeEpisode(
            id: 2,
            title: 'Bangai1',
            seasonNumber: null,
            episodeNumber: 100,
          ),
          _makeEpisode(
            id: 3,
            title: 'Bangai2',
            seasonNumber: 0,
            episodeNumber: 101,
          ),
        ];

        final result = resolver.resolve(episodes, pattern);

        expect(result, isNotNull);
        expect(result!.seasons, hasLength(2));
        expect(result.ungroupedEpisodeIds, isEmpty);

        final season0 = result.seasons.firstWhere((s) => s.id == 'season_0');
        expect(season0.episodeIds, containsAll([2, 3]));
      },
    );

    test('calculates sortKey from max episodeNumber in season', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1, episodeNumber: 5),
        _makeEpisode(id: 2, title: 'Ep2', seasonNumber: 1, episodeNumber: 10),
        _makeEpisode(id: 3, title: 'Ep3', seasonNumber: 2, episodeNumber: 3),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      final season1 = result!.seasons.firstWhere((s) => s.id == 'season_1');
      final season2 = result.seasons.firstWhere((s) => s.id == 'season_2');

      expect(season1.sortKey, 10); // max of 5, 10
      expect(season2.sortKey, 3);
    });

    test('default sort is season number ascending', () {
      expect(resolver.defaultSort, isA<SimpleSeasonSort>());
      final sort = resolver.defaultSort as SimpleSeasonSort;
      expect(sort.field, SeasonSortField.seasonNumber);
      expect(sort.order, SortOrder.ascending);
    });

    test('sortKey is 0 when episodes have no episodeNumber', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1),
        _makeEpisode(id: 2, title: 'Ep2', seasonNumber: 1),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons[0].sortKey, 0);
    });

    test('uses max episodeNumber even with mixed null values', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1, episodeNumber: null),
        _makeEpisode(id: 2, title: 'Ep2', seasonNumber: 1, episodeNumber: 7),
        _makeEpisode(id: 3, title: 'Ep3', seasonNumber: 1, episodeNumber: 3),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.seasons[0].sortKey, 7); // max of null(0), 7, 3
    });
  });
}
