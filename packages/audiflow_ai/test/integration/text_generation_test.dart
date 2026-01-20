// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

/// Integration tests for text generation (Task 8.2).
///
/// Verifies end-to-end text generation across:
/// - Generation with simple prompts on both platforms
/// - Custom config parameters
/// - Error handling for initialization failures
/// - Error handling for prompt too long
/// - Response metadata (token count, duration)
library;

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Text Generation Integration Tests (Task 8.2)', () {
    late List<MethodCall> methodCalls;

    /// Sets up a mock platform channel that simulates text generation.
    void setUpPlatformChannel({
      String generatedText = 'Generated response text',
      int tokenCount = 50,
      int durationMs = 250,
      bool shouldFail = false,
      String? errorCode,
      String? errorMessage,
      String? errorDetails,
      bool isAndroid = true,
    }) {
      methodCalls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(AudiflowAiChannel.name),
            (call) async {
              methodCalls.add(call);
              switch (call.method) {
                case AudiflowAiChannel.checkCapability:
                  return <String, dynamic>{
                    AudiflowAiChannel.kStatus: AudiflowAiChannel.kStatusFull,
                  };
                case AudiflowAiChannel.initialize:
                  return <String, dynamic>{AudiflowAiChannel.kSuccess: true};
                case AudiflowAiChannel.generateText:
                  if (shouldFail) {
                    throw PlatformException(
                      code: errorCode ?? 'GENERATION_FAILED',
                      message: errorMessage ?? 'Generation failed',
                      details: errorDetails,
                    );
                  }
                  return <String, dynamic>{
                    AudiflowAiChannel.kText: generatedText,
                    AudiflowAiChannel.kTokenCount: tokenCount,
                    AudiflowAiChannel.kDurationMs: durationMs,
                  };
                case AudiflowAiChannel.dispose:
                  return <String, dynamic>{AudiflowAiChannel.kSuccess: true};
                default:
                  return null;
              }
            },
          );
    }

    void clearPlatformChannel() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(AudiflowAiChannel.name),
            null,
          );
    }

    setUp(() {
      AudiflowAi.resetInstance();
    });

    tearDown(() {
      clearPlatformChannel();
      AudiflowAi.resetInstance();
    });

    group('Simple prompt generation', () {
      test(
        'generates text with simple prompt on Android',
        () async {
          setUpPlatformChannel(
            generatedText: 'Android generated response',
            tokenCount: 25,
            durationMs: 150,
            isAndroid: true,
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final response = await ai.generateText(prompt: 'Tell me a joke');

          expect(response.text, equals('Android generated response'));
          expect(response.tokenCount, equals(25));
          expect(response.durationMs, equals(150));

          // Verify the prompt was passed to platform channel
          final generateCall = methodCalls.firstWhere(
            (c) => c.method == AudiflowAiChannel.generateText,
          );
          expect(generateCall.arguments['prompt'], equals('Tell me a joke'));
        },
      );

      test(
        'generates text with simple prompt on iOS',
        () async {
          setUpPlatformChannel(
            generatedText: 'iOS generated response',
            tokenCount: 30,
            durationMs: 200,
            isAndroid: false,
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final response = await ai.generateText(
            prompt: 'Summarize this podcast',
          );

          expect(response.text, equals('iOS generated response'));
          expect(response.tokenCount, equals(30));
          expect(response.durationMs, equals(200));
        },
      );

      test(
        'handles empty prompt gracefully',
        () async {
          setUpPlatformChannel(generatedText: '');

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final response = await ai.generateText(prompt: '');

          expect(response.text, isEmpty);
        },
      );
    });

    group('Custom config parameters', () {
      test(
        'passes temperature to platform channel',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          await ai.generateText(
            prompt: 'Test',
            config: const GenerationConfig(temperature: 0.9),
          );

          final generateCall = methodCalls.firstWhere(
            (c) => c.method == AudiflowAiChannel.generateText,
          );
          expect(
            (generateCall.arguments['config'] as Map)['temperature'],
            equals(0.9),
          );
        },
      );

      test(
        'passes maxOutputTokens to platform channel',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          await ai.generateText(
            prompt: 'Test',
            config: const GenerationConfig(maxOutputTokens: 1024),
          );

          final generateCall = methodCalls.firstWhere(
            (c) => c.method == AudiflowAiChannel.generateText,
          );
          expect(
            (generateCall.arguments['config'] as Map)['maxOutputTokens'],
            equals(1024),
          );
        },
      );

      test(
        'passes combined config parameters to platform channel',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          await ai.generateText(
            prompt: 'Complex prompt',
            config: const GenerationConfig(
              temperature: 0.5,
              maxOutputTokens: 512,
            ),
          );

          final generateCall = methodCalls.firstWhere(
            (c) => c.method == AudiflowAiChannel.generateText,
          );
          final config = generateCall.arguments['config'] as Map;
          expect(config['temperature'], equals(0.5));
          expect(config['maxOutputTokens'], equals(512));
        },
      );

      test(
        'uses default config when none provided',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          await ai.generateText(prompt: 'Simple prompt');

          final generateCall = methodCalls.firstWhere(
            (c) => c.method == AudiflowAiChannel.generateText,
          );
          // Config should not be present when not provided
          expect(generateCall.arguments.containsKey('config'), isFalse);
        },
      );
    });

    group('Initialization failure handling', () {
      test(
        'throws AiNotInitializedException when not initialized',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          // Not calling initialize()

          expect(
            () => ai.generateText(prompt: 'Test'),
            throwsA(isA<AiNotInitializedException>()),
          );
        },
      );

      test(
        'throws AiNotInitializedException after dispose',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();
          await ai.dispose();

          expect(
            () => ai.generateText(prompt: 'Test'),
            throwsA(isA<AiNotInitializedException>()),
          );
        },
      );

      test(
        'allows generation after reinitialize',
        () async {
          setUpPlatformChannel(generatedText: 'After reinit');

          final ai = AudiflowAi.instance;
          await ai.initialize();
          await ai.reinitialize();

          final response = await ai.generateText(prompt: 'Test');
          expect(response.text, equals('After reinit'));
        },
      );
    });

    group('Prompt too long error handling', () {
      test(
        'throws PromptTooLongException when prompt exceeds limit',
        () async {
          setUpPlatformChannel(
            shouldFail: true,
            errorCode: 'PROMPT_TOO_LONG',
            errorMessage: 'Prompt exceeds maximum length',
            errorDetails: '4000',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          expect(
            () => ai.generateText(prompt: 'Very long prompt...'),
            throwsA(
              isA<PromptTooLongException>().having(
                (e) => e.maxTokens,
                'maxTokens',
                equals(4000),
              ),
            ),
          );
        },
      );

      test(
        'PromptTooLongException contains descriptive message',
        () async {
          setUpPlatformChannel(
            shouldFail: true,
            errorCode: 'PROMPT_TOO_LONG',
            errorDetails: '2048',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          try {
            await ai.generateText(prompt: 'Long prompt');
            fail('Should have thrown');
          } on PromptTooLongException catch (e) {
            expect(e.message, contains('2048'));
            expect(e.maxTokens, equals(2048));
          }
        },
      );
    });

    group('Generation failure handling', () {
      test(
        'throws AiGenerationException on platform generation failure',
        () async {
          setUpPlatformChannel(
            shouldFail: true,
            errorCode: 'MODEL_ERROR',
            errorMessage: 'Model inference failed',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          expect(
            () => ai.generateText(prompt: 'Test'),
            throwsA(
              isA<AiGenerationException>().having(
                (e) => e.message,
                'message',
                contains('failed'),
              ),
            ),
          );
        },
      );

      test(
        'AiGenerationException preserves cause',
        () async {
          setUpPlatformChannel(
            shouldFail: true,
            errorCode: 'INTERNAL_ERROR',
            errorMessage: 'Internal model error',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          try {
            await ai.generateText(prompt: 'Test');
            fail('Should have thrown');
          } on AiGenerationException catch (e) {
            expect(e.cause, isA<PlatformException>());
          }
        },
      );
    });

    group('Response metadata', () {
      test(
        'response includes token count',
        () async {
          setUpPlatformChannel(tokenCount: 75);

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final response = await ai.generateText(prompt: 'Test');

          expect(response.tokenCount, equals(75));
        },
      );

      test(
        'response includes duration in milliseconds',
        () async {
          setUpPlatformChannel(durationMs: 350);

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final response = await ai.generateText(prompt: 'Test');

          expect(response.durationMs, equals(350));
        },
      );

      test(
        'response handles null token count gracefully',
        () async {
          methodCalls = [];
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                const MethodChannel(AudiflowAiChannel.name),
                (call) async {
                  methodCalls.add(call);
                  switch (call.method) {
                    case AudiflowAiChannel.checkCapability:
                      return <String, dynamic>{
                        AudiflowAiChannel.kStatus:
                            AudiflowAiChannel.kStatusFull,
                      };
                    case AudiflowAiChannel.initialize:
                      return <String, dynamic>{
                        AudiflowAiChannel.kSuccess: true,
                      };
                    case AudiflowAiChannel.generateText:
                      return <String, dynamic>{
                        AudiflowAiChannel.kText: 'Response without token count',
                        // No tokenCount or durationMs
                      };
                    default:
                      return null;
                  }
                },
              );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final response = await ai.generateText(prompt: 'Test');

          expect(response.text, equals('Response without token count'));
          expect(response.tokenCount, isNull);
          expect(response.durationMs, isNull);
        },
      );

      test(
        'response can include additional metadata',
        () async {
          // This tests that the AiResponse model supports metadata
          const response = AiResponse(
            text: 'Generated text',
            tokenCount: 50,
            durationMs: 200,
            metadata: {
              'model': 'gemini-nano',
              'platform': 'android',
              'version': '1.0',
            },
          );

          expect(response.metadata, isNotNull);
          expect(response.metadata!['model'], equals('gemini-nano'));
          expect(response.metadata!['platform'], equals('android'));
        },
      );
    });

    group('Cross-layer communication', () {
      test(
        'generation request flows through all layers',
        () async {
          setUpPlatformChannel(generatedText: 'Layered response');

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final response = await ai.generateText(prompt: 'Multi-layer test');

          // Verify all expected method calls occurred
          expect(
            methodCalls.map((c) => c.method).toList(),
            containsAll([
              AudiflowAiChannel.checkCapability,
              AudiflowAiChannel.initialize,
              AudiflowAiChannel.generateText,
            ]),
          );

          expect(response.text, equals('Layered response'));
        },
      );

      test(
        'multiple sequential generations work correctly',
        () async {
          var callCount = 0;
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                const MethodChannel(AudiflowAiChannel.name),
                (call) async {
                  switch (call.method) {
                    case AudiflowAiChannel.checkCapability:
                      return <String, dynamic>{
                        AudiflowAiChannel.kStatus:
                            AudiflowAiChannel.kStatusFull,
                      };
                    case AudiflowAiChannel.initialize:
                      return <String, dynamic>{
                        AudiflowAiChannel.kSuccess: true,
                      };
                    case AudiflowAiChannel.generateText:
                      callCount++;
                      return <String, dynamic>{
                        AudiflowAiChannel.kText: 'Response $callCount',
                        AudiflowAiChannel.kTokenCount: callCount * 10,
                      };
                    default:
                      return null;
                  }
                },
              );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final response1 = await ai.generateText(prompt: 'First');
          final response2 = await ai.generateText(prompt: 'Second');
          final response3 = await ai.generateText(prompt: 'Third');

          expect(response1.text, equals('Response 1'));
          expect(response2.text, equals('Response 2'));
          expect(response3.text, equals('Response 3'));
          expect(response1.tokenCount, equals(10));
          expect(response2.tokenCount, equals(20));
          expect(response3.tokenCount, equals(30));
        },
      );
    });
  });
}
