import 'dart:io';

import 'package:audiflow_cli/src/commands/smart_playlist_debug_command.dart';
import 'package:audiflow_cli/src/patterns/pattern_registry.dart';
import 'package:audiflow_podcast/parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PatternRegistry registry;

  setUp(() {
    final jsonFile = File('test/fixtures/smart_playlist_patterns.json');
    registry = PatternRegistry.fromJson(jsonFile.readAsStringSync());
  });

  group('SmartPlaylistDebugCommand', () {
    test('processes items and reports results', () async {
      final output = StringBuffer();
      final command = SmartPlaylistDebugCommand(
        sink: output,
        registry: registry,
      );

      final items = [
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title:
              '\u301762-15\u3018Test\u3010COTEN RADIO \u30ea\u30f3\u30ab\u30f3\u7de815\u3011',
          description: '',
          seasonNumber: 62,
          episodeNumber: null,
        ),
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title: '\u3010\u756a\u5916\u7de8#135\u3011Test',
          description: '',
          seasonNumber: null,
          episodeNumber: 135,
        ),
      ];

      final exitCode = await command.runWithItems(
        feedUrl: 'https://anchor.fm/s/8c2088c/podcast/rss',
        items: items,
        json: false,
      );

      expect(exitCode, 0);
      final text = output.toString();
      expect(text, contains('PASS'));
      expect(text, contains('\u30ea\u30f3\u30ab\u30f3\u7de8'));
      expect(text, contains('\u756a\u5916\u7de8'));
      expect(text, contains('Summary'));
    });

    test('returns exit code 1 when extractions fail', () async {
      final output = StringBuffer();
      final command = SmartPlaylistDebugCommand(
        sink: output,
        registry: registry,
      );

      final items = [
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title: '\u3010\u7279\u5225\u7de8\u3011Unknown format',
          description: '',
          seasonNumber: 99,
          episodeNumber: null,
        ),
      ];

      final exitCode = await command.runWithItems(
        feedUrl: 'https://anchor.fm/s/8c2088c/podcast/rss',
        items: items,
        json: false,
      );

      expect(exitCode, 1);
      expect(output.toString(), contains('FAIL'));
    });

    test('outputs JSON when requested', () async {
      final output = StringBuffer();
      final command = SmartPlaylistDebugCommand(
        sink: output,
        registry: registry,
      );

      final items = [
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title:
              '\u301762-15\u3018Test\u3010COTEN RADIO \u30ea\u30f3\u30ab\u30f3\u7de815\u3011',
          description: '',
          seasonNumber: 62,
          episodeNumber: null,
        ),
      ];

      await command.runWithItems(
        feedUrl: 'https://anchor.fm/s/8c2088c/podcast/rss',
        items: items,
        json: true,
      );

      final text = output.toString();
      expect(text, contains('"feed_url"'));
      expect(text, contains('"results"'));
      expect(text, contains('"status": "pass"'));
    });
  });
}
