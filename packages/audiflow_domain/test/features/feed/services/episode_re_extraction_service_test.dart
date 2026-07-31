import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _episode({
  required int id,
  required String title,
  int? seasonNumber,
  int? episodeNumber,
}) => Episode()
  ..id = id
  ..podcastId = 1
  ..guid = 'guid-$id'
  ..title = title
  ..audioUrl = 'https://example.com/$id.mp3'
  ..seasonNumber = seasonNumber
  ..episodeNumber = episodeNumber;

PresetConfig _config({NumberingExtractor? numberingExtractor}) => PresetConfig(
  id: 'test-pattern',
  feedUrls: ['https://example.com/feed.xml'],
  playlists: [
    SmartPlaylistDefinition(
      id: 'regular',
      displayName: 'Regular Series',
      grouping: GroupingConfig(
        by: 'seasonNumber',
        numberingExtractor: numberingExtractor,
      ),
      priority: 0,
    ),
  ],
);

void main() {
  const extractor = NumberingExtractor(
    source: 'title',
    pattern: r'【(\d+)-(\d+)】',
  );

  group('EpisodeReExtractionService', () {
    test('refreshes stale numbering from the new config', () {
      final episodes = [
        // Ingested under an old config without an extractor, so the
        // persisted numbering never matched the title.
        _episode(id: 1, title: '【5-1】Bangladesh 1'),
        _episode(id: 2, title: '【5-2】Bangladesh 2', seasonNumber: 5),
      ];

      final changed = EpisodeReExtractionService().reExtract(
        episodes,
        _config(numberingExtractor: extractor),
      );

      check(changed.map((e) => e.id)).unorderedEquals([1, 2]);
      check(episodes[0].seasonNumber).equals(5);
      check(episodes[0].episodeNumber).equals(1);
      check(episodes[1].episodeNumber).equals(2);
    });

    test('returns only episodes whose numbering changed', () {
      final episodes = [
        _episode(
          id: 1,
          title: '【5-1】Bangladesh 1',
          seasonNumber: 5,
          episodeNumber: 1,
        ),
        _episode(id: 2, title: '【5-2】Bangladesh 2'),
      ];

      final changed = EpisodeReExtractionService().reExtract(
        episodes,
        _config(numberingExtractor: extractor),
      );

      check(changed.map((e) => e.id)).deepEquals([2]);
    });

    test('keeps existing numbering when no extractor matches', () {
      final episodes = [_episode(id: 1, title: 'Plain title', seasonNumber: 3)];

      final changed = EpisodeReExtractionService().reExtract(
        episodes,
        _config(),
      );

      check(changed).isEmpty();
      check(episodes[0].seasonNumber).equals(3);
    });
  });
}
