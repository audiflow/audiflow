import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:test/test.dart';

void main() {
  group('ParseProgress', () {
    test('ParsedPodcastMeta holds metadata', () {
      final meta = ParsedPodcastMeta(
        title: 'Test Podcast',
        description: 'A test podcast',
        author: 'Test Author',
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(meta.title, 'Test Podcast');
      expect(meta.description, 'A test podcast');
      expect(meta.author, 'Test Author');
      expect(meta.imageUrl, 'https://example.com/image.jpg');
    });

    test('ParsedEpisode holds episode data', () {
      final episode = ParsedEpisode(
        guid: 'episode-123',
        title: 'Episode 1',
        enclosureUrl: 'https://example.com/ep1.mp3',
      );

      expect(episode.guid, 'episode-123');
      expect(episode.title, 'Episode 1');
      expect(episode.enclosureUrl, 'https://example.com/ep1.mp3');
    });

    test('ParseComplete reports stats', () {
      final complete = ParseComplete(totalParsed: 50, stoppedEarly: true);

      expect(complete.totalParsed, 50);
      expect(complete.stoppedEarly, isTrue);
    });

    test('ParseProgress is sealed', () {
      // Verify exhaustive switch works
      ParseProgress progress = ParseComplete(
        totalParsed: 1,
        stoppedEarly: false,
      );

      final result = switch (progress) {
        ParsedPodcastMeta() => 'meta',
        ParsedEpisode() => 'episode',
        ParseComplete() => 'complete',
      };

      expect(result, 'complete');
    });
  });
}
