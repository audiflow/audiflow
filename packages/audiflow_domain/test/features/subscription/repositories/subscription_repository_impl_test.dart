import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SubscriptionRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final datasource = SubscriptionLocalDatasource(db);
    repository = SubscriptionRepositoryImpl(datasource: datasource);
  });

  tearDown(() async {
    await db.close();
  });

  group('subscribe', () {
    test('creates subscription with required fields', () async {
      final result = await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      expect(result.id, 1);
      expect(result.itunesId, 'itunes-1');
      expect(result.feedUrl, 'https://example.com/feed.xml');
      expect(result.title, 'Test Podcast');
      expect(result.artistName, 'Test Artist');
    });

    test('creates subscription with optional fields', () async {
      final result = await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
        artworkUrl: 'https://example.com/art.jpg',
        description: 'A test podcast',
        genres: ['Technology', 'Science'],
        explicit: true,
      );

      expect(result.artworkUrl, 'https://example.com/art.jpg');
      expect(result.description, 'A test podcast');
      expect(result.genres, 'Technology,Science');
      expect(result.explicit, true);
    });

    test('defaults explicit to false and genres to empty', () async {
      final result = await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      expect(result.explicit, false);
      expect(result.genres, isEmpty);
    });
  });

  group('unsubscribe', () {
    test('removes existing subscription', () async {
      await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      await repository.unsubscribe('itunes-1');

      final isSubscribed = await repository.isSubscribed('itunes-1');
      expect(isSubscribed, false);
    });

    test('throws SubscriptionNotFoundException for nonexistent', () async {
      expect(
        () => repository.unsubscribe('nonexistent'),
        throwsA(isA<SubscriptionNotFoundException>()),
      );
    });
  });

  group('isSubscribed', () {
    test('returns true when subscribed', () async {
      await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      final result = await repository.isSubscribed('itunes-1');

      expect(result, true);
    });

    test('returns false when not subscribed', () async {
      final result = await repository.isSubscribed('itunes-1');

      expect(result, false);
    });
  });

  group('isSubscribedByFeedUrl', () {
    test('returns true when subscribed by feed URL', () async {
      await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      final result = await repository.isSubscribedByFeedUrl(
        'https://example.com/feed.xml',
      );

      expect(result, true);
    });

    test('returns false when not subscribed by feed URL', () async {
      final result = await repository.isSubscribedByFeedUrl(
        'https://example.com/unknown.xml',
      );

      expect(result, false);
    });
  });

  group('getSubscriptions', () {
    test('returns empty list when no subscriptions', () async {
      final result = await repository.getSubscriptions();

      expect(result, isEmpty);
    });

    test('returns all subscriptions', () async {
      await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed1.xml',
        title: 'Podcast 1',
        artistName: 'Artist 1',
      );
      await repository.subscribe(
        itunesId: 'itunes-2',
        feedUrl: 'https://example.com/feed2.xml',
        title: 'Podcast 2',
        artistName: 'Artist 2',
      );

      final result = await repository.getSubscriptions();

      expect(result, hasLength(2));
    });
  });

  group('getSubscription', () {
    test('returns subscription by iTunes ID', () async {
      await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      final result = await repository.getSubscription('itunes-1');

      expect(result, isNotNull);
      expect(result!.title, 'Test Podcast');
    });

    test('returns null for nonexistent iTunes ID', () async {
      final result = await repository.getSubscription('nonexistent');

      expect(result, isNull);
    });
  });

  group('getByFeedUrl', () {
    test('returns subscription by feed URL', () async {
      await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      final result = await repository.getByFeedUrl(
        'https://example.com/feed.xml',
      );

      expect(result, isNotNull);
      expect(result!.itunesId, 'itunes-1');
    });

    test('returns null for nonexistent feed URL', () async {
      final result = await repository.getByFeedUrl(
        'https://example.com/unknown.xml',
      );

      expect(result, isNull);
    });
  });

  group('getById', () {
    test('returns subscription by database ID', () async {
      final sub = await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      final result = await repository.getById(sub.id);

      expect(result, isNotNull);
      expect(result!.itunesId, 'itunes-1');
    });

    test('returns null for nonexistent ID', () async {
      final result = await repository.getById(999);

      expect(result, isNull);
    });
  });

  group('updateLastRefreshed', () {
    test('updates the lastRefreshedAt timestamp', () async {
      await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );
      final timestamp = DateTime(2024, 6, 15);

      await repository.updateLastRefreshed('itunes-1', timestamp);

      final result = await repository.getSubscription('itunes-1');
      expect(result!.lastRefreshedAt, timestamp);
    });
  });

  group('watchSubscriptions', () {
    test('emits current subscriptions', () async {
      await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      final result = await repository.watchSubscriptions().first;

      expect(result, hasLength(1));
    });
  });
}
