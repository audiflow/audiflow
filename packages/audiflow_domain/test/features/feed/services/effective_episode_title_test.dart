import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _episode({
  String title = 'Raw Title',
  String? description,
  int? season,
  int? number,
}) {
  return Episode()
    ..podcastId = 1
    ..guid = 'guid'
    ..title = title
    ..description = description
    ..audioUrl = 'https://example.com/a.mp3'
    ..seasonNumber = season
    ..episodeNumber = number;
}

SmartPlaylistDefinition _playlist({SmartPlaylistTitleExtractor? extractor}) {
  return SmartPlaylistDefinition(
    id: 'main',
    displayName: 'Main',
    grouping: const GroupingConfig(by: 'seasonNumber'),
    priority: 0,
    episodeItem: extractor == null
        ? null
        : EpisodeItemConfig(titleExtractor: extractor),
  );
}

void main() {
  group('EffectiveEpisodeTitle.forPlaylist', () {
    test('returns null when playlist is null', () {
      final result = EffectiveEpisodeTitle.forPlaylist(
        playlist: null,
        episode: _episode(),
      );
      expect(result, isNull);
    });

    test('returns null when no episodeItem', () {
      final result = EffectiveEpisodeTitle.forPlaylist(
        playlist: _playlist(),
        episode: _episode(),
      );
      expect(result, isNull);
    });

    test('returns null when episodeItem has no titleExtractor', () {
      final playlist = SmartPlaylistDefinition(
        id: 'main',
        displayName: 'Main',
        grouping: const GroupingConfig(by: 'seasonNumber'),
        priority: 0,
        episodeItem: const EpisodeItemConfig(),
      );
      final result = EffectiveEpisodeTitle.forPlaylist(
        playlist: playlist,
        episode: _episode(),
      );
      expect(result, isNull);
    });

    test('returns extracted title when configured', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'^\[(.+?)\]\s*(.+)$',
        template: r'${2}',
      );
      final result = EffectiveEpisodeTitle.forPlaylist(
        playlist: _playlist(extractor: extractor),
        episode: _episode(title: '[Series A] Episode One'),
      );
      expect(result, equals('Episode One'));
    });

    test('returns null when extractor pattern does not match', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'^\[(.+?)\]',
        template: r'${1}',
      );
      final result = EffectiveEpisodeTitle.forPlaylist(
        playlist: _playlist(extractor: extractor),
        episode: _episode(title: 'No brackets here'),
      );
      expect(result, isNull);
    });

    test('returns null when extracted result is empty string', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'^(.*?)$',
        template: r'${5}',
      );
      final result = EffectiveEpisodeTitle.forPlaylist(
        playlist: _playlist(extractor: extractor),
        episode: _episode(title: 'anything'),
      );
      expect(result, isNull);
    });

    test('reads from description source', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'description',
        pattern: r'Topic:\s*(\w+)',
        template: r'${1}',
      );
      final result = EffectiveEpisodeTitle.forPlaylist(
        playlist: _playlist(extractor: extractor),
        episode: _episode(description: 'Topic: Flutter'),
      );
      expect(result, equals('Flutter'));
    });

    test('uses fallbackValue when seasonNumber missing', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'seasonNumber',
        template: r'Season ${0}',
        fallbackValue: 'Unknown',
      );
      final result = EffectiveEpisodeTitle.forPlaylist(
        playlist: _playlist(extractor: extractor),
        episode: _episode(season: null),
      );
      expect(result, equals('Unknown'));
    });

    test('uses fallback extractor chain when primary fails', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'^\[(.+?)\]',
        template: r'${1}',
        fallback: SmartPlaylistTitleExtractor(source: 'title'),
      );
      final result = EffectiveEpisodeTitle.forPlaylist(
        playlist: _playlist(extractor: extractor),
        episode: _episode(title: 'No brackets'),
      );
      expect(result, equals('No brackets'));
    });
  });
}
