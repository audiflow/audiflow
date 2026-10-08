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
  DateTime? lastSyncedAt;
  String? storedWebsite;
  DateTime? websiteSyncedAt;
  int websiteWrites = 0;

  @override
  Future<void> updateWebsiteUrl(
    int id,
    String? websiteUrl, {
    required DateTime syncedAt,
  }) async {
    websiteWrites++;
    storedWebsite = websiteUrl ?? storedWebsite;
    websiteSyncedAt = syncedAt;
  }

  @override
  Future<void> updateFeedMetadata(
    int id, {
    String? artworkUrl,
    String? artistName,
    String? description,
    DateTime? syncedAt,
  }) async {
    callCount++;
    lastId = id;
    lastArtworkUrl = artworkUrl;
    lastArtistName = artistName;
    lastDescription = description;
    lastSyncedAt = syncedAt;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Subscription _subscription({
  int id = 1,
  String artistName = '',
  String? artworkUrl,
  String? description,
  DateTime? feedMetadataSyncedAt,
  String? websiteUrl,
  DateTime? websiteSyncedAt,
}) {
  return Subscription()
    ..id = id
    ..itunesId = 'opml:abc'
    ..feedUrl = 'https://example.com/feed.xml'
    ..title = 'Test Podcast'
    ..artistName = artistName
    ..artworkUrl = artworkUrl
    ..description = description
    ..feedMetadataSyncedAt = feedMetadataSyncedAt
    ..websiteUrl = websiteUrl
    ..websiteSyncedAt = websiteSyncedAt
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

    test('replaces stored artwork, author, and description', () async {
      // A show that replaces its artwork publishes a new channel image URL;
      // keeping the stored one would pin the old artwork forever.
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

      check(repository.lastArtworkUrl).equals('https://example.com/new.jpg');
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
        feedMetadataSyncedAt: DateTime(2026),
      );

      await updater.applyFeedMeta(
        sub,
        const FeedMetaReady(title: 'Test Podcast', description: '   '),
      );

      check(repository.callCount).equals(0);
    });

    test('records the channel read even when nothing changed', () async {
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

      check(repository.callCount).equals(1);
      check(repository.lastSyncedAt).isNotNull();
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
        feedMetadataSyncedAt: DateTime(2026),
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

  group('SubscriptionMetadataUpdater website', () {
    test('stores the channel website', () async {
      await updater.apply(_subscription(), link: ' https://example.com/show ');
      check(repository.storedWebsite).equals('https://example.com/show');
    });

    test('a channel without a link keeps the stored website', () async {
      await updater.apply(
        _subscription(
          websiteUrl: 'https://example.com/show',
          websiteSyncedAt: DateTime(2026),
        ),
        link: null,
      );
      check(repository.websiteWrites).equals(0);
    });

    test('an unchanged website is not written again', () async {
      await updater.apply(
        _subscription(
          websiteUrl: 'https://example.com/show',
          websiteSyncedAt: DateTime(2026),
        ),
        link: 'https://example.com/show',
      );
      check(repository.websiteWrites).equals(0);
    });

    test('the first read is recorded even without a link', () async {
      // Stops the backfill: a feed with no <link> would otherwise be
      // fetched unconditionally on every refresh.
      await updater.apply(_subscription(), link: null);
      check(repository.websiteWrites).equals(1);
      check(repository.storedWebsite).isNull();
      check(repository.websiteSyncedAt).isNotNull();
    });
  });

  group('SubscriptionMetadataUpdater.needsChannelBackfill', () {
    final synced = DateTime(2026);

    test('is true until the website has been read', () {
      // Subscriptions made before the website was stored only 304 on
      // refresh, so they never parse the channel <link> otherwise.
      check(
        SubscriptionMetadataUpdater.needsChannelBackfill(
          _subscription(
            artworkUrl: 'https://example.com/art.jpg',
            feedMetadataSyncedAt: synced,
          ),
        ),
      ).isTrue();
    });

    test('is true while artwork needs a backfill', () {
      check(
        SubscriptionMetadataUpdater.needsChannelBackfill(
          _subscription(websiteSyncedAt: synced),
        ),
      ).isTrue();
    });

    test('is false once both have been read', () {
      check(
        SubscriptionMetadataUpdater.needsChannelBackfill(
          _subscription(feedMetadataSyncedAt: synced, websiteSyncedAt: synced),
        ),
      ).isFalse();
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

    test('is false once the channel has been read, artwork or not', () {
      // The parser recognises only itunes:image, so a feed carrying a plain
      // RSS <image> yields no artwork at all. Without the timestamp such a
      // subscription would refetch its whole feed on every refresh forever.
      check(
        SubscriptionMetadataUpdater.needsArtworkBackfill(
          _subscription(feedMetadataSyncedAt: DateTime(2026)),
        ),
      ).isFalse();
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
