import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RootMeta', () {
    test('deserializes from JSON', () {
      final json = {
        'dataVersion': 1,
        'schemaVersion': 1,
        'patterns': [
          {
            'id': 'coten_radio',
            'dataVersion': 1,
            'displayName': 'Coten Radio',
            'feedUrlHint': 'anchor.fm/s/8c2088c',
            'playlistCount': 3,
          },
        ],
      };
      final meta = RootMeta.fromJson(json);
      expect(meta.dataVersion, 1);
      expect(meta.schemaVersion, 1);
      expect(meta.patterns, hasLength(1));
      expect(meta.patterns[0].id, 'coten_radio');
    });

    test('serializes to JSON', () {
      final meta = RootMeta(
        dataVersion: 1,
        schemaVersion: 2,
        patterns: [
          PatternSummary(
            id: 'test',
            dataVersion: 1,
            displayName: 'Test',
            feedUrlHint: 'test.com',
            playlistCount: 2,
          ),
        ],
      );
      final json = meta.toJson();
      expect(json['dataVersion'], 1);
      expect(json['schemaVersion'], 2);
      expect(json['patterns'] as List, hasLength(1));
    });

    test('parses from JSON string', () {
      final jsonString = jsonEncode({
        'dataVersion': 1,
        'schemaVersion': 3,
        'patterns': [
          {
            'id': 'p1',
            'dataVersion': 1,
            'displayName': 'P1',
            'feedUrlHint': 'example.com',
            'playlistCount': 1,
          },
        ],
      });
      final meta = RootMeta.parseJson(jsonString);
      expect(meta.patterns, hasLength(1));
    });

    test('parseJson throws FormatException when dataVersion missing', () {
      final jsonString = jsonEncode({'schemaVersion': 1, 'patterns': []});
      expect(
        () => RootMeta.parseJson(jsonString),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
