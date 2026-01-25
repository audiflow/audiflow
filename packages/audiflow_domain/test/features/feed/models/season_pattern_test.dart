import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeasonPattern', () {
    test('SeasonPattern holds pattern configuration', () {
      // ignore: deprecated_member_use_from_same_package
      final pattern = SeasonPattern(
        id: 'italy_podcast',
        podcastGuid: 'guid-123',
        // ignore: deprecated_member_use_from_same_package
        feedUrlPatterns: [r'.*italy-travel\.com/feed.*'],
        resolverType: 'title_appearance',
        config: {'pattern': r'\[(\w+)\s+\d+\]'},
        priority: 10,
      );

      expect(pattern.id, 'italy_podcast');
      expect(pattern.podcastGuid, 'guid-123');
      // ignore: deprecated_member_use_from_same_package
      expect(pattern.feedUrlPatterns, [r'.*italy-travel\.com/feed.*']);
      expect(pattern.resolverType, 'title_appearance');
      expect(pattern.config['pattern'], r'\[(\w+)\s+\d+\]');
      expect(pattern.priority, 10);
    });

    test('SeasonPattern can have custom sort spec', () {
      final pattern = SeasonPattern(
        id: 'test',
        resolverType: 'rss',
        config: {},
        customSort: const SimpleSeasonSort(
          SeasonSortField.seasonNumber,
          SortOrder.ascending,
        ),
      );

      expect(pattern.customSort, isA<SimpleSeasonSort>());
    });

    test('SeasonPattern.matchesPodcast matches by GUID first', () {
      // ignore: deprecated_member_use_from_same_package
      final pattern = SeasonPattern(
        id: 'test',
        podcastGuid: 'guid-abc',
        // ignore: deprecated_member_use_from_same_package
        feedUrlPatterns: [r'.*example\.com.*'],
        resolverType: 'rss',
        config: {},
      );

      expect(
        pattern.matchesPodcast('guid-abc', 'https://other.com/feed'),
        isTrue,
      );
      expect(
        pattern.matchesPodcast('guid-xyz', 'https://example.com/feed'),
        isTrue,
      );
      expect(
        pattern.matchesPodcast('guid-xyz', 'https://other.com/feed'),
        isFalse,
      );
    });

    test('SeasonPattern supports feedUrlPatterns list', () {
      final pattern = SeasonPattern(
        id: 'coten_radio',
        feedUrlPatterns: [
          r'https://anchor\.fm/s/8c2088c/podcast/rss',
          r'https://anchor\.fm/s/another/podcast/rss',
        ],
        resolverType: 'rss',
        config: {},
      );

      expect(pattern.feedUrlPatterns, hasLength(2));
    });

    test(
      'matchesPodcast matches any pattern in feedUrlPatterns with anchoring',
      () {
        final pattern = SeasonPattern(
          id: 'coten_radio',
          feedUrlPatterns: [r'https://anchor\.fm/s/8c2088c/podcast/rss'],
          resolverType: 'rss',
          config: {},
        );

        expect(
          pattern.matchesPodcast(
            null,
            'https://anchor.fm/s/8c2088c/podcast/rss',
          ),
          isTrue,
        );
        expect(
          pattern.matchesPodcast(
            null,
            'https://other.com/https://anchor.fm/s/8c2088c/podcast/rss',
          ),
          isFalse,
        );
      },
    );

    test('SeasonPattern can have episodeNumberExtractor', () {
      final pattern = SeasonPattern(
        id: 'test',
        resolverType: 'rss',
        config: {},
        episodeNumberExtractor: EpisodeNumberExtractor(
          pattern: r'(\d+)】',
          captureGroup: 1,
        ),
      );

      expect(pattern.episodeNumberExtractor, isNotNull);
    });
  });
}
