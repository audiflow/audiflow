import 'package:audiflow_cli/src/diagnostics/title_extractor_diagnostics.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode({
  required String title,
  int? seasonNumber,
  int? episodeNumber,
}) {
  return Episode(
    id: 0,
    podcastId: 0,
    guid: 'guid',
    title: title,
    audioUrl: 'https://example.com/audio.mp3',
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
  );
}

void main() {
  group('TitleExtractorDiagnostics', () {
    test('returns fallbackValue result when seasonNumber is null', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'【COTEN RADIO (.+?)\d+】',
        group: 1,
        fallbackValue: '番外編',
      );

      final diagnostics = TitleExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(title: '【番外編#135】Test', seasonNumber: null),
      );

      expect(result.extractedValue, '番外編');
      expect(result.fallbackValue, '番外編');
      expect(result.fallbackConditionMet, isTrue);
      expect(result.error, isNull);
    });

    test('returns pattern match result for positive seasonNumber', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'【COTEN RADIO (ショート)?\s*(.+?)\s*\d+】',
        group: 2,
        fallbackValue: '番外編',
      );

      final diagnostics = TitleExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '【62-15】何が変わった?【COTEN RADIO リンカン編15】',
          seasonNumber: 62,
        ),
      );

      expect(result.extractedValue, 'リンカン編');
      expect(result.patternUsed, r'【COTEN RADIO (ショート)?\s*(.+?)\s*\d+】');
      expect(result.matchResult, 'リンカン編');
      expect(result.error, isNull);
    });

    test('returns error when pattern does not match', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'【COTEN RADIO (.+?)\d+】',
        group: 1,
      );

      final diagnostics = TitleExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(title: '【特別編】ゲスト回', seasonNumber: 99),
      );

      expect(result.extractedValue, isNull);
      expect(result.error, isNotNull);
      expect(result.error, contains('pattern did not match'));
    });
  });
}
