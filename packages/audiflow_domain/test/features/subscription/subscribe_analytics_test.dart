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
    test(
      'subscribe emits PodcastSubscribed with raw iTunes id and title',
      () async {
        await repo.subscribe(
          itunesId: '12345',
          feedUrl: 'https://example.com/podcast/feed.xml',
          title: 'Test',
          artistName: 'Artist',
          source: SubscribeSource.search,
        );

        check(analytics.events).length.equals(1);
        final e = analytics.events.single as PodcastSubscribed;
        check(e.podcastId).equals('12345');
        check(e.podcastTitle).equals('Test');
        check(e.source).equals(SubscribeSource.search);
        // Params carry the title too.
        check(e.params['podcast_title']).equals('Test');
      },
    );

    test(
      'unsubscribe emits PodcastUnsubscribed with raw iTunes id and title',
      () async {
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
        check(e.podcastId).equals('12345');
        check(e.podcastTitle).equals('Test');
      },
    );

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

    test('OPML-imported subscriptions use feedUrl as podcast_id', () async {
      const feedUrl = 'https://example.com/podcast/feed.xml';
      await repo.subscribe(
        itunesId: 'opml:abc123',
        feedUrl: feedUrl,
        title: 'Imported',
        artistName: 'Artist',
        source: SubscribeSource.opml,
      );

      final subscribed = analytics.events.single as PodcastSubscribed;
      check(subscribed.podcastId).equals(feedUrl);
      check(subscribed.source).equals(SubscribeSource.opml);

      analytics.reset();
      await repo.unsubscribe('opml:abc123');

      final unsubscribed = analytics.events.single as PodcastUnsubscribed;
      check(unsubscribed.podcastId).equals(feedUrl);
      check(unsubscribed.podcastTitle).equals('Imported');
    });
  });
}
