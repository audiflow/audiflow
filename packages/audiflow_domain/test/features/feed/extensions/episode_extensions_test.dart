import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/feed/extensions/episode_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EpisodeToEpisodeData', () {
    test('converts episode with all fields', () {
      final episode = Episode()
        ..id = 1
        ..podcastId = 10
        ..guid = 'guid-001'
        ..title = 'Episode Title'
        ..description = 'Episode description text'
        ..audioUrl = 'https://example.com/ep.mp3'
        ..durationMs = 1800000
        ..publishedAt = null
        ..imageUrl = 'https://example.com/img.jpg'
        ..episodeNumber = 5
        ..seasonNumber = 2;

      final data = episode.toEpisodeData();

      expect(data, isA<SimpleEpisodeData>());
      expect(data.title, 'Episode Title');
      expect(data.description, 'Episode description text');
      expect(data.episodeNumber, 5);
      expect(data.seasonNumber, 2);
    });

    test('converts episode with nullable fields as null', () {
      final episode = Episode()
        ..id = 2
        ..podcastId = 10
        ..guid = 'guid-002'
        ..title = 'Minimal Episode'
        ..audioUrl = 'https://example.com/ep2.mp3';

      final data = episode.toEpisodeData();

      expect(data.title, 'Minimal Episode');
      expect(data.description, isNull);
      expect(data.episodeNumber, isNull);
      expect(data.seasonNumber, isNull);
    });

    test('preserves episode number zero', () {
      final episode = Episode()
        ..id = 3
        ..podcastId = 10
        ..guid = 'guid-003'
        ..title = 'Bonus'
        ..audioUrl = 'https://example.com/bonus.mp3'
        ..episodeNumber = 0
        ..seasonNumber = 0;

      final data = episode.toEpisodeData();

      expect(data.episodeNumber, 0);
      expect(data.seasonNumber, 0);
    });

    test('preserves empty description', () {
      final episode = Episode()
        ..id = 4
        ..podcastId = 10
        ..guid = 'guid-004'
        ..title = 'No Desc'
        ..description = ''
        ..audioUrl = 'https://example.com/ep4.mp3';

      final data = episode.toEpisodeData();

      expect(data.description, '');
    });
  });
}
