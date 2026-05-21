import 'dart:io';

import 'package:audiflow_cli/src/presets/preset_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PresetRegistry registry;

  setUp(() {
    final jsonFile = File('test/fixtures/smart_playlist_presets.json');
    registry = PresetRegistry.fromJson(jsonFile.readAsStringSync());
  });

  group('PresetRegistry', () {
    test('contains coten_radio pattern', () {
      expect(registry.presets, isNotEmpty);
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
      final list = registry.listPresets();

      expect(list, isNotEmpty);
      expect(list.first.id, isNotEmpty);
      expect(list.first.feedUrls, isNotEmpty);
    });
  });
}
