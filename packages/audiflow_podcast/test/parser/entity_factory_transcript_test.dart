import 'package:audiflow_podcast/src/parser/entity_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EntityFactory transcript and chapter extraction', () {
    late EntityFactory factory;

    setUp(() {
      factory = EntityFactory();
    });

    tearDown(() {
      factory.dispose();
    });

    group('_extractTranscripts via createItem', () {
      test('populates transcripts from itemData', () {
        final itemData = {
          'title': 'Episode with Transcripts',
          'description': 'Has transcript links',
          'transcripts': <Map<String, dynamic>>[
            {
              'url': 'https://example.com/transcript.srt',
              'type': 'application/srt',
              'language': 'en',
              'rel': 'captions',
            },
            {
              'url': 'https://example.com/transcript.vtt',
              'type': 'text/vtt',
              'language': 'ja',
              'rel': 'transcript',
            },
          ],
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item, isNotNull);
        expect(item!.transcripts, isNotNull);
        expect(item.transcripts, hasLength(2));
        expect(
          item.transcripts![0].url,
          equals('https://example.com/transcript.srt'),
        );
        expect(item.transcripts![0].type, equals('application/srt'));
        expect(item.transcripts![0].language, equals('en'));
        expect(item.transcripts![0].rel, equals('captions'));
        expect(
          item.transcripts![1].url,
          equals('https://example.com/transcript.vtt'),
        );
        expect(item.transcripts![1].type, equals('text/vtt'));
        expect(item.transcripts![1].language, equals('ja'));
        expect(item.transcripts![1].rel, equals('transcript'));
      });

      test('skips transcripts missing url', () {
        final itemData = {
          'title': 'Episode',
          'description': 'Desc',
          'transcripts': <Map<String, dynamic>>[
            {'url': null, 'type': 'text/vtt'},
            {
              'url': 'https://example.com/t.srt',
              'type': 'application/srt',
            },
          ],
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item!.transcripts, hasLength(1));
        expect(
          item.transcripts![0].url,
          equals('https://example.com/t.srt'),
        );
      });

      test('skips transcripts missing type', () {
        final itemData = {
          'title': 'Episode',
          'description': 'Desc',
          'transcripts': <Map<String, dynamic>>[
            {'url': 'https://example.com/t.srt', 'type': null},
          ],
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item!.transcripts, isNull);
      });

      test('returns null when transcripts list is empty', () {
        final itemData = {
          'title': 'Episode',
          'description': 'Desc',
          'transcripts': <Map<String, dynamic>>[],
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item!.transcripts, isNull);
      });

      test('returns null when transcripts key is absent', () {
        final itemData = {
          'title': 'Episode',
          'description': 'Desc',
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item!.transcripts, isNull);
      });
    });

    group('_extractChapters via createItem', () {
      test('populates chapters from itemData', () {
        final itemData = {
          'title': 'Episode with Chapters',
          'description': 'Has chapter markers',
          'chapters': <Map<String, dynamic>>[
            {
              'title': 'Introduction',
              'startTime': const Duration(seconds: 0),
              'url': 'https://example.com/intro',
              'imageUrl': 'https://example.com/intro.jpg',
            },
            {
              'title': 'Main Topic',
              'startTime': const Duration(minutes: 5, seconds: 30),
              'url': null,
              'imageUrl': null,
            },
          ],
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item, isNotNull);
        expect(item!.chapters, isNotNull);
        expect(item.chapters, hasLength(2));
        expect(item.chapters![0].title, equals('Introduction'));
        expect(
          item.chapters![0].startTime,
          equals(const Duration(seconds: 0)),
        );
        expect(
          item.chapters![0].url,
          equals('https://example.com/intro'),
        );
        expect(
          item.chapters![0].imageUrl,
          equals('https://example.com/intro.jpg'),
        );
        expect(item.chapters![1].title, equals('Main Topic'));
        expect(
          item.chapters![1].startTime,
          equals(const Duration(minutes: 5, seconds: 30)),
        );
        expect(item.chapters![1].url, isNull);
        expect(item.chapters![1].imageUrl, isNull);
      });

      test('skips chapters missing title', () {
        final itemData = {
          'title': 'Episode',
          'description': 'Desc',
          'chapters': <Map<String, dynamic>>[
            {
              'title': null,
              'startTime': const Duration(seconds: 0),
            },
            {
              'title': 'Valid Chapter',
              'startTime': const Duration(minutes: 1),
            },
          ],
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item!.chapters, hasLength(1));
        expect(item.chapters![0].title, equals('Valid Chapter'));
      });

      test('skips chapters missing startTime', () {
        final itemData = {
          'title': 'Episode',
          'description': 'Desc',
          'chapters': <Map<String, dynamic>>[
            {'title': 'No Start', 'startTime': null},
          ],
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item!.chapters, isNull);
      });

      test('returns null when chapters list is empty', () {
        final itemData = {
          'title': 'Episode',
          'description': 'Desc',
          'chapters': <Map<String, dynamic>>[],
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item!.chapters, isNull);
      });

      test('returns null when chapters key is absent', () {
        final itemData = {
          'title': 'Episode',
          'description': 'Desc',
        };

        final item = factory.createItem(
          itemData,
          'https://example.com/feed.xml',
        );

        expect(item!.chapters, isNull);
      });
    });

    group('combined transcripts and chapters', () {
      test(
        'creates item with both transcripts and chapters populated',
        () {
          final itemData = {
            'title': 'Full Featured Episode',
            'description': 'Episode with all features',
            'enclosure': {
              'url': 'https://example.com/ep.mp3',
              'type': 'audio/mpeg',
              'length': 48000000,
            },
            'transcripts': <Map<String, dynamic>>[
              {
                'url': 'https://example.com/ep.srt',
                'type': 'application/srt',
                'language': 'en',
                'rel': 'captions',
              },
            ],
            'chapters': <Map<String, dynamic>>[
              {
                'title': 'Opening',
                'startTime': const Duration(seconds: 0),
              },
              {
                'title': 'Discussion',
                'startTime': const Duration(minutes: 3),
                'url': 'https://example.com/discussion',
                'imageUrl': 'https://example.com/discussion.png',
              },
            ],
          };

          final item = factory.createItem(
            itemData,
            'https://example.com/feed.xml',
          );

          expect(item, isNotNull);
          expect(item!.hasTranscripts, isTrue);
          expect(item.hasChapters, isTrue);
          expect(item.transcripts, hasLength(1));
          expect(item.chapters, hasLength(2));
          expect(
            item.enclosureUrl,
            equals('https://example.com/ep.mp3'),
          );
        },
      );
    });
  });
}
