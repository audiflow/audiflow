import 'package:flutter_test/flutter_test.dart';
import 'package:audiflow_podcast/src/models/podcast_feed.dart';
import 'package:audiflow_podcast/src/models/podcast_image.dart';
import '../helpers/test_constants.dart';

void main() {
  group('PodcastFeed', () {
    group('constructor', () {
      test('should create feed with required fields and defaults', () {
        final feed = PodcastFeed(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test Podcast',
          description: 'A test podcast description',
        );

        expect(feed.author, isNull);
        expect(feed.images, isEmpty);
        expect(feed.language, isNull);
        expect(feed.categories, isEmpty);
        expect(feed.isExplicit, isFalse);
      });
    });

    group('fromData factory constructor', () {
      test('should trim whitespace from title and description', () {
        final feed = PodcastFeed.fromData(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: '  Test Podcast  ',
          description: '  A test description  ',
        );

        expect(feed.title, 'Test Podcast');
        expect(feed.description, 'A test description');
      });

      test('should normalize type to lowercase', () {
        final tests = [('EPISODIC', 'episodic'), ('Serial', 'serial')];

        for (final (input, expected) in tests) {
          final feed = PodcastFeed.fromData(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            type: input,
          );
          expect(feed.type, expected);
        }
      });

      test('should throw on invalid type', () {
        expect(
          () => PodcastFeed.fromData(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            type: 'invalid',
          ),
          throwsArgumentError,
        );
      });

      test('should throw on empty title', () {
        expect(
          () => PodcastFeed.fromData(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: '   ',
            description: 'Test',
          ),
          throwsArgumentError,
        );
      });

      test('should allow empty description', () {
        final feed = PodcastFeed.fromData(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: '   ',
        );
        expect(feed.description, '');
      });

      test('should throw on negative TTL', () {
        expect(
          () => PodcastFeed.fromData(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            ttl: -1,
          ),
          throwsArgumentError,
        );
      });

      test('should throw on invalid URL', () {
        expect(
          () => PodcastFeed.fromData(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            link: 'not-a-url',
          ),
          throwsArgumentError,
        );
      });

      test('should throw on invalid email', () {
        expect(
          () => PodcastFeed.fromData(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            ownerEmail: 'not-an-email',
          ),
          throwsArgumentError,
        );
      });

      test('should handle empty strings as null', () {
        final feed = PodcastFeed.fromData(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: 'Test',
          author: '',
          language: '   ',
          subtitle: '',
          summary: '',
          ownerName: '',
          ownerEmail: '',
          link: '',
          copyright: '',
          generator: '',
          managingEditor: '',
          webMaster: '',
          newFeedUrl: '',
        );

        expect(feed.author, isNull);
        expect(feed.language, isNull);
        expect(feed.subtitle, isNull);
        expect(feed.summary, isNull);
        expect(feed.ownerName, isNull);
        expect(feed.ownerEmail, isNull);
        expect(feed.link, isNull);
        expect(feed.copyright, isNull);
        expect(feed.generator, isNull);
        expect(feed.managingEditor, isNull);
        expect(feed.webMaster, isNull);
        expect(feed.newFeedUrl, isNull);
      });
    });

    group('convenience getters', () {
      test('should return primary image based on width', () {
        final tests = [
          (
            [
              const PodcastImage(url: 'small.jpg', width: 300),
              const PodcastImage(url: 'large.jpg', width: 1200),
              const PodcastImage(url: 'medium.jpg', width: 600),
            ],
            'large.jpg',
          ),
          (
            [
              const PodcastImage(url: 'first.jpg'),
              const PodcastImage(url: 'second.jpg'),
            ],
            'first.jpg',
          ),
          (<PodcastImage>[], null),
        ];

        for (final (images, expected) in tests) {
          final feed = PodcastFeed(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            images: images,
          );
          expect(feed.primaryImage?.url, expected);
        }
      });

      test('should filter images by size category', () {
        final images = [
          const PodcastImage(url: 'small1.jpg', width: 200),
          const PodcastImage(url: 'medium1.jpg', width: 400),
          const PodcastImage(url: 'small2.jpg', width: 300),
          const PodcastImage(url: 'large1.jpg', width: 800),
        ];

        final feed = PodcastFeed(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: 'Test',
          images: images,
        );

        expect(feed.getImagesBySize('small').length, 2);
        expect(feed.getImagesBySize('medium').length, 1);
        expect(feed.getImagesBySize('large').length, 1);
      });

      test('should identify podcast type', () {
        final tests = [
          ('episodic', true, false),
          ('serial', false, true),
          (null, false, false),
        ];

        for (final (type, isEpisodic, isSerial) in tests) {
          final feed = PodcastFeed(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            type: type,
          );
          expect(feed.isEpisodic, isEpisodic);
          expect(feed.isSerial, isSerial);
        }
      });

      test('should detect owner info presence', () {
        final tests = [
          ('John Doe', null, true),
          (null, 'john@example.com', true),
          ('John Doe', 'john@example.com', true),
          (null, null, false),
        ];

        for (final (name, email, hasInfo) in tests) {
          final feed = PodcastFeed(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            ownerName: name,
            ownerEmail: email,
          );
          expect(feed.hasOwnerInfo, hasInfo);
        }
      });

      test('should identify complete status', () {
        final tests = [(true, true), (false, false), (null, false)];

        for (final (isComplete, expected) in tests) {
          final feed = PodcastFeed(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            isComplete: isComplete,
          );
          expect(feed.isMarkedComplete, expected);
        }
      });

      test('should calculate cache duration from TTL', () {
        final tests = [
          (120, const Duration(minutes: 120)),
          (null, const Duration(minutes: 60)),
        ];

        for (final (ttl, expected) in tests) {
          final feed = PodcastFeed(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            ttl: ttl,
          );
          expect(feed.cacheDuration, expected);
        }
      });
    });

    group('validation', () {
      test('should validate correct feed', () {
        final feed = PodcastFeed(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Valid Podcast',
          description: 'A valid podcast description',
          type: 'episodic',
          ttl: 60,
          link: 'https://example.com',
          ownerEmail: 'owner@example.com',
          newFeedUrl: 'https://example.com/new-feed.xml',
        );

        expect(feed.isValid, isTrue);
        expect(feed.validate(), isEmpty);
      });

      test('should detect validation errors', () {
        final feed = PodcastFeed(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: '',
          description: '',
          type: 'invalid',
          ttl: -1,
          link: 'not-a-url',
          ownerEmail: 'not-an-email',
          newFeedUrl: 'also-not-a-url',
        );

        expect(feed.isValid, isFalse);
        final errors = feed.validate();
        expect(errors.length, greaterThan(0));
        expect(errors.any((e) => e.contains('title')), isTrue);
        expect(errors.any((e) => e.contains('description')), isTrue);
        expect(errors.any((e) => e.contains('type')), isTrue);
        expect(errors.any((e) => e.contains('TTL')), isTrue);
        expect(errors.any((e) => e.contains('link')), isTrue);
        expect(errors.any((e) => e.contains('email')), isTrue);
        expect(errors.any((e) => e.contains('new feed')), isTrue);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        final feed1 = PodcastFeed(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test Podcast',
          description: 'Test description',
          author: 'Test Author',
          language: 'en-US',
        );

        final feed2 = PodcastFeed(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test Podcast',
          description: 'Test description',
          author: 'Test Author',
          language: 'en-US',
        );

        expect(feed1, feed2);
        expect(feed1.hashCode, feed2.hashCode);
      });

      test('should not be equal when title differs', () {
        final feed1 = PodcastFeed(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test Podcast 1',
          description: 'Test description',
        );

        final feed2 = PodcastFeed(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test Podcast 2',
          description: 'Test description',
        );

        expect(feed1, isNot(feed2));
      });
    });

    test('should have meaningful toString representation', () {
      final feed = PodcastFeed(
        parsedAt: testParsedAt,
        sourceUrl: testSourceUrl,
        title: 'Test Podcast',
        description:
            'A very long description that should be truncated in the toString method because it exceeds fifty characters',
        author: 'Test Author',
        language: 'en-US',
        categories: ['Technology'],
        isExplicit: true,
      );

      final string = feed.toString();
      expect(string, contains('PodcastFeed'));
      expect(string, contains('Test Podcast'));
    });
  });
}
