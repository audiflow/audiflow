import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'voice_audio_recorder.dart';

part 'gemma_voice_capture_providers.g.dart';

/// Mic recorder for the Gemma 4 voice command path.
///
/// keepAlive because the underlying `record` plugin holds a native
/// `AVAudioRecorder` / `MediaRecorder` instance; recreating it per voice
/// turn would re-pay the platform-channel initialization cost. Disposed
/// when the provider container shuts down.
@Riverpod(keepAlive: true)
VoiceAudioRecorder voiceAudioRecorder(Ref ref) {
  final recorder = RecordPackageVoiceAudioRecorder();
  ref.onDispose(() => unawaited(recorder.dispose()));
  return recorder;
}
