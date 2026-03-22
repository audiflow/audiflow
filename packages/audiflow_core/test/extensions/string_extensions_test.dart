import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringExtensions', () {
    group('isBlank', () {
      test('returns true for empty string', () {
        expect(''.isBlank, isTrue);
      });

      test('returns true for whitespace only', () {
        expect('   '.isBlank, isTrue);
      });

      test('returns true for tab characters only', () {
        expect('\t\t'.isBlank, isTrue);
      });

      test('returns true for newline characters only', () {
        expect('\n\n'.isBlank, isTrue);
      });

      test('returns true for mixed whitespace', () {
        expect(' \t\n '.isBlank, isTrue);
      });

      test('returns false for non-empty string', () {
        expect('hello'.isBlank, isFalse);
      });

      test('returns false for string with leading whitespace', () {
        expect(' hello'.isBlank, isFalse);
      });

      test('returns false for single character', () {
        expect('a'.isBlank, isFalse);
      });
    });

    group('isNotBlank', () {
      test('returns false for empty string', () {
        expect(''.isNotBlank, isFalse);
      });

      test('returns false for whitespace only', () {
        expect('   '.isNotBlank, isFalse);
      });

      test('returns true for non-empty string', () {
        expect('hello'.isNotBlank, isTrue);
      });

      test('returns true for string with spaces and content', () {
        expect(' hello '.isNotBlank, isTrue);
      });
    });

    group('capitalize()', () {
      test('returns empty string for empty input', () {
        expect(''.capitalize(), '');
      });

      test('capitalizes first letter of lowercase word', () {
        expect('hello'.capitalize(), 'Hello');
      });

      test('keeps already capitalized word unchanged', () {
        expect('Hello'.capitalize(), 'Hello');
      });

      test('capitalizes single character', () {
        expect('a'.capitalize(), 'A');
      });

      test('does not change rest of string', () {
        expect('hELLO'.capitalize(), 'HELLO');
      });

      test('handles uppercase single character', () {
        expect('A'.capitalize(), 'A');
      });

      test('handles numeric first character', () {
        expect('123abc'.capitalize(), '123abc');
      });

      test('capitalizes first letter of multi-word string', () {
        expect('hello world'.capitalize(), 'Hello world');
      });
    });

    group('toTitleCase()', () {
      test('returns empty string for empty input', () {
        expect(''.toTitleCase(), '');
      });

      test('capitalizes single word', () {
        expect('hello'.toTitleCase(), 'Hello');
      });

      test('capitalizes each word in multi-word string', () {
        expect('hello world'.toTitleCase(), 'Hello World');
      });

      test('handles already title-cased string', () {
        expect('Hello World'.toTitleCase(), 'Hello World');
      });

      test('handles all uppercase words', () {
        expect('HELLO WORLD'.toTitleCase(), 'HELLO WORLD');
      });

      test('handles mixed case words', () {
        expect('hELLO wORLD'.toTitleCase(), 'HELLO WORLD');
      });

      test('handles three words', () {
        expect('one two three'.toTitleCase(), 'One Two Three');
      });

      test('handles single character words', () {
        expect('a b c'.toTitleCase(), 'A B C');
      });
    });

    group('linkifyUrls', () {
      test('wraps plain http URL in anchor tag', () {
        expect(
          'Visit http://example.com for more'.linkifyUrls,
          'Visit <a href="http://example.com">http://example.com</a> for more',
        );
      });

      test('wraps plain https URL in anchor tag', () {
        expect(
          'Check https://example.com/path'.linkifyUrls,
          'Check <a href="https://example.com/path">https://example.com/path</a>',
        );
      });

      test('handles URL with query parameters', () {
        expect(
          'Link: https://example.com/page?q=test&lang=en'.linkifyUrls,
          'Link: <a href="https://example.com/page?q=test&amp;lang=en">'
          'https://example.com/page?q=test&lang=en</a>',
        );
      });

      test('handles URL with fragment', () {
        expect(
          'See https://example.com/page#section'.linkifyUrls,
          'See <a href="https://example.com/page#section">'
          'https://example.com/page#section</a>',
        );
      });

      test('does not double-wrap URL already in href attribute', () {
        const input = '<a href="https://example.com">Click here</a>';
        expect(input.linkifyUrls, input);
      });

      test('does not double-wrap URL that is anchor text', () {
        const input = '<a href="https://example.com">https://example.com</a>';
        expect(input.linkifyUrls, input);
      });

      test('handles multiple plain URLs', () {
        expect(
          'First http://a.com then https://b.com end'.linkifyUrls,
          'First <a href="http://a.com">http://a.com</a> '
          'then <a href="https://b.com">https://b.com</a> end',
        );
      });

      test('handles mixed HTML links and plain URLs', () {
        expect(
          '<a href="https://existing.com">link</a> and https://plain.com'
              .linkifyUrls,
          '<a href="https://existing.com">link</a> and '
          '<a href="https://plain.com">https://plain.com</a>',
        );
      });

      test('returns unchanged string with no URLs', () {
        const input = 'No links here, just text.';
        expect(input.linkifyUrls, input);
      });

      test('returns empty string unchanged', () {
        expect(''.linkifyUrls, '');
      });

      test('handles URL at start of string', () {
        expect(
          'https://start.com is first'.linkifyUrls,
          '<a href="https://start.com">https://start.com</a> is first',
        );
      });

      test('handles URL at end of string', () {
        expect(
          'end with https://end.com'.linkifyUrls,
          'end with <a href="https://end.com">https://end.com</a>',
        );
      });

      test('handles URL with port number', () {
        expect(
          'http://localhost:8080/api'.linkifyUrls,
          '<a href="http://localhost:8080/api">'
          'http://localhost:8080/api</a>',
        );
      });

      test('handles ftp URL', () {
        expect(
          'Download from ftp://files.example.com/data'.linkifyUrls,
          'Download from <a href="ftp://files.example.com/data">'
          'ftp://files.example.com/data</a>',
        );
      });

      test('does not linkify URL inside src attribute', () {
        const input = '<img src="https://img.example.com/pic.jpg">';
        expect(input.linkifyUrls, input);
      });

      test('handles URL followed by punctuation', () {
        expect(
          'See https://example.com.'.linkifyUrls,
          'See <a href="https://example.com">https://example.com</a>.',
        );
      });

      test('handles URL followed by comma', () {
        expect(
          'Visit https://example.com, then continue'.linkifyUrls,
          'Visit <a href="https://example.com">https://example.com</a>,'
          ' then continue',
        );
      });

      test('handles URL in parentheses', () {
        expect(
          '(https://example.com)'.linkifyUrls,
          '(<a href="https://example.com">https://example.com</a>)',
        );
      });

      test('handles URL with path and trailing slash', () {
        expect(
          'https://example.com/path/'.linkifyUrls,
          '<a href="https://example.com/path/">'
          'https://example.com/path/</a>',
        );
      });
    });

    group('plainTextToHtml', () {
      test('returns empty string unchanged', () {
        expect(''.plainTextToHtml, '');
      });

      test('skips conversion when content has HTML tags', () {
        const input = '<p>Already HTML</p>';
        expect(input.plainTextToHtml, input);
      });

      test('skips conversion when content has anchor tags', () {
        const input = '<a href="https://example.com">link</a>';
        expect(input.plainTextToHtml, input);
      });

      test('converts single newline to br', () {
        expect('Line one\nLine two'.plainTextToHtml, 'Line one<br>Line two');
      });

      test('converts double newlines to paragraph breaks', () {
        expect(
          'Para one\n\nPara two'.plainTextToHtml,
          '<p>Para one</p><p>Para two</p>',
        );
      });

      test('converts triple+ spaces to paragraph breaks', () {
        expect(
          'First part.   Second part.'.plainTextToHtml,
          '<p>First part.</p><p>Second part.</p>',
        );
      });

      test('handles mixed newlines and multi-spaces', () {
        expect('A\n\nB   C'.plainTextToHtml, '<p>A</p><p>B</p><p>C</p>');
      });

      test('preserves single spaces between words', () {
        expect('Hello world'.plainTextToHtml, 'Hello world');
      });

      test('trims leading and trailing whitespace in paragraphs', () {
        expect(
          'First.   \n\n   Second.'.plainTextToHtml,
          '<p>First.</p><p>Second.</p>',
        );
      });

      test('handles CRLF newlines', () {
        expect('Line one\r\nLine two'.plainTextToHtml, 'Line one<br>Line two');
      });

      test('handles real podcast description with multi-space separators', () {
        const input =
            '【PR】 日経電子版から、お得なキャンペーンのご案内です。'
            '   技術革新が加速する今、新聞も進化を続けています。';
        final result = input.plainTextToHtml;
        expect(result, contains('<p>'));
        expect(result, contains('【PR】'));
        expect(result, contains('技術革新'));
      });

      test('does not create empty paragraphs', () {
        expect('A\n\n\n\nB'.plainTextToHtml, '<p>A</p><p>B</p>');
      });
    });
  });
}
