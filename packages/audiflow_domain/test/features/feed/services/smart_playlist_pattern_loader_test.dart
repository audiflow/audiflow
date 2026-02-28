import 'dart:convert';

import 'package:audiflow_domain/src/features/feed/services/smart_playlist_pattern_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistPatternLoader', () {
    test('parses valid JSON with version 2', () {
      final json = jsonEncode({
        'version': 2,
        'patterns': [
          {
            'id': 'test',
            'feedUrls': ['https://example.com/feed'],
            'playlists': [
              {'id': 'main', 'displayName': 'Main', 'resolverType': 'rss'},
            ],
          },
        ],
      });
      final result = SmartPlaylistPatternLoader.parse(json);
      expect(result, hasLength(1));
      expect(result[0].id, 'test');
      expect(result[0].playlists, hasLength(1));
    });

    test('returns empty list for empty patterns', () {
      final json = jsonEncode({'version': 2, 'patterns': []});
      final result = SmartPlaylistPatternLoader.parse(json);
      expect(result, isEmpty);
    });
  });
}
