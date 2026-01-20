// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([TextGenerationService])
import 'voice_command_service_test.mocks.dart';

void main() {
  group('VoiceCommandService', () {
    late VoiceCommandService service;
    late MockTextGenerationService mockTextGenService;

    setUp(() {
      mockTextGenService = MockTextGenerationService();
      service = VoiceCommandService(
        textGenerationService: mockTextGenService,
      );
    });

    group('parseCommand', () {
      group('playback intents', () {
        test('recognizes play command', () async {
          _mockResponse(mockTextGenService, '''
intent: play
parameters: {}
confidence: 0.95
''');

          final result = await service.parseCommand('play the podcast');

          expect(result.intent, equals(VoiceIntent.play));
          expect(result.confidence, greaterThan(0.9));
        });

        test('recognizes pause command', () async {
          _mockResponse(mockTextGenService, '''
intent: pause
parameters: {}
confidence: 0.95
''');

          final result = await service.parseCommand('pause');

          expect(result.intent, equals(VoiceIntent.pause));
        });

        test('recognizes stop command', () async {
          _mockResponse(mockTextGenService, '''
intent: stop
parameters: {}
confidence: 0.9
''');

          final result = await service.parseCommand('stop playing');

          expect(result.intent, equals(VoiceIntent.stop));
        });

        test('recognizes skip forward command', () async {
          _mockResponse(mockTextGenService, '''
intent: skipForward
parameters: {seconds: 30}
confidence: 0.85
''');

          final result = await service.parseCommand('skip forward 30 seconds');

          expect(result.intent, equals(VoiceIntent.skipForward));
          expect(result.parameters, containsPair('seconds', '30'));
        });

        test('recognizes skip backward command', () async {
          _mockResponse(mockTextGenService, '''
intent: skipBackward
parameters: {seconds: 15}
confidence: 0.85
''');

          final result = await service.parseCommand('go back 15 seconds');

          expect(result.intent, equals(VoiceIntent.skipBackward));
          expect(result.parameters, containsPair('seconds', '15'));
        });

        test('recognizes seek command', () async {
          _mockResponse(mockTextGenService, '''
intent: seek
parameters: {position: 5:30}
confidence: 0.8
''');

          final result = await service.parseCommand(
            'go to 5 minutes 30 seconds',
          );

          expect(result.intent, equals(VoiceIntent.seek));
        });
      });

      group('search intents', () {
        test('recognizes search command with query', () async {
          _mockResponse(mockTextGenService, '''
intent: search
parameters: {query: technology news}
confidence: 0.9
''');

          final result = await service.parseCommand(
            'search for technology news',
          );

          expect(result.intent, equals(VoiceIntent.search));
          expect(result.parameters, containsPair('query', 'technology news'));
        });

        test('extracts podcast name from search', () async {
          _mockResponse(mockTextGenService, '''
intent: search
parameters: {query: The Daily podcast}
confidence: 0.85
''');

          final result = await service.parseCommand('find The Daily podcast');

          expect(result.intent, equals(VoiceIntent.search));
          expect(result.parameters['query'], contains('Daily'));
        });

        test('extracts topic from search', () async {
          _mockResponse(mockTextGenService, '''
intent: search
parameters: {query: machine learning}
confidence: 0.9
''');

          final result = await service.parseCommand(
            'look for podcasts about machine learning',
          );

          expect(result.intent, equals(VoiceIntent.search));
          expect(result.parameters['query'], contains('machine learning'));
        });
      });

      group('navigation intents', () {
        test('recognizes go to library command', () async {
          _mockResponse(mockTextGenService, '''
intent: goToLibrary
parameters: {}
confidence: 0.95
''');

          final result = await service.parseCommand('go to my library');

          expect(result.intent, equals(VoiceIntent.goToLibrary));
        });

        test('recognizes go to queue command', () async {
          _mockResponse(mockTextGenService, '''
intent: goToQueue
parameters: {}
confidence: 0.95
''');

          final result = await service.parseCommand('show my queue');

          expect(result.intent, equals(VoiceIntent.goToQueue));
        });

        test('recognizes open settings command', () async {
          _mockResponse(mockTextGenService, '''
intent: openSettings
parameters: {}
confidence: 0.9
''');

          final result = await service.parseCommand('open settings');

          expect(result.intent, equals(VoiceIntent.openSettings));
        });
      });

      group('queue management intents', () {
        test('recognizes add to queue command', () async {
          _mockResponse(mockTextGenService, '''
intent: addToQueue
parameters: {item: current episode}
confidence: 0.85
''');

          final result = await service.parseCommand('add this to my queue');

          expect(result.intent, equals(VoiceIntent.addToQueue));
        });

        test('recognizes remove from queue command', () async {
          _mockResponse(mockTextGenService, '''
intent: removeFromQueue
parameters: {}
confidence: 0.85
''');

          final result = await service.parseCommand('remove from queue');

          expect(result.intent, equals(VoiceIntent.removeFromQueue));
        });

        test('recognizes clear queue command', () async {
          _mockResponse(mockTextGenService, '''
intent: clearQueue
parameters: {}
confidence: 0.9
''');

          final result = await service.parseCommand('clear my queue');

          expect(result.intent, equals(VoiceIntent.clearQueue));
        });
      });

      group('unknown intents', () {
        test('returns unknown for unrecognized commands', () async {
          _mockResponse(mockTextGenService, '''
intent: unknown
parameters: {}
confidence: 0.3
''');

          final result = await service.parseCommand('do something weird');

          expect(result.intent, equals(VoiceIntent.unknown));
        });

        test('returns unknown with original transcription', () async {
          _mockResponse(mockTextGenService, '''
intent: unknown
parameters: {}
confidence: 0.2
''');

          const transcription = 'completely random gibberish';
          final result = await service.parseCommand(transcription);

          expect(result.intent, equals(VoiceIntent.unknown));
          expect(result.rawTranscription, equals(transcription));
        });

        test('handles empty transcription', () async {
          _mockResponse(mockTextGenService, '''
intent: unknown
parameters: {}
confidence: 0.0
''');

          final result = await service.parseCommand('');

          expect(result.intent, equals(VoiceIntent.unknown));
          expect(result.confidence, equals(0.0));
        });
      });

      group('confidence scores', () {
        test('returns confidence score between 0 and 1', () async {
          _mockResponse(mockTextGenService, '''
intent: play
parameters: {}
confidence: 0.87
''');

          final result = await service.parseCommand('play');

          expect(result.confidence, greaterThanOrEqualTo(0.0));
          expect(result.confidence, lessThanOrEqualTo(1.0));
        });

        test('clamps confidence to valid range if needed', () async {
          _mockResponse(mockTextGenService, '''
intent: play
parameters: {}
confidence: 1.5
''');

          final result = await service.parseCommand('play');

          expect(result.confidence, lessThanOrEqualTo(1.0));
        });

        test('handles missing confidence gracefully', () async {
          _mockResponse(mockTextGenService, '''
intent: play
parameters: {}
''');

          final result = await service.parseCommand('play');

          // Should have a default confidence
          expect(result.confidence, greaterThanOrEqualTo(0.0));
        });
      });

      group('raw transcription preservation', () {
        test('preserves original transcription in result', () async {
          _mockResponse(mockTextGenService, '''
intent: play
parameters: {}
confidence: 0.9
''');

          const originalText = 'Play the latest episode please';
          final result = await service.parseCommand(originalText);

          expect(result.rawTranscription, equals(originalText));
        });

        test('preserves transcription with special characters', () async {
          _mockResponse(mockTextGenService, '''
intent: search
parameters: {query: test}
confidence: 0.8
''');

          const transcription = "Search for 'The O'Reilly Factor'";
          final result = await service.parseCommand(transcription);

          expect(result.rawTranscription, equals(transcription));
        });
      });

      group('prompt template usage', () {
        test('uses voice command prompt template', () async {
          _mockResponse(mockTextGenService, '''
intent: play
parameters: {}
confidence: 0.9
''');

          await service.parseCommand('play');

          final captured = verify(
            mockTextGenService.generateText(
              prompt: captureAnyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).captured;

          final prompt = captured.first as String;
          // Should contain voice command template elements
          expect(prompt, contains('intent'));
        });

        test('includes transcription in prompt', () async {
          _mockResponse(mockTextGenService, '''
intent: play
parameters: {}
confidence: 0.9
''');

          const transcription = 'unique test transcription';
          await service.parseCommand(transcription);

          final captured = verify(
            mockTextGenService.generateText(
              prompt: captureAnyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).captured;

          expect(captured.first.toString(), contains(transcription));
        });
      });

      group('error handling', () {
        test('handles malformed AI response', () async {
          _mockResponse(mockTextGenService, 'Invalid response format');

          final result = await service.parseCommand('play');

          // Should return unknown with low confidence for malformed responses
          expect(result.intent, equals(VoiceIntent.unknown));
        });

        test('handles AI generation error', () async {
          when(
            mockTextGenService.generateText(
              prompt: anyNamed('prompt'),
              config: anyNamed('config'),
            ),
          ).thenThrow(AiGenerationException('Error'));

          final result = await service.parseCommand('play');

          expect(result.intent, equals(VoiceIntent.unknown));
          expect(result.confidence, equals(0.0));
        });
      });
    });
  });
}

void _mockResponse(MockTextGenerationService mock, String response) {
  when(
    mock.generateText(
      prompt: anyNamed('prompt'),
      config: anyNamed('config'),
    ),
  ).thenAnswer(
    (_) async => AiResponse(
      text: response,
      tokenCount: 10,
      durationMs: 50,
    ),
  );
}
