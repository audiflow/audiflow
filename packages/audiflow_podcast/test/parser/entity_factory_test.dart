import 'package:audiflow_podcast/src/errors/podcast_parse_error.dart';
import 'package:audiflow_podcast/src/parser/entity_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EntityFactory', () {
    late EntityFactory factory;

    setUp(() {
      factory = EntityFactory();
    });

    group('createFeed', () {
      test('creates feed with complete RSS data', () {
        final feedData = {
          'title': 'Test Podcast',
          'description': 'A test podcast description',
          'link': 'https://example.com',
          'language': 'en-US',
          'copyright': '© 2024 Test',
          'managingEditor': 'editor@example.com',
          'webMaster': 'webmaster@example.com',
          'generator': 'Test Generator',
          'lastBuildDate': '2024-01-01T12:00:00Z',
          'pubDate': '2024-01-01T10:00:00Z',
          'ttl': 60,
          'categories': ['Technology', 'Education'],
          'image': {
            'url': 'https://example.com/image.jpg',
            'title': 'Podcast Image',
            'width': 300,
            'height': 300,
          },
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        expect(feed, isNotNull);
        expect(feed!.title, equals('Test Podcast'));
        expect(feed.description, equals('A test podcast description'));
        expect(feed.link, equals('https://example.com'));
        expect(feed.language, equals('en-US'));
        expect(feed.copyright, equals('© 2024 Test'));
        expect(feed.managingEditor, equals('editor@example.com'));
        expect(feed.webMaster, equals('webmaster@example.com'));
        expect(feed.generator, equals('Test Generator'));
        expect(feed.ttl, equals(60));
        expect(feed.categories, equals(['Technology', 'Education']));
        expect(feed.images, hasLength(1));
        expect(feed.images.first.url, equals('https://example.com/image.jpg'));
        expect(feed.images.first.width, equals(300));
        expect(feed.images.first.height, equals(300));
      });

      test('creates feed with iTunes namespace data', () {
        final feedData = {
          'title': 'iTunes Podcast',
          'description': 'An iTunes podcast',
          'itunesAuthor': 'iTunes Author',
          'itunesSubtitle': 'iTunes Subtitle',
          'itunesSummary': 'iTunes Summary',
          'itunesExplicit': true,
          'itunesType': 'episodic',
          'itunesComplete': false,
          'itunesNewFeedUrl': 'https://example.com/new-feed.xml',
          'itunesImage': 'https://example.com/itunes-image.jpg',
          'itunesCategories': ['Arts', 'Music'],
          'itunesOwner': {'name': 'Owner Name', 'email': 'owner@example.com'},
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        expect(feed, isNotNull);
        expect(feed!.title, equals('iTunes Podcast'));
        expect(feed.description, equals('An iTunes podcast'));
        expect(feed.author, equals('iTunes Author'));
        expect(feed.subtitle, equals('iTunes Subtitle'));
        expect(feed.summary, equals('iTunes Summary'));
        expect(feed.isExplicit, isTrue);
        expect(feed.type, equals('episodic'));
        expect(feed.isComplete, isFalse);
        expect(feed.newFeedUrl, equals('https://example.com/new-feed.xml'));
        expect(feed.ownerName, equals('Owner Name'));
        expect(feed.ownerEmail, equals('owner@example.com'));
        expect(feed.categories, equals(['Arts', 'Music']));
        expect(feed.images, hasLength(1));
        expect(
          feed.images.first.url,
          equals('https://example.com/itunes-image.jpg'),
        );
      });

      test('handles missing required fields with defaults', () {
        final feedData = <String, dynamic>{};

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        expect(feed, isNotNull);
        expect(feed!.title, equals('Untitled Podcast'));
        expect(feed.description, equals('No description available'));
        expect(feed.author, isNull);
        expect(feed.language, isNull);
        expect(feed.categories, isEmpty);
        expect(feed.images, isEmpty);
        expect(feed.isExplicit, isFalse);
      });

      test('combines RSS and iTunes categories', () {
        final feedData = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'categories': ['Technology', 'Science'],
          'itunesCategories': [
            'Education',
            'Technology',
          ], // Duplicate should be ignored
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        expect(feed, isNotNull);
        expect(
          feed!.categories,
          equals(['Technology', 'Science', 'Education']),
        );
      });

      test('handles both RSS and iTunes images', () {
        final feedData = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'image': {
            'url': 'https://example.com/rss-image.jpg',
            'width': 144,
            'height': 144,
          },
          'itunesImage': 'https://example.com/itunes-image.jpg',
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        expect(feed, isNotNull);
        expect(feed!.images, hasLength(2));
        expect(feed.images[0].url, equals('https://example.com/rss-image.jpg'));
        expect(feed.images[0].width, equals(144));
        expect(
          feed.images[1].url,
          equals('https://example.com/itunes-image.jpg'),
        );
      });

      test('normalizes iTunes type values', () {
        final feedData1 = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'itunesType': 'EPISODIC',
        };

        final feed1 = factory.createFeed(
          feedData1,
          'https://example.com/feed.xml',
        );
        expect(feed1!.type, equals('episodic'));

        final feedData2 = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'itunesType': 'invalid',
        };

        final feed2 = factory.createFeed(
          feedData2,
          'https://example.com/feed.xml',
        );
        expect(feed2!.type, isNull);
      });

      test('validates and filters invalid URLs', () {
        final feedData = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'image': {'url': 'invalid-url'},
          'itunesImage': 'not-a-url',
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        expect(feed, isNotNull);
        expect(feed!.images, isEmpty); // Invalid URLs should be filtered out
      });

      test('handles date parsing errors gracefully', () {
        final feedData = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'lastBuildDate': 'invalid-date',
          'pubDate': '2024-01-01T12:00:00Z',
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        expect(feed, isNotNull);
        expect(feed!.lastBuildDate, isNull); // Invalid date should be null
        expect(feed.pubDate, isNotNull); // Valid date should be parsed
      });

      test('validates TTL values', () {
        final feedData1 = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'ttl': -5, // Negative value
        };

        final feed1 = factory.createFeed(
          feedData1,
          'https://example.com/feed.xml',
        );
        expect(feed1!.ttl, isNull); // Negative TTL should be null

        final feedData2 = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'ttl': 60,
        };

        final feed2 = factory.createFeed(
          feedData2,
          'https://example.com/feed.xml',
        );
        expect(feed2!.ttl, equals(60));
      });

      test('trims whitespace from string fields', () {
        final feedData = {
          'title': '  Test Podcast  ',
          'description': '  Test description  ',
          'itunesAuthor': '  Author Name  ',
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        expect(feed, isNotNull);
        expect(feed!.title, equals('Test Podcast'));
        expect(feed.description, equals('Test description'));
        expect(feed.author, equals('Author Name'));
      });
    });

    group('createItem', () {
      test('creates item with complete RSS data', () {
        final itemData = {
          'title': 'Test Episode',
          'description': 'A test episode description',
          'link': 'https://example.com/episode1',
          'guid': 'episode-1-guid',
          'isPermaLink': true,
          'pubDate': '2024-01-01T12:00:00Z',
          'categories': ['Technology'],
          'comments': 'https://example.com/comments',
          'source': 'Test Source',
          'contentEncoded': '<p>Rich HTML content</p>',
          'enclosure': {
            'url': 'https://example.com/episode1.mp3',
            'type': 'audio/mpeg',
            'length': 12345678,
          },
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item, isNotNull);
        expect(item!.title, equals('Test Episode'));
        expect(item.description, equals('A test episode description'));
        expect(item.link, equals('https://example.com/episode1'));
        expect(item.guid, equals('episode-1-guid'));
        expect(item.isPermaLink, isTrue);
        expect(item.publishDate, isNotNull);
        expect(item.categories, equals(['Technology']));
        expect(item.comments, equals('https://example.com/comments'));
        expect(item.source, equals('Test Source'));
        expect(item.contentEncoded, equals('<p>Rich HTML content</p>'));
        expect(item.enclosureUrl, equals('https://example.com/episode1.mp3'));
        expect(item.enclosureType, equals('audio/mpeg'));
        expect(item.enclosureLength, equals(12345678));
      });

      test('creates item with iTunes namespace data', () {
        final itemData = {
          'title': 'iTunes Episode',
          'description': 'An iTunes episode',
          'itunesAuthor': 'Episode Author',
          'itunesSubtitle': 'Episode Subtitle',
          'itunesSummary': 'Episode Summary',
          'itunesExplicit': false,
          'itunesDuration': '45:30',
          'itunesEpisode': 42,
          'itunesSeason': 2,
          'itunesEpisodeType': 'full',
          'itunesImage': 'https://example.com/episode-image.jpg',
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item, isNotNull);
        expect(item!.title, equals('iTunes Episode'));
        expect(item.description, equals('An iTunes episode'));
        expect(item.author, equals('Episode Author'));
        expect(item.subtitle, equals('Episode Subtitle'));
        expect(item.summary, equals('Episode Summary'));
        expect(item.isExplicit, isFalse);
        expect(item.duration, equals(const Duration(minutes: 45, seconds: 30)));
        expect(item.episodeNumber, equals(42));
        expect(item.seasonNumber, equals(2));
        expect(item.episodeType, equals('full'));
        expect(item.images, hasLength(1));
        expect(
          item.images.first.url,
          equals('https://example.com/episode-image.jpg'),
        );
      });

      test('handles missing required fields with defaults', () {
        final itemData = <String, dynamic>{};

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item, isNotNull);
        expect(item!.title, equals('Untitled Episode'));
        expect(item.description, equals('No description available'));
        expect(item.author, isNull);
        expect(item.publishDate, isNull);
        expect(item.duration, isNull);
        expect(item.categories, isEmpty);
        expect(item.images, isEmpty);
        expect(item.isExplicit, isNull);
      });

      test('parses various duration formats', () {
        final testCases = [
          {
            'input': '1:30:45',
            'expected': const Duration(hours: 1, minutes: 30, seconds: 45),
          },
          {
            'input': '30:45',
            'expected': const Duration(minutes: 30, seconds: 45),
          },
          {'input': '3600', 'expected': const Duration(seconds: 3600)},
          {'input': 'invalid', 'expected': null},
        ];

        for (final testCase in testCases) {
          final itemData = {
            'title': 'Test Episode',
            'description': 'Test description',
            'itunesDuration': testCase['input'],
          };

          final item = factory.createItem(
            itemData,
            'https://example.com/feed.xml',
          );
          expect(item!.duration, equals(testCase['expected']));
        }
      });

      test('validates episode and season numbers', () {
        final itemData1 = {
          'title': 'Test Episode',
          'description': 'Test description',
          'itunesEpisode': -1, // Negative value
          'itunesSeason': 0, // Zero is valid
        };

        final item1 = factory.createItem(
          itemData1,
          'https://example.com/feed.xml',
        );
        expect(item1!.episodeNumber, isNull); // Negative should be null
        expect(item1.seasonNumber, equals(0)); // Zero should be valid

        final itemData2 = {
          'title': 'Test Episode',
          'description': 'Test description',
          'itunesEpisode': 'invalid',
        };

        final item2 = factory.createItem(
          itemData2,
          'https://example.com/feed.xml',
        );
        expect(item2!.episodeNumber, isNull); // Invalid string should be null
      });

      test('normalizes episode type values', () {
        final testCases = [
          {'input': 'FULL', 'expected': 'full'},
          {'input': 'Trailer', 'expected': 'trailer'},
          {'input': 'BONUS', 'expected': 'bonus'},
          {'input': 'invalid', 'expected': null},
        ];

        for (final testCase in testCases) {
          final itemData = {
            'title': 'Test Episode',
            'description': 'Test description',
            'itunesEpisodeType': testCase['input'],
          };

          final item = factory.createItem(
            itemData,
            'https://example.com/feed.xml',
          );
          expect(item!.episodeType, equals(testCase['expected']));
        }
      });

      test('validates enclosure URLs', () {
        final itemData1 = {
          'title': 'Test Episode',
          'description': 'Test description',
          'enclosure': {
            'url': 'invalid-url',
            'type': 'audio/mpeg',
            'length': 12345,
          },
        };

        final item1 = factory.createItem(
          itemData1,
          'https://example.com/feed.xml',
        );
        expect(
          item1!.enclosureUrl,
          isNull,
        ); // Invalid URL should result in null enclosure

        final itemData2 = {
          'title': 'Test Episode',
          'description': 'Test description',
          'enclosure': {
            'url': 'https://example.com/episode.mp3',
            'type': 'audio/mpeg',
            'length': 12345,
          },
        };

        final item2 = factory.createItem(
          itemData2,
          'https://example.com/feed.xml',
        );
        expect(item2!.enclosureUrl, equals('https://example.com/episode.mp3'));
      });

      test('validates enclosure length', () {
        final itemData = {
          'title': 'Test Episode',
          'description': 'Test description',
          'enclosure': {
            'url': 'https://example.com/episode.mp3',
            'type': 'audio/mpeg',
            'length': -100, // Negative length
          },
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );
        expect(item!.enclosureLength, isNull); // Negative length should be null
      });

      test('handles date parsing errors gracefully', () {
        final itemData = {
          'title': 'Test Episode',
          'description': 'Test description',
          'pubDate': 'invalid-date',
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item, isNotNull);
        expect(item!.publishDate, isNull); // Invalid date should be null
      });

      test('trims whitespace from string fields', () {
        final itemData = {
          'title': '  Test Episode  ',
          'description': '  Test description  ',
          'itunesAuthor': '  Episode Author  ',
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item, isNotNull);
        expect(item!.title, equals('Test Episode'));
        expect(item.description, equals('Test description'));
        expect(item.author, equals('Episode Author'));
      });

      test('handles empty enclosure data', () {
        final itemData = {
          'title': 'Test Episode',
          'description': 'Test description',
          'enclosure': {'url': '', 'type': 'audio/mpeg'},
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item, isNotNull);
        expect(item!.enclosureUrl, isNull); // Empty URL should result in null
      });
    });

    group('error handling', () {
      test('handles malformed feed data gracefully', () {
        final feedData = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'ttl': 'invalid-number',
          'lastBuildDate': 'invalid-date',
          'itunesType': 'invalid-type',
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        expect(feed, isNotNull);
        expect(feed!.title, equals('Test Podcast'));
        expect(feed.ttl, isNull); // Invalid TTL should be null
        expect(feed.lastBuildDate, isNull); // Invalid date should be null
        expect(feed.type, isNull); // Invalid type should be null
      });

      test('handles malformed item data gracefully', () {
        final itemData = {
          'title': 'Test Episode',
          'description': 'Test description',
          'itunesEpisode': 'invalid-number',
          'itunesDuration': 'invalid-duration',
          'pubDate': 'invalid-date',
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item, isNotNull);
        expect(item!.title, equals('Test Episode'));
        expect(
          item.episodeNumber,
          isNull,
        ); // Invalid episode number should be null
        expect(item.duration, isNull); // Invalid duration should be null
        expect(item.publishDate, isNull); // Invalid date should be null
      });

      test('handles null values in nested objects', () {
        final feedData = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'image': null,
          'itunesOwner': null,
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        expect(feed, isNotNull);
        expect(feed!.images, isEmpty);
        expect(feed.ownerName, isNull);
        expect(feed.ownerEmail, isNull);
      });

      test('emits warnings for recoverable parsing issues', () async {
        final warnings = <PodcastParseWarning>[];
        factory.warnings.listen(warnings.add);

        final feedData = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'itunesType': 'invalid-type',
          'lastBuildDate': 'invalid-date',
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        // Allow warnings to be emitted
        await Future.delayed(const Duration(milliseconds: 10));

        expect(feed, isNotNull);
        expect(warnings, isNotEmpty);

        // Check that warnings contain expected information
        final typeWarning = warnings.firstWhere(
          (w) => w.message.contains('Invalid iTunes type'),
          orElse: () => throw StateError('Type warning not found'),
        );
        expect(typeWarning.entityType, equals('Feed'));
        expect(typeWarning.elementName, equals('itunesType'));
      });

      test('emits warnings for item parsing issues', () async {
        final warnings = <PodcastParseWarning>[];
        factory.warnings.listen(warnings.add);

        final itemData = {
          'title': 'Test Episode',
          'description': 'Test description',
          'itunesEpisodeType': 'invalid-type',
          'itunesDuration': 'invalid-duration',
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        // Allow warnings to be emitted
        await Future.delayed(const Duration(milliseconds: 10));

        expect(item, isNotNull);
        expect(warnings, isNotEmpty);

        // Check that warnings contain expected information
        final typeWarning = warnings.firstWhere(
          (w) => w.message.contains('Invalid episode type'),
          orElse: () => throw StateError('Episode type warning not found'),
        );
        expect(typeWarning.entityType, equals('Item'));
        expect(typeWarning.elementName, equals('itunesEpisodeType'));
      });

      test('continues parsing when individual elements fail', () async {
        final warnings = <PodcastParseWarning>[];
        factory.warnings.listen(warnings.add);

        final feedData = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'image': {
            'url':
                'invalid-url', // This should cause a warning but not fail the feed
          },
          'itunesImage':
              'https://example.com/valid-image.jpg', // This should work
          'categories': ['Valid Category'],
          'itunesType': 'episodic',
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        // Allow warnings to be emitted
        await Future.delayed(const Duration(milliseconds: 10));

        expect(feed, isNotNull);
        expect(feed!.title, equals('Test Podcast'));
        expect(feed.type, equals('episodic'));
        expect(feed.categories, equals(['Valid Category']));

        // Should have valid iTunes image even though RSS image failed
        expect(feed.images, hasLength(1));
        expect(
          feed.images.first.url,
          equals('https://example.com/valid-image.jpg'),
        );
      });

      test('handles completely malformed data structures', () async {
        final warnings = <PodcastParseWarning>[];
        factory.warnings.listen(warnings.add);

        // Simulate corrupted data that might cause exceptions
        final feedData = {
          'title': 'Test Podcast',
          'description': 'Test description',
          'itunesOwner': 'not-a-map', // Should be a Map but is a String
          'categories': 'not-a-list', // Should be a List but is a String
        };

        final feed = factory.createFeed(
          feedData,
          'https://example.com/feed.xml',
        );

        // Allow warnings to be emitted
        await Future.delayed(const Duration(milliseconds: 10));

        expect(feed, isNotNull);
        expect(feed!.title, equals('Test Podcast'));
        expect(feed.ownerName, isNull);
        expect(feed.ownerEmail, isNull);
        expect(feed.categories, isEmpty);
      });

      test(
        'validates enclosure data and emits warnings for invalid URLs',
        () async {
          final warnings = <PodcastParseWarning>[];
          factory.warnings.listen(warnings.add);

          final itemData = {
            'title': 'Test Episode',
            'description': 'Test description',
            'enclosure': {
              'url': 'not-a-valid-url',
              'type': 'audio/mpeg',
              'length': 12345,
            },
          };

          final item = factory.createItem(
            itemData,
            'https://example.com/feed.xml',
          );

          // Allow warnings to be emitted
          await Future.delayed(const Duration(milliseconds: 10));

          expect(item, isNotNull);
          expect(
            item!.enclosureUrl,
            isNull,
          ); // Invalid URL should result in null enclosure
        },
      );

      test('disposes resources properly', () {
        expect(() => factory.dispose(), returnsNormally);
      });
    });
  });
}
