import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EpisodeNumberExtractor', () {
    EpisodeData makeEpisode({
      String title = 'Test',
      int? episodeNumber,
      int? seasonNumber,
    }) {
      return SimpleEpisodeData(
        title: title,
        episodeNumber: episodeNumber,
        seasonNumber: seasonNumber,
      );
    }

    test('creates from JSON config', () {
      final json = {
        'pattern': r'(\d+)】',
        'captureGroup': 1,
        'fallbackToRss': true,
      };

      final extractor = EpisodeNumberExtractor.fromJson(json);

      expect(extractor.pattern, r'(\d+)】');
      expect(extractor.captureGroup, 1);
      expect(extractor.fallbackToRss, isTrue);
    });

    test(
      'extracts number from title using regex for positive seasonNumber',
      () {
        final extractor = EpisodeNumberExtractor(
          pattern: r'(\d+)】',
          captureGroup: 1,
          fallbackToRss: true,
        );

        final episode = makeEpisode(
          title: '【62-15】リンカン【COTEN RADIO リンカン編15】',
          seasonNumber: 62,
          episodeNumber: 100,
        );

        final result = extractor.extract(episode);
        expect(result, 15);
      },
    );

    test('uses RSS episodeNumber for null/zero seasonNumber', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final episode = makeEpisode(
        title: '【番外編＃135】仏教のこと',
        seasonNumber: null,
        episodeNumber: 135,
      );

      final result = extractor.extract(episode);
      expect(result, 135);
    });

    test('uses RSS episodeNumber for seasonNumber zero', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final episode = makeEpisode(
        title: '【番外編＃135】仏教のこと',
        seasonNumber: 0,
        episodeNumber: 135,
      );

      final result = extractor.extract(episode);
      expect(result, 135);
    });

    test('falls back to RSS when pattern does not match', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final episode = makeEpisode(
        title: 'No pattern here',
        seasonNumber: 5,
        episodeNumber: 42,
      );

      final result = extractor.extract(episode);
      expect(result, 42);
    });

    test('returns null when no match and fallback disabled', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: false,
      );

      final episode = makeEpisode(
        title: 'No pattern here',
        seasonNumber: 5,
        episodeNumber: null,
      );

      final result = extractor.extract(episode);
      expect(result, isNull);
    });

    test('converts to JSON', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final json = extractor.toJson();

      expect(json['pattern'], r'(\d+)】');
      expect(json['captureGroup'], 1);
      expect(json['fallbackToRss'], true);
    });
  });
}
