@Tags(['integration'])
library;

import 'package:audiflow_cli/src/commands/smart_playlist_debug_command.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistDebugCommand integration', () {
    test('processes COTEN RADIO feed', () async {
      final output = StringBuffer();
      final command = SmartPlaylistDebugCommand(output);

      await command.run(
        feedUrl: 'https://anchor.fm/s/8c2088c/podcast/rss',
        json: false,
      );

      final text = output.toString();

      // Should have processed episodes
      expect(text, contains('Episodes:'));
      expect(text, contains('Summary'));

      // Should have mostly passing results
      expect(text, contains('PASS'));

      // Print output for manual verification
      // ignore: avoid_print
      print(text);
    }, timeout: Timeout(Duration(minutes: 2)));
  });
}
