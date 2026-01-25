import 'dart:convert';

import 'package:audiflow_cli/src/models/extraction_result.dart';
import 'package:audiflow_cli/src/reporters/json_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JsonReporter', () {
    late JsonReporter reporter;
    late StringBuffer output;

    setUp(() {
      output = StringBuffer();
      reporter = JsonReporter(output);
    });

    test('outputs valid JSON with all fields', () {
      reporter.start(feedUrl: 'https://example.com/feed', patternId: 'test');

      reporter.addResult(
        ExtractionResult(
          title: 'Test Episode',
          rssSeasonNumber: 1,
          rssEpisodeNumber: 5,
          extractedTitle: 'Season 1',
          extractedEpisodeNumber: 5,
        ),
      );

      reporter.finish(total: 1, passed: 1, failed: 0);

      final json = jsonDecode(output.toString()) as Map<String, dynamic>;

      expect(json['feed_url'], 'https://example.com/feed');
      expect(json['pattern_id'], 'test');
      expect(json['results'], hasLength(1));
      expect(json['results'][0]['status'], 'pass');
      expect(json['summary']['total'], 1);
      expect(json['summary']['pass'], 1);
    });

    test('includes diagnostics for failed results', () {
      reporter.start(feedUrl: 'https://example.com/feed', patternId: null);

      reporter.addResult(
        ExtractionResult(
          title: 'Failed Episode',
          rssSeasonNumber: null,
          rssEpisodeNumber: null,
          extractedTitle: null,
          extractedEpisodeNumber: null,
          diagnostics: ExtractionDiagnostics(
            titlePattern: r'\[(.+?)\]',
            error: 'no match',
          ),
        ),
      );

      reporter.finish(total: 1, passed: 0, failed: 1);

      final json = jsonDecode(output.toString()) as Map<String, dynamic>;
      final result = json['results'][0] as Map<String, dynamic>;

      expect(result['status'], 'fail');
      expect(result['diagnostics']['error'], 'no match');
    });
  });
}
