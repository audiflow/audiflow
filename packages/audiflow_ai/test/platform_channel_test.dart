// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Platform channel communication', () {
    late List<MethodCall> log;

    setUp(() {
      log = [];
      AudiflowAi.resetInstance();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(AudiflowAiChannel.name),
            (MethodCall methodCall) async {
              log.add(methodCall);

              switch (methodCall.method) {
                case AudiflowAiChannel.checkCapability:
                  return {
                    AudiflowAiChannel.kStatus: AudiflowAiChannel.kStatusFull,
                  };

                case AudiflowAiChannel.initialize:
                  return {AudiflowAiChannel.kSuccess: true};

                case AudiflowAiChannel.generateText:
                  return {
                    AudiflowAiChannel.kText: 'Generated text response',
                    AudiflowAiChannel.kTokenCount: 10,
                    AudiflowAiChannel.kDurationMs: 500,
                  };

                case AudiflowAiChannel.dispose:
                  return {AudiflowAiChannel.kSuccess: true};

                case AudiflowAiChannel.promptAiCoreInstall:
                  return true;

                default:
                  return null;
              }
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

    test('checkCapability invokes correct method channel call', () async {
      final ai = AudiflowAi.instance;
      final result = await ai.checkCapability();

      expect(log.length, equals(1));
      expect(log.first.method, equals(AudiflowAiChannel.checkCapability));
      expect(result, equals(AiCapability.full));
    });

    test('initialize invokes correct method channel call', () async {
      final ai = AudiflowAi.instance;
      await ai.initialize();

      // checkCapability is called first, then initialize
      expect(log.length, equals(2));
      expect(log[0].method, equals(AudiflowAiChannel.checkCapability));
      expect(log[1].method, equals(AudiflowAiChannel.initialize));
    });

    test('initialize with system instructions passes arguments', () async {
      final ai = AudiflowAi.instance;
      await ai.initialize(systemInstructions: 'Custom instructions');

      expect(log.length, equals(2));
      expect(log[1].method, equals(AudiflowAiChannel.initialize));
      expect(
        log[1].arguments,
        containsPair('instructions', 'Custom instructions'),
      );
    });

    test('generateText invokes correct method channel call', () async {
      final ai = AudiflowAi.instance;
      await ai.initialize();
      log.clear();

      final response = await ai.generateText(prompt: 'Test prompt');

      expect(log.length, equals(1));
      expect(log.first.method, equals(AudiflowAiChannel.generateText));
      expect(log.first.arguments, containsPair('prompt', 'Test prompt'));
      expect(response.text, equals('Generated text response'));
      expect(response.tokenCount, equals(10));
      expect(response.durationMs, equals(500));
    });

    test('generateText with config passes configuration', () async {
      final ai = AudiflowAi.instance;
      await ai.initialize();
      log.clear();

      const config = GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 256,
      );
      await ai.generateText(prompt: 'Test', config: config);

      expect(
        log.first.arguments,
        containsPair('config', {
          'temperature': 0.8,
          'maxOutputTokens': 256,
        }),
      );
    });

    test('dispose invokes correct method channel call', () async {
      final ai = AudiflowAi.instance;
      await ai.initialize();
      log.clear();

      await ai.dispose();

      // Dispose is called twice: once by TextGenerationService and once by
      // AudiflowAiImpl for platform channel cleanup
      expect(log.length, equals(2));
      expect(
        log.every((call) => call.method == AudiflowAiChannel.dispose),
        isTrue,
      );
    });

    test('promptAiCoreInstall invokes correct method channel call', () async {
      final ai = AudiflowAi.instance;
      final result = await ai.promptAiCoreInstall();

      expect(log.length, equals(1));
      expect(log.first.method, equals(AudiflowAiChannel.promptAiCoreInstall));
      expect(result, isTrue);
    });

    test('capability status mapping works correctly', () async {
      final statusMappings = {
        AudiflowAiChannel.kStatusFull: AiCapability.full,
        AudiflowAiChannel.kStatusLimited: AiCapability.limited,
        AudiflowAiChannel.kStatusUnavailable: AiCapability.unavailable,
        AudiflowAiChannel.kStatusNeedsSetup: AiCapability.needsSetup,
        'unknown': AiCapability.unavailable,
        null: AiCapability.unavailable,
      };

      for (final entry in statusMappings.entries) {
        AudiflowAi.resetInstance();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel(AudiflowAiChannel.name),
              (MethodCall methodCall) async {
                if (methodCall.method == AudiflowAiChannel.checkCapability) {
                  return {AudiflowAiChannel.kStatus: entry.key};
                }
                return null;
              },
            );

        final result = await AudiflowAi.instance.checkCapability();
        expect(
          result,
          equals(entry.value),
          reason: 'Status "${entry.key}" should map to ${entry.value}',
        );
      }
    });

    test('error codes propagate correctly from platform', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(AudiflowAiChannel.name),
            (MethodCall methodCall) async {
              if (methodCall.method == AudiflowAiChannel.checkCapability) {
                return {
                  AudiflowAiChannel.kStatus: AudiflowAiChannel.kStatusFull,
                };
              }
              if (methodCall.method == AudiflowAiChannel.initialize) {
                return {AudiflowAiChannel.kSuccess: true};
              }
              if (methodCall.method == AudiflowAiChannel.generateText) {
                throw PlatformException(
                  code: 'PROMPT_TOO_LONG',
                  message: 'Prompt exceeds maximum length',
                  details: '4000',
                );
              }
              return null;
            },
          );

      AudiflowAi.resetInstance();
      final ai = AudiflowAi.instance;
      await ai.initialize();

      expect(
        () => ai.generateText(prompt: 'Too long prompt'),
        throwsA(isA<PromptTooLongException>()),
      );
    });

    test(
      'needsSetup status triggers AiCoreRequiredException on initialize',
      () {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel(AudiflowAiChannel.name),
              (MethodCall methodCall) async {
                if (methodCall.method == AudiflowAiChannel.checkCapability) {
                  return {
                    AudiflowAiChannel.kStatus:
                        AudiflowAiChannel.kStatusNeedsSetup,
                  };
                }
                return null;
              },
            );

        AudiflowAi.resetInstance();
        final ai = AudiflowAi.instance;

        expect(
          ai.initialize,
          throwsA(isA<AiCoreRequiredException>()),
        );
      },
    );
  });
}
