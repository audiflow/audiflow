import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EpisodeData interface', () {
    test('SimpleEpisodeData implements EpisodeData', () {
      const data = SimpleEpisodeData(title: 'Test');
      expect(data, isA<EpisodeData>());
    });
  });

  group('SimpleEpisodeData', () {
    test('stores required title', () {
      const data = SimpleEpisodeData(title: 'Episode 1');
      expect(data.title, 'Episode 1');
    });

    test('description defaults to null', () {
      const data = SimpleEpisodeData(title: 'Episode 1');
      expect(data.description, isNull);
    });

    test('seasonNumber defaults to null', () {
      const data = SimpleEpisodeData(title: 'Episode 1');
      expect(data.seasonNumber, isNull);
    });

    test('episodeNumber defaults to null', () {
      const data = SimpleEpisodeData(title: 'Episode 1');
      expect(data.episodeNumber, isNull);
    });

    test('stores all fields when provided', () {
      const data = SimpleEpisodeData(
        title: 'The Great Episode',
        description: 'A wonderful episode about testing',
        seasonNumber: 3,
        episodeNumber: 12,
      );
      expect(data.title, 'The Great Episode');
      expect(data.description, 'A wonderful episode about testing');
      expect(data.seasonNumber, 3);
      expect(data.episodeNumber, 12);
    });

    test('allows empty title', () {
      const data = SimpleEpisodeData(title: '');
      expect(data.title, '');
    });

    test('allows zero season number', () {
      const data = SimpleEpisodeData(title: 'Test', seasonNumber: 0);
      expect(data.seasonNumber, 0);
    });

    test('allows zero episode number', () {
      const data = SimpleEpisodeData(title: 'Test', episodeNumber: 0);
      expect(data.episodeNumber, 0);
    });

    test('allows empty description', () {
      const data = SimpleEpisodeData(title: 'Test', description: '');
      expect(data.description, '');
    });

    test('can be const-constructed', () {
      const data = SimpleEpisodeData(
        title: 'Const Episode',
        description: 'Const description',
        seasonNumber: 1,
        episodeNumber: 1,
      );
      expect(data.title, 'Const Episode');
    });

    test('title getter matches EpisodeData interface', () {
      const EpisodeData data = SimpleEpisodeData(title: 'Interface Test');
      expect(data.title, 'Interface Test');
    });

    test('description getter matches EpisodeData interface', () {
      const EpisodeData data = SimpleEpisodeData(
        title: 'Test',
        description: 'Description via interface',
      );
      expect(data.description, 'Description via interface');
    });

    test('seasonNumber getter matches EpisodeData interface', () {
      const EpisodeData data = SimpleEpisodeData(
        title: 'Test',
        seasonNumber: 5,
      );
      expect(data.seasonNumber, 5);
    });

    test('episodeNumber getter matches EpisodeData interface', () {
      const EpisodeData data = SimpleEpisodeData(
        title: 'Test',
        episodeNumber: 42,
      );
      expect(data.episodeNumber, 42);
    });
  });
}
