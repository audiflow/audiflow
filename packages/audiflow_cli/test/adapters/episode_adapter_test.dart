import 'package:audiflow_cli/src/adapters/episode_adapter.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toEpisode', () {
    test('converts PodcastItem to Episode with all fields', () {
      final item = PodcastItem(
        parsedAt: DateTime(2024, 1, 1),
        sourceUrl: 'https://example.com/feed',
        title: '【62-15】Test Episode【COTEN RADIO リンカン編15】',
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
      expect(episode.guid, 'guid-123');
      expect(episode.audioUrl, 'https://example.com/audio.mp3');
      expect(episode.seasonNumber, 62);
      expect(episode.episodeNumber, 15);
      expect(episode.publishedAt, DateTime(2024, 1, 15));
    });

    test('handles null optional fields', () {
      final item = PodcastItem(
        parsedAt: DateTime(2024, 1, 1),
        sourceUrl: 'https://example.com/feed',
        title: '【番外編#135】Test',
        description: '',
        guid: null,
        enclosureUrl: null,
        seasonNumber: null,
        episodeNumber: 135,
        publishDate: null,
      );

      final episode = toEpisode(item);

      expect(episode.title, '【番外編#135】Test');
      expect(episode.guid, '');
      expect(episode.audioUrl, '');
      expect(episode.seasonNumber, isNull);
      expect(episode.episodeNumber, 135);
      expect(episode.publishedAt, isNull);
    });
  });
}
