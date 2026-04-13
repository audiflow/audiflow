import 'dart:convert';
import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
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

/// Loads and parses a vendored schema file.
Map<String, dynamic> _loadSchema(String filename) {
  final file = File(_fixturePath(filename));
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

void main() {
  late Map<String, dynamic> schema;
  late Map<String, dynamic> defs;
  late JsonSchema jsonSchema;
  late Map<String, dynamic> patternIndexSchema;
  late JsonSchema patternIndexJsonSchema;
  late Map<String, dynamic> patternMetaSchema;
  late JsonSchema patternMetaJsonSchema;

  setUpAll(() {
    schema = _loadSchema('playlist-definition.schema.json');
    defs = schema[r'$defs'] as Map<String, dynamic>;
    jsonSchema = JsonSchema.create(jsonEncode(schema));

    patternIndexSchema = _loadSchema('pattern-index.schema.json');
    patternIndexJsonSchema = JsonSchema.create(jsonEncode(patternIndexSchema));

    patternMetaSchema = _loadSchema('pattern-meta.schema.json');
    patternMetaJsonSchema = JsonSchema.create(jsonEncode(patternMetaSchema));
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
        resolverType: 'seasonNumber',
        presentation: 'separate',
      );
      expect(validate(def.toJson()), isEmpty);
    });

    test('full SmartPlaylistDefinition round-trips', () {
      final def = SmartPlaylistDefinition(
        id: 'seasons',
        displayName: 'Seasons',
        resolverType: 'seasonNumber',
        presentation: 'combined',
        prependSeasonNumber: true,
        episodeFilters: EpisodeFilters(
          require: [EpisodeFilterEntry(title: r'S\d+')],
          exclude: [EpisodeFilterEntry(title: r'Trailer')],
        ),
        groupList: GroupListConfig(
          yearBinding: YearBinding.pinToYear,
          userSortable: true,
          showDateRange: true,
          sort: SmartPlaylistSortRule(
            field: SmartPlaylistSortField.playlistNumber,
            order: SortOrder.descending,
          ),
        ),
        episodeList: EpisodeListConfig(
          showYearHeaders: true,
          sort: EpisodeSortRule(
            field: EpisodeSortField.publishedAt,
            order: SortOrder.descending,
          ),
        ),
        groups: [
          SmartPlaylistGroupDef(
            id: 'main',
            displayName: 'Main',
            pattern: r'^Main\b',
          ),
          SmartPlaylistGroupDef(id: 'other', displayName: 'Other'),
        ],
        titleExtractor: SmartPlaylistTitleExtractor(
          source: 'title',
          pattern: r'\[(.+?)\]',
          group: 1,
          template: 'Season {value}',
        ),
        numberingExtractor: const NumberingExtractor(
          source: 'title',
          pattern: r'\[(\d+)-(\d+)\]',
          seasonGroup: 1,
          episodeGroup: 2,
          fallbackToRss: true,
        ),
      );
      expect(validate(def.toJson()), isEmpty);
    });
  });

  group('enum values match vendored playlist-definition schema', () {
    test('resolverTypes match schema oneOf', () {
      // The v4 schema validates definitions directly at root level
      final props = schema['properties'] as Map<String, dynamic>;
      final resolverType = props['resolverType'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(resolverType);

      // These are the valid resolver type strings from the schema.
      // If this fails, a resolver type was added/removed in the schema
      // and audiflow_domain models need updating.
      expect(
        schemaValues,
        containsAll([
          'seasonNumber',
          'titleClassifier',
          'year',
          'titleDiscovery',
        ]),
      );
    });

    test('presentation values match schema', () {
      final props = schema['properties'] as Map<String, dynamic>;
      final ps = props['presentation'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(ps);
      expect(schemaValues, containsAll(['separate', 'combined']));
    });

    test('yearBinding values match schema', () {
      final yearBinding = defs['YearBinding'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(yearBinding);
      final dartValues = YearBinding.values.map((e) => e.name).toList();
      expect(dartValues, equals(schemaValues));
    });

    test('sortFields match schema oneOf', () {
      final sortRule = defs['SortRule'] as Map<String, dynamic>;
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
      final sortOrder = defs['SortOrder'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(sortOrder);

      final dartEnumValues = SortOrder.values.map((e) => e.name).toList();
      expect(dartEnumValues, equals(schemaValues));
    });

    test('episodeSortField values match schema', () {
      final episodeSortRule = defs['EpisodeSortRule'] as Map<String, dynamic>;
      final props = episodeSortRule['properties'] as Map<String, dynamic>;
      final field = props['field'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(field);
      final dartValues = EpisodeSortField.values.map((e) => e.name).toList();
      expect(dartValues, equals(schemaValues));
    });

    test('titleExtractorSources match schema enum', () {
      final titleExtractor = defs['TitleExtractor'] as Map<String, dynamic>;
      final props = titleExtractor['properties'] as Map<String, dynamic>;
      final source = props['source'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(source);
      expect(
        schemaValues,
        containsAll(['title', 'description', 'seasonNumber', 'episodeNumber']),
      );
    });

    test('numberingExtractorSources match schema enum', () {
      final numberingExtractor =
          defs['NumberingExtractor'] as Map<String, dynamic>;
      final props = numberingExtractor['properties'] as Map<String, dynamic>;
      final source = props['source'] as Map<String, dynamic>;
      final schemaValues = _extractEnum(source);
      expect(schemaValues, containsAll(['title', 'description']));
    });

    test(r'playlist-definition schema has v5 $id', () {
      expect(
        schema[r'$id'],
        equals('https://audiflow.app/schema/v5/playlist-definition.json'),
      );
    });

    test(r'pattern-index schema has v4 $id', () {
      expect(
        patternIndexSchema[r'$id'],
        equals('https://audiflow.app/schema/v4/pattern-index.json'),
      );
    });

    test(r'pattern-meta schema has v4 $id', () {
      expect(
        patternMetaSchema[r'$id'],
        equals('https://audiflow.app/schema/v4/pattern-meta.json'),
      );
    });
  });

  group('RootMeta toJson validates against pattern-index schema', () {
    List<String> validatePatternIndex(Object? parsed) {
      final result = patternIndexJsonSchema.validate(parsed);
      if (result.isValid) return const [];
      return result.errors.map((e) => e.message).toList();
    }

    test('minimal RootMeta round-trips', () {
      final meta = RootMeta(dataVersion: 1, schemaVersion: 4, patterns: []);
      expect(validatePatternIndex(meta.toJson()), isEmpty);
    });

    test('full RootMeta with patterns round-trips', () {
      final meta = RootMeta(
        dataVersion: 5,
        schemaVersion: 4,
        patterns: [
          PatternSummary(
            id: 'coten_radio',
            dataVersion: 2,
            displayName: 'Coten Radio',
            feedUrlHint: 'anchor.fm/s/8c2088c',
            playlistCount: 3,
          ),
        ],
      );
      expect(validatePatternIndex(meta.toJson()), isEmpty);
    });
  });

  group('PatternMeta toJson validates against pattern-meta schema', () {
    List<String> validatePatternMeta(Object? parsed) {
      final result = patternMetaJsonSchema.validate(parsed);
      if (result.isValid) return const [];
      return result.errors.map((e) => e.message).toList();
    }

    test('minimal PatternMeta round-trips', () {
      final meta = PatternMeta(
        dataVersion: 1,
        id: 'test_pattern',
        feedUrls: ['https://example.com/feed.xml'],
        playlists: ['main'],
      );
      expect(validatePatternMeta(meta.toJson()), isEmpty);
    });

    test('full PatternMeta round-trips', () {
      final meta = PatternMeta(
        dataVersion: 3,
        id: 'coten_radio',
        podcastGuid: 'abc-123-def',
        feedUrls: [
          'https://anchor.fm/s/8c2088c/podcast/rss',
          'https://alt-feed.example.com/rss',
        ],
        yearGroupedEpisodes: true,
        playlists: ['regular', 'short', 'extras'],
      );
      expect(validatePatternMeta(meta.toJson()), isEmpty);
    });
  });
}
