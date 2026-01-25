import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(int id, {int? seasonNumber, DateTime? publishedAt}) {
  return Episode(
    id: id,
    podcastId: 1,
    guid: 'guid-$id',
    title: 'Episode $id',
    audioUrl: 'https://example.com/$id.mp3',
    seasonNumber: seasonNumber,
    publishedAt: publishedAt ?? DateTime(2024, 1, id),
  );
}

void main() {
  group('SeasonResolverService', () {
    late SeasonResolverService service;

    setUp(() {
      service = SeasonResolverService(
        resolvers: [RssMetadataResolver(), YearResolver()],
        patterns: [],
      );
    });

    test('returns null when no resolver succeeds', () {
      final episodes = [_makeEpisode(1), _makeEpisode(2)];
      // Override publishedAt to null
      final noDateEpisodes = episodes
          .map(
            (e) => Episode(
              id: e.id,
              podcastId: e.podcastId,
              guid: e.guid,
              title: e.title,
              audioUrl: e.audioUrl,
            ),
          )
          .toList();

      final result = service.resolveSeasons(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: noDateEpisodes,
      );

      expect(result, isNull);
    });

    test('uses first successful resolver (RssMetadataResolver)', () {
      final episodes = [
        _makeEpisode(1, seasonNumber: 1, publishedAt: DateTime(2024, 1, 1)),
        _makeEpisode(2, seasonNumber: 1, publishedAt: DateTime(2024, 2, 1)),
      ];

      final result = service.resolveSeasons(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      expect(result!.resolverType, 'rss');
    });

    test('falls back to next resolver when first fails', () {
      final episodes = [
        _makeEpisode(1, publishedAt: DateTime(2023, 6, 1)),
        _makeEpisode(2, publishedAt: DateTime(2024, 3, 1)),
      ];

      final result = service.resolveSeasons(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      expect(result!.resolverType, 'year');
    });

    test('uses custom pattern when podcast matches', () {
      final serviceWithPattern = SeasonResolverService(
        resolvers: [RssMetadataResolver(), TitleAppearanceOrderResolver()],
        patterns: [
          SeasonPattern(
            id: 'test_pattern',
            feedUrlPatterns: [r'https://example\.com/feed\.rss'],
            resolverType: 'title_appearance',
            config: {'pattern': r'Ep(\d+)'},
          ),
        ],
      );

      final episodes = [
        Episode(
          id: 1,
          podcastId: 1,
          guid: 'g1',
          title: 'Ep1 First',
          audioUrl: 'https://x.com/1.mp3',
          publishedAt: DateTime(2024, 1, 1),
        ),
        Episode(
          id: 2,
          podcastId: 1,
          guid: 'g2',
          title: 'Ep2 Second',
          audioUrl: 'https://x.com/2.mp3',
          publishedAt: DateTime(2024, 1, 2),
        ),
      ];

      final result = serviceWithPattern.resolveSeasons(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed.rss',
        episodes: episodes,
      );

      expect(result, isNotNull);
      expect(result!.resolverType, 'title_appearance');
    });
  });
}
