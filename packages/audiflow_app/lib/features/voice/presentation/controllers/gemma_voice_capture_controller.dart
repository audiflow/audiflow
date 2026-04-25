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

  /// Bumped on every cancel/reset/new-start. Async continuations check the
  /// epoch they captured at the start of their turn before mutating state,
  /// so a late-arriving `route.dispatch` result can't resurrect a state
  /// the user already cancelled.
  int _epoch = 0;

  /// Latched the first time a `stop()` for the current recording session
  /// crosses the synchronous prelude. Prevents the manual-release vs
  /// 30s-timer race from double-stopping the recorder.
  bool _stopping = false;

  /// Latched while a `start()` is in flight so two concurrent start calls
  /// can't both reach `_recorder.start()` — the second would hit the
  /// recorder's re-entry `StateError` (an Error subtype, escaping our
  /// `on Exception` catch).
  bool _starting = false;

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

  /// Begin recording. No-op if already recording, dispatching, or if
  /// another start() is in flight.
  Future<void> start() async {
    if (_starting ||
        (state is! GemmaCaptureIdle &&
            state is! GemmaCaptureSuccess &&
            state is! GemmaCaptureFailure)) {
      return;
    }
    _starting = true;
    final epoch = ++_epoch;
    try {
      if (!await _recorder.hasPermission()) {
        if (_epoch == epoch) {
          state = const GemmaCaptureFailure(
            GemmaCaptureFailureReason.permissionDenied,
          );
        }
        return;
      }
      try {
        await _recorder.start();
      } on Exception catch (e, st) {
        _logger.e('recorder.start() failed', error: e, stackTrace: st);
        if (_epoch == epoch) {
          state = const GemmaCaptureFailure(
            GemmaCaptureFailureReason.recorderUnavailable,
          );
        }
        return;
      }
      if (_epoch != epoch) {
        // The session was cancelled while start() was in flight; tear down
        // the just-started recorder so we don't leak a recording session.
        // Wrap so a recorder cleanup failure can't escape to the user-tap
        // handler as an unhandled async error.
        try {
          await _recorder.cancel();
        } on Exception catch (e, st) {
          _logger.w(
            'recorder.cancel() during start-cancel race failed',
            error: e,
            stackTrace: st,
          );
        }
        return;
      }
      _stopping = false;
      _autoStopTimer = Timer(_maxRecordingDuration, () {
        // The user is holding past the cap; stop and dispatch what we have.
        unawaited(stop());
      });
      state = const GemmaCaptureRecording();
    } finally {
      _starting = false;
    }
  }

  /// Stop recording, dispatch to the route, and emit the resulting state.
  Future<void> stop() async {
    // Synchronous claim: the manual-release callback and the 30s timer
    // can both call stop() in the same microtask; only the first one
    // proceeds.
    if (state is! GemmaCaptureRecording || _stopping) {
      return;
    }
    _stopping = true;
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    final epoch = _epoch;
    final Uint8List audio;
    try {
      audio = await _recorder.stop();
    } on Exception catch (e, st) {
      _logger.e('recorder.stop() failed', error: e, stackTrace: st);
      if (_epoch == epoch) {
        state = const GemmaCaptureFailure(
          GemmaCaptureFailureReason.recordingError,
        );
      }
      return;
    }
    if (_epoch != epoch) {
      // Cancelled mid-stop; drop the audio rather than dispatching it.
      // Logged so on-device traces explain why a tap produced no command.
      _logger.d(
        'stop() epoch mismatch; dropping ${audio.length}B captured audio',
      );
      return;
    }
    state = const GemmaCaptureDispatching();
    try {
      final command = await _route.dispatch(audio);
      if (_epoch == epoch) {
        state = GemmaCaptureSuccess(command);
      }
    } on Exception catch (e, st) {
      _logger.e('route.dispatch() failed', error: e, stackTrace: st);
      if (_epoch == epoch) {
        state = const GemmaCaptureFailure(
          GemmaCaptureFailureReason.dispatchFailed,
        );
      }
    }
  }

  /// Cancel any in-flight recording and return to idle.
  Future<void> cancel() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    _epoch += 1;
    final wasRecording = state is GemmaCaptureRecording;
    state = const GemmaCaptureIdle();
    if (!wasRecording) {
      return;
    }
    try {
      await _recorder.cancel();
    } on Exception catch (e, st) {
      // Already in Idle; recorder cleanup failed but the controller is in
      // a defined state. Log and move on.
      _logger.w('recorder.cancel() failed', error: e, stackTrace: st);
    }
  }

  /// Reset to idle from a terminal state without touching the recorder.
  void reset() {
    if (state is GemmaCaptureSuccess || state is GemmaCaptureFailure) {
      state = const GemmaCaptureIdle();
    }
  }
}
