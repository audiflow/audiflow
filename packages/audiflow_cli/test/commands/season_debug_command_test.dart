import 'package:audiflow_cli/src/commands/season_debug_command.dart';
import 'package:audiflow_podcast/parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeasonDebugCommand', () {
    test('processes items and reports results', () async {
      final output = StringBuffer();
      final command = SeasonDebugCommand(output);

      // Create mock items
      final items = [
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title: '【62-15】Test【COTEN RADIO リンカン編15】',
          description: '',
          seasonNumber: 62,
          episodeNumber: null,
        ),
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title: '【番外編#135】Test',
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
      expect(text, contains('リンカン編'));
      expect(text, contains('番外編'));
      expect(text, contains('Summary'));
    });

    test('returns exit code 1 when extractions fail', () async {
      final output = StringBuffer();
      final command = SeasonDebugCommand(output);

      final items = [
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title: '【特別編】Unknown format',
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
      final command = SeasonDebugCommand(output);

      final items = [
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title: '【62-15】Test【COTEN RADIO リンカン編15】',
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
