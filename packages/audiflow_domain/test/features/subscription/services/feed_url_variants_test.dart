import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pairs https with http', () {
    check(feedUrlVariants('https://example.com/feed.xml?t=1')).deepEquals([
      'https://example.com/feed.xml?t=1',
      'http://example.com/feed.xml?t=1',
    ]);
  });

  test('pairs http with https', () {
    check(feedUrlVariants('http://example.com/feed.xml')).deepEquals([
      'http://example.com/feed.xml',
      'https://example.com/feed.xml',
    ]);
  });

  test('keeps other URLs alone', () {
    check(
      feedUrlVariants('ftp://example.com/feed.xml'),
    ).deepEquals(['ftp://example.com/feed.xml']);
  });

  group('isFetchableFeedUrl', () {
    for (final url in [
      'https://example.com/feed.xml',
      'http://example.com/feed.xml',
      'HTTPS://example.com/feed.xml',
    ]) {
      test('accepts $url', () => check(isFetchableFeedUrl(url)).isTrue());
    }

    for (final url in [
      '',
      '   ',
      'feeds/show.xml',
      '/feeds/show.xml',
      'example.com/feed.xml',
      'https://',
      'https:///feed.xml',
      'feed://example.com/feed.xml',
      'ftp://example.com/feed.xml',
      'http://[broken',
    ]) {
      test('rejects "$url"', () => check(isFetchableFeedUrl(url)).isFalse());
    }
  });
}
