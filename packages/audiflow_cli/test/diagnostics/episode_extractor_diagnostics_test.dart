import 'package:audiflow_cli/src/diagnostics/episode_extractor_diagnostics.dart';
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
  group('EpisodeExtractorDiagnostics', () {
    test('returns RSS episodeNumber for null seasonNumber', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)\]',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final diagnostics = EpisodeExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '[Extra#135] Test',
          seasonNumber: null,
          episodeNumber: 135,
        ),
      );

      expect(result.extractedValue, 135);
      expect(result.usedRssFallback, isTrue);
      expect(result.error, isNull);
    });

    test('extracts from title pattern for positive seasonNumber', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)\]',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final diagnostics = EpisodeExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '[62-15] What changed? [COTEN RADIO Lincoln15]',
          seasonNumber: 62,
          episodeNumber: 999,
        ),
      );

      expect(result.extractedValue, 15);
      expect(result.patternUsed, r'(\d+)\]');
      expect(result.matchResult, '15');
      expect(result.usedRssFallback, isFalse);
    });

    test('falls back to RSS when pattern fails', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'EP(\d+)',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final diagnostics = EpisodeExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '[Special] Test',
          seasonNumber: 99,
          episodeNumber: 42,
        ),
      );

      expect(result.extractedValue, 42);
      expect(result.usedRssFallback, isTrue);
    });

    test('returns error when pattern fails and no RSS fallback', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'EP(\d+)',
        captureGroup: 1,
        fallbackToRss: false,
      );

      final diagnostics = EpisodeExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '[Special] Test',
          seasonNumber: 99,
          episodeNumber: null,
        ),
      );

      expect(result.extractedValue, isNull);
      expect(result.error, isNotNull);
    });
  });
}
