import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionToPodcast', () {
    test('converts subscription to Podcast with all fields', () {
      final subscription = Subscription()
        ..id = 1
        ..itunesId = '12345'
        ..feedUrl = 'https://example.com/feed.xml'
        ..title = 'Test Podcast'
        ..artistName = 'Test Artist'
        ..artworkUrl = 'https://example.com/art.jpg'
        ..description = 'A great podcast about testing'
        ..genres = 'Technology,Science'
        ..explicit = true
        ..subscribedAt = DateTime(2024, 1, 1)
        ..lastRefreshedAt = DateTime(2024, 6, 1);

      final podcast = subscription.toPodcast();

      expect(podcast.id, '12345');
      expect(podcast.name, 'Test Podcast');
      expect(podcast.artistName, 'Test Artist');
      expect(podcast.feedUrl, 'https://example.com/feed.xml');
      expect(podcast.artworkUrl, 'https://example.com/art.jpg');
      expect(podcast.description, 'A great podcast about testing');
      expect(podcast.genres, ['Technology', 'Science']);
      expect(podcast.explicit, isTrue);
    });

    test('converts subscription with nullable fields as null', () {
      final subscription = Subscription()
        ..id = 2
        ..itunesId = '67890'
        ..feedUrl = 'https://example.com/feed2.xml'
        ..title = 'Minimal Podcast'
        ..artistName = 'Minimal Artist'
        ..genres = ''
        ..explicit = false
        ..subscribedAt = DateTime(2024, 3, 15);

      final podcast = subscription.toPodcast();

      expect(podcast.id, '67890');
      expect(podcast.name, 'Minimal Podcast');
      expect(podcast.artworkUrl, isNull);
      expect(podcast.description, isNull);
      expect(podcast.genres, isEmpty);
      expect(podcast.explicit, isFalse);
    });

    test('splits comma-separated genres correctly', () {
      final subscription = Subscription()
        ..id = 3
        ..itunesId = '111'
        ..feedUrl = 'https://example.com/feed.xml'
        ..title = 'Genre Podcast'
        ..artistName = 'Artist'
        ..genres = 'Comedy,News,Sports'
        ..explicit = false
        ..subscribedAt = DateTime(2024, 1, 1);

      final podcast = subscription.toPodcast();

      expect(podcast.genres, ['Comedy', 'News', 'Sports']);
      expect(podcast.genres.length, 3);
    });

    test('handles single genre', () {
      final subscription = Subscription()
        ..id = 4
        ..itunesId = '222'
        ..feedUrl = 'https://example.com/feed.xml'
        ..title = 'Single Genre'
        ..artistName = 'Artist'
        ..genres = 'Music'
        ..explicit = false
        ..subscribedAt = DateTime(2024, 1, 1);

      final podcast = subscription.toPodcast();

      expect(podcast.genres, ['Music']);
    });

    test('empty genres string produces empty list', () {
      final subscription = Subscription()
        ..id = 5
        ..itunesId = '333'
        ..feedUrl = 'https://example.com/feed.xml'
        ..title = 'No Genres'
        ..artistName = 'Artist'
        ..genres = ''
        ..explicit = false
        ..subscribedAt = DateTime(2024, 1, 1);

      final podcast = subscription.toPodcast();

      expect(podcast.genres, isEmpty);
    });
  });
}
