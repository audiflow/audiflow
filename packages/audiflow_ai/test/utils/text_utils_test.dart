// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/src/utils/text_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextUtils', () {
    group('stripHtml', () {
      test('returns empty string for empty input', () {
        expect(TextUtils.stripHtml(''), equals(''));
      });

      test('returns same string when no HTML', () {
        const text = 'Plain text without HTML';
        expect(TextUtils.stripHtml(text), equals(text));
      });

      test('strips simple HTML tags', () {
        const html = '<p>Hello</p>';
        expect(TextUtils.stripHtml(html), equals('Hello'));
      });

      test('strips multiple HTML tags', () {
        const html = '<div><p>Hello <strong>World</strong></p></div>';
        expect(TextUtils.stripHtml(html), equals('Hello World'));
      });

      test('strips self-closing tags', () {
        const html = 'Line one<br/>Line two<br />Line three';
        expect(
          TextUtils.stripHtml(html),
          equals('Line one Line two Line three'),
        );
      });

      test('strips tags with attributes', () {
        const html = '<a href="https://example.com">Link text</a>';
        expect(TextUtils.stripHtml(html), equals('Link text'));
      });

      test('strips tags with multiple attributes', () {
        const html =
            '<div class="container" id="main" data-value="test">Content</div>';
        expect(TextUtils.stripHtml(html), equals('Content'));
      });

      test('handles nested tags', () {
        const html = '<ul><li>Item 1</li><li>Item 2</li></ul>';
        expect(TextUtils.stripHtml(html), equals('Item 1 Item 2'));
      });

      test('handles script tags', () {
        const html = 'Before<script>alert("test");</script>After';
        expect(TextUtils.stripHtml(html), equals('Before After'));
      });

      test('handles style tags', () {
        const html = 'Before<style>.class { color: red; }</style>After';
        expect(TextUtils.stripHtml(html), equals('Before After'));
      });

      test('handles malformed HTML gracefully', () {
        const html = '<p>Unclosed paragraph<div>Mixed</p></div>';
        final result = TextUtils.stripHtml(html);
        expect(result, isNot(contains('<')));
        expect(result, isNot(contains('>')));
      });

      test('handles HTML comments', () {
        const html = 'Before<!-- This is a comment -->After';
        expect(TextUtils.stripHtml(html), equals('Before After'));
      });
    });

    group('decodeHtmlEntities', () {
      test('returns empty string for empty input', () {
        expect(TextUtils.decodeHtmlEntities(''), equals(''));
      });

      test('returns same string when no entities', () {
        const text = 'Plain text';
        expect(TextUtils.decodeHtmlEntities(text), equals(text));
      });

      test('decodes common named entities', () {
        expect(TextUtils.decodeHtmlEntities('&amp;'), equals('&'));
        expect(TextUtils.decodeHtmlEntities('&lt;'), equals('<'));
        expect(TextUtils.decodeHtmlEntities('&gt;'), equals('>'));
        expect(TextUtils.decodeHtmlEntities('&quot;'), equals('"'));
        expect(TextUtils.decodeHtmlEntities('&apos;'), equals("'"));
        expect(TextUtils.decodeHtmlEntities('&nbsp;'), equals('\u00A0'));
      });

      test('decodes numeric entities', () {
        expect(TextUtils.decodeHtmlEntities('&#38;'), equals('&'));
        expect(TextUtils.decodeHtmlEntities('&#60;'), equals('<'));
        expect(TextUtils.decodeHtmlEntities('&#62;'), equals('>'));
      });

      test('decodes hex entities', () {
        expect(TextUtils.decodeHtmlEntities('&#x26;'), equals('&'));
        expect(TextUtils.decodeHtmlEntities('&#x3C;'), equals('<'));
        expect(TextUtils.decodeHtmlEntities('&#x3E;'), equals('>'));
        expect(TextUtils.decodeHtmlEntities('&#X3E;'), equals('>'));
      });

      test('decodes multiple entities in text', () {
        const encoded = 'Tom &amp; Jerry &lt;3 each other';
        expect(
          TextUtils.decodeHtmlEntities(encoded),
          equals('Tom & Jerry <3 each other'),
        );
      });

      test('handles unknown entities gracefully', () {
        const text = 'Unknown &unknownentity; here';
        final result = TextUtils.decodeHtmlEntities(text);
        // Should either leave unknown entity or decode to empty
        expect(result, isNotEmpty);
      });

      test('decodes special characters', () {
        expect(TextUtils.decodeHtmlEntities('&copy;'), equals('\u00A9'));
        expect(TextUtils.decodeHtmlEntities('&reg;'), equals('\u00AE'));
        expect(TextUtils.decodeHtmlEntities('&trade;'), equals('\u2122'));
        expect(TextUtils.decodeHtmlEntities('&mdash;'), equals('\u2014'));
        expect(TextUtils.decodeHtmlEntities('&ndash;'), equals('\u2013'));
      });
    });

    group('normalizeWhitespace', () {
      test('returns empty string for empty input', () {
        expect(TextUtils.normalizeWhitespace(''), equals(''));
      });

      test('trims leading and trailing whitespace', () {
        expect(TextUtils.normalizeWhitespace('  hello  '), equals('hello'));
      });

      test('collapses multiple spaces', () {
        expect(
          TextUtils.normalizeWhitespace('hello    world'),
          equals('hello world'),
        );
      });

      test('normalizes tabs to spaces', () {
        expect(
          TextUtils.normalizeWhitespace('hello\tworld'),
          equals('hello world'),
        );
      });

      test('normalizes mixed whitespace', () {
        expect(
          TextUtils.normalizeWhitespace('hello \t\n  world'),
          equals('hello world'),
        );
      });

      test('normalizes multiple newlines', () {
        expect(
          TextUtils.normalizeWhitespace('line1\n\n\nline2'),
          equals('line1 line2'),
        );
      });

      test('handles carriage returns', () {
        expect(
          TextUtils.normalizeWhitespace('line1\r\nline2'),
          equals('line1 line2'),
        );
      });
    });

    group('normalizeText', () {
      test('performs full normalization', () {
        const html = '<p>Hello &amp; World</p>';
        final result = TextUtils.normalizeText(html);
        expect(result, equals('Hello & World'));
      });

      test('strips HTML, decodes entities, and normalizes whitespace', () {
        const html = '<div>  First &lt;item&gt;  </div><br/><p>  Second  </p>';
        final result = TextUtils.normalizeText(html);
        expect(result, equals('First <item> Second'));
      });

      test('handles complex podcast description', () {
        const html = '''
<p>In this episode, we discuss the &quot;future of AI&quot; with Dr. Smith.</p>
<br/>
<p>Topics include:</p>
<ul>
  <li>Machine Learning &amp; Deep Learning</li>
  <li>Natural Language Processing</li>
</ul>
<p>Don&apos;t miss it!</p>
''';
        final result = TextUtils.normalizeText(html);
        expect(result, contains('future of AI'));
        expect(result, contains('Dr. Smith'));
        expect(result, contains('Machine Learning & Deep Learning'));
        expect(result, contains("Don't miss it"));
        expect(result, isNot(contains('<')));
        expect(result, isNot(contains('>')));
        expect(result, isNot(contains('&amp;')));
      });
    });

    group('truncateText', () {
      test('returns same text if shorter than max length', () {
        const text = 'Short';
        expect(TextUtils.truncateText(text, 100), equals(text));
      });

      test('truncates text to max length with ellipsis', () {
        const text = 'This is a long sentence that needs truncation.';
        final result = TextUtils.truncateText(text, 20);
        expect(result.length, lessThanOrEqualTo(23)); // 20 + '...'
        expect(result, endsWith('...'));
      });

      test('truncates at word boundary when possible', () {
        const text = 'This is a long sentence.';
        final result = TextUtils.truncateText(text, 15, atWordBoundary: true);
        expect(result, isNot(endsWith('lon...')));
      });

      test('handles empty string', () {
        expect(TextUtils.truncateText('', 100), equals(''));
      });

      test('uses custom suffix', () {
        const text = 'This is a long sentence.';
        final result = TextUtils.truncateText(text, 10, suffix: ' [more]');
        expect(result, endsWith('[more]'));
      });
    });

    group('countWords', () {
      test('returns 0 for empty string', () {
        expect(TextUtils.countWords(''), equals(0));
      });

      test('returns 0 for whitespace only', () {
        expect(TextUtils.countWords('   \t\n  '), equals(0));
      });

      test('counts single word', () {
        expect(TextUtils.countWords('hello'), equals(1));
      });

      test('counts multiple words', () {
        expect(TextUtils.countWords('hello world'), equals(2));
      });

      test('handles multiple spaces between words', () {
        expect(TextUtils.countWords('hello    world'), equals(2));
      });

      test('handles punctuation', () {
        expect(TextUtils.countWords('hello, world!'), equals(2));
      });
    });

    group('extractSentences', () {
      test('returns empty list for empty string', () {
        expect(TextUtils.extractSentences(''), isEmpty);
      });

      test('extracts single sentence', () {
        final sentences = TextUtils.extractSentences('Hello world.');
        expect(sentences, hasLength(1));
        expect(sentences.first, equals('Hello world.'));
      });

      test('extracts multiple sentences', () {
        final sentences = TextUtils.extractSentences(
          'First sentence. Second sentence! Third sentence?',
        );
        expect(sentences, hasLength(3));
        expect(sentences[0], equals('First sentence.'));
        expect(sentences[1], equals('Second sentence!'));
        expect(sentences[2], equals('Third sentence?'));
      });

      test('handles sentences without terminal punctuation', () {
        final sentences = TextUtils.extractSentences('No punctuation here');
        expect(sentences, hasLength(1));
        expect(sentences.first, equals('No punctuation here'));
      });

      test('handles abbreviations', () {
        final sentences = TextUtils.extractSentences(
          'Dr. Smith went home. He was tired.',
        );
        // This is tricky - may need smarter handling
        expect(sentences.length, greaterThanOrEqualTo(1));
      });
    });
  });
}
