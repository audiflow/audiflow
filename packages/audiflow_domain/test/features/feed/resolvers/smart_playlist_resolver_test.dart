import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test implementation.
class TestSmartPlaylistResolver implements SmartPlaylistResolver {
  @override
  String get type => 'test';

  @override
  SmartPlaylistSortSpec get defaultSort => const SimpleSmartPlaylistSort(
    SmartPlaylistSortField.playlistNumber,
    SortOrder.ascending,
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
      expect(resolver.defaultSort, isA<SimpleSmartPlaylistSort>());
    });

    test('resolver can return null when no grouping possible', () {
      final resolver = TestSmartPlaylistResolver();
      final result = resolver.resolve([], null);
      expect(result, isNull);
    });
  });
}
