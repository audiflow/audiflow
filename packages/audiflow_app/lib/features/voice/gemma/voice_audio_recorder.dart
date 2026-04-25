import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

import 'wav_header.dart';

/// Captures one short utterance from the device microphone for the Gemma 4
/// voice command path.
///
/// Implementations record raw 16 kHz mono 16-bit PCM and return a complete
/// WAV payload from [stop]; recorders that fail mid-capture must surface a
/// real exception rather than returning a truncated buffer. [cancel] is the
/// no-result counterpart used when the user releases the trigger early or
/// the controller times out.
abstract interface class VoiceAudioRecorder {
  Future<bool> hasPermission();

  /// Begin streaming microphone audio into an internal buffer. Idempotent
  /// failure: re-calling start without an intervening [stop] / [cancel] is
  /// a programming error and may throw.
  Future<void> start();

  /// Stop recording and return the complete WAV payload. Throws
  /// [StateError] if [start] was not called.
  Future<Uint8List> stop();

  /// Discard any in-flight recording. Safe to call when idle.
  Future<void> cancel();

  Future<void> dispose();
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
    _subscription = stream.listen(
      buffer.add,
      onError: (Object error, StackTrace stack) {
        // Surface as an unhandled async error; the controller will catch
        // it via the Future returned by stop().
        _subscription?.cancel();
      },
      cancelOnError: true,
    );
  }

  @override
  Future<Uint8List> stop() async {
    final subscription = _subscription;
    final buffer = _buffer;
    if (subscription == null || buffer == null) {
      throw StateError('VoiceAudioRecorder.stop() called before start()');
    }
    _subscription = null;
    _buffer = null;
    await _recorder.stop();
    await subscription.cancel();
    return wrapPcmAsWav(buffer.toBytes());
  }

  @override
  Future<void> cancel() async {
    final subscription = _subscription;
    _subscription = null;
    _buffer = null;
    if (subscription == null) {
      return;
    }
    await _recorder.cancel();
    await subscription.cancel();
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _recorder.dispose();
  }
}
