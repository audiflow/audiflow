import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    group('isValidEmail()', () {
      test('returns true for valid email', () {
        expect(Validators.isValidEmail('user@example.com'), isTrue);
      });

      test('returns true for email with dots in local part', () {
        expect(Validators.isValidEmail('first.last@example.com'), isTrue);
      });

      test('returns true for email with plus sign', () {
        expect(Validators.isValidEmail('user+tag@example.com'), isTrue);
      });

      test('returns true for email with subdomain', () {
        expect(Validators.isValidEmail('user@mail.example.com'), isTrue);
      });

      test('returns true for email with numbers', () {
        expect(Validators.isValidEmail('user123@example456.com'), isTrue);
      });

      test('returns true for email with percent sign', () {
        expect(Validators.isValidEmail('user%name@example.com'), isTrue);
      });

      test('returns true for email with hyphen in domain', () {
        expect(Validators.isValidEmail('user@my-domain.com'), isTrue);
      });

      test('returns false for empty string', () {
        expect(Validators.isValidEmail(''), isFalse);
      });

      test('returns false for missing @ sign', () {
        expect(Validators.isValidEmail('userexample.com'), isFalse);
      });

      test('returns false for missing domain', () {
        expect(Validators.isValidEmail('user@'), isFalse);
      });

      test('returns false for missing local part', () {
        expect(Validators.isValidEmail('@example.com'), isFalse);
      });

      test('returns false for missing TLD', () {
        expect(Validators.isValidEmail('user@example'), isFalse);
      });

      test('returns false for spaces in email', () {
        expect(Validators.isValidEmail('user @example.com'), isFalse);
      });

      test('returns false for double @ sign', () {
        expect(Validators.isValidEmail('user@@example.com'), isFalse);
      });

      test('returns true for single char TLD with 2+ chars', () {
        expect(Validators.isValidEmail('a@b.co'), isTrue);
      });

      test('returns false for single char TLD', () {
        expect(Validators.isValidEmail('user@example.c'), isFalse);
      });
    });

    group('isValidUrl()', () {
      test('returns true for http URL', () {
        expect(Validators.isValidUrl('http://example.com'), isTrue);
      });

      test('returns true for https URL', () {
        expect(Validators.isValidUrl('https://example.com'), isTrue);
      });

      test('returns true for URL with path', () {
        expect(
          Validators.isValidUrl('https://example.com/path/to/resource'),
          isTrue,
        );
      });

      test('returns true for URL with query parameters', () {
        expect(Validators.isValidUrl('https://example.com?key=value'), isTrue);
      });

      test('returns true for URL with port', () {
        expect(Validators.isValidUrl('https://example.com:8080'), isTrue);
      });

      test('returns true for URL with fragment', () {
        expect(Validators.isValidUrl('https://example.com#section'), isTrue);
      });

      test('returns true for ftp URL', () {
        expect(Validators.isValidUrl('ftp://files.example.com'), isTrue);
      });

      test('returns false for empty string', () {
        expect(Validators.isValidUrl(''), isFalse);
      });

      test('returns false for plain text', () {
        expect(Validators.isValidUrl('not a url'), isFalse);
      });

      test('returns false for missing scheme', () {
        expect(Validators.isValidUrl('example.com'), isFalse);
      });

      test('returns true for scheme with empty authority', () {
        // Uri.parse('https://') has both scheme and authority (empty)
        // so the validator considers it valid per implementation
        expect(Validators.isValidUrl('https://'), isTrue);
      });

      test('returns false for relative path only', () {
        expect(Validators.isValidUrl('/path/to/resource'), isFalse);
      });
    });

    group('isNotEmpty()', () {
      test('returns true for non-empty string', () {
        expect(Validators.isNotEmpty('hello'), isTrue);
      });

      test('returns true for string with content and spaces', () {
        expect(Validators.isNotEmpty(' hello '), isTrue);
      });

      test('returns false for null', () {
        expect(Validators.isNotEmpty(null), isFalse);
      });

      test('returns false for empty string', () {
        expect(Validators.isNotEmpty(''), isFalse);
      });

      test('returns false for whitespace only', () {
        expect(Validators.isNotEmpty('   '), isFalse);
      });

      test('returns false for tab characters only', () {
        expect(Validators.isNotEmpty('\t'), isFalse);
      });

      test('returns false for newline only', () {
        expect(Validators.isNotEmpty('\n'), isFalse);
      });

      test('returns true for single character', () {
        expect(Validators.isNotEmpty('a'), isTrue);
      });

      test('returns true for numeric string', () {
        expect(Validators.isNotEmpty('123'), isTrue);
      });
    });
  });
}
