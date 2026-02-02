import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_pattern_config.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(
  int id, {
  String? title,
  int? seasonNumber,
  DateTime? publishedAt,
}) {
  return Episode(
    id: id,
    podcastId: 1,
    guid: 'guid-$id',
    title: title ?? 'Episode $id',
    audioUrl: 'https://example.com/$id.mp3',
    seasonNumber: seasonNumber,
    publishedAt: publishedAt ?? DateTime(2024, 1, id),
  );
}

void main() {
  group('SmartPlaylistResolverService', () {
    late SmartPlaylistResolverService service;

    setUp(() {
      service = SmartPlaylistResolverService(
        resolvers: [RssMetadataResolver(), YearResolver()],
        patterns: [],
      );
    });

    test('returns null when no resolver succeeds', () {
      final episodes = [_makeEpisode(1), _makeEpisode(2)];
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

      final result = service.resolveSmartPlaylists(
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

      final result = service.resolveSmartPlaylists(
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

      final result = service.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      expect(result!.resolverType, 'year');
    });

    test('uses custom pattern config when podcast matches', () {
      final serviceWithPattern = SmartPlaylistResolverService(
        resolvers: [RssMetadataResolver(), YearResolver()],
        patterns: [
          SmartPlaylistPatternConfig(
            id: 'test_pattern',
            feedUrlPatterns: [r'https://example\.com/feed\.rss'],
            playlists: [
              SmartPlaylistDefinition(
                id: 'main',
                displayName: 'Main',
                resolverType: 'rss',
              ),
            ],
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
          seasonNumber: 1,
          publishedAt: DateTime(2024, 1, 1),
        ),
        Episode(
          id: 2,
          podcastId: 1,
          guid: 'g2',
          title: 'Ep2 Second',
          audioUrl: 'https://x.com/2.mp3',
          seasonNumber: 1,
          publishedAt: DateTime(2024, 1, 2),
        ),
      ];

      final result = serviceWithPattern.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed.rss',
        episodes: episodes,
      );

      expect(result, isNotNull);
      expect(result!.resolverType, 'rss');
    });

    test('routes episodes by titleFilter and excludeFilter', () {
      final serviceWithFilters = SmartPlaylistResolverService(
        resolvers: [RssMetadataResolver(), YearResolver()],
        patterns: [
          SmartPlaylistPatternConfig(
            id: 'filter_test',
            feedUrlPatterns: [r'https://example\.com/feed'],
            playlists: [
              SmartPlaylistDefinition(
                id: 'bonus',
                displayName: 'Bonus',
                resolverType: 'year',
                priority: 10,
                requireFilter: r'Bonus',
              ),
              SmartPlaylistDefinition(
                id: 'main',
                displayName: 'Main',
                resolverType: 'year',
                excludeFilter: r'Bonus',
              ),
            ],
          ),
        ],
      );

      final episodes = [
        _makeEpisode(
          1,
          title: 'Ep1 Main Story',
          publishedAt: DateTime(2024, 1, 1),
        ),
        _makeEpisode(
          2,
          title: 'Bonus: Behind the Scenes',
          publishedAt: DateTime(2024, 2, 1),
        ),
        _makeEpisode(
          3,
          title: 'Ep2 Main Story',
          publishedAt: DateTime(2024, 3, 1),
        ),
        _makeEpisode(
          4,
          title: 'Bonus: Outtakes',
          publishedAt: DateTime(2024, 4, 1),
        ),
      ];

      final result = serviceWithFilters.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);

      // All episodes in 2024, so each definition produces one
      // year-based playlist. Bonus (higher priority) is resolved
      // first, then main gets remaining episodes.
      expect(result!.playlists.length, 2);

      // Collect all episode IDs per playlist
      final firstIds = result.playlists[0].episodeIds;
      final secondIds = result.playlists[1].episodeIds;

      // Bonus playlist gets episodes matching requireFilter
      expect(firstIds, unorderedEquals([2, 4]));
      // Main playlist gets episodes not matching excludeFilter
      expect(secondIds, unorderedEquals([1, 3]));
    });
  });
}
