# Season Debug CLI Design

## Overview

A pure Dart CLI tool for debugging season extraction patterns. Fetches live RSS feeds and tests extractors against every episode, reporting failures with detailed diagnostics.

**Primary use case:** AI-driven validation and debugging of custom season extraction patterns (e.g., COTEN RADIO).

## Package Structure

**Location:** `packages/audiflow_cli/`

```
packages/audiflow_cli/
├── pubspec.yaml
├── bin/
│   └── audiflow_cli.dart              # Entry point
├── lib/
│   ├── audiflow_cli.dart              # Public API
│   └── src/
│       ├── commands/
│       │   ├── season_debug_command.dart
│       │   ├── pattern_test_command.dart
│       │   └── pattern_list_command.dart
│       ├── adapters/
│       │   └── episode_adapter.dart   # PodcastItem → Episode
│       ├── diagnostics/
│       │   ├── title_extractor_diagnostics.dart
│       │   └── episode_extractor_diagnostics.dart
│       ├── reporters/
│       │   ├── json_reporter.dart
│       │   └── table_reporter.dart
│       └── models/
│           └── extraction_result.dart
└── test/
```

**Dependencies:**

```yaml
name: audiflow_cli
description: CLI tools for debugging Audiflow features

environment:
  sdk: ^3.10.0

dependencies:
  audiflow_domain:
    path: ../audiflow_domain
  audiflow_podcast:
    path: ../audiflow_podcast
  args: ^2.4.0
  http: ^1.2.0

dev_dependencies:
  test: ^1.24.0
  lints: ^3.0.0
```

**Constraint:** No Flutter dependencies. Must run with `dart run` without Flutter SDK.

## CLI Interface

**Entry point:** `dart run audiflow_cli <command> [options]`

### Commands

#### `season-debug <feed-url>`

Fetch RSS feed and run all extractors against every episode.

```bash
# Table output (default)
dart run audiflow_cli season-debug https://anchor.fm/s/8c2088c/podcast/rss

# JSON output
dart run audiflow_cli season-debug --json https://anchor.fm/s/8c2088c/podcast/rss

# With specific pattern (auto-detects if not specified)
dart run audiflow_cli season-debug --pattern=coten_radio https://anchor.fm/...
```

#### `pattern-test`

Test regex patterns against individual titles without fetching feed.

```bash
dart run audiflow_cli pattern-test \
  --title='【62-15】何が変わった?【COTEN RADIO リンカン編15】' \
  --title-pattern='【COTEN RADIO (ショート)?\s*(.+?)\s*\d+】' \
  --title-group=2 \
  --episode-pattern='(\d+)】' \
  --season-number=62
```

#### `pattern-list`

List all available pre-configured patterns.

```bash
dart run audiflow_cli pattern-list
# Output:
# coten_radio  https://anchor.fm/s/8c2088c/podcast/rss
```

### Exit Codes

- `0` - All extractions passed
- `1` - One or more extractions failed
- `2` - Network/parse error

## Output Format

### Table Output (default)

```
Fetching: https://anchor.fm/s/8c2088c/podcast/rss
Pattern:  coten_radio (auto-detected)
Episodes: 245

PASS | S62  | E15  | 【62-15】何が変わった?【COTEN RA... | title="リンカン編" ep=15
PASS | S62  | E14  | 【62-14】南北戦争とは【COTEN RAD... | title="リンカン編" ep=14
PASS | null | E135 | 【番外編＃135】仏教のこと           | title="番外編" ep=135
FAIL | null | null | 【特別編】ゲスト回スペシャル
     |      |      |   title_pattern: 【COTEN RADIO (ショート)?\s*(.+?)\s*\d+】
     |      |      |   title_match: none
     |      |      |   fallback_value: "番外編"
     |      |      |   fallback_condition: seasonNumber == null ✓
     |      |      |   error: pattern requires digits before 】, found none

--- Summary ---
Total: 245
Pass:  244 (99.6%)
Fail:    1 (0.4%)
```

### JSON Output (`--json`)

```json
{
  "feed_url": "https://anchor.fm/s/8c2088c/podcast/rss",
  "pattern_id": "coten_radio",
  "results": [
    {
      "status": "pass",
      "title": "【62-15】何が変わった?【COTEN RADIO リンカン編15】",
      "rss_season": 62,
      "rss_episode": null,
      "extracted_title": "リンカン編",
      "extracted_episode": 15
    },
    {
      "status": "fail",
      "title": "【特別編】ゲスト回スペシャル",
      "rss_season": null,
      "rss_episode": null,
      "diagnostics": {
        "title_pattern": "【COTEN RADIO (ショート)?\\s*(.+?)\\s*\\d+】",
        "title_match": null,
        "fallback_value": "番外編",
        "fallback_condition_met": true,
        "error": "pattern requires digits before 】, found none"
      }
    }
  ],
  "summary": {
    "total": 245,
    "pass": 244,
    "fail": 1
  }
}
```

## Core Components

### Episode Adapter

Converts `PodcastItem` from RSS parsing to `Episode` for extractors.

```dart
// lib/src/adapters/episode_adapter.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';

Episode toEpisode(PodcastItem item) {
  return Episode(
    id: 0,                              // stub
    podcastId: 0,                       // stub
    guid: item.guid ?? '',
    title: item.title,
    audioUrl: item.enclosureUrl ?? '',
    description: item.description,
    seasonNumber: item.seasonNumber,
    episodeNumber: item.episodeNumber,
    publishedAt: item.publishDate,
  );
}
```

### Extraction Result Model

```dart
// lib/src/models/extraction_result.dart
class ExtractionResult {
  final String title;
  final int? rssSeasonNumber;
  final int? rssEpisodeNumber;
  final String? extractedTitle;
  final int? extractedEpisodeNumber;
  final bool success;
  final ExtractionDiagnostics? diagnostics;
}

class ExtractionDiagnostics {
  final String? titlePattern;
  final String? titleMatch;
  final String? episodePattern;
  final String? episodeMatch;
  final String? fallbackValue;
  final bool? fallbackConditionMet;
  final String error;
}
```

### Diagnostic Wrappers

The current extractors return only the result - they don't expose why extraction failed. Diagnostic wrappers re-run extraction logic step-by-step to capture intermediate state.

```dart
// lib/src/diagnostics/title_extractor_diagnostics.dart
class TitleExtractorDiagnostics {
  final SeasonTitleExtractor extractor;

  ExtractionDiagnostics run(Episode episode) {
    // Step 1: Check fallback condition
    final seasonNum = episode.seasonNumber;
    if (extractor.fallbackValue != null && (seasonNum == null || 1 > seasonNum)) {
      return ExtractionDiagnostics(
        fallbackValue: extractor.fallbackValue,
        fallbackConditionMet: true,
        result: extractor.fallbackValue,
      );
    }

    // Step 2: Try pattern match
    if (extractor.pattern != null) {
      final regex = RegExp(extractor.pattern!);
      final match = regex.firstMatch(episode.title);
      return ExtractionDiagnostics(
        titlePattern: extractor.pattern,
        titleMatch: match?.group(extractor.group),
        result: match?.group(extractor.group),
        error: match == null ? 'pattern did not match' : null,
      );
    }
    // ... continue for other cases
  }
}
```

### Feed Fetching & Parsing

Uses `http` package (pure Dart) and reuses `StreamingXmlParser` from `audiflow_podcast`.

```dart
// lib/src/commands/season_debug_command.dart
import 'package:http/http.dart' as http;
import 'package:audiflow_podcast/src/parser/streaming_xml_parser.dart';

Future<List<PodcastItem>> fetchAndParse(String feedUrl) async {
  // Fetch RSS
  final response = await http.get(Uri.parse(feedUrl));
  if (response.statusCode != 200) {
    throw FetchException('HTTP ${response.statusCode}');
  }

  // Parse using streaming parser
  final parser = StreamingXmlParser();
  final items = <PodcastItem>[];

  parser.entityStream.listen((entity) {
    if (entity is PodcastItem) {
      items.add(entity);
    }
  });

  await parser.parseXmlString(response.body, sourceUrl: feedUrl);

  return items;
}
```

### Pattern Detection

Match feed URL against registered patterns.

```dart
SeasonPattern? detectPattern(String feedUrl, List<SeasonPattern> patterns) {
  for (final pattern in patterns) {
    if (pattern.matchesPodcast(null, feedUrl)) {
      return pattern;
    }
  }
  return null;
}
```

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Decoupling from Episode | Adapter function | Minimal changes, isolated to CLI |
| Package location | New `audiflow_cli` package | Clean separation, room to grow |
| Output format | Table + JSON flag | Human-readable default, AI-parseable option |
| Diagnostics detail | Verbose on failure only | Minimal noise, full detail when needed |
| HTTP client | `http` package | Pure Dart, no Flutter required |
| RSS parsing | Reuse `StreamingXmlParser` | Already pure Dart, battle-tested |

## Future Extensions

- `feed-inspect` - Dump raw RSS metadata for debugging
- `pattern-generate` - Suggest patterns from sample titles
- `batch-test` - Test multiple feeds from config file
