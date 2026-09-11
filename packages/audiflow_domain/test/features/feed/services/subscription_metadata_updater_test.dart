import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures [updateFeedMetadata] calls; every other member is unused here.
class _FakeSubscriptionRepository implements SubscriptionRepository {
  int callCount = 0;
  int? lastId;
  String? lastArtworkUrl;
  String? lastArtistName;
  String? lastDescription;

  @override
  Future<void> updateFeedMetadata(
    int id, {
    String? artworkUrl,
    String? artistName,
    String? description,
  }) async {
    callCount++;
    lastId = id;
    lastArtworkUrl = artworkUrl;
    lastArtistName = artistName;
    lastDescription = description;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Subscription _subscription({
  int id = 1,
  String artistName = '',
  String? artworkUrl,
  String? description,
}) {
  return Subscription()
    ..id = id
    ..itunesId = 'opml:abc'
    ..feedUrl = 'https://example.com/feed.xml'
    ..title = 'Test Podcast'
    ..artistName = artistName
    ..artworkUrl = artworkUrl
    ..description = description
    ..genres = ''
    ..explicit = false
    ..subscribedAt = DateTime.now();
}

void main() {
  late _FakeSubscriptionRepository repository;
  late SubscriptionMetadataUpdater updater;

  setUp(() {
    repository = _FakeSubscriptionRepository();
    updater = SubscriptionMetadataUpdater(repository);
  });

  group('SubscriptionMetadataUpdater.applyFeedMeta', () {
    test('fills every field left empty by OPML import', () async {
      final sub = _subscription();

      await updater.applyFeedMeta(
        sub,
        const FeedMetaReady(
          title: 'Test Podcast',
          description: 'Show notes',
          imageUrl: 'https://example.com/art.jpg',
          author: 'Jane Doe',
        ),
      );

      check(repository.callCount).equals(1);
      check(repository.lastId).equals(1);
      check(repository.lastArtworkUrl).equals('https://example.com/art.jpg');
      check(repository.lastArtistName).equals('Jane Doe');
      check(repository.lastDescription).equals('Show notes');
    });

    test('replaces a stored author and description, but not artwork', () async {
      // The channel image is 1400-3000 px per Apple's spec against a 600 px
      // search artwork, and artwork is decoded at its intrinsic size, so a
      // stored URL is never swapped out.
      final sub = _subscription(
        artistName: 'Old Artist',
        artworkUrl: 'https://example.com/old.jpg',
        description: 'Old notes',
      );

      await updater.applyFeedMeta(
        sub,
        const FeedMetaReady(
          title: 'Test Podcast',
          description: 'New notes',
          imageUrl: 'https://example.com/new.jpg',
          author: 'New Artist',
        ),
      );

      check(repository.lastArtworkUrl).isNull();
      check(repository.lastArtistName).equals('New Artist');
      check(repository.lastDescription).equals('New notes');
    });

    test(
      'fills artwork when the stored value is blank rather than null',
      () async {
        final sub = _subscription(artworkUrl: '   ');

        await updater.applyFeedMeta(
          sub,
          const FeedMetaReady(
            title: 'Test Podcast',
            description: 'Show notes',
            imageUrl: 'https://example.com/art.jpg',
          ),
        );

        check(repository.lastArtworkUrl).equals('https://example.com/art.jpg');
      },
    );

    test('keeps stored values when the channel omits them', () async {
      final sub = _subscription(
        artistName: 'Search Artist',
        artworkUrl: 'https://example.com/itunes.jpg',
        description: 'Search description',
      );

      await updater.applyFeedMeta(
        sub,
        const FeedMetaReady(title: 'Test Podcast', description: '   '),
      );

      check(repository.callCount).equals(0);
    });

    test('writes only the fields the channel actually changes', () async {
      final sub = _subscription(
        artistName: 'Jane Doe',
        artworkUrl: 'https://example.com/itunes.jpg',
      );

      await updater.applyFeedMeta(
        sub,
        const FeedMetaReady(
          title: 'Test Podcast',
          description: 'Show notes',
          imageUrl: 'https://example.com/itunes.jpg',
          author: 'Jane Doe',
        ),
      );

      check(repository.callCount).equals(1);
      check(repository.lastArtworkUrl).isNull();
      check(repository.lastArtistName).isNull();
      check(repository.lastDescription).equals('Show notes');
    });

    test('skips the write when the feed matches what is stored', () async {
      final sub = _subscription(
        artistName: 'Jane Doe',
        artworkUrl: 'https://example.com/art.jpg',
        description: 'Show notes',
      );

      await updater.applyFeedMeta(
        sub,
        const FeedMetaReady(
          title: 'Test Podcast',
          description: 'Show notes',
          imageUrl: 'https://example.com/art.jpg',
          author: 'Jane Doe',
        ),
      );

      check(repository.callCount).equals(0);
    });

    test('trims surrounding whitespace before comparing and writing', () async {
      final sub = _subscription(artworkUrl: 'https://example.com/art.jpg');

      await updater.applyFeedMeta(
        sub,
        const FeedMetaReady(
          title: 'Test Podcast',
          description: '  Show notes  ',
          imageUrl: '  https://example.com/art.jpg  ',
          author: '  Jane Doe  ',
        ),
      );

      check(repository.lastArtworkUrl).isNull();
      check(repository.lastArtistName).equals('Jane Doe');
      check(repository.lastDescription).equals('Show notes');
    });
  });

  group('SubscriptionMetadataUpdater.needsArtworkBackfill', () {
    test('is true while no artwork is stored', () {
      check(
        SubscriptionMetadataUpdater.needsArtworkBackfill(_subscription()),
      ).isTrue();
      check(
        SubscriptionMetadataUpdater.needsArtworkBackfill(
          _subscription(artworkUrl: '  '),
        ),
      ).isTrue();
    });

    test('is false once artwork is stored', () {
      check(
        SubscriptionMetadataUpdater.needsArtworkBackfill(
          _subscription(artworkUrl: 'https://example.com/art.jpg'),
        ),
      ).isFalse();
    });
  });
}
