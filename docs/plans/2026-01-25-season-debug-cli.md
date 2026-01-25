# Season Debug CLI Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a pure Dart CLI tool for debugging season extraction patterns against live RSS feeds.

**Architecture:** New `audiflow_cli` package with commands for testing patterns. Uses adapter function to convert `PodcastItem` to `Episode`, diagnostic wrappers to capture extraction details, and reporters for table/JSON output.

**Tech Stack:** Dart CLI, `args` package for argument parsing, `http` package for fetching, reuses `StreamingXmlParser` from `audiflow_podcast`.

---

## Task 1: Create Package Scaffold

**Files:**
- Create: `packages/audiflow_cli/pubspec.yaml`
- Create: `packages/audiflow_cli/lib/audiflow_cli.dart`
- Create: `packages/audiflow_cli/bin/audiflow_cli.dart`
- Create: `packages/audiflow_cli/analysis_options.yaml`
- Modify: `pubspec.yaml` (workspace)

**Step 1: Create pubspec.yaml**

```yaml
# packages/audiflow_cli/pubspec.yaml
name: audiflow_cli
description: CLI tools for debugging Audiflow features
version: 0.0.1
publish_to: 'none'

environment:
  sdk: ^3.10.0

resolution: workspace

dependencies:
  audiflow_domain:
    path: ../audiflow_domain
  audiflow_podcast:
    path: ../audiflow_podcast
  args: ^2.6.0
  http: ^1.3.0

dev_dependencies:
  test: ^1.25.0
  lints: ^5.1.0
```

**Step 2: Create analysis_options.yaml**

```yaml
# packages/audiflow_cli/analysis_options.yaml
include: package:lints/recommended.yaml

linter:
  rules:
    prefer_relative_imports: true
```

**Step 3: Create library file**

```dart
// packages/audiflow_cli/lib/audiflow_cli.dart
/// CLI tools for debugging Audiflow features.
library;

export 'src/models/extraction_result.dart';
export 'src/adapters/episode_adapter.dart';
```

**Step 4: Create bin entry point (placeholder)**

```dart
// packages/audiflow_cli/bin/audiflow_cli.dart
import 'dart:io';

void main(List<String> args) {
  print('audiflow_cli - coming soon');
  exit(0);
}
```

**Step 5: Add to workspace**

Modify `pubspec.yaml` at repo root, add to workspace list:

```yaml
workspace:
  - packages/audiflow_ai
  - packages/audiflow_app
  - packages/audiflow_cli  # Add this line
  - packages/audiflow_core
  - packages/audiflow_domain
  - packages/audiflow_podcast
  - packages/audiflow_search
  - packages/audiflow_ui
```

**Step 6: Get dependencies**

Run: `cd packages/audiflow_cli && dart pub get`
Expected: Dependencies resolved successfully

**Step 7: Verify CLI runs**

Run: `dart run audiflow_cli`
Expected: Output `audiflow_cli - coming soon`

**Step 8: Commit**

```bash
git add packages/audiflow_cli pubspec.yaml
git commit -m "feat(cli): scaffold audiflow_cli package"
```

---

## Task 2: Create Extraction Result Model

**Files:**
- Create: `packages/audiflow_cli/lib/src/models/extraction_result.dart`
- Create: `packages/audiflow_cli/test/models/extraction_result_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_cli/test/models/extraction_result_test.dart
import 'package:audiflow_cli/src/models/extraction_result.dart';
import 'package:test/test.dart';

void main() {
  group('ExtractionResult', () {
    test('creates successful result', () {
      final result = ExtractionResult(
        title: 'Test Episode',
        rssSeasonNumber: 1,
        rssEpisodeNumber: 5,
        extractedTitle: 'Season 1',
        extractedEpisodeNumber: 5,
      );

      expect(result.success, isTrue);
      expect(result.diagnostics, isNull);
    });

    test('creates failed result with diagnostics', () {
      final result = ExtractionResult(
        title: 'Test Episode',
        rssSeasonNumber: null,
        rssEpisodeNumber: null,
        extractedTitle: null,
        extractedEpisodeNumber: null,
        diagnostics: ExtractionDiagnostics(
          titlePattern: r'\[(.+?)\]',
          titleMatch: null,
          error: 'pattern did not match',
        ),
      );

      expect(result.success, isFalse);
      expect(result.diagnostics, isNotNull);
      expect(result.diagnostics!.error, 'pattern did not match');
    });
  });

  group('ExtractionResult.toJson', () {
    test('serializes successful result', () {
      final result = ExtractionResult(
        title: 'Test',
        rssSeasonNumber: 1,
        rssEpisodeNumber: 2,
        extractedTitle: 'S1',
        extractedEpisodeNumber: 2,
      );

      final json = result.toJson();

      expect(json['status'], 'pass');
      expect(json['title'], 'Test');
      expect(json['rss_season'], 1);
      expect(json['extracted_title'], 'S1');
      expect(json.containsKey('diagnostics'), isFalse);
    });

    test('serializes failed result with diagnostics', () {
      final result = ExtractionResult(
        title: 'Test',
        rssSeasonNumber: null,
        rssEpisodeNumber: null,
        extractedTitle: null,
        extractedEpisodeNumber: null,
        diagnostics: ExtractionDiagnostics(
          titlePattern: r'\[(.+?)\]',
          error: 'no match',
        ),
      );

      final json = result.toJson();

      expect(json['status'], 'fail');
      expect(json['diagnostics']['title_pattern'], r'\[(.+?)\]');
      expect(json['diagnostics']['error'], 'no match');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_cli && dart test test/models/extraction_result_test.dart`
Expected: FAIL - file not found

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_cli/lib/src/models/extraction_result.dart

/// Result of running extractors on a single episode.
class ExtractionResult {
  const ExtractionResult({
    required this.title,
    required this.rssSeasonNumber,
    required this.rssEpisodeNumber,
    required this.extractedTitle,
    required this.extractedEpisodeNumber,
    this.diagnostics,
  });

  final String title;
  final int? rssSeasonNumber;
  final int? rssEpisodeNumber;
  final String? extractedTitle;
  final int? extractedEpisodeNumber;
  final ExtractionDiagnostics? diagnostics;

  /// Returns true if both title and episode number were extracted.
  bool get success => extractedTitle != null && diagnostics == null;

  /// Converts to JSON for --json output.
  Map<String, dynamic> toJson() {
    return {
      'status': success ? 'pass' : 'fail',
      'title': title,
      'rss_season': rssSeasonNumber,
      'rss_episode': rssEpisodeNumber,
      'extracted_title': extractedTitle,
      'extracted_episode': extractedEpisodeNumber,
      if (diagnostics != null) 'diagnostics': diagnostics!.toJson(),
    };
  }
}

/// Diagnostic information for failed extractions.
class ExtractionDiagnostics {
  const ExtractionDiagnostics({
    this.titlePattern,
    this.titleMatch,
    this.episodePattern,
    this.episodeMatch,
    this.fallbackValue,
    this.fallbackConditionMet,
    required this.error,
  });

  final String? titlePattern;
  final String? titleMatch;
  final String? episodePattern;
  final String? episodeMatch;
  final String? fallbackValue;
  final bool? fallbackConditionMet;
  final String error;

  Map<String, dynamic> toJson() {
    return {
      if (titlePattern != null) 'title_pattern': titlePattern,
      if (titleMatch != null) 'title_match': titleMatch,
      if (episodePattern != null) 'episode_pattern': episodePattern,
      if (episodeMatch != null) 'episode_match': episodeMatch,
      if (fallbackValue != null) 'fallback_value': fallbackValue,
      if (fallbackConditionMet != null)
        'fallback_condition_met': fallbackConditionMet,
      'error': error,
    };
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_cli && dart test test/models/extraction_result_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add packages/audiflow_cli/lib/src/models packages/audiflow_cli/test/models
git commit -m "feat(cli): add ExtractionResult model"
```

---

## Task 3: Create Episode Adapter

**Files:**
- Create: `packages/audiflow_cli/lib/src/adapters/episode_adapter.dart`
- Create: `packages/audiflow_cli/test/adapters/episode_adapter_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_cli/test/adapters/episode_adapter_test.dart
import 'package:audiflow_cli/src/adapters/episode_adapter.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:test/test.dart';

void main() {
  group('toEpisode', () {
    test('converts PodcastItem to Episode with all fields', () {
      final item = PodcastItem(
        parsedAt: DateTime(2024, 1, 1),
        sourceUrl: 'https://example.com/feed',
        title: '【62-15】Test Episode【COTEN RADIO リンカン編15】',
        description: 'Episode description',
        guid: 'guid-123',
        enclosureUrl: 'https://example.com/audio.mp3',
        seasonNumber: 62,
        episodeNumber: 15,
        publishDate: DateTime(2024, 1, 15),
      );

      final episode = toEpisode(item);

      expect(episode.title, item.title);
      expect(episode.description, item.description);
      expect(episode.guid, 'guid-123');
      expect(episode.audioUrl, 'https://example.com/audio.mp3');
      expect(episode.seasonNumber, 62);
      expect(episode.episodeNumber, 15);
      expect(episode.publishedAt, DateTime(2024, 1, 15));
    });

    test('handles null optional fields', () {
      final item = PodcastItem(
        parsedAt: DateTime(2024, 1, 1),
        sourceUrl: 'https://example.com/feed',
        title: '【番外編＃135】Test',
        description: '',
        guid: null,
        enclosureUrl: null,
        seasonNumber: null,
        episodeNumber: 135,
        publishDate: null,
      );

      final episode = toEpisode(item);

      expect(episode.title, '【番外編＃135】Test');
      expect(episode.guid, '');
      expect(episode.audioUrl, '');
      expect(episode.seasonNumber, isNull);
      expect(episode.episodeNumber, 135);
      expect(episode.publishedAt, isNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_cli && dart test test/adapters/episode_adapter_test.dart`
Expected: FAIL - file not found

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_cli/lib/src/adapters/episode_adapter.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';

/// Converts a [PodcastItem] from RSS parsing to an [Episode] for extractors.
///
/// Stub values are used for database-only fields (id, podcastId).
Episode toEpisode(PodcastItem item) {
  return Episode(
    id: 0,
    podcastId: 0,
    guid: item.guid ?? '',
    title: item.title,
    audioUrl: item.enclosureUrl ?? '',
    description: item.description.isEmpty ? null : item.description,
    seasonNumber: item.seasonNumber,
    episodeNumber: item.episodeNumber,
    publishedAt: item.publishDate,
  );
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_cli && dart test test/adapters/episode_adapter_test.dart`
Expected: All tests pass

**Step 5: Update exports**

Update `packages/audiflow_cli/lib/audiflow_cli.dart`:

```dart
/// CLI tools for debugging Audiflow features.
library;

export 'src/adapters/episode_adapter.dart';
export 'src/models/extraction_result.dart';
```

**Step 6: Commit**

```bash
git add packages/audiflow_cli/lib/src/adapters packages/audiflow_cli/test/adapters packages/audiflow_cli/lib/audiflow_cli.dart
git commit -m "feat(cli): add episode adapter for PodcastItem to Episode conversion"
```

---

## Task 4: Create Title Extractor Diagnostics

**Files:**
- Create: `packages/audiflow_cli/lib/src/diagnostics/title_extractor_diagnostics.dart`
- Create: `packages/audiflow_cli/test/diagnostics/title_extractor_diagnostics_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_cli/test/diagnostics/title_extractor_diagnostics_test.dart
import 'package:audiflow_cli/src/diagnostics/title_extractor_diagnostics.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:test/test.dart';

Episode _makeEpisode({
  required String title,
  int? seasonNumber,
  int? episodeNumber,
}) {
  return Episode(
    id: 0,
    podcastId: 0,
    guid: 'guid',
    title: title,
    audioUrl: 'https://example.com/audio.mp3',
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
  );
}

void main() {
  group('TitleExtractorDiagnostics', () {
    test('returns fallbackValue result when seasonNumber is null', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'【COTEN RADIO (.+?)\d+】',
        group: 1,
        fallbackValue: '番外編',
      );

      final diagnostics = TitleExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(title: '【番外編＃135】Test', seasonNumber: null),
      );

      expect(result.extractedValue, '番外編');
      expect(result.fallbackValue, '番外編');
      expect(result.fallbackConditionMet, isTrue);
      expect(result.error, isNull);
    });

    test('returns pattern match result for positive seasonNumber', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'【COTEN RADIO (ショート)?\s*(.+?)\s*\d+】',
        group: 2,
        fallbackValue: '番外編',
      );

      final diagnostics = TitleExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '【62-15】何が変わった?【COTEN RADIO リンカン編15】',
          seasonNumber: 62,
        ),
      );

      expect(result.extractedValue, 'リンカン編');
      expect(result.patternUsed, r'【COTEN RADIO (ショート)?\s*(.+?)\s*\d+】');
      expect(result.matchResult, 'リンカン編');
      expect(result.error, isNull);
    });

    test('returns error when pattern does not match', () {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: r'【COTEN RADIO (.+?)\d+】',
        group: 1,
      );

      final diagnostics = TitleExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(title: '【特別編】ゲスト回', seasonNumber: 99),
      );

      expect(result.extractedValue, isNull);
      expect(result.error, isNotNull);
      expect(result.error, contains('pattern did not match'));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_cli && dart test test/diagnostics/title_extractor_diagnostics_test.dart`
Expected: FAIL - file not found

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_cli/lib/src/diagnostics/title_extractor_diagnostics.dart
import 'package:audiflow_domain/audiflow_domain.dart';

/// Diagnostic result from running title extraction.
class TitleDiagnosticResult {
  const TitleDiagnosticResult({
    this.extractedValue,
    this.patternUsed,
    this.matchResult,
    this.fallbackValue,
    this.fallbackConditionMet,
    this.error,
  });

  final String? extractedValue;
  final String? patternUsed;
  final String? matchResult;
  final String? fallbackValue;
  final bool? fallbackConditionMet;
  final String? error;
}

/// Wraps [SeasonTitleExtractor] to capture diagnostic information.
class TitleExtractorDiagnostics {
  const TitleExtractorDiagnostics(this.extractor);

  final SeasonTitleExtractor extractor;

  /// Runs extraction and captures diagnostic details.
  TitleDiagnosticResult run(Episode episode) {
    final seasonNum = episode.seasonNumber;

    // Step 1: Check fallbackValue condition
    if (extractor.fallbackValue != null &&
        (seasonNum == null || 1 > seasonNum)) {
      return TitleDiagnosticResult(
        extractedValue: extractor.fallbackValue,
        fallbackValue: extractor.fallbackValue,
        fallbackConditionMet: true,
      );
    }

    // Step 2: Get source value
    final sourceValue = _getSourceValue(episode);
    if (sourceValue == null) {
      return TitleDiagnosticResult(
        error: 'source "${extractor.source}" returned null',
      );
    }

    // Step 3: Try pattern match
    if (extractor.pattern != null) {
      final regex = RegExp(extractor.pattern!);
      final match = regex.firstMatch(sourceValue);

      if (match == null) {
        return TitleDiagnosticResult(
          patternUsed: extractor.pattern,
          error: 'pattern did not match title: "$sourceValue"',
        );
      }

      final groupValue = extractor.group == 0
          ? match.group(0)
          : (extractor.group <= match.groupCount
              ? match.group(extractor.group)
              : null);

      if (groupValue == null) {
        return TitleDiagnosticResult(
          patternUsed: extractor.pattern,
          matchResult: match.group(0),
          error: 'capture group ${extractor.group} not found',
        );
      }

      var result = groupValue;
      if (extractor.template != null) {
        result = extractor.template!.replaceAll('{value}', result);
      }

      return TitleDiagnosticResult(
        extractedValue: result,
        patternUsed: extractor.pattern,
        matchResult: groupValue,
      );
    }

    // No pattern - use source directly
    var result = sourceValue;
    if (extractor.template != null) {
      result = extractor.template!.replaceAll('{value}', result);
    }

    return TitleDiagnosticResult(extractedValue: result);
  }

  String? _getSourceValue(Episode episode) {
    return switch (extractor.source) {
      'title' => episode.title,
      'description' => episode.description,
      'seasonNumber' => episode.seasonNumber?.toString(),
      'episodeNumber' => episode.episodeNumber?.toString(),
      _ => null,
    };
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_cli && dart test test/diagnostics/title_extractor_diagnostics_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add packages/audiflow_cli/lib/src/diagnostics packages/audiflow_cli/test/diagnostics
git commit -m "feat(cli): add TitleExtractorDiagnostics for detailed extraction info"
```

---

## Task 5: Create Episode Number Extractor Diagnostics

**Files:**
- Create: `packages/audiflow_cli/lib/src/diagnostics/episode_extractor_diagnostics.dart`
- Create: `packages/audiflow_cli/test/diagnostics/episode_extractor_diagnostics_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_cli/test/diagnostics/episode_extractor_diagnostics_test.dart
import 'package:audiflow_cli/src/diagnostics/episode_extractor_diagnostics.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:test/test.dart';

Episode _makeEpisode({
  required String title,
  int? seasonNumber,
  int? episodeNumber,
}) {
  return Episode(
    id: 0,
    podcastId: 0,
    guid: 'guid',
    title: title,
    audioUrl: 'https://example.com/audio.mp3',
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
  );
}

void main() {
  group('EpisodeExtractorDiagnostics', () {
    test('returns RSS episodeNumber for null seasonNumber', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final diagnostics = EpisodeExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '【番外編＃135】Test',
          seasonNumber: null,
          episodeNumber: 135,
        ),
      );

      expect(result.extractedValue, 135);
      expect(result.usedRssFallback, isTrue);
      expect(result.error, isNull);
    });

    test('extracts from title pattern for positive seasonNumber', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'(\d+)】',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final diagnostics = EpisodeExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '【62-15】何が変わった?【COTEN RADIO リンカン編15】',
          seasonNumber: 62,
          episodeNumber: 999,
        ),
      );

      expect(result.extractedValue, 15);
      expect(result.patternUsed, r'(\d+)】');
      expect(result.matchResult, '15');
      expect(result.usedRssFallback, isFalse);
    });

    test('falls back to RSS when pattern fails', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'EP(\d+)',
        captureGroup: 1,
        fallbackToRss: true,
      );

      final diagnostics = EpisodeExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '【特別編】Test',
          seasonNumber: 99,
          episodeNumber: 42,
        ),
      );

      expect(result.extractedValue, 42);
      expect(result.usedRssFallback, isTrue);
    });

    test('returns error when pattern fails and no RSS fallback', () {
      final extractor = EpisodeNumberExtractor(
        pattern: r'EP(\d+)',
        captureGroup: 1,
        fallbackToRss: false,
      );

      final diagnostics = EpisodeExtractorDiagnostics(extractor);
      final result = diagnostics.run(
        _makeEpisode(
          title: '【特別編】Test',
          seasonNumber: 99,
          episodeNumber: null,
        ),
      );

      expect(result.extractedValue, isNull);
      expect(result.error, isNotNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_cli && dart test test/diagnostics/episode_extractor_diagnostics_test.dart`
Expected: FAIL - file not found

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_cli/lib/src/diagnostics/episode_extractor_diagnostics.dart
import 'package:audiflow_domain/audiflow_domain.dart';

/// Diagnostic result from running episode number extraction.
class EpisodeDiagnosticResult {
  const EpisodeDiagnosticResult({
    this.extractedValue,
    this.patternUsed,
    this.matchResult,
    this.usedRssFallback = false,
    this.error,
  });

  final int? extractedValue;
  final String? patternUsed;
  final String? matchResult;
  final bool usedRssFallback;
  final String? error;
}

/// Wraps [EpisodeNumberExtractor] to capture diagnostic information.
class EpisodeExtractorDiagnostics {
  const EpisodeExtractorDiagnostics(this.extractor);

  final EpisodeNumberExtractor extractor;

  /// Runs extraction and captures diagnostic details.
  EpisodeDiagnosticResult run(Episode episode) {
    final seasonNum = episode.seasonNumber;

    // Step 1: For null/zero seasonNumber, use RSS episodeNumber directly
    if (seasonNum == null || 1 > seasonNum) {
      return EpisodeDiagnosticResult(
        extractedValue: episode.episodeNumber,
        usedRssFallback: true,
      );
    }

    // Step 2: Try regex extraction from title
    final regex = RegExp(extractor.pattern);
    final match = regex.firstMatch(episode.title);

    if (match != null && extractor.captureGroup <= match.groupCount) {
      final captured = match.group(extractor.captureGroup);
      if (captured != null) {
        final parsed = int.tryParse(captured);
        if (parsed != null) {
          return EpisodeDiagnosticResult(
            extractedValue: parsed,
            patternUsed: extractor.pattern,
            matchResult: captured,
          );
        }
      }
    }

    // Step 3: Fall back to RSS episodeNumber if enabled
    if (extractor.fallbackToRss && episode.episodeNumber != null) {
      return EpisodeDiagnosticResult(
        extractedValue: episode.episodeNumber,
        patternUsed: extractor.pattern,
        usedRssFallback: true,
      );
    }

    // Step 4: No match, no fallback
    return EpisodeDiagnosticResult(
      patternUsed: extractor.pattern,
      error:
          'pattern did not match and fallbackToRss=${extractor.fallbackToRss}',
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_cli && dart test test/diagnostics/episode_extractor_diagnostics_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add packages/audiflow_cli/lib/src/diagnostics/episode_extractor_diagnostics.dart packages/audiflow_cli/test/diagnostics/episode_extractor_diagnostics_test.dart
git commit -m "feat(cli): add EpisodeExtractorDiagnostics"
```

---

## Task 6: Create Table Reporter

**Files:**
- Create: `packages/audiflow_cli/lib/src/reporters/table_reporter.dart`
- Create: `packages/audiflow_cli/test/reporters/table_reporter_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_cli/test/reporters/table_reporter_test.dart
import 'package:audiflow_cli/src/models/extraction_result.dart';
import 'package:audiflow_cli/src/reporters/table_reporter.dart';
import 'package:test/test.dart';

void main() {
  group('TableReporter', () {
    late TableReporter reporter;
    late StringBuffer output;

    setUp(() {
      output = StringBuffer();
      reporter = TableReporter(output);
    });

    test('formats passing result as single line', () {
      final result = ExtractionResult(
        title: '【62-15】Test【COTEN RADIO リンカン編15】',
        rssSeasonNumber: 62,
        rssEpisodeNumber: null,
        extractedTitle: 'リンカン編',
        extractedEpisodeNumber: 15,
      );

      reporter.writeResult(result);

      expect(output.toString(), contains('PASS'));
      expect(output.toString(), contains('S62'));
      expect(output.toString(), contains('title="リンカン編"'));
      expect(output.toString(), contains('ep=15'));
    });

    test('formats failing result with diagnostics', () {
      final result = ExtractionResult(
        title: '【特別編】ゲスト回',
        rssSeasonNumber: null,
        rssEpisodeNumber: null,
        extractedTitle: null,
        extractedEpisodeNumber: null,
        diagnostics: ExtractionDiagnostics(
          titlePattern: r'【COTEN RADIO (.+?)\d+】',
          error: 'pattern did not match',
        ),
      );

      reporter.writeResult(result);

      final text = output.toString();
      expect(text, contains('FAIL'));
      expect(text, contains('title_pattern:'));
      expect(text, contains('error:'));
    });

    test('writes summary with counts and percentages', () {
      reporter.writeSummary(total: 100, passed: 95, failed: 5);

      final text = output.toString();
      expect(text, contains('Total: 100'));
      expect(text, contains('Pass:'));
      expect(text, contains('95'));
      expect(text, contains('95.0%'));
      expect(text, contains('Fail:'));
      expect(text, contains('5'));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_cli && dart test test/reporters/table_reporter_test.dart`
Expected: FAIL - file not found

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_cli/lib/src/reporters/table_reporter.dart
import '../models/extraction_result.dart';

/// Formats extraction results as a human-readable table.
class TableReporter {
  TableReporter([StringSink? sink]) : _sink = sink ?? StringBuffer();

  final StringSink _sink;

  /// Writes the header with feed URL and pattern info.
  void writeHeader({
    required String feedUrl,
    required String? patternId,
    required int episodeCount,
  }) {
    _sink.writeln('Fetching: $feedUrl');
    _sink.writeln(
      'Pattern:  ${patternId ?? "(none)"}'
      '${patternId != null ? " (auto-detected)" : ""}',
    );
    _sink.writeln('Episodes: $episodeCount');
    _sink.writeln();
  }

  /// Writes a single extraction result.
  void writeResult(ExtractionResult result) {
    final season = result.rssSeasonNumber != null
        ? 'S${result.rssSeasonNumber}'.padRight(4)
        : 'null'.padRight(4);
    final episode = result.rssEpisodeNumber != null
        ? 'E${result.rssEpisodeNumber}'.padRight(4)
        : 'null'.padRight(4);

    final truncatedTitle = _truncate(result.title, 40);

    if (result.success) {
      _sink.writeln(
        'PASS | $season | $episode | $truncatedTitle | '
        'title="${result.extractedTitle}" ep=${result.extractedEpisodeNumber}',
      );
    } else {
      _sink.writeln('FAIL | $season | $episode | $truncatedTitle');
      _writeDiagnostics(result.diagnostics!);
    }
  }

  void _writeDiagnostics(ExtractionDiagnostics d) {
    const indent = '     |      |      |   ';
    if (d.titlePattern != null) {
      _sink.writeln('${indent}title_pattern: ${d.titlePattern}');
    }
    if (d.titleMatch != null) {
      _sink.writeln('${indent}title_match: ${d.titleMatch}');
    } else if (d.titlePattern != null) {
      _sink.writeln('${indent}title_match: none');
    }
    if (d.fallbackValue != null) {
      _sink.writeln('${indent}fallback_value: "${d.fallbackValue}"');
    }
    if (d.fallbackConditionMet != null) {
      final met = d.fallbackConditionMet! ? '✓' : '✗';
      _sink.writeln('${indent}fallback_condition: $met');
    }
    _sink.writeln('${indent}error: ${d.error}');
  }

  /// Writes summary statistics.
  void writeSummary({
    required int total,
    required int passed,
    required int failed,
  }) {
    final passPercent = total > 0 ? (passed / total * 100).toStringAsFixed(1) : '0.0';
    final failPercent = total > 0 ? (failed / total * 100).toStringAsFixed(1) : '0.0';

    _sink.writeln();
    _sink.writeln('--- Summary ---');
    _sink.writeln('Total: $total');
    _sink.writeln('Pass:  $passed ($passPercent%)');
    _sink.writeln('Fail:  $failed ($failPercent%)');
  }

  String _truncate(String s, int maxLen) {
    if (s.length <= maxLen) return s.padRight(maxLen);
    return '${s.substring(0, maxLen - 3)}...';
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_cli && dart test test/reporters/table_reporter_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add packages/audiflow_cli/lib/src/reporters packages/audiflow_cli/test/reporters
git commit -m "feat(cli): add TableReporter for human-readable output"
```

---

## Task 7: Create JSON Reporter

**Files:**
- Create: `packages/audiflow_cli/lib/src/reporters/json_reporter.dart`
- Create: `packages/audiflow_cli/test/reporters/json_reporter_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_cli/test/reporters/json_reporter_test.dart
import 'dart:convert';

import 'package:audiflow_cli/src/models/extraction_result.dart';
import 'package:audiflow_cli/src/reporters/json_reporter.dart';
import 'package:test/test.dart';

void main() {
  group('JsonReporter', () {
    late JsonReporter reporter;
    late StringBuffer output;

    setUp(() {
      output = StringBuffer();
      reporter = JsonReporter(output);
    });

    test('outputs valid JSON with all fields', () {
      reporter.start(feedUrl: 'https://example.com/feed', patternId: 'test');

      reporter.addResult(
        ExtractionResult(
          title: 'Test Episode',
          rssSeasonNumber: 1,
          rssEpisodeNumber: 5,
          extractedTitle: 'Season 1',
          extractedEpisodeNumber: 5,
        ),
      );

      reporter.finish(total: 1, passed: 1, failed: 0);

      final json = jsonDecode(output.toString()) as Map<String, dynamic>;

      expect(json['feed_url'], 'https://example.com/feed');
      expect(json['pattern_id'], 'test');
      expect(json['results'], hasLength(1));
      expect(json['results'][0]['status'], 'pass');
      expect(json['summary']['total'], 1);
      expect(json['summary']['pass'], 1);
    });

    test('includes diagnostics for failed results', () {
      reporter.start(feedUrl: 'https://example.com/feed', patternId: null);

      reporter.addResult(
        ExtractionResult(
          title: 'Failed Episode',
          rssSeasonNumber: null,
          rssEpisodeNumber: null,
          extractedTitle: null,
          extractedEpisodeNumber: null,
          diagnostics: ExtractionDiagnostics(
            titlePattern: r'\[(.+?)\]',
            error: 'no match',
          ),
        ),
      );

      reporter.finish(total: 1, passed: 0, failed: 1);

      final json = jsonDecode(output.toString()) as Map<String, dynamic>;
      final result = json['results'][0] as Map<String, dynamic>;

      expect(result['status'], 'fail');
      expect(result['diagnostics']['error'], 'no match');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_cli && dart test test/reporters/json_reporter_test.dart`
Expected: FAIL - file not found

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_cli/lib/src/reporters/json_reporter.dart
import 'dart:convert';

import '../models/extraction_result.dart';

/// Formats extraction results as JSON.
class JsonReporter {
  JsonReporter([StringSink? sink]) : _sink = sink ?? StringBuffer();

  final StringSink _sink;
  final List<Map<String, dynamic>> _results = [];
  String? _feedUrl;
  String? _patternId;

  /// Starts the report with metadata.
  void start({required String feedUrl, required String? patternId}) {
    _feedUrl = feedUrl;
    _patternId = patternId;
    _results.clear();
  }

  /// Adds a result to the report.
  void addResult(ExtractionResult result) {
    _results.add(result.toJson());
  }

  /// Finishes the report and writes to sink.
  void finish({
    required int total,
    required int passed,
    required int failed,
  }) {
    final output = {
      'feed_url': _feedUrl,
      'pattern_id': _patternId,
      'results': _results,
      'summary': {
        'total': total,
        'pass': passed,
        'fail': failed,
      },
    };

    _sink.write(const JsonEncoder.withIndent('  ').convert(output));
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_cli && dart test test/reporters/json_reporter_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add packages/audiflow_cli/lib/src/reporters/json_reporter.dart packages/audiflow_cli/test/reporters/json_reporter_test.dart
git commit -m "feat(cli): add JsonReporter for machine-readable output"
```

---

## Task 8: Create Pattern Registry

**Files:**
- Create: `packages/audiflow_cli/lib/src/patterns/pattern_registry.dart`
- Create: `packages/audiflow_cli/test/patterns/pattern_registry_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_cli/test/patterns/pattern_registry_test.dart
import 'package:audiflow_cli/src/patterns/pattern_registry.dart';
import 'package:test/test.dart';

void main() {
  group('PatternRegistry', () {
    test('contains coten_radio pattern', () {
      final registry = PatternRegistry();

      expect(registry.patterns, isNotEmpty);
      expect(registry.findById('coten_radio'), isNotNull);
    });

    test('detects pattern from feed URL', () {
      final registry = PatternRegistry();

      final pattern = registry.detectFromUrl(
        'https://anchor.fm/s/8c2088c/podcast/rss',
      );

      expect(pattern, isNotNull);
      expect(pattern!.id, 'coten_radio');
    });

    test('returns null for unknown feed URL', () {
      final registry = PatternRegistry();

      final pattern = registry.detectFromUrl('https://example.com/unknown');

      expect(pattern, isNull);
    });

    test('lists all patterns with metadata', () {
      final registry = PatternRegistry();

      final list = registry.listPatterns();

      expect(list, isNotEmpty);
      expect(list.first.id, isNotEmpty);
      expect(list.first.feedUrlPatterns, isNotEmpty);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_cli && dart test test/patterns/pattern_registry_test.dart`
Expected: FAIL - file not found

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_cli/lib/src/patterns/pattern_registry.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/feed/patterns/coten_radio_pattern.dart';

/// Registry of all available season patterns.
class PatternRegistry {
  /// All registered patterns.
  List<SeasonPattern> get patterns => [cotenRadioPattern];

  /// Finds a pattern by its ID.
  SeasonPattern? findById(String id) {
    for (final pattern in patterns) {
      if (pattern.id == id) {
        return pattern;
      }
    }
    return null;
  }

  /// Detects a pattern from a feed URL.
  SeasonPattern? detectFromUrl(String feedUrl) {
    for (final pattern in patterns) {
      if (pattern.matchesPodcast(null, feedUrl)) {
        return pattern;
      }
    }
    return null;
  }

  /// Lists all patterns with their metadata.
  List<SeasonPattern> listPatterns() => patterns;
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_cli && dart test test/patterns/pattern_registry_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add packages/audiflow_cli/lib/src/patterns packages/audiflow_cli/test/patterns
git commit -m "feat(cli): add PatternRegistry for pattern lookup"
```

---

## Task 9: Create Pattern List Command

**Files:**
- Create: `packages/audiflow_cli/lib/src/commands/pattern_list_command.dart`
- Create: `packages/audiflow_cli/test/commands/pattern_list_command_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_cli/test/commands/pattern_list_command_test.dart
import 'package:audiflow_cli/src/commands/pattern_list_command.dart';
import 'package:test/test.dart';

void main() {
  group('PatternListCommand', () {
    test('lists all patterns with id and URL', () {
      final output = StringBuffer();
      final command = PatternListCommand(output);

      final exitCode = command.run();

      expect(exitCode, 0);
      expect(output.toString(), contains('coten_radio'));
      expect(output.toString(), contains('anchor.fm'));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_cli && dart test test/commands/pattern_list_command_test.dart`
Expected: FAIL - file not found

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_cli/lib/src/commands/pattern_list_command.dart
import '../patterns/pattern_registry.dart';

/// Command to list all available patterns.
class PatternListCommand {
  PatternListCommand([StringSink? sink])
      : _sink = sink ?? StringBuffer(),
        _registry = PatternRegistry();

  final StringSink _sink;
  final PatternRegistry _registry;

  /// Runs the command and returns exit code.
  int run() {
    final patterns = _registry.listPatterns();

    if (patterns.isEmpty) {
      _sink.writeln('No patterns registered.');
      return 0;
    }

    _sink.writeln('Available patterns:');
    _sink.writeln();

    for (final pattern in patterns) {
      final urls = pattern.feedUrlPatterns?.join(', ') ?? '(no URL patterns)';
      _sink.writeln('  ${pattern.id.padRight(20)} $urls');
    }

    return 0;
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_cli && dart test test/commands/pattern_list_command_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add packages/audiflow_cli/lib/src/commands packages/audiflow_cli/test/commands
git commit -m "feat(cli): add pattern-list command"
```

---

## Task 10: Create Pattern Test Command

**Files:**
- Create: `packages/audiflow_cli/lib/src/commands/pattern_test_command.dart`
- Create: `packages/audiflow_cli/test/commands/pattern_test_command_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_cli/test/commands/pattern_test_command_test.dart
import 'package:audiflow_cli/src/commands/pattern_test_command.dart';
import 'package:test/test.dart';

void main() {
  group('PatternTestCommand', () {
    test('extracts title from pattern match', () {
      final output = StringBuffer();
      final command = PatternTestCommand(output);

      final exitCode = command.run(
        title: '【62-15】Test【COTEN RADIO リンカン編15】',
        titlePattern: r'【COTEN RADIO (ショート)?\s*(.+?)\s*\d+】',
        titleGroup: 2,
        episodePattern: r'(\d+)】',
        seasonNumber: 62,
      );

      expect(exitCode, 0);
      expect(output.toString(), contains('リンカン編'));
      expect(output.toString(), contains('15'));
    });

    test('reports error when pattern does not match', () {
      final output = StringBuffer();
      final command = PatternTestCommand(output);

      final exitCode = command.run(
        title: '【特別編】Test',
        titlePattern: r'【COTEN RADIO (.+?)\d+】',
        titleGroup: 1,
        episodePattern: null,
        seasonNumber: 99,
      );

      expect(exitCode, 1);
      expect(output.toString().toLowerCase(), contains('error'));
    });

    test('uses fallback for null seasonNumber', () {
      final output = StringBuffer();
      final command = PatternTestCommand(output);

      final exitCode = command.run(
        title: '【番外編＃135】Test',
        titlePattern: r'【COTEN RADIO (.+?)\d+】',
        titleGroup: 1,
        titleFallback: '番外編',
        episodePattern: null,
        seasonNumber: null,
        episodeNumber: 135,
      );

      expect(exitCode, 0);
      expect(output.toString(), contains('番外編'));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_cli && dart test test/commands/pattern_test_command_test.dart`
Expected: FAIL - file not found

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_cli/lib/src/commands/pattern_test_command.dart
import 'package:audiflow_domain/audiflow_domain.dart';

import '../adapters/episode_adapter.dart';
import '../diagnostics/episode_extractor_diagnostics.dart';
import '../diagnostics/title_extractor_diagnostics.dart';

/// Command to test pattern extraction against a single title.
class PatternTestCommand {
  PatternTestCommand([StringSink? sink]) : _sink = sink ?? StringBuffer();

  final StringSink _sink;

  /// Runs the command and returns exit code.
  int run({
    required String title,
    required String? titlePattern,
    int titleGroup = 1,
    String? titleFallback,
    String? episodePattern,
    int episodeCaptureGroup = 1,
    int? seasonNumber,
    int? episodeNumber,
  }) {
    // Create a fake Episode for testing
    final episode = Episode(
      id: 0,
      podcastId: 0,
      guid: 'test',
      title: title,
      audioUrl: '',
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );

    _sink.writeln('Input:');
    _sink.writeln('  title: $title');
    _sink.writeln('  seasonNumber: $seasonNumber');
    _sink.writeln('  episodeNumber: $episodeNumber');
    _sink.writeln();

    var hasError = false;

    // Test title extraction
    if (titlePattern != null || titleFallback != null) {
      final extractor = SeasonTitleExtractor(
        source: 'title',
        pattern: titlePattern,
        group: titleGroup,
        fallbackValue: titleFallback,
      );

      final diagnostics = TitleExtractorDiagnostics(extractor);
      final result = diagnostics.run(episode);

      _sink.writeln('Title Extraction:');
      if (result.extractedValue != null) {
        _sink.writeln('  result: ${result.extractedValue}');
        if (result.fallbackConditionMet == true) {
          _sink.writeln('  (used fallback)');
        } else if (result.matchResult != null) {
          _sink.writeln('  match: ${result.matchResult}');
        }
      } else {
        _sink.writeln('  ERROR: ${result.error}');
        hasError = true;
      }
      _sink.writeln();
    }

    // Test episode number extraction
    if (episodePattern != null) {
      final extractor = EpisodeNumberExtractor(
        pattern: episodePattern,
        captureGroup: episodeCaptureGroup,
        fallbackToRss: true,
      );

      final diagnostics = EpisodeExtractorDiagnostics(extractor);
      final result = diagnostics.run(episode);

      _sink.writeln('Episode Number Extraction:');
      if (result.extractedValue != null) {
        _sink.writeln('  result: ${result.extractedValue}');
        if (result.usedRssFallback) {
          _sink.writeln('  (used RSS fallback)');
        } else if (result.matchResult != null) {
          _sink.writeln('  match: ${result.matchResult}');
        }
      } else {
        _sink.writeln('  ERROR: ${result.error}');
        hasError = true;
      }
    }

    return hasError ? 1 : 0;
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_cli && dart test test/commands/pattern_test_command_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add packages/audiflow_cli/lib/src/commands/pattern_test_command.dart packages/audiflow_cli/test/commands/pattern_test_command_test.dart
git commit -m "feat(cli): add pattern-test command"
```

---

## Task 11: Create Season Debug Command

**Files:**
- Create: `packages/audiflow_cli/lib/src/commands/season_debug_command.dart`
- Create: `packages/audiflow_cli/test/commands/season_debug_command_test.dart`

**Step 1: Write the failing test**

```dart
// packages/audiflow_cli/test/commands/season_debug_command_test.dart
import 'package:audiflow_cli/src/commands/season_debug_command.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:test/test.dart';

void main() {
  group('SeasonDebugCommand', () {
    test('processes items and reports results', () async {
      final output = StringBuffer();
      final command = SeasonDebugCommand(output);

      // Create mock items
      final items = [
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title: '【62-15】Test【COTEN RADIO リンカン編15】',
          description: '',
          seasonNumber: 62,
          episodeNumber: null,
        ),
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title: '【番外編＃135】Test',
          description: '',
          seasonNumber: null,
          episodeNumber: 135,
        ),
      ];

      final exitCode = await command.runWithItems(
        feedUrl: 'https://anchor.fm/s/8c2088c/podcast/rss',
        items: items,
        json: false,
      );

      expect(exitCode, 0);
      final text = output.toString();
      expect(text, contains('PASS'));
      expect(text, contains('リンカン編'));
      expect(text, contains('番外編'));
      expect(text, contains('Summary'));
    });

    test('returns exit code 1 when extractions fail', () async {
      final output = StringBuffer();
      final command = SeasonDebugCommand(output);

      final items = [
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title: '【特別編】Unknown format',
          description: '',
          seasonNumber: 99,
          episodeNumber: null,
        ),
      ];

      final exitCode = await command.runWithItems(
        feedUrl: 'https://anchor.fm/s/8c2088c/podcast/rss',
        items: items,
        json: false,
      );

      expect(exitCode, 1);
      expect(output.toString(), contains('FAIL'));
    });

    test('outputs JSON when requested', () async {
      final output = StringBuffer();
      final command = SeasonDebugCommand(output);

      final items = [
        PodcastItem(
          parsedAt: DateTime.now(),
          sourceUrl: 'https://example.com/feed',
          title: '【62-15】Test【COTEN RADIO リンカン編15】',
          description: '',
          seasonNumber: 62,
          episodeNumber: null,
        ),
      ];

      await command.runWithItems(
        feedUrl: 'https://anchor.fm/s/8c2088c/podcast/rss',
        items: items,
        json: true,
      );

      final text = output.toString();
      expect(text, contains('"feed_url"'));
      expect(text, contains('"results"'));
      expect(text, contains('"status": "pass"'));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_cli && dart test test/commands/season_debug_command_test.dart`
Expected: FAIL - file not found

**Step 3: Write minimal implementation**

```dart
// packages/audiflow_cli/lib/src/commands/season_debug_command.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:http/http.dart' as http;

import '../adapters/episode_adapter.dart';
import '../diagnostics/episode_extractor_diagnostics.dart';
import '../diagnostics/title_extractor_diagnostics.dart';
import '../models/extraction_result.dart';
import '../patterns/pattern_registry.dart';
import '../reporters/json_reporter.dart';
import '../reporters/table_reporter.dart';

/// Command to debug season extraction against a live RSS feed.
class SeasonDebugCommand {
  SeasonDebugCommand([StringSink? sink])
      : _sink = sink ?? StringBuffer(),
        _registry = PatternRegistry();

  final StringSink _sink;
  final PatternRegistry _registry;

  /// Runs the command by fetching and parsing the feed.
  Future<int> run({
    required String feedUrl,
    String? patternId,
    bool json = false,
  }) async {
    // Fetch feed
    final response = await http.get(Uri.parse(feedUrl));
    if (response.statusCode != 200) {
      _sink.writeln('Error: HTTP ${response.statusCode}');
      return 2;
    }

    // Parse feed
    final parser = PodcastRssParser();
    final items = <PodcastItem>[];

    try {
      await for (final entity in parser.parseFromString(response.body)) {
        if (entity is PodcastItem) {
          items.add(entity);
        }
      }
    } catch (e) {
      _sink.writeln('Error parsing feed: $e');
      return 2;
    }

    return runWithItems(
      feedUrl: feedUrl,
      items: items,
      patternId: patternId,
      json: json,
    );
  }

  /// Runs with pre-fetched items (for testing).
  Future<int> runWithItems({
    required String feedUrl,
    required List<PodcastItem> items,
    String? patternId,
    bool json = false,
  }) async {
    // Find pattern
    final pattern = patternId != null
        ? _registry.findById(patternId)
        : _registry.detectFromUrl(feedUrl);

    if (pattern == null) {
      _sink.writeln('Error: No pattern found for feed');
      return 2;
    }

    // Process items
    final results = <ExtractionResult>[];
    var passed = 0;
    var failed = 0;

    for (final item in items) {
      final episode = toEpisode(item);
      final result = _extractWithDiagnostics(episode, pattern);
      results.add(result);

      if (result.success) {
        passed++;
      } else {
        failed++;
      }
    }

    // Report
    if (json) {
      final reporter = JsonReporter(_sink);
      reporter.start(feedUrl: feedUrl, patternId: pattern.id);
      for (final result in results) {
        reporter.addResult(result);
      }
      reporter.finish(total: items.length, passed: passed, failed: failed);
    } else {
      final reporter = TableReporter(_sink);
      reporter.writeHeader(
        feedUrl: feedUrl,
        patternId: pattern.id,
        episodeCount: items.length,
      );
      for (final result in results) {
        reporter.writeResult(result);
      }
      reporter.writeSummary(total: items.length, passed: passed, failed: failed);
    }

    return failed > 0 ? 1 : 0;
  }

  ExtractionResult _extractWithDiagnostics(
    Episode episode,
    SeasonPattern pattern,
  ) {
    String? extractedTitle;
    int? extractedEpisodeNumber;
    String? titleError;
    String? episodeError;

    // Extract title
    if (pattern.titleExtractor != null) {
      final diagnostics = TitleExtractorDiagnostics(pattern.titleExtractor!);
      final result = diagnostics.run(episode);
      extractedTitle = result.extractedValue;
      titleError = result.error;
    }

    // Extract episode number
    if (pattern.episodeNumberExtractor != null) {
      final diagnostics = EpisodeExtractorDiagnostics(
        pattern.episodeNumberExtractor!,
      );
      final result = diagnostics.run(episode);
      extractedEpisodeNumber = result.extractedValue;
      episodeError = result.error;
    }

    // Build result
    final hasError = extractedTitle == null;
    final error = titleError ?? episodeError;

    return ExtractionResult(
      title: episode.title,
      rssSeasonNumber: episode.seasonNumber,
      rssEpisodeNumber: episode.episodeNumber,
      extractedTitle: extractedTitle,
      extractedEpisodeNumber: extractedEpisodeNumber,
      diagnostics: hasError
          ? ExtractionDiagnostics(
              titlePattern: pattern.titleExtractor?.pattern,
              fallbackValue: pattern.titleExtractor?.fallbackValue,
              error: error ?? 'extraction failed',
            )
          : null,
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_cli && dart test test/commands/season_debug_command_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add packages/audiflow_cli/lib/src/commands/season_debug_command.dart packages/audiflow_cli/test/commands/season_debug_command_test.dart
git commit -m "feat(cli): add season-debug command"
```

---

## Task 12: Create CLI Entry Point

**Files:**
- Modify: `packages/audiflow_cli/bin/audiflow_cli.dart`

**Step 1: Write the full CLI with arg parsing**

```dart
// packages/audiflow_cli/bin/audiflow_cli.dart
import 'dart:io';

import 'package:args/args.dart';
import 'package:audiflow_cli/src/commands/pattern_list_command.dart';
import 'package:audiflow_cli/src/commands/pattern_test_command.dart';
import 'package:audiflow_cli/src/commands/season_debug_command.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
    ..addFlag('version', negatable: false, help: 'Show version');

  // Add subcommands
  parser.addCommand('season-debug')
    ..addFlag('json', help: 'Output as JSON')
    ..addOption('pattern', abbr: 'p', help: 'Pattern ID to use');

  parser.addCommand('pattern-test')
    ..addOption('title', abbr: 't', help: 'Episode title to test')
    ..addOption('title-pattern', help: 'Regex pattern for title extraction')
    ..addOption('title-group', help: 'Capture group for title', defaultsTo: '1')
    ..addOption('title-fallback', help: 'Fallback value for title')
    ..addOption('episode-pattern', help: 'Regex pattern for episode number')
    ..addOption('season-number', abbr: 's', help: 'Season number (int or null)')
    ..addOption('episode-number', abbr: 'e', help: 'Episode number (int or null)');

  parser.addCommand('pattern-list');

  try {
    final results = parser.parse(args);

    if (results['help'] as bool) {
      _printUsage(parser);
      exit(0);
    }

    if (results['version'] as bool) {
      print('audiflow_cli 0.0.1');
      exit(0);
    }

    final command = results.command;
    if (command == null) {
      _printUsage(parser);
      exit(1);
    }

    switch (command.name) {
      case 'season-debug':
        await _runSeasonDebug(command);
      case 'pattern-test':
        _runPatternTest(command);
      case 'pattern-list':
        _runPatternList();
      default:
        print('Unknown command: ${command.name}');
        exit(1);
    }
  } on FormatException catch (e) {
    print('Error: ${e.message}');
    _printUsage(parser);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Usage: dart run audiflow_cli <command> [options]');
  print('');
  print('Commands:');
  print('  season-debug <url>   Test extractors against RSS feed');
  print('  pattern-test         Test patterns against a single title');
  print('  pattern-list         List available patterns');
  print('');
  print('Options:');
  print(parser.usage);
}

Future<void> _runSeasonDebug(ArgResults command) async {
  if (command.rest.isEmpty) {
    print('Error: Feed URL required');
    exit(1);
  }

  final feedUrl = command.rest.first;
  final json = command['json'] as bool;
  final patternId = command['pattern'] as String?;

  final cmd = SeasonDebugCommand(stdout);
  final exitCode = await cmd.run(
    feedUrl: feedUrl,
    patternId: patternId,
    json: json,
  );
  exit(exitCode);
}

void _runPatternTest(ArgResults command) {
  final title = command['title'] as String?;
  if (title == null) {
    print('Error: --title is required');
    exit(1);
  }

  final titlePattern = command['title-pattern'] as String?;
  final titleGroup = int.tryParse(command['title-group'] as String) ?? 1;
  final titleFallback = command['title-fallback'] as String?;
  final episodePattern = command['episode-pattern'] as String?;

  final seasonNumberStr = command['season-number'] as String?;
  final seasonNumber =
      seasonNumberStr == null ? null : int.tryParse(seasonNumberStr);

  final episodeNumberStr = command['episode-number'] as String?;
  final episodeNumber =
      episodeNumberStr == null ? null : int.tryParse(episodeNumberStr);

  final cmd = PatternTestCommand(stdout);
  final exitCode = cmd.run(
    title: title,
    titlePattern: titlePattern,
    titleGroup: titleGroup,
    titleFallback: titleFallback,
    episodePattern: episodePattern,
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
  );
  exit(exitCode);
}

void _runPatternList() {
  final cmd = PatternListCommand(stdout);
  final exitCode = cmd.run();
  exit(exitCode);
}
```

**Step 2: Test CLI commands manually**

Run: `cd packages/audiflow_cli && dart run audiflow_cli --help`
Expected: Shows usage and commands

Run: `dart run audiflow_cli pattern-list`
Expected: Shows coten_radio pattern

Run: `dart run audiflow_cli pattern-test --title='【62-15】Test【COTEN RADIO リンカン編15】' --title-pattern='【COTEN RADIO (ショート)?\s*(.+?)\s*\d+】' --title-group=2 --season-number=62`
Expected: Shows extraction result

**Step 3: Commit**

```bash
git add packages/audiflow_cli/bin/audiflow_cli.dart
git commit -m "feat(cli): complete CLI entry point with arg parsing"
```

---

## Task 13: Export Public API and Update Library

**Files:**
- Modify: `packages/audiflow_cli/lib/audiflow_cli.dart`

**Step 1: Update exports**

```dart
// packages/audiflow_cli/lib/audiflow_cli.dart
/// CLI tools for debugging Audiflow features.
library;

// Adapters
export 'src/adapters/episode_adapter.dart';

// Commands
export 'src/commands/pattern_list_command.dart';
export 'src/commands/pattern_test_command.dart';
export 'src/commands/season_debug_command.dart';

// Diagnostics
export 'src/diagnostics/episode_extractor_diagnostics.dart';
export 'src/diagnostics/title_extractor_diagnostics.dart';

// Models
export 'src/models/extraction_result.dart';

// Patterns
export 'src/patterns/pattern_registry.dart';

// Reporters
export 'src/reporters/json_reporter.dart';
export 'src/reporters/table_reporter.dart';
```

**Step 2: Run all tests**

Run: `cd packages/audiflow_cli && dart test`
Expected: All tests pass

**Step 3: Format and analyze**

Run: `cd packages/audiflow_cli && dart format . && dart analyze`
Expected: No issues

**Step 4: Commit**

```bash
git add packages/audiflow_cli/lib/audiflow_cli.dart
git commit -m "feat(cli): export public API"
```

---

## Task 14: Integration Test with Live Feed

**Files:**
- Create: `packages/audiflow_cli/test/integration/season_debug_integration_test.dart`

**Note:** This test requires network access and should be skipped in CI.

**Step 1: Write integration test**

```dart
// packages/audiflow_cli/test/integration/season_debug_integration_test.dart
@Tags(['integration'])
library;

import 'package:audiflow_cli/src/commands/season_debug_command.dart';
import 'package:test/test.dart';

void main() {
  group('SeasonDebugCommand integration', () {
    test(
      'processes COTEN RADIO feed',
      () async {
        final output = StringBuffer();
        final command = SeasonDebugCommand(output);

        final exitCode = await command.run(
          feedUrl: 'https://anchor.fm/s/8c2088c/podcast/rss',
          json: false,
        );

        final text = output.toString();

        // Should have processed episodes
        expect(text, contains('Episodes:'));
        expect(text, contains('Summary'));

        // Should have mostly passing results
        expect(text, contains('PASS'));

        // Print output for manual verification
        print(text);
      },
      timeout: Timeout(Duration(minutes: 2)),
    );
  });
}
```

**Step 2: Run integration test**

Run: `cd packages/audiflow_cli && dart test --tags=integration`
Expected: Test passes, output shows COTEN RADIO episodes being processed

**Step 3: Commit**

```bash
git add packages/audiflow_cli/test/integration
git commit -m "test(cli): add integration test for live feed"
```

---

## Summary

This plan creates a complete CLI tool with:

1. **Package scaffold** with pure Dart dependencies
2. **Models** for extraction results and diagnostics
3. **Adapters** to convert PodcastItem to Episode
4. **Diagnostics wrappers** for detailed extraction info
5. **Reporters** for table and JSON output
6. **Commands**:
   - `pattern-list` - list available patterns
   - `pattern-test` - test patterns against single titles
   - `season-debug` - test against live RSS feeds
7. **Integration tests** for live feed verification

Run all commands from `packages/audiflow_cli`:
```bash
dart run audiflow_cli pattern-list
dart run audiflow_cli pattern-test --title='...' --title-pattern='...'
dart run audiflow_cli season-debug https://anchor.fm/s/8c2088c/podcast/rss
dart run audiflow_cli season-debug --json https://anchor.fm/s/8c2088c/podcast/rss
```
