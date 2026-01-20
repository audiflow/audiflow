// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_ai/src/services/text_generation_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TextGenerationService', () {
    late TextGenerationService service;
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];
      service = TextGenerationService();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(AudiflowAiChannel.name),
            (call) async {
              methodCalls.add(call);
              return _handleMethodCall(call);
            },
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(AudiflowAiChannel.name),
            null,
          );
    });

    group('isInitialized', () {
      test('returns false before initialization', () {
        expect(service.isInitialized, isFalse);
      });

      test('returns true after initialization', () async {
        await service.initialize();
        expect(service.isInitialized, isTrue);
      });
    });

    group('isAvailable', () {
      test('invokes checkCapability on platform channel', () async {
        await service.isAvailable();

        expect(methodCalls, hasLength(1));
        expect(
          methodCalls.first.method,
          equals(AudiflowAiChannel.checkCapability),
        );
      });

      test('returns true when capability is full', () async {
        final result = await service.isAvailable();
        expect(result, isTrue);
      });

      test('returns true when capability is limited', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel(AudiflowAiChannel.name),
              (call) async {
                methodCalls.add(call);
                if (call.method == AudiflowAiChannel.checkCapability) {
                  return {
                    AudiflowAiChannel.kStatus: AudiflowAiChannel.kStatusLimited,
                  };
                }
                return _handleMethodCall(call);
              },
            );

        final result = await service.isAvailable();
        expect(result, isTrue);
      });

      test('returns false when capability is unavailable', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel(AudiflowAiChannel.name),
              (call) async {
                methodCalls.add(call);
                if (call.method == AudiflowAiChannel.checkCapability) {
                  return {
                    AudiflowAiChannel.kStatus:
                        AudiflowAiChannel.kStatusUnavailable,
                  };
                }
                return _handleMethodCall(call);
              },
            );

        final result = await service.isAvailable();
        expect(result, isFalse);
      });

      test('returns false when capability is needsSetup', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel(AudiflowAiChannel.name),
              (call) async {
                methodCalls.add(call);
                if (call.method == AudiflowAiChannel.checkCapability) {
                  return {
                    AudiflowAiChannel.kStatus:
                        AudiflowAiChannel.kStatusNeedsSetup,
                  };
                }
                return _handleMethodCall(call);
              },
            );

        final result = await service.isAvailable();
        expect(result, isFalse);
      });
    });

    group('initialize', () {
      test('invokes initialize on platform channel', () async {
        await service.initialize();

        final initCall = methodCalls.firstWhere(
          (call) => call.method == AudiflowAiChannel.initialize,
        );
        expect(initCall, isNotNull);
      });

      test('forwards system instructions to platform channel', () async {
        const instructions = 'Custom AI instructions';
        await service.initialize(systemInstructions: instructions);

        final initCall = methodCalls.firstWhere(
          (call) => call.method == AudiflowAiChannel.initialize,
        );
        expect(initCall.arguments, containsPair('instructions', instructions));
      });

      test('uses default instructions when none provided', () async {
        await service.initialize();

        final initCall = methodCalls.firstWhere(
          (call) => call.method == AudiflowAiChannel.initialize,
        );
        // Should have some default instructions
        expect(initCall.arguments, isA<Map<Object?, Object?>>());
        expect(
          (initCall.arguments as Map<Object?, Object?>).containsKey(
            'instructions',
          ),
          isTrue,
        );
      });

      test('sets isInitialized to true on success', () async {
        await service.initialize();
        expect(service.isInitialized, isTrue);
      });

      test(
        'throws AiNotAvailableException when platform unavailable',
        () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                const MethodChannel(AudiflowAiChannel.name),
                (call) async {
                  if (call.method == AudiflowAiChannel.initialize) {
                    throw PlatformException(code: 'AI_NOT_AVAILABLE');
                  }
                  return _handleMethodCall(call);
                },
              );

          expect(
            () => service.initialize(),
            throwsA(isA<AiNotAvailableException>()),
          );
        },
      );

      test(
        'throws AiCoreRequiredException when AICore not installed',
        () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                const MethodChannel(AudiflowAiChannel.name),
                (call) async {
                  if (call.method == AudiflowAiChannel.initialize) {
                    throw PlatformException(code: 'AICORE_REQUIRED');
                  }
                  return _handleMethodCall(call);
                },
              );

          expect(
            () => service.initialize(),
            throwsA(isA<AiCoreRequiredException>()),
          );
        },
      );
    });

    group('generateText', () {
      setUp(() async {
        await service.initialize();
        methodCalls.clear();
      });

      test('invokes generateText on platform channel', () async {
        await service.generateText(prompt: 'Test prompt');

        expect(methodCalls, hasLength(1));
        expect(
          methodCalls.first.method,
          equals(AudiflowAiChannel.generateText),
        );
      });

      test('forwards prompt to platform channel', () async {
        const prompt = 'Generate some text';
        await service.generateText(prompt: prompt);

        expect(methodCalls.first.arguments, containsPair('prompt', prompt));
      });

      test('forwards config to platform channel when provided', () async {
        const config = GenerationConfig(
          temperature: 0.5,
          maxOutputTokens: 100,
        );
        await service.generateText(prompt: 'Test', config: config);

        expect(
          methodCalls.first.arguments,
          containsPair('config', config.toMap()),
        );
      });

      test('returns AiResponse with generated text', () async {
        final response = await service.generateText(prompt: 'Test prompt');

        expect(response, isA<AiResponse>());
        expect(response.text, isNotEmpty);
      });

      test('includes token count in response when available', () async {
        final response = await service.generateText(prompt: 'Test prompt');
        expect(response.tokenCount, isNotNull);
      });

      test('includes duration in response when available', () async {
        final response = await service.generateText(prompt: 'Test prompt');
        expect(response.durationMs, isNotNull);
      });

      test('throws AiNotInitializedException when not initialized', () async {
        final uninitializedService = TextGenerationService();

        expect(
          () => uninitializedService.generateText(prompt: 'Test'),
          throwsA(isA<AiNotInitializedException>()),
        );
      });

      test('throws PromptTooLongException for oversized prompts', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel(AudiflowAiChannel.name),
              (call) async {
                if (call.method == AudiflowAiChannel.generateText) {
                  throw PlatformException(
                    code: 'PROMPT_TOO_LONG',
                    details: '4000',
                  );
                }
                return _handleMethodCall(call);
              },
            );

        expect(
          () => service.generateText(prompt: 'Very long prompt...'),
          throwsA(isA<PromptTooLongException>()),
        );
      });

      test('throws AiGenerationException on platform error', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel(AudiflowAiChannel.name),
              (call) async {
                if (call.method == AudiflowAiChannel.generateText) {
                  throw PlatformException(
                    code: 'GENERATION_FAILED',
                    message: 'Error',
                  );
                }
                return _handleMethodCall(call);
              },
            );

        expect(
          () => service.generateText(prompt: 'Test'),
          throwsA(isA<AiGenerationException>()),
        );
      });
    });

    group('generateTextSimple', () {
      setUp(() async {
        await service.initialize();
        methodCalls.clear();
      });

      test('returns generated text string directly', () async {
        final result = await service.generateTextSimple(prompt: 'Test');
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });

      test('uses default max tokens when not specified', () async {
        await service.generateTextSimple(prompt: 'Test');

        final args = methodCalls.first.arguments as Map;
        final config = args['config'] as Map?;
        expect(config?['maxOutputTokens'], equals(500));
      });

      test('uses custom max tokens when specified', () async {
        await service.generateTextSimple(prompt: 'Test', maxTokens: 200);

        final args = methodCalls.first.arguments as Map;
        final config = args['config'] as Map?;
        expect(config?['maxOutputTokens'], equals(200));
      });
    });

    group('dispose', () {
      test('invokes dispose on platform channel', () async {
        await service.initialize();
        methodCalls.clear();

        await service.dispose();

        expect(methodCalls, hasLength(1));
        expect(methodCalls.first.method, equals(AudiflowAiChannel.dispose));
      });

      test('sets isInitialized to false', () async {
        await service.initialize();
        expect(service.isInitialized, isTrue);

        await service.dispose();
        expect(service.isInitialized, isFalse);
      });
    });
  });
}

/// Mock handler for platform channel calls.
Map<String, dynamic>? _handleMethodCall(MethodCall call) {
  return switch (call.method) {
    AudiflowAiChannel.checkCapability => {
      AudiflowAiChannel.kStatus: AudiflowAiChannel.kStatusFull,
    },
    AudiflowAiChannel.initialize => {
      AudiflowAiChannel.kSuccess: true,
    },
    AudiflowAiChannel.generateText => {
      AudiflowAiChannel.kText: 'Generated response text',
      AudiflowAiChannel.kTokenCount: 42,
      AudiflowAiChannel.kDurationMs: 150,
    },
    AudiflowAiChannel.dispose => {
      AudiflowAiChannel.kSuccess: true,
    },
    _ => null,
  };
}
