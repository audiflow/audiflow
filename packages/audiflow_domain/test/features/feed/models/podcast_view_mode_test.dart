import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PodcastViewMode', () {
    test('has exactly two values', () {
      expect(PodcastViewMode.values.length, 2);
    });

    test('contains episodes value', () {
      expect(PodcastViewMode.values, contains(PodcastViewMode.episodes));
    });

    test('contains smartPlaylists value', () {
      expect(PodcastViewMode.values, contains(PodcastViewMode.smartPlaylists));
    });

    test('values are in expected order', () {
      expect(PodcastViewMode.values[0], PodcastViewMode.episodes);
      expect(PodcastViewMode.values[1], PodcastViewMode.smartPlaylists);
    });

    test('name returns correct string for episodes', () {
      expect(PodcastViewMode.episodes.name, 'episodes');
    });

    test('name returns correct string for smartPlaylists', () {
      expect(PodcastViewMode.smartPlaylists.name, 'smartPlaylists');
    });
  });
}
