import 'package:flutter_test/flutter_test.dart';
import 'package:audiflow_domain/audiflow_domain.dart';

void main() {
  group('BackgroundNotificationService', () {
    group('formatNotificationBody', () {
      test('single podcast', () {
        final body = BackgroundNotificationService.formatNotificationBody({
          'Podcast A': 2,
        });
        expect(body, '2 new episodes from Podcast A');
      });

      test('two podcasts', () {
        final body = BackgroundNotificationService.formatNotificationBody({
          'Podcast A': 1,
          'Podcast B': 3,
        });
        expect(body, '4 new episodes from Podcast A and Podcast B');
      });

      test('three or more podcasts', () {
        final body = BackgroundNotificationService.formatNotificationBody({
          'Podcast A': 1,
          'Podcast B': 2,
          'Podcast C': 1,
        });
        expect(body, '4 new episodes from Podcast A, Podcast B, and 1 other');
      });

      test('four or more podcasts', () {
        final body = BackgroundNotificationService.formatNotificationBody({
          'Podcast A': 1,
          'Podcast B': 1,
          'Podcast C': 1,
          'Podcast D': 1,
        });
        expect(body, '4 new episodes from Podcast A, Podcast B, and 2 others');
      });

      test('empty map returns empty string', () {
        final body = BackgroundNotificationService.formatNotificationBody({});
        expect(body, '');
      });

      test('singular episode when total is 1', () {
        final body = BackgroundNotificationService.formatNotificationBody({
          'Podcast A': 1,
        });
        expect(body, '1 new episode from Podcast A');
      });
    });
  });
}
