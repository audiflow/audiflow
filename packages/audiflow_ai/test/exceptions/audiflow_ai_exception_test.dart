// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudiflowAiException', () {
    test('extends AppException', () {
      final exception = AudiflowAiException('Test error', 'TEST_CODE');

      expect(exception, isA<AppException>());
    });

    test('creates instance with message only', () {
      final exception = AudiflowAiException('Test error');

      expect(exception.message, equals('Test error'));
      expect(exception.cause, isNull);
    });

    test('creates instance with message and code', () {
      final exception = AudiflowAiException('Test error', 'TEST_CODE');

      expect(exception.message, equals('Test error'));
      expect(exception.code, equals('TEST_CODE'));
    });

    test('creates instance with cause', () {
      final cause = Exception('Original error');
      final exception = AudiflowAiException('Test error', 'TEST_CODE', cause);

      expect(exception.cause, equals(cause));
    });

    test('toString includes message', () {
      final exception = AudiflowAiException('Test error');

      expect(exception.toString(), contains('Test error'));
    });

    test('toString includes cause when present', () {
      final cause = Exception('Original error');
      final exception = AudiflowAiException('Test error', 'TEST_CODE', cause);

      expect(exception.toString(), contains('cause:'));
      expect(exception.toString(), contains('Original error'));
    });

    test('toString does not include cause when null', () {
      final exception = AudiflowAiException('Test error', 'TEST_CODE');

      expect(exception.toString(), isNot(contains('cause:')));
    });
  });

  group('AiNotAvailableException', () {
    test('extends AudiflowAiException', () {
      final exception = AiNotAvailableException();

      expect(exception, isA<AudiflowAiException>());
    });

    test('has default message', () {
      final exception = AiNotAvailableException();

      expect(
        exception.message,
        equals('On-device AI is not available on this device'),
      );
    });

    test('has correct error code', () {
      final exception = AiNotAvailableException();

      expect(exception.code, equals('AI_NOT_AVAILABLE'));
    });

    test('accepts custom details message', () {
      final exception = AiNotAvailableException('Custom details');

      expect(exception.message, equals('Custom details'));
    });
  });

  group('AiNotInitializedException', () {
    test('extends AudiflowAiException', () {
      final exception = AiNotInitializedException();

      expect(exception, isA<AudiflowAiException>());
    });

    test('has correct message', () {
      final exception = AiNotInitializedException();

      expect(
        exception.message,
        equals(
          'AI engine not initialized. Call AudiflowAi.initialize() first.',
        ),
      );
    });

    test('has correct error code', () {
      final exception = AiNotInitializedException();

      expect(exception.code, equals('AI_NOT_INITIALIZED'));
    });
  });

  group('AiCoreRequiredException', () {
    test('extends AudiflowAiException', () {
      final exception = AiCoreRequiredException();

      expect(exception, isA<AudiflowAiException>());
    });

    test('has correct message', () {
      final exception = AiCoreRequiredException();

      expect(
        exception.message,
        equals(
          'Google AICore is required. Call AudiflowAi.promptAiCoreInstall().',
        ),
      );
    });

    test('has correct error code', () {
      final exception = AiCoreRequiredException();

      expect(exception.code, equals('AICORE_REQUIRED'));
    });
  });

  group('AiGenerationException', () {
    test('extends AudiflowAiException', () {
      final exception = AiGenerationException('Generation failed');

      expect(exception, isA<AudiflowAiException>());
    });

    test('accepts custom message', () {
      final exception = AiGenerationException('Custom generation error');

      expect(exception.message, equals('Custom generation error'));
    });

    test('has correct error code', () {
      final exception = AiGenerationException('Error');

      expect(exception.code, equals('AI_GENERATION_FAILED'));
    });

    test('accepts cause parameter', () {
      final cause = Exception('Original error');
      final exception = AiGenerationException('Generation failed', cause);

      expect(exception.cause, equals(cause));
    });

    test('toString includes cause when present', () {
      final cause = Exception('Original error');
      final exception = AiGenerationException('Generation failed', cause);

      expect(exception.toString(), contains('cause:'));
    });
  });

  group('AiSummarizationException', () {
    test('extends AudiflowAiException', () {
      final exception = AiSummarizationException('Summarization failed');

      expect(exception, isA<AudiflowAiException>());
    });

    test('accepts custom message', () {
      final exception = AiSummarizationException('Custom summarization error');

      expect(exception.message, equals('Custom summarization error'));
    });

    test('has correct error code', () {
      final exception = AiSummarizationException('Error');

      expect(exception.code, equals('AI_SUMMARIZATION_FAILED'));
    });

    test('accepts cause parameter', () {
      final cause = Exception('Original error');
      final exception = AiSummarizationException('Summarization failed', cause);

      expect(exception.cause, equals(cause));
    });
  });

  group('PromptTooLongException', () {
    test('extends AudiflowAiException', () {
      final exception = PromptTooLongException(4000);

      expect(exception, isA<AudiflowAiException>());
    });

    test('has correct message with token count', () {
      final exception = PromptTooLongException(4000);

      expect(
        exception.message,
        equals('Prompt exceeds maximum length of 4000 tokens'),
      );
    });

    test('has correct error code', () {
      final exception = PromptTooLongException(4000);

      expect(exception.code, equals('PROMPT_TOO_LONG'));
    });

    test('stores maxTokens value', () {
      final exception = PromptTooLongException(4000);

      expect(exception.maxTokens, equals(4000));
    });

    test('works with different token values', () {
      final exception1 = PromptTooLongException(1000);
      final exception2 = PromptTooLongException(8000);

      expect(exception1.maxTokens, equals(1000));
      expect(exception2.maxTokens, equals(8000));
      expect(
        exception1.message,
        contains('1000'),
      );
      expect(
        exception2.message,
        contains('8000'),
      );
    });
  });

  group('InsufficientContentException', () {
    test('extends AudiflowAiException', () {
      final exception = InsufficientContentException();

      expect(exception, isA<AudiflowAiException>());
    });

    test('has default message', () {
      final exception = InsufficientContentException();

      expect(
        exception.message,
        equals('Insufficient content for processing'),
      );
    });

    test('has correct error code', () {
      final exception = InsufficientContentException();

      expect(exception.code, equals('INSUFFICIENT_CONTENT'));
    });

    test('accepts custom details message', () {
      final exception = InsufficientContentException(
        'Episode title and description are both empty',
      );

      expect(
        exception.message,
        equals('Episode title and description are both empty'),
      );
    });
  });

  group('Exception hierarchy', () {
    test('all exceptions are throwable', () {
      expect(
        () => throw AudiflowAiException('test'),
        throwsA(isA<AudiflowAiException>()),
      );
      expect(
        () => throw AiNotAvailableException(),
        throwsA(isA<AiNotAvailableException>()),
      );
      expect(
        () => throw AiNotInitializedException(),
        throwsA(isA<AiNotInitializedException>()),
      );
      expect(
        () => throw AiCoreRequiredException(),
        throwsA(isA<AiCoreRequiredException>()),
      );
      expect(
        () => throw AiGenerationException('test'),
        throwsA(isA<AiGenerationException>()),
      );
      expect(
        () => throw AiSummarizationException('test'),
        throwsA(isA<AiSummarizationException>()),
      );
      expect(
        () => throw PromptTooLongException(4000),
        throwsA(isA<PromptTooLongException>()),
      );
      expect(
        () => throw InsufficientContentException(),
        throwsA(isA<InsufficientContentException>()),
      );
    });

    test('all subclasses can be caught as AudiflowAiException', () {
      final exceptions = <AudiflowAiException>[
        AiNotAvailableException(),
        AiNotInitializedException(),
        AiCoreRequiredException(),
        AiGenerationException('test'),
        AiSummarizationException('test'),
        PromptTooLongException(4000),
        InsufficientContentException(),
      ];

      for (final exception in exceptions) {
        try {
          throw exception;
        } on AudiflowAiException catch (e) {
          expect(e, isNotNull);
        }
      }
    });

    test('all subclasses can be caught as AppException', () {
      final exceptions = <AppException>[
        AudiflowAiException('test'),
        AiNotAvailableException(),
        AiNotInitializedException(),
        AiCoreRequiredException(),
        AiGenerationException('test'),
        AiSummarizationException('test'),
        PromptTooLongException(4000),
        InsufficientContentException(),
      ];

      for (final exception in exceptions) {
        try {
          throw exception;
        } on AppException catch (e) {
          expect(e, isNotNull);
        }
      }
    });

    test('each exception type can be caught specifically', () {
      void throwAndCatch<T extends AudiflowAiException>(T exception) {
        try {
          throw exception;
        } on T catch (e) {
          expect(e, equals(exception));
        }
      }

      throwAndCatch(AiNotAvailableException());
      throwAndCatch(AiNotInitializedException());
      throwAndCatch(AiCoreRequiredException());
      throwAndCatch(AiGenerationException('test'));
      throwAndCatch(AiSummarizationException('test'));
      throwAndCatch(PromptTooLongException(4000));
      throwAndCatch(InsufficientContentException());
    });
  });
}
