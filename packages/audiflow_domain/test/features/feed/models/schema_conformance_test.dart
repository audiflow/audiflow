import 'dart:convert';
import 'dart:io';

import 'package:audiflow_domain/src/features/feed/models/smart_playlist_definition.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_episode_extractor.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_group_def.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_pattern_config.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_sort.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_title_extractor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

/// Resolves the path to a test fixture file, working correctly
/// regardless of whether flutter test is run from the project root
/// or the package directory.
String _fixturePath(String relativePath) {
  // When flutter test runs from project root, CWD != package root.
  // Try the package-relative path first, then fall back to CWD-relative.
  final candidates = [
    'packages/audiflow_domain/test/fixtures/$relativePath',
    'test/fixtures/$relativePath',
  ];
  for (final path in candidates) {
    final file = File(path);
    if (file.existsSync()) return path;
  }
  throw StateError('Fixture not found: $relativePath');
}

/// Loads and parses the vendored schema.json.
Map<String, dynamic> _loadSchema() {
  final file = File(_fixturePath('schema.json'));
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

/// Extracts enum values from a schema property definition.
List<String> _extractEnum(Map<String, dynamic> property) {
  if (property.containsKey('enum')) {
    return (property['enum'] as List<dynamic>).cast<String>();
  }
  if (property.containsKey('oneOf')) {
    return (property['oneOf'] as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>)['const'] as String)
        .toList();
  }
  return [];
}

/// Wraps playlist definitions in a valid config envelope for schema
/// validation.
Map<String, dynamic> _wrapInConfig(
  List<Map<String, dynamic>> playlists, {
  String id = 'test',
  String? podcastGuid,
  List<String>? feedUrls,
  bool yearGroupedEpisodes = false,
}) {
  return {
    'version': 1,
    'patterns': [
      {
        'id': id,
        'podcastGuid': ?podcastGuid,
        'feedUrls': ?feedUrls,
        if (yearGroupedEpisodes) 'yearGroupedEpisodes': yearGroupedEpisodes,
        'playlists': playlists,
      },
    ],
  };
}

void main() {
  late Map<String, dynamic> schema;
  late Map<String, dynamic> defs;
  late JsonSchema jsonSchema;

  setUpAll(() {
    schema = _loadSchema();
    defs = schema[r'$defs'] as Map<String, dynamic>;
    final schemaString = jsonEncode(schema);
    jsonSchema = JsonSchema.create(schemaString);
  });

  /// Validates a parsed JSON object against the schema.
  /// Returns a list of error messages (empty = valid).
  List<String> validate(Object? parsed) {
    final result = jsonSchema.validate(parsed);
    if (result.isValid) return const [];
    return result.errors.map((e) => e.message).toList();
  }

  group('model toJson round-trip validates against schema', () {
    test('minimal SmartPlaylistDefinition round-trips', () {
      const def = SmartPlaylistDefinition(
        id: 'main',
        displayName: 'Main Episodes',
        resolverType: 'rss',
      );
      final wrapped = _wrapInConfig([def.toJson()]);
      expect(validate(wrapped), isEmpty);
    });

    test('full SmartPlaylistDefinition round-trips', () {
      const def = SmartPlaylistDefinition(
        id: 'seasons',
        displayName: 'Seasons',
        resolverType: 'rss',
        priority: 100,
        contentType: 'groups',
        yearHeaderMode: 'firstEpisode',
        episodeYearHeaders: true,
        showDateRange: true,
        titleFilter: r'S\d+',
        excludeFilter: r'Trailer',
        requireFilter: r'\[.+\]',
        nullSeasonGroupKey: 0,
        groups: [
          SmartPlaylistGroupDef(
            id: 'main',
            displayName: 'Main',
            pattern: r'^Main\b',
          ),
          SmartPlaylistGroupDef(id: 'other', displayName: 'Other'),
        ],
        customSort: SmartPlaylistSortSpec([
          SmartPlaylistSortRule(
            field: SmartPlaylistSortField.playlistNumber,
            order: SortOrder.descending,
            condition: SortKeyGreaterThan(0),
          ),
          SmartPlaylistSortRule(
            field: SmartPlaylistSortField.newestEpisodeDate,
            order: SortOrder.descending,
          ),
        ]),
        titleExtractor: SmartPlaylistTitleExtractor(
          source: 'title',
          pattern: r'\[(.+?)\]',
          group: 1,
          template: 'Season {value}',
        ),
        smartPlaylistEpisodeExtractor: SmartPlaylistEpisodeExtractor(
          source: 'title',
          pattern: r'\[(\d+)-(\d+)\]',
          seasonGroup: 1,
          episodeGroup: 2,
          fallbackToRss: true,
        ),
      );
      final wrapped = _wrapInConfig(
        [def.toJson()],
        podcastGuid: 'guid-123',
        feedUrls: ['https://example.com/feed.xml'],
        yearGroupedEpisodes: true,
      );
      expect(validate(wrapped), isEmpty);
    });

    test('SmartPlaylistPatternConfig round-trips', () {
      final config = SmartPlaylistPatternConfig(
        id: 'test-podcast',
        podcastGuid: 'guid-abc',
        feedUrls: ['https://example.com/feed'],
        yearGroupedEpisodes: true,
        playlists: const [
          SmartPlaylistDefinition(
            id: 'main',
            displayName: 'Main',
            resolverType: 'category',
            groups: [
              SmartPlaylistGroupDef(
                id: 'g1',
                displayName: 'Group 1',
                pattern: r'.*',
              ),
            ],
          ),
        ],
      );
      final wrapped = {
        'version': 1,
        'patterns': [config.toJson()],
      };
      expect(validate(wrapped), isEmpty);
    });
  });

  group('enum values match vendored schema.json', () {
    test('resolverTypes match schema oneOf', () {
      final definition =
          defs['SmartPlaylistDefinition'] as Map<String, dynamic>;
      final props = definition['properties'] as Map<String, dynamic>;
      final resolverType = props['resolverType'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(resolverType);

      // These are the valid resolver type strings from the schema.
      // If this fails, a resolver type was added/removed in the schema
      // and audiflow_domain models need updating.
      expect(
        schemaValues,
        containsAll(['rss', 'category', 'year', 'titleAppearanceOrder']),
      );
    });

    test('contentTypes match schema enum', () {
      final definition =
          defs['SmartPlaylistDefinition'] as Map<String, dynamic>;
      final props = definition['properties'] as Map<String, dynamic>;
      final contentType = props['contentType'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(contentType);
      expect(schemaValues, containsAll(['episodes', 'groups']));
    });

    test('yearHeaderModes match schema enum', () {
      final definition =
          defs['SmartPlaylistDefinition'] as Map<String, dynamic>;
      final props = definition['properties'] as Map<String, dynamic>;
      final yearHeaderMode = props['yearHeaderMode'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(yearHeaderMode);
      expect(schemaValues, containsAll(['none', 'firstEpisode', 'perEpisode']));
    });

    test('sortFields match schema oneOf', () {
      final sortRule = defs['SmartPlaylistSortRule'] as Map<String, dynamic>;
      final props = sortRule['properties'] as Map<String, dynamic>;
      final field = props['field'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(field);

      // Verify SmartPlaylistSortField enum names match schema values
      final dartEnumValues = SmartPlaylistSortField.values
          .map((e) => e.name)
          .toList();
      expect(dartEnumValues, equals(schemaValues));
    });

    test('sortOrders match schema enum', () {
      final sortRule = defs['SmartPlaylistSortRule'] as Map<String, dynamic>;
      final props = sortRule['properties'] as Map<String, dynamic>;
      final order = props['order'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(order);

      final dartEnumValues = SortOrder.values.map((e) => e.name).toList();
      expect(dartEnumValues, equals(schemaValues));
    });

    test('sortConditionTypes match schema enum', () {
      final sortCondition =
          defs['SmartPlaylistSortCondition'] as Map<String, dynamic>;
      final props = sortCondition['properties'] as Map<String, dynamic>;
      final type = props['type'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(type);
      expect(schemaValues, containsAll(['sortKeyGreaterThan', 'greaterThan']));
    });

    test('titleExtractorSources match schema enum', () {
      final titleExtractor =
          defs['SmartPlaylistTitleExtractor'] as Map<String, dynamic>;
      final props = titleExtractor['properties'] as Map<String, dynamic>;
      final source = props['source'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(source);
      expect(
        schemaValues,
        containsAll(['title', 'description', 'seasonNumber', 'episodeNumber']),
      );
    });

    test('episodeExtractorSources match schema enum', () {
      final episodeExtractor =
          defs['SmartPlaylistEpisodeExtractor'] as Map<String, dynamic>;
      final props = episodeExtractor['properties'] as Map<String, dynamic>;
      final source = props['source'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(source);
      expect(schemaValues, containsAll(['title', 'description']));
    });

    test('schema version is 1', () {
      final props = schema['properties'] as Map<String, dynamic>;
      final version = props['version'] as Map<String, dynamic>;
      expect(version['const'], equals(1));
    });
  });
}
