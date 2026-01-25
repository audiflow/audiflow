import 'package:audiflow_cli/src/adapters/episode_adapter.dart';
import 'package:audiflow_podcast/parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toEpisode', () {
    test('converts PodcastItem to SimpleEpisodeData with all fields', () {
      final item = PodcastItem(
        parsedAt: DateTime(2024, 1, 1),
        sourceUrl: 'https://example.com/feed',
        title: 'Test Episode',
        description: 'Episode description',
        guid: 'guid-123',
        enclosureUrl: 'https://example.com/audio.mp3',
        seasonNumber: 62,
        episodeNumber: 15,
        publishDate: DateTime(2024, 1, 15),
      );

      final episode = toEpisode(item);

      expect(episode.title, item.title);
      expect(episode.description, item.description);
      expect(episode.seasonNumber, 62);
      expect(episode.episodeNumber, 15);
    });

    test('handles null optional fields', () {
      final item = PodcastItem(
        parsedAt: DateTime(2024, 1, 1),
        sourceUrl: 'https://example.com/feed',
        title: 'Test',
        description: '',
        guid: null,
        enclosureUrl: null,
        seasonNumber: null,
        episodeNumber: 135,
        publishDate: null,
      );

      final episode = toEpisode(item);

      expect(episode.title, 'Test');
      expect(episode.description, isNull); // Empty description becomes null
      expect(episode.seasonNumber, isNull);
      expect(episode.episodeNumber, 135);
    });
  });
}
