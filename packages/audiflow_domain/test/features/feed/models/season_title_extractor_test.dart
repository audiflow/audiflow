import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeasonTitleExtractor', () {
    test('creates from JSON config with regex pattern', () {
      final json = {
        'source': 'title',
        'pattern': r'\[(.+?)\s+\d+\]',
        'group': 1,
      };

      final extractor = SeasonTitleExtractor.fromJson(json);

      expect(extractor.source, 'title');
      expect(extractor.pattern, r'\[(.+?)\s+\d+\]');
      expect(extractor.group, 1);
    });

    test('creates from JSON config with template', () {
      final json = {'source': 'seasonNumber', 'template': 'Season {value}'};

      final extractor = SeasonTitleExtractor.fromJson(json);

      expect(extractor.source, 'seasonNumber');
      expect(extractor.template, 'Season {value}');
    });

    test('creates from JSON config with fallback', () {
      final json = {
        'source': 'title',
        'pattern': r'\[(.+?)\]',
        'group': 1,
        'fallback': {'source': 'seasonNumber', 'template': 'Season {value}'},
      };

      final extractor = SeasonTitleExtractor.fromJson(json);

      expect(extractor.fallback, isNotNull);
      expect(extractor.fallback!.source, 'seasonNumber');
      expect(extractor.fallback!.template, 'Season {value}');
    });

    test('converts to JSON', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'\[(.+?)\]',
        group: 1,
        fallback: SeasonTitleExtractor(
          source: 'seasonNumber',
          template: 'Season {value}',
        ),
      );

      final json = extractor.toJson();

      expect(json['source'], 'title');
      expect(json['pattern'], r'\[(.+?)\]');
      expect(json['group'], 1);
      expect(json['fallback'], isA<Map<String, dynamic>>());
    });

    test('group defaults to 0 when not specified', () {
      final json = {'source': 'title', 'pattern': r'Season (\d+)'};

      final extractor = SeasonTitleExtractor.fromJson(json);

      expect(extractor.group, 0);
    });
  });

  group('SeasonTitleExtractor.extract', () {
    Episode makeEpisode({
      String title = 'Test Episode',
      int? seasonNumber,
      String? description,
    }) {
      return Episode(
        id: 1,
        podcastId: 1,
        guid: 'guid-1',
        title: title,
        audioUrl: 'https://example.com/1.mp3',
        seasonNumber: seasonNumber,
        description: description,
        publishedAt: DateTime(2024, 1, 1),
      );
    }

    test('extracts from title using regex', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'\[(.+?)\s+\d+\]',
        group: 1,
      );

      final episode = makeEpisode(title: '[Rome 1] First Steps');
      final result = extractor.extract(episode);

      expect(result, 'Rome');
    });

    test('extracts full match when group is 0', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'\[.+?\s+\d+\]',
        group: 0,
      );

      final episode = makeEpisode(title: '[Rome 1] First Steps');
      final result = extractor.extract(episode);

      expect(result, '[Rome 1]');
    });

    test('uses template with seasonNumber', () {
      final extractor = SeasonTitleExtractor(
        source: 'seasonNumber',
        template: 'Season {value}',
      );

      final episode = makeEpisode(seasonNumber: 3);
      final result = extractor.extract(episode);

      expect(result, 'Season 3');
    });

    test('uses fallback when pattern does not match', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'\[(.+?)\]',
        group: 1,
        fallback: SeasonTitleExtractor(
          source: 'seasonNumber',
          template: 'Season {value}',
        ),
      );

      final episode = makeEpisode(title: 'No brackets here', seasonNumber: 2);
      final result = extractor.extract(episode);

      expect(result, 'Season 2');
    });

    test('returns null when no match and no fallback', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'\[(.+?)\]',
        group: 1,
      );

      final episode = makeEpisode(title: 'No brackets here');
      final result = extractor.extract(episode);

      expect(result, isNull);
    });

    test('extracts from description', () {
      final extractor = SeasonTitleExtractor(
        source: 'description',
        pattern: r'Part of the (.+?) arc',
        group: 1,
      );

      final episode = makeEpisode(
        description: 'Part of the Mystery arc - episode 5',
      );
      final result = extractor.extract(episode);

      expect(result, 'Mystery');
    });

    test('returns null when source field is null', () {
      final extractor = SeasonTitleExtractor(
        source: 'seasonNumber',
        template: 'Season {value}',
      );

      final episode = makeEpisode(seasonNumber: null);
      final result = extractor.extract(episode);

      expect(result, isNull);
    });
  });
}
