import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylist', () {
    test('SmartPlaylist holds episode list and metadata', () {
      final playlist = SmartPlaylist(
        id: 'smart_playlist_1',
        displayName: 'Smart Playlist 1',
        sortKey: 1,
        episodeIds: [1, 2, 3],
      );

      expect(playlist.id, 'smart_playlist_1');
      expect(playlist.displayName, 'Smart Playlist 1');
      expect(playlist.sortKey, 1);
      expect(playlist.episodeIds, [1, 2, 3]);
    });

    test('SmartPlaylist.episodeCount returns correct count', () {
      final playlist = SmartPlaylist(
        id: 'smart_playlist_2',
        displayName: 'Smart Playlist 2',
        sortKey: 2,
        episodeIds: [4, 5, 6, 7, 8],
      );

      expect(playlist.episodeCount, 5);
    });
  });

  group('SmartPlaylistGrouping', () {
    test('SmartPlaylistGrouping holds playlists and '
        'ungrouped episodes', () {
      final grouping = SmartPlaylistGrouping(
        playlists: [
          SmartPlaylist(
            id: 's1',
            displayName: 'S1',
            sortKey: 1,
            episodeIds: [1, 2],
          ),
        ],
        ungroupedEpisodeIds: [10, 11],
        resolverType: 'rss',
      );

      expect(grouping.playlists.length, 1);
      expect(grouping.ungroupedEpisodeIds, [10, 11]);
      expect(grouping.resolverType, 'rss');
    });

    test('SmartPlaylistGrouping.hasUngrouped returns true '
        'when ungrouped exist', () {
      final withUngrouped = SmartPlaylistGrouping(
        playlists: [],
        ungroupedEpisodeIds: [1],
        resolverType: 'rss',
      );
      final withoutUngrouped = SmartPlaylistGrouping(
        playlists: [],
        ungroupedEpisodeIds: [],
        resolverType: 'rss',
      );

      expect(withUngrouped.hasUngrouped, isTrue);
      expect(withoutUngrouped.hasUngrouped, isFalse);
    });
  });
}
