# Episode List Rendering Optimization - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Eliminate UI freezes when opening podcasts with many episodes by moving RSS parsing to an isolate and stopping early when known episodes are found.

**Architecture:** Cached episodes display instantly. Background refresh parses in a separate isolate with early-stop when hitting known GUIDs. Batched upserts (20 episodes) maintain performance for fresh podcasts.

**Tech Stack:** Dart isolates (`Isolate.run`), Drift batch operations, Riverpod state management, existing `StreamingXmlParser`.

---

## Task 1: Add ParseProgress Models

Create the sealed class hierarchy for isolate parser progress events.

**Files:**
- Create: `packages/audiflow_podcast/lib/src/parser/parse_progress.dart`
- Modify: `packages/audiflow_podcast/lib/audiflow_podcast.dart` (add export)

**Step 1: Write the test**

Create test file `packages/audiflow_podcast/test/parser/parse_progress_test.dart`:

```dart
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:test/test.dart';

void main() {
  group('ParseProgress', () {
    test('ParsedPodcastMeta holds metadata', () {
      final meta = ParsedPodcastMeta(
        title: 'Test Podcast',
        description: 'A test podcast',
        author: 'Test Author',
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(meta.title, 'Test Podcast');
      expect(meta.description, 'A test podcast');
      expect(meta.author, 'Test Author');
      expect(meta.imageUrl, 'https://example.com/image.jpg');
    });

    test('ParsedEpisode holds episode data', () {
      final episode = ParsedEpisode(
        guid: 'episode-123',
        title: 'Episode 1',
        enclosureUrl: 'https://example.com/ep1.mp3',
      );

      expect(episode.guid, 'episode-123');
      expect(episode.title, 'Episode 1');
      expect(episode.enclosureUrl, 'https://example.com/ep1.mp3');
    });

    test('ParseComplete reports stats', () {
      final complete = ParseComplete(totalParsed: 50, stoppedEarly: true);

      expect(complete.totalParsed, 50);
      expect(complete.stoppedEarly, isTrue);
    });

    test('ParseProgress is sealed', () {
      // Verify exhaustive switch works
      ParseProgress progress = ParseComplete(totalParsed: 1, stoppedEarly: false);

      final result = switch (progress) {
        ParsedPodcastMeta() => 'meta',
        ParsedEpisode() => 'episode',
        ParseComplete() => 'complete',
      };

      expect(result, 'complete');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_podcast && dart test test/parser/parse_progress_test.dart`

Expected: FAIL - cannot find `ParseProgress` classes

**Step 3: Write implementation**

Create `packages/audiflow_podcast/lib/src/parser/parse_progress.dart`:

```dart
/// Progress events emitted during isolate-based RSS parsing.
///
/// Used to communicate parsing state from the isolate back to the main thread.
sealed class ParseProgress {
  const ParseProgress();
}

/// Emitted when podcast metadata has been parsed.
final class ParsedPodcastMeta extends ParseProgress {
  const ParsedPodcastMeta({
    required this.title,
    required this.description,
    this.author,
    this.imageUrl,
    this.language,
  });

  final String title;
  final String description;
  final String? author;
  final String? imageUrl;
  final String? language;
}

/// Emitted for each episode parsed.
final class ParsedEpisode extends ParseProgress {
  const ParsedEpisode({
    required this.guid,
    required this.title,
    this.description,
    this.enclosureUrl,
    this.enclosureType,
    this.enclosureLength,
    this.publishDate,
    this.duration,
    this.episodeNumber,
    this.seasonNumber,
    this.imageUrl,
  });

  final String? guid;
  final String title;
  final String? description;
  final String? enclosureUrl;
  final String? enclosureType;
  final int? enclosureLength;
  final DateTime? publishDate;
  final Duration? duration;
  final int? episodeNumber;
  final int? seasonNumber;
  final String? imageUrl;
}

/// Emitted when parsing is complete.
final class ParseComplete extends ParseProgress {
  const ParseComplete({
    required this.totalParsed,
    required this.stoppedEarly,
  });

  /// Total number of episodes parsed.
  final int totalParsed;

  /// True if parsing stopped early due to finding a known GUID.
  final bool stoppedEarly;
}
```

**Step 4: Add export to library**

Edit `packages/audiflow_podcast/lib/audiflow_podcast.dart`, add after line 100:

```dart
export 'src/parser/parse_progress.dart';
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_podcast && dart test test/parser/parse_progress_test.dart`

Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_podcast/lib/src/parser/parse_progress.dart \
        packages/audiflow_podcast/lib/audiflow_podcast.dart \
        packages/audiflow_podcast/test/parser/parse_progress_test.dart
git commit -m "feat(podcast): add ParseProgress models for isolate parser"
```

---

## Task 2: Create IsolateRssParser

Create the isolate-based parser with early-stop capability.

**Files:**
- Create: `packages/audiflow_podcast/lib/src/parser/isolate_rss_parser.dart`
- Create: `packages/audiflow_podcast/test/parser/isolate_rss_parser_test.dart`
- Modify: `packages/audiflow_podcast/lib/audiflow_podcast.dart` (add export)

**Step 1: Write the test**

Create test file `packages/audiflow_podcast/test/parser/isolate_rss_parser_test.dart`:

```dart
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:test/test.dart';

void main() {
  group('IsolateRssParser', () {
    const testXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Test Podcast</title>
    <description>A test podcast description</description>
    <itunes:author>Test Author</itunes:author>
    <item>
      <guid>episode-3</guid>
      <title>Episode 3</title>
      <enclosure url="https://example.com/ep3.mp3" type="audio/mpeg" length="1000"/>
    </item>
    <item>
      <guid>episode-2</guid>
      <title>Episode 2</title>
      <enclosure url="https://example.com/ep2.mp3" type="audio/mpeg" length="1000"/>
    </item>
    <item>
      <guid>episode-1</guid>
      <title>Episode 1</title>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg" length="1000"/>
    </item>
  </channel>
</rss>
''';

    test('parses all episodes when no known GUIDs', () async {
      final progress = <ParseProgress>[];

      await for (final event in IsolateRssParser.parse(
        feedXml: testXml,
        knownGuids: {},
      )) {
        progress.add(event);
      }

      expect(progress.whereType<ParsedPodcastMeta>(), hasLength(1));
      expect(progress.whereType<ParsedEpisode>(), hasLength(3));
      expect(progress.whereType<ParseComplete>(), hasLength(1));

      final complete = progress.whereType<ParseComplete>().first;
      expect(complete.totalParsed, 3);
      expect(complete.stoppedEarly, isFalse);
    });

    test('stops early when known GUID encountered', () async {
      final progress = <ParseProgress>[];

      await for (final event in IsolateRssParser.parse(
        feedXml: testXml,
        knownGuids: {'episode-2'},
      )) {
        progress.add(event);
      }

      // Should have parsed episode-3, then stopped at episode-2
      final episodes = progress.whereType<ParsedEpisode>().toList();
      expect(episodes, hasLength(1));
      expect(episodes.first.guid, 'episode-3');

      final complete = progress.whereType<ParseComplete>().first;
      expect(complete.totalParsed, 1);
      expect(complete.stoppedEarly, isTrue);
    });

    test('stops at maxNewEpisodes limit', () async {
      final progress = <ParseProgress>[];

      await for (final event in IsolateRssParser.parse(
        feedXml: testXml,
        knownGuids: {},
        maxNewEpisodes: 2,
      )) {
        progress.add(event);
      }

      final episodes = progress.whereType<ParsedEpisode>().toList();
      expect(episodes, hasLength(2));

      final complete = progress.whereType<ParseComplete>().first;
      expect(complete.totalParsed, 2);
      expect(complete.stoppedEarly, isFalse);
    });

    test('emits metadata first', () async {
      final progress = <ParseProgress>[];

      await for (final event in IsolateRssParser.parse(
        feedXml: testXml,
        knownGuids: {},
      )) {
        progress.add(event);
      }

      expect(progress.first, isA<ParsedPodcastMeta>());
      final meta = progress.first as ParsedPodcastMeta;
      expect(meta.title, 'Test Podcast');
      expect(meta.author, 'Test Author');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_podcast && dart test test/parser/isolate_rss_parser_test.dart`

Expected: FAIL - `IsolateRssParser` not found

**Step 3: Write implementation**

Create `packages/audiflow_podcast/lib/src/parser/isolate_rss_parser.dart`:

```dart
import 'dart:async';
import 'dart:isolate';

import 'package:xml/xml.dart';

import 'parse_progress.dart';

/// Parses RSS feeds in a separate isolate to prevent UI freezes.
///
/// Supports early-stop optimization: stops parsing when a known episode GUID
/// is encountered, reducing parse time for subscribed podcasts from O(n) to O(new).
class IsolateRssParser {
  IsolateRssParser._();

  /// Parses the given XML in a background isolate.
  ///
  /// - [feedXml]: Raw XML content of the RSS feed
  /// - [knownGuids]: Set of episode GUIDs already in the database
  /// - [maxNewEpisodes]: Safety limit to prevent runaway parsing (default: 500)
  ///
  /// Returns a stream of [ParseProgress] events.
  static Stream<ParseProgress> parse({
    required String feedXml,
    required Set<String> knownGuids,
    int maxNewEpisodes = 500,
  }) async* {
    final receivePort = ReceivePort();

    try {
      await Isolate.spawn(
        _parseInIsolate,
        _IsolateParams(
          feedXml: feedXml,
          knownGuids: knownGuids,
          maxNewEpisodes: maxNewEpisodes,
          sendPort: receivePort.sendPort,
        ),
      );

      await for (final message in receivePort) {
        if (message is ParseProgress) {
          yield message;
          if (message is ParseComplete) {
            break;
          }
        } else if (message is _IsolateError) {
          throw Exception(message.error);
        }
      }
    } finally {
      receivePort.close();
    }
  }

  static void _parseInIsolate(_IsolateParams params) {
    try {
      final document = XmlDocument.parse(params.feedXml);
      final rssElement =
          document.findElements('rss').firstOrNull ??
          document.findElements('feed').firstOrNull;

      if (rssElement == null) {
        params.sendPort.send(_IsolateError('No RSS or Atom feed found'));
        params.sendPort.send(const ParseComplete(totalParsed: 0, stoppedEarly: false));
        return;
      }

      final channelElement = rssElement.findElements('channel').firstOrNull;
      if (channelElement == null) {
        params.sendPort.send(_IsolateError('No channel element found'));
        params.sendPort.send(const ParseComplete(totalParsed: 0, stoppedEarly: false));
        return;
      }

      // Parse and emit metadata
      final meta = _parseMetadata(channelElement);
      params.sendPort.send(meta);

      // Parse episodes with early-stop
      var parsedCount = 0;
      var stoppedEarly = false;

      for (final itemElement in channelElement.findElements('item')) {
        final guid = _extractText(itemElement, 'guid');

        // Early stop: if we hit a known GUID, stop parsing
        if (guid != null && params.knownGuids.contains(guid)) {
          stoppedEarly = true;
          break;
        }

        final episode = _parseEpisode(itemElement);
        params.sendPort.send(episode);
        parsedCount++;

        // Safety limit
        if (params.maxNewEpisodes <= parsedCount) {
          break;
        }
      }

      params.sendPort.send(ParseComplete(
        totalParsed: parsedCount,
        stoppedEarly: stoppedEarly,
      ));
    } catch (e) {
      params.sendPort.send(_IsolateError(e.toString()));
      params.sendPort.send(const ParseComplete(totalParsed: 0, stoppedEarly: false));
    }
  }

  static ParsedPodcastMeta _parseMetadata(XmlElement channel) {
    return ParsedPodcastMeta(
      title: _extractText(channel, 'title') ?? 'Untitled Podcast',
      description: _extractText(channel, 'description') ?? '',
      author: _extractItunesText(channel, 'author'),
      imageUrl: _extractItunesImageUrl(channel),
      language: _extractText(channel, 'language'),
    );
  }

  static ParsedEpisode _parseEpisode(XmlElement item) {
    final enclosure = item.findElements('enclosure').firstOrNull;

    return ParsedEpisode(
      guid: _extractText(item, 'guid'),
      title: _extractText(item, 'title') ?? 'Untitled Episode',
      description: _extractText(item, 'description'),
      enclosureUrl: enclosure?.getAttribute('url'),
      enclosureType: enclosure?.getAttribute('type'),
      enclosureLength: int.tryParse(enclosure?.getAttribute('length') ?? ''),
      publishDate: _parseDate(_extractText(item, 'pubDate')),
      duration: _parseDuration(_extractItunesText(item, 'duration')),
      episodeNumber: int.tryParse(_extractItunesText(item, 'episode') ?? ''),
      seasonNumber: int.tryParse(_extractItunesText(item, 'season') ?? ''),
      imageUrl: _extractItunesImageUrl(item),
    );
  }

  static String? _extractText(XmlElement parent, String elementName) {
    return parent.findElements(elementName).firstOrNull?.innerText.trim();
  }

  static String? _extractItunesText(XmlElement parent, String localName) {
    for (final element in parent.children.whereType<XmlElement>()) {
      if (element.localName == localName &&
          (element.name.qualified.startsWith('itunes:') ||
           element.namespaceUri == 'http://www.itunes.com/dtds/podcast-1.0.dtd')) {
        return element.innerText.trim();
      }
    }
    return null;
  }

  static String? _extractItunesImageUrl(XmlElement parent) {
    for (final element in parent.children.whereType<XmlElement>()) {
      if (element.localName == 'image' &&
          (element.name.qualified.startsWith('itunes:') ||
           element.namespaceUri == 'http://www.itunes.com/dtds/podcast-1.0.dtd')) {
        return element.getAttribute('href');
      }
    }
    return null;
  }

  static DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      // Try common RSS date formats
      try {
        // RFC 2822 simplified parsing
        return DateTime.tryParse(dateString);
      } catch (_) {
        return null;
      }
    }
  }

  static Duration? _parseDuration(String? durationString) {
    if (durationString == null || durationString.isEmpty) return null;

    final parts = durationString.split(':');
    try {
      if (parts.length == 3) {
        return Duration(
          hours: int.parse(parts[0]),
          minutes: int.parse(parts[1]),
          seconds: int.parse(parts[2]),
        );
      } else if (parts.length == 2) {
        return Duration(
          minutes: int.parse(parts[0]),
          seconds: int.parse(parts[1]),
        );
      } else {
        return Duration(seconds: int.parse(durationString));
      }
    } catch (_) {
      return null;
    }
  }
}

class _IsolateParams {
  const _IsolateParams({
    required this.feedXml,
    required this.knownGuids,
    required this.maxNewEpisodes,
    required this.sendPort,
  });

  final String feedXml;
  final Set<String> knownGuids;
  final int maxNewEpisodes;
  final SendPort sendPort;
}

class _IsolateError {
  const _IsolateError(this.error);
  final String error;
}
```

**Step 4: Add export to library**

Edit `packages/audiflow_podcast/lib/audiflow_podcast.dart`, add after the parse_progress export:

```dart
export 'src/parser/isolate_rss_parser.dart';
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_podcast && dart test test/parser/isolate_rss_parser_test.dart`

Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_podcast/lib/src/parser/isolate_rss_parser.dart \
        packages/audiflow_podcast/lib/audiflow_podcast.dart \
        packages/audiflow_podcast/test/parser/isolate_rss_parser_test.dart
git commit -m "feat(podcast): add IsolateRssParser with early-stop support"
```

---

## Task 3: Add getGuidsByPodcastId to EpisodeLocalDatasource

Add method to retrieve known GUIDs for early-stop optimization.

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/datasources/local/episode_local_datasource.dart`
- Create: `packages/audiflow_domain/test/features/feed/datasources/local/episode_local_datasource_test.dart`

**Step 1: Write the test**

Create test file `packages/audiflow_domain/test/features/feed/datasources/local/episode_local_datasource_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late EpisodeLocalDatasource datasource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = EpisodeLocalDatasource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('getGuidsByPodcastId', () {
    test('returns empty set for podcast with no episodes', () async {
      final guids = await datasource.getGuidsByPodcastId(999);
      expect(guids, isEmpty);
    });

    test('returns all GUIDs for podcast', () async {
      // Insert test episodes
      await datasource.upsert(EpisodesCompanion.insert(
        podcastId: 1,
        guid: 'guid-1',
        title: 'Episode 1',
        audioUrl: 'https://example.com/ep1.mp3',
      ));
      await datasource.upsert(EpisodesCompanion.insert(
        podcastId: 1,
        guid: 'guid-2',
        title: 'Episode 2',
        audioUrl: 'https://example.com/ep2.mp3',
      ));
      await datasource.upsert(EpisodesCompanion.insert(
        podcastId: 2, // Different podcast
        guid: 'guid-3',
        title: 'Episode 3',
        audioUrl: 'https://example.com/ep3.mp3',
      ));

      final guids = await datasource.getGuidsByPodcastId(1);

      expect(guids, hasLength(2));
      expect(guids, containsAll(['guid-1', 'guid-2']));
      expect(guids, isNot(contains('guid-3')));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && dart test test/features/feed/datasources/local/episode_local_datasource_test.dart`

Expected: FAIL - `getGuidsByPodcastId` method not found

**Step 3: Write implementation**

Edit `packages/audiflow_domain/lib/src/features/feed/datasources/local/episode_local_datasource.dart`, add after `getByAudioUrl` method (around line 81):

```dart
  /// Returns all episode GUIDs for a podcast.
  ///
  /// Used for early-stop optimization during RSS parsing.
  Future<Set<String>> getGuidsByPodcastId(int podcastId) async {
    final results = await (_db.select(_db.episodes)
          ..where((e) => e.podcastId.equals(podcastId)))
        .map((e) => e.guid)
        .get();
    return results.toSet();
  }
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_domain && dart test test/features/feed/datasources/local/episode_local_datasource_test.dart`

Expected: PASS

**Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/datasources/local/episode_local_datasource.dart \
        packages/audiflow_domain/test/features/feed/datasources/local/episode_local_datasource_test.dart
git commit -m "feat(domain): add getGuidsByPodcastId for early-stop optimization"
```

---

## Task 4: Add FeedParseProgress Events

Create progress event types for the service layer.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/feed_parse_progress.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart` (add export)

**Step 1: Write the test**

Create test file `packages/audiflow_domain/test/features/feed/models/feed_parse_progress_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:test/test.dart';

void main() {
  group('FeedParseProgress', () {
    test('FeedMetaReady holds metadata', () {
      final meta = FeedMetaReady(
        title: 'Test Podcast',
        description: 'A test',
        imageUrl: 'https://example.com/img.jpg',
      );

      expect(meta.title, 'Test Podcast');
      expect(meta.description, 'A test');
      expect(meta.imageUrl, 'https://example.com/img.jpg');
    });

    test('EpisodesBatchStored reports progress', () {
      final batch = EpisodesBatchStored(totalSoFar: 40);
      expect(batch.totalSoFar, 40);
    });

    test('FeedParseComplete reports final stats', () {
      final complete = FeedParseComplete(
        total: 100,
        stoppedEarly: true,
      );

      expect(complete.total, 100);
      expect(complete.stoppedEarly, isTrue);
    });

    test('exhaustive switch works', () {
      FeedParseProgress progress = FeedParseComplete(total: 1, stoppedEarly: false);

      final result = switch (progress) {
        FeedMetaReady() => 'meta',
        EpisodesBatchStored() => 'batch',
        FeedParseComplete() => 'complete',
      };

      expect(result, 'complete');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && dart test test/features/feed/models/feed_parse_progress_test.dart`

Expected: FAIL - classes not found

**Step 3: Write implementation**

Create `packages/audiflow_domain/lib/src/features/feed/models/feed_parse_progress.dart`:

```dart
/// Progress events emitted during feed parsing with batched storage.
sealed class FeedParseProgress {
  const FeedParseProgress();
}

/// Emitted when podcast metadata is ready.
final class FeedMetaReady extends FeedParseProgress {
  const FeedMetaReady({
    required this.title,
    required this.description,
    this.imageUrl,
    this.author,
  });

  final String title;
  final String description;
  final String? imageUrl;
  final String? author;
}

/// Emitted when a batch of episodes has been stored.
final class EpisodesBatchStored extends FeedParseProgress {
  const EpisodesBatchStored({required this.totalSoFar});

  /// Total episodes stored so far.
  final int totalSoFar;
}

/// Emitted when parsing is complete.
final class FeedParseComplete extends FeedParseProgress {
  const FeedParseComplete({
    required this.total,
    required this.stoppedEarly,
  });

  /// Total episodes parsed and stored.
  final int total;

  /// True if stopped early due to known GUID.
  final bool stoppedEarly;
}
```

**Step 4: Add export to library**

Edit `packages/audiflow_domain/lib/audiflow_domain.dart`, add in the feed feature exports section:

```dart
export 'src/features/feed/models/feed_parse_progress.dart';
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && dart test test/features/feed/models/feed_parse_progress_test.dart`

Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/feed_parse_progress.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart \
        packages/audiflow_domain/test/features/feed/models/feed_parse_progress_test.dart
git commit -m "feat(domain): add FeedParseProgress events for UI updates"
```

---

## Task 5: Add upsertBatch to EpisodeLocalDatasource

The existing `upsertAll` method already handles batch inserts. Verify it works correctly and add any missing functionality.

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/datasources/local/episode_local_datasource.dart` (if needed)
- Modify: `packages/audiflow_domain/test/features/feed/datasources/local/episode_local_datasource_test.dart`

**Step 1: Add test for upsertAll**

Add to the existing test file `packages/audiflow_domain/test/features/feed/datasources/local/episode_local_datasource_test.dart`:

```dart
  group('upsertAll', () {
    test('inserts multiple episodes in batch', () async {
      final companions = [
        EpisodesCompanion.insert(
          podcastId: 1,
          guid: 'batch-1',
          title: 'Batch Episode 1',
          audioUrl: 'https://example.com/batch1.mp3',
        ),
        EpisodesCompanion.insert(
          podcastId: 1,
          guid: 'batch-2',
          title: 'Batch Episode 2',
          audioUrl: 'https://example.com/batch2.mp3',
        ),
      ];

      await datasource.upsertAll(companions);

      final episodes = await datasource.getByPodcastId(1);
      expect(episodes, hasLength(2));
    });

    test('updates existing episodes on conflict', () async {
      // Insert initial episode
      await datasource.upsert(EpisodesCompanion.insert(
        podcastId: 1,
        guid: 'update-test',
        title: 'Original Title',
        audioUrl: 'https://example.com/update.mp3',
      ));

      // Upsert with same guid but different title
      await datasource.upsertAll([
        EpisodesCompanion.insert(
          podcastId: 1,
          guid: 'update-test',
          title: 'Updated Title',
          audioUrl: 'https://example.com/update.mp3',
        ),
      ]);

      final episodes = await datasource.getByPodcastId(1);
      expect(episodes, hasLength(1));
      expect(episodes.first.title, 'Updated Title');
    });
  });
```

**Step 2: Run test to verify it passes**

Run: `cd packages/audiflow_domain && dart test test/features/feed/datasources/local/episode_local_datasource_test.dart`

Expected: PASS (existing implementation should work)

**Step 3: Commit**

```bash
git add packages/audiflow_domain/test/features/feed/datasources/local/episode_local_datasource_test.dart
git commit -m "test(domain): add tests for episode batch upsert"
```

---

## Task 6: Create Streaming FeedParserService

Modify the service to support isolate parsing with progress streaming.

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/feed_parser_service.dart`

**Step 1: Write the test**

Create test file `packages/audiflow_domain/test/features/feed/services/feed_parser_service_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late EpisodeLocalDatasource episodeDatasource;
  late FeedParserService service;

  const testXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Test Podcast</title>
    <description>Test description</description>
    <item>
      <guid>new-episode</guid>
      <title>New Episode</title>
      <enclosure url="https://example.com/new.mp3" type="audio/mpeg"/>
    </item>
    <item>
      <guid>known-episode</guid>
      <title>Known Episode</title>
      <enclosure url="https://example.com/known.mp3" type="audio/mpeg"/>
    </item>
  </channel>
</rss>
''';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    episodeDatasource = EpisodeLocalDatasource(db);
    service = FeedParserService();
  });

  tearDown(() async {
    service.dispose();
    await db.close();
  });

  group('fetchAndParseWithProgress', () {
    test('emits progress events in correct order', () async {
      final events = <FeedParseProgress>[];

      await for (final event in service.parseWithProgress(
        xmlContent: testXml,
        podcastId: 1,
        knownGuids: {},
        onBatchReady: (companions) async {
          await episodeDatasource.upsertAll(companions);
        },
      )) {
        events.add(event);
      }

      expect(events.first, isA<FeedMetaReady>());
      expect(events.last, isA<FeedParseComplete>());

      final complete = events.last as FeedParseComplete;
      expect(complete.total, 2);
    });

    test('stops early when known GUID found', () async {
      final events = <FeedParseProgress>[];

      await for (final event in service.parseWithProgress(
        xmlContent: testXml,
        podcastId: 1,
        knownGuids: {'known-episode'},
        onBatchReady: (companions) async {
          await episodeDatasource.upsertAll(companions);
        },
      )) {
        events.add(event);
      }

      final complete = events.last as FeedParseComplete;
      expect(complete.total, 1);
      expect(complete.stoppedEarly, isTrue);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && dart test test/features/feed/services/feed_parser_service_test.dart`

Expected: FAIL - `parseWithProgress` method not found

**Step 3: Write implementation**

Edit `packages/audiflow_domain/lib/src/features/feed/services/feed_parser_service.dart`, add the new method:

```dart
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../common/database/app_database.dart';
import '../../../common/providers/logger_provider.dart';
import '../builders/podcast_builder.dart';
import '../models/feed_parse_progress.dart';

part 'feed_parser_service.g.dart';

// ... existing code ...

class FeedParserService {
  static const _upsertBatchSize = 20;

  final PodcastRssParser _parser;
  final DefaultPodcastBuilder _builder;
  final Logger? _logger;

  FeedParserService({
    PodcastRssParser? parser,
    DefaultPodcastBuilder? builder,
    Logger? logger,
  }) : _parser = parser ?? PodcastRssParser(logger: logger),
       _builder = builder ?? DefaultPodcastBuilder(logger: logger),
       _logger = logger;

  // ... existing parseFromUrl and parseFromString methods ...

  /// Parses XML content in isolate with progress streaming and batched storage.
  ///
  /// Emits [FeedParseProgress] events for UI updates.
  /// Calls [onBatchReady] when a batch of episodes is ready to store.
  Stream<FeedParseProgress> parseWithProgress({
    required String xmlContent,
    required int podcastId,
    required Set<String> knownGuids,
    required Future<void> Function(List<EpisodesCompanion> companions) onBatchReady,
    int batchSize = _upsertBatchSize,
  }) async* {
    _logger?.i('Starting isolate parse for podcast $podcastId');
    _logger?.d('Known GUIDs: ${knownGuids.length}');

    final buffer = <EpisodesCompanion>[];
    var totalParsed = 0;

    await for (final progress in IsolateRssParser.parse(
      feedXml: xmlContent,
      knownGuids: knownGuids,
    )) {
      switch (progress) {
        case ParsedPodcastMeta(:final title, :final description, :final imageUrl, :final author):
          _logger?.d('Parsed metadata: $title');
          yield FeedMetaReady(
            title: title,
            description: description,
            imageUrl: imageUrl,
            author: author,
          );

        case ParsedEpisode(:final guid, :final title, :final description, :final enclosureUrl, :final enclosureType, :final enclosureLength, :final publishDate, :final duration, :final episodeNumber, :final seasonNumber, :final imageUrl):
          buffer.add(EpisodesCompanion.insert(
            podcastId: podcastId,
            guid: guid ?? enclosureUrl ?? 'unknown-${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            description: Value(description),
            audioUrl: enclosureUrl ?? '',
            audioType: Value(enclosureType),
            audioLength: Value(enclosureLength),
            publishedAt: Value(publishDate),
            durationSeconds: Value(duration?.inSeconds),
            episodeNumber: Value(episodeNumber),
            seasonNumber: Value(seasonNumber),
            imageUrl: Value(imageUrl),
          ));
          totalParsed++;

          if (batchSize <= buffer.length) {
            await onBatchReady(buffer.toList());
            buffer.clear();
            _logger?.d('Stored batch, total: $totalParsed');
            yield EpisodesBatchStored(totalSoFar: totalParsed);
          }

        case ParseComplete(:final stoppedEarly):
          // Flush remaining buffer
          if (buffer.isNotEmpty) {
            await onBatchReady(buffer.toList());
            buffer.clear();
          }

          _logger?.i('Parse complete: $totalParsed episodes, stoppedEarly: $stoppedEarly');
          yield FeedParseComplete(total: totalParsed, stoppedEarly: stoppedEarly);
      }
    }
  }

  /// Disposes resources used by this service.
  void dispose() {
    _parser.dispose();
  }
}
```

**Step 4: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && dart test test/features/feed/services/feed_parser_service_test.dart`

Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/feed_parser_service.dart \
        packages/audiflow_domain/lib/src/features/feed/services/feed_parser_service.g.dart \
        packages/audiflow_domain/test/features/feed/services/feed_parser_service_test.dart
git commit -m "feat(domain): add streaming parseWithProgress to FeedParserService"
```

---

## Task 7: Add PodcastDetailState Model

Create the state model for podcast detail screen with refresh progress.

**Files:**
- Create: `packages/audiflow_app/lib/features/podcast_detail/presentation/models/podcast_detail_state.dart`

**Step 1: Write the test**

Create test file `packages/audiflow_app/test/features/podcast_detail/presentation/models/podcast_detail_state_test.dart`:

```dart
import 'package:audiflow_app/features/podcast_detail/presentation/models/podcast_detail_state.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:test/test.dart';

void main() {
  group('PodcastDetailState', () {
    final mockFeed = ParsedFeed(
      podcast: PodcastFeed.fromData(
        parsedAt: DateTime.now(),
        sourceUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        description: 'Test description',
      ),
      episodes: [],
      errors: [],
      warnings: [],
    );

    test('loaded state has default values', () {
      final state = PodcastDetailState.loaded(feed: mockFeed);

      expect(state.feed, mockFeed);
      expect(state.isRefreshing, isFalse);
      expect(state.refreshProgress, isNull);
      expect(state.refreshError, isNull);
    });

    test('copyWith updates fields', () {
      final state = PodcastDetailState.loaded(feed: mockFeed);
      final updated = state.copyWith(
        isRefreshing: true,
        refreshProgress: 50,
      );

      expect(updated.isRefreshing, isTrue);
      expect(updated.refreshProgress, 50);
      expect(updated.feed, mockFeed);
    });

    test('copyWith clears refresh state', () {
      final state = PodcastDetailState.loaded(
        feed: mockFeed,
        isRefreshing: true,
        refreshProgress: 100,
      );
      final cleared = state.copyWith(
        isRefreshing: false,
        refreshProgress: null,
      );

      expect(cleared.isRefreshing, isFalse);
      expect(cleared.refreshProgress, isNull);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/models/podcast_detail_state_test.dart`

Expected: FAIL - `PodcastDetailState` not found

**Step 3: Write implementation**

Create `packages/audiflow_app/lib/features/podcast_detail/presentation/models/podcast_detail_state.dart`:

```dart
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'podcast_detail_state.freezed.dart';

/// State for the podcast detail screen.
@freezed
class PodcastDetailState with _$PodcastDetailState {
  const factory PodcastDetailState.loaded({
    required ParsedFeed feed,
    @Default(false) bool isRefreshing,
    int? refreshProgress,
    String? refreshError,
  }) = _Loaded;
}
```

**Step 4: Run code generation**

Run: `cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs`

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/models/podcast_detail_state_test.dart`

Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/models/podcast_detail_state.dart \
        packages/audiflow_app/lib/features/podcast_detail/presentation/models/podcast_detail_state.freezed.dart \
        packages/audiflow_app/test/features/podcast_detail/presentation/models/podcast_detail_state_test.dart
git commit -m "feat(app): add PodcastDetailState with refresh progress"
```

---

## Task 8: Update PodcastDetailController

Modify controller to show cached first, refresh in background with progress.

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart`

**Step 1: Write the test**

Create test file `packages/audiflow_app/test/features/podcast_detail/presentation/controllers/podcast_detail_controller_test.dart`:

```dart
import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldFetchRemote', () {
    test('returns false when offline', () {
      expect(
        shouldFetchRemote(
          lastFetchedAt: DateTime.now(),
          isOnline: false,
        ),
        isFalse,
      );
    });

    test('returns true when never fetched', () {
      expect(
        shouldFetchRemote(
          lastFetchedAt: null,
          isOnline: true,
        ),
        isTrue,
      );
    });

    test('returns false within refresh window', () {
      final recentFetch = DateTime.now().subtract(const Duration(minutes: 5));
      expect(
        shouldFetchRemote(
          lastFetchedAt: recentFetch,
          isOnline: true,
        ),
        isFalse,
      );
    });

    test('returns true after refresh window', () {
      final oldFetch = DateTime.now().subtract(const Duration(minutes: 15));
      expect(
        shouldFetchRemote(
          lastFetchedAt: oldFetch,
          isOnline: true,
        ),
        isTrue,
      );
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/controllers/podcast_detail_controller_test.dart`

Expected: FAIL - `shouldFetchRemote` not found

**Step 3: Write implementation**

Edit `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/podcast_detail_state.dart';
import '../widgets/episode_filter_chips.dart';

part 'podcast_detail_controller.g.dart';

/// Refresh window in minutes - skip fetch if last fetched within this time.
const _refreshWindowMinutes = 10;

/// Checks if remote fetch should be performed.
///
/// Returns false if:
/// - Offline
/// - Within refresh window (10 minutes)
bool shouldFetchRemote({
  required DateTime? lastFetchedAt,
  required bool isOnline,
}) {
  if (!isOnline) return false;
  if (lastFetchedAt == null) return true;

  const refreshWindow = Duration(minutes: _refreshWindowMinutes);
  final elapsed = DateTime.now().difference(lastFetchedAt);
  return refreshWindow <= elapsed;
}

// ... existing providers (subscriptionRepositoryAccess, feedHttpClient) ...

/// Controller for podcast detail screen with cached-first loading.
@riverpod
class PodcastDetailController extends _$PodcastDetailController {
  @override
  Future<PodcastDetailState> build(String feedUrl) async {
    final logger = ref.watch(namedLoggerProvider('PodcastDetail'));
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
    final episodeDatasource = ref.read(episodeLocalDatasourceProvider);

    // Check subscription status
    final subscription = await subscriptionRepo.getByFeedUrl(feedUrl);
    final isSubscribed = subscription != null;

    // Check connectivity
    final connectivity = ref.read(connectivityServiceProvider);
    final isOnline = await connectivity.isConnected;

    // Try to load cached data first
    ParsedFeed? cachedFeed;
    if (isSubscribed) {
      final cachedEpisodes = await episodeDatasource.getByPodcastId(subscription.id);
      if (cachedEpisodes.isNotEmpty) {
        // Build ParsedFeed from cached data
        cachedFeed = await _buildFeedFromCache(subscription, cachedEpisodes);
        logger.d('Loaded ${cachedEpisodes.length} cached episodes');
      }
    }

    // Determine if refresh needed
    final needsRefresh = shouldFetchRemote(
      lastFetchedAt: subscription?.lastFetchedAt,
      isOnline: isOnline,
    );

    // If we have cached data and don't need refresh, return immediately
    if (cachedFeed != null && !needsRefresh) {
      logger.i('Using cached data, no refresh needed');
      return PodcastDetailState.loaded(feed: cachedFeed);
    }

    // If we have cached data but need refresh, return cached and refresh in background
    if (cachedFeed != null && needsRefresh) {
      logger.i('Returning cached data, starting background refresh');
      _refreshInBackground(feedUrl, subscription!.id);
      return PodcastDetailState.loaded(
        feed: cachedFeed,
        isRefreshing: true,
      );
    }

    // No cached data - must fetch and parse now
    logger.i('No cache, fetching fresh data');
    final feed = await _fetchAndParse(feedUrl);

    // Persist if subscribed
    if (isSubscribed) {
      final episodeRepo = ref.read(episodeRepositoryProvider);
      await episodeRepo.upsertFromFeedItems(subscription.id, feed.episodes);
      await subscriptionRepo.updateLastFetchedAt(subscription.id, DateTime.now());
    }

    return PodcastDetailState.loaded(feed: feed);
  }

  /// Forces a refresh, bypassing the refresh window.
  Future<void> forceRefresh() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncData(currentState.copyWith(isRefreshing: true));

    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
    final subscription = await subscriptionRepo.getByFeedUrl(
      currentState.feed.podcast.sourceUrl,
    );

    if (subscription != null) {
      await _refreshInBackground(
        currentState.feed.podcast.sourceUrl,
        subscription.id,
      );
    }
  }

  Future<void> _refreshInBackground(String feedUrl, int podcastId) async {
    final logger = ref.read(namedLoggerProvider('PodcastDetail'));
    final dio = ref.read(feedHttpClientProvider);
    final feedParser = ref.read(feedParserServiceProvider);
    final episodeDatasource = ref.read(episodeLocalDatasourceProvider);
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);

    try {
      // Fetch XML
      final response = await dio.get<String>(
        feedUrl,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.data == null || response.data!.isEmpty) {
        throw PodcastException(
          message: 'Empty response from feed URL',
          sourceUrl: feedUrl,
        );
      }

      // Get known GUIDs for early-stop
      final knownGuids = await episodeDatasource.getGuidsByPodcastId(podcastId);
      logger.d('Known GUIDs: ${knownGuids.length}');

      // Parse with progress
      await for (final progress in feedParser.parseWithProgress(
        xmlContent: response.data!,
        podcastId: podcastId,
        knownGuids: knownGuids,
        onBatchReady: (companions) async {
          await episodeDatasource.upsertAll(companions);
        },
      )) {
        switch (progress) {
          case EpisodesBatchStored(:final totalSoFar):
            final currentState = state.valueOrNull;
            if (currentState != null) {
              state = AsyncData(currentState.copyWith(
                refreshProgress: totalSoFar,
              ));
            }

          case FeedParseComplete(:final total, :final stoppedEarly):
            logger.i('Refresh complete: $total episodes, stoppedEarly: $stoppedEarly');

            // Update last fetched timestamp
            await subscriptionRepo.updateLastFetchedAt(podcastId, DateTime.now());

            // Reload feed from database
            final subscription = await subscriptionRepo.getById(podcastId);
            final episodes = await episodeDatasource.getByPodcastId(podcastId);
            final newFeed = await _buildFeedFromCache(subscription!, episodes);

            state = AsyncData(PodcastDetailState.loaded(
              feed: newFeed,
              isRefreshing: false,
            ));

          case FeedMetaReady():
            // Metadata already handled, no action needed
            break;
        }
      }
    } on NetworkException catch (e) {
      logger.e('Network error during refresh: $e');
      final currentState = state.valueOrNull;
      if (currentState != null) {
        state = AsyncData(currentState.copyWith(
          isRefreshing: false,
          refreshError: 'Could not refresh: ${e.message}',
        ));
      }
    } catch (e, stack) {
      logger.e('Error during refresh', error: e, stackTrace: stack);
      final currentState = state.valueOrNull;
      if (currentState != null) {
        state = AsyncData(currentState.copyWith(isRefreshing: false));
      }
    }
  }

  Future<ParsedFeed> _fetchAndParse(String feedUrl) async {
    final dio = ref.read(feedHttpClientProvider);
    final feedParser = ref.read(feedParserServiceProvider);

    final response = await dio.get<String>(
      feedUrl,
      options: Options(responseType: ResponseType.plain),
    );

    if (response.data == null || response.data!.isEmpty) {
      throw PodcastException(
        message: 'Empty response from feed URL',
        sourceUrl: feedUrl,
      );
    }

    return feedParser.parseFromString(response.data!);
  }

  Future<ParsedFeed> _buildFeedFromCache(
    Subscription subscription,
    List<Episode> episodes,
  ) async {
    // Convert cached episodes back to PodcastItem format
    final items = episodes.map((e) => PodcastItem.fromData(
      parsedAt: e.createdAt ?? DateTime.now(),
      sourceUrl: subscription.feedUrl,
      title: e.title,
      description: e.description ?? '',
      guid: e.guid,
      enclosureUrl: e.audioUrl,
      enclosureType: e.audioType,
      enclosureLength: e.audioLength,
      publishDate: e.publishedAt,
      duration: e.durationSeconds != null
          ? Duration(seconds: e.durationSeconds!)
          : null,
      episodeNumber: e.episodeNumber,
      seasonNumber: e.seasonNumber,
      images: e.imageUrl != null ? [PodcastImage(url: e.imageUrl!)] : [],
    )).toList();

    final feed = PodcastFeed.fromData(
      parsedAt: subscription.lastFetchedAt ?? DateTime.now(),
      sourceUrl: subscription.feedUrl,
      title: subscription.title,
      description: subscription.description ?? '',
      images: subscription.imageUrl != null
          ? [PodcastImage(url: subscription.imageUrl!)]
          : [],
      author: subscription.author,
    );

    return ParsedFeed(
      podcast: feed,
      episodes: items,
      errors: [],
      warnings: [],
    );
  }
}

// Keep existing providers for backward compatibility
@riverpod
Future<ParsedFeed> podcastDetail(Ref ref, String feedUrl) async {
  final controller = ref.watch(podcastDetailControllerProvider(feedUrl));
  return controller.maybeWhen(
    data: (state) => state.feed,
    orElse: () => throw StateError('Feed not loaded'),
  );
}

// ... rest of existing providers (episodeProgress, episodeFilterState, filteredEpisodes) ...
```

**Step 4: Run code generation**

Run: `cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs`

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/controllers/podcast_detail_controller_test.dart`

Expected: PASS

**Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart \
        packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.g.dart \
        packages/audiflow_app/test/features/podcast_detail/presentation/controllers/podcast_detail_controller_test.dart
git commit -m "feat(app): update PodcastDetailController with cached-first loading"
```

---

## Task 9: Update Podcast Detail Screen UI

Add subtle refresh indicator to the screen.

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart`

**Step 1: Review current implementation**

Read the current screen implementation to understand the structure.

**Step 2: Update screen to use new controller**

Edit `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart`:

Add refresh indicator in the header:

```dart
// In the build method, replace the existing AsyncValue handling:

@override
Widget build(BuildContext context, WidgetRef ref) {
  final stateAsync = ref.watch(podcastDetailControllerProvider(feedUrl));

  return stateAsync.when(
    loading: () => const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
    error: (error, stack) => Scaffold(
      body: Center(child: Text('Error: $error')),
    ),
    data: (state) => _buildContent(context, ref, state),
  );
}

Widget _buildContent(
  BuildContext context,
  WidgetRef ref,
  PodcastDetailState state,
) {
  final theme = Theme.of(context);
  final feed = state.feed;

  return Scaffold(
    body: RefreshIndicator(
      onRefresh: () => ref
          .read(podcastDetailControllerProvider(feedUrl).notifier)
          .forceRefresh(),
      child: CustomScrollView(
        slivers: [
          // ... existing SliverAppBar ...

          // Add refresh progress indicator
          if (state.isRefreshing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.refreshProgress != null
                          ? 'Updating... ${state.refreshProgress} episodes'
                          : 'Checking for new episodes...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Show error if refresh failed
          if (state.refreshError != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  state.refreshError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),

          // ... rest of existing content (filter chips, episode list) ...
        ],
      ),
    ),
  );
}
```

**Step 3: Run analyzer**

Run: `cd packages/audiflow_app && dart analyze lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart`

Expected: No errors

**Step 4: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart
git commit -m "feat(app): add refresh progress indicator to podcast detail screen"
```

---

## Task 10: Integration Testing

Run full test suite and manual verification.

**Step 1: Run all tests**

Run: `melos run test`

Expected: All tests pass

**Step 2: Run analyzer**

Run: `melos run analyze`

Expected: No errors

**Step 3: Build app**

Run: `cd packages/audiflow_app && flutter build apk --flavor dev -t lib/main_dev.dart --debug`

Expected: Build succeeds

**Step 4: Commit final changes**

```bash
git add -A
git commit -m "chore: complete episode list rendering optimization"
```

---

## Summary

This implementation plan addresses the UI freeze issue with:

1. **Isolate-based parsing** (Tasks 1-2): XML parsing runs in a separate isolate
2. **Early-stop optimization** (Tasks 2-3): Parsing stops when known GUIDs are found
3. **Batched storage** (Tasks 4-6): Episodes stored in batches of 20
4. **Cached-first loading** (Tasks 7-8): Display cached data instantly
5. **Progress feedback** (Task 9): UI shows refresh status

**Expected outcomes:**
- Fresh podcast (500 eps): No freeze, ~3s background
- Subscribed (5 new eps): No freeze, ~200ms
- Within refresh window: Instant (~100ms)
- Offline: Instant (~100ms)
