import 'package:audiflow_cli/src/patterns/pattern_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatternRegistry', () {
    test('contains coten_radio pattern', () {
      final registry = PatternRegistry();

      expect(registry.patterns, isNotEmpty);
      expect(registry.findById('coten_radio'), isNotNull);
    });

    test('detects pattern from feed URL', () {
      final registry = PatternRegistry();

      final pattern = registry.detectFromUrl(
        'https://anchor.fm/s/8c2088c/podcast/rss',
      );

      expect(pattern, isNotNull);
      expect(pattern!.id, 'coten_radio');
    });

    test('returns null for unknown feed URL', () {
      final registry = PatternRegistry();

      final pattern = registry.detectFromUrl('https://example.com/unknown');

      expect(pattern, isNull);
    });

    test('lists all patterns with metadata', () {
      final registry = PatternRegistry();

      final list = registry.listPatterns();

      expect(list, isNotEmpty);
      expect(list.first.id, isNotEmpty);
      expect(list.first.feedUrlPatterns, isNotEmpty);
    });
  });
}
