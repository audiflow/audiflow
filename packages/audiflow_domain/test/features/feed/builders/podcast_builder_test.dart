import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DefaultPodcastBuilder builder;

  setUp(() {
    builder = DefaultPodcastBuilder();
  });

  group('DefaultPodcastBuilder', () {
    group('buildFeed', () {
      test('builds PodcastFeed from feed data map', () {
        final feedData = <String, dynamic>{
          'title': 'My Podcast',
          'description': 'A great podcast',
          'language': 'en',
          'itunesAuthor': 'Author Name',
          'itunesExplicit': false,
        };

        final feed = builder.buildFeed(feedData, 'https://example.com/rss');

        expect(feed, isA<PodcastFeed>());
        expect(feed.title, 'My Podcast');
        expect(feed.description, 'A great podcast');
        expect(feed.language, 'en');
        expect(feed.sourceUrl, 'https://example.com/rss');
      });

      test('builds feed with minimal data', () {
        final feedData = <String, dynamic>{
          'title': 'Minimal',
          'description': '',
        };

        final feed = builder.buildFeed(feedData, 'https://example.com/rss');

        expect(feed.title, 'Minimal');
        expect(feed.description, isEmpty);
      });

      test('builds feed with empty title uses fallback', () {
        final feedData = <String, dynamic>{'title': '', 'description': 'desc'};

        final feed = builder.buildFeed(feedData, 'https://example.com/rss');

        expect(feed.title, 'Untitled Podcast');
      });
    });

    group('buildItem', () {
      test('builds PodcastItem from item data map', () {
        final itemData = <String, dynamic>{
          'title': 'Episode 1',
          'description': 'First episode',
          'guid': 'ep-001',
          'pubDate': DateTime(2024, 1, 15),
          'itunesDuration': const Duration(minutes: 30),
          'itunesEpisode': 1,
          'itunesSeason': 1,
          'enclosure': <String, dynamic>{
            'url': 'https://example.com/ep1.mp3',
            'type': 'audio/mpeg',
            'length': 15000000,
          },
        };

        final item = builder.buildItem(itemData, 'https://example.com/rss');

        expect(item, isA<PodcastItem>());
        expect(item.title, 'Episode 1');
        expect(item.description, 'First episode');
        expect(item.guid, 'ep-001');
        expect(item.episodeNumber, 1);
        expect(item.seasonNumber, 1);
        expect(item.enclosureUrl, 'https://example.com/ep1.mp3');
        expect(item.enclosureType, 'audio/mpeg');
        expect(item.sourceUrl, 'https://example.com/rss');
      });

      test('builds item with minimal data', () {
        final itemData = <String, dynamic>{
          'title': 'Episode',
          'description': '',
        };

        final item = builder.buildItem(itemData, 'https://example.com/rss');

        expect(item.title, 'Episode');
        expect(item.episodeNumber, isNull);
        expect(item.seasonNumber, isNull);
      });
    });

    group('onError', () {
      test('handles parse error without throwing', () {
        final error = XmlParsingError(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/rss',
          message: 'malformed xml',
        );

        // Should not throw
        expect(() => builder.onError(error), returnsNormally);
      });
    });

    group('onWarning', () {
      test('handles parse warning without throwing', () {
        final warning = PodcastParseWarning(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/rss',
          message: 'missing description',
        );

        // Should not throw
        expect(() => builder.onWarning(warning), returnsNormally);
      });
    });
  });

  group('ParsedFeed', () {
    late PodcastFeed podcast;

    setUp(() {
      podcast = PodcastFeed.fromData(
        parsedAt: DateTime.now(),
        sourceUrl: 'https://example.com/rss',
        title: 'Test Podcast',
        description: 'A test podcast',
      );
    });

    test('reports clean state with no errors or warnings', () {
      final parsed = ParsedFeed(podcast: podcast, episodes: const []);

      expect(parsed.hasNoErrors, isTrue);
      expect(parsed.hasNoWarnings, isTrue);
      expect(parsed.isClean, isTrue);
      expect(parsed.episodeCount, 0);
    });

    test('reports errors', () {
      final parsed = ParsedFeed(
        podcast: podcast,
        episodes: const [],
        errors: [
          XmlParsingError(
            parsedAt: DateTime.now(),
            sourceUrl: 'https://example.com/rss',
            message: 'bad xml',
          ),
        ],
      );

      expect(parsed.hasNoErrors, isFalse);
      expect(parsed.isClean, isFalse);
    });

    test('reports warnings', () {
      final parsed = ParsedFeed(
        podcast: podcast,
        episodes: const [],
        warnings: [
          PodcastParseWarning(
            parsedAt: DateTime.now(),
            sourceUrl: 'https://example.com/rss',
            message: 'missing field',
          ),
        ],
      );

      expect(parsed.hasNoWarnings, isFalse);
      expect(parsed.isClean, isFalse);
    });

    test('reports episode count', () {
      final items = [
        PodcastItem.fromData(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/rss',
          title: 'Ep 1',
          description: 'First',
        ),
        PodcastItem.fromData(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/rss',
          title: 'Ep 2',
          description: 'Second',
        ),
      ];

      final parsed = ParsedFeed(podcast: podcast, episodes: items);

      expect(parsed.episodeCount, 2);
    });
  });
}
