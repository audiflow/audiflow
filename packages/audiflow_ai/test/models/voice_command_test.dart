// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceIntent', () {
    test('has all required playback intents', () {
      expect(VoiceIntent.values, contains(VoiceIntent.play));
      expect(VoiceIntent.values, contains(VoiceIntent.pause));
      expect(VoiceIntent.values, contains(VoiceIntent.stop));
      expect(VoiceIntent.values, contains(VoiceIntent.skipForward));
      expect(VoiceIntent.values, contains(VoiceIntent.skipBackward));
      expect(VoiceIntent.values, contains(VoiceIntent.seek));
    });

    test('has search intent', () {
      expect(VoiceIntent.values, contains(VoiceIntent.search));
    });

    test('has all required navigation intents', () {
      expect(VoiceIntent.values, contains(VoiceIntent.goToLibrary));
      expect(VoiceIntent.values, contains(VoiceIntent.goToQueue));
      expect(VoiceIntent.values, contains(VoiceIntent.openSettings));
    });

    test('has all required queue management intents', () {
      expect(VoiceIntent.values, contains(VoiceIntent.addToQueue));
      expect(VoiceIntent.values, contains(VoiceIntent.removeFromQueue));
      expect(VoiceIntent.values, contains(VoiceIntent.clearQueue));
    });

    test('has unknown intent', () {
      expect(VoiceIntent.values, contains(VoiceIntent.unknown));
    });

    test('has expected total number of intents', () {
      // 6 playback + 1 search + 3 navigation + 3 queue + 1 unknown = 14
      expect(VoiceIntent.values, hasLength(14));
    });
  });

  group('VoiceCommand', () {
    group('constructor', () {
      test('creates instance with all required parameters', () {
        const command = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {'podcast': 'Tech Talk'},
          confidence: 0.95,
          rawTranscription: 'play tech talk podcast',
        );

        expect(command.intent, equals(VoiceIntent.play));
        expect(command.parameters, equals({'podcast': 'Tech Talk'}));
        expect(command.confidence, equals(0.95));
        expect(command.rawTranscription, equals('play tech talk podcast'));
      });

      test('creates instance with empty parameters', () {
        const command = VoiceCommand(
          intent: VoiceIntent.pause,
          parameters: {},
          confidence: 1,
          rawTranscription: 'pause',
        );

        expect(command.parameters, isEmpty);
      });

      test('creates instance with zero confidence', () {
        const command = VoiceCommand(
          intent: VoiceIntent.unknown,
          parameters: {},
          confidence: 0,
          rawTranscription: 'gibberish',
        );

        expect(command.confidence, equals(0.0));
      });

      test('creates instance with unknown intent', () {
        const command = VoiceCommand(
          intent: VoiceIntent.unknown,
          parameters: {},
          confidence: 0.2,
          rawTranscription: 'some unrecognized command',
        );

        expect(command.intent, equals(VoiceIntent.unknown));
      });
    });

    group('playback commands', () {
      test('play command with podcast name', () {
        const command = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {'podcast': 'Daily News'},
          confidence: 0.9,
          rawTranscription: 'play daily news',
        );

        expect(command.intent, equals(VoiceIntent.play));
        expect(command.parameters['podcast'], equals('Daily News'));
      });

      test('skip forward command with duration', () {
        const command = VoiceCommand(
          intent: VoiceIntent.skipForward,
          parameters: {'seconds': '30'},
          confidence: 0.85,
          rawTranscription: 'skip forward 30 seconds',
        );

        expect(command.intent, equals(VoiceIntent.skipForward));
        expect(command.parameters['seconds'], equals('30'));
      });

      test('seek command with timestamp', () {
        const command = VoiceCommand(
          intent: VoiceIntent.seek,
          parameters: {'position': '10:30'},
          confidence: 0.88,
          rawTranscription: 'go to 10 minutes 30 seconds',
        );

        expect(command.intent, equals(VoiceIntent.seek));
        expect(command.parameters['position'], equals('10:30'));
      });
    });

    group('search commands', () {
      test('search command with query', () {
        const command = VoiceCommand(
          intent: VoiceIntent.search,
          parameters: {'query': 'technology podcasts'},
          confidence: 0.92,
          rawTranscription: 'search for technology podcasts',
        );

        expect(command.intent, equals(VoiceIntent.search));
        expect(command.parameters['query'], equals('technology podcasts'));
      });
    });

    group('navigation commands', () {
      test('go to library command', () {
        const command = VoiceCommand(
          intent: VoiceIntent.goToLibrary,
          parameters: {},
          confidence: 0.98,
          rawTranscription: 'go to my library',
        );

        expect(command.intent, equals(VoiceIntent.goToLibrary));
      });

      test('go to queue command', () {
        const command = VoiceCommand(
          intent: VoiceIntent.goToQueue,
          parameters: {},
          confidence: 0.97,
          rawTranscription: 'show my queue',
        );

        expect(command.intent, equals(VoiceIntent.goToQueue));
      });

      test('open settings command', () {
        const command = VoiceCommand(
          intent: VoiceIntent.openSettings,
          parameters: {},
          confidence: 0.95,
          rawTranscription: 'open settings',
        );

        expect(command.intent, equals(VoiceIntent.openSettings));
      });
    });

    group('queue management commands', () {
      test('add to queue command', () {
        const command = VoiceCommand(
          intent: VoiceIntent.addToQueue,
          parameters: {'episode': 'Latest Episode'},
          confidence: 0.88,
          rawTranscription: 'add latest episode to queue',
        );

        expect(command.intent, equals(VoiceIntent.addToQueue));
        expect(command.parameters['episode'], equals('Latest Episode'));
      });

      test('remove from queue command', () {
        const command = VoiceCommand(
          intent: VoiceIntent.removeFromQueue,
          parameters: {'episode': 'Episode 5'},
          confidence: 0.85,
          rawTranscription: 'remove episode 5 from queue',
        );

        expect(command.intent, equals(VoiceIntent.removeFromQueue));
      });

      test('clear queue command', () {
        const command = VoiceCommand(
          intent: VoiceIntent.clearQueue,
          parameters: {},
          confidence: 0.99,
          rawTranscription: 'clear the queue',
        );

        expect(command.intent, equals(VoiceIntent.clearQueue));
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        const command1 = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {'key': 'value'},
          confidence: 0.9,
          rawTranscription: 'play something',
        );
        const command2 = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {'key': 'value'},
          confidence: 0.9,
          rawTranscription: 'play something',
        );

        expect(command1, equals(command2));
      });

      test('different intent makes instances unequal', () {
        const command1 = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {},
          confidence: 0.9,
          rawTranscription: 'command',
        );
        const command2 = VoiceCommand(
          intent: VoiceIntent.pause,
          parameters: {},
          confidence: 0.9,
          rawTranscription: 'command',
        );

        expect(command1, isNot(equals(command2)));
      });

      test('different confidence makes instances unequal', () {
        const command1 = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {},
          confidence: 0.9,
          rawTranscription: 'command',
        );
        const command2 = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {},
          confidence: 0.8,
          rawTranscription: 'command',
        );

        expect(command1, isNot(equals(command2)));
      });

      test('different rawTranscription makes instances unequal', () {
        const command1 = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {},
          confidence: 0.9,
          rawTranscription: 'command 1',
        );
        const command2 = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {},
          confidence: 0.9,
          rawTranscription: 'command 2',
        );

        expect(command1, isNot(equals(command2)));
      });

      test('identical instance is equal to itself', () {
        const command = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {},
          confidence: 0.9,
          rawTranscription: 'play',
        );

        expect(command, equals(command));
      });
    });

    group('hashCode', () {
      test('equal instances have same hashCode', () {
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

        expect(command1.hashCode, equals(command2.hashCode));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        const command = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: {'podcast': 'Test'},
          confidence: 0.95,
          rawTranscription: 'play test',
        );

        expect(
          command.toString(),
          equals(
            'VoiceCommand(intent: VoiceIntent.play, confidence: 0.95, '
            'params: {podcast: Test})',
          ),
        );
      });

      test('returns formatted string with empty parameters', () {
        const command = VoiceCommand(
          intent: VoiceIntent.pause,
          parameters: {},
          confidence: 1,
          rawTranscription: 'pause',
        );

        expect(
          command.toString(),
          equals(
            'VoiceCommand(intent: VoiceIntent.pause, confidence: 1.0, '
            'params: {})',
          ),
        );
      });
    });
  });
}
