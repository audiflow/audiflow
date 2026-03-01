# Podcast Transcript & Chapter Support - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add podcast transcript and chapter support with read-along playback, full-text search, offline reading, and chapter navigation.

**Architecture:** RSS `<podcast:transcript>` and `<podcast:chapters>` tags are extracted during feed parsing. Chapter data is stored immediately in Drift tables. Transcript metadata is stored during sync, but file content (SRT/VTT) is fetched lazily on first play/demand. Parsed segments are stored in Drift for timestamp range queries and FTS5 search. UI adds a "Transcript" tab to the player screen with a unified timeline merging chapters and transcript segments.

**Tech Stack:** Drift (SQLite + FTS5), Riverpod, Dio, xml package (existing), Flutter

**Design doc:** `docs/plans/2026-03-01-podcast-transcript-design.md`

---

## Task 1: RSS Transcript Extraction in Streaming XML Parser

Extract `<podcast:transcript>` elements from RSS item XML in the streaming parser, storing them in `itemData` for the entity factory.

**Files:**
- Modify: `packages/audiflow_podcast/lib/src/parser/streaming_xml_parser.dart`
- Test: `packages/audiflow_podcast/test/parser/streaming_xml_parser_transcript_test.dart`

**Step 1: Write the failing test**

Create test file that verifies transcript elements are extracted from item XML:

```dart
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('Podcast transcript extraction', () {
    test('should extract transcript elements from item', () async {
      final xml = buildRssXml(
        itemExtra: '''
          <podcast:transcript url="https://example.com/ep1.vtt" type="text/vtt" language="en" rel="captions" />
          <podcast:transcript url="https://example.com/ep1.srt" type="application/srt" />
        ''',
      );

      final entities = await parseXmlToEntities(xml);
      final item = entities.whereType<PodcastItem>().first;

      expect(item.hasTranscripts, isTrue);
      expect(item.transcripts!.length, equals(2));

      final vtt = item.transcripts!.first;
      expect(vtt.url, equals('https://example.com/ep1.vtt'));
      expect(vtt.type, equals('text/vtt'));
      expect(vtt.language, equals('en'));
      expect(vtt.rel, equals('captions'));
      expect(vtt.isVtt, isTrue);

      final srt = item.transcripts![1];
      expect(srt.url, equals('https://example.com/ep1.srt'));
      expect(srt.type, equals('application/srt'));
      expect(srt.language, isNull);
      expect(srt.isSrt, isTrue);
    });

    test('should return null transcripts when none present', () async {
      final xml = buildRssXml();
      final entities = await parseXmlToEntities(xml);
      final item = entities.whereType<PodcastItem>().first;

      expect(item.hasTranscripts, isFalse);
    });
  });
}
```

Create `test_helpers.dart` if it doesn't exist, with `buildRssXml()` and `parseXmlToEntities()` helpers.

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_podcast && flutter test test/parser/streaming_xml_parser_transcript_test.dart`
Expected: FAIL (transcripts not parsed)

**Step 3: Implement transcript extraction**

In `streaming_xml_parser.dart`, add handling for `podcast:transcript` in `_processItemChildElement` and `_handleItemElementEnd`:

```dart
// In _processItemChildElement (streaming path)
// After content:encoded handling:
if (element.name.qualified == 'podcast:transcript') {
  _addTranscriptToItemData(element, itemData);
}

// In _handleItemElementEnd (DOM path)
// After content:encoded handling:
if (element.name.qualified == 'podcast:transcript') {
  _addTranscriptToItemData(element, _state.currentItemData);
}
```

Add helper method:

```dart
void _addTranscriptToItemData(
  XmlElement element,
  Map<String, dynamic> itemData,
) {
  final url = element.getAttribute('url');
  final type = element.getAttribute('type');
  if (url == null || type == null) return;

  final transcript = <String, dynamic>{
    'url': url,
    'type': type,
    'language': element.getAttribute('language'),
    'rel': element.getAttribute('rel'),
  };

  final transcripts =
      itemData['transcripts'] as List<Map<String, dynamic>>? ?? [];
  transcripts.add(transcript);
  itemData['transcripts'] = transcripts;
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_podcast && flutter test test/parser/streaming_xml_parser_transcript_test.dart`
Expected: PASS

**Step 5: Commit**

```
feat(podcast): extract podcast:transcript elements from RSS
```

---

## Task 2: RSS Chapter Extraction in Streaming XML Parser

Extract `<podcast:chapters>` (Podlove Simple Chapters `<psc:chapter>`) from RSS item XML.

**Files:**
- Modify: `packages/audiflow_podcast/lib/src/parser/streaming_xml_parser.dart`
- Test: `packages/audiflow_podcast/test/parser/streaming_xml_parser_chapter_test.dart`

**Step 1: Write the failing test**

```dart
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('Podcast chapter extraction', () {
    test('should extract psc:chapter elements from item', () async {
      final xml = buildRssXml(
        itemExtra: '''
          <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
            <psc:chapter start="00:00:00.000" title="Introduction" href="https://example.com" image="https://example.com/img.jpg" />
            <psc:chapter start="00:05:30.000" title="Main Topic" />
            <psc:chapter start="01:10:00.000" title="Wrap Up" />
          </psc:chapters>
        ''',
      );

      final entities = await parseXmlToEntities(xml);
      final item = entities.whereType<PodcastItem>().first;

      expect(item.hasChapters, isTrue);
      expect(item.chapters!.length, equals(3));

      final intro = item.chapters!.first;
      expect(intro.title, equals('Introduction'));
      expect(intro.startTime, equals(Duration.zero));
      expect(intro.url, equals('https://example.com'));
      expect(intro.imageUrl, equals('https://example.com/img.jpg'));

      final main = item.chapters![1];
      expect(main.title, equals('Main Topic'));
      expect(
        main.startTime,
        equals(const Duration(minutes: 5, seconds: 30)),
      );

      final wrap = item.chapters![2];
      expect(wrap.startTime, equals(const Duration(hours: 1, minutes: 10)));
    });

    test('should return null chapters when none present', () async {
      final xml = buildRssXml();
      final entities = await parseXmlToEntities(xml);
      final item = entities.whereType<PodcastItem>().first;

      expect(item.hasChapters, isFalse);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_podcast && flutter test test/parser/streaming_xml_parser_chapter_test.dart`
Expected: FAIL

**Step 3: Implement chapter extraction**

In `streaming_xml_parser.dart`:

```dart
// In _processItemChildElement (streaming path)
if (elementName == 'chapters' &&
    (element.name.qualified.startsWith('psc:') ||
     element.namespaceUri == 'http://podlove.org/simple-chapters')) {
  _extractPscChapters(element, itemData);
}

// In _handleItemElementEnd (DOM path) - same logic for _state.currentItemData
```

Add helper:

```dart
void _extractPscChapters(
  XmlElement chaptersElement,
  Map<String, dynamic> itemData,
) {
  final chapters = <Map<String, dynamic>>[];

  for (final child in chaptersElement.children) {
    if (child is! XmlElement) continue;
    if (child.localName != 'chapter') continue;

    final start = child.getAttribute('start');
    final title = child.getAttribute('title');
    if (start == null || title == null) continue;

    chapters.add({
      'title': title,
      'startTime': _parseChapterTimestamp(start),
      'url': child.getAttribute('href'),
      'imageUrl': child.getAttribute('image'),
    });
  }

  if (chapters.isNotEmpty) {
    itemData['chapters'] = chapters;
  }
}

Duration? _parseChapterTimestamp(String timestamp) {
  // Format: HH:MM:SS.mmm or HH:MM:SS
  final parts = timestamp.split(':');
  if (parts.length < 3) return null;

  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = int.tryParse(parts[1]) ?? 0;
  final secondsParts = parts[2].split('.');
  final seconds = int.tryParse(secondsParts[0]) ?? 0;
  final millis = secondsParts.length < 2
      ? 0
      : int.tryParse(secondsParts[1].padRight(3, '0').substring(0, 3)) ?? 0;

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: millis,
  );
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_podcast && flutter test test/parser/streaming_xml_parser_chapter_test.dart`
Expected: PASS

**Step 5: Commit**

```
feat(podcast): extract psc:chapter elements from RSS
```

---

## Task 3: Wire Entity Factory _extractTranscripts and _extractChapters

Replace the TODO placeholders in `entity_factory.dart` with actual implementations that convert the parsed `itemData` maps into model objects.

**Files:**
- Modify: `packages/audiflow_podcast/lib/src/parser/entity_factory.dart`
- Test: `packages/audiflow_podcast/test/parser/entity_factory_transcript_test.dart`

**Step 1: Write the failing test**

```dart
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('EntityFactory transcript/chapter extraction', () {
    test('should create PodcastItem with transcripts from itemData', () async {
      // End-to-end: parse XML -> EntityFactory -> PodcastItem
      final xml = buildRssXml(
        itemExtra: '''
          <podcast:transcript url="https://example.com/ep1.vtt" type="text/vtt" language="en" rel="captions" />
          <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
            <psc:chapter start="00:00:00.000" title="Intro" />
          </psc:chapters>
        ''',
      );

      final entities = await parseXmlToEntities(xml);
      final item = entities.whereType<PodcastItem>().first;

      expect(item.hasTranscripts, isTrue);
      expect(item.transcripts!.first.isVtt, isTrue);

      expect(item.hasChapters, isTrue);
      expect(item.chapters!.first.title, equals('Intro'));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_podcast && flutter test test/parser/entity_factory_transcript_test.dart`
Expected: FAIL (entity factory returns null for both)

**Step 3: Implement the extraction methods**

In `entity_factory.dart`, replace the TODO methods:

```dart
List<PodcastChapter>? _extractChapters(Map<String, dynamic> itemData) {
  final chaptersData = itemData['chapters'] as List<Map<String, dynamic>>?;
  if (chaptersData == null || chaptersData.isEmpty) return null;

  final chapters = <PodcastChapter>[];
  for (final data in chaptersData) {
    final title = data['title'] as String?;
    final startTime = data['startTime'] as Duration?;
    if (title == null || startTime == null) continue;

    chapters.add(PodcastChapter(
      title: title,
      startTime: startTime,
      url: data['url'] as String?,
      imageUrl: data['imageUrl'] as String?,
    ));
  }

  return chapters.isEmpty ? null : chapters;
}

List<PodcastTranscript>? _extractTranscripts(Map<String, dynamic> itemData) {
  final transcriptsData =
      itemData['transcripts'] as List<Map<String, dynamic>>?;
  if (transcriptsData == null || transcriptsData.isEmpty) return null;

  final transcripts = <PodcastTranscript>[];
  for (final data in transcriptsData) {
    final url = data['url'] as String?;
    final type = data['type'] as String?;
    if (url == null || type == null) continue;

    transcripts.add(PodcastTranscript(
      url: url,
      type: type,
      language: data['language'] as String?,
      rel: data['rel'] as String?,
    ));
  }

  return transcripts.isEmpty ? null : transcripts;
}
```

**Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_podcast && flutter test test/parser/entity_factory_transcript_test.dart`
Expected: PASS

**Step 5: Run all audiflow_podcast tests**

Run: `cd packages/audiflow_podcast && flutter test`
Expected: All PASS

**Step 6: Commit**

```
feat(podcast): wire transcript and chapter extraction in entity factory
```

---

## Task 4: SRT File Parser

Create a parser for SubRip (.srt) transcript files.

**Files:**
- Create: `packages/audiflow_podcast/lib/src/parser/transcript/transcript_segment.dart`
- Create: `packages/audiflow_podcast/lib/src/parser/transcript/srt_parser.dart`
- Test: `packages/audiflow_podcast/test/parser/transcript/srt_parser_test.dart`
- Create: `packages/audiflow_podcast/test/fixtures/sample.srt`

**Step 1: Create the TranscriptSegment model**

```dart
/// A single timed segment from a transcript file.
class TranscriptSegment {
  const TranscriptSegment({
    required this.startMs,
    required this.endMs,
    required this.text,
    this.speaker,
  });

  final int startMs;
  final int endMs;
  final String text;
  final String? speaker;
}
```

**Step 2: Create test fixture**

`packages/audiflow_podcast/test/fixtures/sample.srt`:
```
1
00:00:00,000 --> 00:00:05,500
Welcome to the show.

2
00:00:05,500 --> 00:00:12,300
Today we're talking about
podcast transcripts.

3
00:01:00,000 --> 00:01:10,000
And that wraps things up.
```

**Step 3: Write the failing test**

```dart
import 'dart:io';

import 'package:audiflow_podcast/src/parser/transcript/srt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SrtParser', () {
    late SrtParser parser;

    setUp(() {
      parser = SrtParser();
    });

    test('should parse SRT content into segments', () {
      final content = File('test/fixtures/sample.srt').readAsStringSync();
      final segments = parser.parse(content);

      expect(segments.length, equals(3));

      expect(segments[0].startMs, equals(0));
      expect(segments[0].endMs, equals(5500));
      expect(segments[0].text, equals('Welcome to the show.'));

      expect(segments[1].startMs, equals(5500));
      expect(segments[1].endMs, equals(12300));
      expect(segments[1].text, equals('Today we\'re talking about podcast transcripts.'));

      expect(segments[2].startMs, equals(60000));
      expect(segments[2].endMs, equals(70000));
    });

    test('should return empty list for empty content', () {
      expect(parser.parse(''), isEmpty);
    });

    test('should skip malformed entries gracefully', () {
      const content = '''
1
INVALID --> 00:00:05,000
Some text

2
00:00:05,000 --> 00:00:10,000
Valid text
''';
      final segments = parser.parse(content);
      expect(segments.length, equals(1));
      expect(segments[0].text, equals('Valid text'));
    });
  });
}
```

**Step 4: Run test to verify it fails**

Run: `cd packages/audiflow_podcast && flutter test test/parser/transcript/srt_parser_test.dart`
Expected: FAIL (file not found)

**Step 5: Implement SrtParser**

```dart
import 'transcript_segment.dart';

/// Parses SubRip (.srt) transcript files into timed segments.
class SrtParser {
  /// Parses SRT content string into a list of transcript segments.
  List<TranscriptSegment> parse(String content) {
    if (content.trim().isEmpty) return [];

    final segments = <TranscriptSegment>[];
    // Split by double newline (blank line) to get blocks
    final blocks = content.trim().split(RegExp(r'\n\s*\n'));

    for (final block in blocks) {
      final segment = _parseBlock(block.trim());
      if (segment != null) {
        segments.add(segment);
      }
    }

    return segments;
  }

  TranscriptSegment? _parseBlock(String block) {
    final lines = block.split('\n');
    if (3 <= lines.length) {
      // Line 0: sequence number (skip)
      // Line 1: timestamps
      // Lines 2+: text
      return _parseTimedBlock(lines.sublist(1));
    } else if (2 <= lines.length) {
      return _parseTimedBlock(lines);
    }
    return null;
  }

  TranscriptSegment? _parseTimedBlock(List<String> lines) {
    final timestampLine = lines[0];
    final match = RegExp(
      r'(\d{2}:\d{2}:\d{2}[,\.]\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2}[,\.]\d{3})',
    ).firstMatch(timestampLine);

    if (match == null) return null;

    final startMs = _parseTimestamp(match.group(1)!);
    final endMs = _parseTimestamp(match.group(2)!);
    if (startMs == null || endMs == null) return null;

    final text = lines.sublist(1).join(' ').trim();
    if (text.isEmpty) return null;

    return TranscriptSegment(startMs: startMs, endMs: endMs, text: text);
  }

  int? _parseTimestamp(String timestamp) {
    // Format: HH:MM:SS,mmm or HH:MM:SS.mmm
    final normalized = timestamp.replaceAll(',', '.');
    final parts = normalized.split(':');
    if (parts.length < 3) return null;

    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    final secondsParts = parts[2].split('.');
    final seconds = int.tryParse(secondsParts[0]);
    final millis = secondsParts.length < 2
        ? 0
        : int.tryParse(secondsParts[1]);

    if (hours == null || minutes == null || seconds == null) return null;

    return (hours * 3600 + minutes * 60 + seconds) * 1000 + (millis ?? 0);
  }
}
```

**Step 6: Run test to verify it passes**

Run: `cd packages/audiflow_podcast && flutter test test/parser/transcript/srt_parser_test.dart`
Expected: PASS

**Step 7: Commit**

```
feat(podcast): add SRT transcript file parser
```

---

## Task 5: VTT File Parser

Create a parser for WebVTT (.vtt) transcript files with speaker identification support.

**Files:**
- Create: `packages/audiflow_podcast/lib/src/parser/transcript/vtt_parser.dart`
- Test: `packages/audiflow_podcast/test/parser/transcript/vtt_parser_test.dart`
- Create: `packages/audiflow_podcast/test/fixtures/sample.vtt`

**Step 1: Create test fixture**

`packages/audiflow_podcast/test/fixtures/sample.vtt`:
```
WEBVTT

00:00:00.000 --> 00:00:05.500
<v Alice>Welcome to the show.

00:00:05.500 --> 00:00:12.300
<v Bob>Thanks for having me.

NOTE This is a comment and should be ignored.

00:01:00.000 --> 00:01:10.000
And that wraps things up.
```

**Step 2: Write the failing test**

```dart
import 'dart:io';

import 'package:audiflow_podcast/src/parser/transcript/vtt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VttParser', () {
    late VttParser parser;

    setUp(() {
      parser = VttParser();
    });

    test('should parse VTT content with speakers', () {
      final content = File('test/fixtures/sample.vtt').readAsStringSync();
      final segments = parser.parse(content);

      expect(segments.length, equals(3));

      expect(segments[0].startMs, equals(0));
      expect(segments[0].endMs, equals(5500));
      expect(segments[0].text, equals('Welcome to the show.'));
      expect(segments[0].speaker, equals('Alice'));

      expect(segments[1].speaker, equals('Bob'));

      // Segment without speaker tag
      expect(segments[2].speaker, isNull);
      expect(segments[2].text, equals('And that wraps things up.'));
    });

    test('should skip WEBVTT header and NOTE blocks', () {
      const content = '''
WEBVTT

NOTE A note block
that spans multiple lines.

00:00:00.000 --> 00:00:05.000
Only valid cue.
''';
      final segments = parser.parse(content);
      expect(segments.length, equals(1));
    });

    test('should return empty list for empty content', () {
      expect(parser.parse(''), isEmpty);
    });
  });
}
```

**Step 3: Run test to verify it fails**

Run: `cd packages/audiflow_podcast && flutter test test/parser/transcript/vtt_parser_test.dart`
Expected: FAIL

**Step 4: Implement VttParser**

```dart
import 'transcript_segment.dart';

/// Parses WebVTT (.vtt) transcript files into timed segments.
///
/// Supports `<v SpeakerName>` voice tags for speaker identification.
class VttParser {
  static final _cueTimestampRegex = RegExp(
    r'(\d{2}:\d{2}:\d{2}\.\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2}\.\d{3})',
  );
  static final _voiceTagRegex = RegExp(r'<v\s+([^>]+)>');

  /// Parses VTT content string into a list of transcript segments.
  List<TranscriptSegment> parse(String content) {
    if (content.trim().isEmpty) return [];

    final segments = <TranscriptSegment>[];
    final blocks = content.trim().split(RegExp(r'\n\s*\n'));

    for (final block in blocks) {
      final trimmed = block.trim();

      // Skip WEBVTT header and NOTE blocks
      if (trimmed.startsWith('WEBVTT') || trimmed.startsWith('NOTE')) continue;

      final segment = _parseCueBlock(trimmed);
      if (segment != null) {
        segments.add(segment);
      }
    }

    return segments;
  }

  TranscriptSegment? _parseCueBlock(String block) {
    final lines = block.split('\n');

    // Find the timestamp line
    int timestampLineIndex = -1;
    for (var i = 0; i < lines.length; i++) {
      if (_cueTimestampRegex.hasMatch(lines[i])) {
        timestampLineIndex = i;
        break;
      }
    }

    if (timestampLineIndex == -1) return null;

    final match = _cueTimestampRegex.firstMatch(lines[timestampLineIndex])!;
    final startMs = _parseTimestamp(match.group(1)!);
    final endMs = _parseTimestamp(match.group(2)!);
    if (startMs == null || endMs == null) return null;

    // Text is everything after the timestamp line
    final textLines = lines.sublist(timestampLineIndex + 1);
    if (textLines.isEmpty) return null;

    final rawText = textLines.join(' ').trim();
    if (rawText.isEmpty) return null;

    // Extract speaker from voice tag
    final voiceMatch = _voiceTagRegex.firstMatch(rawText);
    final speaker = voiceMatch?.group(1);

    // Strip all HTML-like tags from text
    final cleanText = rawText.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    if (cleanText.isEmpty) return null;

    return TranscriptSegment(
      startMs: startMs,
      endMs: endMs,
      text: cleanText,
      speaker: speaker,
    );
  }

  int? _parseTimestamp(String timestamp) {
    final parts = timestamp.split(':');
    if (parts.length < 3) return null;

    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    final secondsParts = parts[2].split('.');
    final seconds = int.tryParse(secondsParts[0]);
    final millis = secondsParts.length < 2
        ? 0
        : int.tryParse(secondsParts[1]);

    if (hours == null || minutes == null || seconds == null) return null;

    return (hours * 3600 + minutes * 60 + seconds) * 1000 + (millis ?? 0);
  }
}
```

**Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_podcast && flutter test test/parser/transcript/vtt_parser_test.dart`
Expected: PASS

**Step 6: Commit**

```
feat(podcast): add VTT transcript file parser with speaker support
```

---

## Task 6: TranscriptFileParser Facade

Create a facade that selects the right parser based on MIME type.

**Files:**
- Create: `packages/audiflow_podcast/lib/src/parser/transcript/transcript_file_parser.dart`
- Test: `packages/audiflow_podcast/test/parser/transcript/transcript_file_parser_test.dart`
- Modify: `packages/audiflow_podcast/lib/audiflow_podcast.dart` (add exports)

**Step 1: Write the failing test**

```dart
import 'package:audiflow_podcast/src/parser/transcript/transcript_file_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TranscriptFileParser', () {
    late TranscriptFileParser parser;

    setUp(() {
      parser = TranscriptFileParser();
    });

    test('should parse SRT content by MIME type', () {
      const content = '1\n00:00:00,000 --> 00:00:05,000\nHello\n';
      final segments = parser.parse(content, mimeType: 'application/srt');

      expect(segments.length, equals(1));
      expect(segments[0].text, equals('Hello'));
    });

    test('should parse VTT content by MIME type', () {
      const content = 'WEBVTT\n\n00:00:00.000 --> 00:00:05.000\nHello\n';
      final segments = parser.parse(content, mimeType: 'text/vtt');

      expect(segments.length, equals(1));
      expect(segments[0].text, equals('Hello'));
    });

    test('should handle text/srt MIME type', () {
      const content = '1\n00:00:00,000 --> 00:00:05,000\nHello\n';
      final segments = parser.parse(content, mimeType: 'text/srt');

      expect(segments.length, equals(1));
    });

    test('should throw for unsupported MIME type', () {
      expect(
        () => parser.parse('content', mimeType: 'text/plain'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
```

**Step 2: Implement TranscriptFileParser**

```dart
import 'srt_parser.dart';
import 'transcript_segment.dart';
import 'vtt_parser.dart';

/// Facade that selects the right transcript parser based on MIME type.
class TranscriptFileParser {
  final _srtParser = SrtParser();
  final _vttParser = VttParser();

  /// Parses transcript content using the parser matching [mimeType].
  ///
  /// Supported types: `application/srt`, `text/srt`, `text/vtt`.
  /// Throws [UnsupportedError] for unknown types.
  List<TranscriptSegment> parse(
    String content, {
    required String mimeType,
  }) {
    return switch (mimeType) {
      'application/srt' || 'text/srt' => _srtParser.parse(content),
      'text/vtt' => _vttParser.parse(content),
      _ => throw UnsupportedError('Unsupported transcript type: $mimeType'),
    };
  }

  /// Whether the given MIME type is supported for parsing.
  static bool isSupported(String mimeType) {
    return mimeType == 'application/srt' ||
        mimeType == 'text/srt' ||
        mimeType == 'text/vtt';
  }
}
```

**Step 3: Add exports to audiflow_podcast.dart**

```dart
export 'src/parser/transcript/transcript_file_parser.dart';
export 'src/parser/transcript/transcript_segment.dart';
```

**Step 4: Run all tests**

Run: `cd packages/audiflow_podcast && flutter test`
Expected: All PASS

**Step 5: Commit**

```
feat(podcast): add TranscriptFileParser facade with MIME type routing
```

---

## Task 7: Drift Tables + Migration (v16 -> v17)

Add `EpisodeTranscripts`, `EpisodeChapters`, and `TranscriptSegments` Drift tables with migration.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/transcript/models/episode_transcript.dart`
- Create: `packages/audiflow_domain/lib/src/features/transcript/models/transcript_segment.dart`
- Create: `packages/audiflow_domain/lib/src/features/transcript/models/episode_chapter.dart`
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart`
- Test: `packages/audiflow_domain/test/common/database/migration_v17_test.dart`

**Step 1: Create Drift table definitions**

`episode_transcript.dart`:
```dart
import 'package:drift/drift.dart';

import '../../feed/models/episode.dart';

/// Drift table for episode transcript metadata.
///
/// Stores metadata (URL, type, language) during feed sync.
/// Actual transcript content is fetched lazily and stored in TranscriptSegments.
class EpisodeTranscripts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get episodeId => integer().references(Episodes, #id)();
  TextColumn get url => text()();
  TextColumn get type => text()();
  TextColumn get language => text().nullable()();
  TextColumn get rel => text().nullable()();
  DateTimeColumn get fetchedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {episodeId, url},
  ];
}
```

`transcript_segment.dart`:
```dart
import 'package:drift/drift.dart';

import 'episode_transcript.dart';

/// Drift table for parsed transcript segments.
///
/// Each row represents a timed text segment from a transcript file.
/// Indexed on (transcriptId, startMs) for efficient range queries.
class TranscriptSegments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transcriptId => integer().references(EpisodeTranscripts, #id)();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();
  TextColumn get text => text()();
  TextColumn get speaker => text().nullable()();
}
```

`episode_chapter.dart`:
```dart
import 'package:drift/drift.dart';

import '../../feed/models/episode.dart';

/// Drift table for episode chapters.
///
/// Stored during feed sync from psc:chapter elements.
class EpisodeChapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get episodeId => integer().references(Episodes, #id)();
  IntColumn get sortOrder => integer()();
  TextColumn get title => text()();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get imageUrl => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {episodeId, sortOrder},
  ];
}
```

**Step 2: Register tables and bump schema version**

In `app_database.dart`, add imports and register new tables in `@DriftDatabase`. Bump `schemaVersion` to 17. Add migration block:

```dart
// Migration from v16 to v17: add transcript and chapter tables
if (17 <= to && from < 17) {
  await m.createTable(episodeTranscripts);
  await m.createTable(transcriptSegments);
  await m.createTable(episodeChapters);
}
```

**Step 3: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

**Step 4: Write migration test**

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_domain/src/common/database/app_database.dart';

void main() {
  group('Migration v16 to v17', () {
    test('should create transcript and chapter tables', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      // Verify tables exist by inserting data
      // Insert a subscription first (FK dependency)
      final subId = await db.into(db.subscriptions).insert(
        SubscriptionsCompanion.insert(
          itunesId: 'test-1',
          feedUrl: 'https://example.com/feed.xml',
          title: 'Test Podcast',
          artistName: 'Test Artist',
          subscribedAt: DateTime.now(),
        ),
      );

      final episodeId = await db.into(db.episodes).insert(
        EpisodesCompanion.insert(
          podcastId: subId,
          guid: 'ep-1',
          title: 'Episode 1',
          audioUrl: 'https://example.com/ep1.mp3',
        ),
      );

      // Insert transcript metadata
      final transcriptId = await db.into(db.episodeTranscripts).insert(
        EpisodeTranscriptsCompanion.insert(
          episodeId: episodeId,
          url: 'https://example.com/ep1.vtt',
          type: 'text/vtt',
        ),
      );

      expect(0 < transcriptId, isTrue);

      // Insert transcript segment
      final segmentId = await db.into(db.transcriptSegments).insert(
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 0,
          endMs: 5000,
          text: 'Hello world',
        ),
      );

      expect(0 < segmentId, isTrue);

      // Insert chapter
      final chapterId = await db.into(db.episodeChapters).insert(
        EpisodeChaptersCompanion.insert(
          episodeId: episodeId,
          sortOrder: 0,
          title: 'Introduction',
          startMs: 0,
        ),
      );

      expect(0 < chapterId, isTrue);

      await db.close();
    });
  });
}
```

**Step 5: Run migration test**

Run: `cd packages/audiflow_domain && flutter test test/common/database/migration_v17_test.dart`
Expected: PASS

**Step 6: Commit**

```
feat(domain): add Drift tables for transcripts, segments, and chapters
```

---

## Task 8: Transcript Local Datasource

Create a datasource for transcript CRUD operations using Drift.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/transcript/datasources/local/transcript_local_datasource.dart`
- Test: `packages/audiflow_domain/test/features/transcript/datasources/local/transcript_local_datasource_test.dart`

**Step 1: Write the failing test**

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_domain/src/common/database/app_database.dart';
import 'package:audiflow_domain/src/features/transcript/datasources/local/transcript_local_datasource.dart';

void main() {
  late AppDatabase db;
  late TranscriptLocalDatasource datasource;
  late int episodeId;
  late int transcriptId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = TranscriptLocalDatasource(db);

    // Insert FK dependencies
    final subId = await db.into(db.subscriptions).insert(
      SubscriptionsCompanion.insert(
        itunesId: 'test-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test',
        artistName: 'Test',
        subscribedAt: DateTime.now(),
      ),
    );
    episodeId = await db.into(db.episodes).insert(
      EpisodesCompanion.insert(
        podcastId: subId,
        guid: 'ep-1',
        title: 'Episode 1',
        audioUrl: 'https://example.com/ep1.mp3',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('upsertMetas', () {
    test('should insert transcript metadata', () async {
      final companions = [
        EpisodeTranscriptsCompanion.insert(
          episodeId: episodeId,
          url: 'https://example.com/ep1.vtt',
          type: 'text/vtt',
          language: const Value('en'),
          rel: const Value('captions'),
        ),
      ];

      await datasource.upsertMetas(companions);

      final results = await datasource.getMetasByEpisodeId(episodeId);
      expect(results.length, equals(1));
      expect(results.first.url, equals('https://example.com/ep1.vtt'));
      expect(results.first.type, equals('text/vtt'));
    });
  });

  group('upsertSegments / getSegments', () {
    setUp(() async {
      transcriptId = await db.into(db.episodeTranscripts).insert(
        EpisodeTranscriptsCompanion.insert(
          episodeId: episodeId,
          url: 'https://example.com/ep1.vtt',
          type: 'text/vtt',
        ),
      );
    });

    test('should insert and query segments by time range', () async {
      final segments = [
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 0,
          endMs: 5000,
          text: 'First segment',
        ),
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 5000,
          endMs: 10000,
          text: 'Second segment',
        ),
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 10000,
          endMs: 15000,
          text: 'Third segment',
        ),
      ];

      await datasource.insertSegments(segments);

      final results = await datasource.getSegments(
        transcriptId,
        startMs: 4000,
        endMs: 11000,
      );

      // Should include segments that overlap the range
      expect(results.length, equals(2));
    });
  });

  group('markAsFetched', () {
    setUp(() async {
      transcriptId = await db.into(db.episodeTranscripts).insert(
        EpisodeTranscriptsCompanion.insert(
          episodeId: episodeId,
          url: 'https://example.com/ep1.vtt',
          type: 'text/vtt',
        ),
      );
    });

    test('should set fetchedAt timestamp', () async {
      expect(
        (await datasource.getMetasByEpisodeId(episodeId)).first.fetchedAt,
        isNull,
      );

      await datasource.markAsFetched(transcriptId);

      final result = (await datasource.getMetasByEpisodeId(episodeId)).first;
      expect(result.fetchedAt, isNotNull);
    });
  });
}
```

**Step 2: Implement TranscriptLocalDatasource**

```dart
import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';

/// Local datasource for transcript operations using Drift.
class TranscriptLocalDatasource {
  TranscriptLocalDatasource(this._db);

  final AppDatabase _db;

  /// Returns transcript metadata for an episode.
  Future<List<EpisodeTranscript>> getMetasByEpisodeId(int episodeId) {
    return (_db.select(_db.episodeTranscripts)
          ..where((t) => t.episodeId.equals(episodeId)))
        .get();
  }

  /// Upserts transcript metadata records.
  Future<void> upsertMetas(List<EpisodeTranscriptsCompanion> companions) async {
    await _db.batch((batch) {
      for (final companion in companions) {
        batch.insert(
          _db.episodeTranscripts,
          companion,
          onConflict: DoUpdate(
            (old) => companion,
            target: [
              _db.episodeTranscripts.episodeId,
              _db.episodeTranscripts.url,
            ],
          ),
        );
      }
    });
  }

  /// Bulk inserts transcript segments.
  Future<void> insertSegments(
    List<TranscriptSegmentsCompanion> segments,
  ) async {
    await _db.batch((batch) {
      batch.insertAll(_db.transcriptSegments, segments);
    });
  }

  /// Returns all segments for a transcript, ordered by startMs.
  Future<List<TranscriptSegment>> getAllSegments(int transcriptId) {
    return (_db.select(_db.transcriptSegments)
          ..where((s) => s.transcriptId.equals(transcriptId))
          ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
        .get();
  }

  /// Returns segments overlapping the given time range.
  Future<List<TranscriptSegment>> getSegments(
    int transcriptId, {
    required int startMs,
    required int endMs,
  }) {
    return (_db.select(_db.transcriptSegments)
          ..where(
            (s) =>
                s.transcriptId.equals(transcriptId) &
                s.startMs.isSmallerThanValue(endMs) &
                s.endMs.isBiggerThanValue(startMs),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.startMs)]))
        .get();
  }

  /// Marks a transcript as fetched by setting fetchedAt.
  Future<void> markAsFetched(int transcriptId) {
    return (_db.update(_db.episodeTranscripts)
          ..where((t) => t.id.equals(transcriptId)))
        .write(
      EpisodeTranscriptsCompanion(fetchedAt: Value(DateTime.now())),
    );
  }

  /// Whether transcript content has been fetched.
  Future<bool> isContentFetched(int transcriptId) async {
    final result = await (_db.select(_db.episodeTranscripts)
          ..where((t) => t.id.equals(transcriptId)))
        .getSingleOrNull();
    return result?.fetchedAt != null;
  }

  /// Deletes all segments for a transcript.
  Future<int> deleteSegments(int transcriptId) {
    return (_db.delete(_db.transcriptSegments)
          ..where((s) => s.transcriptId.equals(transcriptId)))
        .go();
  }
}
```

**Step 3: Run test**

Run: `cd packages/audiflow_domain && flutter test test/features/transcript/datasources/local/transcript_local_datasource_test.dart`
Expected: PASS

**Step 4: Commit**

```
feat(domain): add transcript local datasource with Drift operations
```

---

## Task 9: Chapter Local Datasource

Create a datasource for chapter CRUD operations.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/transcript/datasources/local/chapter_local_datasource.dart`
- Test: `packages/audiflow_domain/test/features/transcript/datasources/local/chapter_local_datasource_test.dart`

Follow the same TDD pattern as Task 8. Key methods:

- `getByEpisodeId(int episodeId)` - ordered by `startMs`
- `upsertChapters(List<EpisodeChaptersCompanion> companions)`
- `deleteByEpisodeId(int episodeId)`

**Commit:**

```
feat(domain): add chapter local datasource
```

---

## Task 10: Transcript Repository

Create repository interface + implementation for transcript operations.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/transcript/repositories/transcript_repository.dart`
- Create: `packages/audiflow_domain/lib/src/features/transcript/repositories/transcript_repository_impl.dart`

**Interface methods:**

```dart
abstract class TranscriptRepository {
  Future<List<EpisodeTranscript>> getMetasByEpisodeId(int episodeId);
  Future<List<TranscriptSegment>> getAllSegments(int transcriptId);
  Future<List<TranscriptSegment>> getSegments(int transcriptId, {required int startMs, required int endMs});
  Future<void> upsertMetas(List<EpisodeTranscriptsCompanion> companions);
  Future<void> insertSegments(List<TranscriptSegmentsCompanion> segments);
  Future<void> markAsFetched(int transcriptId);
  Future<bool> isContentFetched(int transcriptId);
}
```

**Implementation** delegates to `TranscriptLocalDatasource`. Provider:

```dart
@Riverpod(keepAlive: true)
TranscriptRepository transcriptRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return TranscriptRepositoryImpl(
    datasource: TranscriptLocalDatasource(db),
  );
}
```

**Commit:**

```
feat(domain): add transcript repository with interface and impl
```

---

## Task 11: Chapter Repository

Create repository interface + implementation for chapter operations.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/transcript/repositories/chapter_repository.dart`
- Create: `packages/audiflow_domain/lib/src/features/transcript/repositories/chapter_repository_impl.dart`

**Interface methods:**

```dart
abstract class ChapterRepository {
  Future<List<EpisodeChapter>> getByEpisodeId(int episodeId);
  Stream<List<EpisodeChapter>> watchByEpisodeId(int episodeId);
  Future<void> upsertChapters(List<EpisodeChaptersCompanion> companions);
}
```

**Commit:**

```
feat(domain): add chapter repository with interface and impl
```

---

## Task 12: TranscriptService (Lazy Fetch and Parse)

Create a service that orchestrates downloading, parsing, and storing transcript content on demand.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/transcript/services/transcript_service.dart`
- Test: `packages/audiflow_domain/test/features/transcript/services/transcript_service_test.dart`

**Key logic:**

```dart
@Riverpod(keepAlive: true)
TranscriptService transcriptService(Ref ref) {
  final logger = ref.watch(namedLoggerProvider('Transcript'));
  return TranscriptService(ref: ref, logger: logger);
}

class TranscriptService {
  TranscriptService({required Ref ref, required Logger logger})
    : _ref = ref, _logger = logger;

  final Ref _ref;
  final Logger _logger;

  /// Ensures transcript content is available. Fetches if not already stored.
  ///
  /// Returns the transcriptId of the fetched transcript.
  Future<int?> ensureContent(int episodeId) async {
    final repo = _ref.read(transcriptRepositoryProvider);
    final metas = await repo.getMetasByEpisodeId(episodeId);

    // Find best available transcript (prefer VTT, then SRT)
    final supported = metas.where(
      (m) => TranscriptFileParser.isSupported(m.type),
    ).toList();
    if (supported.isEmpty) return null;

    // Prefer VTT for speaker support
    final chosen = supported.firstWhere(
      (m) => m.type == 'text/vtt',
      orElse: () => supported.first,
    );

    // Already fetched?
    if (chosen.fetchedAt != null) return chosen.id;

    // Fetch and parse
    final dio = _ref.read(dioProvider);
    final response = await dio.get<String>(chosen.url);
    final content = response.data;
    if (content == null || content.isEmpty) return null;

    final parser = TranscriptFileParser();
    final segments = parser.parse(content, mimeType: chosen.type);

    // Store segments
    final companions = segments.map((s) =>
      TranscriptSegmentsCompanion.insert(
        transcriptId: chosen.id,
        startMs: s.startMs,
        endMs: s.endMs,
        text: s.text,
        speaker: Value(s.speaker),
      ),
    ).toList();

    await repo.insertSegments(companions);
    await repo.markAsFetched(chosen.id);

    _logger.i('Fetched transcript for episode $episodeId: ${segments.length} segments');

    return chosen.id;
  }
}
```

**Test with mocked Dio and in-memory DB to verify the full flow.**

**Commit:**

```
feat(domain): add TranscriptService for lazy transcript fetch and parse
```

---

## Task 13: Wire Transcript Metadata into Feed Sync

Update `FeedSyncService` and `EpisodeRepository` to store transcript metadata and chapters during feed sync.

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/repositories/episode_repository_impl.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/feed_sync_service.dart`

**Key changes:**

In `EpisodeRepositoryImpl.upsertFromFeedItems`, after upserting episodes, also extract and store transcript metadata and chapters from `PodcastItem`:

```dart
// After existing upsertAll call, store transcript/chapter metadata
for (final item in items) {
  if (item.guid == null) continue;

  final episode = await _datasource.getByPodcastIdAndGuid(podcastId, item.guid!);
  if (episode == null) continue;

  // Store transcript metadata
  if (item.hasTranscripts) {
    final transcriptCompanions = item.transcripts!.map((t) =>
      EpisodeTranscriptsCompanion.insert(
        episodeId: episode.id,
        url: t.url,
        type: t.type,
        language: Value(t.language),
        rel: Value(t.rel),
      ),
    ).toList();
    await transcriptDatasource.upsertMetas(transcriptCompanions);
  }

  // Store chapters
  if (item.hasChapters) {
    final chapterCompanions = item.chapters!.asMap().entries.map((entry) =>
      EpisodeChaptersCompanion.insert(
        episodeId: episode.id,
        sortOrder: entry.key,
        title: entry.value.title,
        startMs: entry.value.startTime.inMilliseconds,
        endMs: Value(entry.value.endTime?.inMilliseconds),
        url: Value(entry.value.url),
        imageUrl: Value(entry.value.imageUrl),
      ),
    ).toList();
    await chapterDatasource.upsertChapters(chapterCompanions);
  }
}
```

Note: The exact integration point will depend on the feed sync flow. The implementation agent should study `feed_parser_service.dart` and `feed_sync_service.dart` to find the right insertion point (likely in `parseWithProgress` callback or a new method).

**Commit:**

```
feat(domain): store transcript metadata and chapters during feed sync
```

---

## Task 14: Riverpod Providers for Transcript and Chapter State

Create providers that expose transcript and chapter data to the UI layer.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/transcript/providers/transcript_providers.dart`

**Providers:**

```dart
@riverpod
Future<List<EpisodeTranscript>> episodeTranscriptMetas(
  Ref ref,
  int episodeId,
) {
  return ref.watch(transcriptRepositoryProvider).getMetasByEpisodeId(episodeId);
}

@riverpod
Future<List<TranscriptSegment>> transcriptSegments(
  Ref ref,
  int transcriptId,
) {
  return ref.watch(transcriptRepositoryProvider).getAllSegments(transcriptId);
}

@riverpod
Future<List<EpisodeChapter>> episodeChapters(Ref ref, int episodeId) {
  return ref.watch(chapterRepositoryProvider).getByEpisodeId(episodeId);
}

@riverpod
Future<bool> episodeHasTranscript(Ref ref, int episodeId) async {
  final metas = await ref.watch(episodeTranscriptMetasProvider(episodeId).future);
  return metas.any((m) => TranscriptFileParser.isSupported(m.type));
}
```

**Commit:**

```
feat(domain): add Riverpod providers for transcript and chapter data
```

---

## Task 15: Export New Transcript Feature from audiflow_domain

Update `audiflow_domain.dart` to export all new transcript feature files.

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

Add exports:

```dart
// Transcript feature
export 'src/features/transcript/models/episode_transcript.dart';
export 'src/features/transcript/models/transcript_segment.dart';
export 'src/features/transcript/models/episode_chapter.dart';
export 'src/features/transcript/datasources/local/transcript_local_datasource.dart';
export 'src/features/transcript/datasources/local/chapter_local_datasource.dart';
export 'src/features/transcript/repositories/transcript_repository.dart';
export 'src/features/transcript/repositories/transcript_repository_impl.dart';
export 'src/features/transcript/repositories/chapter_repository.dart';
export 'src/features/transcript/repositories/chapter_repository_impl.dart';
export 'src/features/transcript/services/transcript_service.dart';
export 'src/features/transcript/providers/transcript_providers.dart';
```

**Commit:**

```
chore(domain): export transcript feature from audiflow_domain
```

---

## Task 16: Player Screen - Add Transcript Tab

Add a "Transcript" tab to the player screen, conditionally visible when the episode has transcript or chapter data.

**Files:**
- Modify: `packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart`
- Create: `packages/audiflow_app/lib/features/player/presentation/widgets/transcript_timeline_view.dart`
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb` (add strings)
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb` (add strings)

**Key changes to player_screen.dart:**

Convert the player body to use `TabBar` + `TabBarView` with two tabs: "Now Playing" (existing content) and "Transcript" (new). The transcript tab is only shown when `episodeHasTranscriptProvider` or `episodeChaptersProvider` returns data.

**The TranscriptTimelineView widget** should:
1. Accept `transcriptId`, `episodeId`, and current playback position
2. Display chapters as section headers and segments as tappable text items
3. Highlight the currently active segment
4. Auto-scroll to the active segment
5. Support tap-to-seek on any segment

This task requires the `NowPlayingInfo` model to include `episodeId` (check if it already does; if not, add it).

**Commit:**

```
feat(player): add transcript tab to player screen
```

---

## Task 17: TranscriptTimelineView Widget

Build the unified timeline widget that merges chapters and transcript segments.

**Files:**
- Create: `packages/audiflow_app/lib/features/player/presentation/widgets/transcript_timeline_view.dart`
- Test: `packages/audiflow_app/test/features/player/presentation/widgets/transcript_timeline_view_test.dart`

**Key behaviors:**
- `ListView.builder` with segments grouped under chapter headers
- Active segment determined by comparing `playbackProgress.position.inMilliseconds` against segment `startMs`/`endMs`
- Auto-scroll via `ScrollController.animateTo()` when active segment changes
- Manual scroll detection pauses auto-scroll; shows "Jump to current" FAB
- Tap handler calls `ref.read(audioPlayerControllerProvider.notifier).seek(Duration(milliseconds: segment.startMs))`

**Commit:**

```
feat(player): add TranscriptTimelineView with sync and tap-to-seek
```

---

## Task 18: Episode Detail - Transcript Indicator

Add a transcript availability indicator to episode list items and the episode detail screen.

**Files:**
- Modify: Episode card/list widgets in `packages/audiflow_app/`
- Add an icon (e.g., `Symbols.closed_caption`) when `episodeHasTranscriptProvider(episodeId)` returns true

**Commit:**

```
feat(ui): add transcript indicator to episode cards
```

---

## Task 19: Full-Text Search with FTS5

Add FTS5 virtual table for transcript search.

**Files:**
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart` (add FTS5 table via `customStatement` in migration)
- Modify: `packages/audiflow_domain/lib/src/features/transcript/datasources/local/transcript_local_datasource.dart` (add search method)
- Create: `packages/audiflow_domain/lib/src/features/transcript/models/transcript_search_result.dart`
- Test: `packages/audiflow_domain/test/features/transcript/datasources/local/transcript_search_test.dart`

**Migration addition** (bump to v18 or include in v17 if not yet applied):

```dart
await customStatement('''
  CREATE VIRTUAL TABLE IF NOT EXISTS transcript_segments_fts
  USING fts5(text, content='transcript_segments', content_rowid='id')
''');

// Triggers to keep FTS in sync
await customStatement('''
  CREATE TRIGGER IF NOT EXISTS transcript_segments_ai AFTER INSERT ON transcript_segments BEGIN
    INSERT INTO transcript_segments_fts(rowid, text) VALUES (new.id, new.text);
  END
''');

await customStatement('''
  CREATE TRIGGER IF NOT EXISTS transcript_segments_ad AFTER DELETE ON transcript_segments BEGIN
    INSERT INTO transcript_segments_fts(transcript_segments_fts, rowid, text) VALUES('delete', old.id, old.text);
  END
''');
```

**Search method in TranscriptLocalDatasource:**

```dart
Future<List<TranscriptSearchResult>> search(String query) async {
  final results = await _db.customSelect(
    '''
    SELECT ts.id, ts.transcript_id, ts.start_ms, ts.end_ms, ts.text, ts.speaker,
           et.episode_id
    FROM transcript_segments_fts fts
    JOIN transcript_segments ts ON fts.rowid = ts.id
    JOIN episode_transcripts et ON ts.transcript_id = et.id
    WHERE fts.text MATCH ?
    ORDER BY rank
    LIMIT 50
    ''',
    variables: [Variable.withString(query)],
  ).get();

  return results.map((row) => TranscriptSearchResult(
    segmentId: row.read<int>('id'),
    transcriptId: row.read<int>('transcript_id'),
    episodeId: row.read<int>('episode_id'),
    startMs: row.read<int>('start_ms'),
    endMs: row.read<int>('end_ms'),
    text: row.read<String>('text'),
    speaker: row.readNullable<String>('speaker'),
  )).toList();
}
```

**Commit:**

```
feat(domain): add FTS5 full-text search for transcript segments
```

---

## Task 20: Final Integration and Polish

Run all tests, fix any issues, update exports, run analyzer.

**Steps:**

1. Run: `cd packages/audiflow_podcast && flutter test` - all pass
2. Run: `cd packages/audiflow_domain && flutter test` - all pass
3. Run: `cd packages/audiflow_app && flutter test` - all pass
4. Run: `dart_format` tool on all changed files
5. Run: `analyze_files` tool - zero errors/warnings
6. Create bookmark: `jj bookmark create feat/podcast-transcript`

**Commit:**

```
feat: complete podcast transcript and chapter support
```
