import 'package:audiflow_cli/src/models/extraction_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExtractionResult', () {
    test('creates successful result', () {
      final result = ExtractionResult(
        title: 'Test Episode',
        rssSeasonNumber: 1,
        rssEpisodeNumber: 5,
        extractedTitle: 'Season 1',
        extractedEpisodeNumber: 5,
      );

      expect(result.success, isTrue);
      expect(result.diagnostics, isNull);
    });

    test('creates failed result with diagnostics', () {
      final result = ExtractionResult(
        title: 'Test Episode',
        rssSeasonNumber: null,
        rssEpisodeNumber: null,
        extractedTitle: null,
        extractedEpisodeNumber: null,
        diagnostics: ExtractionDiagnostics(
          titlePattern: r'\[(.+?)\]',
          titleMatch: null,
          error: 'pattern did not match',
        ),
      );

      expect(result.success, isFalse);
      expect(result.diagnostics, isNotNull);
      expect(result.diagnostics!.error, 'pattern did not match');
    });
  });

  group('ExtractionResult.toJson', () {
    test('serializes successful result', () {
      final result = ExtractionResult(
        title: 'Test',
        rssSeasonNumber: 1,
        rssEpisodeNumber: 2,
        extractedTitle: 'S1',
        extractedEpisodeNumber: 2,
      );

      final json = result.toJson();

      expect(json['status'], 'pass');
      expect(json['title'], 'Test');
      expect(json['rss_season'], 1);
      expect(json['extracted_title'], 'S1');
      expect(json.containsKey('diagnostics'), isFalse);
    });

    test('serializes failed result with diagnostics', () {
      final result = ExtractionResult(
        title: 'Test',
        rssSeasonNumber: null,
        rssEpisodeNumber: null,
        extractedTitle: null,
        extractedEpisodeNumber: null,
        diagnostics: ExtractionDiagnostics(
          titlePattern: r'\[(.+?)\]',
          error: 'no match',
        ),
      );

      final json = result.toJson();

      expect(json['status'], 'fail');
      expect(json['diagnostics']['title_pattern'], r'\[(.+?)\]');
      expect(json['diagnostics']['error'], 'no match');
    });
  });
}
