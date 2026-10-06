import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late SubscriptionRepositoryImpl repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([SubscriptionSchema]);
    final datasource = SubscriptionLocalDatasource(isar);
    repository = SubscriptionRepositoryImpl(datasource: datasource);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
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

      expect(await repository.isSubscribed('itunes-1'), true);
    });

    test('returns false when not subscribed', () async {
      expect(await repository.isSubscribed('itunes-1'), false);
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

      expect(
        await repository.isSubscribedByFeedUrl('https://example.com/feed.xml'),
        true,
      );
    });

    test('returns false when not subscribed by feed URL', () async {
      expect(
        await repository.isSubscribedByFeedUrl(
          'https://example.com/unknown.xml',
        ),
        false,
      );
    });
  });

  group('getSubscriptions', () {
    test('returns empty list when no subscriptions', () async {
      expect(await repository.getSubscriptions(), isEmpty);
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

      expect(await repository.getSubscriptions(), hasLength(2));
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
      expect(await repository.getSubscription('nonexistent'), isNull);
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
      expect(
        await repository.getByFeedUrl('https://example.com/unknown.xml'),
        isNull,
      );
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
      expect(await repository.getById(999), isNull);
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

  group('updateAutoDownloadKeepCount', () {
    test('sets and clears the per-podcast override', () async {
      final sub = await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );
      expect(sub.autoDownloadKeepCount, isNull);

      await repository.updateAutoDownloadKeepCount(sub.id, 5);
      expect((await repository.getById(sub.id))!.autoDownloadKeepCount, 5);

      await repository.updateAutoDownloadKeepCount(sub.id, null);
      expect((await repository.getById(sub.id))!.autoDownloadKeepCount, isNull);
    });
  });

  group('auto-download activity', () {
    late Subscription sub;

    setUp(() async {
      sub = await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );
    });

    test('accumulates auto downloads since last play', () async {
      expect(await repository.addAutoDownloadsSinceLastPlay(sub.id, 2), 2);
      expect(await repository.addAutoDownloadsSinceLastPlay(sub.id, 3), 5);
    });

    test('returns 0 for an unknown subscription', () async {
      expect(await repository.addAutoDownloadsSinceLastPlay(999, 2), 0);
    });

    test('reset clears the count and the pause', () async {
      await repository.addAutoDownloadsSinceLastPlay(sub.id, 5);
      await repository.pauseAutoDownload(sub.id, DateTime(2026, 10, 6));

      await repository.resetAutoDownloadActivity(sub.id);

      final stored = (await repository.getById(sub.id))!;
      expect(stored.autoDownloadsSinceLastPlay, 0);
      expect(stored.autoDownloadPausedAt, isNull);
    });

    test('turning auto-download on clears the pause', () async {
      await repository.addAutoDownloadsSinceLastPlay(sub.id, 5);
      await repository.pauseAutoDownload(sub.id, DateTime(2026, 10, 6));

      await repository.updateAutoDownload(sub.id, autoDownload: true);

      final stored = (await repository.getById(sub.id))!;
      expect(stored.autoDownloadsSinceLastPlay, 0);
      expect(stored.autoDownloadPausedAt, isNull);
    });

    test('turning auto-download off keeps the pause', () async {
      await repository.pauseAutoDownload(sub.id, DateTime(2026, 10, 6));

      await repository.updateAutoDownload(sub.id, autoDownload: false);

      expect(
        (await repository.getById(sub.id))!.autoDownloadPausedAt,
        DateTime(2026, 10, 6),
      );
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

  group('updateHttpCacheHeaders', () {
    test('stores etag and lastModified', () async {
      final sub = await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      await repository.updateHttpCacheHeaders(
        sub.id,
        etag: '"abc123"',
        lastModified: 'Sat, 29 Mar 2026 00:00:00 GMT',
      );

      final result = await repository.getById(sub.id);
      expect(result!.httpEtag, '"abc123"');
      expect(result.httpLastModified, 'Sat, 29 Mar 2026 00:00:00 GMT');
    });

    test('clears headers when called with null values', () async {
      final sub = await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      // First set headers
      await repository.updateHttpCacheHeaders(
        sub.id,
        etag: '"abc123"',
        lastModified: 'Sat, 29 Mar 2026 00:00:00 GMT',
      );

      // Then clear them
      await repository.updateHttpCacheHeaders(sub.id);

      final result = await repository.getById(sub.id);
      expect(result!.httpEtag, isNull);
      expect(result.httpLastModified, isNull);
    });

    test('does nothing for nonexistent ID', () async {
      // Should not throw
      await repository.updateHttpCacheHeaders(999, etag: '"abc123"');
    });
  });
}
