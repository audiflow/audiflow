import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _episode({required int id, String? imageUrl}) => Episode()
  ..id = id
  ..podcastId = 1
  ..guid = 'guid-$id'
  ..title = 'Episode $id'
  ..audioUrl = 'https://example.com/$id.mp3'
  ..imageUrl = imageUrl;

void main() {
  group('findPodcastImageUrl', () {
    test('returns null for empty list', () {
      expect(findPodcastImageUrl([]), isNull);
    });

    test('returns null when no episodes have imageUrl', () {
      final episodes = [_episode(id: 1), _episode(id: 2), _episode(id: 3)];
      expect(findPodcastImageUrl(episodes), isNull);
    });

    test('returns url when all episodes share the same image', () {
      const url = 'https://example.com/podcast.jpg';
      final episodes = [
        _episode(id: 1, imageUrl: url),
        _episode(id: 2, imageUrl: url),
        _episode(id: 3, imageUrl: url),
      ];
      expect(findPodcastImageUrl(episodes), url);
    });

    test('returns url when clear majority share same image', () {
      const podcastUrl = 'https://example.com/podcast.jpg';
      const seasonUrl = 'https://example.com/season2.jpg';
      final episodes = [
        _episode(id: 1, imageUrl: podcastUrl),
        _episode(id: 2, imageUrl: podcastUrl),
        _episode(id: 3, imageUrl: podcastUrl),
        _episode(id: 4, imageUrl: seasonUrl),
      ];
      // 3 out of 4 = 75% — above 50% threshold
      expect(findPodcastImageUrl(episodes), podcastUrl);
    });

    test('returns null when two seasons have equal count', () {
      const season1 = 'https://example.com/season1.jpg';
      const season2 = 'https://example.com/season2.jpg';
      final episodes = [
        _episode(id: 1, imageUrl: season1),
        _episode(id: 2, imageUrl: season1),
        _episode(id: 3, imageUrl: season2),
        _episode(id: 4, imageUrl: season2),
      ];
      // 2 out of 4 = 50% — not above threshold
      expect(findPodcastImageUrl(episodes), isNull);
    });

    test('returns null when no image has strict majority', () {
      const url1 = 'https://example.com/a.jpg';
      const url2 = 'https://example.com/b.jpg';
      const url3 = 'https://example.com/c.jpg';
      final episodes = [
        _episode(id: 1, imageUrl: url1),
        _episode(id: 2, imageUrl: url1),
        _episode(id: 3, imageUrl: url2),
        _episode(id: 4, imageUrl: url2),
        _episode(id: 5, imageUrl: url3),
      ];
      // 2 out of 5 = 40% — below threshold
      expect(findPodcastImageUrl(episodes), isNull);
    });

    test('ignores episodes without imageUrl for threshold', () {
      const podcastUrl = 'https://example.com/podcast.jpg';
      const otherUrl = 'https://example.com/other.jpg';
      final episodes = [
        _episode(id: 1, imageUrl: podcastUrl),
        _episode(id: 2, imageUrl: podcastUrl),
        _episode(id: 3, imageUrl: otherUrl),
        _episode(id: 4), // no imageUrl
        _episode(id: 5), // no imageUrl
      ];
      // 2 out of 3 with images = 66% — above threshold
      expect(findPodcastImageUrl(episodes), podcastUrl);
    });

    test('returns url for single episode with image', () {
      final episodes = [
        _episode(id: 1, imageUrl: 'https://example.com/solo.jpg'),
      ];
      // 1 out of 1 = 100%
      expect(findPodcastImageUrl(episodes), 'https://example.com/solo.jpg');
    });
  });
}
