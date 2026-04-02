import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewEpisodeNotification', () {
    test('constructs with required fields', () {
      final notification = NewEpisodeNotification(
        episodeId: 42,
        podcastId: 7,
        podcastTitle: 'The Daily',
        episodeTitle: 'Breaking News',
      );

      expect(notification.episodeId, 42);
      expect(notification.podcastId, 7);
      expect(notification.podcastTitle, 'The Daily');
      expect(notification.episodeTitle, 'Breaking News');
    });

    test('toPayload returns valid JSON with type and IDs', () {
      final notification = NewEpisodeNotification(
        episodeId: 42,
        podcastId: 7,
        podcastTitle: 'The Daily',
        episodeTitle: 'Breaking News',
      );

      final payload = notification.toPayload();
      final decoded = jsonDecode(payload) as Map<String, dynamic>;

      expect(decoded['type'], 'new_episode');
      expect(decoded['episodeId'], 42);
      expect(decoded['podcastId'], 7);
    });
  });
}
