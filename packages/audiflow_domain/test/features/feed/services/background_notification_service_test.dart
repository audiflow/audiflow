import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackgroundNotificationService', () {
    group('buildNotificationDetails', () {
      test('returns per-episode details list', () {
        final notifications = [
          const NewEpisodeNotification(
            episodeId: 1,
            podcastId: 10,
            podcastTitle: 'Podcast A',
            episodeTitle: 'Episode 1',
          ),
          const NewEpisodeNotification(
            episodeId: 2,
            podcastId: 10,
            podcastTitle: 'Podcast A',
            episodeTitle: 'Episode 2',
          ),
        ];

        final details = BackgroundNotificationService.buildNotificationDetails(
          notifications,
        );

        expect(details.length, 2);

        expect(details[0].id, 1);
        expect(details[0].title, 'Podcast A');
        expect(details[0].body, 'Episode 1');
        final payload0 = jsonDecode(details[0].payload) as Map<String, dynamic>;
        expect(payload0['type'], 'new_episode');
        expect(payload0['episodeId'], 1);
        expect(payload0['podcastId'], 10);

        expect(details[1].id, 2);
        expect(details[1].title, 'Podcast A');
        expect(details[1].body, 'Episode 2');
      });

      test('returns empty list for empty input', () {
        final details = BackgroundNotificationService.buildNotificationDetails(
          [],
        );
        expect(details, isEmpty);
      });
    });
  });
}
