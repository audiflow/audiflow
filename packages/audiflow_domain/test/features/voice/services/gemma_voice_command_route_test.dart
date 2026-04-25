import 'dart:typed_data';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_app_settings_repository.dart';

void main() {
  group('GemmaVoiceCommandRoute', () {
    test('builds settings snapshot from registry and forwards audio', () async {
      final session = _RecordingSession(
        GemmaFunctionCall(name: 'pause', args: const {}),
      );
      final route = GemmaVoiceCommandRoute(
        service: GemmaVoiceCommandService(session: session),
        registry: SettingsMetadataRegistry(),
        settingsRepository: FakeAppSettingsRepository(),
      );

      final audio = Uint8List.fromList(const [9, 8, 7]);
      final command = await route.dispatch(audio);

      check(command.intent).equals(VoiceIntent.pause);
      final received = session.lastAudio?.toList() ?? const <int>[];
      check(received).deepEquals(audio.toList());

      // Snapshot must include every key registered in the metadata
      // registry; verify a representative sample.
      final keys = session.lastTools!
          .map((t) => t.name)
          .where((name) => name == 'changeSettings')
          .toList();
      check(keys).length.equals(1);
    });
  });
}

class _RecordingSession implements GemmaInferenceSession {
  _RecordingSession(this._call);
  final GemmaFunctionCall _call;
  Uint8List? lastAudio;
  List<VoiceToolDefinition>? lastTools;

  @override
  Future<GemmaFunctionCall> runWithAudio({
    required Uint8List audio,
    required String systemPrompt,
    required List<VoiceToolDefinition> tools,
  }) async {
    lastAudio = audio;
    lastTools = tools;
    return _call;
  }
}
