// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudiflowAi', () {
    setUp(AudiflowAi.resetInstance);

    test('instance returns singleton', () {
      final instance1 = AudiflowAi.instance;
      final instance2 = AudiflowAi.instance;

      expect(identical(instance1, instance2), isTrue);
    });

    test('setInstance allows test injection', () {
      final mock = _MockAudiflowAi();
      AudiflowAi.setInstance(mock);

      expect(AudiflowAi.instance, same(mock));
    });

    test('resetInstance clears singleton', () {
      final originalInstance = AudiflowAi.instance;
      AudiflowAi.resetInstance();
      final newInstance = AudiflowAi.instance;

      expect(identical(originalInstance, newInstance), isFalse);
    });

    test('isInitialized returns false before initialization', () {
      expect(AudiflowAi.instance.isInitialized, isFalse);
    });
  });

  group('AudiflowAiImpl stub behavior', () {
    late AudiflowAi ai;

    setUp(() {
      AudiflowAi.resetInstance();
      ai = AudiflowAi.instance;
    });

    test('checkCapability returns unavailable in test environment', () async {
      final capability = await ai.checkCapability();
      expect(capability, equals(AiCapability.unavailable));
    });

    test(
      'initialize throws AiNotAvailableException in test environment',
      () {
        expect(
          ai.initialize,
          throwsA(isA<AiNotAvailableException>()),
        );
      },
    );

    test(
      'generateText throws AiNotInitializedException when not initialized',
      () {
        expect(
          () => ai.generateText(prompt: 'test'),
          throwsA(isA<AiNotInitializedException>()),
        );
      },
    );

    test(
      'summarize throws AiNotInitializedException when not initialized',
      () {
        expect(
          () => ai.summarize(text: 'test'),
          throwsA(isA<AiNotInitializedException>()),
        );
      },
    );

    test(
      'summarizeEpisode throws AiNotInitializedException when not initialized',
      () {
        expect(
          () => ai.summarizeEpisode(title: 'Test', description: 'Test desc'),
          throwsA(isA<AiNotInitializedException>()),
        );
      },
    );

    test(
      'parseVoiceCommand throws AiNotInitializedException when not initialized',
      () {
        expect(
          () => ai.parseVoiceCommand(transcription: 'play podcast'),
          throwsA(isA<AiNotInitializedException>()),
        );
      },
    );

    test(
      'promptAiCoreInstall returns false on non-Android platforms',
      () async {
        final result = await ai.promptAiCoreInstall();
        expect(result, isFalse);
      },
    );

    test('dispose completes without error', () async {
      await expectLater(ai.dispose(), completes);
    });
  });

  group('Platform channel constants', () {
    test('channel name is correct', () {
      expect(AudiflowAiChannel.name, equals('com.audiflow/ai'));
    });

    test('method names are defined', () {
      expect(AudiflowAiChannel.checkCapability, equals('checkCapability'));
      expect(AudiflowAiChannel.initialize, equals('initialize'));
      expect(AudiflowAiChannel.generateText, equals('generateText'));
      expect(AudiflowAiChannel.dispose, equals('dispose'));
      expect(
        AudiflowAiChannel.promptAiCoreInstall,
        equals('promptAiCoreInstall'),
      );
    });

    test('response keys are defined', () {
      expect(AudiflowAiChannel.kStatus, equals('status'));
      expect(AudiflowAiChannel.kText, equals('text'));
      expect(AudiflowAiChannel.kTokenCount, equals('tokenCount'));
      expect(AudiflowAiChannel.kSuccess, equals('success'));
      expect(AudiflowAiChannel.kErrorCode, equals('errorCode'));
      expect(AudiflowAiChannel.kErrorMessage, equals('errorMessage'));
    });

    test('capability status values are defined', () {
      expect(AudiflowAiChannel.kStatusFull, equals('full'));
      expect(AudiflowAiChannel.kStatusLimited, equals('limited'));
      expect(AudiflowAiChannel.kStatusUnavailable, equals('unavailable'));
      expect(AudiflowAiChannel.kStatusNeedsSetup, equals('needsSetup'));
    });
  });
}

/// Mock implementation for testing singleton injection.
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
  }) async => const AiResponse(text: 'mock');

  @override
  Future<String> summarize({
    required String text,
    SummarizationConfig? config,
    AiProgressCallback? onProgress,
  }) async => 'mock summary';

  @override
  Future<EpisodeSummary> summarizeEpisode({
    required String title,
    required String description,
    String? transcript,
    SummarizationConfig? config,
    AiProgressCallback? onProgress,
  }) async => const EpisodeSummary(summary: 'mock', keyTopics: []);

  @override
  Future<VoiceCommand> parseVoiceCommand({
    required String transcription,
  }) async => VoiceCommand(
    intent: VoiceIntent.unknown,
    parameters: const {},
    confidence: 0,
    rawTranscription: transcription,
  );

  @override
  Future<Map<String, dynamic>?> resolveSettingsIntent({
    required String transcription,
    required String settingsSchemaJson,
  }) async => null;

  @override
  Future<bool> promptAiCoreInstall() async => true;

  @override
  Future<void> dispose() async {}
}
