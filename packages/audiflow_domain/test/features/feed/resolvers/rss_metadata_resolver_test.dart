import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode({
  required int id,
  required String title,
  int? seasonNumber,
  int? episodeNumber,
  DateTime? publishedAt,
}) {
  return Episode(
    id: id,
    podcastId: 1,
    guid: 'guid-$id',
    title: title,
    audioUrl: 'https://example.com/$id.mp3',
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
    publishedAt: publishedAt ?? DateTime(2024, 1, 1),
    description: null,
    durationMs: null,
    imageUrl: null,
  );
}

void main() {
  group('RssMetadataResolver', () {
    late RssMetadataResolver resolver;

    setUp(() {
      resolver = RssMetadataResolver();
    });

    test('type is "rss"', () {
      expect(resolver.type, 'rss');
    });

    test('returns null when no episodes have season numbers', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1'),
        _makeEpisode(id: 2, title: 'Ep2'),
        _makeEpisode(id: 3, title: 'Ep3'),
      ];

      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });

    test('groups episodes by seasonNumber', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1, episodeNumber: 1),
        _makeEpisode(id: 2, title: 'Ep2', seasonNumber: 1, episodeNumber: 2),
        _makeEpisode(id: 3, title: 'Ep3', seasonNumber: 2, episodeNumber: 1),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.playlists, hasLength(2));

      final playlist1 = result.playlists.firstWhere((s) => s.id == 'season_1');
      final playlist2 = result.playlists.firstWhere((s) => s.id == 'season_2');
      expect(playlist1.episodeIds, [1, 2]);
      expect(playlist2.episodeIds, [3]);
    });

    test('treats null seasonNumber as ungrouped by default', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1, episodeNumber: 1),
        _makeEpisode(
          id: 2,
          title: 'Ep2',
          seasonNumber: null,
          episodeNumber: 100,
        ),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.playlists, hasLength(1));
      expect(result.ungroupedEpisodeIds, [2]);
    });

    test(
      'groups null/zero seasonNumber when groupNullSeasonAs is configured',
      () {
        final pattern = SmartPlaylistPattern(
          id: 'test',
          resolverType: 'rss',
          config: {'groupNullSeasonAs': 0},
        );
        final episodes = [
          _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 62, episodeNumber: 1),
          _makeEpisode(
            id: 2,
            title: 'Bangai1',
            seasonNumber: null,
            episodeNumber: 100,
          ),
          _makeEpisode(
            id: 3,
            title: 'Bangai2',
            seasonNumber: 0,
            episodeNumber: 101,
          ),
        ];

        final result = resolver.resolve(episodes, pattern);

        expect(result, isNotNull);
        expect(result!.playlists, hasLength(2));
        expect(result.ungroupedEpisodeIds, isEmpty);

        final playlist0 = result.playlists.firstWhere(
          (s) => s.id == 'season_0',
        );
        expect(playlist0.episodeIds, containsAll([2, 3]));
      },
    );

    test('uses season number as sortKey', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1, episodeNumber: 5),
        _makeEpisode(id: 2, title: 'Ep2', seasonNumber: 1, episodeNumber: 10),
        _makeEpisode(id: 3, title: 'Ep3', seasonNumber: 2, episodeNumber: 3),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      final playlist1 = result!.playlists.firstWhere((s) => s.id == 'season_1');
      final playlist2 = result.playlists.firstWhere((s) => s.id == 'season_2');

      expect(playlist1.sortKey, 1);
      expect(playlist2.sortKey, 2);
    });

    test('default sort is season number ascending', () {
      expect(resolver.defaultSort, isA<SimpleSmartPlaylistSort>());
      final sort = resolver.defaultSort as SimpleSmartPlaylistSort;
      expect(sort.field, SmartPlaylistSortField.playlistNumber);
      expect(sort.order, SortOrder.ascending);
    });

    test('sortKey is season number regardless of episodeNumber', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1),
        _makeEpisode(id: 2, title: 'Ep2', seasonNumber: 1),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.playlists[0].sortKey, 1); // season number
    });

    test('sortKey is season number even with mixed episodeNumber values', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1, episodeNumber: null),
        _makeEpisode(id: 2, title: 'Ep2', seasonNumber: 1, episodeNumber: 7),
        _makeEpisode(id: 3, title: 'Ep3', seasonNumber: 1, episodeNumber: 3),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.playlists[0].sortKey, 1); // season number
    });

    test('yearGroupedPlaylists config sets yearHeaderMode', () {
      final pattern = SmartPlaylistPattern(
        id: 'test',
        resolverType: 'rss',
        config: {
          'groupNullSeasonAs': 0,
          'yearGroupedPlaylists': {'0': true},
        },
      );
      final episodes = [
        _makeEpisode(id: 1, title: 'S1E1', seasonNumber: 1, episodeNumber: 1),
        _makeEpisode(
          id: 2,
          title: 'Extra1',
          seasonNumber: null,
          episodeNumber: 100,
        ),
      ];

      final result = resolver.resolve(episodes, pattern);

      expect(result, isNotNull);
      final playlist0 = result!.playlists.firstWhere((s) => s.id == 'season_0');
      expect(playlist0.yearHeaderMode, YearHeaderMode.firstEpisode);
    });

    test('playlists not in yearGroupedPlaylists get '
        'yearHeaderMode=none', () {
      final pattern = SmartPlaylistPattern(
        id: 'test',
        resolverType: 'rss',
        config: {
          'yearGroupedPlaylists': {'0': true},
        },
      );
      final episodes = [
        _makeEpisode(id: 1, title: 'S1E1', seasonNumber: 1, episodeNumber: 1),
      ];

      final result = resolver.resolve(episodes, pattern);

      expect(result, isNotNull);
      final playlist1 = result!.playlists.firstWhere((s) => s.id == 'season_1');
      expect(playlist1.yearHeaderMode, YearHeaderMode.none);
    });

    test('seasons are sorted by season number', () {
      final episodes = [
        _makeEpisode(id: 1, title: 'Ep1', seasonNumber: 3, episodeNumber: 1),
        _makeEpisode(id: 2, title: 'Ep2', seasonNumber: 1, episodeNumber: 1),
        _makeEpisode(id: 3, title: 'Ep3', seasonNumber: 2, episodeNumber: 1),
      ];

      final result = resolver.resolve(episodes, null);

      expect(result, isNotNull);
      expect(result!.playlists.length, 3);
      expect(result.playlists[0].sortKey, 1);
      expect(result.playlists[1].sortKey, 2);
      expect(result.playlists[2].sortKey, 3);
    });

    group('playlists config', () {
      test('filters episodes by titleFilter into '
          'parent playlists with groups', () {
        final pattern = SmartPlaylistPattern(
          id: 'test',
          resolverType: 'rss',
          config: {
            'playlists': [
              {
                'id': 'regular',
                'displayName': 'Regular',
                'contentType': 'groups',
                'yearHeaderMode': 'firstEpisode',
                'episodeYearHeaders': false,
                'titleFilter': r'\[S\d+',
              },
              {
                'id': 'extras',
                'displayName': 'Extras',
                'contentType': 'groups',
                'yearHeaderMode': 'perEpisode',
                'episodeYearHeaders': false,
              },
            ],
          },
        );
        final episodes = [
          _makeEpisode(id: 1, title: '[S1-1] Topic A', seasonNumber: 1),
          _makeEpisode(id: 2, title: '[S1-2] Topic A', seasonNumber: 1),
          _makeEpisode(id: 3, title: '[S2-1] Topic B', seasonNumber: 2),
          _makeEpisode(id: 4, title: 'Bonus episode', seasonNumber: 3),
        ];

        final result = resolver.resolve(episodes, pattern);

        expect(result, isNotNull);
        expect(result!.playlists, hasLength(2));

        final regular = result.playlists.firstWhere((p) => p.id == 'regular');
        expect(regular.contentType, SmartPlaylistContentType.groups);
        expect(regular.yearHeaderMode, YearHeaderMode.firstEpisode);
        expect(regular.groups, isNotNull);
        expect(regular.groups, hasLength(2));
        expect(regular.episodeIds, [1, 2, 3]);

        final group1 = regular.groups!.firstWhere((g) => g.id == 'season_1');
        expect(group1.episodeIds, [1, 2]);

        final group2 = regular.groups!.firstWhere((g) => g.id == 'season_2');
        expect(group2.episodeIds, [3]);

        // Fallback playlist gets unmatched episodes
        final extras = result.playlists.firstWhere((p) => p.id == 'extras');
        expect(extras.episodeIds, [4]);
        expect(extras.groups, hasLength(1));
        expect(extras.yearHeaderMode, YearHeaderMode.perEpisode);
      });

      test('excludeFilter removes episodes from a playlist', () {
        final pattern = SmartPlaylistPattern(
          id: 'test',
          resolverType: 'rss',
          config: {
            'playlists': [
              {
                'id': 'main',
                'displayName': 'Main',
                'contentType': 'groups',
                'titleFilter': r'\[\d+-\d+\]',
                'excludeFilter': r'Short',
              },
              {
                'id': 'extras',
                'displayName': 'Extras',
                'contentType': 'groups',
              },
            ],
          },
        );
        final episodes = [
          _makeEpisode(id: 1, title: '[1-1] Regular', seasonNumber: 1),
          _makeEpisode(id: 2, title: '[1-2] Short edition', seasonNumber: 1),
          _makeEpisode(id: 3, title: 'No match', seasonNumber: 2),
        ];

        final result = resolver.resolve(episodes, pattern);

        expect(result, isNotNull);
        final main = result!.playlists.firstWhere((p) => p.id == 'main');
        // Episode 2 excluded by excludeFilter
        expect(main.episodeIds, [1]);

        final extras = result.playlists.firstWhere((p) => p.id == 'extras');
        // Episodes 2 and 3 fall to extras
        expect(extras.episodeIds, containsAll([2, 3]));
      });

      test('requireFilter narrows matches further', () {
        final pattern = SmartPlaylistPattern(
          id: 'test',
          resolverType: 'rss',
          config: {
            'playlists': [
              {
                'id': 'short',
                'displayName': 'Short',
                'contentType': 'groups',
                'titleFilter': r'\[\d+-\d+\]',
                'requireFilter': r'Short',
              },
              {
                'id': 'extras',
                'displayName': 'Extras',
                'contentType': 'groups',
              },
            ],
          },
        );
        final episodes = [
          _makeEpisode(id: 1, title: '[1-1] Regular', seasonNumber: 1),
          _makeEpisode(id: 2, title: '[1-2] Short', seasonNumber: 1),
        ];

        final result = resolver.resolve(episodes, pattern);

        expect(result, isNotNull);
        final short = result!.playlists.firstWhere((p) => p.id == 'short');
        expect(short.episodeIds, [2]);

        final extras = result.playlists.firstWhere((p) => p.id == 'extras');
        expect(extras.episodeIds, [1]);
      });

      test('groups within parent playlist use '
          'titleExtractor for display names', () {
        final pattern = SmartPlaylistPattern(
          id: 'test',
          resolverType: 'rss',
          config: {
            'playlists': [
              {'id': 'all', 'displayName': 'All', 'contentType': 'groups'},
            ],
          },
          titleExtractor: const SmartPlaylistTitleExtractor(
            source: 'title',
            pattern: r'(.+?) \d+$',
            group: 1,
          ),
        );
        final episodes = [
          _makeEpisode(id: 1, title: 'Topic A 1', seasonNumber: 1),
          _makeEpisode(id: 2, title: 'Topic A 2', seasonNumber: 1),
        ];

        final result = resolver.resolve(episodes, pattern);

        expect(result, isNotNull);
        final all = result!.playlists.firstWhere((p) => p.id == 'all');
        expect(all.groups, hasLength(1));
        expect(all.groups!.first.displayName, 'Topic A');
      });

      test('episodes without seasonNumber go to '
          'ungrouped when no fallback playlist', () {
        final pattern = SmartPlaylistPattern(
          id: 'test',
          resolverType: 'rss',
          config: {
            'playlists': [
              {
                'id': 'main',
                'displayName': 'Main',
                'contentType': 'groups',
                'titleFilter': r'match',
              },
            ],
          },
        );
        final episodes = [
          _makeEpisode(id: 1, title: 'match ep', seasonNumber: 1),
          _makeEpisode(id: 2, title: 'no season'),
        ];

        final result = resolver.resolve(episodes, pattern);

        expect(result, isNotNull);
        expect(result!.ungroupedEpisodeIds, [2]);
      });

      test('episodeYearHeaders is set from config', () {
        final pattern = SmartPlaylistPattern(
          id: 'test',
          resolverType: 'rss',
          config: {
            'playlists': [
              {
                'id': 'main',
                'displayName': 'Main',
                'contentType': 'groups',
                'episodeYearHeaders': true,
              },
            ],
          },
        );
        final episodes = [_makeEpisode(id: 1, title: 'Ep1', seasonNumber: 1)];

        final result = resolver.resolve(episodes, pattern);

        expect(result, isNotNull);
        final main = result!.playlists.first;
        expect(main.episodeYearHeaders, isTrue);
      });

      test('playlists are ordered by config order', () {
        final pattern = SmartPlaylistPattern(
          id: 'test',
          resolverType: 'rss',
          config: {
            'playlists': [
              {
                'id': 'first',
                'displayName': 'First',
                'contentType': 'groups',
                'titleFilter': r'AAA',
              },
              {
                'id': 'second',
                'displayName': 'Second',
                'contentType': 'groups',
                'titleFilter': r'BBB',
              },
              {'id': 'third', 'displayName': 'Third', 'contentType': 'groups'},
            ],
          },
        );
        final episodes = [
          _makeEpisode(id: 1, title: 'BBB ep', seasonNumber: 1),
          _makeEpisode(id: 2, title: 'AAA ep', seasonNumber: 2),
          _makeEpisode(id: 3, title: 'CCC ep', seasonNumber: 3),
        ];

        final result = resolver.resolve(episodes, pattern);

        expect(result, isNotNull);
        expect(result!.playlists[0].id, 'first');
        expect(result.playlists[0].sortKey, 0);
        expect(result.playlists[1].id, 'second');
        expect(result.playlists[1].sortKey, 1);
        expect(result.playlists[2].id, 'third');
        expect(result.playlists[2].sortKey, 2);
      });
    });
  });
}
