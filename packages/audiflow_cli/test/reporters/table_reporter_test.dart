import 'package:audiflow_cli/src/models/extraction_result.dart';
import 'package:audiflow_cli/src/reporters/table_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TableReporter', () {
    late TableReporter reporter;
    late StringBuffer output;

    setUp(() {
      output = StringBuffer();
      reporter = TableReporter(output);
    });

    test('formats passing result as single line', () {
      final result = ExtractionResult(
        title: '【62-15】Test【COTEN RADIO リンカン編15】',
        rssSeasonNumber: 62,
        rssEpisodeNumber: null,
        extractedTitle: 'リンカン編',
        extractedEpisodeNumber: 15,
      );

      reporter.writeResult(result);

      expect(output.toString(), contains('PASS'));
      expect(output.toString(), contains('S62'));
      expect(output.toString(), contains('title="リンカン編"'));
      expect(output.toString(), contains('ep=15'));
    });

    test('formats failing result with diagnostics', () {
      final result = ExtractionResult(
        title: '【特別編】ゲスト回',
        rssSeasonNumber: null,
        rssEpisodeNumber: null,
        extractedTitle: null,
        extractedEpisodeNumber: null,
        diagnostics: ExtractionDiagnostics(
          titlePattern: r'【COTEN RADIO (.+?)\d+】',
          error: 'pattern did not match',
        ),
      );

      reporter.writeResult(result);

      final text = output.toString();
      expect(text, contains('FAIL'));
      expect(text, contains('title_pattern:'));
      expect(text, contains('error:'));
    });

    test('writes summary with counts and percentages', () {
      reporter.writeSummary(total: 100, passed: 95, failed: 5);

      final text = output.toString();
      expect(text, contains('Total: 100'));
      expect(text, contains('Pass:'));
      expect(text, contains('95'));
      expect(text, contains('95.0%'));
      expect(text, contains('Fail:'));
      expect(text, contains('5'));
    });
  });
}
