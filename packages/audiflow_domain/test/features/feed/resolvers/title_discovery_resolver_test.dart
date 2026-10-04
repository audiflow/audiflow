import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(int id, String title, DateTime publishedAt) {
  return Episode()
    ..id = id
    ..podcastId = 1
    ..guid = 'guid-$id'
    ..title = title
    ..audioUrl = 'https://example.com/$id.mp3'
    ..publishedAt = publishedAt;
}

const _hintDefinition = SmartPlaylistDefinition(
  id: 'test',
  displayName: 'Test',
  grouping: GroupingConfig(
    by: 'titleDiscovery',
    discoveryHint: r'\[(\w+)\s+\d+\]',
  ),
  priority: 0,
);

Map<String, String> _idsByName(SmartPlaylistGrouping grouping) => {
  for (final p in grouping.playlists) p.displayName: p.id,
};

void main() {
  group('TitleDiscoveryResolver', () {
    late TitleDiscoveryResolver resolver;

    setUp(() {
      resolver = TitleDiscoveryResolver();
    });

    test('type is "titleDiscovery"', () {
      expect(resolver.type, 'titleDiscovery');
    });

    test('returns null when no definition provided', () {
      final episodes = [
        _makeEpisode(1, '[Rome 1] First', DateTime(2024, 1, 1)),
      ];

      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });

    test('groups by first appearance order using group pattern', () {
      const definition = SmartPlaylistDefinition(
        id: 'test',
        displayName: 'Test',
        grouping: GroupingConfig(
          by: 'titleDiscovery',
          discoveryHint: r'\[(\w+)\s+\d+\]',
        ),
        priority: 0,
      );

      // Episodes in feed order (newest first typically)
      final episodes = [
        _makeEpisode(6, '[Firenze 1] Renaissance', DateTime(2024, 3, 1)),
        _makeEpisode(5, '[Venezia 2] Canals', DateTime(2024, 2, 15)),
        _makeEpisode(4, '[Venezia 1] Arrival', DateTime(2024, 2, 1)),
        _makeEpisode(3, '[Rome 3] Colosseum', DateTime(2024, 1, 20)),
        _makeEpisode(2, '[Rome 2] Vatican', DateTime(2024, 1, 10)),
        _makeEpisode(1, '[Rome 1] First Steps', DateTime(2024, 1, 1)),
      ];

      final result = resolver.resolve(episodes, definition);

      expect(result, isNotNull);
      expect(result!.playlists.length, 3);

      // Rome appeared first chronologically, so it's season 1
      expect(result.playlists[0].displayName, 'Rome');
      expect(result.playlists[0].sortKey, 1);
      expect(result.playlists[0].episodeIds, containsAll([1, 2, 3]));

      // Venezia appeared second
      expect(result.playlists[1].displayName, 'Venezia');
      expect(result.playlists[1].sortKey, 2);

      // Firenze appeared third
      expect(result.playlists[2].displayName, 'Firenze');
      expect(result.playlists[2].sortKey, 3);
    });

    test('non-matching episodes go to ungrouped', () {
      const definition = SmartPlaylistDefinition(
        id: 'test',
        displayName: 'Test',
        grouping: GroupingConfig(
          by: 'titleDiscovery',
          discoveryHint: r'\[(\w+)\s+\d+\]',
        ),
        priority: 0,
      );

      final episodes = [
        _makeEpisode(1, '[Rome 1] First', DateTime(2024, 1, 1)),
        _makeEpisode(2, 'Bonus Episode', DateTime(2024, 1, 5)), // No match
      ];

      final result = resolver.resolve(episodes, definition);

      expect(result, isNotNull);
      expect(result!.ungroupedEpisodeIds, [2]);
    });

    test('returns null when no matches found', () {
      const definition = SmartPlaylistDefinition(
        id: 'test',
        displayName: 'Test',
        grouping: GroupingConfig(
          by: 'titleDiscovery',
          discoveryHint: r'\[(\w+)\s+\d+\]',
        ),
        priority: 0,
      );

      final episodes = [
        _makeEpisode(1, 'No Pattern Here', DateTime(2024, 1, 1)),
        _makeEpisode(2, 'Another One', DateTime(2024, 1, 2)),
      ];

      final result = resolver.resolve(episodes, definition);
      expect(result, isNull);
    });

    group('playlist ids', () {
      final rome = _makeEpisode(1, '[Rome 1] First', DateTime(2024, 1, 1));
      final venezia = _makeEpisode(2, '[Venezia 1] Canals', DateTime(2024, 2));
      final firenze = _makeEpisode(3, '[Firenze 1] Arts', DateTime(2024, 3));

      test('stay the same when the earliest series is dropped', () {
        final resolver = TitleDiscoveryResolver();
        final before = resolver.resolve([
          rome,
          venezia,
          firenze,
        ], _hintDefinition);
        final after = resolver.resolve([venezia, firenze], _hintDefinition);

        check(
          _idsByName(after!)['Venezia'],
        ).equals(_idsByName(before!)['Venezia']);
        check(
          _idsByName(after)['Firenze'],
        ).equals(_idsByName(before)['Firenze']);
      });

      test('stay the same when an older series is backfilled, while sortKey '
          'follows appearance order', () {
        final resolver = TitleDiscoveryResolver();
        final before = resolver.resolve([venezia, firenze], _hintDefinition);
        final after = resolver.resolve([
          rome,
          venezia,
          firenze,
        ], _hintDefinition);

        check(
          _idsByName(after!)['Venezia'],
        ).equals(_idsByName(before!)['Venezia']);
        check(
          after.playlists.map((p) => p.displayName),
        ).deepEquals(['Rome', 'Venezia', 'Firenze']);
        check(after.playlists.map((p) => p.sortKey)).deepEquals([1, 2, 3]);
      });

      test('are distinct per series and never positional', () {
        final result = TitleDiscoveryResolver().resolve([
          rome,
          venezia,
          firenze,
        ], _hintDefinition)!;

        final ids = result.playlists.map((p) => p.id).toList();
        check(ids.toSet()).length.equals(3);
        for (final id in ids) {
          check(id).not((it) => it.startsWith('season_'));
        }
      });
    });
  });
}
