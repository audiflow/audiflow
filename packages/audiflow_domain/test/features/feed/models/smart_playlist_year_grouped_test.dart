import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylist.yearBinding', () {
    test('defaults to none', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
      );
      expect(playlist.yearBinding, YearBinding.none);
    });

    test('can be set to pinToYear', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearBinding: YearBinding.pinToYear,
      );
      expect(playlist.yearBinding, YearBinding.pinToYear);
    });

    test('can be set to splitByYear', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearBinding: YearBinding.splitByYear,
      );
      expect(playlist.yearBinding, YearBinding.splitByYear);
    });

    test('copyWith preserves yearBinding', () {
      const playlist = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearBinding: YearBinding.splitByYear,
      );
      final copy = playlist.copyWith(displayName: 'Updated');
      expect(copy.yearBinding, YearBinding.splitByYear);
    });

    test('splitByYear is distinct from pinToYear', () {
      const splitByYear = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearBinding: YearBinding.splitByYear,
      );
      const pinToYear = SmartPlaylist(
        id: 'test',
        displayName: 'Test',
        sortKey: 1,
        episodeIds: [],
        yearBinding: YearBinding.pinToYear,
      );

      expect(splitByYear.yearBinding, isNot(pinToYear.yearBinding));
      expect(splitByYear.yearBinding, YearBinding.splitByYear);
      expect(pinToYear.yearBinding, YearBinding.pinToYear);
    });
  });

  group('YearBinding.name round-trip', () {
    test('all modes survive name round-trip via '
        'parseYearBinding', () {
      for (final mode in YearBinding.values) {
        final parsed = RssMetadataResolver.parseYearBinding(mode.name);
        expect(parsed, mode, reason: 'Failed for ${mode.name}');
      }
    });

    test('null parses to none', () {
      expect(RssMetadataResolver.parseYearBinding(null), YearBinding.none);
    });

    test('unknown string parses to none', () {
      expect(RssMetadataResolver.parseYearBinding('unknown'), YearBinding.none);
    });
  });
}
