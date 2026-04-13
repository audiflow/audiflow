import 'dart:convert';

import 'package:audiflow_domain/src/features/feed/models/episode_filter_entry.dart';
import 'package:audiflow_domain/src/features/feed/models/episode_filters.dart';
import 'package:audiflow_domain/src/features/feed/models/group_item_config.dart';
import 'package:audiflow_domain/src/features/feed/models/group_listing_config.dart';
import 'package:audiflow_domain/src/features/feed/models/grouping_config.dart';
import 'package:audiflow_domain/src/features/feed/models/numbering_extractor.dart';
import 'package:audiflow_domain/src/features/feed/models/selector_config.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_definition.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_group_def.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_sort.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_title_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistDefinition', () {
    test('round-trip with full seasonNumber config', () {
      final def = SmartPlaylistDefinition(
        id: 'main',
        displayName: 'Main Episodes',
        grouping: const GroupingConfig(
          by: 'seasonNumber',
          numberingExtractor: NumberingExtractor(
            source: 'title',
            pattern: r'\[(\d+)-(\d+)\]',
          ),
        ),
        priority: 0,
        selector: const SelectorConfig(),
        groupListing: const GroupListingConfig(
          sort: SmartPlaylistSortRule(
            field: SmartPlaylistSortField.playlistNumber,
            order: SortOrder.ascending,
          ),
        ),
        groupItem: const GroupItemConfig(
          titleExtractor: SmartPlaylistTitleExtractor(
            source: 'seasonNumber',
            template: 'Season {value}',
          ),
        ),
        episodeFilters: EpisodeFilters(
          require: [EpisodeFilterEntry(title: r'^\[\d+')],
          exclude: [EpisodeFilterEntry(title: r'bonus')],
        ),
      );

      final json = def.toJson();
      final jsonString = jsonEncode(json);
      final decoded = SmartPlaylistDefinition.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      expect(decoded.id, 'main');
      expect(decoded.displayName, 'Main Episodes');
      expect(decoded.grouping.by, 'seasonNumber');
      expect(decoded.isSeparate, isTrue);
      expect(decoded.episodeFilters, isNotNull);
      expect(decoded.episodeFilters!.require, hasLength(1));
      expect(decoded.episodeFilters!.exclude, hasLength(1));
      expect(decoded.groupListing, isNotNull);
      expect(decoded.groupListing!.sort, isNotNull);
      expect(decoded.groupItem?.titleExtractor, isNotNull);
      expect(decoded.grouping.numberingExtractor, isNotNull);
    });

    test('round-trip with titleClassifier groups', () {
      const def = SmartPlaylistDefinition(
        id: 'categories',
        displayName: 'Categories',
        grouping: GroupingConfig(
          by: 'titleClassifier',
          staticClassifiers: [
            SmartPlaylistGroupDef(
              id: 'tech',
              displayName: 'Tech',
              pattern: r'tech',
            ),
            SmartPlaylistGroupDef(id: 'other', displayName: 'Other'),
          ],
        ),
        priority: 0,
        selector: SelectorConfig(),
      );

      final json = def.toJson();
      final jsonString = jsonEncode(json);
      final decoded = SmartPlaylistDefinition.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      expect(decoded.id, 'categories');
      expect(decoded.grouping.staticClassifiers, hasLength(2));
      expect(decoded.grouping.staticClassifiers![0].id, 'tech');
      expect(decoded.grouping.staticClassifiers![0].pattern, r'tech');
      expect(decoded.grouping.staticClassifiers![1].pattern, isNull);
    });

    test('minimal definition with required fields only', () {
      const def = SmartPlaylistDefinition(
        id: 'simple',
        displayName: 'Simple',
        grouping: GroupingConfig(by: 'seasonNumber'),
        priority: 0,
        selector: SelectorConfig(),
      );

      final json = def.toJson();

      // Only required keys present
      expect(
        json.keys,
        containsAll(['id', 'displayName', 'grouping', 'priority']),
      );
      expect(json.containsKey('groupListing'), isFalse);
      expect(json.containsKey('episodeFilters'), isFalse);

      final decoded = SmartPlaylistDefinition.fromJson(json);

      expect(decoded.id, 'simple');
      expect(decoded.isSeparate, isTrue);
      expect(decoded.groupItem?.prependSeasonNumber, isNull);
      expect(decoded.groupListing, isNull);
      expect(decoded.episodeFilters, isNull);
      expect(decoded.grouping.numberingExtractor, isNull);
      expect(decoded.grouping.staticClassifiers, isNull);
      expect(decoded.groupItem?.titleExtractor, isNull);
    });

    test('round-trip with userSortable true', () {
      const def = SmartPlaylistDefinition(
        id: 'toggle-test',
        displayName: 'Toggle Test',
        grouping: GroupingConfig(by: 'seasonNumber'),
        priority: 0,
        groupListing: GroupListingConfig(
          userSortable: true,
          sort: SmartPlaylistSortRule(
            field: SmartPlaylistSortField.playlistNumber,
            order: SortOrder.ascending,
          ),
        ),
      );

      final json = def.toJson();
      expect(json['groupListing'], isNotNull);
      expect((json['groupListing'] as Map)['userSortable'], isTrue);

      final jsonString = jsonEncode(json);
      final decoded = SmartPlaylistDefinition.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );

      expect(decoded.groupListing?.userSortable, isTrue);
      expect(decoded.groupListing?.sort, isNotNull);
      expect(decoded.groupListing!.sort!.order, SortOrder.ascending);
    });
  });
}
