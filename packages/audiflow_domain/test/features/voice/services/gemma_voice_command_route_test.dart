import 'dart:typed_data';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_app_settings_repository.dart';

void main() {
  group('GemmaVoiceCommandRoute', () {
    late _RecordingService service;
    late GemmaVoiceCommandRoute route;

    setUp(() {
      service = _RecordingService();
      route = GemmaVoiceCommandRoute(
        service: service,
        registry: SettingsMetadataRegistry(),
        settingsRepository: FakeAppSettingsRepository(),
      );
    });

    test('builds settings snapshot from registry and forwards audio', () async {
      final audio = Uint8List.fromList(const [9, 8, 7]);
      service.responseFor = (audio: audio, snapshot: null);
      service.commandToReturn = const VoiceCommand(
        intent: VoiceIntent.pause,
        parameters: {},
        confidence: 0.95,
        rawTranscription: '',
      );

      final command = await route.dispatch(audio);

      check(command.intent).equals(VoiceIntent.pause);
      final received = service.lastAudio?.toList() ?? const <int>[];
      check(received).deepEquals(audio.toList());
      // Snapshot must include every key registered in the metadata
      // registry; verify a representative sample.
      final keys = service.lastSnapshot!
          .map((entry) => entry['key'])
          .whereType<String>()
          .toSet();
      check(keys).contains(SettingsKeys.themeMode);
      check(keys).contains(SettingsKeys.playbackSpeed);
      check(keys).contains(SettingsKeys.skipForwardSeconds);
    });
  });
}

class _RecordingService extends GemmaVoiceCommandService {
  _RecordingService() : super(session: _UnusedSession());

  Uint8List? lastAudio;
  List<SettingsSnapshotEntry>? lastSnapshot;
  ({Uint8List audio, List<SettingsSnapshotEntry>? snapshot})? responseFor;
  VoiceCommand commandToReturn = const VoiceCommand(
    intent: VoiceIntent.unknown,
    parameters: {},
    confidence: 0,
    rawTranscription: '',
  );

  @override
  Future<VoiceCommand> dispatch({
    required Uint8List audio,
    required List<SettingsSnapshotEntry> settingsSnapshot,
  }) async {
    lastAudio = audio;
    lastSnapshot = settingsSnapshot;
    return commandToReturn;
  }
}

class _UnusedSession implements GemmaInferenceSession {
  @override
  Future<GemmaFunctionCall> runWithAudio({
    required Uint8List audio,
    required String systemPrompt,
    required List<VoiceToolDefinition> tools,
  }) async => throw UnimplementedError('not used in this test');
}
