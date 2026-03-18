import 'package:audiflow_app/features/player/helpers/podcast_lookup.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  group('lookupPodcastForEpisode', () {
    late FakeSubscriptionRepository fakeRepo;

    final subscriptionA = Subscription()
      ..id = 4
      ..itunesId = '111'
      ..feedUrl = 'https://example.com/a.xml'
      ..title = 'Podcast A'
      ..artistName = 'Artist A'
      ..genres = 'Tech'
      ..explicit = false
      ..subscribedAt = DateTime(2024, 1, 1);

    final subscriptionB = Subscription()
      ..id = 7
      ..itunesId = '222'
      ..feedUrl = 'https://example.com/b.xml'
      ..title = 'Podcast B'
      ..artistName = 'Artist B'
      ..genres = ''
      ..explicit = false
      ..subscribedAt = DateTime(2024, 2, 1);

    setUp(() {
      fakeRepo = FakeSubscriptionRepository(
        subscriptions: [subscriptionA, subscriptionB],
      );
    });

    test('returns podcast when direct ID lookup succeeds', () async {
      final result = await lookupPodcastForEpisode(
        subscriptionRepo: fakeRepo,
        podcastId: 4,
        podcastTitle: 'Podcast A',
      );

      check(result).isNotNull()
        ..has((p) => p.id, 'id').equals('111')
        ..has((p) => p.name, 'name').equals('Podcast A');
    });

    test('falls back to title match when ID lookup fails', () async {
      final result = await lookupPodcastForEpisode(
        subscriptionRepo: fakeRepo,
        podcastId: 1, // stale ID, no subscription with this ID
        podcastTitle: 'Podcast B',
      );

      check(result).isNotNull()
        ..has((p) => p.id, 'id').equals('222')
        ..has((p) => p.name, 'name').equals('Podcast B');
    });

    test('returns null when both ID and title lookups fail', () async {
      final result = await lookupPodcastForEpisode(
        subscriptionRepo: fakeRepo,
        podcastId: 99,
        podcastTitle: 'Nonexistent Podcast',
      );

      check(result).isNull();
    });

    test('skips title fallback when podcastTitle is empty', () async {
      final result = await lookupPodcastForEpisode(
        subscriptionRepo: fakeRepo,
        podcastId: 99,
        podcastTitle: '',
      );

      check(result).isNull();
    });

    test('prefers direct ID match over title match', () async {
      final repoWithConflict = FakeSubscriptionRepository(
        subscriptions: [
          subscriptionA,
          Subscription()
            ..id = 10
            ..itunesId = '999'
            ..feedUrl = 'https://example.com/c.xml'
            ..title = 'Podcast A'
            ..artistName = 'Other Artist'
            ..genres = ''
            ..explicit = false
            ..subscribedAt = DateTime(2024, 3, 1),
        ],
      );

      final result = await lookupPodcastForEpisode(
        subscriptionRepo: repoWithConflict,
        podcastId: 4,
        podcastTitle: 'Podcast A',
      );

      check(result).isNotNull().has((p) => p.id, 'id').equals('111');
    });
  });
}
