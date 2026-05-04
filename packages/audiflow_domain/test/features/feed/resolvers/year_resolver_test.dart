import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(int id, {DateTime? publishedAt}) {
  return Episode()
    ..id = id
    ..podcastId = 1
    ..guid = 'guid-$id'
    ..title = 'Episode $id'
    ..audioUrl = 'https://example.com/$id.mp3'
    ..publishedAt = publishedAt;
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
      final episodes = List.generate(30, (i) => _makeEpisode(i + 1));

      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });

    test('groups episodes by publish year', () {
      final episodes = [
        for (var i = 0; i < 15; i++)
          _makeEpisode(i + 1, publishedAt: DateTime(2023, 3, (i % 28) + 1)),
        for (var i = 0; i < 15; i++)
          _makeEpisode(i + 16, publishedAt: DateTime(2024, 1, (i % 28) + 1)),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.playlists.length, 2);
      expect(result.playlists[0].displayName, '2024');
      expect(result.playlists[0].episodeIds, List.generate(15, (i) => i + 16));
      expect(result.playlists[1].displayName, '2023');
      expect(result.playlists[1].episodeIds, List.generate(15, (i) => i + 1));
    });

    test('episodes without publishedAt go to ungrouped', () {
      final dated = List.generate(
        29,
        (i) =>
            _makeEpisode(i + 1, publishedAt: DateTime(2024, 1, (i % 28) + 1)),
      );
      final undated = _makeEpisode(30); // No date

      final result = resolver.resolve([...dated, undated], null);

      expect(result, isNotNull);
      expect(result!.ungroupedEpisodeIds, [30]);
    });

    test(
      'returns null on auto-detect when episode count is below threshold',
      () {
        final episodes = List.generate(
          29,
          (i) => _makeEpisode(i + 1, publishedAt: DateTime(2024, 1, i + 1)),
        );

        final result = resolver.resolve(episodes, null);

        expect(result, isNull);
      },
    );

    test(
      'returns grouping on auto-detect when episode count meets threshold',
      () {
        final episodes = List.generate(
          30,
          (i) => _makeEpisode(i + 1, publishedAt: DateTime(2024, 1, i + 1)),
        );

        final result = resolver.resolve(episodes, null);

        expect(result, isNotNull);
        expect(result!.playlists, hasLength(1));
        expect(result.playlists.first.displayName, '2024');
      },
    );

    test('explicit definition bypasses threshold for small feeds', () {
      final episodes = List.generate(
        5,
        (i) => _makeEpisode(i + 1, publishedAt: DateTime(2024, 1, i + 1)),
      );

      final definition = const SmartPlaylistDefinition(
        id: 'years',
        displayName: 'Years',
        grouping: GroupingConfig(by: 'year'),
        priority: 0,
      );

      final result = resolver.resolve(episodes, definition);

      expect(result, isNotNull);
      expect(result!.playlists, hasLength(1));
    });

    test('heuristicVersion is bumped to 2', () {
      expect(resolver.heuristicVersion, 2);
    });

    test('default sort is year descending (newest first)', () {
      expect(resolver.defaultSort, isA<SmartPlaylistSortRule>());
      expect(resolver.defaultSort.field, SmartPlaylistSortField.playlistNumber);
      expect(resolver.defaultSort.order, SortOrder.descending);
    });
  });
}
