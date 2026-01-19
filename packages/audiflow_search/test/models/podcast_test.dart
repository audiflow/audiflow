import 'package:audiflow_search/audiflow_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Podcast', () {
    group('constructor', () {
      test('should create podcast with required fields', () {
        const podcast = Podcast(
          id: '123456',
          name: 'Test Podcast',
          artistName: 'Test Artist',
          genres: ['Technology', 'News'],
        );

        expect(podcast.id, '123456');
        expect(podcast.name, 'Test Podcast');
        expect(podcast.artistName, 'Test Artist');
        expect(podcast.genres, const ['Technology', 'News']);
        expect(podcast.explicit, false);
      });

      test('should create podcast with all fields', () {
        final releaseDate = DateTime(2025);
        final podcast = Podcast(
          id: '123456',
          name: 'Test Podcast',
          artistName: 'Test Artist',
          genres: const ['Technology', 'News'],
          explicit: true,
          feedUrl: 'https://example.com/feed.rss',
          description: 'A test podcast description',
          artworkUrl: 'https://example.com/artwork.jpg',
          releaseDate: releaseDate,
          trackCount: 100,
        );

        expect(podcast.feedUrl, 'https://example.com/feed.rss');
        expect(podcast.description, 'A test podcast description');
        expect(podcast.artworkUrl, 'https://example.com/artwork.jpg');
        expect(podcast.releaseDate, releaseDate);
        expect(podcast.trackCount, 100);
      });
    });

    group('validated factory', () {
      test('should create validated podcast with valid fields', () {
        final podcast = Podcast.validated(
          id: '123456',
          name: 'Test Podcast',
          artistName: 'Test Artist',
        );

        expect(podcast.id, '123456');
        expect(podcast.name, 'Test Podcast');
        expect(podcast.artistName, 'Test Artist');
      });

      test('should throw when id is empty', () {
        expect(
          () => Podcast.validated(
            id: '',
            name: 'Test Podcast',
            artistName: 'Test Artist',
          ),
          throwsA(isA<SearchException>()),
        );
      });

      test('should throw when name is empty', () {
        expect(
          () => Podcast.validated(
            id: '123456',
            name: '',
            artistName: 'Test Artist',
          ),
          throwsA(isA<SearchException>()),
        );
      });

      test('should throw when artistName is empty', () {
        expect(
          () => Podcast.validated(
            id: '123456',
            name: 'Test Podcast',
            artistName: '',
          ),
          throwsA(isA<SearchException>()),
        );
      });
    });

    group('fromJson', () {
      test('should parse podcast with all fields from JSON', () {
        final json = {
          'collectionId': 123456,
          'collectionName': 'Test Podcast',
          'artistName': 'Test Artist',
          'feedUrl': 'https://example.com/feed.rss',
          'description': 'A test description',
          'genres': ['Technology', 'News'],
          'artworkUrl600': 'https://example.com/600.jpg',
          'releaseDate': '2025-01-01T00:00:00Z',
          'trackExplicitness': 'explicit',
          'trackCount': 100,
        };

        final podcast = Podcast.fromJson(json);

        expect(podcast.id, json['collectionId'].toString());
        expect(podcast.name, json['collectionName']);
        expect(podcast.artistName, json['artistName']);
        expect(podcast.feedUrl, json['feedUrl']);
        expect(podcast.description, json['description']);
        expect(podcast.genres, json['genres']);
        expect(podcast.artworkUrl, json['artworkUrl600']);
        expect(
          podcast.releaseDate,
          DateTime.parse(json['releaseDate']! as String),
        );
        expect(podcast.explicit, true);
        expect(podcast.trackCount, json['trackCount']);
      });

      test('should parse podcast with minimal fields from JSON', () {
        final json = {
          'collectionId': 123456,
          'collectionName': 'Test Podcast',
          'artistName': 'Test Artist',
          'genres': <String>[],
          'trackExplicitness': 'notExplicit',
        };

        final podcast = Podcast.fromJson(json);

        expect(podcast.id, json['collectionId'].toString());
        expect(podcast.name, json['collectionName']);
        expect(podcast.artistName, json['artistName']);
        expect(podcast.genres, json['genres']);
        expect(podcast.explicit, false);
      });

      test('should use trackId as fallback when collectionId is missing', () {
        final json = {
          'trackId': 789012,
          'trackName': 'Test Podcast',
          'artistName': 'Test Artist',
          'genres': <String>[],
          'trackExplicitness': 'notExplicit',
        };

        final podcast = Podcast.fromJson(json);

        expect(podcast.id, json['trackId'].toString());
        expect(podcast.name, json['trackName']);
      });

      test('should throw when id is missing', () {
        final json = {
          'collectionName': 'Test',
          'artistName': 'Artist',
        };

        expect(
          () => Podcast.fromJson(json),
          throwsA(isA<SearchException>()),
        );
      });

      test('should throw when name is missing', () {
        final json = {
          'collectionId': 123,
          'artistName': 'Artist',
        };

        expect(
          () => Podcast.fromJson(json),
          throwsA(isA<SearchException>()),
        );
      });

      test('should throw when artistName is missing', () {
        final json = {
          'collectionId': 123,
          'collectionName': 'Test',
        };

        expect(
          () => Podcast.fromJson(json),
          throwsA(isA<SearchException>()),
        );
      });

      test('should select highest resolution artwork URL', () {
        final json = {
          'collectionId': 123456,
          'collectionName': 'Test Podcast',
          'artistName': 'Test Artist',
          'genres': <String>[],
          'trackExplicitness': 'notExplicit',
          'artworkUrl30': 'https://example.com/30.jpg',
          'artworkUrl60': 'https://example.com/60.jpg',
          'artworkUrl100': 'https://example.com/100.jpg',
          'artworkUrl600': 'https://example.com/600.jpg',
        };

        final podcast = Podcast.fromJson(json);

        expect(podcast.artworkUrl, json['artworkUrl600']);
      });

      test('should map explicit trackExplicitness to explicit=true', () {
        final json = {
          'collectionId': 123456,
          'collectionName': 'Test Podcast',
          'artistName': 'Test Artist',
          'genres': <String>[],
          'trackExplicitness': 'explicit',
        };

        expect(Podcast.fromJson(json).explicit, true);
      });

      test('should map notExplicit trackExplicitness to explicit=false', () {
        final json = {
          'collectionId': 123456,
          'collectionName': 'Test Podcast',
          'artistName': 'Test Artist',
          'genres': <String>[],
          'trackExplicitness': 'notExplicit',
        };

        expect(Podcast.fromJson(json).explicit, false);
      });
    });

    group('equality', () {
      test('should be equal when ids are the same', () {
        const podcast1 = Podcast(
          id: '123456',
          name: 'Test Podcast 1',
          artistName: 'Test Artist 1',
          genres: ['Technology'],
        );

        const podcast2 = Podcast(
          id: '123456',
          name: 'Test Podcast 2',
          artistName: 'Test Artist 2',
          genres: ['News'],
          explicit: true,
        );

        expect(podcast1, podcast2);
        expect(podcast1.hashCode, podcast2.hashCode);
      });

      test('should not be equal when ids are different', () {
        const podcast1 = Podcast(
          id: '123456',
          name: 'Test Podcast',
          artistName: 'Test Artist',
          genres: ['Technology'],
        );

        const podcast2 = Podcast(
          id: '789012',
          name: 'Test Podcast',
          artistName: 'Test Artist',
          genres: ['Technology'],
        );

        expect(podcast1, isNot(podcast2));
      });
    });

    group('immutability', () {
      test('should not allow modification of genres list', () {
        const podcast = Podcast(
          id: '123456',
          name: 'Test Podcast',
          artistName: 'Test Artist',
          genres: ['Technology', 'News'],
        );

        expect(
          () => podcast.genres.add('Comedy'),
          throwsUnsupportedError,
        );
      });
    });

    group('copyWith', () {
      test('should create a copy with modified fields', () {
        const original = Podcast(
          id: '123456',
          name: 'Test Podcast',
          artistName: 'Test Artist',
          genres: ['Technology'],
        );

        final copy = original.copyWith(
          name: 'Updated Podcast',
          explicit: true,
        );

        expect(copy.id, original.id);
        expect(copy.name, 'Updated Podcast');
        expect(copy.artistName, original.artistName);
        expect(copy.explicit, true);
      });

      test('should keep original values when no parameters provided', () {
        const original = Podcast(
          id: '123456',
          name: 'Test Podcast',
          artistName: 'Test Artist',
          genres: ['Technology'],
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.name, original.name);
        expect(copy.artistName, original.artistName);
        expect(copy.genres, original.genres);
        expect(copy.explicit, original.explicit);
      });
    });

    group('toBuilderData', () {
      test('should convert podcast to builder data map', () {
        final releaseDate = DateTime(2025);
        final podcast = Podcast(
          id: '123456',
          name: 'Test Podcast',
          artistName: 'Test Artist',
          genres: const ['Technology'],
          explicit: true,
          feedUrl: 'https://example.com/feed.rss',
          description: 'A test description',
          artworkUrl: 'https://example.com/artwork.jpg',
          releaseDate: releaseDate,
          trackCount: 100,
        );

        final data = podcast.toBuilderData();

        expect(data['id'], podcast.id);
        expect(data['name'], podcast.name);
        expect(data['artistName'], podcast.artistName);
        expect(data['genres'], podcast.genres);
        expect(data['explicit'], podcast.explicit);
        expect(data['feedUrl'], podcast.feedUrl);
        expect(data['description'], podcast.description);
        expect(data['artworkUrl'], podcast.artworkUrl);
        expect(data['releaseDate'], podcast.releaseDate);
        expect(data['trackCount'], podcast.trackCount);
      });
    });
  });
}
