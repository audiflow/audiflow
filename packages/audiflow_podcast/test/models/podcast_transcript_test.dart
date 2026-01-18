import 'package:flutter_test/flutter_test.dart';
import 'package:audiflow_podcast/src/models/podcast_transcript.dart';

void main() {
  group('PodcastTranscript', () {
    test('should create transcript with required fields', () {
      const url = 'https://example.com/transcript.txt';
      const type = 'text/plain';

      const transcript = PodcastTranscript(url: url, type: type);

      expect(transcript.url, equals(url));
      expect(transcript.type, equals(type));
      expect(transcript.language, isNull);
      expect(transcript.rel, isNull);
    });

    test('should create transcript with all fields', () {
      const url = 'https://example.com/transcript.srt';
      const type = 'application/srt';
      const language = 'en-US';
      const rel = 'captions';

      const transcript = PodcastTranscript(
        url: url,
        type: type,
        language: language,
        rel: rel,
      );

      expect(transcript.url, equals(url));
      expect(transcript.type, equals(type));
      expect(transcript.language, equals(language));
      expect(transcript.rel, equals(rel));
    });

    group('type detection methods', () {
      test('should correctly identify plain text transcripts', () {
        const plainTextTranscript = PodcastTranscript(
          url: 'https://example.com/transcript.txt',
          type: 'text/plain',
        );

        const htmlTranscript = PodcastTranscript(
          url: 'https://example.com/transcript.html',
          type: 'text/html',
        );

        expect(plainTextTranscript.isPlainText, isTrue);
        expect(plainTextTranscript.isHtml, isFalse);
        expect(plainTextTranscript.isSrt, isFalse);
        expect(plainTextTranscript.isVtt, isFalse);

        expect(htmlTranscript.isPlainText, isFalse);
        expect(htmlTranscript.isHtml, isTrue);
      });

      test('should correctly identify HTML transcripts', () {
        const htmlTranscript = PodcastTranscript(
          url: 'https://example.com/transcript.html',
          type: 'text/html',
        );

        expect(htmlTranscript.isHtml, isTrue);
        expect(htmlTranscript.isPlainText, isFalse);
        expect(htmlTranscript.isSrt, isFalse);
        expect(htmlTranscript.isVtt, isFalse);
      });

      test('should correctly identify SRT transcripts', () {
        const srtTranscript1 = PodcastTranscript(
          url: 'https://example.com/transcript.srt',
          type: 'application/srt',
        );

        const srtTranscript2 = PodcastTranscript(
          url: 'https://example.com/transcript.srt',
          type: 'text/srt',
        );

        expect(srtTranscript1.isSrt, isTrue);
        expect(srtTranscript1.isVtt, isFalse);
        expect(srtTranscript1.isPlainText, isFalse);
        expect(srtTranscript1.isHtml, isFalse);

        expect(srtTranscript2.isSrt, isTrue);
      });

      test('should correctly identify VTT transcripts', () {
        const vttTranscript = PodcastTranscript(
          url: 'https://example.com/transcript.vtt',
          type: 'text/vtt',
        );

        expect(vttTranscript.isVtt, isTrue);
        expect(vttTranscript.isSrt, isFalse);
        expect(vttTranscript.isPlainText, isFalse);
        expect(vttTranscript.isHtml, isFalse);
      });
    });

    group('convenience getters', () {
      test('should correctly identify if transcript has language', () {
        const transcriptWithLanguage = PodcastTranscript(
          url: 'https://example.com/transcript.txt',
          type: 'text/plain',
          language: 'en-US',
        );

        const transcriptWithEmptyLanguage = PodcastTranscript(
          url: 'https://example.com/transcript.txt',
          type: 'text/plain',
          language: '',
        );

        const transcriptWithoutLanguage = PodcastTranscript(
          url: 'https://example.com/transcript.txt',
          type: 'text/plain',
        );

        expect(transcriptWithLanguage.hasLanguage, isTrue);
        expect(transcriptWithEmptyLanguage.hasLanguage, isFalse);
        expect(transcriptWithoutLanguage.hasLanguage, isFalse);
      });

      test('should correctly identify captions vs transcripts', () {
        const captions = PodcastTranscript(
          url: 'https://example.com/captions.srt',
          type: 'application/srt',
          rel: 'captions',
        );

        const transcript = PodcastTranscript(
          url: 'https://example.com/transcript.txt',
          type: 'text/plain',
          rel: 'transcript',
        );

        const unspecified = PodcastTranscript(
          url: 'https://example.com/text.txt',
          type: 'text/plain',
        );

        expect(captions.isCaptions, isTrue);
        expect(captions.isTranscript, isFalse);

        expect(transcript.isCaptions, isFalse);
        expect(transcript.isTranscript, isTrue);

        expect(unspecified.isCaptions, isFalse);
        expect(unspecified.isTranscript, isFalse);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        const transcript1 = PodcastTranscript(
          url: 'https://example.com/transcript.srt',
          type: 'application/srt',
          language: 'en-US',
          rel: 'captions',
        );

        const transcript2 = PodcastTranscript(
          url: 'https://example.com/transcript.srt',
          type: 'application/srt',
          language: 'en-US',
          rel: 'captions',
        );

        expect(transcript1, equals(transcript2));
        expect(transcript1.hashCode, equals(transcript2.hashCode));
      });

      test('should not be equal when URLs differ', () {
        const transcript1 = PodcastTranscript(
          url: 'https://example.com/transcript1.txt',
          type: 'text/plain',
        );

        const transcript2 = PodcastTranscript(
          url: 'https://example.com/transcript2.txt',
          type: 'text/plain',
        );

        expect(transcript1, isNot(equals(transcript2)));
      });

      test('should not be equal when types differ', () {
        const transcript1 = PodcastTranscript(
          url: 'https://example.com/transcript.txt',
          type: 'text/plain',
        );

        const transcript2 = PodcastTranscript(
          url: 'https://example.com/transcript.txt',
          type: 'text/html',
        );

        expect(transcript1, isNot(equals(transcript2)));
      });
    });

    test('should have meaningful toString representation', () {
      const url = 'https://example.com/transcript.srt';
      const type = 'application/srt';
      const language = 'en-US';
      const rel = 'captions';

      const transcript = PodcastTranscript(
        url: url,
        type: type,
        language: language,
        rel: rel,
      );

      final string = transcript.toString();
      expect(string, contains('PodcastTranscript'));
      expect(string, contains(url));
      expect(string, contains(type));
      expect(string, contains(language));
      expect(string, contains(rel));
    });
  });
}
