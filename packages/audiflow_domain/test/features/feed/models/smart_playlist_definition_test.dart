import 'dart:convert';

import 'package:audiflow_domain/src/features/feed/models/episode_filter_entry.dart';
import 'package:audiflow_domain/src/features/feed/models/episode_filters.dart';
import 'package:audiflow_domain/src/features/feed/models/group_list_config.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_definition.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_episode_extractor.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_group_def.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_sort.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_title_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistDefinition', () {
    test('round-trip with full RSS config', () {
      final def = SmartPlaylistDefinition(
        id: 'main',
        displayName: 'Main Episodes',
        resolverType: 'rss',
        priority: 1,
        episodeFilters: EpisodeFilters(
          require: [EpisodeFilterEntry(title: r'^\[\d+')],
          exclude: [EpisodeFilterEntry(title: r'bonus')],
        ),
        nullSeasonGroupKey: 0,
        groupList: GroupListConfig(
          sort: SmartPlaylistSortRule(
            field: SmartPlaylistSortField.playlistNumber,
            order: SortOrder.ascending,
          ),
        ),
        titleExtractor: const SmartPlaylistTitleExtractor(
          source: 'seasonNumber',
          template: 'Season {value}',
        ),
        episodeExtractor: const SmartPlaylistEpisodeExtractor(
          source: 'title',
          pattern: r'\[(\d+)-(\d+)\]',
        ),
      );

      final json = def.toJson();
      final jsonString = jsonEncode(json);
      final decoded = SmartPlaylistDefinition.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      expect(decoded.id, 'main');
      expect(decoded.displayName, 'Main Episodes');
      expect(decoded.resolverType, 'rss');
      expect(decoded.priority, 1);
      expect(decoded.episodeFilters, isNotNull);
      expect(decoded.episodeFilters!.require, hasLength(1));
      expect(decoded.episodeFilters!.exclude, hasLength(1));
      expect(decoded.nullSeasonGroupKey, 0);
      expect(decoded.groupList, isNotNull);
      expect(decoded.groupList!.sort, isNotNull);
      expect(decoded.titleExtractor, isNotNull);
      expect(decoded.episodeExtractor, isNotNull);
    });

    test('round-trip with category groups', () {
      const def = SmartPlaylistDefinition(
        id: 'categories',
        displayName: 'Categories',
        resolverType: 'category',
        groups: [
          SmartPlaylistGroupDef(
            id: 'tech',
            displayName: 'Tech',
            pattern: r'tech',
          ),
          SmartPlaylistGroupDef(id: 'other', displayName: 'Other'),
        ],
      );

      final json = def.toJson();
      final jsonString = jsonEncode(json);
      final decoded = SmartPlaylistDefinition.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      expect(decoded.id, 'categories');
      expect(decoded.groups, hasLength(2));
      expect(decoded.groups![0].id, 'tech');
      expect(decoded.groups![0].pattern, r'tech');
      expect(decoded.groups![1].pattern, isNull);
    });

    test('minimal definition with required fields only', () {
      const def = SmartPlaylistDefinition(
        id: 'simple',
        displayName: 'Simple',
        resolverType: 'rss',
      );

      final json = def.toJson();

      // Only required keys present
      expect(json.keys, containsAll(['id', 'displayName', 'resolverType']));
      expect(json.containsKey('priority'), isFalse);
      expect(json.containsKey('groups'), isFalse);
      expect(json.containsKey('groupList'), isFalse);
      expect(json.containsKey('episodeFilters'), isFalse);

      final decoded = SmartPlaylistDefinition.fromJson(json);

      expect(decoded.id, 'simple');
      expect(decoded.priority, 0);
      expect(decoded.prependSeasonNumber, isFalse);
      expect(decoded.groupList, isNull);
      expect(decoded.episodeFilters, isNull);
      expect(decoded.episodeExtractor, isNull);
      expect(decoded.groups, isNull);
      expect(decoded.titleExtractor, isNull);
    });

    test('round-trip with userSortable true', () {
      const def = SmartPlaylistDefinition(
        id: 'toggle-test',
        displayName: 'Toggle Test',
        resolverType: 'rss',
        groupList: GroupListConfig(
          userSortable: true,
          sort: SmartPlaylistSortRule(
            field: SmartPlaylistSortField.playlistNumber,
            order: SortOrder.ascending,
          ),
        ),
      );

      final json = def.toJson();
      expect(json['groupList'], isNotNull);
      expect((json['groupList'] as Map)['userSortable'], isTrue);

      final jsonString = jsonEncode(json);
      final decoded = SmartPlaylistDefinition.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      expect(decoded.groupList?.userSortable, isTrue);
      expect(decoded.groupList?.sort, isNotNull);
      expect(decoded.groupList!.sort!.order, SortOrder.ascending);
    });
  });
}
