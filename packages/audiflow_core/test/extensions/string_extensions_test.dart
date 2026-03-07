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
  });
}
