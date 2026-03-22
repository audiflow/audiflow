import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_subscription_repository.dart';
import 'package:audiflow_domain/src/features/share/services/share_link_builder_impl.dart';

void main() {
  late FakeSubscriptionRepository fakeSubRepo;
  late ShareLinkBuilderImpl builder;

  setUp(() {
    fakeSubRepo = FakeSubscriptionRepository();
    builder = ShareLinkBuilderImpl(subscriptionRepository: fakeSubRepo);
  });

  group('buildPodcastLink', () {
    test('returns URL with itunesId from subscription', () async {
      fakeSubRepo.addSubscription(id: 1, itunesId: '1234567');

      final result = await builder.buildPodcastLink(subscriptionId: 1);

      check(result).equals('https://audiflow.reedom.com/p/1234567');
    });

    test('returns null when subscription not found', () async {
      final result = await builder.buildPodcastLink(subscriptionId: 99);

      check(result).isNull();
    });
  });

  group('buildEpisodeLink', () {
    test('returns URL with base64url-encoded guid without padding', () async {
      fakeSubRepo.addSubscription(id: 1, itunesId: '1234567');

      final result = await builder.buildEpisodeLink(
        subscriptionId: 1,
        episodeGuid: 'test-guid',
      );

      // 'test-guid' -> base64url no padding = 'dGVzdC1ndWlk'
      check(
        result,
      ).equals('https://audiflow.reedom.com/p/1234567/e/dGVzdC1ndWlk');
    });

    test('encoded guid contains no +, /, or = characters', () async {
      fakeSubRepo.addSubscription(id: 1, itunesId: '1234567');

      final result = await builder.buildEpisodeLink(
        subscriptionId: 1,
        episodeGuid: 'https://example.com/ep/1?v=2',
      );

      check(result).isNotNull();
      final uri = Uri.parse(result!);
      final encodedPart = uri.pathSegments.last;
      check(encodedPart).not((s) => s.contains('+'));
      check(encodedPart).not((s) => s.contains('/'));
      check(encodedPart).not((s) => s.contains('='));
    });

    test('returns null when subscription not found', () async {
      final result = await builder.buildEpisodeLink(
        subscriptionId: 99,
        episodeGuid: 'test-guid',
      );

      check(result).isNull();
    });
  });
}
