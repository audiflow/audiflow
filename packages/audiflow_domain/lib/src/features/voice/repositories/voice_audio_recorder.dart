import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../utils/wav_header.dart';

part 'voice_audio_recorder.g.dart';

/// Captures one short utterance from the device microphone for the on-device
/// Gemma 4 voice command path.
///
/// Implementations record raw 16 kHz mono 16-bit PCM and return a complete
/// WAV payload from [stop]; recorders that fail mid-capture must surface a
/// real exception rather than returning a truncated buffer. [cancel] is the
/// no-result counterpart used when the user releases the trigger early.
abstract interface class VoiceAudioRecorder {
  Future<bool> hasPermission();

  /// Begin streaming microphone audio into an internal buffer. Re-calling
  /// start without an intervening [stop] / [cancel] is a programming error
  /// and throws [StateError].
  Future<void> start();

  /// Stop recording and return the complete WAV payload. Throws if
  /// [start] was not called or the underlying stream errored mid-capture.
  Future<Uint8List> stop();

  /// Discard any in-flight recording. Safe to call when idle.
  Future<void> cancel();

  Future<void> dispose();
}

/// keepAlive because the underlying `record` plugin holds a native
/// `AVAudioRecorder` / `MediaRecorder` instance; recreating it per voice
/// turn would re-pay the platform-channel initialization cost.
@Riverpod(keepAlive: true)
VoiceAudioRecorder voiceAudioRecorder(Ref ref) {
  final logger = ref.read(namedLoggerProvider('VoiceAudioRecorder'));
  final recorder = RecordPackageVoiceAudioRecorder();
  ref.onDispose(() {
    unawaited(
      recorder.dispose().catchError(
        (Object e, StackTrace st) {
          logger.w(
            'voiceAudioRecorder.dispose() failed during teardown',
            error: e,
            stackTrace: st,
          );
        },
        // Only swallow recoverable failures — `Error` subtypes signal
        // programming bugs (e.g. LateInitializationError) and must propagate.
        test: (e) => e is Exception,
      ),
    );
  });
  return recorder;
}

/// [VoiceAudioRecorder] backed by the `record` package, streaming PCM into
/// a [BytesBuilder] and prepending a WAV header on [stop].
class RecordPackageVoiceAudioRecorder implements VoiceAudioRecorder {
  RecordPackageVoiceAudioRecorder({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  static const _config = RecordConfig(
    encoder: AudioEncoder.pcm16bits,
    sampleRate: 16000,
    numChannels: 1,
    // Disabling AGC/echo cancellation keeps the audio close to what the
    // model was trained on; the platform DSP defaults can muddy speech.
    autoGain: false,
    echoCancel: false,
    noiseSuppress: false,
  );

  final AudioRecorder _recorder;

  StreamSubscription<Uint8List>? _subscription;
  BytesBuilder? _buffer;
  Object? _streamError;
  StackTrace? _streamErrorStack;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<void> start() async {
    if (_subscription != null) {
      throw StateError('VoiceAudioRecorder already recording');
    }
    final stream = await _recorder.startStream(_config);
    final buffer = BytesBuilder(copy: false);
    _buffer = buffer;
    _streamError = null;
    _streamErrorStack = null;
    _subscription = stream.listen(
      buffer.add,
      onError: (Object error, StackTrace stack) {
        // Latch the first stream error so stop() can rethrow it instead of
        // silently returning a truncated WAV.
        if (_streamError == null) {
          _streamError = error;
          _streamErrorStack = stack;
        }
      },
      cancelOnError: true,
    );
  }

  @override
  Future<Uint8List> stop() async {
    final subscription = _subscription;
    final buffer = _buffer;
    final streamError = _streamError;
    final streamErrorStack = _streamErrorStack;
    if (subscription == null || buffer == null) {
      throw StateError('VoiceAudioRecorder.stop() called before start()');
    }
    _subscription = null;
    _buffer = null;
    _streamError = null;
    _streamErrorStack = null;
    try {
      await _recorder.stop();
    } finally {
      // Always tear down the subscription — leaving it attached after a
      // failed stop() leaks the native stream and breaks the next start().
      await subscription.cancel();
    }
    if (streamError != null) {
      // Force the typed catch in callers to fire even if the platform
      // surfaced a non-Exception error; preserve the original stack.
      Error.throwWithStackTrace(
        _RecorderStreamException(streamError),
        streamErrorStack ?? StackTrace.current,
      );
    }
    return wrapPcmAsWav(buffer.toBytes());
  }

  @override
  Future<void> cancel() async {
    final subscription = _subscription;
    _subscription = null;
    _buffer = null;
    _streamError = null;
    _streamErrorStack = null;
    if (subscription == null) {
      return;
    }
    try {
      await _recorder.cancel();
    } finally {
      await subscription.cancel();
    }
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _recorder.dispose();
  }
}

class _RecorderStreamException implements Exception {
  _RecorderStreamException(this.cause);
  final Object cause;

  @override
  String toString() => 'RecorderStreamException: $cause';
}
