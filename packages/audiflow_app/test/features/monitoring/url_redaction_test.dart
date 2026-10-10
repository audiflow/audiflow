import 'package:audiflow_app/features/monitoring/services/url_redaction.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const _secretUrl = 'https://u:p@feeds.example.com/private/rss?token=abc';
const _host = 'https://feeds.example.com';

void main() {
  group('redactUrls', () {
    test('keeps only scheme and host of each URL', () {
      check(
        redactUrls('a http://x.example.com/p?q=1 and https://y.example.org/'),
      ).equals('a http://x.example.com and https://y.example.org');
    });

    test('keeps punctuation that follows a URL', () {
      check(
        redactUrls('(url: https://x.example.com/a(b)?t=1).'),
      ).equals('(url: https://x.example.com).');
    });

    test('redacts apostrophes inside a URL', () {
      check(
        redactUrls("fetch 'https://x.example.com/p?token=abc'def' failed"),
      ).equals("fetch 'https://x.example.com' failed");
    });

    test('leaves text without URLs unchanged', () {
      check(
        redactUrls('parse failed at line 3'),
      ).equals('parse failed at line 3');
    });
  });

  group('scrubEventUrls', () {
    test('redacts exception values', () {
      final event = SentryEvent(
        exceptions: [
          SentryException(
            type: 'PodcastException',
            value: 'Network error (url: $_secretUrl)',
          ),
        ],
      );

      final scrubbed = scrubEventUrls(event);

      check(
        scrubbed.exceptions!.single.value,
      ).equals('Network error (url: $_host)');
    });

    test('redacts the event message', () {
      final event = SentryEvent(
        message: SentryMessage(
          'failed $_secretUrl',
          template: 'failed $_secretUrl',
        ),
      );

      final message = scrubEventUrls(event).message!;

      check(message.formatted).equals('failed $_host');
      check(message.template).equals('failed $_host');
    });

    test('redacts breadcrumb messages and nested data', () {
      final event = SentryEvent(
        breadcrumbs: [
          Breadcrumb(
            message: 'GET $_secretUrl',
            data: {
              'url': _secretUrl,
              'status_code': 200,
              'nested': {
                'list': [_secretUrl, 3],
              },
            },
          ),
        ],
      );

      final crumb = scrubEventUrls(event).breadcrumbs!.single;

      check(crumb.message).equals('GET $_host');
      check(crumb.data!['url']).equals(_host);
      check(crumb.data!['status_code']).equals(200);
      check(crumb.data!['nested']).isA<Map<String, dynamic>>().deepEquals({
        'list': [_host, 3],
      });
    });

    test('redacts custom contexts and keeps typed ones', () {
      final device = SentryDevice(name: 'iPad mini');
      final event = SentryEvent(
        contexts: Contexts(device: device)
          ..['player_interruption'] = {
            'error': 'PlayerException: $_secretUrl',
            'position': 42,
          },
      );

      final contexts = scrubEventUrls(event).contexts;

      check(contexts['player_interruption'])
          .isA<Map<String, dynamic>>()
          .deepEquals({'error': 'PlayerException: $_host', 'position': 42});
      check(contexts.device).identicalTo(device);
    });

    test('leaves an event without URLs intact', () {
      final event = SentryEvent(
        message: SentryMessage('plain'),
        exceptions: [SentryException(type: 'StateError', value: 'boom')],
      );

      final scrubbed = scrubEventUrls(event);

      check(scrubbed.message!.formatted).equals('plain');
      check(scrubbed.exceptions!.single.value).equals('boom');
    });
  });
}
