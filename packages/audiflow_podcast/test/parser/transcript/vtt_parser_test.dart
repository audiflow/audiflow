import 'dart:io';

import 'package:audiflow_podcast/src/parser/transcript/transcript_segment.dart';
import 'package:audiflow_podcast/src/parser/transcript/vtt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resolves fixture path from either package root or workspace root.
String _fixturePath(String relativePath) {
  const packageDir = 'packages/audiflow_podcast';
  final fromPackage = File(relativePath);
  if (fromPackage.existsSync()) return relativePath;
  return '$packageDir/$relativePath';
}

void main() {
  late VttParser parser;

  setUp(() {
    parser = const VttParser();
  });

  group('VttParser', () {
    test('parses VTT content with speakers', () {
      const content = '''WEBVTT

00:00:00.000 --> 00:00:05.500
<v Alice>Welcome to the show.

00:00:05.500 --> 00:00:12.300
<v Bob>Thanks for having me.
''';

      final segments = parser.parse(content);

      expect(segments, hasLength(2));

      expect(segments[0].startMs, 0);
      expect(segments[0].endMs, 5500);
      expect(segments[0].text, 'Welcome to the show.');
      expect(segments[0].speaker, 'Alice');

      expect(segments[1].startMs, 5500);
      expect(segments[1].endMs, 12300);
      expect(segments[1].text, 'Thanks for having me.');
      expect(segments[1].speaker, 'Bob');
    });

    test('segments without speaker tags have null speaker', () {
      const content = '''WEBVTT

00:01:00.000 --> 00:01:10.000
And that wraps things up.
''';

      final segments = parser.parse(content);

      expect(segments, hasLength(1));
      expect(segments[0].startMs, 60000);
      expect(segments[0].endMs, 70000);
      expect(segments[0].text, 'And that wraps things up.');
      expect(segments[0].speaker, isNull);
    });

    test('skips WEBVTT header and NOTE blocks', () {
      const content = '''WEBVTT

NOTE This is a comment and should be ignored.

00:00:00.000 --> 00:00:05.500
Hello world.

NOTE Another comment.

00:00:05.500 --> 00:00:10.000
Goodbye world.
''';

      final segments = parser.parse(content);

      expect(segments, hasLength(2));
      expect(segments[0].text, 'Hello world.');
      expect(segments[1].text, 'Goodbye world.');
    });

    test('empty content returns empty list', () {
      final segments = parser.parse('');

      expect(segments, isEmpty);
    });

    test('whitespace-only content returns empty list', () {
      final segments = parser.parse('   \n\n  ');

      expect(segments, isEmpty);
    });

    test('verifies timestamps are correct', () {
      const content = '''WEBVTT

01:23:45.678 --> 02:34:56.789
Timed segment.
''';

      final segments = parser.parse(content);

      expect(segments, hasLength(1));
      // 1*3600000 + 23*60000 + 45*1000 + 678 = 5025678
      expect(segments[0].startMs, 5025678);
      // 2*3600000 + 34*60000 + 56*1000 + 789 = 9296789
      expect(segments[0].endMs, 9296789);
    });

    test('strips HTML-like tags from text', () {
      const content = '''WEBVTT

00:00:00.000 --> 00:00:05.000
<b>Bold</b> and <i>italic</i> text.
''';

      final segments = parser.parse(content);

      expect(segments, hasLength(1));
      expect(segments[0].text, 'Bold and italic text.');
    });

    test('skips cue blocks without timestamp', () {
      const content = '''WEBVTT

No timestamp here.

00:00:00.000 --> 00:00:05.000
Valid cue.
''';

      final segments = parser.parse(content);

      expect(segments, hasLength(1));
      expect(segments[0].text, 'Valid cue.');
    });

    test('skips cue blocks without text', () {
      const content = '''WEBVTT

00:00:00.000 --> 00:00:05.000

00:00:05.000 --> 00:00:10.000
Has text.
''';

      final segments = parser.parse(content);

      expect(segments, hasLength(1));
      expect(segments[0].text, 'Has text.');
    });

    test('supports optional cue identifiers', () {
      const content = '''WEBVTT

1
00:00:00.000 --> 00:00:05.000
First cue.

intro-text
00:00:05.000 --> 00:00:10.000
Second cue.
''';

      final segments = parser.parse(content);

      expect(segments, hasLength(2));
      expect(segments[0].text, 'First cue.');
      expect(segments[1].text, 'Second cue.');
    });

    test('handles multi-line cue text', () {
      const content = '''WEBVTT

00:00:00.000 --> 00:00:05.000
First line.
Second line.
''';

      final segments = parser.parse(content);

      expect(segments, hasLength(1));
      expect(segments[0].text, 'First line. Second line.');
    });

    test('parses sample.vtt fixture file', () {
      final file = File(_fixturePath('test/fixtures/sample.vtt'));
      final content = file.readAsStringSync();

      final segments = parser.parse(content);

      expect(segments, hasLength(3));

      expect(
        segments[0],
        const TranscriptSegment(
          startMs: 0,
          endMs: 5500,
          text: 'Welcome to the show.',
          speaker: 'Alice',
        ),
      );
      expect(
        segments[1],
        const TranscriptSegment(
          startMs: 5500,
          endMs: 12300,
          text: 'Thanks for having me.',
          speaker: 'Bob',
        ),
      );
      expect(
        segments[2],
        const TranscriptSegment(
          startMs: 60000,
          endMs: 70000,
          text: 'And that wraps things up.',
        ),
      );
    });

    test('extracts speaker from voice tag with closing tag', () {
      const content = '''WEBVTT

00:00:00.000 --> 00:00:05.000
<v Alice>Hello there.</v>
''';

      final segments = parser.parse(content);

      expect(segments, hasLength(1));
      expect(segments[0].speaker, 'Alice');
      expect(segments[0].text, 'Hello there.');
    });

    test('handles WEBVTT header with metadata', () {
      const content = '''WEBVTT Kind: captions; Language: en

00:00:00.000 --> 00:00:05.000
Caption text.
''';

      final segments = parser.parse(content);

      expect(segments, hasLength(1));
      expect(segments[0].text, 'Caption text.');
    });
  });
}
