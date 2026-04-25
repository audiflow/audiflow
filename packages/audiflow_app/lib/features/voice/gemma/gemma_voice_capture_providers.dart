import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
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
  // Capture the logger eagerly: by the time onDispose runs, ref.read may
  // be unsafe and we'd lose the breadcrumb if dispose() rejects.
  final logger = ref.read(namedLoggerProvider('GemmaVoiceCapture'));
  final recorder = RecordPackageVoiceAudioRecorder();
  ref.onDispose(() {
    unawaited(
      recorder.dispose().catchError((Object e, StackTrace st) {
        logger.w(
          'voiceAudioRecorder.dispose() failed during teardown',
          error: e,
          stackTrace: st,
        );
      }),
    );
  });
  return recorder;
}
