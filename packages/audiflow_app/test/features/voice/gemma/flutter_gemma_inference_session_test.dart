import 'package:audiflow_ai/audiflow_ai.dart' as ai;
import 'package:audiflow_app/features/voice/gemma/flutter_gemma_inference_session.dart';
import 'package:checks/checks.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('voiceToolToFlutterGemmaTool', () {
    test('preserves name, description, and parameters map', () {
      final def = ai.VoiceToolDefinition(
        intent: ai.VoiceIntent.seek,
        description: 'Seek to seconds.',
        parameters: const {
          'type': 'object',
          'properties': {
            'seconds': {'type': 'integer'},
          },
        },
      );
      final tool = voiceToolToFlutterGemmaTool(def);
      check(tool.name).equals('seek');
      check(tool.description).equals('Seek to seconds.');
      check(tool.parameters['type']).equals('object');
    });
  });

  group('parseFlutterGemmaResponse', () {
    test('FunctionCallResponse maps 1:1 to GemmaFunctionCall', () {
      final response = const FunctionCallResponse(name: 'pause', args: {});
      final call = parseFlutterGemmaResponse(response);
      check(call.name).equals('pause');
      check(call.args).isEmpty();
    });

    test('args dynamic typing converts to Object?', () {
      final response = const FunctionCallResponse(
        name: 'seek',
        args: <String, dynamic>{'seconds': 120},
      );
      final call = parseFlutterGemmaResponse(response);
      check(call.args['seconds']).equals(120);
    });

    test('ParallelFunctionCallResponse keeps the first call', () {
      const response = ParallelFunctionCallResponse(
        calls: [
          FunctionCallResponse(name: 'play', args: {}),
          FunctionCallResponse(name: 'pause', args: {}),
        ],
      );
      final call = parseFlutterGemmaResponse(response);
      check(call.name).equals('play');
    });

    test('TextResponse throws (no function call emitted)', () {
      const response = TextResponse('hello');
      check(() => parseFlutterGemmaResponse(response)).throws<Exception>();
    });

    test('empty ParallelFunctionCallResponse throws', () {
      const response = ParallelFunctionCallResponse(calls: []);
      check(() => parseFlutterGemmaResponse(response)).throws<Exception>();
    });
  });
}
