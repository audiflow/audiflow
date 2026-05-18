import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late FakeAnalyticsService analytics;
  late SubscriptionRepositoryImpl repo;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([SubscriptionSchema]);
    analytics = FakeAnalyticsService();
    repo = SubscriptionRepositoryImpl(
      datasource: SubscriptionLocalDatasource(isar),
      analytics: analytics,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('SubscriptionRepositoryImpl analytics', () {
    test('subscribe emits PodcastSubscribed with hashed feedUrl', () async {
      await repo.subscribe(
        itunesId: '12345',
        feedUrl: 'https://example.com/podcast/feed.xml',
        title: 'Test',
        artistName: 'Artist',
        source: SubscribeSource.search,
      );

      check(analytics.events).length.equals(1);
      final e = analytics.events.single as PodcastSubscribed;
      check(
        e.podcastId,
      ).equals(stableId('https://example.com/podcast/feed.xml'));
      check(e.source).equals(SubscribeSource.search);
    });

    test('unsubscribe emits PodcastUnsubscribed with hashed feedUrl', () async {
      await repo.subscribe(
        itunesId: '12345',
        feedUrl: 'https://example.com/podcast/feed.xml',
        title: 'Test',
        artistName: 'Artist',
        source: SubscribeSource.search,
      );
      analytics.reset();

      await repo.unsubscribe('12345');

      check(analytics.events).length.equals(1);
      final e = analytics.events.single as PodcastUnsubscribed;
      check(
        e.podcastId,
      ).equals(stableId('https://example.com/podcast/feed.xml'));
    });

    test(
      'subscribe defaults to SubscribeSource.unknown if not passed',
      () async {
        await repo.subscribe(
          itunesId: '12345',
          feedUrl: 'https://example.com/podcast/feed.xml',
          title: 'Test',
          artistName: 'Artist',
        );

        check(analytics.events).length.equals(1);
        final e = analytics.events.single as PodcastSubscribed;
        check(e.source).equals(SubscribeSource.unknown);
      },
    );
  });
}
