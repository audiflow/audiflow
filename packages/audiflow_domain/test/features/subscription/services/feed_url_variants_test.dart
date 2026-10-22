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
}
