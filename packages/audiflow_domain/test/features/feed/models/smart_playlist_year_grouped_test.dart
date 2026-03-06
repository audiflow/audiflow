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

    test('can be set to perEpisode', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearHeaderMode: YearHeaderMode.perEpisode,
      );
      expect(playlist.yearHeaderMode, YearHeaderMode.perEpisode);
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

    test('perEpisode is distinct from firstEpisode', () {
      const perEpisode = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearHeaderMode: YearHeaderMode.perEpisode,
      );
      const firstEpisode = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearHeaderMode: YearHeaderMode.firstEpisode,
      );

      expect(perEpisode.yearHeaderMode, isNot(firstEpisode.yearHeaderMode));
      expect(perEpisode.yearHeaderMode, YearHeaderMode.perEpisode);
      expect(firstEpisode.yearHeaderMode, YearHeaderMode.firstEpisode);
    });
  });

  group('YearHeaderMode.name round-trip', () {
    test('all modes survive name round-trip via '
        'parseYearHeaderMode', () {
      for (final mode in YearHeaderMode.values) {
        final parsed = RssMetadataResolver.parseYearHeaderMode(mode.name);
        expect(parsed, mode, reason: 'Failed for ${mode.name}');
      }
    });

    test('null parses to none', () {
      expect(
        RssMetadataResolver.parseYearHeaderMode(null),
        YearHeaderMode.none,
      );
    });

    test('unknown string parses to none', () {
      expect(
        RssMetadataResolver.parseYearHeaderMode('unknown'),
        YearHeaderMode.none,
      );
    });
  });
}
