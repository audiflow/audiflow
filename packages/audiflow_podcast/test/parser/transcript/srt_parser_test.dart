import 'dart:io';

import 'package:audiflow_podcast/src/parser/transcript/srt_parser.dart';
import 'package:audiflow_podcast/src/parser/transcript/transcript_segment.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resolves fixture path from either package root or workspace root.
String _fixturePath(String relativePath) {
  const packageDir = 'packages/audiflow_podcast';
  final fromPackage = File(relativePath);
  if (fromPackage.existsSync()) return relativePath;
  return '$packageDir/$relativePath';
}

void main() {
  late SrtParser parser;

  setUp(() {
    parser = const SrtParser();
  });

  group('SrtParser', () {
    test('parses fixture file into correct number of segments', () {
      final file = File(_fixturePath('test/fixtures/sample.srt'));
      final content = file.readAsStringSync();

      final segments = parser.parse(content);

      expect(segments.length, equals(3));
    });

    test('parses timestamps correctly', () {
      const content = '''1
00:00:00,000 --> 00:00:05,500
Hello.''';

      final segments = parser.parse(content);

      expect(segments.length, equals(1));
      expect(segments[0].startMs, equals(0));
      expect(segments[0].endMs, equals(5500));
    });

    test('parses hour-level timestamps correctly', () {
      const content = '''1
01:30:15,250 --> 02:00:00,000
Long episode segment.''';

      final segments = parser.parse(content);

      expect(segments[0].startMs, equals(5415250));
      expect(segments[0].endMs, equals(7200000));
    });

    test('joins multi-line text with space', () {
      const content = '''1
00:00:05,500 --> 00:00:12,300
Today we're talking about
podcast transcripts.''';

      final segments = parser.parse(content);

      expect(segments.length, equals(1));
      expect(
        segments[0].text,
        equals("Today we're talking about podcast transcripts."),
      );
    });

    test('returns empty list for empty content', () {
      final segments = parser.parse('');

      expect(segments, isEmpty);
    });

    test('returns empty list for whitespace-only content', () {
      final segments = parser.parse('   \n\n  \n  ');

      expect(segments, isEmpty);
    });

    test('skips malformed blocks gracefully', () {
      const content = '''1
00:00:00,000 --> 00:00:05,500
Valid segment.

2
This line is not a timestamp
Some text.

3
00:00:10,000 --> 00:00:15,000
Another valid segment.''';

      final segments = parser.parse(content);

      expect(segments.length, equals(2));
      expect(segments[0].text, equals('Valid segment.'));
      expect(segments[1].text, equals('Another valid segment.'));
    });

    test('handles dot as decimal separator', () {
      const content = '''1
00:00:01.500 --> 00:00:03.750
Dot separator.''';

      final segments = parser.parse(content);

      expect(segments.length, equals(1));
      expect(segments[0].startMs, equals(1500));
      expect(segments[0].endMs, equals(3750));
    });

    test('verifies all fields from fixture file', () {
      final file = File(_fixturePath('test/fixtures/sample.srt'));
      final content = file.readAsStringSync();

      final segments = parser.parse(content);

      expect(
        segments[0],
        equals(
          const TranscriptSegment(
            startMs: 0,
            endMs: 5500,
            text: 'Welcome to the show.',
          ),
        ),
      );
      expect(
        segments[1],
        equals(
          const TranscriptSegment(
            startMs: 5500,
            endMs: 12300,
            text: "Today we're talking about podcast transcripts.",
          ),
        ),
      );
      expect(
        segments[2],
        equals(
          const TranscriptSegment(
            startMs: 60000,
            endMs: 70000,
            text: 'And that wraps things up.',
          ),
        ),
      );
    });

    test('handles block with missing text lines', () {
      const content = '''1
00:00:00,000 --> 00:00:05,500

2
00:00:05,500 --> 00:00:10,000
Valid text.''';

      final segments = parser.parse(content);

      // Block with no text should be skipped
      expect(segments.length, equals(1));
      expect(segments[0].text, equals('Valid text.'));
    });

    test('speaker field defaults to null', () {
      const content = '''1
00:00:00,000 --> 00:00:05,500
Hello world.''';

      final segments = parser.parse(content);

      expect(segments[0].speaker, isNull);
    });
  });
}
