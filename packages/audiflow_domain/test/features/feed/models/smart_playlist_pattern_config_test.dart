import 'dart:convert';

import 'package:audiflow_domain/src/features/feed/models/grouping_config.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_definition.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_group_def.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_pattern_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistPatternConfig', () {
    test('round-trip with feedUrls and playlists', () {
      final config = SmartPlaylistPatternConfig(
        id: 'test-podcast',
        feedUrls: ['https://example.com/feed/rss'],
        playlists: const [
          SmartPlaylistDefinition(
            id: 'main',
            displayName: 'Main',
            grouping: GroupingConfig(by: 'seasonNumber'),
            priority: 0,
          ),
        ],
      );

      final jsonString = jsonEncode(config.toJson());
      final decoded = SmartPlaylistPatternConfig.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      expect(decoded.id, 'test-podcast');
      expect(decoded.feedUrls, hasLength(1));
      expect(decoded.playlists, hasLength(1));
      expect(decoded.playlists.first.id, 'main');
      expect(decoded.yearGroupedEpisodes, isFalse);
    });

    test('matchesPodcast by feed URL - match', () {
      final config = SmartPlaylistPatternConfig(
        id: 'test',
        feedUrls: ['https://example.com/feed/rss'],
        playlists: const [
          SmartPlaylistDefinition(
            id: 'p1',
            displayName: 'P1',
            grouping: GroupingConfig(by: 'seasonNumber'),
            priority: 0,
          ),
        ],
      );

      expect(
        config.matchesPodcast(null, 'https://example.com/feed/rss'),
        isTrue,
      );
    });

    test('matchesPodcast by feed URL - no match', () {
      final config = SmartPlaylistPatternConfig(
        id: 'test',
        feedUrls: ['https://example.com/feed/rss'],
        playlists: const [
          SmartPlaylistDefinition(
            id: 'p1',
            displayName: 'P1',
            grouping: GroupingConfig(by: 'seasonNumber'),
            priority: 0,
          ),
        ],
      );

      expect(config.matchesPodcast(null, 'https://other.com/feed'), isFalse);
    });

    test('matchesPodcast by GUID - match', () {
      final config = SmartPlaylistPatternConfig(
        id: 'test',
        podcastGuid: 'abc-123',
        playlists: const [
          SmartPlaylistDefinition(
            id: 'p1',
            displayName: 'P1',
            grouping: GroupingConfig(by: 'seasonNumber'),
            priority: 0,
          ),
        ],
      );

      expect(config.matchesPodcast('abc-123', 'https://any.com/feed'), isTrue);
    });

    test('matchesPodcast by GUID - no match', () {
      final config = SmartPlaylistPatternConfig(
        id: 'test',
        podcastGuid: 'abc-123',
        playlists: const [
          SmartPlaylistDefinition(
            id: 'p1',
            displayName: 'P1',
            grouping: GroupingConfig(by: 'seasonNumber'),
            priority: 0,
          ),
        ],
      );

      expect(config.matchesPodcast('xyz-999', 'https://any.com/feed'), isFalse);
    });

    group('showEpisodeThumbnail tri-state round-trip', () {
      SmartPlaylistDefinition makePlaylist() => const SmartPlaylistDefinition(
        id: 'p1',
        displayName: 'P1',
        grouping: GroupingConfig(by: 'seasonNumber'),
        priority: 0,
      );

      test('explicit false survives encode/decode', () {
        final config = SmartPlaylistPatternConfig(
          id: 'test',
          feedUrls: const ['https://example.com/feed'],
          showEpisodeThumbnail: false,
          playlists: [makePlaylist()],
        );

        final decoded = SmartPlaylistPatternConfig.fromJson(
          jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>,
        );

        expect(decoded.showEpisodeThumbnail, isFalse);
      });

      test('explicit true survives encode/decode', () {
        final config = SmartPlaylistPatternConfig(
          id: 'test',
          feedUrls: const ['https://example.com/feed'],
          showEpisodeThumbnail: true,
          playlists: [makePlaylist()],
        );

        final decoded = SmartPlaylistPatternConfig.fromJson(
          jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>,
        );

        expect(decoded.showEpisodeThumbnail, isTrue);
      });

      test('unset stays null and is omitted from toJson()', () {
        final config = SmartPlaylistPatternConfig(
          id: 'test',
          feedUrls: const ['https://example.com/feed'],
          playlists: [makePlaylist()],
        );

        expect(config.showEpisodeThumbnail, isNull);
        expect(config.toJson().containsKey('showEpisodeThumbnail'), isFalse);

        final decoded = SmartPlaylistPatternConfig.fromJson(
          jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>,
        );
        expect(decoded.showEpisodeThumbnail, isNull);
      });
    });

    group('findPlaylist', () {
      SmartPlaylistPatternConfig makeConfig(List<String> ids) =>
          SmartPlaylistPatternConfig(
            id: 'test',
            feedUrls: const ['https://example.com/feed'],
            playlists: [
              for (final id in ids)
                SmartPlaylistDefinition(
                  id: id,
                  displayName: id,
                  grouping: const GroupingConfig(by: 'seasonNumber'),
                  priority: 0,
                ),
            ],
          );

      test('returns the playlist with matching id', () {
        final config = makeConfig(['regular', 'short', 'extras']);
        expect(config.findPlaylist('short')?.id, 'short');
      });

      test('returns null when no playlist matches', () {
        final config = makeConfig(['regular', 'short']);
        expect(config.findPlaylist('missing'), isNull);
      });

      test('returns null on empty playlist list', () {
        final config = makeConfig(const []);
        expect(config.findPlaylist('any'), isNull);
      });

      test('returns the first match when ids are duplicated', () {
        final config = makeConfig(['dup', 'dup']);
        expect(
          identical(config.findPlaylist('dup'), config.playlists.first),
          isTrue,
        );
      });
    });
  });

  group('GroupingConfig.findStaticClassifier', () {
    GroupingConfig makeGrouping(List<String>? classifierIds) => GroupingConfig(
      by: classifierIds == null ? 'seasonNumber' : 'titleClassifier',
      staticClassifiers: classifierIds == null
          ? null
          : [
              for (final id in classifierIds)
                SmartPlaylistGroupDef(id: id, displayName: id),
            ],
    );

    test('returns null when staticClassifiers is null', () {
      expect(makeGrouping(null).findStaticClassifier('anything'), isNull);
    });

    test('returns the matching classifier by id', () {
      expect(makeGrouping(['a', 'b', 'c']).findStaticClassifier('b')?.id, 'b');
    });

    test('returns null when id is not present', () {
      expect(makeGrouping(['a', 'b']).findStaticClassifier('z'), isNull);
    });

    test('returns first match on duplicate ids', () {
      final grouping = makeGrouping(['dup', 'dup']);
      expect(
        identical(
          grouping.findStaticClassifier('dup'),
          grouping.staticClassifiers!.first,
        ),
        isTrue,
      );
    });
  });
}
