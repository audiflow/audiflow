import 'package:audiflow_cli/src/diagnostics/episode_extractor_diagnostics.dart';
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
  group('EpisodeExtractorDiagnostics', () {
    test('returns RSS episodeNumber for null seasonNumber', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final diagnostics = EpisodeExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '【番外編#135】Test',
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
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final diagnostics = EpisodeExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '【62-15】何が変わった?【COTEN RADIO リンカン編15】',
          seasonNumber: 62,
          episodeNumber: 999,
        ),
      );

      expect(result.extractedValue, 15);
      expect(result.patternUsed, r'(\d+)】');
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
        _makeEpisode(title: '【特別編】Test', seasonNumber: 99, episodeNumber: 42),
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
        _makeEpisode(title: '【特別編】Test', seasonNumber: 99, episodeNumber: null),
      );

      expect(result.extractedValue, isNull);
      expect(result.error, isNotNull);
    });
  });
}
