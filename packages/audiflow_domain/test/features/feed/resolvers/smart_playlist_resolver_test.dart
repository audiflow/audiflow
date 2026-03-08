import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test implementation.
class TestSmartPlaylistResolver implements SmartPlaylistResolver {
  @override
  String get type => 'test';

  @override
  SmartPlaylistSortRule get defaultSort => const SmartPlaylistSortRule(
    field: SmartPlaylistSortField.playlistNumber,
    order: SortOrder.ascending,
  );

  @override
  SmartPlaylistGrouping? resolve(
    List<Episode> episodes,
    SmartPlaylistDefinition? definition,
  ) {
    if (episodes.isEmpty) return null;
    return SmartPlaylistGrouping(
      playlists: [
        SmartPlaylist(
          id: 'test_playlist',
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
  group('SmartPlaylistResolver', () {
    test('resolver has type identifier', () {
      final resolver = TestSmartPlaylistResolver();
      expect(resolver.type, 'test');
    });

    test('resolver has default sort', () {
      final resolver = TestSmartPlaylistResolver();
      expect(resolver.defaultSort, isA<SmartPlaylistSortRule>());
      expect(resolver.defaultSort.field, SmartPlaylistSortField.playlistNumber);
    });

    test('resolver can return null when no grouping possible', () {
      final resolver = TestSmartPlaylistResolver();
      final result = resolver.resolve([], null);
      expect(result, isNull);
    });
  });
}
