import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceRecognitionState', () {
    group('idle', () {
      test('creates idle state', () {
        const state = VoiceRecognitionState.idle();
        expect(state, isA<VoiceIdle>());
      });

      test('two idle states are equal', () {
        const a = VoiceRecognitionState.idle();
        const b = VoiceRecognitionState.idle();
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('listening', () {
      test('creates with no partial transcript', () {
        const state = VoiceRecognitionState.listening();
        expect(state, isA<VoiceListening>());
        expect((state as VoiceListening).partialTranscript, isNull);
      });

      test('creates with partial transcript', () {
        const state = VoiceRecognitionState.listening(
          partialTranscript: 'play the',
        );
        expect((state as VoiceListening).partialTranscript, 'play the');
      });

      test('accepts empty partial transcript', () {
        const state = VoiceRecognitionState.listening(partialTranscript: '');
        expect((state as VoiceListening).partialTranscript, '');
      });

      test('two listening states with same transcript are equal', () {
        const a = VoiceRecognitionState.listening(partialTranscript: 'hello');
        const b = VoiceRecognitionState.listening(partialTranscript: 'hello');
        expect(a, equals(b));
      });

      test('two listening states with different transcripts differ', () {
        const a = VoiceRecognitionState.listening(partialTranscript: 'hello');
        const b = VoiceRecognitionState.listening(partialTranscript: 'world');
        expect(a, isNot(equals(b)));
      });

      test('listening with null differs from listening with empty', () {
        const a = VoiceRecognitionState.listening();
        const b = VoiceRecognitionState.listening(partialTranscript: '');
        expect(a, isNot(equals(b)));
      });
    });

    group('processing', () {
      test('holds transcription', () {
        const state = VoiceRecognitionState.processing(
          transcription: 'play podcast',
        );
        expect(state, isA<VoiceProcessing>());
        expect((state as VoiceProcessing).transcription, 'play podcast');
      });

      test('accepts empty transcription', () {
        const state = VoiceRecognitionState.processing(transcription: '');
        expect((state as VoiceProcessing).transcription, '');
      });

      test('is not equal to listening', () {
        const processing = VoiceRecognitionState.processing(
          transcription: 'text',
        );
        const listening = VoiceRecognitionState.listening(
          partialTranscript: 'text',
        );
        expect(processing, isNot(equals(listening)));
      });
    });

    group('executing', () {
      test('holds voice command', () {
        final command = VoiceCommand(
          intent: VoiceIntent.play,
          parameters: const {},
          confidence: 0.9,
          rawTranscription: 'play',
        );
        final state = VoiceRecognitionState.executing(command: command);

        expect(state, isA<VoiceExecuting>());
        expect((state as VoiceExecuting).command.intent, VoiceIntent.play);
        expect(state.command.confidence, 0.9);
      });

      test('two executing states with same command are equal', () {
        final command = VoiceCommand(
          intent: VoiceIntent.pause,
          parameters: const {},
          confidence: 0.95,
          rawTranscription: 'pause',
        );
        final a = VoiceRecognitionState.executing(command: command);
        final b = VoiceRecognitionState.executing(command: command);
        expect(a, equals(b));
      });
    });

    group('success', () {
      test('holds success message', () {
        const state = VoiceRecognitionState.success(
          message: 'Playback started',
        );
        expect(state, isA<VoiceSuccess>());
        expect((state as VoiceSuccess).message, 'Playback started');
      });

      test('accepts empty message', () {
        const state = VoiceRecognitionState.success(message: '');
        expect((state as VoiceSuccess).message, '');
      });

      test('two success states with same message are equal', () {
        const a = VoiceRecognitionState.success(message: 'ok');
        const b = VoiceRecognitionState.success(message: 'ok');
        expect(a, equals(b));
      });
    });

    group('error', () {
      test('holds error message', () {
        const state = VoiceRecognitionState.error(
          message: 'Microphone unavailable',
        );
        expect(state, isA<VoiceError>());
        expect((state as VoiceError).message, 'Microphone unavailable');
      });

      test('accepts empty message', () {
        const state = VoiceRecognitionState.error(message: '');
        expect((state as VoiceError).message, '');
      });

      test('is not equal to success with same message', () {
        const error = VoiceRecognitionState.error(message: 'msg');
        const success = VoiceRecognitionState.success(message: 'msg');
        expect(error, isNot(equals(success)));
      });
    });

    group('pattern matching', () {
      test('exhaustive switch covers all variants', () {
        final command = VoiceCommand(
          intent: VoiceIntent.search,
          parameters: const {'query': 'tech'},
          confidence: 0.85,
          rawTranscription: 'search tech',
        );

        final states = <VoiceRecognitionState>[
          const VoiceRecognitionState.idle(),
          const VoiceRecognitionState.listening(partialTranscript: 'search'),
          const VoiceRecognitionState.processing(transcription: 'search tech'),
          VoiceRecognitionState.executing(command: command),
          const VoiceRecognitionState.success(message: 'Found results'),
          const VoiceRecognitionState.error(message: 'No results'),
        ];

        final results = states.map((state) {
          return switch (state) {
            VoiceIdle() => 'idle',
            VoiceListening() => 'listening',
            VoiceProcessing() => 'processing',
            VoiceExecuting() => 'executing',
            VoiceSuccess() => 'success',
            VoiceError() => 'error',
          };
        }).toList();

        expect(results, [
          'idle',
          'listening',
          'processing',
          'executing',
          'success',
          'error',
        ]);
      });

      test('destructuring extracts fields', () {
        const VoiceRecognitionState state = VoiceRecognitionState.processing(
          transcription: 'play music',
        );

        final text = switch (state) {
          VoiceListening(:final partialTranscript) => partialTranscript,
          VoiceProcessing(:final transcription) => transcription,
          VoiceSuccess(:final message) => message,
          VoiceError(:final message) => message,
          _ => null,
        };

        expect(text, 'play music');
      });
    });

    group('copyWith', () {
      test('copies listening with new transcript', () {
        const original = VoiceRecognitionState.listening(
          partialTranscript: 'play',
        );
        final copied = (original as VoiceListening).copyWith(
          partialTranscript: 'play podcast',
        );

        expect(copied.partialTranscript, 'play podcast');
      });

      test('copies processing with new transcription', () {
        const original = VoiceRecognitionState.processing(transcription: 'old');
        final copied = (original as VoiceProcessing).copyWith(
          transcription: 'new',
        );

        expect(copied.transcription, 'new');
      });

      test('copies error with new message', () {
        const original = VoiceRecognitionState.error(message: 'old error');
        final copied = (original as VoiceError).copyWith(message: 'new error');

        expect(copied.message, 'new error');
      });
    });
  });
}
