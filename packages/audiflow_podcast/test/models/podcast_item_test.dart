import 'package:audiflow_podcast/src/models/podcast_chapter.dart';
import 'package:audiflow_podcast/src/models/podcast_image.dart';
import 'package:audiflow_podcast/src/models/podcast_item.dart';
import 'package:audiflow_podcast/src/models/podcast_transcript.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_constants.dart';

void main() {
  group('PodcastItem', () {
    group('constructor', () {
      test('should create item with required fields and defaults', () {
        final item = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Episode 1',
          description: 'First episode description',
        );

        expect(item.publishDate, isNull);
        expect(item.duration, isNull);
        expect(item.enclosureUrl, isNull);
        expect(item.episodeNumber, isNull);
        expect(item.seasonNumber, isNull);
        expect(item.images, isEmpty);
        expect(item.categories, isEmpty);
      });
    });

    group('fromData factory constructor', () {
      test('should trim whitespace from title and description', () {
        final item = PodcastItem.fromData(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: '  Episode Title  ',
          description: '  Episode description  ',
        );

        expect(item.title, 'Episode Title');
        expect(item.description, 'Episode description');
      });

      test('should normalize episode type to lowercase', () {
        final tests = [
          ('FULL', 'full'),
          ('Trailer', 'trailer'),
          ('BONUS', 'bonus'),
        ];

        for (final (input, expected) in tests) {
          final item = PodcastItem.fromData(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            episodeType: input,
          );
          expect(item.episodeType, expected);
        }
      });

      test('should throw on invalid episode type', () {
        expect(
          () => PodcastItem.fromData(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            episodeType: 'invalid',
          ),
          throwsArgumentError,
        );
      });

      test('should throw on empty title', () {
        expect(
          () => PodcastItem.fromData(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: '   ',
            description: 'Test',
          ),
          throwsArgumentError,
        );
      });

      test('should allow empty description', () {
        final item = PodcastItem.fromData(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: '   ',
        );
        expect(item.description, '');
      });

      test('should throw on negative numbers', () {
        final tests = [(-1, null, null), (null, -1, null), (null, null, -1)];

        for (final (episodeNum, seasonNum, enclosureLen) in tests) {
          expect(
            () => PodcastItem.fromData(
              parsedAt: testParsedAt,
              sourceUrl: testSourceUrl,
              title: 'Test',
              description: 'Test',
              episodeNumber: episodeNum,
              seasonNumber: seasonNum,
              enclosureLength: enclosureLen,
            ),
            throwsArgumentError,
          );
        }
      });

      test('should throw on invalid URLs', () {
        final tests = [
          ('enclosureUrl', 'not-a-url', null, null),
          ('link', null, 'not-a-url', null),
          ('comments', null, null, 'not-a-url'),
        ];

        for (final (_, enclosureUrl, link, comments) in tests) {
          expect(
            () => PodcastItem.fromData(
              parsedAt: testParsedAt,
              sourceUrl: testSourceUrl,
              title: 'Test',
              description: 'Test',
              enclosureUrl: enclosureUrl,
              link: link,
              comments: comments,
            ),
            throwsArgumentError,
          );
        }
      });

      test('should throw on invalid MIME type', () {
        expect(
          () => PodcastItem.fromData(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            enclosureType: 'invalid-mime',
          ),
          throwsArgumentError,
        );
      });

      test('should handle empty strings as null', () {
        final item = PodcastItem.fromData(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: 'Test',
          enclosureUrl: '',
          enclosureType: '   ',
          guid: '',
          subtitle: '',
          summary: '',
          author: '',
          link: '',
          comments: '',
          source: '',
          contentEncoded: '',
        );

        expect(item.enclosureUrl, isNull);
        expect(item.enclosureType, isNull);
        expect(item.guid, isNull);
        expect(item.subtitle, isNull);
        expect(item.summary, isNull);
        expect(item.author, isNull);
        expect(item.link, isNull);
        expect(item.comments, isNull);
        expect(item.source, isNull);
        expect(item.contentEncoded, isNull);
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
          final item = PodcastItem(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            images: images,
          );
          expect(item.primaryImage?.url, expected);
        }
      });

      test('should identify episode types', () {
        final tests = [
          ('full', true, false, false),
          ('trailer', false, true, false),
          ('bonus', false, false, true),
          (null, true, false, false), // Default to full
        ];

        for (final (type, isFull, isTrailer, isBonus) in tests) {
          final item = PodcastItem(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            episodeType: type,
          );

          expect(item.isFullEpisode, isFull);
          expect(item.isTrailer, isTrailer);
          expect(item.isBonus, isBonus);
        }
      });

      test('should identify presence of various features', () {
        final itemWithEnclosure = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: 'Test',
          enclosureUrl: 'https://example.com/audio.mp3',
        );

        final itemWithChapters = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: 'Test',
          chapters: [
            const PodcastChapter(title: 'Chapter 1', startTime: Duration.zero),
          ],
        );

        final itemWithTranscripts = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: 'Test',
          transcripts: [
            const PodcastTranscript(url: 'transcript.txt', type: 'text/plain'),
          ],
        );

        final itemWithNumbering = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: 'Test',
          episodeNumber: 1,
          seasonNumber: 1,
        );

        final itemWithPermaLink = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: 'Test',
          isPermaLink: true,
        );

        final basicItem = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: 'Test',
        );

        expect(itemWithEnclosure.hasEnclosure, isTrue);
        expect(itemWithChapters.hasChapters, isTrue);
        expect(itemWithTranscripts.hasTranscripts, isTrue);
        expect(itemWithNumbering.hasNumbering, isTrue);
        expect(itemWithPermaLink.guidIsPermaLink, isTrue);

        expect(basicItem.hasEnclosure, isFalse);
        expect(basicItem.hasChapters, isFalse);
        expect(basicItem.hasTranscripts, isFalse);
        expect(basicItem.hasNumbering, isFalse);
        expect(basicItem.guidIsPermaLink, isFalse);
      });

      test('should format file size correctly', () {
        final testCases = [
          (null, null),
          (500, '500 B'),
          (1536, '1.5 KB'),
          (1572864, '1.5 MB'),
          (1610612736, '1.5 GB'),
        ];

        for (final (length, expected) in testCases) {
          final item = PodcastItem(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            enclosureLength: length,
          );

          expect(item.formattedFileSize, equals(expected));
        }
      });

      test('should format duration correctly', () {
        final testCases = [
          (null, null),
          (const Duration(seconds: 30), '00:30'),
          (const Duration(minutes: 5, seconds: 30), '05:30'),
          (const Duration(hours: 1, minutes: 30, seconds: 45), '01:30:45'),
          (const Duration(hours: 2, minutes: 5, seconds: 3), '02:05:03'),
        ];

        for (final (duration, expected) in testCases) {
          final item = PodcastItem(
            parsedAt: testParsedAt,
            sourceUrl: testSourceUrl,
            title: 'Test',
            description: 'Test',
            duration: duration,
          );

          expect(item.formattedDuration, equals(expected));
        }
      });

      test('should filter transcripts by type and rel', () {
        final transcripts = [
          const PodcastTranscript(
            url: 'plain.txt',
            type: 'text/plain',
            rel: 'transcript',
          ),
          const PodcastTranscript(
            url: 'html.html',
            type: 'text/html',
            rel: 'transcript',
          ),
          const PodcastTranscript(
            url: 'captions.srt',
            type: 'application/srt',
            rel: 'captions',
          ),
          const PodcastTranscript(
            url: 'captions.vtt',
            type: 'text/vtt',
            rel: 'captions',
          ),
        ];

        final item = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test',
          description: 'Test',
          transcripts: transcripts,
        );

        final plainTranscripts = item.getTranscriptsByType('text/plain');
        final captionTranscripts = item.getTranscriptsByRel('captions');
        final transcriptTranscripts = item.getTranscriptsByRel('transcript');

        expect(plainTranscripts.length, equals(1));
        expect(plainTranscripts.first.url, equals('plain.txt'));

        expect(captionTranscripts.length, equals(2));
        expect(
          captionTranscripts.map((t) => t.url),
          containsAll(['captions.srt', 'captions.vtt']),
        );

        expect(transcriptTranscripts.length, equals(2));
        expect(
          transcriptTranscripts.map((t) => t.url),
          containsAll(['plain.txt', 'html.html']),
        );
      });
    });

    group('validation', () {
      test('should validate correct item', () {
        final item = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Valid Episode',
          description: 'A valid episode description',
          episodeType: 'full',
          episodeNumber: 1,
          seasonNumber: 1,
          enclosureLength: 1000000,
          enclosureUrl: 'https://example.com/audio.mp3',
          enclosureType: 'audio/mpeg',
          link: 'https://example.com/episode',
          comments: 'https://example.com/comments',
        );

        expect(item.isValid, isTrue);
        expect(item.validate(), isEmpty);
      });

      test('should detect validation errors', () {
        final item = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: '',
          description: '',
          episodeType: 'invalid',
          episodeNumber: -1,
          seasonNumber: -1,
          enclosureLength: -1,
          enclosureUrl: 'not-a-url',
          enclosureType: 'invalid-mime',
          link: 'not-a-url',
          comments: 'not-a-url',
        );

        expect(item.isValid, isFalse);
        final errors = item.validate();
        expect(errors.length, greaterThan(0));
        expect(errors.any((e) => e.contains('title')), isTrue);
        expect(errors.any((e) => e.contains('description')), isTrue);
        expect(errors.any((e) => e.contains('Episode type')), isTrue);
        expect(errors.any((e) => e.contains('Episode number')), isTrue);
        expect(errors.any((e) => e.contains('Season number')), isTrue);
        expect(errors.any((e) => e.contains('Enclosure length')), isTrue);
        expect(errors.any((e) => e.contains('enclosure URL')), isTrue);
        expect(errors.any((e) => e.contains('MIME type')), isTrue);
        expect(errors.any((e) => e.contains('link URL')), isTrue);
        expect(errors.any((e) => e.contains('comments URL')), isTrue);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        final item1 = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test Episode',
          description: 'Test description',
          episodeNumber: 1,
          seasonNumber: 1,
        );

        final item2 = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Test Episode',
          description: 'Test description',
          episodeNumber: 1,
          seasonNumber: 1,
        );

        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final item1 = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Episode 1',
          description: 'Test description',
        );

        final item2 = PodcastItem(
          parsedAt: testParsedAt,
          sourceUrl: testSourceUrl,
          title: 'Episode 2',
          description: 'Test description',
        );

        expect(item1, isNot(equals(item2)));
      });
    });

    test('should have meaningful toString representation', () {
      final item = PodcastItem(
        parsedAt: testParsedAt,
        sourceUrl: testSourceUrl,
        title: 'Test Episode',
        description: 'Test description',
        episodeNumber: 5,
        seasonNumber: 2,
        duration: const Duration(minutes: 45, seconds: 30),
        publishDate: DateTime(2023, 12, 20),
      );

      final string = item.toString();
      expect(string, contains('PodcastItem'));
      expect(string, contains('Test Episode'));
      expect(string, contains('5'));
      expect(string, contains('2'));
      expect(string, contains('45:30'));
      expect(string, contains('2023-12-20'));
    });
  });
}
