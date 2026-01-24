import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeasonPattern', () {
    test('SeasonPattern holds pattern configuration', () {
      final pattern = SeasonPattern(
        id: 'italy_podcast',
        podcastGuid: 'guid-123',
        feedUrlPattern: r'.*italy-travel\.com/feed.*',
        resolverType: 'title_appearance',
        config: {'pattern': r'\[(\w+)\s+\d+\]'},
        priority: 10,
      );

      expect(pattern.id, 'italy_podcast');
      expect(pattern.podcastGuid, 'guid-123');
      expect(pattern.feedUrlPattern, r'.*italy-travel\.com/feed.*');
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
      final pattern = SeasonPattern(
        id: 'test',
        podcastGuid: 'guid-abc',
        feedUrlPattern: r'.*example\.com.*',
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
  });
}
