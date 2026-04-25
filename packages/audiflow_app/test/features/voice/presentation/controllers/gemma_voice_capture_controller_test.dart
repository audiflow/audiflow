import 'dart:typed_data';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_app/features/voice/gemma/gemma_voice_capture_providers.dart';
import 'package:audiflow_app/features/voice/gemma/gemma_voice_providers.dart';
import 'package:audiflow_app/features/voice/gemma/voice_audio_recorder.dart';
import 'package:audiflow_app/features/voice/presentation/controllers/gemma_voice_capture_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeRecorder recorder;
  late _FakeRoute route;

  setUp(() {
    recorder = _FakeRecorder();
    route = _FakeRoute();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        voiceAudioRecorderProvider.overrideWithValue(recorder),
        gemmaVoiceCommandRouteProvider.overrideWithValue(route),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('starts recording when permission is granted', () async {
    final container = makeContainer();
    final notifier = container.read(
      gemmaVoiceCaptureControllerProvider.notifier,
    );

    await notifier.start();

    check(
      container.read(gemmaVoiceCaptureControllerProvider),
    ).isA<GemmaCaptureRecording>();
    check(recorder.startCalls).equals(1);
  });

  test('emits permissionDenied when permission missing', () async {
    recorder.permission = false;
    final container = makeContainer();
    final notifier = container.read(
      gemmaVoiceCaptureControllerProvider.notifier,
    );

    await notifier.start();

    final state = container.read(gemmaVoiceCaptureControllerProvider);
    check(state)
        .isA<GemmaCaptureFailure>()
        .has((s) => s.reason, 'reason')
        .equals(GemmaCaptureFailureReason.permissionDenied);
    check(recorder.startCalls).equals(0);
  });

  test('emits recorderUnavailable when start throws', () async {
    recorder.startError = Exception('plugin missing');
    final container = makeContainer();
    final notifier = container.read(
      gemmaVoiceCaptureControllerProvider.notifier,
    );

    await notifier.start();

    final state = container.read(gemmaVoiceCaptureControllerProvider);
    check(state)
        .isA<GemmaCaptureFailure>()
        .has((s) => s.reason, 'reason')
        .equals(GemmaCaptureFailureReason.recorderUnavailable);
  });

  test('stop dispatches captured audio and emits the parsed command', () async {
    final container = makeContainer();
    final notifier = container.read(
      gemmaVoiceCaptureControllerProvider.notifier,
    );
    await notifier.start();
    await notifier.stop();

    check(route.dispatchedAudio).isNotNull();
    check(route.dispatchedAudio!.toList()).deepEquals([1, 2, 3]);
    final state = container.read(gemmaVoiceCaptureControllerProvider);
    check(state)
        .isA<GemmaCaptureSuccess>()
        .has((s) => s.command.intent, 'command.intent')
        .equals(VoiceIntent.pause);
  });

  test('emits recordingError when stop throws', () async {
    recorder.stopError = Exception('boom');
    final container = makeContainer();
    final notifier = container.read(
      gemmaVoiceCaptureControllerProvider.notifier,
    );
    await notifier.start();
    await notifier.stop();

    final state = container.read(gemmaVoiceCaptureControllerProvider);
    check(state)
        .isA<GemmaCaptureFailure>()
        .has((s) => s.reason, 'reason')
        .equals(GemmaCaptureFailureReason.recordingError);
    check(route.dispatchedAudio).isNull();
  });

  test('emits dispatchFailed when route throws', () async {
    route.error = Exception('inference exploded');
    final container = makeContainer();
    final notifier = container.read(
      gemmaVoiceCaptureControllerProvider.notifier,
    );
    await notifier.start();
    await notifier.stop();

    final state = container.read(gemmaVoiceCaptureControllerProvider);
    check(state)
        .isA<GemmaCaptureFailure>()
        .has((s) => s.reason, 'reason')
        .equals(GemmaCaptureFailureReason.dispatchFailed);
  });

  test('inference-modeled failure surfaces as success state', () async {
    // VoiceCommandFailureReason.inferenceError is a route-returned outcome,
    // not a thrown exception, so it must end up in GemmaCaptureSuccess
    // carrying a VoiceCommand whose intent is unknown.
    route.command = VoiceCommand(
      intent: VoiceIntent.unknown,
      parameters: const {},
      confidence: 0,
      rawTranscription: '',
      failureReason: VoiceCommandFailureReason.inferenceError,
    );
    final container = makeContainer();
    final notifier = container.read(
      gemmaVoiceCaptureControllerProvider.notifier,
    );
    await notifier.start();
    await notifier.stop();

    final state = container.read(gemmaVoiceCaptureControllerProvider);
    check(state)
        .isA<GemmaCaptureSuccess>()
        .has((s) => s.command.failureReason, 'failureReason')
        .equals(VoiceCommandFailureReason.inferenceError);
  });

  test('cancel returns to idle and asks recorder to discard buffer', () async {
    final container = makeContainer();
    final notifier = container.read(
      gemmaVoiceCaptureControllerProvider.notifier,
    );
    await notifier.start();
    await notifier.cancel();

    check(
      container.read(gemmaVoiceCaptureControllerProvider),
    ).isA<GemmaCaptureIdle>();
    check(recorder.cancelCalls).equals(1);
  });

  test('start is a no-op while already recording', () async {
    final container = makeContainer();
    final notifier = container.read(
      gemmaVoiceCaptureControllerProvider.notifier,
    );
    await notifier.start();
    await notifier.start();

    check(recorder.startCalls).equals(1);
  });

  test('reset clears terminal state without touching recorder', () async {
    final container = makeContainer();
    final notifier = container.read(
      gemmaVoiceCaptureControllerProvider.notifier,
    );
    await notifier.start();
    await notifier.stop();
    notifier.reset();

    check(
      container.read(gemmaVoiceCaptureControllerProvider),
    ).isA<GemmaCaptureIdle>();
    check(recorder.cancelCalls).equals(0);
  });
}

class _FakeRecorder implements VoiceAudioRecorder {
  bool permission = true;
  Object? startError;
  Object? stopError;
  Uint8List wav = Uint8List.fromList([1, 2, 3]);

  int startCalls = 0;
  int cancelCalls = 0;

  @override
  Future<bool> hasPermission() async => permission;

  @override
  Future<void> start() async {
    if (startError != null) throw startError!;
    startCalls += 1;
  }

  @override
  Future<Uint8List> stop() async {
    if (stopError != null) throw stopError!;
    return wav;
  }

  @override
  Future<void> cancel() async {
    cancelCalls += 1;
  }

  @override
  Future<void> dispose() async {}
}

class _FakeRoute implements GemmaVoiceCommandRoute {
  Uint8List? dispatchedAudio;
  Object? error;
  VoiceCommand command = VoiceCommand(
    intent: VoiceIntent.pause,
    parameters: const {},
    confidence: 1,
    rawTranscription: '',
  );

  @override
  Future<VoiceCommand> dispatch(Uint8List audio) async {
    dispatchedAudio = audio;
    if (error != null) throw error!;
    return command;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
