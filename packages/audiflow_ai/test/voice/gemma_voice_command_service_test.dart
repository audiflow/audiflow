import 'dart:typed_data';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final audio = Uint8List.fromList(const [1, 2, 3]);
  final settingsSnapshot = <SettingsSnapshotEntry>[
    {'key': 'speed'},
    {'key': 'theme'},
    {'key': 'skip_forward_seconds'},
  ];

  group('GemmaVoiceCommandService', () {
    test('maps a fixed tool to its VoiceIntent', () async {
      final service = _serviceReturning(
        const GemmaFunctionCall(name: 'pause', args: {}),
      );
      final command = await service.dispatch(
        audio: audio,
        settingsSnapshot: settingsSnapshot,
      );
      check(command.intent).equals(VoiceIntent.pause);
      check(command.confidence).equals(0.95);
      check(command.parameters).isEmpty();
      check(command.settingsPayload).isNull();
    });

    test('preserves args for tools that take parameters', () async {
      final service = _serviceReturning(
        const GemmaFunctionCall(
          name: 'seek',
          args: {'seconds': 120},
        ),
      );
      final command = await service.dispatch(
        audio: audio,
        settingsSnapshot: settingsSnapshot,
      );
      check(command.intent).equals(VoiceIntent.seek);
      check(command.parameters['seconds']).equals('120');
    });

    test('passes the system prompt and built tools to the session', () async {
      final session = _RecordingSession(
        const GemmaFunctionCall(name: 'play', args: {}),
      );
      final service = GemmaVoiceCommandService(session: session);
      await service.dispatch(audio: audio, settingsSnapshot: settingsSnapshot);
      check(session.lastSystemPrompt).equals(voiceSystemPrompt);
      check(session.lastTools).isNotNull();
      check(
        session.lastTools!.map((t) => t.name).toList(),
      ).contains('changeSettings');
    });

    test('changeSettings absolute -> SettingsChangePayloadAbsolute', () async {
      final service = _serviceReturning(
        const GemmaFunctionCall(
          name: 'changeSettings',
          args: {
            'variant': 'absolute',
            'key': 'speed',
            'value': '1.5',
            'confidence': 0.92,
          },
        ),
      );
      final command = await service.dispatch(
        audio: audio,
        settingsSnapshot: settingsSnapshot,
      );
      check(command.intent).equals(VoiceIntent.changeSettings);
      check(command.confidence).equals(0.92);
      check(command.settingsPayload).equals(
        const SettingsChangePayload.absolute(
          key: 'speed',
          value: '1.5',
          confidence: 0.92,
        ),
      );
    });

    test('changeSettings relative -> SettingsChangePayloadRelative', () async {
      final service = _serviceReturning(
        const GemmaFunctionCall(
          name: 'changeSettings',
          args: {
            'variant': 'relative',
            'key': 'speed',
            'direction': 'increase',
            'magnitude': 'small',
            'confidence': 0.7,
          },
        ),
      );
      final command = await service.dispatch(
        audio: audio,
        settingsSnapshot: settingsSnapshot,
      );
      check(command.settingsPayload).equals(
        const SettingsChangePayload.relative(
          key: 'speed',
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.small,
          confidence: 0.7,
        ),
      );
    });

    test(
      'changeSettings ambiguous (non-empty) -> SettingsChangePayloadAmbiguous',
      () async {
        final service = _serviceReturning(
          const GemmaFunctionCall(
            name: 'changeSettings',
            args: {
              'variant': 'ambiguous',
              'candidates': [
                {'key': 'speed', 'value': '1.5', 'confidence': 0.6},
                {
                  'key': 'skip_forward_seconds',
                  'value': '15',
                  'confidence': 0.4,
                },
              ],
            },
          ),
        );
        final command = await service.dispatch(
          audio: audio,
          settingsSnapshot: settingsSnapshot,
        );
        check(command.intent).equals(VoiceIntent.changeSettings);
        final payload = command.settingsPayload;
        check(payload).isA<SettingsChangePayloadAmbiguous>();
        check(
          (payload! as SettingsChangePayloadAmbiguous).candidates,
        ).length.equals(2);
        check(command.confidence).equals(0.6);
      },
    );

    test(
      'empty ambiguous candidates surface as zero-confidence',
      () async {
        final service = _serviceReturning(
          const GemmaFunctionCall(
            name: 'changeSettings',
            args: {'variant': 'ambiguous', 'candidates': []},
          ),
        );
        final command = await service.dispatch(
          audio: audio,
          settingsSnapshot: settingsSnapshot,
        );
        // System prompt instructs the model to use this shape as the
        // "no command recognized" signal -- but it still emits a valid
        // ambiguous payload, so we surface that as unknown via confidence.
        check(command.intent).equals(VoiceIntent.changeSettings);
        check(command.confidence).equals(0);
      },
    );

    test('unknown tool name -> VoiceIntent.unknown', () async {
      final service = _serviceReturning(
        const GemmaFunctionCall(name: 'doSomethingWeird', args: {}),
      );
      final command = await service.dispatch(
        audio: audio,
        settingsSnapshot: settingsSnapshot,
      );
      check(command.intent).equals(VoiceIntent.unknown);
    });

    test('inference throws -> VoiceIntent.unknown', () async {
      final service = GemmaVoiceCommandService(
        session: _ThrowingSession(),
      );
      final command = await service.dispatch(
        audio: audio,
        settingsSnapshot: settingsSnapshot,
      );
      check(command.intent).equals(VoiceIntent.unknown);
    });

    test(
      'changeSettings with malformed payload -> VoiceIntent.unknown',
      () async {
        final service = _serviceReturning(
          const GemmaFunctionCall(
            name: 'changeSettings',
            args: {'variant': 'absolute', 'key': 'speed'},
            // missing value + confidence
          ),
        );
        final command = await service.dispatch(
          audio: audio,
          settingsSnapshot: settingsSnapshot,
        );
        check(command.intent).equals(VoiceIntent.unknown);
      },
    );
  });
}

GemmaVoiceCommandService _serviceReturning(GemmaFunctionCall call) =>
    GemmaVoiceCommandService(session: _StubSession(call));

class _StubSession implements GemmaInferenceSession {
  _StubSession(this._call);
  final GemmaFunctionCall _call;

  @override
  Future<GemmaFunctionCall> runWithAudio({
    required Uint8List audio,
    required String systemPrompt,
    required List<VoiceToolDefinition> tools,
  }) async => _call;
}

class _RecordingSession implements GemmaInferenceSession {
  _RecordingSession(this._call);
  final GemmaFunctionCall _call;
  String? lastSystemPrompt;
  List<VoiceToolDefinition>? lastTools;

  @override
  Future<GemmaFunctionCall> runWithAudio({
    required Uint8List audio,
    required String systemPrompt,
    required List<VoiceToolDefinition> tools,
  }) async {
    lastSystemPrompt = systemPrompt;
    lastTools = tools;
    return _call;
  }
}

class _ThrowingSession implements GemmaInferenceSession {
  @override
  Future<GemmaFunctionCall> runWithAudio({
    required Uint8List audio,
    required String systemPrompt,
    required List<VoiceToolDefinition> tools,
  }) async => throw StateError('boom');
}
