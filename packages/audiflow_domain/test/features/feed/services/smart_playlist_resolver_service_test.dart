import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(
  int id, {
  String? title,
  int? seasonNumber,
  DateTime? publishedAt,
}) {
  return Episode()
    ..id = id
    ..podcastId = 1
    ..guid = 'guid-$id'
    ..title = title ?? 'Episode $id'
    ..audioUrl = 'https://example.com/$id.mp3'
    ..seasonNumber = seasonNumber
    ..publishedAt = publishedAt ?? DateTime(2024, 1, id);
}

void main() {
  group('SmartPlaylistResolverService', () {
    late SmartPlaylistResolverService service;

    setUp(() {
      service = SmartPlaylistResolverService(
        resolvers: [SeasonNumberResolver(), YearResolver()],
        patterns: [],
      );
    });

    test('returns null when no resolver succeeds', () {
      final episodes = [_makeEpisode(1), _makeEpisode(2)];
      final noDateEpisodes = episodes
          .map(
            (e) => Episode()
              ..id = e.id
              ..podcastId = e.podcastId
              ..guid = e.guid
              ..title = e.title
              ..audioUrl = e.audioUrl,
          )
          .toList();

      final result = service.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: noDateEpisodes,
      );

      expect(result, isNull);
    });

    test('uses first successful resolver (SeasonNumberResolver)', () {
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
      expect(result!.resolverType, 'seasonNumber');
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
        resolvers: [SeasonNumberResolver(), YearResolver()],
        patterns: [
          SmartPlaylistPatternConfig(
            id: 'test_pattern',
            feedUrls: ['https://example.com/feed.rss'],
            playlists: [
              const SmartPlaylistDefinition(
                id: 'main',
                displayName: 'Main',
                grouping: GroupingConfig(by: 'seasonNumber'),
                priority: 0,
                selector: SelectorConfig(),
              ),
            ],
          ),
        ],
      );

      final episodes = [
        Episode()
          ..id = 1
          ..podcastId = 1
          ..guid = 'g1'
          ..title = 'Ep1 First'
          ..audioUrl = 'https://x.com/1.mp3'
          ..seasonNumber = 1
          ..publishedAt = DateTime(2024, 1, 1),
        Episode()
          ..id = 2
          ..podcastId = 1
          ..guid = 'g2'
          ..title = 'Ep2 Second'
          ..audioUrl = 'https://x.com/2.mp3'
          ..seasonNumber = 1
          ..publishedAt = DateTime(2024, 1, 2),
      ];

      final result = serviceWithPattern.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed.rss',
        episodes: episodes,
      );

      expect(result, isNotNull);
      expect(result!.resolverType, 'seasonNumber');
    });

    test('wraps resolver playlists as groups when not isSeparate', () {
      final serviceWithGroups = SmartPlaylistResolverService(
        resolvers: [SeasonNumberResolver()],
        patterns: [
          SmartPlaylistPatternConfig(
            id: 'test',
            feedUrls: ['https://example.com/feed'],
            playlists: [
              const SmartPlaylistDefinition(
                id: 'regular',
                displayName: 'Regular Series',
                grouping: GroupingConfig(by: 'seasonNumber'),
                priority: 0,
                groupListing: GroupListingConfig(
                  yearBinding: YearBinding.pinToYear,
                ),
              ),
            ],
          ),
        ],
      );

      final episodes = [
        _makeEpisode(1, seasonNumber: 1, title: 'S1E1'),
        _makeEpisode(2, seasonNumber: 1, title: 'S1E2'),
        _makeEpisode(3, seasonNumber: 2, title: 'S2E1'),
      ];

      final result = serviceWithGroups.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      // One parent playlist, not two separate season playlists
      expect(result!.playlists, hasLength(1));

      final playlist = result.playlists.first;
      expect(playlist.id, 'regular');
      expect(playlist.displayName, 'Regular Series');
      expect(playlist.isSeparate, isFalse);
      expect(playlist.yearBinding, YearBinding.pinToYear);
      expect(playlist.episodeIds, unorderedEquals([1, 2, 3]));

      // Seasons become groups inside the playlist
      expect(playlist.groups, isNotNull);
      expect(playlist.groups, hasLength(2));
      expect(
        playlist.groups!.map((g) => g.id),
        containsAll(['season_1', 'season_2']),
      );
    });

    test('groupItem.pinToYear sets yearOverride on group', () {
      final serviceWithPinToYear = SmartPlaylistResolverService(
        resolvers: [SeasonNumberResolver()],
        patterns: [
          SmartPlaylistPatternConfig(
            id: 'test',
            feedUrls: ['https://example.com/feed'],
            playlists: [
              SmartPlaylistDefinition(
                id: 'regular',
                displayName: 'Regular',
                grouping: GroupingConfig(
                  by: 'seasonNumber',
                  staticClassifiers: [
                    const SmartPlaylistGroupDef(
                      id: 'season_1',
                      displayName: 'Season 1',
                      groupItem: GroupItemConfig(pinToYear: true),
                    ),
                  ],
                ),
                priority: 0,
              ),
            ],
          ),
        ],
      );

      final episodes = [
        _makeEpisode(1, seasonNumber: 1, title: 'S1E1'),
        _makeEpisode(2, seasonNumber: 2, title: 'S2E1'),
      ];

      final result = serviceWithPinToYear.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      final playlist = result!.playlists.first;
      expect(playlist.groups, isNotNull);

      final season1 = playlist.groups!.firstWhere((g) => g.id == 'season_1');
      expect(
        season1.yearOverride,
        YearBinding.pinToYear,
        reason: 'groupItem.pinToYear should set yearOverride',
      );

      // season_2 has no groupDef, so yearOverride stays null
      final season2 = playlist.groups!.firstWhere((g) => g.id == 'season_2');
      expect(season2.yearOverride, isNull);
    });

    test('multiple definitions produce separate parent playlists', () {
      final serviceWithMultiple = SmartPlaylistResolverService(
        resolvers: [SeasonNumberResolver()],
        patterns: [
          SmartPlaylistPatternConfig(
            id: 'test',
            feedUrls: ['https://example.com/feed'],
            playlists: [
              SmartPlaylistDefinition(
                id: 'main',
                displayName: 'Main',
                grouping: const GroupingConfig(by: 'seasonNumber'),
                priority: 0,
                episodeFilters: EpisodeFilters(
                  require: [EpisodeFilterEntry(title: r'Main')],
                ),
              ),
              const SmartPlaylistDefinition(
                id: 'extras',
                displayName: 'Extras',
                grouping: GroupingConfig(by: 'seasonNumber'),
                priority: 1,
              ),
            ],
          ),
        ],
      );

      final episodes = [
        _makeEpisode(1, seasonNumber: 1, title: 'Main S1E1'),
        _makeEpisode(2, seasonNumber: 1, title: 'Main S1E2'),
        _makeEpisode(3, seasonNumber: 1, title: 'Extra Bonus'),
      ];

      final result = serviceWithMultiple.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      // Two parent playlists (Main and Extras), not flat seasons
      expect(result!.playlists, hasLength(2));
      expect(result.playlists[0].displayName, 'Main');
      expect(result.playlists[0].groups, isNotNull);
      expect(result.playlists[1].displayName, 'Extras');
    });

    test('isSeparate keeps resolver playlists as top-level', () {
      final serviceWithEpisodes = SmartPlaylistResolverService(
        resolvers: [SeasonNumberResolver()],
        patterns: [
          SmartPlaylistPatternConfig(
            id: 'test',
            feedUrls: ['https://example.com/feed'],
            playlists: [
              const SmartPlaylistDefinition(
                id: 'all',
                displayName: 'All',
                grouping: GroupingConfig(by: 'seasonNumber'),
                priority: 0,
                selector: SelectorConfig(),
              ),
            ],
          ),
        ],
      );

      final episodes = [
        _makeEpisode(1, seasonNumber: 1, title: 'S1E1'),
        _makeEpisode(2, seasonNumber: 2, title: 'S2E1'),
      ];

      final result = serviceWithEpisodes.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      expect(result, isNotNull);
      // Separate: each season is a separate top-level playlist
      expect(result!.playlists, hasLength(2));
      expect(result.playlists.first.groups, isNull);
    });

    test('routes episodes by episodeFilters', () {
      final serviceWithFilters = SmartPlaylistResolverService(
        resolvers: [SeasonNumberResolver(), YearResolver()],
        patterns: [
          SmartPlaylistPatternConfig(
            id: 'filter_test',
            feedUrls: ['https://example.com/feed'],
            playlists: [
              SmartPlaylistDefinition(
                id: 'bonus',
                displayName: 'Bonus',
                grouping: const GroupingConfig(by: 'year'),
                priority: 0,
                selector: const SelectorConfig(),
                episodeFilters: EpisodeFilters(
                  require: [EpisodeFilterEntry(title: r'Bonus')],
                ),
              ),
              SmartPlaylistDefinition(
                id: 'main',
                displayName: 'Main',
                grouping: const GroupingConfig(by: 'year'),
                priority: 1,
                selector: const SelectorConfig(),
                episodeFilters: EpisodeFilters(
                  exclude: [EpisodeFilterEntry(title: r'Bonus')],
                ),
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
      // year-based playlist. Playlists appear in definition order:
      // bonus first, main second.
      expect(result!.playlists.length, 2);

      // Collect all episode IDs per playlist
      final firstIds = result.playlists[0].episodeIds;
      final secondIds = result.playlists[1].episodeIds;

      // Bonus playlist (first in definition) gets episodes matching requireFilter
      expect(firstIds, unorderedEquals([2, 4]));
      // Main playlist (second in definition) gets episodes not matching excludeFilter
      expect(secondIds, unorderedEquals([1, 3]));
    });

    test('require filters use OR across entries', () {
      final service = SmartPlaylistResolverService(
        resolvers: [YearResolver()],
        patterns: [
          SmartPlaylistPatternConfig(
            id: 'or_test',
            feedUrls: ['https://example.com/feed'],
            playlists: [
              SmartPlaylistDefinition(
                id: 'special',
                displayName: 'Special',
                grouping: const GroupingConfig(by: 'year'),
                priority: 0,
                selector: const SelectorConfig(),
                episodeFilters: EpisodeFilters(
                  require: [
                    EpisodeFilterEntry(title: r'Bonus'),
                    EpisodeFilterEntry(title: r'Extra'),
                  ],
                ),
              ),
            ],
          ),
        ],
      );

      final episodes = [
        _makeEpisode(1, title: 'Bonus: BTS', publishedAt: DateTime(2024)),
        _makeEpisode(2, title: 'Extra: Outtakes', publishedAt: DateTime(2024)),
        _makeEpisode(3, title: 'Regular Ep', publishedAt: DateTime(2024)),
      ];

      final result = service.resolveSmartPlaylists(
        podcastGuid: null,
        feedUrl: 'https://example.com/feed',
        episodes: episodes,
      );

      // OR: episodes matching either 'Bonus' or 'Extra' are included
      expect(result, isNotNull);
      final ids = result!.playlists[0].episodeIds;
      expect(ids, unorderedEquals([1, 2]));
    });
  });
}
