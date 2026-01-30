import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _makeEpisode(int id, String title) {
  return Episode(
    id: id,
    podcastId: 1,
    guid: 'guid-$id',
    title: title,
    audioUrl: 'https://example.com/$id.mp3',
    publishedAt: null,
    description: null,
    durationMs: null,
    imageUrl: null,
    seasonNumber: null,
    episodeNumber: null,
  );
}

SmartPlaylistPattern _categoryPattern() {
  return const SmartPlaylistPattern(
    id: 'test_category',
    resolverType: 'category',
    config: {
      'categories': [
        {
          'id': 'daily_news',
          'displayName': 'Daily News',
          'pattern': r'【\d+月\d+日】',
          'yearGrouped': true,
          'sortKey': 1,
        },
        {
          'id': 'programs',
          'displayName': 'Programs',
          'pattern': r'【(?!\d+月\d+日)\S+',
          'yearGrouped': false,
          'sortKey': 2,
        },
      ],
    },
  );
}

void main() {
  group('CategoryResolver', () {
    late CategoryResolver resolver;

    setUp(() {
      resolver = CategoryResolver();
    });

    test('type is "category"', () {
      expect(resolver.type, 'category');
    });

    test('returns null without pattern', () {
      final episodes = [_makeEpisode(1, 'Episode 1')];
      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });

    test('returns null without categories config', () {
      const pattern = SmartPlaylistPattern(
        id: 'empty',
        resolverType: 'category',
        config: {},
      );
      final episodes = [_makeEpisode(1, 'Episode 1')];
      final result = resolver.resolve(episodes, pattern);
      expect(result, isNull);
    });

    test('groups episodes by category pattern', () {
      final pattern = _categoryPattern();
      final episodes = [
        _makeEpisode(1, '【1月29日】EU news'),
        _makeEpisode(2, '【土曜版 #62】direct prize'),
        _makeEpisode(3, '【ニュース小話 #200】bonds'),
        _makeEpisode(4, '【2月1日】US news'),
      ];

      final result = resolver.resolve(episodes, pattern);

      expect(result, isNotNull);
      expect(result!.playlists, hasLength(2));

      final daily = result.playlists.firstWhere(
        (p) => p.id == 'playlist_daily_news',
      );
      expect(daily.episodeIds, [1, 4]);
      expect(daily.displayName, 'Daily News');

      final programs = result.playlists.firstWhere(
        (p) => p.id == 'playlist_programs',
      );
      expect(programs.episodeIds, [2, 3]);
      expect(programs.displayName, 'Programs');
    });

    test('ungrouped episodes go to ungroupedEpisodeIds', () {
      final pattern = _categoryPattern();
      final episodes = [
        _makeEpisode(1, '【1月29日】EU news'),
        _makeEpisode(2, 'No bracket title'),
      ];

      final result = resolver.resolve(episodes, pattern);

      expect(result, isNotNull);
      expect(result!.ungroupedEpisodeIds, [2]);
    });

    test('yearGrouped flags are set per category', () {
      final pattern = _categoryPattern();
      final episodes = [
        _makeEpisode(1, '【1月29日】EU news'),
        _makeEpisode(2, '【土曜版 #62】direct prize'),
      ];

      final result = resolver.resolve(episodes, pattern);

      expect(result, isNotNull);
      final daily = result!.playlists.firstWhere(
        (p) => p.id == 'playlist_daily_news',
      );
      final programs = result.playlists.firstWhere(
        (p) => p.id == 'playlist_programs',
      );
      expect(daily.yearGrouped, isTrue);
      expect(programs.yearGrouped, isFalse);
    });

    test('resolves sub-categories when configured', () {
      const pattern = SmartPlaylistPattern(
        id: 'test_sub',
        resolverType: 'category',
        config: {
          'categories': [
            {
              'id': 'programs',
              'displayName': 'Programs',
              'pattern': r'【\S+',
              'sortKey': 1,
              'subCategories': [
                {
                  'id': 'saturday',
                  'displayName': 'Saturday',
                  'pattern': r'【土曜版',
                },
                {'id': 'talk', 'displayName': 'Talk', 'pattern': r'【ニュース小話'},
              ],
            },
          ],
        },
      );
      final episodes = [
        _makeEpisode(1, '【土曜版 #62】topic'),
        _makeEpisode(2, '【ニュース小話 #200】bonds'),
        _makeEpisode(3, '【特別編】special'),
      ];

      final result = resolver.resolve(episodes, pattern);

      expect(result, isNotNull);
      final playlist = result!.playlists.first;
      expect(playlist.subCategories, isNotNull);
      expect(playlist.subCategories, hasLength(3));

      expect(playlist.subCategories![0].id, 'saturday');
      expect(playlist.subCategories![0].episodeIds, [1]);

      expect(playlist.subCategories![1].id, 'talk');
      expect(playlist.subCategories![1].episodeIds, [2]);

      // Unmatched sub-category goes to "Other"
      expect(playlist.subCategories![2].id, 'other');
      expect(playlist.subCategories![2].episodeIds, [3]);
    });

    test('sub-categories are null when not configured', () {
      final pattern = _categoryPattern();
      final episodes = [_makeEpisode(1, '【1月29日】EU news')];

      final result = resolver.resolve(episodes, pattern);

      expect(result, isNotNull);
      final daily = result!.playlists.firstWhere(
        (p) => p.id == 'playlist_daily_news',
      );
      expect(daily.subCategories, isNull);
    });

    test('first match wins when multiple patterns could match', () {
      const pattern = SmartPlaylistPattern(
        id: 'overlap',
        resolverType: 'category',
        config: {
          'categories': [
            {
              'id': 'first',
              'displayName': 'First',
              'pattern': r'Hello',
              'sortKey': 1,
            },
            {
              'id': 'second',
              'displayName': 'Second',
              'pattern': r'Hello World',
              'sortKey': 2,
            },
          ],
        },
      );
      final episodes = [_makeEpisode(1, 'Hello World')];

      final result = resolver.resolve(episodes, pattern);

      expect(result, isNotNull);
      expect(result!.playlists, hasLength(1));
      expect(result.playlists.first.id, 'playlist_first');
    });
  });
}
