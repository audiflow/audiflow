import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Episode.toPodcastItem', () {
    Episode buildFullEpisode() => Episode()
      ..id = 1
      ..podcastId = 10
      ..guid = 'guid-001'
      ..title = 'Episode Title'
      ..description = 'Plain description'
      ..summary = 'iTunes summary text'
      ..contentEncoded = '<p>Rich HTML content</p>'
      ..link = 'https://example.com/episode/1'
      ..audioUrl = 'https://example.com/ep.mp3'
      ..durationMs = 1800000
      ..publishedAt = DateTime.utc(2025, 1, 15)
      ..imageUrl = 'https://example.com/img.jpg'
      ..episodeNumber = 5
      ..seasonNumber = 2;

    test('maps all fields correctly', () {
      final item = buildFullEpisode().toPodcastItem(
        feedUrl: 'https://example.com/feed.xml',
      );

      check(item.title).equals('Episode Title');
      check(item.description).equals('Plain description');
      check(item.summary).equals('iTunes summary text');
      check(item.contentEncoded).equals('<p>Rich HTML content</p>');
      check(item.link).equals('https://example.com/episode/1');
      check(item.sourceUrl).equals('https://example.com/feed.xml');
      check(item.enclosureUrl).equals('https://example.com/ep.mp3');
      check(item.guid).equals('guid-001');
      check(item.episodeNumber).equals(5);
      check(item.seasonNumber).equals(2);
      check(item.duration).equals(const Duration(milliseconds: 1800000));
      check(item.publishDate).equals(DateTime.utc(2025, 1, 15));
    });

    test('maps imageUrl to images list', () {
      final item = buildFullEpisode().toPodcastItem();

      check(item.images).length.equals(1);
      check(item.images.first.url).equals('https://example.com/img.jpg');
    });

    test('produces empty images list when imageUrl is null', () {
      final episode = Episode()
        ..podcastId = 10
        ..guid = 'guid-no-img'
        ..title = 'No Image'
        ..audioUrl = 'https://example.com/ep.mp3';

      final item = episode.toPodcastItem();

      check(item.images).isEmpty();
    });

    test('defaults sourceUrl to empty string when feedUrl omitted', () {
      final item = buildFullEpisode().toPodcastItem();

      check(item.sourceUrl).equals('');
    });

    test('maps nullable fields as null when absent', () {
      final episode = Episode()
        ..podcastId = 10
        ..guid = 'guid-minimal'
        ..title = 'Minimal'
        ..audioUrl = 'https://example.com/ep.mp3';

      final item = episode.toPodcastItem();

      check(item.description).equals('');
      check(item.summary).isNull();
      check(item.contentEncoded).isNull();
      check(item.link).isNull();
      check(item.duration).isNull();
      check(item.publishDate).isNull();
      check(item.episodeNumber).isNull();
      check(item.seasonNumber).isNull();
    });

    test('handles zero duration', () {
      final episode = Episode()
        ..podcastId = 10
        ..guid = 'guid-zero-dur'
        ..title = 'Zero Duration'
        ..audioUrl = 'https://example.com/ep.mp3'
        ..durationMs = 0;

      final item = episode.toPodcastItem();

      check(item.duration).equals(Duration.zero);
    });
  });
}
