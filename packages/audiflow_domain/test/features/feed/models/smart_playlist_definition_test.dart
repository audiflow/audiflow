import 'dart:convert';

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
        titleFilter: r'^\[\d+',
        excludeFilter: r'bonus',
        nullSeasonGroupKey: 0,
        customSort: const SmartPlaylistSortSpec([
          SmartPlaylistSortRule(
            field: SmartPlaylistSortField.playlistNumber,
            order: SortOrder.ascending,
          ),
        ]),
        titleExtractor: const SmartPlaylistTitleExtractor(
          source: 'seasonNumber',
          template: 'Season {value}',
        ),
        smartPlaylistEpisodeExtractor: const SmartPlaylistEpisodeExtractor(
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
      expect(decoded.titleFilter, r'^\[\d+');
      expect(decoded.excludeFilter, r'bonus');
      expect(decoded.nullSeasonGroupKey, 0);
      expect(decoded.customSort, isA<SmartPlaylistSortSpec>());
      expect(decoded.customSort!.rules, hasLength(1));
      expect(decoded.titleExtractor, isNotNull);
      expect(decoded.smartPlaylistEpisodeExtractor, isNotNull);
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
      expect(json.containsKey('customSort'), isFalse);
      expect(json.containsKey('showSortOrderToggle'), isFalse);

      final decoded = SmartPlaylistDefinition.fromJson(json);

      expect(decoded.id, 'simple');
      expect(decoded.priority, 0);
      expect(decoded.episodeYearHeaders, isFalse);
      expect(decoded.showSortOrderToggle, isFalse);
      expect(decoded.groups, isNull);
      expect(decoded.customSort, isNull);
      expect(decoded.titleExtractor, isNull);
      expect(decoded.smartPlaylistEpisodeExtractor, isNull);
    });

    test('round-trip with showSortOrderToggle true', () {
      const def = SmartPlaylistDefinition(
        id: 'toggle-test',
        displayName: 'Toggle Test',
        resolverType: 'rss',
        showSortOrderToggle: true,
        customSort: SmartPlaylistSortSpec([
          SmartPlaylistSortRule(
            field: SmartPlaylistSortField.playlistNumber,
            order: SortOrder.ascending,
          ),
        ]),
      );

      final json = def.toJson();
      expect(json['showSortOrderToggle'], isTrue);

      final jsonString = jsonEncode(json);
      final decoded = SmartPlaylistDefinition.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      expect(decoded.showSortOrderToggle, isTrue);
      expect(decoded.customSort, isNotNull);
      expect(decoded.customSort!.rules.first.order, SortOrder.ascending);
    });
  });
}
