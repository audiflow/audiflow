import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SubscriptionLocalDatasource datasource;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = SubscriptionLocalDatasource(db);
  });

  tearDown(() async {
    await db.close();
  });

  SubscriptionsCompanion makeCompanion({
    String itunesId = 'itunes-1',
    String feedUrl = 'https://example.com/feed.xml',
    String title = 'Test Podcast',
    String artistName = 'Test Artist',
  }) {
    return SubscriptionsCompanion.insert(
      itunesId: itunesId,
      feedUrl: feedUrl,
      title: title,
      artistName: artistName,
      subscribedAt: DateTime.now(),
    );
  }

  group('insert', () {
    test('inserts subscription and returns it with generated id', () async {
      final result = await datasource.insert(makeCompanion());

      expect(result.id, 1);
      expect(result.itunesId, 'itunes-1');
      expect(result.feedUrl, 'https://example.com/feed.xml');
      expect(result.title, 'Test Podcast');
      expect(result.artistName, 'Test Artist');
    });

    test('auto-increments id for multiple inserts', () async {
      final first = await datasource.insert(makeCompanion());
      final second = await datasource.insert(
        makeCompanion(
          itunesId: 'itunes-2',
          feedUrl: 'https://example.com/feed2.xml',
        ),
      );

      expect(first.id, 1);
      expect(second.id, 2);
    });
  });

  group('deleteByItunesId', () {
    test('deletes existing subscription and returns 1', () async {
      await datasource.insert(makeCompanion());

      final deleted = await datasource.deleteByItunesId('itunes-1');

      expect(deleted, 1);
      final all = await datasource.getAll();
      expect(all, isEmpty);
    });

    test('returns 0 when subscription does not exist', () async {
      final deleted = await datasource.deleteByItunesId('nonexistent');

      expect(deleted, 0);
    });
  });

  group('getAll', () {
    test('returns empty list when no subscriptions exist', () async {
      final all = await datasource.getAll();

      expect(all, isEmpty);
    });

    test('returns subscriptions ordered by subscribedAt descending', () async {
      await datasource.insert(
        SubscriptionsCompanion.insert(
          itunesId: 'older',
          feedUrl: 'https://example.com/older.xml',
          title: 'Older Podcast',
          artistName: 'Artist',
          subscribedAt: DateTime(2024, 1, 1),
        ),
      );
      await datasource.insert(
        SubscriptionsCompanion.insert(
          itunesId: 'newer',
          feedUrl: 'https://example.com/newer.xml',
          title: 'Newer Podcast',
          artistName: 'Artist',
          subscribedAt: DateTime(2024, 6, 1),
        ),
      );

      final all = await datasource.getAll();

      expect(all, hasLength(2));
      expect(all.first.itunesId, 'newer');
      expect(all.last.itunesId, 'older');
    });
  });

  group('watchAll', () {
    test('emits current subscriptions', () async {
      await datasource.insert(makeCompanion());

      final result = await datasource.watchAll().first;

      expect(result, hasLength(1));
      expect(result.first.itunesId, 'itunes-1');
    });

    test('emits updates when subscription is added', () async {
      final stream = datasource.watchAll();

      // First emission: empty
      expectLater(stream, emitsInOrder([hasLength(0), hasLength(1)]));

      // Trigger an insert after stream is subscribed
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await datasource.insert(makeCompanion());
    });
  });

  group('getByItunesId', () {
    test('returns subscription when found', () async {
      await datasource.insert(makeCompanion());

      final result = await datasource.getByItunesId('itunes-1');

      expect(result, isNotNull);
      expect(result!.itunesId, 'itunes-1');
    });

    test('returns null when not found', () async {
      final result = await datasource.getByItunesId('nonexistent');

      expect(result, isNull);
    });
  });

  group('exists', () {
    test('returns true when subscription exists', () async {
      await datasource.insert(makeCompanion());

      final result = await datasource.exists('itunes-1');

      expect(result, true);
    });

    test('returns false when subscription does not exist', () async {
      final result = await datasource.exists('nonexistent');

      expect(result, false);
    });
  });

  group('existsByFeedUrl', () {
    test('returns true when subscription with feed URL exists', () async {
      await datasource.insert(makeCompanion());

      final result = await datasource.existsByFeedUrl(
        'https://example.com/feed.xml',
      );

      expect(result, true);
    });

    test('returns false when no subscription with feed URL', () async {
      final result = await datasource.existsByFeedUrl(
        'https://example.com/nonexistent.xml',
      );

      expect(result, false);
    });
  });

  group('getByFeedUrl', () {
    test('returns subscription when found', () async {
      await datasource.insert(makeCompanion());

      final result = await datasource.getByFeedUrl(
        'https://example.com/feed.xml',
      );

      expect(result, isNotNull);
      expect(result!.title, 'Test Podcast');
    });

    test('returns null when not found', () async {
      final result = await datasource.getByFeedUrl(
        'https://example.com/unknown.xml',
      );

      expect(result, isNull);
    });
  });

  group('getById', () {
    test('returns subscription when found', () async {
      final inserted = await datasource.insert(makeCompanion());

      final result = await datasource.getById(inserted.id);

      expect(result, isNotNull);
      expect(result!.itunesId, 'itunes-1');
    });

    test('returns null when not found', () async {
      final result = await datasource.getById(999);

      expect(result, isNull);
    });
  });

  group('updateLastRefreshed', () {
    test('updates lastRefreshedAt timestamp', () async {
      await datasource.insert(makeCompanion());
      final timestamp = DateTime(2024, 6, 15);

      await datasource.updateLastRefreshed('itunes-1', timestamp);

      final result = await datasource.getByItunesId('itunes-1');
      expect(result, isNotNull);
      expect(result!.lastRefreshedAt, timestamp);
    });

    test('returns 0 when subscription does not exist', () async {
      final timestamp = DateTime(2024, 6, 15);

      final updated = await datasource.updateLastRefreshed(
        'nonexistent',
        timestamp,
      );

      expect(updated, 0);
    });

    test('does not affect other subscriptions', () async {
      await datasource.insert(makeCompanion());
      await datasource.insert(
        makeCompanion(
          itunesId: 'itunes-2',
          feedUrl: 'https://example.com/feed2.xml',
        ),
      );
      final timestamp = DateTime(2024, 6, 15);

      await datasource.updateLastRefreshed('itunes-1', timestamp);

      final other = await datasource.getByItunesId('itunes-2');
      expect(other!.lastRefreshedAt, isNull);
    });
  });
}
