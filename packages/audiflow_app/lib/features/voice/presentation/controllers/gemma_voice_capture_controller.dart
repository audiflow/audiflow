import 'dart:async';
import 'dart:typed_data';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../gemma/gemma_voice_capture_providers.dart';
import '../../gemma/gemma_voice_providers.dart';
import '../../gemma/voice_audio_recorder.dart';

part 'gemma_voice_capture_controller.g.dart';

/// Hold-to-talk capture state machine for the Gemma 4 voice command path.
///
/// `idle -> recording -> dispatching -> {success | failure}`. Calling
/// [GemmaVoiceCaptureController.start] more than once without an
/// intervening [GemmaVoiceCaptureController.stop] /
/// [GemmaVoiceCaptureController.cancel] is a no-op so trigger-button
/// double-taps don't desync the recorder.
sealed class GemmaCaptureState {
  const GemmaCaptureState();
}

final class GemmaCaptureIdle extends GemmaCaptureState {
  const GemmaCaptureIdle();
}

final class GemmaCaptureRecording extends GemmaCaptureState {
  const GemmaCaptureRecording();
}

final class GemmaCaptureDispatching extends GemmaCaptureState {
  const GemmaCaptureDispatching();
}

final class GemmaCaptureSuccess extends GemmaCaptureState {
  const GemmaCaptureSuccess(this.command);
  final VoiceCommand command;
}

final class GemmaCaptureFailure extends GemmaCaptureState {
  const GemmaCaptureFailure(this.reason);
  final GemmaCaptureFailureReason reason;
}

/// Reasons capture can fail. Distinct from
/// [VoiceCommandFailureReason] which describes inference outcomes; this
/// enum covers everything that goes wrong before the route runs.
enum GemmaCaptureFailureReason {
  permissionDenied,

  /// `recorder.start()` threw (e.g. platform plugin unavailable).
  recorderUnavailable,

  /// `recorder.stop()` threw (mid-capture failure).
  recordingError,

  /// The route / inference layer threw an unhandled exception. Inference
  /// outcomes that the service models as
  /// [VoiceCommandFailureReason.inferenceError] still flow through as
  /// success (the route returns a [VoiceCommand]); only thrown errors
  /// land here.
  dispatchFailed,
}

/// Hard cap on a single utterance. Matches the Gemma audio token budget
/// (25 tokens/sec, ~750 max for the chat session's 1024-token budget).
const Duration _maxRecordingDuration = Duration(seconds: 30);

@riverpod
class GemmaVoiceCaptureController extends _$GemmaVoiceCaptureController {
  Timer? _autoStopTimer;

  @override
  GemmaCaptureState build() {
    ref.onDispose(() {
      _autoStopTimer?.cancel();
      _autoStopTimer = null;
    });
    return const GemmaCaptureIdle();
  }

  Logger get _logger => ref.read(namedLoggerProvider('GemmaVoiceCapture'));
  VoiceAudioRecorder get _recorder => ref.read(voiceAudioRecorderProvider);
  GemmaVoiceCommandRoute get _route => ref.read(gemmaVoiceCommandRouteProvider);

  /// Begin recording. No-op if already recording or dispatching.
  Future<void> start() async {
    if (state is! GemmaCaptureIdle &&
        state is! GemmaCaptureSuccess &&
        state is! GemmaCaptureFailure) {
      return;
    }
    if (!await _recorder.hasPermission()) {
      state = const GemmaCaptureFailure(
        GemmaCaptureFailureReason.permissionDenied,
      );
      return;
    }
    try {
      await _recorder.start();
    } on Exception catch (e, st) {
      _logger.e('recorder.start() failed', error: e, stackTrace: st);
      state = const GemmaCaptureFailure(
        GemmaCaptureFailureReason.recorderUnavailable,
      );
      return;
    }
    _autoStopTimer = Timer(_maxRecordingDuration, () {
      // The user is holding past the cap; stop and dispatch what we have.
      unawaited(stop());
    });
    state = const GemmaCaptureRecording();
  }

  /// Stop recording, dispatch to the route, and emit the resulting state.
  Future<void> stop() async {
    if (state is! GemmaCaptureRecording) {
      return;
    }
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    final Uint8List audio;
    try {
      audio = await _recorder.stop();
    } on Exception catch (e, st) {
      _logger.e('recorder.stop() failed', error: e, stackTrace: st);
      state = const GemmaCaptureFailure(
        GemmaCaptureFailureReason.recordingError,
      );
      return;
    }
    state = const GemmaCaptureDispatching();
    try {
      final command = await _route.dispatch(audio);
      state = GemmaCaptureSuccess(command);
    } on Exception catch (e, st) {
      _logger.e('route.dispatch() failed', error: e, stackTrace: st);
      state = const GemmaCaptureFailure(
        GemmaCaptureFailureReason.dispatchFailed,
      );
    }
  }

  /// Cancel any in-flight recording and return to idle.
  Future<void> cancel() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    if (state is GemmaCaptureRecording) {
      await _recorder.cancel();
    }
    state = const GemmaCaptureIdle();
  }

  /// Reset to idle from a terminal state without touching the recorder.
  void reset() {
    if (state is GemmaCaptureSuccess || state is GemmaCaptureFailure) {
      state = const GemmaCaptureIdle();
    }
  }
}
