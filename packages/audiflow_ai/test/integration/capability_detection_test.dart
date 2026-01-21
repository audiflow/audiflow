// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

/// Integration tests for capability detection (Task 8.1).
///
/// Verifies end-to-end capability detection across:
/// - Supported Android devices with AICore installed
/// - Supported iOS devices
/// - needsSetup detection when AICore not installed
/// - Unavailable detection on unsupported devices
/// - Singleton consistency
library;

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Capability Detection Integration Tests (Task 8.1)', () {
    late List<MethodCall> methodCalls;

    /// Sets up a mock platform channel that simulates a specific platform
    /// and capability state.
    void setUpPlatformChannel({
      required String status,
      bool aiCoreInstalled = true,
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
                  // Simulate platform-specific response
                  if (isAndroid && !aiCoreInstalled) {
                    return <String, dynamic>{
                      AudiflowAiChannel.kStatus:
                          AudiflowAiChannel.kStatusNeedsSetup,
                    };
                  }
                  return <String, dynamic>{AudiflowAiChannel.kStatus: status};
                case AudiflowAiChannel.initialize:
                  if (status == AudiflowAiChannel.kStatusUnavailable) {
                    throw PlatformException(
                      code: 'AI_NOT_AVAILABLE',
                      message: 'AI not available on this device',
                    );
                  }
                  if (isAndroid && !aiCoreInstalled) {
                    throw PlatformException(
                      code: 'AICORE_REQUIRED',
                      message: 'AICore installation required',
                    );
                  }
                  return <String, dynamic>{AudiflowAiChannel.kSuccess: true};
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

    setUp(AudiflowAi.resetInstance);

    tearDown(() {
      clearPlatformChannel();
      AudiflowAi.resetInstance();
    });

    group('Android capability detection', () {
      test(
        'returns full capability on supported Android device with AICore',
        () async {
          setUpPlatformChannel(
            status: AudiflowAiChannel.kStatusFull,
          );

          final ai = AudiflowAi.instance;
          final capability = await ai.checkCapability();

          expect(capability, equals(AiCapability.full));
          expect(capability.isUsable, isTrue);
          expect(capability.requiresAction, isFalse);
          expect(
            methodCalls.any(
              (c) => c.method == AudiflowAiChannel.checkCapability,
            ),
            isTrue,
          );
        },
      );

      test(
        'returns needsSetup when AICore not installed on Android',
        () async {
          setUpPlatformChannel(
            status: AudiflowAiChannel.kStatusNeedsSetup,
            aiCoreInstalled: false,
          );

          final ai = AudiflowAi.instance;
          final capability = await ai.checkCapability();

          expect(capability, equals(AiCapability.needsSetup));
          expect(capability.isUsable, isFalse);
          expect(capability.requiresAction, isTrue);
        },
      );

      test(
        'returns limited capability when Android reports limited',
        () async {
          setUpPlatformChannel(
            status: AudiflowAiChannel.kStatusLimited,
          );

          final ai = AudiflowAi.instance;
          final capability = await ai.checkCapability();

          expect(capability, equals(AiCapability.limited));
          expect(capability.isUsable, isTrue);
        },
      );
    });

    group('iOS capability detection', () {
      test(
        'returns full capability on supported iOS device',
        () async {
          setUpPlatformChannel(
            status: AudiflowAiChannel.kStatusFull,
            isAndroid: false,
          );

          final ai = AudiflowAi.instance;
          final capability = await ai.checkCapability();

          expect(capability, equals(AiCapability.full));
          expect(capability.isUsable, isTrue);
          expect(capability.requiresAction, isFalse);
        },
      );

      test(
        'returns unavailable on unsupported iOS device',
        () async {
          setUpPlatformChannel(
            status: AudiflowAiChannel.kStatusUnavailable,
            isAndroid: false,
          );

          final ai = AudiflowAi.instance;
          final capability = await ai.checkCapability();

          expect(capability, equals(AiCapability.unavailable));
          expect(capability.isUsable, isFalse);
          expect(capability.requiresAction, isFalse);
        },
      );
    });

    group('Unsupported device detection', () {
      test(
        'returns unavailable when device does not meet requirements',
        () async {
          setUpPlatformChannel(
            status: AudiflowAiChannel.kStatusUnavailable,
          );

          final ai = AudiflowAi.instance;
          final capability = await ai.checkCapability();

          expect(capability, equals(AiCapability.unavailable));
          expect(capability.isUsable, isFalse);
        },
      );

      test(
        'returns unavailable when platform returns unknown status',
        () async {
          methodCalls = [];
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                const MethodChannel(AudiflowAiChannel.name),
                (call) async {
                  methodCalls.add(call);
                  if (call.method == AudiflowAiChannel.checkCapability) {
                    return <String, dynamic>{
                      AudiflowAiChannel.kStatus: 'unknown_status',
                    };
                  }
                  return null;
                },
              );

          final ai = AudiflowAi.instance;
          final capability = await ai.checkCapability();

          expect(capability, equals(AiCapability.unavailable));
        },
      );

      test(
        'returns unavailable when platform returns null status',
        () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                const MethodChannel(AudiflowAiChannel.name),
                (call) async {
                  if (call.method == AudiflowAiChannel.checkCapability) {
                    return <String, dynamic>{AudiflowAiChannel.kStatus: null};
                  }
                  return null;
                },
              );

          final ai = AudiflowAi.instance;
          final capability = await ai.checkCapability();

          expect(capability, equals(AiCapability.unavailable));
        },
      );
    });

    group('Singleton consistency', () {
      test(
        'singleton instance returns consistent results across calls',
        () async {
          setUpPlatformChannel(
            status: AudiflowAiChannel.kStatusFull,
          );

          final ai1 = AudiflowAi.instance;
          final ai2 = AudiflowAi.instance;

          expect(identical(ai1, ai2), isTrue);

          final capability1 = await ai1.checkCapability();
          final capability2 = await ai2.checkCapability();

          expect(capability1, equals(capability2));
          expect(capability1, equals(AiCapability.full));
        },
      );

      test(
        'resetInstance creates new instance with fresh state',
        () async {
          setUpPlatformChannel(
            status: AudiflowAiChannel.kStatusFull,
          );

          final ai1 = AudiflowAi.instance;
          await ai1.initialize();
          expect(ai1.isInitialized, isTrue);

          AudiflowAi.resetInstance();

          final ai2 = AudiflowAi.instance;
          expect(identical(ai1, ai2), isFalse);
          expect(ai2.isInitialized, isFalse);
        },
      );

      test(
        'testInstance allows injecting mock instance',
        () {
          final mockAi = _MockAudiflowAi();
          AudiflowAi.testInstance = mockAi;

          final ai = AudiflowAi.instance;
          expect(identical(ai, mockAi), isTrue);
        },
      );
    });

    group('Cross-layer capability propagation', () {
      test(
        'capability check propagates through all layers correctly',
        () async {
          setUpPlatformChannel(
            status: AudiflowAiChannel.kStatusFull,
          );

          final ai = AudiflowAi.instance;

          // First check - should invoke platform channel
          final capability1 = await ai.checkCapability();
          expect(capability1, equals(AiCapability.full));
          expect(methodCalls.length, equals(1));

          // Second check - should also invoke platform channel
          // (no caching at this layer)
          final capability2 = await ai.checkCapability();
          expect(capability2, equals(AiCapability.full));
          expect(methodCalls.length, equals(2));
        },
      );

      test(
        'initialize respects capability check result',
        () {
          setUpPlatformChannel(
            status: AudiflowAiChannel.kStatusUnavailable,
          );

          final ai = AudiflowAi.instance;

          expect(
            ai.initialize,
            throwsA(isA<AiNotAvailableException>()),
          );
        },
      );

      test(
        'initialize throws AiCoreRequiredException on needsSetup',
        () {
          setUpPlatformChannel(
            status: AudiflowAiChannel.kStatusNeedsSetup,
            aiCoreInstalled: false,
          );

          final ai = AudiflowAi.instance;

          expect(
            ai.initialize,
            throwsA(isA<AiCoreRequiredException>()),
          );
        },
      );
    });

    group('AiCapability extension methods', () {
      test('full capability has correct extension values', () {
        const capability = AiCapability.full;
        expect(capability.isUsable, isTrue);
        expect(capability.requiresAction, isFalse);
        expect(capability.description, contains('Full'));
      });

      test('limited capability has correct extension values', () {
        const capability = AiCapability.limited;
        expect(capability.isUsable, isTrue);
        expect(capability.requiresAction, isFalse);
        expect(capability.description, contains('Limited'));
      });

      test('unavailable capability has correct extension values', () {
        const capability = AiCapability.unavailable;
        expect(capability.isUsable, isFalse);
        expect(capability.requiresAction, isFalse);
        expect(capability.description, contains('not available'));
      });

      test('needsSetup capability has correct extension values', () {
        const capability = AiCapability.needsSetup;
        expect(capability.isUsable, isFalse);
        expect(capability.requiresAction, isTrue);
        expect(capability.description, contains('setup'));
      });
    });
  });
}

/// Mock implementation of AudiflowAi for testing.
class _MockAudiflowAi implements AudiflowAi {
  @override
  bool get isInitialized => false;

  @override
  Future<AiCapability> checkCapability() async => AiCapability.full;

  @override
  Future<void> initialize({String? systemInstructions}) async {}

  @override
  Future<void> reinitialize({String? systemInstructions}) async {}

  @override
  Future<AiResponse> generateText({
    required String prompt,
    GenerationConfig? config,
  }) async {
    return const AiResponse(text: 'mock');
  }

  @override
  Future<String> summarize({
    required String text,
    SummarizationConfig? config,
    AiProgressCallback? onProgress,
  }) async {
    return 'mock summary';
  }

  @override
  Future<EpisodeSummary> summarizeEpisode({
    required String title,
    required String description,
    String? transcript,
    SummarizationConfig? config,
    AiProgressCallback? onProgress,
  }) async {
    return const EpisodeSummary(summary: 'mock', keyTopics: []);
  }

  @override
  Future<VoiceCommand> parseVoiceCommand({
    required String transcription,
  }) async {
    return const VoiceCommand(
      intent: VoiceIntent.unknown,
      parameters: {},
      confidence: 0,
      rawTranscription: '',
    );
  }

  @override
  Future<bool> promptAiCoreInstall() async => false;

  @override
  Future<void> dispose() async {}
}
