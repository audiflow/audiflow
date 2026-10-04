import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = JsonChaptersParser();

  group('JsonChaptersParser', () {
    test('parses titles, times, images and urls', () {
      final chapters = parser.parse('''
{
  "version": "1.2.0",
  "chapters": [
    {"startTime": 0, "title": "Intro", "img": "https://example.com/a.jpg"},
    {"startTime": 65.5, "endTime": 120, "title": "Topic",
     "url": "https://example.com/topic"}
  ]
}''');

      expect(chapters, hasLength(2));
      expect(chapters[0].title, 'Intro');
      expect(chapters[0].startTime, Duration.zero);
      expect(chapters[0].imageUrl, 'https://example.com/a.jpg');
      expect(chapters[1].startTime, const Duration(milliseconds: 65500));
      expect(chapters[1].endTime, const Duration(seconds: 120));
      expect(chapters[1].url, 'https://example.com/topic');
    });

    test('skips toc:false entries', () {
      final chapters = parser.parse('''
{"version": "1.2.0", "chapters": [
  {"startTime": 0, "title": "Intro"},
  {"startTime": 10, "title": "Hidden ad", "toc": false},
  {"startTime": 20, "title": "Shown", "toc": true}
]}''');

      expect(chapters.map((c) => c.title), ['Intro', 'Shown']);
    });

    test('skips entries without a title or start time', () {
      final chapters = parser.parse('''
{"version": "1.2.0", "chapters": [
  {"startTime": 0},
  {"startTime": 5, "title": "  "},
  {"title": "No start"},
  {"startTime": "12", "title": "String start"},
  {"startTime": 30, "title": "Kept"}
]}''');

      expect(chapters.map((c) => c.title), ['Kept']);
    });

    test('sorts unsorted entries by start time', () {
      final chapters = parser.parse('''
{"version": "1.2.0", "chapters": [
  {"startTime": 300, "title": "C"},
  {"startTime": 0, "title": "A"},
  {"startTime": 120, "title": "B"}
]}''');

      expect(chapters.map((c) => c.title), ['A', 'B', 'C']);
    });

    test('drops an end time that is not after the start', () {
      final chapters = parser.parse('''
{"version": "1.2.0", "chapters": [
  {"startTime": 30, "endTime": 10, "title": "A"}
]}''');

      expect(chapters.single.endTime, isNull);
    });

    test('returns empty for an empty chapters array', () {
      expect(parser.parse('{"version": "1.2.0", "chapters": []}'), isEmpty);
    });

    test('throws FormatException for malformed JSON', () {
      expect(() => parser.parse('{"chapters": ['), throwsFormatException);
    });

    test('throws FormatException when chapters is missing', () {
      expect(() => parser.parse('{"version": "1.2.0"}'), throwsFormatException);
      expect(() => parser.parse('[1, 2]'), throwsFormatException);
    });
  });
}
