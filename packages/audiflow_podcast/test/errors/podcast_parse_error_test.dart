import 'package:flutter_test/flutter_test.dart';
import 'package:audiflow_podcast/src/errors/podcast_parse_error.dart';

import '../helpers/test_constants.dart';

void main() {
  group('PodcastParseError', () {
    final now = DateTime.now();

    group('XmlParsingError', () {
      test('creates error with all fields', () {
        const message = 'Invalid XML structure';
        const elementName = 'channel';
        final originalException = Exception('XML parse failed');

        final error = XmlParsingError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
          elementName: elementName,
          originalException: originalException,
        );

        expect(error.message, equals(message));
        expect(error.elementName, equals(elementName));
        expect(error.originalException, equals(originalException));
        expect(error.parsedAt, equals(now));
        expect(error.sourceUrl, equals(testSourceUrl));
      });

      test('creates error with minimal fields', () {
        const message = 'XML error';

        final error = XmlParsingError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
        );

        expect(error.message, equals(message));
        expect(error.elementName, isNull);
        expect(error.originalException, isNull);
      });

      test('toString includes all available information', () {
        const message = 'Invalid XML';
        const elementName = 'item';

        final error = XmlParsingError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
          elementName: elementName,
          originalException: Exception('Parse failed'),
        );

        final string = error.toString();
        expect(string, contains('XmlParsingError'));
        expect(string, contains(message));
        expect(string, contains('element: $elementName'));
        expect(string, contains('Original: Exception: Parse failed'));
      });
    });

    group('EntityValidationError', () {
      test('creates error with validation details', () {
        const message = 'Validation failed';
        const entityType = 'Feed';
        const validationErrors = ['Title is required', 'Invalid URL'];
        const elementName = 'title';

        final error = EntityValidationError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
          entityType: entityType,
          validationErrors: validationErrors,
          elementName: elementName,
        );

        expect(error.message, equals(message));
        expect(error.entityType, equals(entityType));
        expect(error.validationErrors, equals(validationErrors));
        expect(error.elementName, equals(elementName));
      });

      test('toString includes validation errors', () {
        const message = 'Validation failed';
        const entityType = 'Item';
        const validationErrors = [
          'Duration invalid',
          'Episode number negative',
        ];

        final error = EntityValidationError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
          entityType: entityType,
          validationErrors: validationErrors,
        );

        final string = error.toString();
        expect(string, contains('EntityValidationError'));
        expect(string, contains(message));
        expect(string, contains('entityType: $entityType'));
        expect(string, contains(validationErrors.join(', ')));
      });
    });

    group('NetworkError', () {
      test('creates error with status code', () {
        const message = 'HTTP request failed';
        const statusCode = 404;
        final originalException = Exception('Not found');

        final error = NetworkError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
          statusCode: statusCode,
          originalException: originalException,
        );

        expect(error.message, equals(message));
        expect(error.statusCode, equals(statusCode));
        expect(error.originalException, equals(originalException));
      });

      test('toString includes status code', () {
        const message = 'Request timeout';
        const statusCode = 408;

        final error = NetworkError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
          statusCode: statusCode,
        );

        final string = error.toString();
        expect(string, contains('NetworkError'));
        expect(string, contains(message));
        expect(string, contains('status: $statusCode'));
      });
    });

    group('CacheError', () {
      test('creates error with operation details', () {
        const message = 'Cache write failed';
        const operation = 'write';
        final originalException = Exception('Disk full');

        final error = CacheError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
          operation: operation,
          originalException: originalException,
        );

        expect(error.message, equals(message));
        expect(error.operation, equals(operation));
        expect(error.originalException, equals(originalException));
      });

      test('toString includes operation', () {
        const message = 'Cache read failed';
        const operation = 'read';

        final error = CacheError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
          operation: operation,
        );

        final string = error.toString();
        expect(string, contains('CacheError'));
        expect(string, contains(message));
        expect(string, contains('operation: $operation'));
      });
    });

    group('PodcastParseWarning', () {
      test('creates warning with all fields', () {
        const message = 'Invalid date format, using default';
        const elementName = 'pubDate';
        const entityType = 'Item';

        final warning = PodcastParseWarning(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
          elementName: elementName,
          entityType: entityType,
        );

        expect(warning.message, equals(message));
        expect(warning.elementName, equals(elementName));
        expect(warning.entityType, equals(entityType));
        expect(warning.parsedAt, equals(now));
        expect(warning.sourceUrl, equals(testSourceUrl));
      });

      test('creates warning with minimal fields', () {
        const message = 'Minor parsing issue';

        final warning = PodcastParseWarning(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
        );

        expect(warning.message, equals(message));
        expect(warning.elementName, isNull);
        expect(warning.entityType, isNull);
      });

      test('toString includes all available information', () {
        const message = 'Invalid duration format';
        const elementName = 'itunesDuration';
        const entityType = 'Item';

        final warning = PodcastParseWarning(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: message,
          elementName: elementName,
          entityType: entityType,
        );

        final string = warning.toString();
        expect(string, contains('PodcastParseWarning'));
        expect(string, contains(message));
        expect(string, contains('entityType: $entityType'));
        expect(string, contains('element: $elementName'));
      });
    });

    group('error inheritance', () {
      test('all error types extend PodcastParseError', () {
        final xmlError = XmlParsingError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: 'XML error',
        );

        final validationError = EntityValidationError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: 'Validation error',
          entityType: 'Feed',
          validationErrors: [],
        );

        final networkError = NetworkError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: 'Network error',
        );

        final cacheError = CacheError(
          parsedAt: now,
          sourceUrl: testSourceUrl,
          message: 'Cache error',
          operation: 'read',
        );

        expect(xmlError, isA<PodcastParseError>());
        expect(validationError, isA<PodcastParseError>());
        expect(networkError, isA<PodcastParseError>());
        expect(cacheError, isA<PodcastParseError>());
      });
    });
  });
}
