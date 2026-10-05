import 'package:audiflow_app/app/notification/test_notification_sender.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSubscriptionRepository implements SubscriptionRepository {
  _FakeSubscriptionRepository(this.subscriptions);

  final List<Subscription> subscriptions;

  @override
  Future<List<Subscription>> getSubscriptions() async => subscriptions;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeEpisodeRepository implements EpisodeRepository {
  _FakeEpisodeRepository(this.newestByPodcast);

  final Map<int, Episode> newestByPodcast;

  @override
  Future<Episode?> getNewestByPodcastId(int podcastId) async =>
      newestByPodcast[podcastId];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Subscription _subscription(int id) => Subscription()
  ..id = id
  ..itunesId = '$id'
  ..title = 'Podcast $id'
  ..artworkUrl = 'https://example.com/$id.jpg';

Episode _episode(int podcastId) => Episode()
  ..id = podcastId * 100
  ..podcastId = podcastId
  ..guid = 'g$podcastId'
  ..title = 'Episode of $podcastId'
  ..audioUrl = 'https://example.com/$podcastId.mp3';

void main() {
  late List<List<NewEpisodeNotification>> posted;

  setUp(() => posted = []);

  TestNotificationSender sender(
    List<Subscription> subscriptions,
    Map<int, Episode> newest,
  ) => TestNotificationSender(
    subscriptionRepo: _FakeSubscriptionRepository(subscriptions),
    episodeRepo: _FakeEpisodeRepository(newest),
    post: (notifications) async => posted.add(notifications),
  );

  test('posts the newest episode of each podcast, at most three', () async {
    final subscriptions = [for (var id = 1; id <= 5; id++) _subscription(id)];
    final newest = {for (final s in subscriptions) s.id: _episode(s.id)};

    final count = await sender(subscriptions, newest).send();

    check(count).equals(3);
    check(posted.single.map((n) => n.episodeId)).deepEquals([100, 200, 300]);
    check(posted.single.map((n) => n.artworkUrl)).deepEquals([
      'https://example.com/1.jpg',
      'https://example.com/2.jpg',
      'https://example.com/3.jpg',
    ]);
  });

  test('skips podcasts without episodes', () async {
    final subscriptions = [for (var id = 1; id <= 4; id++) _subscription(id)];

    final count = await sender(subscriptions, {
      2: _episode(2),
      4: _episode(4),
    }).send();

    check(count).equals(2);
    check(posted.single.map((n) => n.podcastId)).deepEquals([2, 4]);
  });

  test('posts nothing without subscriptions', () async {
    final count = await sender([], {}).send();

    check(count).equals(0);
    check(posted).isEmpty();
  });
}
