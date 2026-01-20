// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

/// Integration tests for voice command parsing (Task 8.4).
///
/// Verifies end-to-end voice command parsing across:
/// - Playback commands (play, pause, stop, skip)
/// - Search commands with extracted terms
/// - Navigation commands (library, queue, settings)
/// - Queue management commands
/// - Unknown intent handling
/// - Confidence scores
library;

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Voice Command Parsing Integration Tests (Task 8.4)', () {
    late List<MethodCall> methodCalls;

    /// Sets up a mock platform channel that simulates voice command parsing.
    void setUpPlatformChannel({
      String Function(String transcription)? responseGenerator,
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
                  final prompt = call.arguments['prompt'] as String;
                  // Extract the transcription from the prompt for response
                  // generation
                  final generatedText =
                      responseGenerator?.call(prompt) ??
                      'intent: unknown\n'
                          'parameters: {}\n'
                          'confidence: 0.5';
                  return <String, dynamic>{
                    AudiflowAiChannel.kText: generatedText,
                    AudiflowAiChannel.kTokenCount: 20,
                    AudiflowAiChannel.kDurationMs: 100,
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

    group('Playback commands', () {
      test(
        'parses play command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: play\n'
                'parameters: {}\n'
                'confidence: 0.95',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'play the podcast',
          );

          expect(command.intent, equals(VoiceIntent.play));
          expect(command.confidence, closeTo(0.95, 0.01));
          expect(command.rawTranscription, equals('play the podcast'));
        },
      );

      test(
        'parses pause command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: pause\n'
                'parameters: {}\n'
                'confidence: 0.92',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'pause playback',
          );

          expect(command.intent, equals(VoiceIntent.pause));
        },
      );

      test(
        'parses stop command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: stop\n'
                'parameters: {}\n'
                'confidence: 0.88',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'stop the episode',
          );

          expect(command.intent, equals(VoiceIntent.stop));
        },
      );

      test(
        'parses skip forward command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: skipforward\n'
                'parameters: {seconds: 30}\n'
                'confidence: 0.85',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'skip forward 30 seconds',
          );

          expect(command.intent, equals(VoiceIntent.skipForward));
          expect(command.parameters['seconds'], equals('30'));
        },
      );

      test(
        'parses skip backward command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: skipbackward\n'
                'parameters: {seconds: 15}\n'
                'confidence: 0.87',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'go back 15 seconds',
          );

          expect(command.intent, equals(VoiceIntent.skipBackward));
        },
      );

      test(
        'parses seek command with time parameter',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: seek\n'
                'parameters: {time: 5:30}\n'
                'confidence: 0.82',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'jump to 5 minutes 30 seconds',
          );

          expect(command.intent, equals(VoiceIntent.seek));
          expect(command.parameters['time'], equals('5:30'));
        },
      );
    });

    group('Search commands', () {
      test(
        'parses search command with podcast name',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: search\n'
                'parameters: {query: The Daily}\n'
                'confidence: 0.9',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'search for The Daily podcast',
          );

          expect(command.intent, equals(VoiceIntent.search));
          expect(command.parameters['query'], equals('The Daily'));
        },
      );

      test(
        'parses search command with topic',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: search\n'
                'parameters: {query: technology news}\n'
                'confidence: 0.85',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'find podcasts about technology news',
          );

          expect(command.intent, equals(VoiceIntent.search));
          expect(command.parameters['query'], contains('technology'));
        },
      );

      test(
        'parses find command as search intent',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: search\n'
                'parameters: {query: comedy shows}\n'
                'confidence: 0.88',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'find comedy shows',
          );

          expect(command.intent, equals(VoiceIntent.search));
        },
      );

      test(
        'parses lookup command as search intent',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: search\n'
                'parameters: {query: Joe Rogan}\n'
                'confidence: 0.9',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'look up Joe Rogan',
          );

          expect(command.intent, equals(VoiceIntent.search));
        },
      );
    });

    group('Navigation commands', () {
      test(
        'parses go to library command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: gotolibrary\n'
                'parameters: {}\n'
                'confidence: 0.93',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'go to my library',
          );

          expect(command.intent, equals(VoiceIntent.goToLibrary));
        },
      );

      test(
        'parses show library command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: library\n'
                'parameters: {}\n'
                'confidence: 0.91',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'show library',
          );

          expect(command.intent, equals(VoiceIntent.goToLibrary));
        },
      );

      test(
        'parses go to queue command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: gotoqueue\n'
                'parameters: {}\n'
                'confidence: 0.92',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'show me the queue',
          );

          expect(command.intent, equals(VoiceIntent.goToQueue));
        },
      );

      test(
        'parses open settings command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: opensettings\n'
                'parameters: {}\n'
                'confidence: 0.89',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'open settings',
          );

          expect(command.intent, equals(VoiceIntent.openSettings));
        },
      );
    });

    group('Queue management commands', () {
      test(
        'parses add to queue command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: addtoqueue\n'
                'parameters: {episode: this episode}\n'
                'confidence: 0.87',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'add this episode to queue',
          );

          expect(command.intent, equals(VoiceIntent.addToQueue));
        },
      );

      test(
        'parses remove from queue command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: removefromqueue\n'
                'parameters: {}\n'
                'confidence: 0.84',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'remove this from queue',
          );

          expect(command.intent, equals(VoiceIntent.removeFromQueue));
        },
      );

      test(
        'parses clear queue command',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: clearqueue\n'
                'parameters: {}\n'
                'confidence: 0.91',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'clear the queue',
          );

          expect(command.intent, equals(VoiceIntent.clearQueue));
        },
      );

      test(
        'parses empty queue command as clear queue',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: emptyqueue\n'
                'parameters: {}\n'
                'confidence: 0.88',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'empty my queue',
          );

          expect(command.intent, equals(VoiceIntent.clearQueue));
        },
      );
    });

    group('Unknown intent handling', () {
      test(
        'returns unknown for unrecognized commands',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: unknown\n'
                'parameters: {}\n'
                'confidence: 0.2',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'what is the meaning of life',
          );

          expect(command.intent, equals(VoiceIntent.unknown));
        },
      );

      test(
        'returns unknown for gibberish input',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: unknown\n'
                'parameters: {}\n'
                'confidence: 0.1',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'asdfghjkl qwerty',
          );

          expect(command.intent, equals(VoiceIntent.unknown));
          expect(0.3 > command.confidence, isTrue);
        },
      );

      test(
        'preserves raw transcription for unknown commands',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: unknown\n'
                'parameters: {}\n'
                'confidence: 0.15',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          const transcription = 'random words that make no sense';
          final command = await ai.parseVoiceCommand(
            transcription: transcription,
          );

          expect(command.rawTranscription, equals(transcription));
        },
      );

      test(
        'handles empty transcription',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(transcription: '');

          expect(command.intent, equals(VoiceIntent.unknown));
          expect(command.confidence, equals(0.0));
        },
      );

      test(
        'returns unknown when AI response is unparseable',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) => 'This is not a valid response format.',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'some command',
          );

          expect(command.intent, equals(VoiceIntent.unknown));
        },
      );
    });

    group('Confidence scores', () {
      test(
        'returns high confidence for clear commands',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: play\n'
                'parameters: {}\n'
                'confidence: 0.98',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(transcription: 'play');

          expect(0.9 < command.confidence, isTrue);
        },
      );

      test(
        'returns moderate confidence for ambiguous commands',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: search\n'
                'parameters: {query: stuff}\n'
                'confidence: 0.65',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'find some stuff',
          );

          expect(0.5 < command.confidence, isTrue);
          expect(0.9 > command.confidence, isTrue);
        },
      );

      test(
        'returns low confidence for unclear commands',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: unknown\n'
                'parameters: {}\n'
                'confidence: 0.25',
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'maybe do something',
          );

          expect(0.5 > command.confidence, isTrue);
        },
      );

      test(
        'confidence is clamped to valid range 0-1',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: play\n'
                'parameters: {}\n'
                'confidence: 1.5', // Invalid value
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(transcription: 'play');

          expect(0.0 <= command.confidence, isTrue);
          expect(command.confidence <= 1.0, isTrue);
        },
      );

      test(
        'handles missing confidence gracefully',
        () async {
          setUpPlatformChannel(
            responseGenerator: (_) =>
                'intent: play\n'
                'parameters: {}',
            // No confidence line
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(transcription: 'play');

          // Should have a default confidence value
          expect(0.0 < command.confidence, isTrue);
        },
      );
    });

    group('Error handling', () {
      test(
        'throws AiNotInitializedException when not initialized',
        () async {
          setUpPlatformChannel();

          final ai = AudiflowAi.instance;
          // Not calling initialize()

          expect(
            () => ai.parseVoiceCommand(transcription: 'play'),
            throwsA(isA<AiNotInitializedException>()),
          );
        },
      );

      test(
        'returns unknown on generation failure',
        () async {
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
                      throw PlatformException(
                        code: 'GENERATION_FAILED',
                        message: 'Model error',
                      );
                    default:
                      return null;
                  }
                },
              );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(transcription: 'play');

          expect(command.intent, equals(VoiceIntent.unknown));
          expect(command.confidence, equals(0.0));
        },
      );
    });

    group('Cross-layer communication', () {
      test(
        'transcription flows through all layers correctly',
        () async {
          setUpPlatformChannel(
            responseGenerator: (prompt) {
              // Verify the transcription is included in the prompt
              expect(prompt, contains('play my favorite podcast'));
              return 'intent: play\nparameters: {}\nconfidence: 0.9';
            },
          );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command = await ai.parseVoiceCommand(
            transcription: 'play my favorite podcast',
          );

          expect(command.intent, equals(VoiceIntent.play));

          // Verify platform channel was invoked
          expect(
            methodCalls.any(
              (c) => c.method == AudiflowAiChannel.generateText,
            ),
            isTrue,
          );
        },
      );

      test(
        'multiple voice commands work sequentially',
        () async {
          var callCount = 0;
          final intents = ['play', 'pause', 'search'];
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
                      final intent = intents[callCount % intents.length];
                      callCount++;
                      return <String, dynamic>{
                        AudiflowAiChannel.kText:
                            'intent: $intent\n'
                            'parameters: {}\n'
                            'confidence: 0.9',
                      };
                    default:
                      return null;
                  }
                },
              );

          final ai = AudiflowAi.instance;
          await ai.initialize();

          final command1 = await ai.parseVoiceCommand(
            transcription: 'first command',
          );
          final command2 = await ai.parseVoiceCommand(
            transcription: 'second command',
          );
          final command3 = await ai.parseVoiceCommand(
            transcription: 'third command',
          );

          expect(command1.intent, equals(VoiceIntent.play));
          expect(command2.intent, equals(VoiceIntent.pause));
          expect(command3.intent, equals(VoiceIntent.search));
        },
      );
    });

    group('VoiceCommand model', () {
      test(
        'VoiceCommand equality works correctly',
        () {
          const command1 = VoiceCommand(
            intent: VoiceIntent.play,
            parameters: {},
            confidence: 0.9,
            rawTranscription: 'play',
          );
          const command2 = VoiceCommand(
            intent: VoiceIntent.play,
            parameters: {},
            confidence: 0.9,
            rawTranscription: 'play',
          );
          const command3 = VoiceCommand(
            intent: VoiceIntent.pause,
            parameters: {},
            confidence: 0.9,
            rawTranscription: 'pause',
          );

          expect(command1, equals(command2));
          expect(command1, isNot(equals(command3)));
        },
      );

      test(
        'VoiceCommand toString includes intent and confidence',
        () {
          const command = VoiceCommand(
            intent: VoiceIntent.search,
            parameters: {'query': 'test'},
            confidence: 0.85,
            rawTranscription: 'search test',
          );

          final str = command.toString();
          expect(str, contains('search'));
          expect(str, contains('0.85'));
        },
      );

      test(
        'VoiceIntent enum has all expected values',
        () {
          expect(VoiceIntent.values, contains(VoiceIntent.play));
          expect(VoiceIntent.values, contains(VoiceIntent.pause));
          expect(VoiceIntent.values, contains(VoiceIntent.stop));
          expect(VoiceIntent.values, contains(VoiceIntent.skipForward));
          expect(VoiceIntent.values, contains(VoiceIntent.skipBackward));
          expect(VoiceIntent.values, contains(VoiceIntent.seek));
          expect(VoiceIntent.values, contains(VoiceIntent.search));
          expect(VoiceIntent.values, contains(VoiceIntent.goToLibrary));
          expect(VoiceIntent.values, contains(VoiceIntent.goToQueue));
          expect(VoiceIntent.values, contains(VoiceIntent.openSettings));
          expect(VoiceIntent.values, contains(VoiceIntent.addToQueue));
          expect(VoiceIntent.values, contains(VoiceIntent.removeFromQueue));
          expect(VoiceIntent.values, contains(VoiceIntent.clearQueue));
          expect(VoiceIntent.values, contains(VoiceIntent.unknown));
        },
      );
    });
  });
}
