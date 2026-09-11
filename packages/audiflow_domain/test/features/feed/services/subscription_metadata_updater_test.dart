import 'package:audiflow_domain/audiflow_domain.dart';
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

      expect(repository.callCount, 1);
      expect(repository.lastId, 1);
      expect(repository.lastArtworkUrl, 'https://example.com/art.jpg');
      expect(repository.lastArtistName, 'Jane Doe');
      expect(repository.lastDescription, 'Show notes');
    });

    test('replaces stored values the feed disagrees with', () async {
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

      expect(repository.lastArtworkUrl, 'https://example.com/new.jpg');
      expect(repository.lastArtistName, 'New Artist');
      expect(repository.lastDescription, 'New notes');
    });

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

      expect(repository.callCount, 0);
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

      expect(repository.callCount, 1);
      expect(repository.lastArtworkUrl, isNull);
      expect(repository.lastArtistName, isNull);
      expect(repository.lastDescription, 'Show notes');
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

      expect(repository.callCount, 0);
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

      expect(repository.lastArtworkUrl, isNull);
      expect(repository.lastArtistName, 'Jane Doe');
      expect(repository.lastDescription, 'Show notes');
    });
  });
}
