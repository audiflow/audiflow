import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_domain/src/features/share/services/share_link_builder_impl.dart';

void main() {
  late ShareLinkBuilderImpl builder;

  setUp(() {
    builder = ShareLinkBuilderImpl();
  });

  group('buildPodcastLink', () {
    test('returns URL with itunesId', () async {
      final result = await builder.buildPodcastLink(itunesId: '1234567');

      check(result).equals('https://audiflow.reedom.com/p/1234567');
    });
  });

  group('buildEpisodeLink', () {
    test('returns URL with base64url-encoded guid without padding', () async {
      final result = await builder.buildEpisodeLink(
        itunesId: '1234567',
        episodeGuid: 'test-guid',
      );

      // 'test-guid' -> base64url no padding = 'dGVzdC1ndWlk'
      check(
        result,
      ).equals('https://audiflow.reedom.com/p/1234567/e/dGVzdC1ndWlk');
    });

    test('encoded guid contains no +, /, or = characters', () async {
      final result = await builder.buildEpisodeLink(
        itunesId: '1234567',
        episodeGuid: 'https://example.com/ep/1?v=2',
      );

      check(result).isNotNull();
      final uri = Uri.parse(result!);
      final encodedPart = uri.pathSegments.last;
      check(encodedPart).not((s) => s.contains('+'));
      check(encodedPart).not((s) => s.contains('/'));
      check(encodedPart).not((s) => s.contains('='));
    });
  });
}
