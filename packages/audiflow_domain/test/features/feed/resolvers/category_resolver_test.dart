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

void main() {
  group('CategoryResolver', () {
    late CategoryResolver resolver;

    setUp(() {
      resolver = CategoryResolver();
    });

    test('type is "category"', () {
      expect(resolver.type, 'category');
    });

    test('returns null without definition', () {
      final episodes = [_makeEpisode(1, 'Episode 1')];
      final result = resolver.resolve(episodes, null);
      expect(result, isNull);
    });

    test('returns null without groups', () {
      const definition = SmartPlaylistDefinition(
        id: 'empty',
        displayName: 'Empty',
        resolverType: 'category',
      );
      final episodes = [_makeEpisode(1, 'Episode 1')];
      final result = resolver.resolve(episodes, definition);
      expect(result, isNull);
    });

    test('groups episodes by pattern', () {
      const definition = SmartPlaylistDefinition(
        id: 'test',
        displayName: 'Test',
        resolverType: 'category',
        groups: [
          SmartPlaylistGroupDef(
            id: 'saturday',
            displayName: 'Saturday',
            pattern: r'【土曜版',
          ),
          SmartPlaylistGroupDef(
            id: 'news_talk',
            displayName: 'News Talk',
            pattern: r'【ニュース小話',
          ),
          SmartPlaylistGroupDef(id: 'other', displayName: 'Other'),
        ],
      );

      final episodes = [
        _makeEpisode(1, '【土曜版 #62】topic'),
        _makeEpisode(2, '【ニュース小話 #200】bonds'),
        _makeEpisode(3, '【1月29日】EU news'),
      ];

      final result = resolver.resolve(episodes, definition);

      expect(result, isNotNull);
      expect(result!.playlists, hasLength(1));

      final playlist = result.playlists.first;
      expect(playlist.groups, hasLength(3));
      expect(playlist.groups![0].id, 'saturday');
      expect(playlist.groups![0].episodeIds, [1]);
      expect(playlist.groups![1].id, 'news_talk');
      expect(playlist.groups![1].episodeIds, [2]);
      expect(playlist.groups![2].id, 'other');
      expect(playlist.groups![2].episodeIds, [3]);
    });

    test('ungrouped when no fallback group', () {
      const definition = SmartPlaylistDefinition(
        id: 'test',
        displayName: 'Test',
        resolverType: 'category',
        groups: [
          SmartPlaylistGroupDef(
            id: 'saturday',
            displayName: 'Saturday',
            pattern: r'【土曜版',
          ),
        ],
      );

      final episodes = [
        _makeEpisode(1, '【土曜版 #62】topic'),
        _makeEpisode(2, 'No match'),
      ];

      final result = resolver.resolve(episodes, definition);

      expect(result, isNotNull);
      expect(result!.ungroupedEpisodeIds, [2]);
    });

    test('first match wins when multiple patterns could match', () {
      const definition = SmartPlaylistDefinition(
        id: 'overlap',
        displayName: 'Overlap',
        resolverType: 'category',
        groups: [
          SmartPlaylistGroupDef(
            id: 'first',
            displayName: 'First',
            pattern: r'Hello',
          ),
          SmartPlaylistGroupDef(
            id: 'second',
            displayName: 'Second',
            pattern: r'Hello World',
          ),
        ],
      );
      final episodes = [_makeEpisode(1, 'Hello World')];

      final result = resolver.resolve(episodes, definition);

      expect(result, isNotNull);
      final groups = result!.playlists.first.groups!;
      expect(groups, hasLength(1));
      expect(groups.first.id, 'first');
    });

    test('returns null when groups list is empty', () {
      const definition = SmartPlaylistDefinition(
        id: 'empty',
        displayName: 'Empty',
        resolverType: 'category',
        groups: [],
      );

      final episodes = [_makeEpisode(1, 'Episode 1')];

      final result = resolver.resolve(episodes, definition);
      expect(result, isNull);
    });

    test('fallback group collects unmatched episodes', () {
      const definition = SmartPlaylistDefinition(
        id: 'test',
        displayName: 'Test',
        resolverType: 'category',
        groups: [
          SmartPlaylistGroupDef(
            id: 'matched',
            displayName: 'Matched',
            pattern: r'AAA',
          ),
          SmartPlaylistGroupDef(id: 'fallback', displayName: 'Fallback'),
        ],
      );

      final episodes = [
        _makeEpisode(1, 'AAA episode'),
        _makeEpisode(2, 'BBB episode'),
      ];

      final result = resolver.resolve(episodes, definition);

      expect(result, isNotNull);
      final groups = result!.playlists.first.groups!;
      expect(groups, hasLength(2));
      expect(groups[0].id, 'matched');
      expect(groups[0].episodeIds, [1]);
      expect(groups[1].id, 'fallback');
      expect(groups[1].episodeIds, [2]);
    });
  });
}
