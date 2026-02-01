import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylist.yearHeaderMode', () {
    test('defaults to none', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
      );
      expect(playlist.yearHeaderMode, YearHeaderMode.none);
    });

    test('can be set to firstEpisode', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearHeaderMode: YearHeaderMode.firstEpisode,
      );
      expect(playlist.yearHeaderMode, YearHeaderMode.firstEpisode);
    });

    test('copyWith preserves yearHeaderMode', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearHeaderMode: YearHeaderMode.perEpisode,
      );
      final copy = playlist.copyWith(displayName: 'Updated');
      expect(copy.yearHeaderMode, YearHeaderMode.perEpisode);
    });
  });
}
