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

    test('isSupported returns true for supported types', () {
      expect(TranscriptFileParser.isSupported('application/srt'), isTrue);
      expect(TranscriptFileParser.isSupported('text/srt'), isTrue);
      expect(TranscriptFileParser.isSupported('text/vtt'), isTrue);
    });

    test('isSupported returns false for unsupported types', () {
      expect(TranscriptFileParser.isSupported('text/plain'), isFalse);
      expect(
        TranscriptFileParser.isSupported('application/json'),
        isFalse,
      );
    });
  });
}
