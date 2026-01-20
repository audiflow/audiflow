// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  TextGenerationService,
  SummarizationService,
  VoiceCommandService,
])
import 'audiflow_ai_impl_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudiflowAiImpl facade', () {
    late MockTextGenerationService mockTextGenService;
    late MockSummarizationService mockSummarizationService;
    late MockVoiceCommandService mockVoiceCommandService;
    late List<MethodCall> methodCalls;

    void setUpPlatformChannel(AiCapability capability) {
      methodCalls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(AudiflowAiChannel.name),
            (call) async {
              methodCalls.add(call);
              switch (call.method) {
                case AudiflowAiChannel.checkCapability:
                  return <String, dynamic>{
                    AudiflowAiChannel.kStatus: capability.name,
                  };
                case AudiflowAiChannel.initialize:
                  return <String, dynamic>{AudiflowAiChannel.kSuccess: true};
                case AudiflowAiChannel.generateText:
                  return <String, dynamic>{
                    AudiflowAiChannel.kText: 'Generated text',
                    AudiflowAiChannel.kTokenCount: 10,
                    AudiflowAiChannel.kDurationMs: 100,
                  };
                case AudiflowAiChannel.dispose:
                  return <String, dynamic>{AudiflowAiChannel.kSuccess: true};
                case AudiflowAiChannel.promptAiCoreInstall:
                  return true;
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
      mockTextGenService = MockTextGenerationService();
      mockSummarizationService = MockSummarizationService();
      mockVoiceCommandService = MockVoiceCommandService();
      AudiflowAi.resetInstance();
    });

    tearDown(() {
      clearPlatformChannel();
      AudiflowAi.resetInstance();
    });

    group('service delegation', () {
      late AudiflowAiImpl ai;

      setUp(() {
        setUpPlatformChannel(AiCapability.full);

        // Set up mock services
        when(mockTextGenService.isInitialized).thenReturn(true);
        when(
          mockTextGenService.initialize(
            systemInstructions: anyNamed('systemInstructions'),
          ),
        ).thenAnswer((_) async {});
        when(
          mockTextGenService.generateText(
            prompt: anyNamed('prompt'),
            config: anyNamed('config'),
          ),
        ).thenAnswer(
          (_) async => const AiResponse(
            text: 'Generated text',
            tokenCount: 10,
            durationMs: 100,
          ),
        );
        when(mockTextGenService.dispose()).thenAnswer((_) async {});

        when(
          mockSummarizationService.summarize(
            text: anyNamed('text'),
            config: anyNamed('config'),
            onProgress: anyNamed('onProgress'),
          ),
        ).thenAnswer((_) async => 'Summarized text');

        when(
          mockSummarizationService.summarizeEpisode(
            title: anyNamed('title'),
            description: anyNamed('description'),
            transcript: anyNamed('transcript'),
            config: anyNamed('config'),
            onProgress: anyNamed('onProgress'),
          ),
        ).thenAnswer(
          (_) async => const EpisodeSummary(
            summary: 'Episode summary',
            keyTopics: ['Topic 1', 'Topic 2'],
            estimatedListeningMinutes: 30,
          ),
        );

        when(mockVoiceCommandService.parseCommand(any)).thenAnswer(
          (_) async => const VoiceCommand(
            intent: VoiceIntent.play,
            parameters: {},
            confidence: 0.9,
            rawTranscription: 'play podcast',
          ),
        );

        ai = AudiflowAiImpl.withServices(
          textGenerationService: mockTextGenService,
          summarizationService: mockSummarizationService,
          voiceCommandService: mockVoiceCommandService,
        );
      });

      test('delegates generateText to TextGenerationService', () async {
        await ai.initialize();

        await ai.generateText(prompt: 'test prompt');

        verify(
          mockTextGenService.generateText(
            prompt: 'test prompt',
            config: anyNamed('config'),
          ),
        ).called(1);
      });

      test('delegates summarize to SummarizationService', () async {
        await ai.initialize();

        await ai.summarize(
          text: 'text to summarize',
          config: const SummarizationConfig(),
        );

        verify(
          mockSummarizationService.summarize(
            text: 'text to summarize',
            config: anyNamed('config'),
            onProgress: anyNamed('onProgress'),
          ),
        ).called(1);
      });

      test('delegates summarizeEpisode to SummarizationService', () async {
        await ai.initialize();

        await ai.summarizeEpisode(
          title: 'Episode Title',
          description: 'Episode description',
        );

        verify(
          mockSummarizationService.summarizeEpisode(
            title: 'Episode Title',
            description: 'Episode description',
            transcript: anyNamed('transcript'),
            config: anyNamed('config'),
            onProgress: anyNamed('onProgress'),
          ),
        ).called(1);
      });

      test('delegates parseVoiceCommand to VoiceCommandService', () async {
        await ai.initialize();

        await ai.parseVoiceCommand(transcription: 'play podcast');

        verify(mockVoiceCommandService.parseCommand('play podcast')).called(1);
      });

      test('forwards progress callback to SummarizationService', () async {
        await ai.initialize();

        void progressCallback(double progress) {}

        await ai.summarize(
          text: 'text',
          onProgress: progressCallback,
        );

        verify(
          mockSummarizationService.summarize(
            text: 'text',
            config: anyNamed('config'),
            onProgress: progressCallback,
          ),
        ).called(1);
      });
    });

    group('initialization state tracking', () {
      setUp(() {
        setUpPlatformChannel(AiCapability.full);
      });

      test('isInitialized returns false before initialization', () {
        final ai = AudiflowAiImpl();
        expect(ai.isInitialized, isFalse);
      });

      test(
        'isInitialized returns true after successful initialization',
        () async {
          final ai = AudiflowAiImpl();
          await ai.initialize();
          expect(ai.isInitialized, isTrue);
        },
      );

      test('isInitialized returns false after dispose', () async {
        final ai = AudiflowAiImpl();
        await ai.initialize();
        await ai.dispose();
        expect(ai.isInitialized, isFalse);
      });

      test('reinitialize resets and reinitializes', () async {
        final ai = AudiflowAiImpl();
        await ai.initialize(systemInstructions: 'first');
        expect(ai.isInitialized, isTrue);

        await ai.reinitialize(systemInstructions: 'second');
        expect(ai.isInitialized, isTrue);
      });
    });

    group('AiNotInitializedException enforcement', () {
      setUp(() {
        setUpPlatformChannel(AiCapability.full);
      });

      test(
        'generateText throws AiNotInitializedException when not initialized',
        () {
          final ai = AudiflowAiImpl();
          expect(
            () => ai.generateText(prompt: 'test'),
            throwsA(isA<AiNotInitializedException>()),
          );
        },
      );

      test(
        'summarize throws AiNotInitializedException when not initialized',
        () {
          final ai = AudiflowAiImpl();
          expect(
            () => ai.summarize(text: 'test'),
            throwsA(isA<AiNotInitializedException>()),
          );
        },
      );

      test(
        'summarizeEpisode throws AiNotInitializedException '
        'when not initialized',
        () {
          final ai = AudiflowAiImpl();
          expect(
            () => ai.summarizeEpisode(title: 'Title', description: 'Desc'),
            throwsA(isA<AiNotInitializedException>()),
          );
        },
      );

      test(
        'parseVoiceCommand throws AiNotInitializedException '
        'when not initialized',
        () {
          final ai = AudiflowAiImpl();
          expect(
            () => ai.parseVoiceCommand(transcription: 'play'),
            throwsA(isA<AiNotInitializedException>()),
          );
        },
      );
    });

    group('checkCapability through platform channel', () {
      test('returns full when platform reports full', () async {
        setUpPlatformChannel(AiCapability.full);
        final ai = AudiflowAiImpl();

        final capability = await ai.checkCapability();

        expect(capability, equals(AiCapability.full));
      });

      test('returns limited when platform reports limited', () async {
        setUpPlatformChannel(AiCapability.limited);
        final ai = AudiflowAiImpl();

        final capability = await ai.checkCapability();

        expect(capability, equals(AiCapability.limited));
      });

      test('returns needsSetup when platform reports needsSetup', () async {
        setUpPlatformChannel(AiCapability.needsSetup);
        final ai = AudiflowAiImpl();

        final capability = await ai.checkCapability();

        expect(capability, equals(AiCapability.needsSetup));
      });

      test('returns unavailable when platform reports unavailable', () async {
        setUpPlatformChannel(AiCapability.unavailable);
        final ai = AudiflowAiImpl();

        final capability = await ai.checkCapability();

        expect(capability, equals(AiCapability.unavailable));
      });
    });

    group('promptAiCoreInstall', () {
      test('invokes platform channel method', () async {
        setUpPlatformChannel(AiCapability.needsSetup);
        final ai = AudiflowAiImpl();

        final result = await ai.promptAiCoreInstall();

        expect(result, isTrue);
        expect(
          methodCalls.any(
            (c) => c.method == AudiflowAiChannel.promptAiCoreInstall,
          ),
          isTrue,
        );
      });

      test('returns false when platform returns false', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel(AudiflowAiChannel.name),
              (call) async {
                if (call.method == AudiflowAiChannel.promptAiCoreInstall) {
                  return false;
                }
                return null;
              },
            );

        final ai = AudiflowAiImpl();
        final result = await ai.promptAiCoreInstall();

        expect(result, isFalse);
      });
    });

    group('initialization with capability checks', () {
      test(
        'throws AiNotAvailableException when capability is unavailable',
        () async {
          setUpPlatformChannel(AiCapability.unavailable);
          final ai = AudiflowAiImpl();

          expect(
            ai.initialize,
            throwsA(isA<AiNotAvailableException>()),
          );
        },
      );

      test(
        'throws AiCoreRequiredException when capability is needsSetup',
        () async {
          setUpPlatformChannel(AiCapability.needsSetup);
          final ai = AudiflowAiImpl();

          expect(
            ai.initialize,
            throwsA(isA<AiCoreRequiredException>()),
          );
        },
      );
    });
  });

  group('Resource management (Task 7.2)', () {
    late List<MethodCall> methodCalls;

    void setUpPlatformChannel() {
      methodCalls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(AudiflowAiChannel.name),
            (call) async {
              methodCalls.add(call);
              switch (call.method) {
                case AudiflowAiChannel.checkCapability:
                  return <String, dynamic>{
                    AudiflowAiChannel.kStatus: AiCapability.full.name,
                  };
                case AudiflowAiChannel.initialize:
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

    setUp(() {
      setUpPlatformChannel();
      AudiflowAi.resetInstance();
    });

    tearDown(() {
      clearPlatformChannel();
      AudiflowAi.resetInstance();
    });

    group('dispose', () {
      test('invokes platform channel dispose', () async {
        final ai = AudiflowAiImpl();
        await ai.initialize();

        await ai.dispose();

        expect(
          methodCalls.any((c) => c.method == AudiflowAiChannel.dispose),
          isTrue,
        );
      });

      test('resets initialization state', () async {
        final ai = AudiflowAiImpl();
        await ai.initialize();
        expect(ai.isInitialized, isTrue);

        await ai.dispose();

        expect(ai.isInitialized, isFalse);
      });

      test('forwards dispose to services', () async {
        final mockTextGenService = MockTextGenerationService();
        final mockSummarizationService = MockSummarizationService();
        final mockVoiceCommandService = MockVoiceCommandService();

        when(mockTextGenService.isInitialized).thenReturn(true);
        when(
          mockTextGenService.initialize(
            systemInstructions: anyNamed('systemInstructions'),
          ),
        ).thenAnswer((_) async {});
        when(mockTextGenService.dispose()).thenAnswer((_) async {});

        final ai = AudiflowAiImpl.withServices(
          textGenerationService: mockTextGenService,
          summarizationService: mockSummarizationService,
          voiceCommandService: mockVoiceCommandService,
        );

        await ai.initialize();
        await ai.dispose();

        verify(mockTextGenService.dispose()).called(1);
      });

      test('dispose can be called multiple times without error', () async {
        final ai = AudiflowAiImpl();
        await ai.initialize();

        await ai.dispose();
        await ai.dispose(); // Should not throw

        expect(ai.isInitialized, isFalse);
      });

      test('dispose works even when not initialized', () async {
        final ai = AudiflowAiImpl();

        await expectLater(ai.dispose(), completes);
      });
    });

    group('CancellationToken', () {
      test('CancellationToken can be created', () {
        final token = CancellationToken();
        expect(token.isCancelled, isFalse);
      });

      test('CancellationToken can be cancelled', () {
        final token = CancellationToken();
        token.cancel();
        expect(token.isCancelled, isTrue);
      });

      test('CancellationToken notifies listeners on cancel', () {
        final token = CancellationToken();
        var notified = false;
        token.addListener(() => notified = true);

        token.cancel();

        expect(notified, isTrue);
      });

      test('CancellationToken does not notify after removal', () {
        final token = CancellationToken();
        var notified = false;
        void listener() => notified = true;

        token.addListener(listener);
        token.removeListener(listener);
        token.cancel();

        expect(notified, isFalse);
      });

      test('CancellationToken.none is never cancelled', () {
        expect(CancellationToken.none.isCancelled, isFalse);
      });
    });

    group('response metadata with resource usage', () {
      test('AiResponse can include resource usage in metadata', () {
        const response = AiResponse(
          text: 'Generated text',
          tokenCount: 100,
          durationMs: 500,
          metadata: {
            'memoryUsedBytes': 1024000,
            'processingTimeMs': 450,
          },
        );

        expect(response.metadata, isNotNull);
        expect(response.metadata!['memoryUsedBytes'], equals(1024000));
        expect(response.metadata!['processingTimeMs'], equals(450));
      });
    });
  });
}
