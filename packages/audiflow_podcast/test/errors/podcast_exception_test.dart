import 'package:audiflow_podcast/src/errors/podcast_exception.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PodcastException.isFeedUnavailable', () {
    for (final status in [400, 401, 403, 404, 410]) {
      test('is true for HTTP $status', () {
        final error = PodcastException.network('x', statusCode: status);

        check(error.statusCode).equals(status);
        check(error.isFeedUnavailable).isTrue();
      });
    }

    // Timeouts and rate limits clear up on their own, and server errors
    // are worth seeing in error monitoring.
    for (final status in [408, 429, 500, 503]) {
      test('is false for HTTP $status', () {
        final error = PodcastException.network('x', statusCode: status);

        check(error.isFeedUnavailable).isFalse();
      });
    }

    test('is false without a status code', () {
      check(PodcastException.network('offline').isFeedUnavailable).isFalse();
      check(PodcastException.parsing('bad xml').isFeedUnavailable).isFalse();
    });
  });
}
