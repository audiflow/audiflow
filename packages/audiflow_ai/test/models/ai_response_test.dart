// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiResponse', () {
    group('constructor', () {
      test('creates instance with required text', () {
        const response = AiResponse(text: 'Generated text');

        expect(response.text, equals('Generated text'));
        expect(response.tokenCount, isNull);
        expect(response.durationMs, isNull);
        expect(response.metadata, isNull);
      });

      test('creates instance with all parameters', () {
        const response = AiResponse(
          text: 'Generated text',
          tokenCount: 10,
          durationMs: 500,
          metadata: {'key': 'value'},
        );

        expect(response.text, equals('Generated text'));
        expect(response.tokenCount, equals(10));
        expect(response.durationMs, equals(500));
        expect(response.metadata, equals({'key': 'value'}));
      });

      test('creates instance with empty text', () {
        const response = AiResponse(text: '');

        expect(response.text, isEmpty);
      });
    });

    group('isComplete', () {
      test('returns true when metadata is null', () {
        const response = AiResponse(text: 'text');

        expect(response.isComplete, isTrue);
      });

      test('returns true when metadata does not contain truncated', () {
        const response = AiResponse(
          text: 'text',
          metadata: {'other': 'value'},
        );

        expect(response.isComplete, isTrue);
      });

      test('returns true when truncated is false', () {
        const response = AiResponse(
          text: 'text',
          metadata: {'truncated': false},
        );

        expect(response.isComplete, isTrue);
      });

      test('returns false when truncated is true', () {
        const response = AiResponse(
          text: 'text',
          metadata: {'truncated': true},
        );

        expect(response.isComplete, isFalse);
      });
    });

    group('wasTruncated', () {
      test('returns false when metadata is null', () {
        const response = AiResponse(text: 'text');

        expect(response.wasTruncated, isFalse);
      });

      test('returns false when metadata does not contain truncated', () {
        const response = AiResponse(
          text: 'text',
          metadata: {'other': 'value'},
        );

        expect(response.wasTruncated, isFalse);
      });

      test('returns false when truncated is false', () {
        const response = AiResponse(
          text: 'text',
          metadata: {'truncated': false},
        );

        expect(response.wasTruncated, isFalse);
      });

      test('returns true when truncated is true', () {
        const response = AiResponse(
          text: 'text',
          metadata: {'truncated': true},
        );

        expect(response.wasTruncated, isTrue);
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        const response1 = AiResponse(
          text: 'Generated text',
          tokenCount: 10,
          durationMs: 500,
        );
        const response2 = AiResponse(
          text: 'Generated text',
          tokenCount: 10,
          durationMs: 500,
        );

        expect(response1, equals(response2));
      });

      test('different text makes instances unequal', () {
        const response1 = AiResponse(text: 'Text 1');
        const response2 = AiResponse(text: 'Text 2');

        expect(response1, isNot(equals(response2)));
      });

      test('different tokenCount makes instances unequal', () {
        const response1 = AiResponse(text: 'text', tokenCount: 10);
        const response2 = AiResponse(text: 'text', tokenCount: 20);

        expect(response1, isNot(equals(response2)));
      });

      test('different durationMs makes instances unequal', () {
        const response1 = AiResponse(text: 'text', durationMs: 100);
        const response2 = AiResponse(text: 'text', durationMs: 200);

        expect(response1, isNot(equals(response2)));
      });

      test('identical instance is equal to itself', () {
        const response = AiResponse(text: 'text');

        expect(response, equals(response));
      });
    });

    group('hashCode', () {
      test('equal instances have same hashCode', () {
        const response1 = AiResponse(
          text: 'Generated text',
          tokenCount: 10,
          durationMs: 500,
        );
        const response2 = AiResponse(
          text: 'Generated text',
          tokenCount: 10,
          durationMs: 500,
        );

        expect(response1.hashCode, equals(response2.hashCode));
      });
    });

    group('toString', () {
      test('returns formatted string with all values', () {
        const response = AiResponse(
          text: 'Hello world',
          tokenCount: 2,
          durationMs: 100,
        );

        expect(
          response.toString(),
          equals(
            'AiResponse(text: 11 chars, tokenCount: 2, durationMs: 100)',
          ),
        );
      });

      test('returns formatted string with null values', () {
        const response = AiResponse(text: 'Test');

        expect(
          response.toString(),
          equals(
            'AiResponse(text: 4 chars, tokenCount: null, durationMs: null)',
          ),
        );
      });
    });
  });
}
