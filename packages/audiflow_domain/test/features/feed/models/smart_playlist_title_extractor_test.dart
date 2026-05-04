import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistTitleExtractor (JSON)', () {
    test('parses pattern + template', () {
      final extractor = SmartPlaylistTitleExtractor.fromJson({
        'source': 'title',
        'pattern': r'\[(.+?)\s+(\d+)\]',
        'template': r'${1} ${2}',
      });

      expect(extractor.source, 'title');
      expect(extractor.pattern, r'\[(.+?)\s+(\d+)\]');
      expect(extractor.template, r'${1} ${2}');
    });

    test('parses fallback chain', () {
      final extractor = SmartPlaylistTitleExtractor.fromJson({
        'source': 'title',
        'pattern': r'\[(.+?)\]',
        'template': r'${1}',
        'fallback': {'source': 'seasonNumber', 'template': r'Season ${0}'},
      });

      expect(extractor.fallback, isNotNull);
      expect(extractor.fallback!.source, 'seasonNumber');
      expect(extractor.fallback!.template, r'Season ${0}');
    });

    test('toJson round-trip preserves pattern/template/fallback', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'\[(.+?)\]',
        template: r'${1}',
        fallback: SmartPlaylistTitleExtractor(
          source: 'seasonNumber',
          template: r'Season ${0}',
        ),
      );

      final json = extractor.toJson();

      expect(json['source'], 'title');
      expect(json['pattern'], r'\[(.+?)\]');
      expect(json['template'], r'${1}');
      expect(json['fallback'], isA<Map<String, dynamic>>());
    });

    test('parses fallbackValue', () {
      final extractor = SmartPlaylistTitleExtractor.fromJson({
        'source': 'seasonNumber',
        'template': r'Season ${0}',
        'fallbackValue': 'Extras',
      });

      expect(extractor.fallbackValue, 'Extras');
    });

    test('toJson includes fallbackValue when set', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'episodeNumber',
        template: r'Episode ${0}',
        fallbackValue: 'Bonus',
      );

      expect(extractor.toJson()['fallbackValue'], 'Bonus');
    });
  });

  group('SmartPlaylistTitleExtractor.extract', () {
    EpisodeData makeEpisode({
      String title = 'Test Episode',
      int? seasonNumber,
      int? episodeNumber,
      String? description,
    }) {
      return SimpleEpisodeData(
        title: title,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        description: description,
      );
    }

    test(r'renders ${0} as full match', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'\[.+?\s+\d+\]',
        template: r'[${0}]',
      );

      final result = extractor.extract(
        makeEpisode(title: '[Rome 1] First Steps'),
      );

      expect(result, '[[Rome 1]]');
    });

    test('combines multiple capture groups via template', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'\[(.+?)\s+(\d+)\]',
        template: r'${1} - ${2}',
      );

      final result = extractor.extract(
        makeEpisode(title: '[Rome 1] First Steps'),
      );

      expect(result, 'Rome - 1');
    });

    test('out-of-range capture renders empty', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'^(\w+) (\w+)$',
        template: r'${1}/${5}/${2}',
      );

      final result = extractor.extract(makeEpisode(title: 'foo bar'));

      expect(result, 'foo//bar');
    });

    test('omitted template returns full match (group 0)', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'\d+',
      );

      final result = extractor.extract(makeEpisode(title: 'Episode 99'));

      expect(result, '99');
    });

    test(r'no pattern + template substitutes ${0} with source value', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'seasonNumber',
        template: r'Season ${0}',
      );

      final result = extractor.extract(makeEpisode(seasonNumber: 3));

      expect(result, 'Season 3');
    });

    test('no pattern + no template returns source value', () {
      final extractor = SmartPlaylistTitleExtractor(source: 'title');

      final result = extractor.extract(makeEpisode(title: 'Just the title'));

      expect(result, 'Just the title');
    });

    test(r'literal $ outside ${...} preserved', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'^(\w+)$',
        template: r'${1} - $5 cost',
      );

      final result = extractor.extract(makeEpisode(title: 'Promo'));

      expect(result, r'Promo - $5 cost');
    });

    test(r'malformed ${...} emitted literally', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'^(\w+)$',
        template: r'${1} ${abc} ${',
      );

      final result = extractor.extract(makeEpisode(title: 'ok'));

      expect(result, r'ok ${abc} ${');
    });

    test('uses fallback extractor when pattern does not match', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'\[(.+?)\]',
        template: r'${1}',
        fallback: SmartPlaylistTitleExtractor(
          source: 'seasonNumber',
          template: r'Season ${0}',
        ),
      );

      final result = extractor.extract(
        makeEpisode(title: 'No brackets here', seasonNumber: 2),
      );

      expect(result, 'Season 2');
    });

    test('returns null when no match and no fallback', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'\[(.+?)\]',
        template: r'${1}',
      );

      final result = extractor.extract(makeEpisode(title: 'No brackets here'));

      expect(result, isNull);
    });

    test('extracts from description', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'description',
        pattern: r'Part of the (.+?) arc',
        template: r'${1}',
      );

      final result = extractor.extract(
        makeEpisode(description: 'Part of the Mystery arc - episode 5'),
      );

      expect(result, 'Mystery');
    });

    test('returns null when source field is null and no fallback', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'description',
        template: r'${0}',
      );

      final result = extractor.extract(makeEpisode(description: null));

      expect(result, isNull);
    });

    test('fallbackValue triggers for missing seasonNumber when source is '
        'seasonNumber', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'seasonNumber',
        template: r'Season ${0}',
        fallbackValue: 'Extras',
      );

      expect(extractor.extract(makeEpisode()), 'Extras');
      expect(extractor.extract(makeEpisode(seasonNumber: 1)), 'Season 1');
    });

    test('fallbackValue triggers for missing episodeNumber when source is '
        'episodeNumber', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'episodeNumber',
        template: r'Episode ${0}',
        fallbackValue: 'Bonus',
      );

      expect(extractor.extract(makeEpisode()), 'Bonus');
      expect(extractor.extract(makeEpisode(episodeNumber: 7)), 'Episode 7');
    });

    test('fallbackValue does NOT short-circuit non-numeric sources', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'^(.+)$',
        template: r'${1}',
        fallbackValue: 'Should never appear',
      );

      final episode = makeEpisode(title: 'Real title');
      // Episode lacks season number; with new semantics title still wins.
      expect(extractor.extract(episode), 'Real title');
    });

    test('fallback chain uses new template semantics per link', () {
      final extractor = SmartPlaylistTitleExtractor(
        source: 'title',
        pattern: r'^primary-(\w+)-(\w+)$',
        template: r'P:${1}+${2}',
        fallback: SmartPlaylistTitleExtractor(
          source: 'title',
          pattern: r'^backup-(\w+)$',
          template: r'F:${1}',
        ),
      );

      expect(extractor.extract(makeEpisode(title: 'primary-aa-bb')), 'P:aa+bb');
      expect(extractor.extract(makeEpisode(title: 'backup-cc')), 'F:cc');
    });
  });
}
