import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylist.yearGrouped', () {
    test('defaults to false', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
      );
      expect(playlist.yearGrouped, isFalse);
    });

    test('can be set to true', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearGrouped: true,
      );
      expect(playlist.yearGrouped, isTrue);
    });

    test('copyWith preserves yearGrouped', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearGrouped: true,
      );
      final copy = playlist.copyWith(displayName: 'Updated');
      expect(copy.yearGrouped, isTrue);
    });
  });
}
