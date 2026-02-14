import 'dart:io';

import 'package:audiflow_cli/src/patterns/pattern_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PatternRegistry registry;

  setUp(() {
    final jsonFile = File('test/fixtures/smart_playlist_patterns.json');
    registry = PatternRegistry.fromJson(jsonFile.readAsStringSync());
  });

  group('PatternRegistry', () {
    test('contains coten_radio pattern', () {
      expect(registry.patterns, isNotEmpty);
      expect(registry.findById('coten_radio'), isNotNull);
    });

    test('detects pattern from feed URL', () {
      final pattern = registry.detectFromUrl(
        'https://anchor.fm/s/8c2088c/podcast/rss',
      );

      expect(pattern, isNotNull);
      expect(pattern!.id, 'coten_radio');
    });

    test('returns null for unknown feed URL', () {
      final pattern = registry.detectFromUrl('https://example.com/unknown');

      expect(pattern, isNull);
    });

    test('lists all patterns with metadata', () {
      final list = registry.listPatterns();

      expect(list, isNotEmpty);
      expect(list.first.id, isNotEmpty);
      expect(list.first.feedUrls, isNotEmpty);
    });
  });
}
