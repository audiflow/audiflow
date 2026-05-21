import 'dart:convert';

import 'package:audiflow_domain/src/features/feed/services/preset_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PresetLoader', () {
    test('parses valid JSON with version 2', () {
      final json = jsonEncode({
        'dataVersion': 1,
        'schemaVersion': 1,
        'presets': [
          {
            'id': 'test',
            'feedUrls': ['https://example.com/feed'],
            'playlists': [
              {
                'id': 'main',
                'displayName': 'Main',
                'grouping': {'by': 'seasonNumber'},
                'priority': 0,
              },
            ],
          },
        ],
      });
      final result = PresetLoader.parse(json);
      expect(result, hasLength(1));
      expect(result[0].id, 'test');
      expect(result[0].playlists, hasLength(1));
    });

    test('returns empty list for empty patterns', () {
      final json = jsonEncode({
        'dataVersion': 1,
        'schemaVersion': 1,
        'presets': [],
      });
      final result = PresetLoader.parse(json);
      expect(result, isEmpty);
    });
  });
}
