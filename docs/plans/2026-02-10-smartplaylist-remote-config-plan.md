# SmartPlaylist Remote Config Loading - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace bundled asset SmartPlaylist configs with remote fetching from GCS/GitHub Pages using lazy per-podcast loading and disk-based caching with version invalidation.

**Architecture:** New split-format models (RootMeta, PatternMeta, PatternSummary) in audiflow_domain. Remote datasource fetches via Dio. Local datasource caches to disk mirroring remote file structure. Repository orchestrates cache-aware lazy loading. Providers updated for on-demand config fetching per podcast.

**Tech Stack:** Dart 3.10, Flutter 3.38, Dio (existing), path_provider (existing), Riverpod with code generation, audiflow_domain package.

**Design doc:** `docs/plans/2026-02-10-smartplaylist-remote-config-design.md`

---

## Phase 1: Split-Format Models

### Task 1: Add PatternSummary model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/pattern_summary.dart`
- Test: `packages/audiflow_domain/test/features/feed/models/pattern_summary_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart` (add export)

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/models/pattern_summary_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatternSummary', () {
    test('constructs with required fields', () {
      final summary = PatternSummary(
        id: 'coten_radio',
        version: 1,
        displayName: 'Coten Radio',
        feedUrlHint: 'anchor.fm/s/8c2088c',
        playlistCount: 3,
      );
      expect(summary.id, 'coten_radio');
      expect(summary.version, 1);
      expect(summary.displayName, 'Coten Radio');
      expect(summary.feedUrlHint, 'anchor.fm/s/8c2088c');
      expect(summary.playlistCount, 3);
    });

    test('deserializes from JSON', () {
      final json = {
        'id': 'coten_radio',
        'version': 2,
        'displayName': 'Coten Radio',
        'feedUrlHint': 'anchor.fm/s/8c2088c',
        'playlistCount': 3,
      };
      final summary = PatternSummary.fromJson(json);
      expect(summary.id, 'coten_radio');
      expect(summary.version, 2);
    });

    test('serializes to JSON', () {
      final summary = PatternSummary(
        id: 'news',
        version: 1,
        displayName: 'News',
        feedUrlHint: 'example.com',
        playlistCount: 2,
      );
      final json = summary.toJson();
      expect(json['id'], 'news');
      expect(json['version'], 1);
      expect(json['displayName'], 'News');
      expect(json['feedUrlHint'], 'example.com');
      expect(json['playlistCount'], 2);
    });

    test('roundtrips through JSON', () {
      final original = PatternSummary(
        id: 'test',
        version: 5,
        displayName: 'Test Pattern',
        feedUrlHint: 'test.com/feed',
        playlistCount: 1,
      );
      final restored = PatternSummary.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.version, original.version);
      expect(restored.displayName, original.displayName);
      expect(restored.feedUrlHint, original.feedUrlHint);
      expect(restored.playlistCount, original.playlistCount);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `dart test packages/audiflow_domain/test/features/feed/models/pattern_summary_test.dart`
Expected: FAIL - cannot find `PatternSummary`

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/pattern_summary.dart

/// Summary of a pattern from root meta.json.
///
/// Used for browse lists, feed URL pre-filtering, and
/// version-based cache invalidation.
final class PatternSummary {
  const PatternSummary({
    required this.id,
    required this.version,
    required this.displayName,
    required this.feedUrlHint,
    required this.playlistCount,
  });

  factory PatternSummary.fromJson(Map<String, dynamic> json) {
    return PatternSummary(
      id: json['id'] as String,
      version: json['version'] as int,
      displayName: json['displayName'] as String,
      feedUrlHint: json['feedUrlHint'] as String,
      playlistCount: json['playlistCount'] as int,
    );
  }

  final String id;
  final int version;
  final String displayName;
  final String feedUrlHint;
  final int playlistCount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'displayName': displayName,
      'feedUrlHint': feedUrlHint,
      'playlistCount': playlistCount,
    };
  }
}
```

Add export to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/models/pattern_summary.dart';
```

**Step 4: Run test to verify it passes**

Run: `dart test packages/audiflow_domain/test/features/feed/models/pattern_summary_test.dart`
Expected: PASS

**Step 5: Commit**

---

### Task 2: Add RootMeta model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/root_meta.dart`
- Test: `packages/audiflow_domain/test/features/feed/models/root_meta_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart` (add export)

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/models/root_meta_test.dart
import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RootMeta', () {
    test('deserializes from JSON', () {
      final json = {
        'version': 1,
        'patterns': [
          {
            'id': 'coten_radio',
            'version': 1,
            'displayName': 'Coten Radio',
            'feedUrlHint': 'anchor.fm/s/8c2088c',
            'playlistCount': 3,
          },
        ],
      };
      final meta = RootMeta.fromJson(json);
      expect(meta.version, 1);
      expect(meta.patterns, hasLength(1));
      expect(meta.patterns[0].id, 'coten_radio');
    });

    test('serializes to JSON', () {
      final meta = RootMeta(
        version: 1,
        patterns: [
          PatternSummary(
            id: 'test',
            version: 1,
            displayName: 'Test',
            feedUrlHint: 'test.com',
            playlistCount: 2,
          ),
        ],
      );
      final json = meta.toJson();
      expect(json['version'], 1);
      expect((json['patterns'] as List), hasLength(1));
    });

    test('parses from JSON string', () {
      final jsonString = jsonEncode({
        'version': 1,
        'patterns': [
          {
            'id': 'p1',
            'version': 1,
            'displayName': 'P1',
            'feedUrlHint': 'example.com',
            'playlistCount': 1,
          },
        ],
      });
      final meta = RootMeta.parseJson(jsonString);
      expect(meta.patterns, hasLength(1));
    });

    test('throws FormatException for unsupported version', () {
      final jsonString = jsonEncode({'version': 99, 'patterns': []});
      expect(
        () => RootMeta.parseJson(jsonString),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `dart test packages/audiflow_domain/test/features/feed/models/root_meta_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/root_meta.dart
import 'dart:convert';

import 'pattern_summary.dart';

/// Root meta.json from the split config repository.
///
/// Contains schema version and pattern summaries for discovery.
final class RootMeta {
  const RootMeta({
    required this.version,
    required this.patterns,
  });

  static const _supportedVersion = 1;

  factory RootMeta.fromJson(Map<String, dynamic> json) {
    return RootMeta(
      version: json['version'] as int,
      patterns: (json['patterns'] as List<dynamic>)
          .map((p) => PatternSummary.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Parses a JSON string into a RootMeta.
  ///
  /// Throws [FormatException] if version is unsupported.
  static RootMeta parseJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final version = data['version'] as int?;
    if (version == null || version != _supportedVersion) {
      throw FormatException(
        'Unsupported root meta version: $version '
        '(supported: $_supportedVersion)',
      );
    }
    return RootMeta.fromJson(data);
  }

  final int version;
  final List<PatternSummary> patterns;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'patterns': patterns.map((p) => p.toJson()).toList(),
    };
  }
}
```

Add export to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/models/root_meta.dart';
```

**Step 4: Run test to verify it passes**

Run: `dart test packages/audiflow_domain/test/features/feed/models/root_meta_test.dart`
Expected: PASS

**Step 5: Commit**

---

### Task 3: Add PatternMeta model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/pattern_meta.dart`
- Test: `packages/audiflow_domain/test/features/feed/models/pattern_meta_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart` (add export)

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/models/pattern_meta_test.dart
import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatternMeta', () {
    test('deserializes from JSON', () {
      final json = {
        'version': 1,
        'id': 'coten_radio',
        'feedUrlPatterns': [
          r'https://anchor\.fm/s/8c2088c/podcast/rss',
        ],
        'yearGroupedEpisodes': true,
        'playlists': ['regular', 'short', 'extras'],
      };
      final meta = PatternMeta.fromJson(json);
      expect(meta.version, 1);
      expect(meta.id, 'coten_radio');
      expect(meta.feedUrlPatterns, hasLength(1));
      expect(meta.yearGroupedEpisodes, isTrue);
      expect(meta.playlists, ['regular', 'short', 'extras']);
    });

    test('defaults yearGroupedEpisodes to false', () {
      final json = {
        'version': 1,
        'id': 'test',
        'feedUrlPatterns': <String>[],
        'playlists': ['main'],
      };
      final meta = PatternMeta.fromJson(json);
      expect(meta.yearGroupedEpisodes, isFalse);
    });

    test('handles optional podcastGuid', () {
      final json = {
        'version': 1,
        'id': 'test',
        'podcastGuid': 'abc-123',
        'feedUrlPatterns': <String>[],
        'playlists': ['main'],
      };
      final meta = PatternMeta.fromJson(json);
      expect(meta.podcastGuid, 'abc-123');
    });

    test('serializes to JSON', () {
      final meta = PatternMeta(
        version: 1,
        id: 'test',
        feedUrlPatterns: ['pattern1'],
        yearGroupedEpisodes: true,
        playlists: ['p1', 'p2'],
      );
      final json = meta.toJson();
      expect(json['version'], 1);
      expect(json['id'], 'test');
      expect(json['yearGroupedEpisodes'], isTrue);
      expect(json['playlists'], ['p1', 'p2']);
    });

    test('parses from JSON string', () {
      final jsonString = jsonEncode({
        'version': 1,
        'id': 'test',
        'feedUrlPatterns': ['pattern'],
        'playlists': ['main'],
      });
      final meta = PatternMeta.parseJson(jsonString);
      expect(meta.id, 'test');
    });

    test('roundtrips through JSON', () {
      final original = PatternMeta(
        version: 2,
        id: 'test',
        podcastGuid: 'guid-1',
        feedUrlPatterns: ['p1', 'p2'],
        yearGroupedEpisodes: true,
        playlists: ['a', 'b'],
      );
      final restored = PatternMeta.fromJson(original.toJson());
      expect(restored.version, original.version);
      expect(restored.id, original.id);
      expect(restored.podcastGuid, original.podcastGuid);
      expect(restored.feedUrlPatterns, original.feedUrlPatterns);
      expect(restored.yearGroupedEpisodes, original.yearGroupedEpisodes);
      expect(restored.playlists, original.playlists);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `dart test packages/audiflow_domain/test/features/feed/models/pattern_meta_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/models/pattern_meta.dart
import 'dart:convert';

/// Pattern-level meta.json from the split config repository.
///
/// Contains feed matching rules and ordered playlist IDs.
final class PatternMeta {
  const PatternMeta({
    required this.version,
    required this.id,
    this.podcastGuid,
    required this.feedUrlPatterns,
    this.yearGroupedEpisodes = false,
    required this.playlists,
  });

  factory PatternMeta.fromJson(Map<String, dynamic> json) {
    return PatternMeta(
      version: json['version'] as int,
      id: json['id'] as String,
      podcastGuid: json['podcastGuid'] as String?,
      feedUrlPatterns:
          (json['feedUrlPatterns'] as List<dynamic>).cast<String>(),
      yearGroupedEpisodes:
          (json['yearGroupedEpisodes'] as bool?) ?? false,
      playlists: (json['playlists'] as List<dynamic>).cast<String>(),
    );
  }

  /// Parses a JSON string into a PatternMeta.
  static PatternMeta parseJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return PatternMeta.fromJson(data);
  }

  final int version;
  final String id;
  final String? podcastGuid;
  final List<String> feedUrlPatterns;
  final bool yearGroupedEpisodes;

  /// Ordered list of playlist IDs. Each corresponds to
  /// `playlists/{id}.json` in the pattern directory.
  final List<String> playlists;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'id': id,
      if (podcastGuid != null) 'podcastGuid': podcastGuid,
      'feedUrlPatterns': feedUrlPatterns,
      if (yearGroupedEpisodes) 'yearGroupedEpisodes': yearGroupedEpisodes,
      'playlists': playlists,
    };
  }
}
```

Add export to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/models/pattern_meta.dart';
```

**Step 4: Run test to verify it passes**

Run: `dart test packages/audiflow_domain/test/features/feed/models/pattern_meta_test.dart`
Expected: PASS

**Step 5: Commit**

---

### Task 4: Add ConfigAssembler service

Assembles a `SmartPlaylistPatternConfig` from split files (PatternMeta + playlist definitions).

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/services/config_assembler.dart`
- Test: `packages/audiflow_domain/test/features/feed/services/config_assembler_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart` (add export)

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/services/config_assembler_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfigAssembler', () {
    test('assembles config from pattern meta and playlists', () {
      final meta = PatternMeta(
        version: 1,
        id: 'coten_radio',
        feedUrlPatterns: [r'https://anchor\.fm/s/8c2088c/podcast/rss'],
        yearGroupedEpisodes: true,
        playlists: ['regular', 'short'],
      );
      final playlists = [
        SmartPlaylistDefinition(
          id: 'regular',
          displayName: 'Regular',
          resolverType: 'rss',
        ),
        SmartPlaylistDefinition(
          id: 'short',
          displayName: 'Short',
          resolverType: 'rss',
        ),
      ];

      final config = ConfigAssembler.assemble(meta, playlists);

      expect(config.id, 'coten_radio');
      expect(config.feedUrlPatterns, hasLength(1));
      expect(config.yearGroupedEpisodes, isTrue);
      expect(config.playlists, hasLength(2));
      expect(config.playlists[0].id, 'regular');
      expect(config.playlists[1].id, 'short');
    });

    test('preserves podcastGuid when present', () {
      final meta = PatternMeta(
        version: 1,
        id: 'test',
        podcastGuid: 'guid-abc',
        feedUrlPatterns: [],
        playlists: ['main'],
      );
      final playlists = [
        SmartPlaylistDefinition(
          id: 'main',
          displayName: 'Main',
          resolverType: 'rss',
        ),
      ];

      final config = ConfigAssembler.assemble(meta, playlists);
      expect(config.podcastGuid, 'guid-abc');
    });

    test('orders playlists by meta playlist list order', () {
      final meta = PatternMeta(
        version: 1,
        id: 'test',
        feedUrlPatterns: [],
        playlists: ['b', 'a'],
      );
      // Provide playlists in opposite order
      final playlists = [
        SmartPlaylistDefinition(
          id: 'a',
          displayName: 'A',
          resolverType: 'rss',
        ),
        SmartPlaylistDefinition(
          id: 'b',
          displayName: 'B',
          resolverType: 'rss',
        ),
      ];

      final config = ConfigAssembler.assemble(meta, playlists);
      expect(config.playlists[0].id, 'b');
      expect(config.playlists[1].id, 'a');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `dart test packages/audiflow_domain/test/features/feed/services/config_assembler_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/services/config_assembler.dart
import '../models/pattern_meta.dart';
import '../models/smart_playlist_definition.dart';
import '../models/smart_playlist_pattern_config.dart';

/// Assembles a [SmartPlaylistPatternConfig] from split config files.
///
/// Combines a [PatternMeta] with its playlist definitions into
/// the unified config that resolvers expect.
final class ConfigAssembler {
  ConfigAssembler._();

  /// Assembles a full config from pattern metadata and playlist
  /// definitions.
  ///
  /// Playlists are ordered according to [meta.playlists]. Any
  /// playlists not listed in meta are appended at the end.
  static SmartPlaylistPatternConfig assemble(
    PatternMeta meta,
    List<SmartPlaylistDefinition> playlists,
  ) {
    final playlistMap = {for (final p in playlists) p.id: p};

    final ordered = <SmartPlaylistDefinition>[];
    for (final id in meta.playlists) {
      final playlist = playlistMap.remove(id);
      if (playlist != null) {
        ordered.add(playlist);
      }
    }
    ordered.addAll(playlistMap.values);

    return SmartPlaylistPatternConfig(
      id: meta.id,
      podcastGuid: meta.podcastGuid,
      feedUrlPatterns: meta.feedUrlPatterns,
      yearGroupedEpisodes: meta.yearGroupedEpisodes,
      playlists: ordered,
    );
  }
}
```

Add export to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/services/config_assembler.dart';
```

**Step 4: Run test to verify it passes**

Run: `dart test packages/audiflow_domain/test/features/feed/services/config_assembler_test.dart`
Expected: PASS

**Step 5: Commit**

---

## Phase 2: Cache Datasource

### Task 5: Add SmartPlaylistCacheDatasource

Reads/writes JSON files under `{cacheDir}/smartplaylist/` and manages `versions.json`.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/datasources/local/smart_playlist_cache_datasource.dart`
- Test: `packages/audiflow_domain/test/features/feed/datasources/local/smart_playlist_cache_datasource_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/datasources/local/smart_playlist_cache_datasource_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the datasource directly since it may not be exported yet
import 'package:audiflow_domain/src/features/feed/datasources/local/smart_playlist_cache_datasource.dart';

void main() {
  late Directory tempDir;
  late SmartPlaylistCacheDatasource datasource;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sp_cache_test_');
    datasource = SmartPlaylistCacheDatasource(cacheDir: tempDir.path);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('SmartPlaylistCacheDatasource', () {
    group('versions', () {
      test('returns empty map when no versions cached', () async {
        final versions = await datasource.readVersions();
        expect(versions, isEmpty);
      });

      test('writes and reads versions', () async {
        await datasource.writeVersions({'coten_radio': 3, 'news': 1});
        final versions = await datasource.readVersions();
        expect(versions['coten_radio'], 3);
        expect(versions['news'], 1);
      });
    });

    group('root meta', () {
      test('returns null when no root meta cached', () async {
        final meta = await datasource.readRootMeta();
        expect(meta, isNull);
      });

      test('writes and reads root meta', () async {
        final meta = RootMeta(
          version: 1,
          patterns: [
            PatternSummary(
              id: 'test',
              version: 1,
              displayName: 'Test',
              feedUrlHint: 'test.com',
              playlistCount: 1,
            ),
          ],
        );
        await datasource.writeRootMeta(meta);
        final restored = await datasource.readRootMeta();
        expect(restored, isNotNull);
        expect(restored!.patterns, hasLength(1));
        expect(restored.patterns[0].id, 'test');
      });
    });

    group('pattern meta', () {
      test('returns null when not cached', () async {
        final meta = await datasource.readPatternMeta('missing');
        expect(meta, isNull);
      });

      test('writes and reads pattern meta', () async {
        final meta = PatternMeta(
          version: 1,
          id: 'coten_radio',
          feedUrlPatterns: [r'anchor\.fm'],
          playlists: ['regular'],
        );
        await datasource.writePatternMeta('coten_radio', meta);
        final restored = await datasource.readPatternMeta('coten_radio');
        expect(restored, isNotNull);
        expect(restored!.id, 'coten_radio');
      });
    });

    group('playlist', () {
      test('returns null when not cached', () async {
        final playlist = await datasource.readPlaylist('p', 'missing');
        expect(playlist, isNull);
      });

      test('writes and reads playlist', () async {
        final definition = SmartPlaylistDefinition(
          id: 'regular',
          displayName: 'Regular',
          resolverType: 'rss',
        );
        await datasource.writePlaylist('coten_radio', 'regular', definition);
        final restored =
            await datasource.readPlaylist('coten_radio', 'regular');
        expect(restored, isNotNull);
        expect(restored!.id, 'regular');
        expect(restored.resolverType, 'rss');
      });
    });

    group('evictPattern', () {
      test('removes pattern directory and version entry', () async {
        // Set up cached data
        final meta = PatternMeta(
          version: 1,
          id: 'old',
          feedUrlPatterns: [],
          playlists: ['main'],
        );
        await datasource.writePatternMeta('old', meta);
        await datasource.writeVersions({'old': 1, 'keep': 2});

        // Evict
        await datasource.evictPattern('old');

        // Pattern dir gone
        final restored = await datasource.readPatternMeta('old');
        expect(restored, isNull);

        // Version entry removed, other entries preserved
        final versions = await datasource.readVersions();
        expect(versions.containsKey('old'), isFalse);
        expect(versions['keep'], 2);
      });
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `dart test packages/audiflow_domain/test/features/feed/datasources/local/smart_playlist_cache_datasource_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/datasources/local/smart_playlist_cache_datasource.dart
import 'dart:convert';
import 'dart:io';

import '../../models/pattern_meta.dart';
import '../../models/pattern_summary.dart';
import '../../models/root_meta.dart';
import '../../models/smart_playlist_definition.dart';

/// Manages disk-based caching of split SmartPlaylist config files.
///
/// Cache structure mirrors the remote file layout:
/// ```
/// {cacheDir}/smartplaylist/
///   versions.json
///   meta.json
///   {patternId}/
///     meta.json
///     playlists/
///       {playlistId}.json
/// ```
class SmartPlaylistCacheDatasource {
  SmartPlaylistCacheDatasource({required String cacheDir})
      : _baseDir = '$cacheDir/smartplaylist';

  final String _baseDir;

  // -- versions.json --

  /// Reads cached version map ({patternId: version}).
  Future<Map<String, int>> readVersions() async {
    final file = File('$_baseDir/versions.json');
    if (!file.existsSync()) return {};
    final raw = await file.readAsString();
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return data.map((k, v) => MapEntry(k, v as int));
  }

  /// Writes version map to disk.
  Future<void> writeVersions(Map<String, int> versions) async {
    final file = File('$_baseDir/versions.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(versions));
  }

  // -- root meta.json --

  /// Reads cached root meta, or null if not cached.
  Future<RootMeta?> readRootMeta() async {
    final file = File('$_baseDir/meta.json');
    if (!file.existsSync()) return null;
    final raw = await file.readAsString();
    return RootMeta.parseJson(raw);
  }

  /// Writes root meta to disk.
  Future<void> writeRootMeta(RootMeta meta) async {
    final file = File('$_baseDir/meta.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(meta.toJson()));
  }

  // -- pattern meta --

  /// Reads cached pattern meta, or null if not cached.
  Future<PatternMeta?> readPatternMeta(String patternId) async {
    final file = File('$_baseDir/$patternId/meta.json');
    if (!file.existsSync()) return null;
    final raw = await file.readAsString();
    return PatternMeta.parseJson(raw);
  }

  /// Writes pattern meta to disk.
  Future<void> writePatternMeta(
    String patternId,
    PatternMeta meta,
  ) async {
    final file = File('$_baseDir/$patternId/meta.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(meta.toJson()));
  }

  // -- playlist definitions --

  /// Reads a cached playlist definition, or null if not cached.
  Future<SmartPlaylistDefinition?> readPlaylist(
    String patternId,
    String playlistId,
  ) async {
    final file = File(
      '$_baseDir/$patternId/playlists/$playlistId.json',
    );
    if (!file.existsSync()) return null;
    final raw = await file.readAsString();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return SmartPlaylistDefinition.fromJson(json);
  }

  /// Writes a playlist definition to disk.
  Future<void> writePlaylist(
    String patternId,
    String playlistId,
    SmartPlaylistDefinition definition,
  ) async {
    final file = File(
      '$_baseDir/$patternId/playlists/$playlistId.json',
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(definition.toJson()));
  }

  // -- eviction --

  /// Removes a pattern's entire cache directory and its version
  /// entry.
  Future<void> evictPattern(String patternId) async {
    final dir = Directory('$_baseDir/$patternId');
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }

    // Remove from versions.json
    final versions = await readVersions();
    versions.remove(patternId);
    await writeVersions(versions);
  }
}
```

**Step 4: Run test to verify it passes**

Run: `dart test packages/audiflow_domain/test/features/feed/datasources/local/smart_playlist_cache_datasource_test.dart`
Expected: PASS

**Step 5: Commit**

---

## Phase 3: Remote Datasource

### Task 6: Add SmartPlaylistRemoteDatasource

Fetches split config files from the remote base URL via Dio.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/datasources/remote/smart_playlist_remote_datasource.dart`
- Test: `packages/audiflow_domain/test/features/feed/datasources/remote/smart_playlist_remote_datasource_test.dart`

**Step 1: Write the failing test**

Use a fake HTTP function for testing, matching the pattern used in sp_server's `ConfigRepository`.

```dart
// packages/audiflow_domain/test/features/feed/datasources/remote/smart_playlist_remote_datasource_test.dart
import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_domain/src/features/feed/datasources/remote/smart_playlist_remote_datasource.dart';

void main() {
  const baseUrl = 'https://storage.example.com/config';

  group('SmartPlaylistRemoteDatasource', () {
    late Map<String, String> fakeResponses;
    late SmartPlaylistRemoteDatasource datasource;

    setUp(() {
      fakeResponses = {};
      datasource = SmartPlaylistRemoteDatasource(
        baseUrl: baseUrl,
        httpGet: (Uri url) async {
          final body = fakeResponses[url.toString()];
          if (body == null) throw Exception('Not found: $url');
          return body;
        },
      );
    });

    test('fetchRootMeta returns parsed root meta', () async {
      fakeResponses['$baseUrl/meta.json'] = jsonEncode({
        'version': 1,
        'patterns': [
          {
            'id': 'test',
            'version': 1,
            'displayName': 'Test',
            'feedUrlHint': 'test.com',
            'playlistCount': 1,
          },
        ],
      });

      final meta = await datasource.fetchRootMeta();
      expect(meta.patterns, hasLength(1));
      expect(meta.patterns[0].id, 'test');
    });

    test('fetchPatternMeta returns parsed pattern meta', () async {
      fakeResponses['$baseUrl/coten_radio/meta.json'] = jsonEncode({
        'version': 1,
        'id': 'coten_radio',
        'feedUrlPatterns': [r'anchor\.fm'],
        'playlists': ['regular'],
      });

      final meta = await datasource.fetchPatternMeta('coten_radio');
      expect(meta.id, 'coten_radio');
    });

    test('fetchPlaylist returns parsed playlist definition', () async {
      fakeResponses['$baseUrl/coten_radio/playlists/regular.json'] =
          jsonEncode({
        'id': 'regular',
        'displayName': 'Regular',
        'resolverType': 'rss',
      });

      final playlist =
          await datasource.fetchPlaylist('coten_radio', 'regular');
      expect(playlist.id, 'regular');
      expect(playlist.resolverType, 'rss');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `dart test packages/audiflow_domain/test/features/feed/datasources/remote/smart_playlist_remote_datasource_test.dart`
Expected: FAIL

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/datasources/remote/smart_playlist_remote_datasource.dart
import 'dart:convert';

import '../../models/pattern_meta.dart';
import '../../models/root_meta.dart';
import '../../models/smart_playlist_definition.dart';

/// Signature for an HTTP GET function returning the response body.
typedef HttpGetFn = Future<String> Function(Uri url);

/// Fetches split SmartPlaylist config files from a remote URL.
class SmartPlaylistRemoteDatasource {
  SmartPlaylistRemoteDatasource({
    required String baseUrl,
    required HttpGetFn httpGet,
  }) : _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
       _httpGet = httpGet;

  final String _baseUrl;
  final HttpGetFn _httpGet;

  /// Fetches and parses root meta.json.
  Future<RootMeta> fetchRootMeta() async {
    final body = await _httpGet(Uri.parse('$_baseUrl/meta.json'));
    return RootMeta.parseJson(body);
  }

  /// Fetches and parses pattern meta.json.
  Future<PatternMeta> fetchPatternMeta(String patternId) async {
    final body = await _httpGet(
      Uri.parse('$_baseUrl/$patternId/meta.json'),
    );
    return PatternMeta.parseJson(body);
  }

  /// Fetches and parses a single playlist definition.
  Future<SmartPlaylistDefinition> fetchPlaylist(
    String patternId,
    String playlistId,
  ) async {
    final body = await _httpGet(
      Uri.parse('$_baseUrl/$patternId/playlists/$playlistId.json'),
    );
    final json = jsonDecode(body) as Map<String, dynamic>;
    return SmartPlaylistDefinition.fromJson(json);
  }
}
```

**Step 4: Run test to verify it passes**

Run: `dart test packages/audiflow_domain/test/features/feed/datasources/remote/smart_playlist_remote_datasource_test.dart`
Expected: PASS

**Step 5: Commit**

---

## Phase 4: Repository

### Task 7: Add SmartPlaylistConfigRepository interface and implementation

Orchestrates remote fetching, disk caching, version-based invalidation, and lazy per-podcast loading.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/repositories/smart_playlist_config_repository.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/repositories/smart_playlist_config_repository_impl.dart`
- Test: `packages/audiflow_domain/test/features/feed/repositories/smart_playlist_config_repository_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart` (add exports)

**Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/feed/repositories/smart_playlist_config_repository_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/feed/datasources/local/smart_playlist_cache_datasource.dart';
import 'package:audiflow_domain/src/features/feed/datasources/remote/smart_playlist_remote_datasource.dart';
import 'package:audiflow_domain/src/features/feed/repositories/smart_playlist_config_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late Map<String, String> fakeResponses;
  late SmartPlaylistCacheDatasource cache;
  late SmartPlaylistRemoteDatasource remote;
  late SmartPlaylistConfigRepositoryImpl repo;

  const baseUrl = 'https://storage.example.com/config';

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sp_repo_test_');
    fakeResponses = {};
    cache = SmartPlaylistCacheDatasource(cacheDir: tempDir.path);
    remote = SmartPlaylistRemoteDatasource(
      baseUrl: baseUrl,
      httpGet: (Uri url) async {
        final body = fakeResponses[url.toString()];
        if (body == null) throw Exception('Not found: $url');
        return body;
      },
    );
    repo = SmartPlaylistConfigRepositoryImpl(
      remote: remote,
      cache: cache,
    );
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('SmartPlaylistConfigRepository', () {
    test('fetchRootMeta returns root meta and caches it', () async {
      fakeResponses['$baseUrl/meta.json'] = jsonEncode({
        'version': 1,
        'patterns': [
          {
            'id': 'test',
            'version': 1,
            'displayName': 'Test',
            'feedUrlHint': 'test.com',
            'playlistCount': 1,
          },
        ],
      });

      final meta = await repo.fetchRootMeta();
      expect(meta.patterns, hasLength(1));

      // Cached to disk
      final cached = await cache.readRootMeta();
      expect(cached, isNotNull);
    });

    test('fetchRootMeta falls back to cache on network error', () async {
      // Pre-populate cache
      await cache.writeRootMeta(RootMeta(
        version: 1,
        patterns: [
          PatternSummary(
            id: 'cached',
            version: 1,
            displayName: 'Cached',
            feedUrlHint: 'cached.com',
            playlistCount: 1,
          ),
        ],
      ));

      // No fake responses -> network error
      final meta = await repo.fetchRootMeta();
      expect(meta.patterns[0].id, 'cached');
    });

    test('reconcileCache evicts stale patterns', () async {
      // Cache pattern at version 1
      await cache.writeVersions({'old_pattern': 1, 'current': 2});
      await cache.writePatternMeta(
        'old_pattern',
        PatternMeta(
          version: 1,
          id: 'old_pattern',
          feedUrlPatterns: [],
          playlists: ['main'],
        ),
      );

      // Reconcile with only 'current' in latest
      await repo.reconcileCache([
        PatternSummary(
          id: 'current',
          version: 2,
          displayName: 'Current',
          feedUrlHint: 'current.com',
          playlistCount: 1,
        ),
      ]);

      // old_pattern evicted
      final meta = await cache.readPatternMeta('old_pattern');
      expect(meta, isNull);
    });

    test('reconcileCache evicts version-bumped patterns', () async {
      await cache.writeVersions({'test': 1});
      await cache.writePatternMeta(
        'test',
        PatternMeta(
          version: 1,
          id: 'test',
          feedUrlPatterns: [],
          playlists: ['main'],
        ),
      );

      // Version bumped to 2
      await repo.reconcileCache([
        PatternSummary(
          id: 'test',
          version: 2,
          displayName: 'Test',
          feedUrlHint: 'test.com',
          playlistCount: 1,
        ),
      ]);

      final meta = await cache.readPatternMeta('test');
      expect(meta, isNull);
    });

    test('getConfig fetches and caches when not cached', () async {
      fakeResponses['$baseUrl/test/meta.json'] = jsonEncode({
        'version': 1,
        'id': 'test',
        'feedUrlPatterns': [r'test\.com'],
        'playlists': ['main'],
      });
      fakeResponses['$baseUrl/test/playlists/main.json'] = jsonEncode({
        'id': 'main',
        'displayName': 'Main',
        'resolverType': 'rss',
      });

      final summary = PatternSummary(
        id: 'test',
        version: 1,
        displayName: 'Test',
        feedUrlHint: 'test.com',
        playlistCount: 1,
      );

      final config = await repo.getConfig(summary);
      expect(config.id, 'test');
      expect(config.playlists, hasLength(1));
      expect(config.playlists[0].id, 'main');

      // Cached to disk
      final cachedMeta = await cache.readPatternMeta('test');
      expect(cachedMeta, isNotNull);
      final cachedPlaylist = await cache.readPlaylist('test', 'main');
      expect(cachedPlaylist, isNotNull);
    });

    test('getConfig uses cache when version matches', () async {
      // Pre-populate cache
      await cache.writeVersions({'test': 1});
      await cache.writePatternMeta(
        'test',
        PatternMeta(
          version: 1,
          id: 'test',
          feedUrlPatterns: [r'test\.com'],
          playlists: ['main'],
        ),
      );
      await cache.writePlaylist(
        'test',
        'main',
        SmartPlaylistDefinition(
          id: 'main',
          displayName: 'Main Cached',
          resolverType: 'rss',
        ),
      );

      // No fake responses -> would fail if it tried network
      final summary = PatternSummary(
        id: 'test',
        version: 1,
        displayName: 'Test',
        feedUrlHint: 'test.com',
        playlistCount: 1,
      );

      final config = await repo.getConfig(summary);
      expect(config.playlists[0].displayName, 'Main Cached');
    });

    test('findMatchingPattern returns matching summary', () async {
      final summaries = [
        PatternSummary(
          id: 'coten',
          version: 1,
          displayName: 'Coten',
          feedUrlHint: 'anchor.fm/s/8c2088c',
          playlistCount: 3,
        ),
        PatternSummary(
          id: 'other',
          version: 1,
          displayName: 'Other',
          feedUrlHint: 'other.com',
          playlistCount: 1,
        ),
      ];
      repo.setPatternSummaries(summaries);

      final match = repo.findMatchingPattern(
        null,
        'https://anchor.fm/s/8c2088c/podcast/rss',
      );
      expect(match, isNotNull);
      expect(match!.id, 'coten');
    });

    test('findMatchingPattern returns null when no match', () async {
      repo.setPatternSummaries([
        PatternSummary(
          id: 'test',
          version: 1,
          displayName: 'Test',
          feedUrlHint: 'test.com',
          playlistCount: 1,
        ),
      ]);

      final match = repo.findMatchingPattern(
        null,
        'https://unrelated.example.com/feed',
      );
      expect(match, isNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `dart test packages/audiflow_domain/test/features/feed/repositories/smart_playlist_config_repository_test.dart`
Expected: FAIL

**Step 3: Write interface**

```dart
// packages/audiflow_domain/lib/src/features/feed/repositories/smart_playlist_config_repository.dart
import '../models/pattern_summary.dart';
import '../models/root_meta.dart';
import '../models/smart_playlist_pattern_config.dart';

/// Repository for fetching and caching split SmartPlaylist configs.
abstract class SmartPlaylistConfigRepository {
  /// Fetches root meta from remote, falls back to cache on error.
  Future<RootMeta> fetchRootMeta();

  /// Returns assembled config for a pattern. Uses disk cache if
  /// version matches, otherwise fetches remotely.
  Future<SmartPlaylistPatternConfig> getConfig(PatternSummary summary);

  /// Finds matching pattern summary for a podcast.
  ///
  /// Uses `feedUrlHint` for quick pre-filtering before full regex
  /// match via the assembled config.
  PatternSummary? findMatchingPattern(
    String? podcastGuid,
    String feedUrl,
  );

  /// Evicts stale patterns based on version comparison.
  ///
  /// Removes cached patterns not in [latest] and patterns whose
  /// version has changed.
  Future<void> reconcileCache(List<PatternSummary> latest);

  /// Sets the current pattern summaries for matching.
  void setPatternSummaries(List<PatternSummary> summaries);
}
```

**Step 4: Write implementation**

```dart
// packages/audiflow_domain/lib/src/features/feed/repositories/smart_playlist_config_repository_impl.dart
import '../datasources/local/smart_playlist_cache_datasource.dart';
import '../datasources/remote/smart_playlist_remote_datasource.dart';
import '../models/pattern_summary.dart';
import '../models/root_meta.dart';
import '../models/smart_playlist_pattern_config.dart';
import '../services/config_assembler.dart';
import 'smart_playlist_config_repository.dart';

/// Implementation of [SmartPlaylistConfigRepository] with disk
/// caching, version-based invalidation, and concurrent request
/// deduplication.
class SmartPlaylistConfigRepositoryImpl
    implements SmartPlaylistConfigRepository {
  SmartPlaylistConfigRepositoryImpl({
    required SmartPlaylistRemoteDatasource remote,
    required SmartPlaylistCacheDatasource cache,
  }) : _remote = remote,
       _cache = cache;

  final SmartPlaylistRemoteDatasource _remote;
  final SmartPlaylistCacheDatasource _cache;
  final Map<String, Future<SmartPlaylistPatternConfig>> _inFlight = {};
  List<PatternSummary> _summaries = [];

  @override
  Future<RootMeta> fetchRootMeta() async {
    try {
      final meta = await _remote.fetchRootMeta();
      await _cache.writeRootMeta(meta);
      return meta;
    } catch (_) {
      // Fall back to cached root meta
      final cached = await _cache.readRootMeta();
      if (cached != null) return cached;
      // No cache and no network -> empty root meta
      return const RootMeta(version: 1, patterns: []);
    }
  }

  @override
  Future<SmartPlaylistPatternConfig> getConfig(
    PatternSummary summary,
  ) async {
    // Deduplicate concurrent requests for the same pattern
    final existing = _inFlight[summary.id];
    if (existing != null) return existing;

    final future = _getConfigInternal(summary);
    _inFlight[summary.id] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(summary.id);
    }
  }

  Future<SmartPlaylistPatternConfig> _getConfigInternal(
    PatternSummary summary,
  ) async {
    // Check if cache is fresh
    final versions = await _cache.readVersions();
    final cachedVersion = versions[summary.id];

    if (cachedVersion == summary.version) {
      // Cache hit - load from disk
      final meta = await _cache.readPatternMeta(summary.id);
      if (meta != null) {
        final playlists = <SmartPlaylistDefinition>[];
        for (final playlistId in meta.playlists) {
          final playlist = await _cache.readPlaylist(
            summary.id,
            playlistId,
          );
          if (playlist != null) {
            playlists.add(playlist);
          }
        }
        // Only use cache if all playlists were found
        if (playlists.length == meta.playlists.length) {
          return ConfigAssembler.assemble(meta, playlists);
        }
      }
    }

    // Cache miss or stale - fetch from remote
    final meta = await _remote.fetchPatternMeta(summary.id);
    await _cache.writePatternMeta(summary.id, meta);

    final playlists = <SmartPlaylistDefinition>[];
    for (final playlistId in meta.playlists) {
      final playlist = await _remote.fetchPlaylist(
        summary.id,
        playlistId,
      );
      await _cache.writePlaylist(summary.id, playlistId, playlist);
      playlists.add(playlist);
    }

    // Update version tracking
    versions[summary.id] = summary.version;
    await _cache.writeVersions(versions);

    return ConfigAssembler.assemble(meta, playlists);
  }

  @override
  PatternSummary? findMatchingPattern(
    String? podcastGuid,
    String feedUrl,
  ) {
    for (final summary in _summaries) {
      // Quick pre-filter using feedUrlHint (plain string contains)
      if (feedUrl.contains(summary.feedUrlHint)) {
        return summary;
      }
    }
    return null;
  }

  @override
  Future<void> reconcileCache(List<PatternSummary> latest) async {
    final versions = await _cache.readVersions();
    final latestMap = {for (final s in latest) s.id: s.version};

    // Evict patterns not in latest
    for (final cachedId in versions.keys.toList()) {
      if (!latestMap.containsKey(cachedId)) {
        await _cache.evictPattern(cachedId);
      }
    }

    // Evict patterns with bumped versions
    for (final summary in latest) {
      final cachedVersion = versions[summary.id];
      if (cachedVersion != null && cachedVersion != summary.version) {
        await _cache.evictPattern(summary.id);
      }
    }
  }

  @override
  void setPatternSummaries(List<PatternSummary> summaries) {
    _summaries = summaries;
  }
}
```

Need to import SmartPlaylistDefinition in the impl. Add at top of `smart_playlist_config_repository_impl.dart`:
```dart
import '../models/smart_playlist_definition.dart';
```

Add exports to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/feed/repositories/smart_playlist_config_repository.dart';
export 'src/features/feed/repositories/smart_playlist_config_repository_impl.dart';
```

**Step 4: Run test to verify it passes**

Run: `dart test packages/audiflow_domain/test/features/feed/repositories/smart_playlist_config_repository_test.dart`
Expected: PASS

**Step 5: Run all existing tests to check for regressions**

Run: `dart test packages/audiflow_domain/`
Expected: ALL PASS

**Step 6: Commit**

---

## Phase 5: FlavorConfig & Provider Integration

### Task 8: Add smartPlaylistConfigBaseUrl to FlavorConfig

**Files:**
- Modify: `packages/audiflow_core/lib/src/config/flavor_config.dart`
- Test: No test needed (configuration only)

**Step 1: Add field to FlavorConfig**

In `packages/audiflow_core/lib/src/config/flavor_config.dart`, add `smartPlaylistConfigBaseUrl` field:

- Constructor: add `required this.smartPlaylistConfigBaseUrl`
- Field: `final String smartPlaylistConfigBaseUrl;`
- dev: `smartPlaylistConfigBaseUrl: 'https://storage.googleapis.com/audiflow-dev-config'`
- stg: `smartPlaylistConfigBaseUrl: 'https://storage.googleapis.com/audiflow-dev-config'`
- prod: `smartPlaylistConfigBaseUrl: 'https://reedom.github.io/audiflow-smart-playlists'`

**Step 2: Run analyze**

Run: `dart analyze packages/audiflow_core/`
Expected: Zero errors (may have warnings about unused field until consumers are updated)

**Step 3: Commit**

---

### Task 9: Update providers for lazy loading

Replace `SmartPlaylistPatterns` provider with `PatternSummaries` provider, and wire up the repository.

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/providers/smart_playlist_providers.dart`
- Test: Existing provider tests may need updates

**Step 1: Add new providers and update existing ones**

In `smart_playlist_providers.dart`:

1. Add `SmartPlaylistConfigRepository` provider (keepAlive)
2. Replace `SmartPlaylistPatterns` with `PatternSummaries` provider
3. Update `smartPlaylistResolverServiceProvider` to no longer take patterns (resolver service stays unchanged - patterns are now loaded on-demand)
4. Update `smartPlaylistPatternByFeedUrlProvider` to use repository's `findMatchingPattern` + lazy `getConfig`
5. Update `podcastSmartPlaylistsProvider` to use repository for lazy config loading

Key changes:
- `SmartPlaylistPatterns` provider -> `PatternSummaries` provider (holds `List<PatternSummary>`)
- `smartPlaylistResolverServiceProvider` -> still provides `SmartPlaylistResolverService`, but patterns come from on-demand loading rather than pre-loaded list
- `smartPlaylistPatternByFeedUrlProvider` -> uses repository to find pattern and lazily load config

**Step 2: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

**Step 3: Run tests**

Run: `dart test packages/audiflow_domain/`
Expected: PASS (some test adjustments may be needed)

**Step 4: Commit**

---

### Task 10: Update main.dart startup flow

**Files:**
- Modify: `packages/audiflow_app/lib/main.dart`

**Step 1: Replace asset loading with remote fetch**

Replace:
```dart
final patternsJson = await rootBundle.loadString(
  'assets/smart_playlist_patterns.json',
);
final patterns = SmartPlaylistPatternLoader.parse(patternsJson);
container.read(smartPlaylistPatternsProvider.notifier).setPatterns(patterns);
```

With:
```dart
final configRepo = container.read(smartPlaylistConfigRepositoryProvider);
final rootMeta = await configRepo.fetchRootMeta();
await configRepo.reconcileCache(rootMeta.patterns);
configRepo.setPatternSummaries(rootMeta.patterns);
container.read(patternSummariesProvider.notifier).setSummaries(rootMeta.patterns);
```

**Step 2: Remove import of `SmartPlaylistPatternLoader` if no longer used**

**Step 3: Run analyze**

Run: `dart analyze packages/audiflow_app/`
Expected: Zero errors

**Step 4: Commit**

---

### Task 11: Delete bundled asset file

**Files:**
- Delete: `packages/audiflow_app/assets/smart_playlist_patterns.json`
- Modify: `packages/audiflow_app/pubspec.yaml` (remove asset declaration if present)

**Step 1: Remove the asset file**

**Step 2: Remove asset declaration from pubspec.yaml** (if `assets/smart_playlist_patterns.json` is listed)

**Step 3: Run analyze**

Run: `dart analyze packages/audiflow_app/`
Expected: Zero errors

**Step 4: Commit**

---

## Phase 6: Quality Gates

### Task 12: Format, analyze, and run full test suite

**Step 1: Format**

Run: `dart format .`

**Step 2: Analyze**

Run: `dart analyze`
Expected: Zero issues

**Step 3: Run all tests**

Run: `dart test packages/audiflow_domain/ && dart test packages/audiflow_core/`
Expected: ALL PASS

**Step 4: Create bookmark**

```bash
jj bookmark create feat/remote-smartplaylist-config
```

---

## Summary of Deliverables

| Phase | What | Files |
|-------|------|-------|
| 1 | Split-format models | PatternSummary, RootMeta, PatternMeta, ConfigAssembler |
| 2 | Cache datasource | SmartPlaylistCacheDatasource (disk I/O) |
| 3 | Remote datasource | SmartPlaylistRemoteDatasource (HTTP fetch) |
| 4 | Repository | SmartPlaylistConfigRepository interface + impl |
| 5 | Integration | FlavorConfig, providers, main.dart |
| 6 | Cleanup | Delete asset, format, analyze, test, bookmark |
