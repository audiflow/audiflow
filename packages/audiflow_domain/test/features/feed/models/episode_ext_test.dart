import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toPodcastItem', () {
    Episode episode({required bool explicit}) => Episode()
      ..podcastId = 1
      ..guid = 'g'
      ..title = 'T'
      ..audioUrl = 'https://example.com/a.mp3'
      ..itunesExplicit = explicit;

    test('carries the explicit flag', () {
      check(episode(explicit: true).toPodcastItem().isExplicit).equals(true);
      check(episode(explicit: false).toPodcastItem().isExplicit).equals(false);
    });
  });
}
