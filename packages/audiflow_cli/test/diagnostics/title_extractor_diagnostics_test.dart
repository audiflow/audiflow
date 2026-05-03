import 'package:audiflow_cli/src/diagnostics/title_extractor_diagnostics.dart';
import 'package:audiflow_domain/patterns.dart';
import 'package:flutter_test/flutter_test.dart';

SimpleEpisodeData _makeEpisode({
  required String title,
  int? seasonNumber,
  int? episodeNumber,
}) {
  return SimpleEpisodeData(
    title: title,
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
  );
}

void main() {
  group('TitleExtractorDiagnostics', () {
    test('returns fallbackValue result when seasonNumber source is null', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'seasonNumber',
        template: r'Season ${0}',
        fallbackValue: 'Extra',
      );

      final diagnostics = TitleExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(title: 'Anything', seasonNumber: null),
      );

      expect(result.extractedValue, 'Extra');
      expect(result.fallbackValue, 'Extra');
      expect(result.fallbackConditionMet, isTrue);
      expect(result.error, isNull);
    });

    test('renders template with multi-capture pattern match', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'COTEN RADIO (Short)?\s*(.+?)\s*\d+',
        template: r'${2}',
        fallbackValue: 'Extra',
      );

      final diagnostics = TitleExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '62-15 What changed? COTEN RADIO Lincoln15',
          seasonNumber: 62,
        ),
      );

      expect(result.extractedValue, 'Lincoln');
      expect(result.patternUsed, r'COTEN RADIO (Short)?\s*(.+?)\s*\d+');
      expect(result.matchResult, contains('COTEN RADIO'));
      expect(result.templateUsed, r'${2}');
      expect(result.error, isNull);
    });

    test('returns error when pattern does not match', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'COTEN RADIO (.+?)\d+',
        template: r'${1}',
      );

      final diagnostics = TitleExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(title: 'Special Edition Guest Episode', seasonNumber: 99),
      );

      expect(result.extractedValue, isNull);
      expect(result.error, isNotNull);
      expect(result.error, contains('pattern did not match'));
    });
  });
}
